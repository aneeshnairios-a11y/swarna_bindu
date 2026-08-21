import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/gold_rate_model.dart';
import '../../data/repository/gold_rate_repository.dart';

enum GoldRateStatus { idle, loading, success, error }

class GoldRateState {
  const GoldRateState({
    this.status = GoldRateStatus.idle,
    this.rate,
    this.errorMessage,
  });

  final GoldRateStatus status;
  final GoldRateModel? rate;
  final String? errorMessage;

  bool get isLoading => status == GoldRateStatus.loading;
  bool get hasError => status == GoldRateStatus.error;

  GoldRateState copyWith({
    GoldRateStatus? status,
    GoldRateModel? rate,
    String? errorMessage,
  }) {
    return GoldRateState(
      status: status ?? this.status,
      rate: rate ?? this.rate,
      errorMessage: errorMessage,
    );
  }
}

/// Plain autoDispose Notifier — no family/generator needed since this
/// screen has no per-argument state (single "today's rate" fetch), same
/// reasoning as SchemeDetailNotifier's manual-notifier note in Section 6A.
class GoldRateNotifier extends Notifier<GoldRateState> {
  @override
  GoldRateState build() => const GoldRateState();

  Future<void> loadRate() async {
    state = state.copyWith(status: GoldRateStatus.loading, errorMessage: null);

    final result = await ref.read(goldRateRepositoryProvider).getTodayRate();

    result.when(
      success: (rate) {
        state = state.copyWith(status: GoldRateStatus.success, rate: rate);
      },
      failure: (e) {
        state = state.copyWith(
          status: GoldRateStatus.error,
          errorMessage: e.message,
        );
      },
    );
  }
}

final goldRateProvider =
NotifierProvider.autoDispose<GoldRateNotifier, GoldRateState>(
  GoldRateNotifier.new,
);