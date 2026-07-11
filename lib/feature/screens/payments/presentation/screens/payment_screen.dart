import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';
import 'package:swarna_bindu/feature/global_widgets/common_button.dart';
import 'package:swarna_bindu/feature/screens/payments/presentation/viewmodels/payment_viewmodel.dart';

/// Complete five-step payment flow opened by the Payments landing page.
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key, required this.enrollmentId});

  final String enrollmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentProvider);
    return switch (state.step) {
      PaymentFlowStep.scheme => _SchemeStep(
        onContinue: () => ref
            .read(paymentProvider.notifier)
            .goTo(PaymentFlowStep.installment),
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
      PaymentFlowStep.processing => const _ProcessingStep(),
      PaymentFlowStep.success => _SuccessStep(onBack: () => context.pop()),
    };
  }
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
                Text(
                  title,
                  style: AppTypography.headingSM(color: Colors.black),
                ),
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

class _SchemeStep extends StatelessWidget {
  const _SchemeStep({required this.onContinue, required this.onBack});
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => _FlowScaffold(
    title: 'Select Scheme',
    onBack: onBack,
    body: ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      children: [
        const _DueStrip(),
        SizedBox(height: AppSpacing.lg),
        Text(
          'Your Active Schemes',
          style: AppTypography.sectionTitleSM(color: Colors.black),
        ),
        SizedBox(height: AppSpacing.sm),
        const _DetailedSchemeCard(selected: true),
      ],
    ),
    bottom: AppButton(
      text: 'Continue',
      onPressed: onContinue,
      backgroundColor: AppColors.maroonDark,
    ),
  );
}

class _InstallmentStep extends ConsumerWidget {
  const _InstallmentStep({required this.onBack, required this.onContinue});
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      paymentProvider.select((value) => value.installmentType),
    );
    return _FlowScaffold(
      title: 'Select Installment',
      onBack: onBack,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          0,
        ),
        children: [
          const _CompactSchemeCard(),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Select Installment Type',
            style: AppTypography.sectionTitleSM(color: Colors.black),
          ),
          SizedBox(height: AppSpacing.sm),
          _InstallmentTile(
            type: InstallmentType.currentMonth,
            selected: selected == InstallmentType.currentMonth,
            icon: Icons.calendar_month_outlined,
            title: 'Current Month Installment',
            subtitle: 'Pay your current installment',
            amount: '₹ 5,000.00',
          ),
          SizedBox(height: AppSpacing.sm),
          _InstallmentTile(
            type: InstallmentType.pendingDues,
            selected: selected == InstallmentType.pendingDues,
            icon: Icons.calendar_month_outlined,
            title: 'Pending Dues',
            subtitle: 'Clear your pending installments',
            amount: '₹ 10,000.00',
            detail: '2 Dues     Total Amount',
          ),
          SizedBox(height: AppSpacing.sm),
          _InstallmentTile(
            type: InstallmentType.advancePayment,
            selected: selected == InstallmentType.advancePayment,
            icon: Icons.calendar_month_outlined,
            title: 'Advance Payment',
            subtitle: 'Advance for upcoming installments',
            amount: '₹ 15,000.00',
            detail: '3 Months     Total Amount',
          ),
          SizedBox(height: AppSpacing.sm),
          const _NoteCard(),
          SizedBox(height: AppSpacing.sm),
          _PaymentSummary(type: selected),
        ],
      ),
      bottom: AppButton(
        text: 'Continue',
        onPressed: onContinue,
        backgroundColor: AppColors.maroonDark,
      ),
    );
  }
}

