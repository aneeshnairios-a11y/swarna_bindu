import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../core/constants/image_string/image_strings.dart';
import '../../../global_widgets/common_button.dart';
import '../schemes_viewmodel/scheme_model.dart';
import 'my_schemes_screen.dart';

/// Scheme detail + join flow — Phase 1, mock data only.
///
/// Flow: agree to both consent checkboxes → tap "Join This Scheme" →
/// [_ConfirmSchemeDialog] asks the user to confirm → tapping "Add scheme"
/// there simulates the enrollment call and lands on [MySchemesScreen].
/// Wire the mock delay up to `POST /enrollments` once the data layer is
/// ready.
class SchemeDetailScreen extends StatefulWidget {
  const SchemeDetailScreen({super.key, required this.schemeId});

  final String schemeId;

  @override
  State<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen> {
  bool _agreedTerms = false;
  bool _consentKyc = false;
  bool _submitting = false;

  bool get _canSubmit => _agreedTerms && _consentKyc && !_submitting;

  Future<void> _onJoinPressed(SchemeModel scheme) async {
    // Step 1 — ask the user to confirm the scheme they're about to add.
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ConfirmSchemeDialog(scheme: scheme),
    );

    if (confirmed != true || !mounted) return;

    // Step 2 — "Add scheme" was tapped: simulate the enrollment call.
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 600)); // mock latency
    if (!mounted) return;
    setState(() => _submitting = false);

    // Step 3 — land on My Schemes with the new enrollment.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MySchemesScreen(scheme: scheme)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = findScheme(widget.schemeId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: Text('Scheme Details', style: AppTypography.sectionTitle(color: textColor))),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            width: double.infinity,
            // padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl, horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.splashGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Column(
              children: [
                Image.asset(AppAssetImage.appLogo, height: 164.h,width: 164.w,),
              ],
            ),
          ),
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
              children: scheme.termsAndConditions
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
                          decoration: const BoxDecoration(color: AppColors.primaryGold, shape: BoxShape.circle),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(t, style: AppTypography.bodyXSmall(color: mutedColor))),
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
            isLoading: _submitting,
            onPressed: _canSubmit ? () => _onJoinPressed(scheme) : null,
            backgroundColor: AppColors.maroonDark,
            disabledBackgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.borderStrongLight,
            textColor: Colors.white,
          ),
          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({required this.value, required this.label, required this.onChanged});

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
            // ── Maroon header — logo + title ──────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.sm,),
              decoration: const BoxDecoration(gradient: AppColors.splashGradient),
              child: Column(
                children: [
                  Image.asset(AppAssetImage.appLogo, height: 150.h,width: 150.w,),
                  // SizedBox(height: AppSpacing.sm),
                  Text(
                    'Confirm Scheme Selection',
                    textAlign: TextAlign.center,
                    style: AppTypography.sectionTitle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // ── White body — confirmation + actions ───────────
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
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
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