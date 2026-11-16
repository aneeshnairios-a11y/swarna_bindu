import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../global_widgets/common_text_field.dart';

/// Kerala-first per project scope — extend/replace with a full India
/// state/district dataset in Phase 2.
const List<String> kKeralaDistricts = [
  'Thiruvananthapuram',
  'Kollam',
  'Pathanamthitta',
  'Alappuzha',
  'Kottayam',
  'Idukki',
  'Ernakulam',
  'Thrissur',
  'Palakkad',
  'Malappuram',
  'Kozhikode',
  'Wayanad',
  'Kannur',
  'Kasaragod',
];

const List<String> kIndianStates = [
  'Kerala',
  'Tamil Nadu',
  'Karnataka',
  'Other',
];

class KycStepAddress extends StatelessWidget {
  const KycStepAddress({
    super.key,
    required this.formKey,
    required this.houseController,
    required this.streetController,
    required this.landmarkController,
    required this.cityController,
    required this.pinController,
    required this.district,
    required this.state,
    required this.onDistrictChanged,
    required this.onStateChanged,
    this.onDetectLocation,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController houseController;
  final TextEditingController streetController;
  final TextEditingController landmarkController;
  final TextEditingController cityController;
  final TextEditingController pinController;
  final String? district;
  final String state;
  final ValueChanged<String?> onDistrictChanged;
  final ValueChanged<String?> onStateChanged;
  final VoidCallback? onDetectLocation;

  @override
  Widget build(BuildContext context) {
    final k = AppStrings.kyc;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textMutedLight;

    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final goldSurfaceColor = isDark
        ? AppColors.goldSurfaceDark
        : AppColors.goldSurfaceLight;

    final accentColor = isDark
        ? AppColors.primaryGold
        : AppColors.primaryGoldDark;

    final iconColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.mutedGray;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k.addressTitle,
            style: AppTypography.sectionTitle(
              color: primaryTextColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            k.addressSubtitle,
            style: AppTypography.bodySmall(color: secondaryTextColor),
          ),
          SizedBox(height: AppSpacing.xl),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                AppTextField(
                  label: k.houseLabel,
                  isRequired: true,
                  hintText: k.houseHint,
                  controller: houseController,
                  prefixIcon: Icons.home_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'This field is required'
                      : null,
                ),
                SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: k.streetLabel,
                  isRequired: true,
                  hintText: k.streetHint,
                  controller: streetController,
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'This field is required'
                      : null,
                ),
                SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: k.landmarkLabel,
                  hintText: k.landmarkHint,
                  controller: landmarkController,
                  prefixIcon: Icons.flag_outlined,
                ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: k.cityLabel,
                        isRequired: true,
                        hintText: k.cityHint,
                        controller: cityController,
                        prefixIcon: Icons.location_city_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppDropdownField<String>(
                        label: k.districtLabel,
                        isRequired: true,
                        hintText: 'Select',
                        value: district,
                        items: kKeralaDistricts,
                        itemLabel: (d) => d,
                        onChanged: onDistrictChanged,
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppDropdownField<String>(
                        label: k.stateLabel,
                        isRequired: true,
                        value: state,
                        items: kIndianStates,
                        itemLabel: (s) => s,
                        onChanged: onStateChanged,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        label: k.pinCodeLabel,
                        isRequired: true,
                        hintText: k.pinCodeHint,
                        controller: pinController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.pin_drop_outlined,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Required';
                          if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                            return 'Enter a valid 6-digit PIN';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: onDetectLocation,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.my_location,
                    color: accentColor,
                    size: AppSpacing.iconLg,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          k.detectLocationTitle,
                          style: AppTypography.sectionTitleSM(
                            color: primaryTextColor,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          k.detectLocationSubtitle,
                          style: AppTypography.caption(
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: iconColor),
                ],
              ),
            ),
          ),

          SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: goldSurfaceColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: AppSpacing.iconMd,
                  color: accentColor,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    k.addressSecureNote,
                    style: AppTypography.caption(
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
