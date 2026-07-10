import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ── Models ──────────────────────────────────────────────────────
/// Phase 1: plain mock models living next to the ViewModel.
/// Phase 2: move to `data/models` + map from API DTOs.

class SchemeSummary {
  const SchemeSummary({
    required this.id,
    required this.name,
    required this.monthlyInvestment,
    required this.nextDueDate,
    required this.progressPercent,
    required this.paidGrams,
    required this.goalGrams,
  });

  final String id;
  final String name;
  final double monthlyInvestment;
  final DateTime nextDueDate;
  final double progressPercent; // 0 - 100
  final double paidGrams;
  final double goalGrams;
}

class DashboardState {
  const DashboardState({
    required this.userName,
    required this.totalSavings,
    required this.totalGoldGrams,
    required this.goalGoldGrams,
    required this.goalProgress,
    required this.nextInstallmentAmount,
    required this.nextInstallmentDate,
    required this.daysLeft,
    required this.rate22k,
    required this.rate24k,
    required this.mySchemes,
    this.unreadNotifications = 0,
    this.isLoading = false,
  });

  final String userName;
  final double totalSavings;
  final double totalGoldGrams;
  final double goalGoldGrams;
  final double goalProgress; // 0.0 - 1.0
  final double nextInstallmentAmount;
  final DateTime nextInstallmentDate;
  final int daysLeft;
  final double rate22k;
  final double rate24k;
  final List<SchemeSummary> mySchemes;
  final int unreadNotifications;
  final bool isLoading;

  DashboardState copyWith({
    String? userName,
    double? totalSavings,
    double? totalGoldGrams,
    double? goalGoldGrams,
    double? goalProgress,
    double? nextInstallmentAmount,
    DateTime? nextInstallmentDate,
    int? daysLeft,
    double? rate22k,
    double? rate24k,
    List<SchemeSummary>? mySchemes,
    int? unreadNotifications,
    bool? isLoading,
  }) {
    return DashboardState(
      userName: userName ?? this.userName,
      totalSavings: totalSavings ?? this.totalSavings,
      totalGoldGrams: totalGoldGrams ?? this.totalGoldGrams,
      goalGoldGrams: goalGoldGrams ?? this.goalGoldGrams,
      goalProgress: goalProgress ?? this.goalProgress,
      nextInstallmentAmount: nextInstallmentAmount ?? this.nextInstallmentAmount,
      nextInstallmentDate: nextInstallmentDate ?? this.nextInstallmentDate,
      daysLeft: daysLeft ?? this.daysLeft,
      rate22k: rate22k ?? this.rate22k,
      rate24k: rate24k ?? this.rate24k,
      mySchemes: mySchemes ?? this.mySchemes,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// ── Notifier ────────────────────────────────────────────────────
/// Phase 2: replace [build]'s mock data with a repository call
/// (GET /users/:id, GET /gold-rates/today, GET /users/:id/enrollments)
/// wrapped in an AsyncNotifier.
class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return DashboardState(
      userName: 'John Mathew',
      totalSavings: 48000,
      totalGoldGrams: 18.400,
      goalGoldGrams: 25.000,
      goalProgress: 0.73,
      nextInstallmentAmount: 5000,
      nextInstallmentDate: DateTime(2026, 6, 5),
      daysLeft: 3,
      rate22k: 6730,
      rate24k: 11253.20,
      unreadNotifications: 2,
      mySchemes: [
        SchemeSummary(
          id: 'sch_swarna_bindu',
          name: 'Swarna Bindu',
          monthlyInvestment: 5000,
          progressPercent: 73,
          paidGrams: 18.400,
          goalGrams: 25,
          nextDueDate: DateTime(2026, 5, 5),
        ),
      ],
    );
  }

  /// Pull-to-refresh hook. Phase 2: refetch from API.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isLoading: false);
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);
