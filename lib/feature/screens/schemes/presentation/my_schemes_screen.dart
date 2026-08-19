import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../core/constants/image_string/image_strings.dart';
import '../../../../core/formatter/app_formatters.dart';
import '../../../global_widgets/common_button.dart';
import '../data/models/scheme_response_model.dart';
import '../schemes_viewmodel/schemes_notifier.dart';

/// My Schemes — Phase 2, wired to `GET /schemes/my-schemes` via
/// [mySchemesProvider].
///
/// Reached either from the dashboard/profile nav, or right after
/// `POST /schemes/:id/join` succeeds on [SchemeDetailScreen] — either way
/// this screen always re-fetches the live list on open (rather than
/// trusting the static join response), so a freshly joined scheme, an
/// updated payment total, or a redemption made elsewhere is always
/// reflected here.
class MySchemesScreen extends ConsumerStatefulWidget {
  const MySchemesScreen({super.key});

  @override
  ConsumerState<MySchemesScreen> createState() => _MySchemesScreenState();
}

class _MySchemesScreenState extends ConsumerState<MySchemesScreen> {
  @override
  void initState() {
    super.initState();
    // Always pull the latest list on open — don't rely on whatever was
    // cached from a previous visit (e.g. right after a fresh join).
    Future.microtask(() => ref.read(mySchemesProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final state = ref.watch(mySchemesProvider);

    return Scaffold(
      backgroundColor: bgColor,
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
                  Text('My Schemes', style: AppTypography.headingSM(color: textColor)),
                ],
              ),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MySchemesState state) {
    if (state.isLoading && state.schemes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.schemes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 40, color: AppColors.errorRed),
              SizedBox(height: AppSpacing.sm),
              Text(state.errorMessage!, textAlign: TextAlign.center),
              SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () => ref.read(mySchemesProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.schemes.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.savings_outlined, size: 40, color: mutedColor),
              SizedBox(height: AppSpacing.sm),
              Text(
                "You haven't joined any scheme yet.",
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(color: mutedColor),
              ),
              SizedBox(height: AppSpacing.md),
              AppButton(
                text: 'Browse Schemes',
                width: 200,
                onPressed: () => context.go(RouteName.schemes),
                backgroundColor: AppColors.maroonDark,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(mySchemesProvider.notifier).refresh(),
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.lg),
        itemCount: state.schemes.length,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) => _MySchemeCard(scheme: state.schemes[i]),
      ),
    );
  }
}

class _MySchemeCard extends StatelessWidget {
  const _MySchemeCard({required this.scheme});

  final MySchemeModel scheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final footerBg = isDark ? AppColors.goldSurfaceDark : AppColors.goldSurfaceLight;

    final statusBg = scheme.isRedeemed
        ? (isDark ? AppColors.processingBgDark : AppColors.processingBg)
        : (isDark ? AppColors.paidBgDark : AppColors.successGreenLight);
    final statusText = scheme.isRedeemed
        ? (isDark ? AppColors.processingTextDark : AppColors.processingText)
        : (isDark ? AppColors.paidTextDark : AppColors.successGreen);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.maroonDark,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(AppAssetImage.goldRate, fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scheme.schemeName,
                              style: AppTypography.sectionTitleSM(color: textColor),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Goal: ${AppFormatters.goldWeight(scheme.goalGoldGram)} · '
                                  '${AppFormatters.date(scheme.startDate)} – ${AppFormatters.date(scheme.endDate)}',
                              style: AppTypography.caption(color: mutedColor),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(scheme.status, style: AppTypography.labelSmall(color: statusText)),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  Container(height: 1, color: border),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCell(
                          label: 'Total Paid',
                          value: AppFormatters.currency(scheme.totalPaid),
                          textColor: textColor,
                          mutedColor: mutedColor,
                        ),
                      ),
                      Expanded(
                        child: _StatCell(
                          label: scheme.isRedeemed ? 'Redeemed Gold' : 'Total Gold',
                          value: AppFormatters.goldWeightShort(
                            scheme.isRedeemed ? (scheme.redeemedGoldGram ?? 0) : scheme.goldAccumulated,
                          ),
                          textColor: textColor,
                          mutedColor: mutedColor,
                        ),
                      ),
                      Expanded(
                        child: _StatCell(
                          label: 'Progress',
                          value: '${scheme.progressPercent}%',
                          textColor: textColor,
                          mutedColor: mutedColor,
                        ),
                      ),
                    ],
                  ),
                  if (!scheme.isRedeemed) ...[
                    SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      child: LinearProgressIndicator(
                        value: (scheme.progressPercent.clamp(0, 100)) / 100,
                        minHeight: 6,
                        backgroundColor: border,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primaryGold),
                      ),
                    ),
                  ],
                  if (scheme.isRedeemed && scheme.redeemedAt != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Redeemed on ${AppFormatters.date(scheme.redeemedAt!)} for '
                          '${AppFormatters.currency(scheme.redeemedValue ?? 0)}',
                      style: AppTypography.caption(color: mutedColor),
                    ),
                  ],
                ],
              ),
            ),
            if (scheme.isActive) ...[
              SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                color: footerBg.withValues(alpha: 0.5),
                child: AppButton(
                  text: 'Pay',
                  onPressed: () => context.push(RouteName.paymentPath(scheme.id)),
                  height: 46,
                  backgroundColor: AppColors.maroonDark,
                  textColor: Colors.white,
                ),
              ),
            ] else
              SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption(color: mutedColor)),
        SizedBox(height: 4),
        Text(value, style: AppTypography.sectionTitleSM(color: textColor)),
      ],
    );
  }
}