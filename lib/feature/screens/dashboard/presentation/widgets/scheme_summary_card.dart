import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/image_string/image_strings.dart';
import '../../../../../core/formatter/app_formatters.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class SchemeSummaryCard extends StatelessWidget {
  const SchemeSummaryCard({
    super.key,
    required this.name,
    required this.monthlyInvestment,
    required this.nextDueDate,
    required this.progressPercent,
    required this.paidGrams,
    required this.goalGrams,
    this.onTap,
  });

  final String name;
  final double monthlyInvestment;
  final DateTime nextDueDate;
  final double progressPercent; // 0 - 100
  final double paidGrams;
  final double goalGrams;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72.w,
                  height: 74.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    image: const DecorationImage(
                      image: AssetImage(AppAssetImage.jewellery),
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
                        name,
                        style: AppTypography.sectionTitleSM(color: textPrimary),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _InfoBlock(
                              label: 'Monthly Investment',
                              value: AppFormatters.currency(monthlyInvestment),
                            ),
                          ),
                          _InfoBlock(
                            label: 'Next Due date',
                            value: AppFormatters.date(nextDueDate),
                            alignEnd: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  '${progressPercent.round()}% Completed',
                  style: AppTypography.caption(color: AppColors.mutedGray),
                ),
                const Spacer(),
                Text(
                  '${AppFormatters.goldWeightShort(paidGrams)} / ${goalGrams.toStringAsFixed(0)}g',
                  style: AppTypography.caption(color: AppColors.mutedGray),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: (progressPercent / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.successGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.hint(color: AppColors.mutedGray)),
        Text(value, style: AppTypography.labelMedium(color: textPrimary)),
      ],
    );
  }
}