class _MethodStep extends ConsumerWidget {
  const _MethodStep({required this.onBack, required this.onPay});
  final VoidCallback onBack;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(paymentProvider.select((value) => value.method));
    return _FlowScaffold(
      title: 'Select Payment',
      onBack: onBack,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          0,
        ),
        children: [
          const _CompactSchemeCard(),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Recommended for You',
            style: AppTypography.sectionTitleSM(color: Colors.black),
          ),
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
          Text(
            'Card',
            style: AppTypography.sectionTitleSM(color: Colors.black),
          ),
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
          Text(
            'Other Payment Options',
            style: AppTypography.sectionTitleSM(color: Colors.black),
          ),
          SizedBox(height: AppSpacing.sm),
          _PaymentTile(
            method: PaymentMethod.netBanking,
            selected: selected == PaymentMethod.netBanking,
            icon: Icons.account_balance_outlined,
            iconColor: const Color(0xFF2175B2),
            title: 'Net Banking',
            subtitle: 'Pay using your saved debit card',
          ),
          SizedBox(height: AppSpacing.sm),
          _WalletTile(),
        ],
      ),
      bottom: _PayBar(onPay: onPay),
    );
  }
}

class _ProcessingStep extends ConsumerWidget {
  const _ProcessingStep();
  @override
  Widget build(BuildContext context, WidgetRef ref) => _FlowScaffold(
    title: 'Processing Payment',
    onBack: () {},
    body: ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
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
                BoxShadow(
                  color: Color(0x22E8B03B),
                  blurRadius: 20,
                  spreadRadius: 7,
                ),
              ],
            ),
            child: const Icon(
              Icons.currency_rupee_rounded,
              color: Color(0xFFD5950B),
              size: 46,
            ),
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
          style: AppTypography.bodyXSmall(
            color: AppColors.mutedGray,
          ).copyWith(fontSize: 10),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.lg),
        const _ProgressTrack(),
        SizedBox(height: AppSpacing.xl),
        const _TransactionCard(),
        SizedBox(height: AppSpacing.sm),
        const _SecureProcessingCard(),
      ],
    ),
  );
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => _FlowScaffold(
    title: 'Processing Payment',
    onBack: onBack,
    body: ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        100,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        Text(
          'Payment Successful',
          style: AppTypography.headingSM(color: Colors.black),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          'Your Payment Has Been Received Successfully.\nThank You For Your Payment.',
          style: AppTypography.bodyXSmall(
            color: AppColors.mutedGray,
          ).copyWith(fontSize: 10),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.lg),
        const _SuccessNotice(),
        SizedBox(height: AppSpacing.lg),
        const _TransactionCard(),
        SizedBox(height: AppSpacing.lg),
        const _ReceiptActions(),
      ],
    ),
    bottom: AppButton(
      text: 'Back',
      onPressed: onBack,
      backgroundColor: AppColors.maroonDark,
    ),
  );
}

class _DueStrip extends StatelessWidget {
  const _DueStrip();
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
          child: Icon(
            Icons.calendar_month_outlined,
            color: AppColors.primaryGoldLight,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next Due Amount',
                style: AppTypography.bodyXSmall(
                  color: AppColors.mutedGray,
                ).copyWith(fontSize: 10),
              ),
              Text(
                '₹ 5,000.00',
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
                style: AppTypography.bodyXSmall(
                  color: AppColors.mutedGray,
                ).copyWith(fontSize: 10),
              ),
              Text(
                '05 Feb 2025',
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
  const _DetailedSchemeCard({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: selected ? const Color(0xFFC58C27) : AppColors.borderLight,
      ),
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
                    child: Text(
                      'Swarna Bindu',
                      style: AppTypography.sectionTitleSM(color: Colors.black),
                    ),
                  ),
                  const _ActiveBadge(),
                ],
              ),
              Text(
                'Best for long term wealth creation',
                style: AppTypography.bodyXSmall(
                  color: AppColors.mutedGray,
                ).copyWith(fontSize: 10),
              ),
              const Divider(),
              const _SchemeMeta(),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CompactSchemeCard extends StatelessWidget {
  const _CompactSchemeCard();
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
                    child: Text(
                      'Swarna Bindu',
                      style: AppTypography.sectionTitleSM(color: Colors.black),
                    ),
                  ),
                  const _ActiveBadge(),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              const _SchemeMeta(),
            ],
          ),
        ),
      ],
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
    ),
    child: const Icon(
      Icons.workspace_premium_rounded,
      color: AppColors.primaryGold,
      size: 34,
    ),
  );
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFDDF6E4),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      'Active',
      style: AppTypography.bodyXSmall(
        color: const Color(0xFF258B44),
      ).copyWith(fontSize: 10),
    ),
  );
}

