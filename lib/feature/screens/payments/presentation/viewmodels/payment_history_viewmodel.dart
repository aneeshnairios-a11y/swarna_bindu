import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/payment_history_model.dart';
import '../data/repository/payments_repository.dart';

enum PaymentHistoryLoadStatus { idle, loading, loaded, error }

class PaymentHistoryState {
  const PaymentHistoryState({
    this.status = PaymentHistoryLoadStatus.idle,
    this.items = const [],
    this.pagination = const PaymentPaginationModel(),
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final PaymentHistoryLoadStatus status;
  final List<PaymentHistoryItemModel> items;
  final PaymentPaginationModel pagination;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get isLoading => status == PaymentHistoryLoadStatus.loading;
  bool get isError => status == PaymentHistoryLoadStatus.error;
  bool get hasMore => pagination.hasMore;
  bool get isEmpty => status == PaymentHistoryLoadStatus.loaded && items.isEmpty;

  PaymentHistoryState copyWith({
    PaymentHistoryLoadStatus? status,
    List<PaymentHistoryItemModel>? items,
    PaymentPaginationModel? pagination,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return PaymentHistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}

/// Bottom-scroll (infinite) pagination notifier — the screen calls
/// [loadMore] from a ScrollController listener near the list's end.
class PaymentHistoryNotifier extends Notifier<PaymentHistoryState> {
  static const _pageSize = 10;

  @override
  PaymentHistoryState build() => const PaymentHistoryState();

  Future<void> loadFirstPage() async {
    state = state.copyWith(status: PaymentHistoryLoadStatus.loading, errorMessage: null);

    final result = await ref.read(paymentsRepositoryProvider).getHistory(page: 1, limit: _pageSize);

    result.when(
      success: (data) {
        state = state.copyWith(
          status: PaymentHistoryLoadStatus.loaded,
          items: data.items,
          pagination: data.pagination,
        );
      },
      failure: (e) {
        state = state.copyWith(status: PaymentHistoryLoadStatus.error, errorMessage: e.message);
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.pagination.page + 1;
    final result = await ref
        .read(paymentsRepositoryProvider)
        .getHistory(page: nextPage, limit: _pageSize);

    result.when(
      success: (data) {
        state = state.copyWith(
          items: [...state.items, ...data.items],
          pagination: data.pagination,
          isLoadingMore: false,
        );
      },
      failure: (e) {
        // Keep existing items visible; only surface the error + stop the
        // loading indicator so the user can scroll-retry.
        state = state.copyWith(isLoadingMore: false, errorMessage: e.message);
      },
    );
  }

  Future<void> refresh() => loadFirstPage();
}

final paymentHistoryProvider =
NotifierProvider.autoDispose<PaymentHistoryNotifier, PaymentHistoryState>(
  PaymentHistoryNotifier.new,
);