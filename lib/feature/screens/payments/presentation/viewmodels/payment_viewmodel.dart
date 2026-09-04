import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/payment_dues_model.dart';
import '../data/models/payment_initialize_model.dart';
import '../data/models/payment_verify_model.dart';
import '../data/repository/payments_repository.dart';

enum PaymentMethod { upi, card, netBanking }

extension PaymentMethodX on PaymentMethod {
  /// String sent as `paymentMethod` to POST /payments/verify.
  String get apiLabel => switch (this) {
    PaymentMethod.upi => 'UPI - Google Pay',
    PaymentMethod.card => 'Card',
    PaymentMethod.netBanking => 'Net Banking',
  };
}

enum PaymentStatus { idle, processing, success, failure }

enum PaymentFlowStep { scheme, installment, payment, processing, success }

enum InstallmentType { currentMonth, pendingDues, advancePayment }

extension InstallmentTypeX on InstallmentType {
  /// String sent as `installmentType` to POST /payments/initialize.
  String get apiValue => switch (this) {
    InstallmentType.currentMonth => 'CURRENT_MONTH',
    InstallmentType.pendingDues => 'PENDING_DUES',
    InstallmentType.advancePayment => 'ADVANCE_PAYMENT',
  };
}

enum DuesLoadStatus { idle, loading, loaded, error }

/// Kept for compatibility with any existing navigation/routes that still
/// reference a standalone receipt shape (e.g. RouteName.paymentSuccess).
/// Not used by the real checkout flow below — see PaymentVerifyModel.
class PaymentReceipt {
  const PaymentReceipt({
    required this.enrollmentId,
    required this.amount,
    required this.transactionId,
    required this.method,
  });

  final String enrollmentId;
  final double amount;
  final String transactionId;
  final PaymentMethod method;
}

class PaymentState {
  const PaymentState({
    this.method = PaymentMethod.upi,
    this.status = PaymentStatus.idle,
    this.errorMessage,
    this.transactionId,
    this.step = PaymentFlowStep.scheme,
    this.installmentType = InstallmentType.currentMonth,
    this.userSchemeId,
    this.duesStatus = DuesLoadStatus.idle,
    this.dues,
    this.duesErrorMessage,
    this.initializeResult,
    this.verifyResult,
  });

  final PaymentMethod method;
  final PaymentStatus status;
  final String? errorMessage;
  final String? transactionId;
  final PaymentFlowStep step;
  final InstallmentType installmentType;

  /// The scheme this checkout session is for (route's enrollmentId is
  /// treated as the userSchemeId — see CheckoutScreen).
  final String? userSchemeId;

  final DuesLoadStatus duesStatus;
  final PaymentDuesModel? dues;
  final String? duesErrorMessage;

  final PaymentInitializeModel? initializeResult;
  final PaymentVerifyModel? verifyResult;

  bool get isProcessing => status == PaymentStatus.processing;
  bool get isSuccessful => status == PaymentStatus.success;
  bool get isFailed => status == PaymentStatus.failure;
  bool get isDuesLoading => duesStatus == DuesLoadStatus.loading;
  bool get isDuesError => duesStatus == DuesLoadStatus.error;

  /// The specific scheme's due info, resolved once dues + userSchemeId are
  /// both available.
  DueSchemeModel? get selectedScheme {
    final id = userSchemeId;
    if (dues == null || id == null) return null;
    return dues!.schemeById(id);
  }

  bool get hasPendingDues => selectedScheme?.hasPendingDues ?? false;

  /// The amount to charge for the currently-selected installment type.
  num get selectedAmount {
    final scheme = selectedScheme;
    if (scheme == null) return 0;
    return switch (installmentType) {
      InstallmentType.currentMonth => scheme.nextDueAmount,
      InstallmentType.pendingDues => scheme.pendingAmount,
      InstallmentType.advancePayment => scheme.advanceAmount,
    };
  }

  PaymentState copyWith({
    PaymentMethod? method,
    PaymentStatus? status,
    String? errorMessage,
    String? transactionId,
    PaymentFlowStep? step,
    InstallmentType? installmentType,
    String? userSchemeId,
    DuesLoadStatus? duesStatus,
    PaymentDuesModel? dues,
    String? duesErrorMessage,
    PaymentInitializeModel? initializeResult,
    PaymentVerifyModel? verifyResult,
    bool clearError = false,
  }) {
    return PaymentState(
      method: method ?? this.method,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      transactionId: transactionId ?? this.transactionId,
      step: step ?? this.step,
      installmentType: installmentType ?? this.installmentType,
      userSchemeId: userSchemeId ?? this.userSchemeId,
      duesStatus: duesStatus ?? this.duesStatus,
      dues: dues ?? this.dues,
      duesErrorMessage: duesErrorMessage,
      initializeResult: initializeResult ?? this.initializeResult,
      verifyResult: verifyResult ?? this.verifyResult,
    );
  }
}

