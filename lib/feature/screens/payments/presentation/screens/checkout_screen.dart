import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swarna_bindu/core/constants/image_string/image_strings.dart';
import 'package:swarna_bindu/core/formatter/app_formatters.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';
import 'package:swarna_bindu/feature/global_widgets/common_button.dart';
import '../data/models/payment_dues_model.dart';
import '../viewmodels/payment_viewmodel.dart';

/// Complete five-step payment flow opened by the Payments landing page.
/// `enrollmentId` (route param) is treated as the `userSchemeId` for the
/// /payments/dues lookup and the /payments/initialize + /verify calls.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.enrollmentId});

  final String enrollmentId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => ref.read(paymentProvider.notifier).loadDues(widget.enrollmentId),
    );
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);

    if (state.isDuesLoading || state.dues == null) {
      if (state.isDuesError) {
        return _DuesErrorScaffold(
          message: state.duesErrorMessage ?? 'Could not load scheme details.',
          onRetry: () => ref.read(paymentProvider.notifier).retryLoadDues(),
          onBack: () => context.pop(),
        );
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.selectedScheme == null) {
      return _DuesErrorScaffold(
        message: 'This scheme could not be found.',
        onRetry: () => ref.read(paymentProvider.notifier).retryLoadDues(),
        onBack: () => context.pop(),
      );
    }

    return switch (state.step) {
      PaymentFlowStep.scheme => _SchemeStep(
        onContinue: () =>
            ref.read(paymentProvider.notifier).goTo(PaymentFlowStep.installment),
        onBack: () => context.pop(),
      ),
      PaymentFlowStep.installment => _InstallmentStep(
        onBack: () => ref.read(paymentProvider.notifier).goBack(),
        onContinue: () =>
            ref.read(paymentProvider.notifier).goTo(PaymentFlowStep.payment),
      ),
      PaymentFlowStep.payment => _MethodStep(
        onBack: () => ref.read(paymentProvider.notifier).goBack(),
        onPay: () => ref.read(paymentProvider.notifier).pay(),
      ),
      PaymentFlowStep.processing => _ProcessingStep(
        onRetry: () => ref.read(paymentProvider.notifier).retryPayment(),
        onPayAgain: () => ref.read(paymentProvider.notifier).pay(),
      ),
      PaymentFlowStep.success => _SuccessStep(onBack: () => context.pop()),
    };
  }
}

class _DuesErrorScaffold extends StatelessWidget {
  const _DuesErrorScaffold({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFFCF8),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 8, 16, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                Text('Payment', style: AppTypography.headingSM(color: Colors.black)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall(color: AppColors.mutedGray),
                    ),
                    SizedBox(height: AppSpacing.md),
                    OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _FlowScaffold extends StatelessWidget {
  const _FlowScaffold({
    required this.title,
    required this.onBack,
    required this.body,
    this.bottom,
  });
  final String title;
  final VoidCallback onBack;
  final Widget body;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFFCF8),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 8, 16, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                Text(title, style: AppTypography.headingSM(color: Colors.black)),
              ],
            ),
          ),
          Expanded(child: body),
          if (bottom != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: bottom!,
            ),
        ],
      ),
    ),
  );
}

class _SchemeStep extends ConsumerWidget {
  const _SchemeStep({required this.onContinue, required this.onBack});
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(paymentProvider.select((s) => s.selectedScheme))!;
    return _FlowScaffold(
      title: 'Select Scheme',
      onBack: onBack,
      body: ListView(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
        children: [
          _DueStrip(scheme: scheme),
          SizedBox(height: AppSpacing.lg),
          Text('Your Active Schemes', style: AppTypography.sectionTitleSM(color: Colors.black)),
          SizedBox(height: AppSpacing.sm),
          _DetailedSchemeCard(scheme: scheme, selected: true),
        ],
      ),
      bottom: AppButton(text: 'Continue', onPressed: onContinue, backgroundColor: AppColors.maroonDark),
    );
  }
}

