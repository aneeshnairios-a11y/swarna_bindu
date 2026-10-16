import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/constants/image_string/image_strings.dart';
import 'package:swarna_bindu/core/formatter/app_formatters.dart';
import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../data/models/payment_history_model.dart';
import '../viewmodels/payment_history_viewmodel.dart';
import '../viewmodels/payment_receipt_viewmodel.dart';
import '../widgets/receipt_action_feedback.dart';

/// Shown when the customer taps "View History" from the payment screen's
/// quick actions. Bottom-scroll auto-loads the next page. Successful
/// payments have "View Receipt" and "Download" actions.
class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(paymentHistoryProvider.notifier).loadFirstPage());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(paymentHistoryProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentHistoryProvider);

    // Snackbar feedback for downloads started from the cards.
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
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(RouteName.dashboard),
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                  ),
                  Text('Payment History', style: AppTypography.headingSM(color: Colors.black)),
                ],
              ),
            ),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PaymentHistoryState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isError && state.items.isEmpty) {
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
                onPressed: () => ref.read(paymentHistoryProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(paymentHistoryProvider.notifier).refresh(),
        child: ListView(
          children: [
            const SizedBox(height: 120.0),
            Center(
              child: Text(
                'No payments yet',
                style: AppTypography.bodySmall(color: AppColors.mutedGray),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(paymentHistoryProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) {
          if (i >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return _TransactionCard(transaction: state.items[i]);
        },
      ),
    );
  }
}

class _TransactionCard extends ConsumerWidget {
  const _TransactionCard({required this.transaction});

  final PaymentHistoryItemModel transaction;

  bool get _hasReceipt => transaction.status.toUpperCase() == 'SUCCESSFUL';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dt = transaction.paidAtDateTime?.toLocal();

    // Only this card's own download state — avoids rebuilding every card.
    final downloading = ref.watch(
      receiptActionProvider.select(
            (s) =>
        s.transactionId == transaction.transactionId &&
            s.status == ReceiptActionStatus.downloading,
      ),
    );
    final anyBusy = ref.watch(receiptActionProvider.select((s) => s.isBusy));

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
              Expanded(
                child: Text(
                  transaction.schemeName,
                  style: AppTypography.labelLarge(color: Colors.black),
                ),
              ),
              _StatusChip(status: transaction.status),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: AppColors.borderLight),
          SizedBox(height: AppSpacing.sm),
          _DetailRow(label: 'Transaction ID', value: transaction.transactionId),
          const SizedBox(height: 6),
          _DetailRow(label: 'Payment Method', value: transaction.paymentMethod),
          const SizedBox(height: 6),
          _DetailRow(
            label: 'Date & Time',
            value: dt == null ? '—' : AppFormatters.dateTime(dt),
          ),
          const SizedBox(height: 6),
          _DetailRow(
            label: 'Amount paid',
            value: AppFormatters.currency(transaction.amountPaid),
            emphasize: true,
          ),
          if (_hasReceipt) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      RouteName.paymentReceiptPath(transaction.transactionId),
                    ),
                    icon: const Icon(Icons.receipt_long_outlined, size: 16),
                    label: const Text('View Receipt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.maroonDark,
                      side: const BorderSide(color: Color(0xFFF0D9DE)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: anyBusy
                        ? null
                        : () => ref
                        .read(receiptActionProvider.notifier)
                        .download(transaction.transactionId),
                    icon: downloading
                        ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.file_download_outlined, size: 16),
                    label: Text(downloading ? 'Downloading' : 'Download'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.maroonDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final isSuccess = status.toUpperCase() == 'SUCCESSFUL';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSuccess ? AppColors.paidBg : AppColors.pendingBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTypography.bodyXSmall(
          color: isSuccess ? AppColors.paidText : AppColors.pendingText,
        ).copyWith(fontSize: 9),
      ),
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
        Text(label, style: AppTypography.bodyXSmall(color: AppColors.mutedGray)),
        Text(
          value,
          style: emphasize
              ? AppTypography.labelMedium(color: Colors.black)
              : AppTypography.labelMedium(color: Colors.black).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}