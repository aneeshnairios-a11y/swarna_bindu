import 'package:flutter/material.dart';

import 'package:swarna_bindu/core/formatter/app_formatters.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../global_widgets/common_button.dart';

/// Shown when the customer taps "Redeem Gold" from the dashboard quick
/// actions. Phase 1 — mock balance; replace with the enrollment's real
/// gold balance and wire the button to `POST /redemptions` in Phase 2.
class RedeemGoldScreen extends StatefulWidget {
  const RedeemGoldScreen({
    super.key,
    this.availableGoldGrams = 7.250,
    this.investedAmount = 60000,
    this.goldRatePerGram = 8500,
  });

  final double availableGoldGrams;
  final double investedAmount;
  final double goldRatePerGram;

  @override
  State<RedeemGoldScreen> createState() => _RedeemGoldScreenState();
}

class _RedeemGoldScreenState extends State<RedeemGoldScreen> {
  bool _submitting = false;

  double get _currentValue => widget.availableGoldGrams * widget.goldRatePerGram;

  Future<void> _confirmRedeem() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 600)); // mock latency
    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Redemption request for ${AppFormatters.goldWeight(widget.availableGoldGrams)} submitted.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back_rounded, color: textColor, size: AppSpacing.iconLg),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text('Redeem Gold', style: AppTypography.headingSM(color: textColor)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.splashGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Available gold', style: AppTypography.bodySmall(color: Colors.white70)),
                              SizedBox(height: 4),
                              Text(
                                '${widget.availableGoldGrams.toStringAsFixed(3)}g',
                                style: AppTypography.goldAmount(color: AppColors.primaryGold),
                              ),
                              SizedBox(height: 2),
                              Text(
                                AppFormatters.currencyDecimal(widget.investedAmount),
                                style: AppTypography.bodySmall(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(gradient: AppColors.goldCardGradient, shape: BoxShape.circle),
                          child: const Icon(Icons.diamond_rounded, color: AppColors.textOnGold, size: 30),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You will receive', style: AppTypography.sectionTitleSM(color: textColor)),
                        SizedBox(height: AppSpacing.md),
                        _InfoRow(
                          label: 'Invested Amount',
                          value: AppFormatters.currencyDecimal(widget.investedAmount),
                          textColor: textColor,
                          mutedColor: mutedColor,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        _InfoRow(
                          label: 'Gold Quantity',
                          value: '${widget.availableGoldGrams.toStringAsFixed(3)}g',
                          textColor: textColor,
                          mutedColor: mutedColor,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        _InfoRow(
                          label: 'gold rate',
                          value: '${AppFormatters.currencyDecimal(widget.goldRatePerGram)}/gm',
                          textColor: textColor,
                          mutedColor: mutedColor,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        _InfoRow(
                          label: 'Current value',
                          value: AppFormatters.currencyDecimal(_currentValue),
                          textColor: textColor,
                          mutedColor: mutedColor,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Container(height: 1, color: border),
                        SizedBox(height: AppSpacing.md),
                        _InfoRow(
                          label: 'Redeem gold',
                          value: AppFormatters.goldWeight(widget.availableGoldGrams),
                          textColor: AppColors.maroonPrimary,
                          mutedColor: textColor,
                          emphasize: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: AppButton(
          text: 'Redeem Gold',
          isLoading: _submitting,
          onPressed: _submitting ? null : _confirmRedeem,
          backgroundColor: AppColors.maroonDark,
          textColor: Colors.white,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color mutedColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final labelStyle = emphasize
        ? AppTypography.labelLarge(color: mutedColor).copyWith(fontWeight: FontWeight.w700)
        : AppTypography.bodySmall(color: mutedColor);
    final valueStyle = emphasize
        ? AppTypography.sectionTitleSM(color: textColor).copyWith(fontWeight: FontWeight.w700)
        : AppTypography.labelMedium(color: textColor);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}