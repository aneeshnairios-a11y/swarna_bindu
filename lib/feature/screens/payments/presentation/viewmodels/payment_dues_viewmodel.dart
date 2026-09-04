import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/payment_dues_model.dart';
import '../data/repository/payments_repository.dart';

enum PaymentDuesLoadStatus { idle, loading, loaded, error }

/// Powers the Payments landing screen (`checkout_screen.dart`) — the
/// aggregate "Next Due Amount" hero card plus the "Your Schemes" list.
/// Kept separate from PaymentNotifier's dues fetch (checkout flow), since
/// the landing screen isn't scoped to a single scheme.
class PaymentDuesState {
  const PaymentDuesState({
    this.status = PaymentDuesLoadStatus.idle,
    this.dues,
    this.errorMessage,
  });

  final PaymentDuesLoadStatus status;
  final PaymentDuesModel? dues;
  final String? errorMessage;

  bool get isLoading => status == PaymentDuesLoadStatus.loading;
  bool get isError => status == PaymentDuesLoadStatus.error;

  PaymentDuesState copyWith({
    PaymentDuesLoadStatus? status,
    PaymentDuesModel? dues,
    String? errorMessage,
  }) {
    return PaymentDuesState(
      status: status ?? this.status,
      dues: dues ?? this.dues,
      errorMessage: errorMessage,
    );
  }
}

class PaymentDuesNotifier extends Notifier<PaymentDuesState> {
  @override
  PaymentDuesState build() => const PaymentDuesState();

  Future<void> loadDues() async {
    state = state.copyWith(status: PaymentDuesLoadStatus.loading, errorMessage: null);

    final result = await ref.read(paymentsRepositoryProvider).getDues();

    result.when(
      success: (data) {
        state = state.copyWith(status: PaymentDuesLoadStatus.loaded, dues: data);
      },
      failure: (e) {
        state = state.copyWith(status: PaymentDuesLoadStatus.error, errorMessage: e.message);
      },
    );
  }

  Future<void> refresh() => loadDues();
}

final paymentDuesProvider = NotifierProvider.autoDispose<PaymentDuesNotifier, PaymentDuesState>(
  PaymentDuesNotifier.new,
);