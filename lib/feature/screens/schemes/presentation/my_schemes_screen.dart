import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../core/constants/image_string/image_strings.dart';
import '../../../../core/formatter/app_formatters.dart';
import '../../../global_widgets/common_button.dart';
import '../data/models/scheme_response_model.dart';

/// Shown right after `POST /schemes/:id/join` succeeds on
/// [SchemeDetailScreen]. A brand-new enrollment always starts at ₹0 paid /
/// 0g gold / 0 pending installments, so [totalPaid]/[totalGoldGrams]/
/// [pendingCount] default to 0 — the join response itself doesn't carry
/// running totals (see [UserSchemeModel]). Once the user makes a payment,
/// those figures live in `GET /schemes/my-schemes` (`MySchemeModel`)
/// instead, surfaced on the schemes-list screen, not here.
class MySchemesScreen extends StatelessWidget {
  const MySchemesScreen({
    super.key,
    required this.userScheme,
    this.totalPaid = 0,
    this.totalGoldGrams = 0.0,
    this.pendingCount = 0,
  });

  final UserSchemeModel userScheme;
  final num totalPaid;
  final double totalGoldGrams;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final footerBg = isDark ? AppColors.goldSurfaceDark : AppColors.goldSurfaceLight;

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
                  Text(
                    'My Schemes',
                    style: AppTypography.headingSM(color: textColor),
                  ),
                ],
              ),
            ),

            // ── Enrollment card ─────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ClipRRect(
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
                                    child: Image.asset(
                                      AppAssetImage.goldRate,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userScheme.schemeName,
                                        style: AppTypography.sectionTitleSM(color: textColor),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Goal: ${AppFormatters.goldWeight(userScheme.goalGoldGram)} · '
                                            '${AppFormatters.date(userScheme.startDate)} – ${AppFormatters.date(userScheme.endDate)}',
                                        style: AppTypography.caption(color: mutedColor),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.paidBgDark
                                        : AppColors.successGreenLight,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                  ),
                                  child: Text(
                                    userScheme.status,
                                    style: AppTypography.labelSmall(
                                      color: isDark ? AppColors.paidTextDark : AppColors.successGreen,
                                    ),
                                  ),
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
                                    value: AppFormatters.currency(totalPaid),
                                    textColor: textColor,
                                    mutedColor: mutedColor,
                                  ),
                                ),
                                Expanded(
                                  child: _StatCell(
                                    label: 'Total Gold',
                                    value: AppFormatters.goldWeightShort(totalGoldGrams),
                                    textColor: textColor,
                                    mutedColor: mutedColor,
                                  ),
                                ),
                                Expanded(
                                  child: _StatCell(
                                    label: 'Pending',
                                    value: '$pendingCount',
                                    textColor: textColor,
                                    mutedColor: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        color: footerBg.withValues(alpha: 0.5),
                        child: AppButton(
                          text: 'pay',
                          onPressed: () => context.push(RouteName.paymentPath(userScheme.id)),
                          height: 46,
                          backgroundColor: AppColors.maroonDark,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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