class _InstallmentStep extends ConsumerWidget {
  const _InstallmentStep({required this.onBack, required this.onContinue});
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(paymentProvider.select((v) => v.installmentType));
    final scheme = ref.watch(paymentProvider.select((v) => v.selectedScheme))!;

    return _FlowScaffold(
      title: 'Select Installment',
      onBack: onBack,
      body: ListView(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
        children: [
          _CompactSchemeCard(scheme: scheme),
          SizedBox(height: AppSpacing.lg),
          Text('Select Installment Type', style: AppTypography.sectionTitleSM(color: Colors.black)),
          SizedBox(height: AppSpacing.sm),
          _InstallmentTile(
            type: InstallmentType.currentMonth,
            selected: selected == InstallmentType.currentMonth,
            icon: Icons.calendar_month_outlined,
            title: 'Current Month Installment',
            subtitle: 'Pay your current installment',
            amount: AppFormatters.currencyDecimal(scheme.nextDueAmount),
          ),
          if (scheme.hasPendingDues) ...[
            SizedBox(height: AppSpacing.sm),
            _InstallmentTile(
              type: InstallmentType.pendingDues,
              selected: selected == InstallmentType.pendingDues,
              icon: Icons.calendar_month_outlined,
              title: 'Pending Dues',
              subtitle: 'Clear your pending installments',
              amount: AppFormatters.currencyDecimal(scheme.pendingAmount),
              detail: '${scheme.pendingDuesCount} Dues     Total Amount',
            ),
          ],
          SizedBox(height: AppSpacing.sm),
          _InstallmentTile(
            type: InstallmentType.advancePayment,
            selected: selected == InstallmentType.advancePayment,
            icon: Icons.calendar_month_outlined,
            title: 'Advance Payment',
            subtitle: 'Advance for upcoming installments',
            amount: AppFormatters.currencyDecimal(scheme.advanceAmount),
            detail: '${DueSchemeModel.advanceMonths} Months     Total Amount',
          ),
          SizedBox(height: AppSpacing.sm),
          const _NoteCard(),
          SizedBox(height: AppSpacing.sm),
          _PaymentSummary(type: selected, scheme: scheme),
        ],
      ),
      bottom: AppButton(text: 'Continue', onPressed: onContinue, backgroundColor: AppColors.maroonDark),
    );
  }
}

class _MethodStep extends ConsumerWidget {
  const _MethodStep({required this.onBack, required this.onPay});
  final VoidCallback onBack;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(paymentProvider.select((v) => v.method));
    final scheme = ref.watch(paymentProvider.select((v) => v.selectedScheme))!;

    return _FlowScaffold(
      title: 'Select Payment',
      onBack: onBack,
      body: ListView(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
        children: [
          _CompactSchemeCard(scheme: scheme),
          SizedBox(height: AppSpacing.lg),
          Text('Recommended for You', style: AppTypography.sectionTitleSM(color: Colors.black)),
          SizedBox(height: AppSpacing.sm),
          _PaymentTile(
            method: PaymentMethod.upi,
            selected: selected == PaymentMethod.upi,
            icon: Icons.account_balance_wallet_outlined,
            iconColor: const Color(0xFF377B44),
            title: 'Pay using UPI',
            subtitle: 'Instant payment using your UPI app',
            highlighted: true,
          ),
          SizedBox(height: AppSpacing.md),
          Text('Card', style: AppTypography.sectionTitleSM(color: Colors.black)),
          SizedBox(height: AppSpacing.sm),
          _PaymentTile(
            method: PaymentMethod.card,
            selected: selected == PaymentMethod.card,
            icon: Icons.credit_card_outlined,
            iconColor: const Color(0xFFAF7608),
            title: 'Debit/Credit Card',
            subtitle: 'Pay using your saved debit card',
          ),
          SizedBox(height: AppSpacing.md),
          Text('Other Payment Options', style: AppTypography.sectionTitleSM(color: Colors.black)),
          SizedBox(height: AppSpacing.sm),
          _PaymentTile(
            method: PaymentMethod.netBanking,
            selected: selected == PaymentMethod.netBanking,
            icon: Icons.account_balance_outlined,
            iconColor: const Color(0xFF2175B2),
            title: 'Net Banking',
            subtitle: 'Pay using net banking',
          ),
        ],
      ),
      bottom: _PayBar(onPay: onPay),
    );
  }
}

