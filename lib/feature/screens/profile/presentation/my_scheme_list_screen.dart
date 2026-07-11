import 'package:flutter/material.dart';

import 'package:swarna_bindu/core/formatter/app_formatters.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../core/constants/image_string/image_strings.dart';

enum _EnrollmentStatus { active, redeemed }

class _EnrollmentSummary {
  const _EnrollmentSummary({
    required this.id,
    required this.name,
    required this.tagline,
    required this.status,
    required this.monthlyInvestment,
    required this.eventDate,
    required this.goldGrams,
  });

  final String id;
  final String name;
  final String tagline;
  final _EnrollmentStatus status;
  final double monthlyInvestment;

  /// Redemption date for redeemed schemes, join/maturity-adjacent date for
  /// active ones — matches the "Redeemed date" column in the design either
  /// way for Phase 1 mock data.
  final DateTime eventDate;
  final double goldGrams;
}

final _mockEnrollments = <_EnrollmentSummary>[
  _EnrollmentSummary(
    id: 'enr-1',
    name: 'Swarna Bindu',
    tagline: 'Best for long term wealth creation',
    status: _EnrollmentStatus.redeemed,
    monthlyInvestment: 5000,
    eventDate: DateTime(2025, 2, 5),
    goldGrams: 6.670,
  ),
  _EnrollmentSummary(
    id: 'enr-2',
    name: 'Swarna Bindu',
    tagline: 'Best for long term wealth creation',
    status: _EnrollmentStatus.active,
    monthlyInvestment: 5000,
    eventDate: DateTime(2025, 2, 5),
    goldGrams: 6.670,
  ),
];

/// Shown when the customer taps "My Scheme" from the Profile screen.
/// Lists every enrollment (active + redeemed). Active enrollments carry a
/// radio-style selector — this is provisional UI for a future "pay towards
/// this scheme" flow; wire the selection up once that's defined.
/// Phase 1 — mock data only; replace with `GET /users/:id/enrollments`.
class MySchemeListScreen extends StatefulWidget {
  const MySchemeListScreen({super.key});

  @override
  State<MySchemeListScreen> createState() => _MySchemeListScreenState();
}

class _MySchemeListScreenState extends State<MySchemeListScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    // Default-select the first active enrollment, matching the design.
    _selectedId = _mockEnrollments
        .firstWhere(
          (e) => e.status == _EnrollmentStatus.active,
      orElse: () => _mockEnrollments.first,
    )
        .id;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

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
                  Text('Schemes', style: AppTypography.headingSM(color: textColor)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(AppSpacing.lg),
                itemCount: _mockEnrollments.length,
                separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) {
                  final e = _mockEnrollments[i];
                  return _EnrollmentCard(
                    enrollment: e,
                    selected: e.id == _selectedId,
                    onTap: e.status == _EnrollmentStatus.active
                        ? () => setState(() => _selectedId = e.id)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({required this.enrollment, required this.selected, this.onTap});

  final _EnrollmentSummary enrollment;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final isActive = enrollment.status == _EnrollmentStatus.active;

    final badgeBg = isActive
        ? (isDark ? AppColors.paidBgDark : AppColors.successGreenLight)
        : (isDark ? AppColors.processingBgDark : AppColors.infoBlueLight);
    final badgeText = isActive
        ? (isDark ? AppColors.paidTextDark : AppColors.successGreen)
        : (isDark ? AppColors.processingTextDark : AppColors.infoBlue);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: selected ? AppColors.primaryGold : border, width: selected ? 1.5 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isActive) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: selected ? AppColors.primaryGoldDark : mutedColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          child: Image.asset(
                            AppAssetImage.jewellery,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(enrollment.name, style: AppTypography.sectionTitleSM(color: textColor)),
                              SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                ),
                                child: Text(
                                  isActive ? 'Active' : 'Redeemed',
                                  style: AppTypography.labelSmall(color: badgeText),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(enrollment.tagline, style: AppTypography.caption(color: mutedColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Container(height: 1, color: border),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCell(
                            label: 'Monthly Investment',
                            value: AppFormatters.currencyDecimal(enrollment.monthlyInvestment),
                            textColor: textColor,
                            mutedColor: mutedColor,
                          ),
                        ),
                        _StatDivider(color: border),
                        Expanded(
                          child: _StatCell(
                            label: isActive ? 'Next due date' : 'Redeemed date',
                            value: AppFormatters.date(enrollment.eventDate),
                            textColor: textColor,
                            mutedColor: mutedColor,
                          ),
                        ),
                        _StatDivider(color: border),
                        Expanded(
                          child: _StatCell(
                            label: isActive ? 'Gold saved' : 'Redeemed Gold',
                            value: AppFormatters.goldWeight(enrollment.goldGrams),
                            textColor: textColor,
                            mutedColor: mutedColor,
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
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: color, margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm));
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
        Text(value, style: AppTypography.labelMedium(color: textColor)),
      ],
    );
  }
}