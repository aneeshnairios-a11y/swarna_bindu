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
          color: _hasFile
              ? AppColors.successGreenLight
              : AppColors.goldSurfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: _hasFile
                ? AppColors.successGreen
                : AppColors.goldBorderLight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _hasFile ? Icons.check_circle : Icons.file_upload_outlined,
              color: _hasFile
                  ? AppColors.successGreen
                  : AppColors.primaryGoldDark,
              size: AppSpacing.iconLg,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              _hasFile ? 'Uploaded' : label,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall(
                color: AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              hint ?? AppStrings.kyc.uploadHint,
              textAlign: TextAlign.center,
              style: AppTypography.caption(color: AppColors.textMutedLight),
            ),
          ],
        ),
      ),
    );
  }
}
