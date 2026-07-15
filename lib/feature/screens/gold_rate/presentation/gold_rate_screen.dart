import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/formatter/app_formatters.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../global_widgets/common_button.dart';
import '../../../global_widgets/dashboard_bottom_nav.dart';

/// Gold Rate screen — today's 22k/24k rate card + a note about live pricing.
///
/// Phase 1: values are static placeholders. In Phase 2 this reads from
/// `GET /gold-rates/today` via a Riverpod AsyncNotifier.
class GoldRateScreen extends StatefulWidget {
  const GoldRateScreen({super.key});

  @override
  State<GoldRateScreen> createState() => _GoldRateScreenState();
}

class _GoldRateScreenState extends State<GoldRateScreen> {
  int _navIndex = 3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    onTap: () => context.go(RouteName.dashboard),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: textColor,
                        size: AppSpacing.iconLg,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Gold Rate',
                    style: AppTypography.headingSM(color: textColor),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RateCard(
                      onJoinScheme: () {
                        // TODO: navigate to scheme listing / enrollment flow
                      },
                    ),
                    SizedBox(height: AppSpacing.lg),
                    const _LiveRateNotice(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.onJoinScheme});

  final VoidCallback onJoinScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroonDark.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Today's Gold Rate",
            style: AppTypography.sectionTitleSM(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _RateColumn(
                    label: '22k Gold (1g)',
                    amount: AppFormatters.currencyDecimal(13250),
                  ),
                ),
                Container(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                Expanded(
                  child: _RateColumn(
                    label: '24k Gold (8g)',
                    amount: AppFormatters.currencyDecimal(106000),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          AppButton(
            text: 'Join Scheme',
            onPressed: onJoinScheme,
            backgroundColor: Colors.white,
            textColor: AppColors.maroonDark,
          ),
        ],
      ),
    );
  }
}

class _RateColumn extends StatelessWidget {
  const _RateColumn({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.bodyXSmall(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          amount,
          textAlign: TextAlign.center,
          style: AppTypography.currencyAmountSM(
            color: AppColors.primaryGoldLight,
          ),
        ),
      ],
    );
  }
}

class _LiveRateNotice extends StatelessWidget {
  const _LiveRateNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.goldSurfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.goldBorderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.maroonDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Gold Rate Are Updated In Real Time Based On Market Price. Price May Vary In Stores',
              style: AppTypography.caption(color: AppColors.textSecondaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