class _SchemeMeta extends StatelessWidget {
  const _SchemeMeta();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _Meta(label: 'Monthly Investment', value: '₹ 5,000.00'),
      ),
      Container(width: 1, height: 24, color: AppColors.borderLight),
      SizedBox(width: AppSpacing.sm),
      Expanded(
        child: _Meta(label: 'Gold Accumulated', value: '18.400 g'),
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
      Text(
        label,
        style: AppTypography.bodyXSmall(
          color: AppColors.mutedGray,
        ).copyWith(fontSize: 9),
      ),
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
        border: Border.all(
          color: selected ? const Color(0xFFD19A3D) : AppColors.borderLight,
        ),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Radio<InstallmentType>(
            value: type,
            groupValue: ref.watch(
              paymentProvider.select((v) => v.installmentType),
            ),
            onChanged: (v) {
              if (v != null) {
                ref.read(paymentProvider.notifier).selectInstallment(v);
              }
            },
            activeColor: const Color(0xFFD09116),
          ),
          CircleAvatar(
            radius: 21,
            backgroundColor: selected
                ? const Color(0xFFFFF1D9)
                : const Color(0xFFFFE8EC),
            child: Icon(
              icon,
              color: selected
                  ? const Color(0xFFD38A18)
                  : const Color(0xFFFA5265),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium(color: Colors.black),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodyXSmall(
                    color: AppColors.mutedGray,
                  ).copyWith(fontSize: 10),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: AppTypography.bodyXSmall(
                      color: type == InstallmentType.pendingDues
                          ? Colors.red
                          : const Color(0xFF7E3DD7),
                    ).copyWith(fontSize: 10),
                  ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTypography.labelMedium(
              color: selected ? const Color(0xFF248A47) : Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.type});
  final InstallmentType type;
  @override
  Widget build(BuildContext context) {
    final amount = switch (type) {
      InstallmentType.currentMonth => '₹ 5,000.00',
      InstallmentType.pendingDues => '₹ 10,000.00',
      InstallmentType.advancePayment => '₹ 15,000.00',
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
              Text(
                'Payment Summary',
                style: AppTypography.sectionTitleSM(color: Colors.black),
              ),
              Text(
                'Current Month',
                style: AppTypography.labelSmall(color: const Color(0xFF258B44)),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          _TotalRow('Installment Amount', amount),
          _TotalRow('Convenience Fee', '₹ 0'),
          _TotalRow('GST (0%)', '₹ 0'),
          const Divider(),
          _TotalRow('Total Payable', amount, prominent: true),
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
          style: AppTypography.bodyXSmall(
            color: prominent ? Colors.black : AppColors.mutedGray,
          ),
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
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7EC),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info, color: Color(0xFFD69B2D)),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Note',
                style: AppTypography.labelMedium(color: Colors.black),
              ),
              Text(
                'Your payment will be adjusted to the oldest pending installment first.\nAny advance amount will be adjusted to upcoming installments.',
                style: AppTypography.bodyXSmall(
                  color: AppColors.mutedGray,
                ).copyWith(fontSize: 9),
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
        border: Border.all(
          color: highlighted ? const Color(0xFF75AC79) : AppColors.borderLight,
        ),
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
                Text(
                  title,
                  style: AppTypography.labelMedium(color: Colors.black),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodyXSmall(
                    color: AppColors.mutedGray,
                  ).copyWith(fontSize: 10),
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

class _WalletTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: AppColors.borderLight),
      boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 4)],
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFF0E5FF),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            color: Color(0xFF7953B6),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallets',
                style: AppTypography.labelMedium(color: Colors.black),
              ),
              Text(
                'Pay using wallet balance',
                style: AppTypography.bodyXSmall(
                  color: AppColors.mutedGray,
                ).copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.radio_button_unchecked,
          color: AppColors.borderStrongLight,
        ),
      ],
    ),
  );
}

