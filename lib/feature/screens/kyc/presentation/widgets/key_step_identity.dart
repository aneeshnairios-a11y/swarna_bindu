import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/constants/image_string/image_strings.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../global_widgets/common_text_field.dart';
import 'upload_document_box.dart';

class KycStepIdentity extends StatelessWidget {
  const KycStepIdentity({
    super.key,
    required this.formKey,
    required this.aadhaarController,
    required this.panController,
    this.aadhaarFrontPath,
    this.aadhaarBackPath,
    this.panCardPath,
    this.onUploadAadhaarFront,
    this.onUploadAadhaarBack,
    this.onUploadPanCard,
    this.onConnectDigiLocker,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController aadhaarController;
  final TextEditingController panController;
  final String? aadhaarFrontPath;
  final String? aadhaarBackPath;
  final String? panCardPath;
  final VoidCallback? onUploadAadhaarFront;
  final VoidCallback? onUploadAadhaarBack;
  final VoidCallback? onUploadPanCard;
  final VoidCallback? onConnectDigiLocker;

  @override
  Widget build(BuildContext context) {
    final k = AppStrings.kyc;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k.identityTitle, style: AppTypography.sectionTitle(color: AppColors.textPrimaryLight)),
          SizedBox(height: 4.h),
          Text(k.identitySubtitle, style: AppTypography.bodySmall(color: AppColors.textMutedLight)),
          SizedBox(height: AppSpacing.xl),

          _DocCard(
            image: AppAssetImage.aadhaarCard,
            iconColor: AppColors.warningOrange,
            title: k.aadhaarCardTitle,
            required: true,
            children: [
              AppTextField(
                label: k.aadhaarNumberLabel,
                isRequired: true,
                hintText: k.aadhaarNumberHint,
                controller: aadhaarController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
                validator: (v) {
                  final digits = (v ?? '').trim();
                  if (digits.isEmpty) return 'Aadhaar number is required';
                  if (digits.length != 12) return 'Enter a valid 12-digit Aadhaar number';
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: UploadDocumentBox(label: k.uploadFront, filePath: aadhaarFrontPath, onTap: onUploadAadhaarFront),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: UploadDocumentBox(label: k.uploadBack, filePath: aadhaarBackPath, onTap: onUploadAadhaarBack),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.borderLight)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(k.orDivider, style: AppTypography.labelSmall(color: AppColors.textMutedLight)),
              ),
              Expanded(child: Divider(color: AppColors.borderLight)),
            ],
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
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user_outlined, color: AppColors.infoBlue, size: AppSpacing.iconLg),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k.digiLockerTitle, style: AppTypography.sectionTitleSM(color: AppColors.textPrimaryLight)),
                          SizedBox(height: 2.h),
                          Text(k.digiLockerSubtitle, style: AppTypography.caption(color: AppColors.textMutedLight)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onConnectDigiLocker,
                    style: ButtonStyle(
                      side: WidgetStateProperty.all(BorderSide(color: AppColors.maroonPrimary, width: 1.w)),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd))),
                    ),
                    child: Text(k.digiLockerCta, style: AppTypography.buttonMedium(color: AppColors.maroonPrimary)),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          _DocCard(
            image: AppAssetImage.panCard,
            iconColor: AppColors.infoBlue,
            title: k.panCardTitle,
            required: true,
            children: [
              AppTextField(
                label: k.panNumberLabel,
                isRequired: true,
                hintText: k.panNumberHint,
                controller: panController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
                validator: (v) {
                  final value = (v ?? '').trim().toUpperCase();
                  if (value.isEmpty) return 'PAN number is required';
                  final ok = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(value);
                  return ok ? null : 'Enter a valid PAN number';
                },
              ),
              SizedBox(height: AppSpacing.md),
              UploadDocumentBox(label: k.uploadPanCard, filePath: panCardPath, onTap: onUploadPanCard),
            ],
          ),

          SizedBox(height: AppSpacing.lg),
          _InfoStrip(icon: Icons.verified_user_rounded, text: k.documentsSafeNote),
        ],
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  const _DocCard({required this.image, required this.iconColor, required this.title, required this.required, required this.children});

  final String image;
  final Color iconColor;
  final String title;
  final bool required;
  final List<Widget> children;

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
              Image.asset(image, color: iconColor, fit: BoxFit.cover, width: AppSpacing.iconLg, height: AppSpacing.iconLg),
              SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTypography.sectionTitleSM(color: AppColors.textPrimaryLight)),
              if (required) ...[
                SizedBox(width: AppSpacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2.h),
                  decoration: BoxDecoration(color: AppColors.paidBg, borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                  child: Text(AppStrings.kyc.requiredTag, style: AppTypography.statusBadge(color: AppColors.paidText)),
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ...children,
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
      decoration: BoxDecoration(
        color: AppColors.goldSurfaceLight.withValues(alpha: 0.5),
        border: Border.all(color: AppColors.goldBorderLight),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.iconLg,
            height: AppSpacing.iconLg,
            decoration: BoxDecoration(color: AppColors.goldSurfaceLight, shape: BoxShape.circle),
            child: Center(
              child: Icon(icon, color: AppColors.primaryGoldDark, size: AppSpacing.iconMd),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: AppTypography.caption(color: AppColors.textMutedLight)),
          ),
        ],
      ),
    );
  }
}
