import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swarna_bindu/core/constants/image_string/image_strings.dart';
import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

class _Transaction {
  const _Transaction({
    required this.schemeName,
    required this.transactionId,
    required this.paymentMethod,
    required this.dateTime,
    required this.amountPaid,
  });

  final String schemeName;
  final String transactionId;
  final String paymentMethod;
  final String dateTime;
  final num amountPaid;
}

/// Phase 1 mock data — replace with `GET /users/:id/enrollments` +
/// installment history once the data layer is ready.
final _mockTransactions = <_Transaction>[
  _Transaction(
    schemeName: 'Swarna Bindu',
    transactionId: 'TXN125060512341',
    paymentMethod: 'UPI - Google Pay',
    dateTime: '05 Jun 2025, 9:41 AM',
    amountPaid: 5000,
  ),
  _Transaction(
    schemeName: 'Swarna Bindu',
    transactionId: 'TXN125060512341',
    paymentMethod: 'UPI - Google Pay',
    dateTime: '05 July 2025, 9:41 AM',
    amountPaid: 5000,
  ),
];

/// Shown when the customer taps "View History" from the payment screen's
/// quick actions.
class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF6),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(RouteName.dashboard),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  Text(
                    'Payment History',
                    style: AppTypography.headingSM(color: Colors.black),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _mockTransactions.isEmpty
                  ? Center(
                      child: Text(
                        'No payments yet',
                        style: AppTypography.bodySmall(
                          color: AppColors.mutedGray,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: _mockTransactions.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) =>
                          _TransactionCard(transaction: _mockTransactions[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final _Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(AppAssetImage.jewellery),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                transaction.schemeName,
                style: AppTypography.labelLarge(color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: AppColors.borderLight),
          SizedBox(height: AppSpacing.sm),
          _DetailRow(label: 'Transaction ID', value: transaction.transactionId),
          SizedBox(height: 6),
          _DetailRow(label: 'Payment Method', value: transaction.paymentMethod),
          SizedBox(height: 6),
          _DetailRow(label: 'Date & Time', value: transaction.dateTime),
          SizedBox(height: 6),
          _DetailRow(
            label: 'Amount paid',
            value: '₹${transaction.amountPaid.toStringAsFixed(0)}',
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyXSmall(color: AppColors.mutedGray),
        ),
        Text(
          value,
          style: emphasize
              ? AppTypography.labelMedium(color: Colors.black)
              : AppTypography.labelMedium(
                  color: Colors.black,
                ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
