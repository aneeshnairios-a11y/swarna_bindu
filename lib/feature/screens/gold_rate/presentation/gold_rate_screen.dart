import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/formatter/app_formatters.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../global_widgets/common_button.dart';
import '../../../global_widgets/dashboard_bottom_nav.dart';
import 'viewmodels/gold_rate_viewmodel.dart';

/// Gold Rate screen — today's 22k/24k rate card, live from
/// `GET /gold-rate/today`.
class GoldRateScreen extends ConsumerStatefulWidget {
  const GoldRateScreen({super.key});

  @override
  ConsumerState<GoldRateScreen> createState() => _GoldRateScreenState();
}

class _GoldRateScreenState extends ConsumerState<GoldRateScreen> {
  int _navIndex = 3;

  @override
  void initState() {
    super.initState();
    // Always fetch fresh on open — rate can move intraday, matching the
    // "never trust stale cache" convention used by MySchemesScreen.
    Future.microtask(() => ref.read(goldRateProvider.notifier).loadRate());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goldRateProvider);
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
              child: RefreshIndicator(
                color: AppColors.primaryGold,
                onRefresh: () =>
                    ref.read(goldRateProvider.notifier).loadRate(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRateArea(state, textColor),
                      SizedBox(height: AppSpacing.lg),
                      const _LiveRateNotice(),
                    ],
                  ),
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

  Widget _buildRateArea(GoldRateState state, Color textColor) {
    if (state.isLoading && state.rate == null) {
      return const _RateCardSkeleton();
    }

    if (state.hasError && state.rate == null) {
      return _RateCardError(
        message: state.errorMessage ?? 'Something went wrong.',
        onRetry: () => ref.read(goldRateProvider.notifier).loadRate(),
      );
    }

    final rate = state.rate;
    if (rate == null) return const _RateCardSkeleton();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RateCard(
          rate22k: rate.rate22KPerGram,
          rate24k: rate.rate24KPer8Gram,
          onJoinScheme: () => context.push(RouteName.schemes),
        ),
        SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            'Last updated: ${AppFormatters.dateTime(rate.lastUpdated.toLocal())}',
            style: AppTypography.caption(color: AppColors.textMutedLight),
          ),
        ),
      ],
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({
    required this.rate22k,
    required this.rate24k,
    required this.onJoinScheme,
  });

  final double rate22k;
  final double rate24k;
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
                    amount: AppFormatters.currencyDecimal(rate22k),
                  ),
                ),
                Container(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                Expanded(
                  child: _RateColumn(
                    label: '24k Gold (8g)',
                    amount: AppFormatters.currencyDecimal(rate24k),
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

/// Shown while the very first fetch is in flight (no cached rate yet).
class _RateCardSkeleton extends StatelessWidget {
  const _RateCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

/// Shown when the first fetch fails outright (nothing to display yet).
class _RateCardError extends StatelessWidget {
  const _RateCardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.errorRedLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: AppSpacing.iconXl),
          SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(color: AppColors.errorRed),
          ),
          SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Retry'),
          ),
        ],
      ),
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