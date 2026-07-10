import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_spacing.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';

import '../../../../../core/formatter/app_formatters.dart';

/// Hero card shown at the top of the Dashboard — total savings, gold
/// accumulated, goal, and a circular progress ring toward the goal.
class SavingsHeroCard extends StatelessWidget {
  const SavingsHeroCard({super.key, required this.totalSavings, required this.totalGoldGrams, required this.goalGoldGrams, required this.goalProgress});

  final double totalSavings;
  final double totalGoldGrams;
  final double goalGoldGrams;
  final double goalProgress; // 0.0 - 1.0

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [BoxShadow(color: AppColors.maroonDark.withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('Total Savings Value'),
                SizedBox(height: 2),
                Text(AppFormatters.currencyDecimal(totalSavings), style: AppTypography.headingXL(color: AppColors.primaryGoldLight)),
                SizedBox(height: AppSpacing.lg),
                _Label('Total Gold Accumulated'),
                SizedBox(height: 2),
                Text(AppFormatters.goldWeight(totalGoldGrams), style: AppTypography.headingSM(color: Colors.white)),
                SizedBox(height: AppSpacing.lg),
                _Label('Your Goal'),
                SizedBox(height: 2),
                Text(AppFormatters.goldWeight(goalGoldGrams), style: AppTypography.headingSM(color: Colors.white)),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          CircularPercentIndicator(
            radius: 52,
            lineWidth: 8,
            percent: goalProgress.clamp(0.0, 1.0),
            animation: true,
            animationDuration: 900,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            progressColor: AppColors.primaryGold,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(goalProgress * 100).round()}%', style: AppTypography.headingMD(color: Colors.white)),
                Text(
                  'of your goal',
                  textAlign: TextAlign.center,
                  style: AppTypography.hint(color: Colors.white70),
                ),
              ],
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
    return Text(text, style: AppTypography.bodyXSmall(color: Colors.white.withValues(alpha: 0.72)));
  }
}