class _ProcessingStep extends ConsumerWidget {
  const _ProcessingStep({required this.onRetry, required this.onPayAgain});
  final VoidCallback onRetry;
  final VoidCallback onPayAgain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentProvider);
    final scheme = state.selectedScheme;

    if (state.isFailed) {
      return _FlowScaffold(
        title: 'Payment Failed',
        onBack: onRetry,
        body: ListView(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
          children: [
            const SizedBox(height: 15),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.errorRedLight,
                ),
                child: const Icon(Icons.close_rounded, color: AppColors.errorRed, size: 46),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Your Payment Could Not Be Processed',
              style: AppTypography.sectionTitleSM(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              state.errorMessage ?? 'Something went wrong. Please try again.',
              style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        bottom: AppButton(text: 'Try Again', onPressed: onPayAgain, backgroundColor: AppColors.maroonDark),
      );
    }

    return _FlowScaffold(
      title: 'Processing Payment',
      onBack: () {},
      body: ListView(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
        children: [
          const SizedBox(height: 15),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF0B63A), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x22E8B03B), blurRadius: 20, spreadRadius: 7),
                ],
              ),
              child: const Icon(Icons.currency_rupee_rounded, color: Color(0xFFD5950B), size: 46),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            'Your Payment Is Being Processed',
            style: AppTypography.sectionTitleSM(color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            'Please Wait While We Confirm Your Payment.\nThis Will Only Take A Few Seconds.',
            style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          const _ProgressTrack(),
          SizedBox(height: AppSpacing.xl),
          if (scheme != null) _TransactionCard(scheme: scheme, state: state),
          SizedBox(height: AppSpacing.sm),
          const _SecureProcessingCard(),
        ],
      ),
    );
  }
}

class _SuccessStep extends ConsumerWidget {
  const _SuccessStep({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentProvider);
    final scheme = state.selectedScheme;
    final payment = state.verifyResult?.payment;

    return _FlowScaffold(
      title: 'Payment Successful',
      onBack: onBack,
      body: ListView(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, 60, AppSpacing.lg, AppSpacing.lg),
        children: [
          Text(
            'Payment Successful',
            style: AppTypography.headingSM(color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            'Your Payment Has Been Received Successfully.\nThank You For Your Payment.',
            style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          _SuccessNotice(amount: payment?.amountPaid ?? 0),
          SizedBox(height: AppSpacing.lg),
          if (scheme != null) _TransactionCard(scheme: scheme, state: state),
          if (payment != null && payment.goldGained > 0) ...[
            SizedBox(height: AppSpacing.sm),
            _GoldGainedCard(goldGained: payment.goldGained),
          ],
        ],
      ),
      bottom: AppButton(text: 'Back', onPressed: onBack, backgroundColor: AppColors.maroonDark),
    );
  }
}

class _DueStrip extends StatelessWidget {
  const _DueStrip({required this.scheme});
  final DueSchemeModel scheme;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7EC),
      border: Border.all(color: const Color(0xFFF5E4C8)),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.maroonDark,
          child: Icon(Icons.calendar_month_outlined, color: AppColors.primaryGoldLight),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next Due Amount',
                style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 10),
              ),
              Text(
                AppFormatters.currencyDecimal(scheme.nextDueAmount),
                style: AppTypography.sectionTitleSM(color: Colors.black),
              ),
            ],
          ),
        ),
        Container(width: 1, height: 24, color: AppColors.borderStrongLight),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Due Date',
                style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 10),
              ),
              Text(
                scheme.nextDueDateTime == null ? '—' : AppFormatters.date(scheme.nextDueDateTime!),
                style: AppTypography.sectionTitleSM(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DetailedSchemeCard extends StatelessWidget {
  const _DetailedSchemeCard({required this.scheme, required this.selected});
  final DueSchemeModel scheme;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: selected ? const Color(0xFFC58C27) : AppColors.borderLight),
      boxShadow: const [BoxShadow(color: Color(0x15000000), blurRadius: 5)],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Radio<bool>(value: true, groupValue: selected, onChanged: (_) {}),
        const _GoldThumbnail(),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(scheme.schemeName, style: AppTypography.sectionTitleSM(color: Colors.black)),
                  ),
                  _StatusBadge(status: scheme.status),
                ],
              ),
              Text(
                '${scheme.paidInstallments} of ${scheme.totalInstallments} installments paid',
                style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 10),
              ),
              const Divider(),
              _SchemeMeta(scheme: scheme),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CompactSchemeCard extends StatelessWidget {
  const _CompactSchemeCard({required this.scheme});
  final DueSchemeModel scheme;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [BoxShadow(color: Color(0x15000000), blurRadius: 5)],
    ),
    child: Row(
      children: [
        const _GoldThumbnail(small: true),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(scheme.schemeName, style: AppTypography.sectionTitleSM(color: Colors.black)),
                  ),
                  _StatusBadge(status: scheme.status),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              _SchemeMeta(scheme: scheme),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFDDF6E4),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      status,
      style: AppTypography.bodyXSmall(color: const Color(0xFF258B44)).copyWith(fontSize: 10),
    ),
  );
}

