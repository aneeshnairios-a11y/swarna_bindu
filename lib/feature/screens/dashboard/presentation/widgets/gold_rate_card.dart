import 'package:flutter/material.dart';

import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_spacing.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';

import '../../../../../core/formatter/app_formatters.dart';

class GoldRateCard extends StatelessWidget {
  const GoldRateCard({
    super.key,
    required this.rate22k,
    required this.rate24k,
    this.onTap,
  });

  final double rate22k;
  final double rate24k;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(gradient: AppColors.goldGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.workspace_premium_rounded, color: AppColors.textOnGold, size: 20),
                ),
                SizedBox(width: AppSpacing.md),
                Text("Today's Gold Rate", style: AppTypography.sectionTitleSM(color: textPrimary)),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _RateColumn(label: '22K Gold (1g)', value: AppFormatters.currencyDecimal(rate22k)),
                ),
                Container(width: 1, height: 32, color: border),
                Expanded(
                  child: _RateColumn(
                    label: '24K Gold (8g)',
                    value: AppFormatters.currencyDecimal(rate24k),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RateColumn extends StatelessWidget {
  const _RateColumn({required this.label, required this.value, this.alignEnd = false});

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption(color: AppColors.mutedGray)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.sectionTitleSM(color: textPrimary)),
        ],
      ),
    );
  }
}
