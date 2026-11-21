import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swarna_bindu/core/formatter/app_formatters.dart';
import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';
import 'package:swarna_bindu/feature/global_widgets/common_button.dart';

class PaymentFailureScreen extends StatelessWidget {
  const PaymentFailureScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.message,
    required this.enrollmentId,
  });

  final String orderId;
  final num amount;
  final String message;
  final String enrollmentId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final errorBackground = isDark
        ? AppColors.errorRedDark
        : AppColors.errorRedLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        context.go(RouteName.dashboard),
                    icon: Icon(
                      Icons.arrow_back,
                      color: primaryTextColor,
                    ),
                  ),
                  Text(
                    'Payment Status',
                    style: AppTypography.headingSM(
                      color: primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.xl),

                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: errorBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.errorRed,
                        size: 52,
                      ),
                    ),

                    SizedBox(height: AppSpacing.xl),

                    Text(
                      'Payment Failed',
                      style: AppTypography.headingSM(
                        color: primaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.sm),

                    Text(
                      message,
                      style: AppTypography.bodySmall(
                        color: secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.xl),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Details',
                            style: AppTypography.sectionTitleSM(
                              color: primaryTextColor,
                            ),
                          ),

                          SizedBox(height: AppSpacing.md),

                          _DetailRow(
                            label: 'Amount',
                            value: AppFormatters.currencyDecimal(
                              amount.toDouble(),
                            ),
                          ),

                          SizedBox(height: AppSpacing.sm),

                          _DetailRow(
                            label: 'Order ID',
                            value: orderId,
                          ),

                          SizedBox(height: AppSpacing.sm),

                          _DetailRow(
                            label: 'Status',
                            value: 'Failed / Not Confirmed',
                            valueColor: AppColors.errorRed,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSpacing.lg),

                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariantLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.warningOrange,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'If money has been deducted from your account, '
                              'please check your payment history before '
                              'trying again. Contact support if the amount '
                              'is not refunded.',
                              style: AppTypography.bodyXSmall(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                text: 'Back to Dashboard',
                onPressed: () =>
                    context.go(RouteName.dashboard),
                backgroundColor: AppColors.maroonDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyXSmall(
              color: secondaryTextColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.labelMedium(
              color: valueColor ?? primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
