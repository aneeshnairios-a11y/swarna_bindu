import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../../core/router/route_name.dart';
import '../viewmodels/dashboard_viewmodel.dart';
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
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryGold,
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenH, vertical: AppSpacing.screenV),
            children: [
              DashboardHeader(
                userName: state.userName,
                unreadNotifications: state.unreadNotifications,
                onNotificationTap: () {
                 context.push(RouteName.notifications);
                },
              ),
              SizedBox(height: AppSpacing.xl),

              SavingsHeroCard(
                totalSavings: state.totalSavings,
                totalGoldGrams: state.totalGoldGrams,
                goalGoldGrams: state.goalGoldGrams,
                goalProgress: state.goalProgress,
              ),
              SizedBox(height: AppSpacing.lg),

              InstallmentDueCard(
                amount: state.nextInstallmentAmount,
                dueDate: state.nextInstallmentDate,
                daysLeft: state.daysLeft,
                onTap: () {
                  // TODO(Phase 2): context.push(RouteName.paymentPath(enrollmentId));
                },
              ),
              SizedBox(height: AppSpacing.xl),

              Text('Quick Actions', style: AppTypography.sectionTitle(color: textPrimary)),
              SizedBox(height: AppSpacing.md),
              QuickActionsGrid(
                actions: [
                  QuickAction(
                    label: 'Pay Now',
                    icon: Icons.qr_code_scanner_rounded,
                    color: AppColors.successGreen,
                    onTap: () {},
                  ),
                  QuickAction(
                    label: 'View History',
                    icon: Icons.history_rounded,
                    color: const Color(0xFF7C5CD6),
                    onTap: () {},
                  ),
                  QuickAction(
                    label: 'Join Scheme',
                    icon: Icons.add_rounded,
                    color: AppColors.primaryGoldDark,
                    onTap: () {},
                  ),
                  QuickAction(
                    label: 'Redeem Gold',
                    icon: Icons.card_giftcard_rounded,
                    color: AppColors.infoBlue,
                    onTap: () {
                      context.push(RouteName.redeemGold);
                    },
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),

              GoldRateCard(
                rate22k: state.rate22k,
                rate24k: state.rate24k,
                onTap: () {
                  // TODO(Phase 2): context.push(RouteName.goldRates);
                },
              ),
              SizedBox(height: AppSpacing.xl),

              Text('My Schemes', style: AppTypography.sectionTitle(color: textPrimary)),
              SizedBox(height: AppSpacing.md),
              ...state.mySchemes.map(
                (s) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: SchemeSummaryCard(
                    name: s.name,
                    monthlyInvestment: s.monthlyInvestment,
                    nextDueDate: s.nextDueDate,
                    progressPercent: s.progressPercent,
                    paidGrams: s.paidGrams,
                    goalGrams: s.goalGrams,
                    onTap: () {
                      // TODO(Phase 2): context.push(RouteName.passbookPath(s.id));
                    },
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sm),

              PromoBannerCard(
                onExplore: () {
                  // TODO(Phase 2): context.push(RouteName.schemes);
                },
              ),
              SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}
