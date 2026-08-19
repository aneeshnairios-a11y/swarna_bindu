import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../core/constants/image_string/image_strings.dart';
import '../../../global_widgets/common_button.dart';
import '../schemes_viewmodel/scheme_model.dart';
import '../schemes_viewmodel/schemes_notifier.dart';
import 'my_schemes_screen.dart';

/// Scheme detail + join flow — Phase 2, wired to `GET /schemes/:id` and
/// `POST /schemes/:id/join` via [schemeDetailProvider].
///
/// Flow: agree to both consent checkboxes → tap "Join This Scheme" →
/// [_ConfirmSchemeDialog] asks the user to confirm → tapping "Add scheme"
/// there calls the real join endpoint. On success, lands on
/// [MySchemesScreen], which re-fetches the live list via
/// `GET /schemes/my-schemes` rather than being handed the join response
/// directly. On `KYC_REQUIRED`,
/// prompts the user to complete KYC instead of showing a generic error.
class SchemeDetailScreen extends ConsumerStatefulWidget {
  const SchemeDetailScreen({super.key, required this.schemeId});

  final String schemeId;

  @override
  ConsumerState<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends ConsumerState<SchemeDetailScreen> {
  bool _agreedTerms = false;
  bool _consentKyc = false;

  bool _canSubmit(bool isJoining) => _agreedTerms && _consentKyc && !isJoining;

  Future<void> _onJoinPressed(SchemeModel scheme) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ConfirmSchemeDialog(scheme: scheme),
    );

    if (confirmed != true || !mounted) return;

    await ref.read(schemeDetailProvider.notifier).join();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.errorRed));
  }

  Future<void> _showKycRequiredDialog() async {
    if (!mounted) return;
    final goToKyc = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('KYC Required'),
        content: const Text(
          'Your KYC approval is required before joining a gold scheme. '
              'Complete your KYC to continue.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Later')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Complete KYC')),
        ],
      ),
    );
    if (goToKyc == true && mounted) {
      context.push(RouteName.kycSubmit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(schemeDetailProvider);

    ref.listen<SchemeDetailState>(schemeDetailProvider, (previous, next) {
      if (previous?.joinStatus == next.joinStatus) return;

      switch (next.joinStatus) {
        case SchemeJoinStatus.success:
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MySchemesScreen()),
          );
          break;
        case SchemeJoinStatus.kycRequired:
          _showKycRequiredDialog();
          ref.read(schemeDetailProvider.notifier).resetJoinStatus();
          break;
        case SchemeJoinStatus.error:
          _showError(next.joinErrorMessage ?? 'Something went wrong. Please try again.');
          ref.read(schemeDetailProvider.notifier).resetJoinStatus();
          break;
        case SchemeJoinStatus.idle:
        case SchemeJoinStatus.joining:
          break;
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Scheme Details', style: AppTypography.sectionTitle(color: textColor)),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, SchemeDetailState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final scheme = state.scheme;
    if (scheme == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 40, color: AppColors.errorRed),
              SizedBox(height: AppSpacing.sm),
              Text(
                state.errorMessage ?? 'Could not load this scheme.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () => ref.read(schemeDetailProvider.notifier).loadDetail(widget.schemeId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.splashGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Column(
            children: [
              Image.asset(AppAssetImage.appLogo, height: 164.h, width: 164.w),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Text(scheme.name, style: AppTypography.headingSM(color: textColor)),
        SizedBox(height: AppSpacing.xs),
        Text(scheme.description, style: AppTypography.bodySmall(color: mutedColor)),
        SizedBox(height: AppSpacing.xl),
        Text('Terms & Condition', style: AppTypography.sectionTitleSM(color: textColor)),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.pendingBgDark : AppColors.warningOrangeLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warningOrange),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Please read all terms carefully before proceeding with the scheme.',
                  style: AppTypography.bodyXSmall(color: mutedColor),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: border),
          ),
          child: Column(
            children: scheme.termsList
                .map(
                  (t) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(t, style: AppTypography.bodyXSmall(color: mutedColor)),
                    ),
                  ],
                ),
              ),
            )
                .toList(),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        _ConsentTile(
          value: _agreedTerms,
          label: 'I agree to the scheme terms & privacy policy',
          onChanged: (v) => setState(() => _agreedTerms = v),
        ),
        _ConsentTile(
          value: _consentKyc,
          label: 'I consent to sharing my KYC (Aadhaar / PAN) for scheme verification',
          onChanged: (v) => setState(() => _consentKyc = v),
        ),
        SizedBox(height: AppSpacing.xxl),
        AppButton(
          text: 'Join This Scheme',
          isLoading: state.isJoining,
          onPressed: _canSubmit(state.isJoining) ? () => _onJoinPressed(scheme) : null,
          backgroundColor: AppColors.maroonDark,
          disabledBackgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.borderStrongLight,
          textColor: Colors.white,
        ),
        SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.maroonDark,
              checkColor: AppColors.surfaceLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(label, style: AppTypography.bodySmall(color: textColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Are you sure you want to add the following scheme?" confirmation
/// dialog, shown right after the user taps "Join This Scheme".
/// Returns `true` via [Navigator.pop] when "Add scheme" is tapped,
/// `false`/`null` on Cancel or dismiss.
class _ConfirmSchemeDialog extends StatelessWidget {
  const _ConfirmSchemeDialog({required this.scheme});

  final SchemeModel scheme;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(gradient: AppColors.splashGradient),
              child: Column(
                children: [
                  Image.asset(AppAssetImage.appLogo, height: 150.h, width: 150.w),
                  Text(
                    'Confirm Scheme Selection',
                    textAlign: TextAlign.center,
                    style: AppTypography.sectionTitle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: AppColors.surfaceLight,
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to add the following scheme ?',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall(color: AppColors.textPrimaryLight),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.goldSurfaceLight,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.savings_rounded, color: AppColors.maroonDark),
                        SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            '${scheme.name} Scheme',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelLarge(color: AppColors.maroonDark)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'you can cancel within 24 hours of joining with no penalty',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(color: AppColors.textMutedLight)
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          onPressed: () => Navigator.of(context).pop(false),
                          height: 48,
                          backgroundColor: AppColors.surfaceVariantLight,
                          textColor: AppColors.textPrimaryLight,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppButton(
                          text: 'Add scheme',
                          onPressed: () => Navigator.of(context).pop(true),
                          height: 48,
                          backgroundColor: AppColors.maroonDark,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}