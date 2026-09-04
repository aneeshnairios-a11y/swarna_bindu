import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swarna_bindu/core/constants/image_string/image_strings.dart';
import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

/// Shown when the customer taps "Receipts" from the payment screen's quick
/// actions, or right after a successful payment in Phase 2.
/// Phase 1 — mock data only; replace with the real installment/payment
/// record once `POST /payments/verify` is wired up.
class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({
    super.key,
    this.schemeName = 'Swarna Bindu',
    this.installmentType = 'Current Month',
    this.dueDate = '05 Jun 2025',
    this.amountPaid = 5000,
    this.transactionId = 'TXN125060512341',
    this.invoiceNo = 'INV-2026-00456',
    this.razorpayOrderId = 'order_QZk7pT2xR9ml',
    this.paymentMethod = 'UPI - Google Pay',
    this.dateTime = '05 Jun 2025, 9:41 AM',
    this.gstPercent = 0,
  });

  final String schemeName;
  final String installmentType;
  final String dueDate;
  final num amountPaid;
  final String transactionId;
  final String invoiceNo;
  final String razorpayOrderId;
  final String paymentMethod;
  final String dateTime;
  final num gstPercent;

  void _notReady(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label will be available soon.')));
  }

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
                    'Payment Receipt',
                    style: AppTypography.headingSM(color: Colors.black),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
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
                                width: 44,
                                height: 44,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    schemeName,
                                    style: AppTypography.labelLarge(
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDDF6E4),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Active',
                                      style: AppTypography.bodyXSmall(
                                        color: const Color(0xFF258B44),
                                      ).copyWith(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: _ColumnStat(
                                  label: 'Installment Type',
                                  value: installmentType,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: AppColors.borderLight,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _ColumnStat(
                                  label: 'Due Date',
                                  value: dueDate,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: AppColors.borderLight,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _ColumnStat(
                                  label: 'Amount Paid',
                                  value: '₹${amountPaid.toStringAsFixed(0)}',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.md),
                          Container(height: 1, color: AppColors.borderLight),
                          SizedBox(height: AppSpacing.md),
                          _DetailRow(
                            label: 'Transaction ID',
                            value: transactionId,
                          ),
                          SizedBox(height: 8),
                          _DetailRow(label: 'Invoice No', value: invoiceNo),
                          SizedBox(height: 8),
                          _DetailRow(
                            label: 'Razorpay order id',
                            value: razorpayOrderId,
                          ),
                          SizedBox(height: 8),
                          _DetailRow(
                            label: 'Payment Method',
                            value: paymentMethod,
                          ),
                          SizedBox(height: 8),
                          _DetailRow(label: 'Date & Time', value: dateTime),
                          SizedBox(height: 8),
                          _DetailRow(
                            label: 'GST(${gstPercent.toStringAsFixed(0)}%)',
                            value: '₹0.00',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.file_download_outlined,
                            title: 'Download Receipt',
                            subtitle: 'Save  your receipt',
                            onTap: () => _notReady(context, 'Download'),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.send_outlined,
                            title: 'Share',
                            subtitle: 'Share your receipt',
                            onTap: () => _notReady(context, 'Share'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(
            //     AppSpacing.lg,
            //     0,
            //     AppSpacing.lg,
            //     AppSpacing.lg,
            //   ),
            //   child: SizedBox(
            //     width: double.infinity,
            //     height: 52,
            //     child: FilledButton(
            //       onPressed: () => context.canPop()
            //           ? context.pop()
            //           : context.go(RouteName.dashboard),
            //       style: FilledButton.styleFrom(
            //         backgroundColor: AppColors.maroonDark,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //       ),
            //       child: Text(
            //         'Back',
            //         style: AppTypography.buttonLarge(color: Colors.white),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _ColumnStat extends StatelessWidget {
  const _ColumnStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyXSmall(
            color: AppColors.mutedGray,
          ).copyWith(fontSize: 10),
        ),
        SizedBox(height: 3),
        Text(
          value,
          style: AppTypography.labelMedium(
            color: Colors.black,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall(color: AppColors.mutedGray)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.labelMedium(
              color: Colors.black,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF0D9DE)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF3E7EA),
                child: Icon(icon, size: 16, color: AppColors.maroonDark),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.labelMedium(
                  color: Colors.black,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodyXSmall(
                  color: AppColors.mutedGray,
                ).copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
