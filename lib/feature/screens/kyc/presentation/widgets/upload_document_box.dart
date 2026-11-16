import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

/// Tappable upload box used for KYC document capture (Aadhaar / PAN).
/// Phase 1: UI-only placeholder. Phase 2: wire to image_picker +
/// flutter_image_compress, then upload via POST /users/:id/kyc.
class UploadDocumentBox extends StatelessWidget {
  const UploadDocumentBox({
    super.key,
    required this.label,
    this.hint,
    this.filePath,
    this.onTap,
  });

  final String label;
  final String? hint;
  final String? filePath;
  final VoidCallback? onTap;

  bool get _hasFile => filePath != null && filePath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = _hasFile
        ? (isDark
              ? AppColors.successGreen.withValues(alpha: 0.16)
              : AppColors.successGreenLight)
        : (isDark
              ? AppColors.goldSurfaceDark.withValues(alpha: 0.5)
              : AppColors.goldSurfaceLight.withValues(alpha: 0.5));

    final borderColor = _hasFile
        ? AppColors.successGreen
        : (isDark ? AppColors.borderStrongDark : AppColors.goldBorderLight);

    final iconColor = _hasFile
        ? AppColors.successGreen
        : (isDark ? AppColors.primaryGold : AppColors.primaryGoldDark);

    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textMutedLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _hasFile ? Icons.check_circle : Icons.file_upload_outlined,
              color: iconColor,
              size: AppSpacing.iconLg,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              _hasFile ? 'Uploaded' : label,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall(
                color: primaryTextColor,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              hint ?? AppStrings.kyc.uploadHint,
              textAlign: TextAlign.center,
              style: AppTypography.caption(color: secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