class _GoldThumbnail extends StatelessWidget {
  const _GoldThumbnail({this.small = false});
  final bool small;
  @override
  Widget build(BuildContext context) => Container(
    width: small ? 64 : 66,
    height: small ? 58 : 66,
    decoration: BoxDecoration(
      color: AppColors.darkNavy,
      borderRadius: BorderRadius.circular(8),
      image: DecorationImage(image: AssetImage(AppAssetImage.jewellery), fit: BoxFit.cover),
    ),
  );
}

class _SchemeMeta extends StatelessWidget {
  const _SchemeMeta({required this.scheme});
  final DueSchemeModel scheme;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _Meta(
          label: 'Monthly Investment',
          value: AppFormatters.currencyDecimal(scheme.monthlyInvestment),
        ),
      ),
      Container(width: 1, height: 24, color: AppColors.borderLight),
      SizedBox(width: AppSpacing.sm),
      Expanded(
        child: _Meta(
          label: 'Pending Dues',
          value: scheme.hasPendingDues
              ? '${scheme.pendingDuesCount} (${AppFormatters.currency(scheme.pendingAmount)})'
              : 'None',
        ),
      ),
    ],
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 9)),
      Text(value, style: AppTypography.labelMedium(color: Colors.black)),
    ],
  );
}

