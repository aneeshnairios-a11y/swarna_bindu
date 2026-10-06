import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:swarna_bindu/core/network/api_endpoints.dart';

import '../../data/models/dashboard_response_model.dart';
import '../../data/repository/dashboard_repository.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.data,
    this.errorMessage,
    this.isRefreshing = false,
    this.unreadNotifications = 0,
  });

  final DashboardStatus status;
  final DashboardData? data;
  final String? errorMessage;
  final bool isRefreshing;

  /// Not provided by GET /user/dashboard — wired up with the Notifications feature.
  final int unreadNotifications;

  bool get isLoading => status == DashboardStatus.loading;
  bool get hasError => status == DashboardStatus.error;
  bool get hasData => data != null;

  // ── Derived values the existing widgets bind to ─────────────────
  String get userName {
    final name = data?.user.fullName.trim() ?? '';
    return name.isEmpty ? 'Guest' : name;
  }

  String? get profilePicturePath => data?.user.profilePicture;

  List<PortfolioScheme> get mySchemes => data?.portfolio ?? const [];

  double get totalSavings => data?.summary.totalAmountPaid ?? 0;
  double get currentGoldValue => data?.summary.currentGoldValue ?? 0;
  double get totalGoldGrams => data?.summary.totalGramsSaved ?? 0;

  /// API has no overall goal → sum of every active scheme's goal.
  double get goalGoldGrams => mySchemes
      .where((s) => s.isActive)
      .fold<double>(0, (sum, s) => sum + s.goalGoldGram);

  /// 0.0 – 1.0, gold accumulated vs. the combined goal.
  double get goalProgress {
    final activeGold = mySchemes
        .where((s) => s.isActive)
        .fold<double>(0, (sum, s) => sum + s.goldAccumulated);
    if (goalGoldGrams <= 0) return 0;
    return (activeGold / goalGoldGrams).clamp(0.0, 1.0);
  }

  double get rate22k => data?.goldRate.rate22kPerGram ?? 0;
  double get rate24k => data?.goldRate.rate24kPer8g ?? 0;

  double get nextInstallmentAmount => data?.summary.nextInstallmentDue ?? 0;
  DateTime? get nextInstallmentDate => data?.summary.nextDueDate;

  /// True when something is due (an amount and a date exist).
  bool get hasNextInstallment =>
      nextInstallmentDate != null && nextInstallmentAmount > 0;

  /// Whole calendar days from today to the due date.
  /// Positive = days left, 0 = due today, negative = overdue by |n| days.
  int get daysLeft {
    final due = nextInstallmentDate;
    if (due == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    return dueDay.difference(today).inDays;
  }

  bool get isOverdue => hasNextInstallment && daysLeft < 0;

  /// The scheme to pay when the due card / "Pay Now" is tapped.
  PortfolioScheme? get firstActiveScheme {
    for (final s in mySchemes) {
      if (s.isActive) return s;
    }
    return null;
  }

  /// Absolute URL for the relative `profilePicture` path (host of the API).
  String? get profilePictureUrl {
    final p = profilePicturePath;
    if (p == null || p.isEmpty) return null;
    if (p.startsWith('http')) return p;
    final host = EnvConfig.baseUrl.replaceFirst(RegExp(r'/api/v\d+/?$'), '');
    return '$host${p.startsWith('/') ? '' : '/'}$p';
  }

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardData? data,
    String? errorMessage,
    bool? isRefreshing,
    int? unreadNotifications,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      // errorMessage intentionally NOT carried over — each copy clears it
      // unless explicitly set (same convention as KycState).
      errorMessage: errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
    );
  }
}

/// Plain `Notifier` (no family / codegen) — screen calls [load] once from
/// `initState`, pull-to-refresh calls [refresh].
class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() => const DashboardState();

  /// First load: shows the full-screen loader.
  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(status: DashboardStatus.loading);
    await _fetch();
  }

  /// Pull-to-refresh / return-from-other-screen: keeps showing the current
  /// data and only falls back to the error screen if nothing was loaded yet.
  Future<void> refresh() async {
    if (state.isLoading || state.isRefreshing) return;
    if (!state.hasData) {
      await load();
      return;
    }
    state = state.copyWith(isRefreshing: true, status: state.status);
    await _fetch();
  }

  Future<void> _fetch() async {
    final result = await ref.read(dashboardRepositoryProvider).getDashboard();

    result.when(
      success: (data) {
        state = state.copyWith(
          status: DashboardStatus.loaded,
          data: data,
          isRefreshing: false,
        );
      },
      failure: (e) {
        // Keep stale data visible on a failed refresh; surface the message
        // via errorMessage so the screen can show a SnackBar.
        state = state.copyWith(
          status: state.hasData ? DashboardStatus.loaded : DashboardStatus.error,
          errorMessage: e.message,
          isRefreshing: false,
        );
      },
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(status: state.status);
    }
  }
}

final dashboardProvider =
NotifierProvider.autoDispose<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);