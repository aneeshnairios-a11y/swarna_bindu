import 'package:flutter/material.dart';

import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../../core/formatter/app_formatters.dart';

class InstallmentDueCard extends StatelessWidget {
  const InstallmentDueCard({
    super.key,
    required this.amount,
    required this.dueDate,
    required this.daysLeft,
    this.onTap,
  });

  final double amount;
  final DateTime dueDate;
  final int daysLeft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.errorRedDark : AppColors.errorRedLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.errorRed.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.receipt_long_rounded, color: AppColors.errorRed),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Next Installment Due', style: AppTypography.labelMedium(color: textPrimary)),
                      ),
                      const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.mutedGray),
                      const SizedBox(width: 4),
                      Text(AppFormatters.date(dueDate), style: AppTypography.caption(color: AppColors.mutedGray)),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppFormatters.currencyDecimal(amount),
                        style: AppTypography.currencyAmountSM(color: AppColors.errorRed),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text('$daysLeft days left', style: AppTypography.labelSmall(color: AppColors.errorRed)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
