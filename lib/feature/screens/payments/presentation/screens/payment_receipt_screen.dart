import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/constants/image_string/image_strings.dart';
import 'package:swarna_bindu/core/formatter/app_formatters.dart';
import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../data/models/payment_receipt_model.dart';
import '../viewmodels/payment_receipt_viewmodel.dart';
import '../widgets/receipt_action_feedback.dart';

/// Receipt for a single transaction. Opened from Payment History
/// ("View Receipt") — route: `/app/paymentReceipt/:transactionId`.
class PaymentReceiptScreen extends ConsumerStatefulWidget {
  const PaymentReceiptScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  ConsumerState<PaymentReceiptScreen> createState() => _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState extends ConsumerState<PaymentReceiptScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => ref.read(paymentReceiptProvider.notifier).load(widget.transactionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentReceiptProvider);
    final action = ref.watch(receiptActionProvider);

    ref.listen<ReceiptActionState>(
      receiptActionProvider,
          (prev, next) => handleReceiptActionChange(context, prev, next),
    );

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
                    onPressed: () =>
                    context.canPop() ? context.pop() : context.go(RouteName.dashboard),
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                  ),
                  Text('Payment Receipt', style: AppTypography.headingSM(color: Colors.black)),
                ],
              ),
            ),
            Expanded(child: _buildBody(state, action)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PaymentReceiptState state, ReceiptActionState action) {
    final receipt = state.receipt;

    if (receipt == null) {
      if (state.isError) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall(color: AppColors.mutedGray),
                ),
                SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () => ref.read(paymentReceiptProvider.notifier).retry(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final txn = receipt.transactionId.isNotEmpty ? receipt.transactionId : widget.transactionId;
    final isThisTxn = action.transactionId == txn;
    final downloading = isThisTxn && action.status == ReceiptActionStatus.downloading;
    final sharing = isThisTxn && action.status == ReceiptActionStatus.sharing;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReceiptCard(receipt: receipt),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.file_download_outlined,
                  title: 'Download Receipt',
                  subtitle: 'Save your receipt',
                  loading: downloading,
                  onTap: action.isBusy
                      ? null
                      : () => ref.read(receiptActionProvider.notifier).download(txn),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionTile(
                  icon: Icons.send_outlined,
                  title: 'Share',
                  subtitle: 'Share your receipt',
                  loading: sharing,
                  onTap: action.isBusy
                      ? null
                      : () => ref.read(receiptActionProvider.notifier).share(
                    txn,
                    subject: 'Swarna Bindu receipt ${receipt.invoiceNo ?? txn}',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.receipt});

  final PaymentReceiptModel receipt;

  @override
  Widget build(BuildContext context) {
    final paidAt = receipt.paidAtDateTime;
    final active = receipt.isSchemeActive;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3)),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.schemeName,
                      style: AppTypography.labelLarge(color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFFDDF6E4) : AppColors.pendingBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        receipt.schemeStatusLabel,
                        style: AppTypography.bodyXSmall(
                          color: active ? const Color(0xFF258B44) : AppColors.pendingText,
                        ).copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ColumnStat(label: 'Installment Type', value: receipt.installmentLabel),
              ),
              Container(width: 1, height: 30, color: AppColors.borderLight),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ColumnStat(
                  label: 'Paid On',
                  value: paidAt == null ? '—' : AppFormatters.date(paidAt),
                ),
              ),
              Container(width: 1, height: 30, color: AppColors.borderLight),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ColumnStat(
                  label: 'Amount Paid',
                  value: AppFormatters.currency(receipt.amountPaid),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Container(height: 1, color: AppColors.borderLight),
          SizedBox(height: AppSpacing.md),
          _DetailRow(label: 'Transaction ID', value: receipt.transactionId),
          const SizedBox(height: 8),
          _DetailRow(label: 'Invoice No', value: receipt.invoiceNo ?? '—'),
          const SizedBox(height: 8),
          _DetailRow(label: 'Razorpay order id', value: receipt.razorpayOrderId ?? '—'),
          const SizedBox(height: 8),
          _DetailRow(label: 'Payment Method', value: receipt.paymentMethod),
          const SizedBox(height: 8),
          _DetailRow(
            label: 'Date & Time',
            value: paidAt == null ? '—' : AppFormatters.dateTime(paidAt),
          ),
          const SizedBox(height: 8),
          _DetailRow(label: 'GST', value: AppFormatters.currencyDecimal(receipt.gst)),
          const SizedBox(height: 8),
          _DetailRow(
            label: 'Convenience Fee',
            value: AppFormatters.currencyDecimal(receipt.convenienceFee),
          ),
          SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: AppColors.borderLight),
          SizedBox(height: AppSpacing.sm),
          _DetailRow(
            label: 'Total Paid',
            value: AppFormatters.currencyDecimal(receipt.totalPaid),
            emphasize: true,
          ),
        ],
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
          style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 10),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTypography.labelMedium(color: Colors.black).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.emphasize = false});

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
          style: emphasize
              ? AppTypography.labelMedium(color: Colors.black)
              : AppTypography.bodySmall(color: AppColors.mutedGray),
        ),
        SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.labelMedium(color: Colors.black).copyWith(
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            ),
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
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null && !loading ? 0.5 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF0D9DE)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFF3E7EA),
                  child: loading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.maroonDark,
                    ),
                  )
                      : Icon(icon, size: 16, color: AppColors.maroonDark),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  title,
                  style: AppTypography.labelMedium(color: Colors.black)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodyXSmall(color: AppColors.mutedGray)
                      .copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}