import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../../core/router/route_name.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../../../../global_widgets/common_button.dart';
import '../../../../global_widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/gold_rate_card.dart';
import '../widgets/installment_due_card.dart';
import '../widgets/promo_banner_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/savings_hero_card.dart';
import '../widgets/scheme_summary_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fresh data every time the dashboard is opened (a payment, join or
    // redemption elsewhere must be reflected).
    Future.microtask(() => ref.read(dashboardProvider.notifier).load());
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.errorRed),
      );
  }

  @override
  Widget build(BuildContext context) {
    // A failed pull-to-refresh keeps the stale data on screen and reports
    // the failure through a SnackBar instead.
    ref.listen<DashboardState>(dashboardProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.hasData &&
          prev?.errorMessage != next.errorMessage) {
        _showError(next.errorMessage!);
        ref.read(dashboardProvider.notifier).clearError();
      }
    });

    final state = ref.watch(dashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(bottom: false, child: _buildBody(context, state, isDark)),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardState state, bool isDark) {
    if (!state.hasData) {
      if (state.hasError) {
        return _ErrorView(
          message: state.errorMessage ?? AppStrings.common.genericError,
          onRetry: () => ref.read(dashboardProvider.notifier).load(),
        );
      }
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      );
    }

    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final schemes = state.mySchemes;

    return RefreshIndicator(
      color: AppColors.primaryGold,
      onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.screenV,
        ),
        children: [
          DashboardHeader(
            userName: state.userName,
            profileImageUrl: state.profilePictureUrl,
            unreadNotifications: state.unreadNotifications,
            onNotificationTap: () => context.push(RouteName.notifications),
          ),
          SizedBox(height: AppSpacing.xl),

          SavingsHeroCard(
            totalSavings: state.totalSavings,
            totalGoldGrams: state.totalGoldGrams,
            goalGoldGrams: state.goalGoldGrams,
            goalProgress: state.goalProgress,
          ),
          SizedBox(height: AppSpacing.lg),

          if (state.hasNextInstallment) ...[
            InstallmentDueCard(
              amount: state.nextInstallmentAmount,
              dueDate: state.nextInstallmentDate!,
              daysLeft: state.daysLeft,
              onTap: () {
                // TODO(Payments): context.push(RouteName.paymentPath(
                //   state.firstActiveScheme!.userSchemeId));
              },
            ),
            SizedBox(height: AppSpacing.xl),
          ] else
            SizedBox(height: AppSpacing.sm),

          Text(
            'Quick Actions',
            style: AppTypography.sectionTitle(color: textPrimary),
          ),
          SizedBox(height: AppSpacing.md),
          QuickActionsGrid(
            actions: [
              QuickAction(
                label: 'Pay Now',
                icon: Icons.qr_code_scanner_rounded,
                color: AppColors.successGreen,
                onTap: () {
                  // TODO(Payments): navigate to payment for the due scheme.
                },
              ),
              QuickAction(
                label: 'View History',
                icon: Icons.history_rounded,
                color: const Color(0xFF7C5CD6),
                onTap: () {
                  // TODO(Payments): context.push(RouteName.paymentHistory);
                },
              ),
              QuickAction(
                label: 'Join Scheme',
                icon: Icons.add_rounded,
                color: AppColors.primaryGoldDark,
                onTap: () => context.push(RouteName.schemes),
              ),
              QuickAction(
                label: 'Redeem Gold',
                icon: Icons.card_giftcard_rounded,
                color: AppColors.infoBlue,
                onTap: () => context.push(RouteName.redeemGold),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),

          GoldRateCard(
            rate22k: state.rate22k,
            rate24k: state.rate24k,
            onTap: () {
              // TODO(Gold Rate): context.push(RouteName.goldRates);
            },
          ),
          SizedBox(height: AppSpacing.xl),

          Text(
            'My Schemes',
            style: AppTypography.sectionTitle(color: textPrimary),
          ),
          SizedBox(height: AppSpacing.md),
          if (schemes.isEmpty)
            _NoSchemesView(onExplore: () => context.push(RouteName.schemes))
          else
            ...schemes.map(
                  (s) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: SchemeSummaryCard(
                  name: s.schemeName,
                  monthlyInvestment: s.monthlyInvestment,
                  progressPercent: s.progressPercent,
                  paidGrams: s.goldAccumulated,
                  goalGrams: s.goalGoldGram,
                  statusLabel: s.isActive ? null : _statusLabel(s.status),
                  // Active schemes share the single account-level due date
                  // shown in the Installment card above, so none per card.
                  onTap: () {
                    // TODO(Enrollments): context.push(passbook for s.userSchemeId);
                  },
                ),
              ),
            ),
          SizedBox(height: AppSpacing.sm),

          PromoBannerCard(onExplore: () => context.push(RouteName.schemes)),
          SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return '—';
    final lower = status.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: AppColors.mutedGray,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(color: textPrimary),
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              text: 'Try again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSchemesView extends StatelessWidget {
  const _NoSchemesView({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.savings_outlined,
            size: 40,
            color: AppColors.primaryGoldDark,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            "You haven't joined any scheme yet",
            textAlign: TextAlign.center,
            style: AppTypography.sectionTitleSM(color: textPrimary),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Pick a plan and start building your gold savings.',
            textAlign: TextAlign.center,
            style: AppTypography.caption(color: AppColors.mutedGray),
          ),
          SizedBox(height: AppSpacing.lg),
          AppButton(text: 'Explore Schemes', onPressed: onExplore),
        ],
      ),
    );
  }
}