class _InstallmentTile extends ConsumerWidget {
  const _InstallmentTile({
    required this.type,
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.detail,
  });
  final InstallmentType type;
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String? detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) => InkWell(
    onTap: () => ref.read(paymentProvider.notifier).selectInstallment(type),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? const Color(0xFFD19A3D) : AppColors.borderLight),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Radio<InstallmentType>(
            value: type,
            groupValue: ref.watch(paymentProvider.select((v) => v.installmentType)),
            onChanged: (v) {
              if (v != null) ref.read(paymentProvider.notifier).selectInstallment(v);
            },
            activeColor: const Color(0xFFD09116),
          ),
          CircleAvatar(
            radius: 21,
            backgroundColor: selected ? const Color(0xFFFFF1D9) : const Color(0xFFFFE8EC),
            child: Icon(icon, color: selected ? const Color(0xFFD38A18) : const Color(0xFFFA5265)),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium(color: Colors.black)),
                Text(
                  subtitle,
                  style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 10),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: AppTypography.bodyXSmall(
                      color: type == InstallmentType.pendingDues ? Colors.red : const Color(0xFF7E3DD7),
                    ).copyWith(fontSize: 10),
                  ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTypography.labelMedium(color: selected ? const Color(0xFF248A47) : Colors.black),
          ),
        ],
      ),
    ),
  );
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.type, required this.scheme});
  final InstallmentType type;
  final DueSchemeModel scheme;

  @override
  Widget build(BuildContext context) {
    final amount = switch (type) {
      InstallmentType.currentMonth => scheme.nextDueAmount,
      InstallmentType.pendingDues => scheme.pendingAmount,
      InstallmentType.advancePayment => scheme.advanceAmount,
    };
    final label = switch (type) {
      InstallmentType.currentMonth => 'Current Month',
      InstallmentType.pendingDues => 'Pending Dues',
      InstallmentType.advancePayment => 'Advance',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF6E7D5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment Summary', style: AppTypography.sectionTitleSM(color: Colors.black)),
              Text(label, style: AppTypography.labelSmall(color: const Color(0xFF258B44))),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          _TotalRow('Installment Amount', AppFormatters.currencyDecimal(amount)),
          _TotalRow('Convenience Fee', AppFormatters.currency(0)),
          _TotalRow('GST (0%)', AppFormatters.currency(0)),
          const Divider(),
          _TotalRow('Total Payable', AppFormatters.currencyDecimal(amount), prominent: true),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.value, {this.prominent = false});
  final String label;
  final String value;
  final bool prominent;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyXSmall(color: prominent ? Colors.black : AppColors.mutedGray),
        ),
        Text(
          value,
          style: AppTypography.labelMedium(
            color: prominent ? const Color(0xFFD08112) : Colors.black,
          ),
        ),
      ],
    ),
  );
}

class _NoteCard extends StatelessWidget {
  const _NoteCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0xFFFFF7EC), borderRadius: BorderRadius.circular(8)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info, color: Color(0xFFD69B2D)),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Note', style: AppTypography.labelMedium(color: Colors.black)),
              Text(
                'Your payment will be adjusted to the oldest pending installment first.\nAny advance amount will be adjusted to upcoming installments.',
                style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PaymentTile extends ConsumerWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.highlighted = false,
  });
  final PaymentMethod method;
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool highlighted;
  @override
  Widget build(BuildContext context, WidgetRef ref) => InkWell(
    onTap: () => ref.read(paymentProvider.notifier).selectMethod(method),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFF7FFF7) : Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: highlighted ? const Color(0xFF75AC79) : AppColors.borderLight),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 4)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withValues(alpha: .12),
            child: Icon(icon, color: iconColor),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium(color: Colors.black)),
                Text(
                  subtitle,
                  style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          Radio<PaymentMethod>(
            value: method,
            groupValue: ref.watch(paymentProvider.select((v) => v.method)),
            onChanged: (v) {
              if (v != null) ref.read(paymentProvider.notifier).selectMethod(v);
            },
            activeColor: const Color(0xFF28884B),
          ),
        ],
      ),
    ),
  );
}

