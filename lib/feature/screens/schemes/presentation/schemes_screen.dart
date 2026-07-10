import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gold_scheme/core/router/route_name.dart';
import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_spacing.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';

import '../../../../core/formatter/app_formatters.dart';
import '../../../global_widgets/common_button.dart';
import '../../../global_widgets/dashboard_bottom_nav.dart';
import '../schemes_viewmodel/scheme_model.dart';


/// Scheme browser — Phase 1, mock data only.
class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  int navIndex = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: DashboardBottomNav(currentIndex: navIndex,  onTap: (i) => setState(() => navIndex = i),),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    onTap: () => context.go(RouteName.dashboard),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back_rounded, color: textColor, size: AppSpacing.iconLg),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text('Schemes', style: AppTypography.headingSM(color: textColor)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding:  EdgeInsets.all(AppSpacing.lg),
                itemCount: mockSchemes.length,
                separatorBuilder: (_, __) =>  SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) =>  _SchemeCard(scheme: mockSchemes[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  const _SchemeCard({required this.scheme});

  final SchemeModel scheme;

  void _openDetail(BuildContext context) => context.push(RouteName.schemeDetailPath(scheme.id));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      onTap: () => _openDetail(context),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldCardGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.diamond_rounded, color: AppColors.textOnGold),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scheme.name, style: AppTypography.sectionTitleSM(color: textColor)),
                      SizedBox(height: 2),
                      Text(scheme.tagline, style: AppTypography.caption(color: mutedColor)),
                    ],
                  ),
                ),
                if (scheme.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.paidBgDark : AppColors.successGreenLight,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      scheme.badge!,
                      style: AppTypography.labelSmall(
                        color: isDark ? AppColors.paidTextDark : AppColors.successGreen,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatCell(
                    label: 'Monthly Investment',
                    value: AppFormatters.currency(scheme.monthlyInvestment),
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ),
                Expanded(
                  child: _StatCell(
                    label: 'Duration',
                    value: AppFormatters.months(scheme.durationMonths),
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatCell(
                    label: 'Maturity Bonus',
                    value: 'Up to ${scheme.maturityBonusPercent.toStringAsFixed(0)}%',
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ),
                Expanded(
                  child: _StatCell(
                    label: 'Min. Gold',
                    value: '${scheme.minGoldGrams.toStringAsFixed(0)} Gram',
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      scheme.bestFor,
                      style: AppTypography.labelSmall(color: mutedColor),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                AppButton(
                  text: 'Join Now',
                  onPressed: () => _openDetail(context),
                  width: 110,
                  height: 40,
                  backgroundColor: AppColors.primaryGold,
                  textColor: AppColors.textOnGold,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, required this.textColor, required this.mutedColor});

  final String label;
  final String value;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption(color: mutedColor)),
        SizedBox(height: 2),
        Text(value, style: AppTypography.labelLarge(color: textColor)),
      ],
    );
  }
}