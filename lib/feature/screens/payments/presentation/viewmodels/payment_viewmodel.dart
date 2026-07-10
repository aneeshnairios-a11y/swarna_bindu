import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentMethod { upi, card, netBanking }

enum PaymentStatus { idle, processing, success, failure }

enum PaymentFlowStep { scheme, installment, payment, processing, success }

enum InstallmentType { currentMonth, pendingDues, advancePayment }

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
  });

  final PaymentMethod method;
  final PaymentStatus status;
  final String? errorMessage;
  final String? transactionId;
  final PaymentFlowStep step;
  final InstallmentType installmentType;

  bool get isProcessing => status == PaymentStatus.processing;
  bool get isSuccessful => status == PaymentStatus.success;

  PaymentState copyWith({
    PaymentMethod? method,
    PaymentStatus? status,
    String? errorMessage,
    String? transactionId,
    PaymentFlowStep? step,
    InstallmentType? installmentType,
    bool clearError = false,
  }) {
    return PaymentState(
      method: method ?? this.method,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      transactionId: transactionId ?? this.transactionId,
      step: step ?? this.step,
      installmentType: installmentType ?? this.installmentType,
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
      PaymentFlowStep.processing ||
      PaymentFlowStep.success => PaymentFlowStep.payment,
    };
    state = state.copyWith(step: previous);
  }

  /// Phase 1 mock payment. Replace with create-order → Razorpay → verify API
  /// calls in Phase 2; the UI remains driven by this same notifier state.
  Future<void> pay() async {
    state = state.copyWith(
      status: PaymentStatus.processing,
      step: PaymentFlowStep.processing,
      clearError: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    state = state.copyWith(
      status: PaymentStatus.success,
      step: PaymentFlowStep.success,
      transactionId:
          'BGS${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
    );
  }

  void reset() => state = const PaymentState();
}

final paymentProvider =
    NotifierProvider.autoDispose<PaymentNotifier, PaymentState>(
      PaymentNotifier.new,
    );
