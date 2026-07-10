import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gold_scheme/core/constants/app_string/app_strings.dart';
import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_spacing.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';

import '../../../../global_widgets/common_text_field.dart';

/// Placeholder list — replace with the store's supported bank list
/// (or a searchable IFSC-lookup field) in Phase 2.
const List<String> kSupportedBanks = ['Axis Bank Ltd.', 'State Bank of India', 'HDFC Bank', 'ICICI Bank', 'Federal Bank', 'Canara Bank', 'Kerala Gramin Bank', 'Other'];

class KycStepBank extends StatelessWidget {
  const KycStepBank({
    super.key,
    required this.formKey,
    required this.accountHolderController,
    required this.accountNumberController,
    required this.confirmAccountNumberController,
    required this.ifscController,
    required this.branchController,
    required this.upiController,
    required this.bankName,
    required this.onBankChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController accountHolderController;
  final TextEditingController accountNumberController;
  final TextEditingController confirmAccountNumberController;
  final TextEditingController ifscController;
  final TextEditingController branchController;
  final TextEditingController upiController;
  final String? bankName;
  final ValueChanged<String?> onBankChanged;

  @override
  Widget build(BuildContext context) {
    final k = AppStrings.kyc;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k.bankTitle, style: AppTypography.sectionTitle(color: AppColors.textPrimaryLight)),
          SizedBox(height: 4.h),
          Text(k.bankSubtitle, style: AppTypography.bodySmall(color: AppColors.textMutedLight)),
          SizedBox(height: AppSpacing.xl),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                AppTextField(
                  label: k.accountHolderLabel,
                  isRequired: true,
                  hintText: k.accountHolderHint,
                  controller: accountHolderController,
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Account holder name is required' : null,
                ),
                SizedBox(height: AppSpacing.lg),
                AppDropdownField<String>(
                  label: k.bankNameLabel,
                  isRequired: true,
                  hintText: 'Select bank',
                  value: bankName,
                  items: kSupportedBanks,
                  itemLabel: (b) => b,
                  prefixIcon: Icons.account_balance_outlined,
                  onChanged: onBankChanged,
                  validator: (v) => v == null ? 'Required' : null,
                ),
                SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: k.accountNumberLabel,
                  isRequired: true,
                  hintText: k.accountNumberHint,
                  controller: accountNumberController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.credit_card_outlined,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Account number is required';
                    if (value.length < 9 || value.length > 18) return 'Enter a valid account number';
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: k.confirmAccountNumberLabel,
                  isRequired: true,
                  hintText: k.accountNumberHint,
                  controller: confirmAccountNumberController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.credit_card_outlined,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Please confirm the account number';
                    if (value != accountNumberController.text.trim()) return 'Account numbers do not match';
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: k.ifscLabel,
                        isRequired: true,
                        hintText: k.ifscHint,
                        controller: ifscController,
                        textCapitalization: TextCapitalization.characters,
                        validator: (v) {
                          final value = (v ?? '').trim().toUpperCase();
                          if (value.isEmpty) return 'Required';
                          final ok = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value);
                          return ok ? null : 'Enter a valid IFSC code';
                        },
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        label: k.branchNameLabel,
                        isRequired: true,
                        hintText: k.branchNameHint,
                        controller: branchController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                _InfoStrip(icon: Icons.shield_outlined, text: k.bankUsageNote),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k.upiLabel, style: AppTypography.labelMedium(color: AppColors.textSecondaryLight)),
                SizedBox(height: 2.h),
                Text(k.upiSubtitle, style: AppTypography.caption(color: AppColors.textMutedLight)),
                SizedBox(height: AppSpacing.sm),
                AppTextField(hintText: k.upiHint, controller: upiController, prefixIcon: Icons.alternate_email),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.lg),
          _InfoStrip(icon: Icons.shield_outlined, text: k.bankSecureNote),
        ],
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.goldSurfaceLight, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSpacing.iconMd, color: AppColors.primaryGoldDark),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: AppTypography.caption(color: AppColors.textMutedLight)),
          ),
        ],
      ),
    );
  }
}
