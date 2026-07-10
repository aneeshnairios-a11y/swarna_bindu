import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gold_scheme/core/router/route_name.dart';
import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_spacing.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';

import '../../../global_widgets/common_button.dart';
import '../schemes_viewmodel/scheme_model.dart';

/// Scheme detail + join flow — Phase 1, mock data only.
/// "Confirm & Join Scheme" currently just simulates success; wire it up to
/// `POST /enrollments` once the data layer is ready.
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

  Future<void> _confirmJoin(SchemeModel scheme) async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 600)); // mock latency
    if (!mounted) return;
    setState(() => _submitting = false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) => _SuccessSheet(
        schemeName: scheme.name,
        onDone: () {
          Navigator.of(ctx).pop();
          context.go(RouteName.dashboard);
        },
      ),
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
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl, horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.splashGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(gradient: AppColors.goldCardGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.wb_sunny_rounded, color: AppColors.textOnGold, size: 28),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  scheme.name.toUpperCase(),
                  style: AppTypography.headingLG(color: Colors.white).copyWith(letterSpacing: 2),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(scheme.tagline, style: AppTypography.bodySmall(color: Colors.white70)),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text('Terms & Conditions', style: AppTypography.sectionTitleSM(color: textColor)),
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
            text: 'Confirm & Join Scheme',
            isLoading: _submitting,
            onPressed: _canSubmit ? () => _confirmJoin(scheme) : null,
            backgroundColor: AppColors.primaryGold,
            disabledBackgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.borderStrongLight,
            textColor: AppColors.textOnGold,
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
              activeColor: AppColors.primaryGold,
              checkColor: AppColors.textOnGold,
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

class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet({required this.schemeName, required this.onDone});

  final String schemeName;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xl),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXxl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? AppColors.paidBgDark : AppColors.successGreenLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: AppColors.successGreen, size: 32),
          ),
          SizedBox(height: AppSpacing.lg),
          Text("You're in!", style: AppTypography.headingSM(color: textColor)),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Your request to join $schemeName has been recorded.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(color: mutedColor),
          ),
          SizedBox(height: AppSpacing.xl),
          AppButton(
            text: 'Go to Dashboard',
            onPressed: onDone,
            backgroundColor: AppColors.primaryGold,
            textColor: AppColors.textOnGold,
          ),
        ],
      ),
    );
  }
}