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

  /// Positive = days left, 0 = due today, negative = overdue by |n| days.
  final int daysLeft;
  final VoidCallback? onTap;

  bool get _overdue => daysLeft < 0;

  String get _badgeText {
    if (daysLeft < 0) {
      final n = -daysLeft;
      return 'Overdue by $n ${n == 1 ? 'day' : 'days'}';
    }
    if (daysLeft == 0) return 'Due today';
    return '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} left';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    // Overdue / due-today keep the existing red look; upcoming dues use the
    // softer orange so the card isn't alarming when there is time left.
    final urgent = daysLeft <= 0;
    final accent = urgent ? AppColors.errorRed : AppColors.warningOrange;
    final cardBg = urgent
        ? (isDark ? AppColors.errorRedDark : AppColors.errorRedLight)
        : (isDark ? AppColors.warningOrangeDark : AppColors.warningOrangeLight);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_rounded, color: accent),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _overdue
                              ? 'Installment Overdue'
                              : 'Next Installment Due',
                          style: AppTypography.labelMedium(color: textPrimary),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppColors.mutedGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppFormatters.date(dueDate),
                        style: AppTypography.caption(
                          color: AppColors.mutedGray,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppFormatters.currencyDecimal(amount),
                        style: AppTypography.currencyAmountSM(color: accent),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                        ),
                        child: Text(
                          _badgeText,
                          style: AppTypography.labelSmall(color: accent),
                        ),
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