class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => const PaymentState();

  void selectMethod(PaymentMethod method) {
    if (!state.isProcessing) {
      state = state.copyWith(method: method, clearError: true);
    }
  }

  void selectInstallment(InstallmentType type) {
    state = state.copyWith(installmentType: type);
  }

  void goTo(PaymentFlowStep step) => state = state.copyWith(step: step);

  void goBack() {
    final previous = switch (state.step) {
      PaymentFlowStep.scheme => PaymentFlowStep.scheme,
      PaymentFlowStep.installment => PaymentFlowStep.scheme,
      PaymentFlowStep.payment => PaymentFlowStep.installment,
      PaymentFlowStep.processing || PaymentFlowStep.success => PaymentFlowStep.payment,
    };
    state = state.copyWith(step: previous);
  }

  /// Call once when the checkout flow opens for a given scheme
  /// (userSchemeId comes from the route's enrollmentId param).
  Future<void> loadDues(String userSchemeId) async {
    state = state.copyWith(
      userSchemeId: userSchemeId,
      duesStatus: DuesLoadStatus.loading,
      duesErrorMessage: null,
    );

    final result = await ref.read(paymentsRepositoryProvider).getDues();
    if (!ref.mounted) return;

    result.when(
      success: (data) {
        state = state.copyWith(dues: data, duesStatus: DuesLoadStatus.loaded);
      },
      failure: (e) {
        state = state.copyWith(duesStatus: DuesLoadStatus.error, duesErrorMessage: e.message);
      },
    );
  }

  Future<void> retryLoadDues() {
    final id = state.userSchemeId;
    if (id == null) return Future.value();
    return loadDues(id);
  }

  /// initialize -> verify, in sequence. Sets [PaymentState.errorMessage] and
  /// [PaymentStatus.failure] on either step's failure — never silently
  /// "succeeds" the way the old mock did.
  Future<void> pay() async {
    final scheme = state.selectedScheme;
    final userSchemeId = state.userSchemeId;
    if (scheme == null || userSchemeId == null) {
      state = state.copyWith(
        status: PaymentStatus.failure,
        step: PaymentFlowStep.processing,
        errorMessage: 'Scheme details not found. Please go back and try again.',
      );
      return;
    }

    state = state.copyWith(
      status: PaymentStatus.processing,
      step: PaymentFlowStep.processing,
      clearError: true,
    );

    final repo = ref.read(paymentsRepositoryProvider);

    final initResult = await repo.initializePayment(
      userSchemeId: userSchemeId,
      installmentType: state.installmentType.apiValue,
      amount: state.selectedAmount,
    );
    if (!ref.mounted) return;

    String? txnId;
    final initFailed = initResult.when(
      success: (data) {
        txnId = data.transactionId;
        state = state.copyWith(initializeResult: data, transactionId: data.transactionId);
        return false;
      },
      failure: (e) {
        state = state.copyWith(status: PaymentStatus.failure, errorMessage: e.message);
        return true;
      },
    );
    if (initFailed || txnId == null || txnId!.isEmpty) return;

    final verifyResult = await repo.verifyPayment(
      transactionId: txnId!,
      status: 'SUCCESSFUL',
      paymentMethod: state.method.apiLabel,
    );
    if (!ref.mounted) return;

    verifyResult.when(
      success: (data) {
        state = state.copyWith(
          status: PaymentStatus.success,
          step: PaymentFlowStep.success,
          verifyResult: data,
          transactionId: data.payment.transactionId,
        );
      },
      failure: (e) {
        state = state.copyWith(status: PaymentStatus.failure, errorMessage: e.message);
      },
    );
  }

  /// Lets the Processing step's "Try Again" button re-attempt from the
  /// Method step without losing the loaded dues/selection.
  void retryPayment() {
    state = state.copyWith(
      status: PaymentStatus.idle,
      step: PaymentFlowStep.payment,
      clearError: true,
    );
  }

  void reset() => state = const PaymentState();
}

final paymentProvider = NotifierProvider.autoDispose<PaymentNotifier, PaymentState>(
  PaymentNotifier.new,
);