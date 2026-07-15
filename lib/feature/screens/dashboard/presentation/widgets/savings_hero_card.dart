import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../../core/formatter/app_formatters.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

/// Hero card shown at the top of the Dashboard — total savings, gold
/// accumulated, goal, and a circular progress ring toward the goal.
class SavingsHeroCard extends StatelessWidget {
  const SavingsHeroCard({
    super.key,
    required this.totalSavings,
    required this.totalGoldGrams,
    required this.goalGoldGrams,
    required this.goalProgress,
  });

  final double totalSavings;
  final double totalGoldGrams;
  final double goalGoldGrams;
  final double goalProgress; // 0.0 - 1.0

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroonDark.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Label('Total Savings Value'),
                const SizedBox(height: 4),
                _AmountText(totalSavings),
                SizedBox(height: AppSpacing.md),
                const _Label('Total Gold Accumulated'),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.goldWeight(totalGoldGrams),
                  style: AppTypography.sectionTitleSM(
                    color: AppColors.primaryGoldLight,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                const _Label('Your Goal'),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.goldWeight(goalGoldGrams),
                  style: AppTypography.sectionTitleSM(
                    color: AppColors.primaryGoldLight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          CircularPercentIndicator(
            radius: 65.r,
            lineWidth: 9,
            percent: goalProgress.clamp(0.0, 1.0),
            animation: true,
            animationDuration: 900,
            // Dark maroon track (not white-tinted) to match the ring
            // sitting flush against the card background.
            backgroundColor: Colors.black.withValues(alpha: 0.28),
            progressColor: AppColors.primaryGoldLight,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(goalProgress * 100).round()}%',
                  style: AppTypography.headingLG(color: Colors.white),
                ),
                Text(
                  'of your goal',
                  textAlign: TextAlign.center,
                  style: AppTypography.hint(
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ₹48,000.00 — whole amount bold & full-size, the trailing ".00" rendered
/// smaller and lighter, matching the reference design.
class _AmountText extends StatelessWidget {
  const _AmountText(this.value);
  final double value;

  @override
  Widget build(BuildContext context) {
    final formatted = AppFormatters.currencyDecimal(value); // e.g. ₹48,000.00
    final dotIndex = formatted.lastIndexOf('.');
    final whole = dotIndex == -1 ? formatted : formatted.substring(0, dotIndex);
    final decimals = dotIndex == -1 ? '' : formatted.substring(dotIndex);

    return RichText(
      text: TextSpan(
        style: AppTypography.headingLG(color: AppColors.primaryGoldLight),
        children: [
          TextSpan(text: whole),
          if (decimals.isNotEmpty)
            TextSpan(
              text: decimals,
              style: AppTypography.sectionTitleSM(
                color: AppColors.primaryGoldLight,
              ),
            ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.bodyXSmall(
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }
}