class _PayBar extends StatelessWidget {
  const _PayBar({required this.onPay});
  final VoidCallback onPay;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.maroonDark,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount Payable',
                style: AppTypography.bodyXSmall(
                  color: Colors.white,
                ).copyWith(fontSize: 10),
              ),
              Text(
                '₹ 5,000.00',
                style: AppTypography.sectionTitleSM(color: Colors.white),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 150,
          child: FilledButton(
            onPressed: onPay,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7B4E0B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text('Pay ₹5,000'),
          ),
        ),
      ],
    ),
  );
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
            child: Icon(
              Icons.circle_outlined,
              color: AppColors.borderStrongLight,
              size: 17,
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Payment Initiated',
            style: AppTypography.bodyXSmall(
              color: Colors.black,
            ).copyWith(fontSize: 9),
          ),
          Text(
            'Processing...',
            style: AppTypography.bodyXSmall(
              color: const Color(0xFFD19115),
            ).copyWith(fontSize: 9),
          ),
          Text(
            'Payment Successful',
            style: AppTypography.bodyXSmall(
              color: AppColors.mutedGray,
            ).copyWith(fontSize: 9),
          ),
        ],
      ),
    ],
  );
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 7)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Summary',
          style: AppTypography.sectionTitleSM(color: Colors.black),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const _GoldThumbnail(small: true),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Swarna Bindu',
                    style: AppTypography.labelMedium(color: Colors.black),
                  ),
                  const _ActiveBadge(),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _Meta(label: 'Installment Type', value: 'Current Month'),
            ),
            Container(width: 1, height: 24, color: AppColors.borderLight),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _Meta(label: 'Due Date', value: '05 Jun 2025'),
            ),
            Container(width: 1, height: 24, color: AppColors.borderLight),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _Meta(label: 'Amount Paid', value: '₹5,000'),
            ),
          ],
        ),
        const Divider(),
        _TransactionRow('Transaction ID', 'TXN125060512341'),
        _TransactionRow('Payment Method', 'UPI - Google Pay'),
        _TransactionRow('Date & Time', '05 Jun 2025, 9:41 AM'),
      ],
    ),
  );
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
        Text(
          label,
          style: AppTypography.bodyXSmall(
            color: AppColors.mutedGray,
          ).copyWith(fontSize: 10),
        ),
        Text(
          value,
          style: AppTypography.bodyXSmall(
            color: Colors.black,
          ).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
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
          child: Icon(
            Icons.verified_user_outlined,
            size: 19,
            color: AppColors.primaryGoldLight,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Safe & Secure',
                style: AppTypography.labelMedium(color: Colors.black),
              ),
              Text(
                'Your payment is secure. Please do not press back\nor close the app while we process your payment.',
                style: AppTypography.bodyXSmall(
                  color: AppColors.mutedGray,
                ).copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SuccessNotice extends StatelessWidget {
  const _SuccessNotice();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F6F1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF338D4B)),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Payment Of ₹5,000 Has Been Successfully Processed.\nA Confirmation Has Been Sent To Your Registered Mobile\nNumber And Email ID.',
            style: AppTypography.bodyXSmall(
              color: AppColors.textSecondaryLight,
            ).copyWith(fontSize: 9),
          ),
        ),
      ],
    ),
  );
}

class _ReceiptActions extends StatelessWidget {
  const _ReceiptActions();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ReceiptAction(
          icon: Icons.receipt_long_outlined,
          label: 'Download Receipt',
          subtitle: 'Save or share\nyour receipt',
        ),
      ),
      SizedBox(width: AppSpacing.sm),
      Expanded(
        child: _ReceiptAction(
          icon: Icons.calendar_month_outlined,
          label: 'View Payment History',
          subtitle: 'Check your all\npayments',
        ),
      ),
    ],
  );
}

class _ReceiptAction extends StatelessWidget {
  const _ReceiptAction({
    required this.icon,
    required this.label,
    required this.subtitle,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFF1E4D6)),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFFF2E4E6),
          child: Icon(icon, size: 17, color: AppColors.maroonDark),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodyXSmall(
                  color: Colors.black,
                ).copyWith(fontSize: 9, fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: AppTypography.bodyXSmall(
                  color: AppColors.mutedGray,
                ).copyWith(fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
