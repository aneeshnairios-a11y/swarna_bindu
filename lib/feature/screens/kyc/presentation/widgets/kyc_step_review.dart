import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../../core/formatter/app_formatters.dart';
import '../viewmodels/kyc_viewmodels.dart';

class KycStepReview extends StatelessWidget {
  const KycStepReview({
    super.key,
    required this.data,
    required this.onEditStep,
    this.onCaptureSelfie,
  });

  final KycFormData data;

  /// step index: 0=Personal, 1=Identity, 2=Address, 3=Bank
  final ValueChanged<int> onEditStep;
  final VoidCallback? onCaptureSelfie;

  @override
  Widget build(BuildContext context) {
    final k = AppStrings.kyc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          k.reviewTitle,
          style: AppTypography.sectionTitle(color: AppColors.textPrimaryLight),
        ),
        SizedBox(height: 4.h),
        Text(
          k.reviewSubtitle,
          style: AppTypography.bodySmall(color: AppColors.textMutedLight),
        ),
        SizedBox(height: AppSpacing.xl),

        _ReviewCard(
          icon: Icons.person_outline,
          title: k.personalSectionLabel,
          onEdit: () => onEditStep(0),
          children: [
            _ReviewRow(
              left: _ReviewField(label: k.fullNameLabel, value: data.fullName),
              right: _ReviewField(label: k.emailLabel, value: data.email),
            ),
            SizedBox(height: AppSpacing.md),
            _ReviewRow(
              left: _ReviewField(
                label: k.dobLabel,
                value: data.dob == null ? '—' : AppFormatters.date(data.dob!),
              ),
              right: _ReviewField(
                label: k.mobileLabel,
                value: data.mobile.isEmpty ? '—' : data.mobile,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            _ReviewField(label: k.genderLabel, value: data.gender ?? '—'),
          ],
        ),

        SizedBox(height: AppSpacing.lg),
        _ReviewCard(
          icon: Icons.badge_outlined,
          title: k.identitySectionLabel,
          onEdit: () => onEditStep(1),
          children: [
            _ReviewRow(
              left: _ReviewField(
                label: k.aadhaarNumberLabel,
                value: _maskAadhaar(data.aadhaarNumber),
              ),
              right: _ReviewField(
                label: k.panNumberLabel,
                value: data.panNumber.isEmpty ? '—' : data.panNumber,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.lg),
        _ReviewCard(
          icon: Icons.home_outlined,
          title: k.addressSectionLabel,
          onEdit: () => onEditStep(2),
          children: [
            _ReviewField(
              label: 'Address',
              value: data.formattedAddress.isEmpty
                  ? '—'
                  : data.formattedAddress,
            ),
            SizedBox(height: AppSpacing.md),
            _ReviewField(
              label: k.pinCodeLabel,
              value: data.pinCode.isEmpty ? '—' : data.pinCode,
            ),
          ],
        ),

        SizedBox(height: AppSpacing.lg),
        _ReviewCard(
          icon: Icons.account_balance_outlined,
          title: k.bankSectionLabel,
          onEdit: () => onEditStep(3),
          children: [
            _ReviewRow(
              left: _ReviewField(
                label: k.bankNameLabel,
                value: data.bankName ?? '—',
              ),
              right: _ReviewField(
                label: k.ifscLabel,
                value: data.ifscCode.isEmpty ? '—' : data.ifscCode,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            _ReviewRow(
              left: _ReviewField(
                label: k.accountNumberLabel,
                value: _maskAccount(data.accountNumber),
              ),
              right: _ReviewField(
                label: 'UPI ID',
                value: data.upiId.isEmpty ? '—' : data.upiId,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.lg),
        _SelfieCard(
          selfieCapturedAt: data.selfieCapturedAt,
          onCapture: onCaptureSelfie,
        ),

        SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.goldSurfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.shield_outlined,
                size: AppSpacing.iconMd,
                color: AppColors.primaryGoldDark,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  k.reviewSecureNote,
                  style: AppTypography.caption(color: AppColors.textMutedLight),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _maskAadhaar(String value) {
    if (value.length != 12) return value.isEmpty ? '—' : value;
    return 'XXXX XXXX ${value.substring(8)}';
  }

  String _maskAccount(String value) {
    if (value.isEmpty) return '—';
    if (value.length <= 4) return value;
    return value.substring(value.length - 4).padLeft(value.length, '•');
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.children,
    this.onEdit,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.goldSurfaceLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  icon,
                  size: AppSpacing.iconMd,
                  color: AppColors.primaryGoldDark,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.sectionTitleSM(
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 14.sp,
                          color: AppColors.maroonPrimary,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Edit',
                          style: AppTypography.labelSmall(
                            color: AppColors.maroonPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: AppSpacing.md),
        Expanded(child: right),
      ],
    );
  }
}

class _ReviewField extends StatelessWidget {
  const _ReviewField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption(color: AppColors.textMutedLight),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTypography.labelMedium(color: AppColors.textPrimaryLight),
        ),
      ],
    );
  }
}

/// Selfie isn't yet its own wizard step in the Figma flow provided —
/// this card previews what Review will show once a selfie-capture step
/// (camera + liveness check) is added in Phase 2.
class _SelfieCard extends StatelessWidget {
  const _SelfieCard({required this.selfieCapturedAt, this.onCapture});

  final DateTime? selfieCapturedAt;
  final VoidCallback? onCapture;

  @override
  Widget build(BuildContext context) {
    final k = AppStrings.kyc;
    final captured = selfieCapturedAt != null;

    return Container(
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.goldSurfaceLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: AppSpacing.iconMd,
                  color: AppColors.primaryGoldDark,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  k.selfieSectionLabel,
                  style: AppTypography.sectionTitleSM(
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              if (!captured)
                InkWell(
                  onTap: onCapture,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2.h,
                    ),
                    child: Text(
                      k.captureSelfieCta,
                      style: AppTypography.labelSmall(
                        color: AppColors.maroonPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _ReviewField(
            label: k.selfieSectionLabel,
            value: captured
                ? 'Captured on ${AppFormatters.dateTime(selfieCapturedAt!)}'
                : k.selfieNotCaptured,
          ),
        ],
      ),
    );
  }
}
