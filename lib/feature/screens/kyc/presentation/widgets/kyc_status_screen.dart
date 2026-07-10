import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:gold_scheme/core/constants/app_string/app_strings.dart';
import 'package:gold_scheme/core/router/route_name.dart';
import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_spacing.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';

import '../../../../global_widgets/common_button.dart';

enum KycOutcome { success, rejected, pending }

/// Terminal screen shown after KYC submission.
/// - [success]  → mirrors "KYC Status" mock (green check, Go to Dashboard)
/// - [rejected] → mirrors "Complete KYC" retry mock (red X, Re-upload Document)
/// - [pending]  → inferred third state per the KYC Status spec in Section 9
///   of the project doc (pending/verified/rejected timeline); no mock was
///   provided for it, styled consistently with the other two.
class KycStatusScreen extends StatelessWidget {
  const KycStatusScreen({super.key, required this.outcome, this.onRetry});

  final KycOutcome outcome;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final k = AppStrings.kyc;

    late final String appBarTitle;
    late final IconData icon;
    late final Color iconColor;
    late final Color iconBg;
    late final String title;
    late final String subtitle;

    switch (outcome) {
      case KycOutcome.success:
        appBarTitle = k.statusAppBarTitle;
        icon = Icons.check;
        iconColor = AppColors.successGreen;
        iconBg = AppColors.successGreenLight;
        title = k.statusSuccessTitle;
        subtitle = k.statusSuccessSubtitle;
        break;
      case KycOutcome.rejected:
        appBarTitle = k.appBarTitle; // "Complete KYC" — matches the retry mock
        icon = Icons.close;
        iconColor = AppColors.errorRed;
        iconBg = AppColors.errorRedLight;
        title = k.statusRejectedTitle;
        subtitle = k.statusRejectedSubtitle;
        break;
      case KycOutcome.pending:
        appBarTitle = k.statusAppBarTitle;
        icon = Icons.hourglass_top_rounded;
        iconColor = AppColors.warningOrange;
        iconBg = AppColors.warningOrangeLight;
        title = k.statusPendingTitle;
        subtitle = k.statusPendingSubtitle;
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
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
                  Text(
                    appBarTitle,
                    style: AppTypography.headingSM(
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: AppSpacing.xxxl + AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  k.statusStepCaption,
                  style: AppTypography.caption(color: AppColors.textMutedLight),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.xxxl,
                        horizontal: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: iconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: AppSpacing.iconXl,
                              color: iconColor,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppTypography.headingSM(
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall(
                              color: AppColors.textMutedLight,
                            ),
                          ),
                          if (outcome == KycOutcome.success ||
                              outcome == KycOutcome.pending) ...[
                            SizedBox(height: AppSpacing.lg),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                                horizontal: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successGreenLight,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: AppSpacing.iconSm,
                                    color: AppColors.successGreen,
                                  ),
                                  SizedBox(width: AppSpacing.xs),
                                  Column(
                                    children: [
                                      Text(
                                        k.statusEtaLabel,
                                        style: AppTypography.caption(
                                          color: AppColors.textMutedLight,
                                        ),
                                      ),
                                      Text(
                                        k.statusEtaValue,
                                        style: AppTypography.labelMedium(
                                          color: AppColors.successGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: outcome == KycOutcome.rejected
                  ? OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.maroonPrimary,
                        side: const BorderSide(color: AppColors.maroonPrimary),
                      ),
                      onPressed: onRetry ?? () => context.pop(),
                      child: Text(k.statusReuploadCta),
                    )
                  : AppButton(
                      text: k.statusGoToDashboardCta,
                      onPressed: () =>
                          context.go(RouteName.paymentPath('demo')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
