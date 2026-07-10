import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gold_scheme/core/formatter/app_formatters.dart';
import 'package:gold_scheme/core/router/route_name.dart';
import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_spacing.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';
import 'package:gold_scheme/feature/global_widgets/common_button.dart';
import 'package:gold_scheme/feature/screens/payments/presentation/viewmodels/payment_viewmodel.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key, required this.receipt});
  final PaymentReceipt receipt;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundLight,
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 52,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Payment successful!',
              style: AppTypography.headingXL(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '${AppFormatters.currency(receipt.amount)} has been paid towards your Bindu Gold Savings Plan.',
              style: AppTypography.bodyMedium(color: AppColors.mutedGray),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xxl),
            _ReceiptCard(receipt: receipt),
            const Spacer(),
            AppButton(
              text: 'View my passbook',
              onPressed: () =>
                  context.go(RouteName.passbookPath(receipt.enrollmentId)),
              gradient: AppColors.goldGradient,
              textColor: AppColors.textOnGold,
            ),
            SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => context.go(RouteName.dashboard),
              child: Text(
                'Back to home',
                style: AppTypography.labelLarge(color: AppColors.darkNavy),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.receipt});
  final PaymentReceipt receipt;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Column(
      children: [
        _row(
          'Amount paid',
          AppFormatters.currency(receipt.amount),
          prominent: true,
        ),
        Divider(height: AppSpacing.xl),
        _row('Payment method', _methodLabel(receipt.method)),
        SizedBox(height: AppSpacing.md),
        _row('Transaction ID', receipt.transactionId),
        SizedBox(height: AppSpacing.md),
        _row('Paid on', AppFormatters.dateTime(DateTime.now())),
      ],
    ),
  );

  String _methodLabel(PaymentMethod method) => switch (method) {
    PaymentMethod.upi => 'UPI',
    PaymentMethod.card => 'Card',
    PaymentMethod.netBanking => 'Net banking',
  };

  Widget _row(String label, String value, {bool prominent = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: AppTypography.bodyXSmall(color: AppColors.mutedGray)),
      Flexible(
        child: Text(
          value,
          style: prominent
              ? AppTypography.goldAmountSM(color: AppColors.darkNavy)
              : AppTypography.labelMedium(),
          textAlign: TextAlign.end,
        ),
      ),
    ],
  );
}
