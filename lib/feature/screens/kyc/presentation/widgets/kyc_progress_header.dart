import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

/// Header used on every KYC step: back arrow, title, skip link,
/// "Step X of Y • Section" caption, and a segmented progress bar.
class KycProgressHeader extends StatelessWidget {
  const KycProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.sectionLabel,
    this.onBack,
    this.onSkip,
  });

  /// 1-based current step, e.g. 1 for the first step.
  final int currentStep;
  final int totalSteps;
  final String sectionLabel;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final percent = ((currentStep / totalSteps) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  Icons.arrow_back,
                  size: AppSpacing.iconLg,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                AppStrings.kyc.appBarTitle,
                style: AppTypography.headingSM(
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            InkWell(
              onTap: onSkip,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.kyc.skip,
                      style: AppTypography.labelMedium(
                        color: AppColors.maroonPrimary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.arrow_forward,
                      size: 14.sp,
                      color: AppColors.maroonPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.only(left: AppSpacing.xxxl + AppSpacing.xs),
          child: Text(
            'Step $currentStep of $totalSteps • $sectionLabel',
            style: AppTypography.caption(color: AppColors.textMutedLight),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(totalSteps, (i) {
                  final filled = i < currentStep;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: i == totalSteps - 1 ? 0 : 4.w,
                      ),
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: filled
                            ? AppColors.maroonPrimary
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              '$percent%',
              style: AppTypography.labelSmall(
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