class _PayBar extends ConsumerWidget {
  const _PayBar({required this.onPay});
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = ref.watch(paymentProvider.select((v) => v.selectedAmount));
    final isProcessing = ref.watch(paymentProvider.select((v) => v.isProcessing));

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.maroonDark, borderRadius: BorderRadius.circular(9)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount Payable',
                  style: AppTypography.bodyXSmall(color: Colors.white).copyWith(fontSize: 10),
                ),
                Text(
                  AppFormatters.currencyDecimal(amount),
                  style: AppTypography.sectionTitleSM(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: FilledButton(
              onPressed: isProcessing ? null : onPay,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7B4E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: isProcessing
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text('Pay ${AppFormatters.currency(amount)}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          const CircleAvatar(
            radius: 10,
            backgroundColor: Color(0xFFE3B13B),
            child: Icon(Icons.check, color: Colors.white, size: 14),
          ),
          const Expanded(child: Divider(color: Color(0xFFE3B13B))),
          const CircleAvatar(
            radius: 10,
            backgroundColor: Colors.white,
            child: Icon(Icons.more_horiz, color: Color(0xFFE3B13B), size: 17),
          ),
          const Expanded(child: Divider(color: AppColors.borderStrongLight)),
          const CircleAvatar(
            radius: 10,
            backgroundColor: Colors.white,
            child: Icon(Icons.circle_outlined, color: AppColors.borderStrongLight, size: 17),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Payment Initiated', style: AppTypography.bodyXSmall(color: Colors.black).copyWith(fontSize: 9)),
          Text('Processing...', style: AppTypography.bodyXSmall(color: const Color(0xFFD19115)).copyWith(fontSize: 9)),
          Text('Payment Successful', style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 9)),
        ],
      ),
    ],
  );
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.scheme, required this.state});
  final DueSchemeModel scheme;
  final PaymentState state;

  @override
  Widget build(BuildContext context) {
    final payment = state.verifyResult?.payment;
    final txnId = payment?.transactionId ?? state.transactionId ?? '—';
    final method = payment?.paymentMethod ?? state.method.apiLabel;
    final paidAt = payment?.paidAtDateTime;
    final amount = payment?.amountPaid ?? state.selectedAmount;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 7)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaction Summary', style: AppTypography.sectionTitleSM(color: Colors.black)),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const _GoldThumbnail(small: true),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scheme.schemeName, style: AppTypography.labelMedium(color: Colors.black)),
                    _StatusBadge(status: scheme.status),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _Meta(
                  label: 'Installment Type',
                  value: switch (state.installmentType) {
                    InstallmentType.currentMonth => 'Current Month',
                    InstallmentType.pendingDues => 'Pending Dues',
                    InstallmentType.advancePayment => 'Advance',
                  },
                ),
              ),
              Container(width: 1, height: 24, color: AppColors.borderLight),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Meta(
                  label: 'Amount',
                  value: AppFormatters.currencyDecimal(amount),
                ),
              ),
            ],
          ),
          const Divider(),
          _TransactionRow('Transaction ID', txnId),
          _TransactionRow('Payment Method', method),
          _TransactionRow(
            'Date & Time',
            paidAt == null ? '—' : AppFormatters.dateTime(paidAt),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 10)),
        Text(
          value,
          style: AppTypography.bodyXSmall(color: Colors.black).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _SecureProcessingCard extends StatelessWidget {
  const _SecureProcessingCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4E7),
      border: Border.all(color: const Color(0xFFF5E1C6)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.maroonDark,
          child: Icon(Icons.verified_user_outlined, size: 19, color: AppColors.primaryGoldLight),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Safe & Secure', style: AppTypography.labelMedium(color: Colors.black)),
              Text(
                'Your payment is secure. Please do not press back\nor close the app while we process your payment.',
                style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SuccessNotice extends StatelessWidget {
  const _SuccessNotice({required this.amount});
  final num amount;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF1F6F1), borderRadius: BorderRadius.circular(8)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF338D4B)),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Payment of ${AppFormatters.currency(amount)} has been successfully processed.\nA confirmation has been sent to your registered mobile number and email ID.',
            style: AppTypography.bodyXSmall(color: AppColors.textSecondaryLight).copyWith(fontSize: 9),
          ),
        ),
      ],
    ),
  );
}

class _GoldGainedCard extends StatelessWidget {
  const _GoldGainedCard({required this.goldGained});
  final num goldGained;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.goldSurfaceLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(Icons.workspace_premium_outlined, color: AppColors.primaryGoldDark),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gold Credited', style: AppTypography.labelMedium(color: Colors.black)),
              Text(
                AppFormatters.goldWeight(goldGained.toDouble()),
                style: AppTypography.goldAmountSM(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}