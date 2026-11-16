import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../global_widgets/common_text_field.dart';

class KycStepPersonal extends StatelessWidget {
  const KycStepPersonal({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.mobileController,
    required this.dob,
    required this.gender,
    required this.onDobChanged,
    required this.onGenderChanged,
    this.profileImagePath,
    this.onPickProfileImage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  final DateTime? dob;
  final String? gender;
  final ValueChanged<DateTime> onDobChanged;
  final ValueChanged<String?> onGenderChanged;
  final String? profileImagePath;
  final VoidCallback? onPickProfileImage;

  static const _genders = ['Male', 'Female', 'Other'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  Future<void> _pickDob(BuildContext context) async {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? AppColors.primaryGold
        : AppColors.maroonPrimary;

    final picked = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      builder: (context, child) {
        final theme = Theme.of(context);

        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: accentColor,
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: accentColor,
              headerForegroundColor: isDark
                  ? AppColors.textOnGold
                  : Colors.white,
              todayForegroundColor: WidgetStatePropertyAll(accentColor),
              todayBorder: BorderSide(color: accentColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDobChanged(picked);
    }
  }

  String get _dobText => dob == null
      ? ''
      : '${dob!.day.toString().padLeft(2, '0')} ${_months[dob!.month - 1]} ${dob!.year}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    final accentColor = isDark
        ? AppColors.primaryGold
        : AppColors.maroonPrimary;

    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KycBanner(
            icon: Icons.badge_outlined,
            title: AppStrings.kyc.bannerTitle,
            subtitle: AppStrings.kyc.bannerSubtitle,
          ),
          SizedBox(height: AppSpacing.xxl),
          Center(
            child: GestureDetector(
              onTap: onPickProfileImage,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: AppSpacing.avatarXl,
                        height: AppSpacing.avatarXl,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceVariantLight,
                          border: Border.all(
                            color: accentColor,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              profileImagePath == null ||
                                  profileImagePath!.trim().isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: AppSpacing.iconXl,
                                  color: accentColor,
                                )
                              : Image.file(
                                  File(profileImagePath!.trim()),
                                  width: AppSpacing.avatarXl,
                                  height: AppSpacing.avatarXl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.person,
                                        size: AppSpacing.iconXl,
                                        color: accentColor,
                                      ),
                                ),
                        ),
                      ), // CircleAvatar(
                      //   radius: AppSpacing.avatarXl / 2,
                      //   backgroundColor: AppColors.surfaceVariantLight,
                      //   backgroundImage: profileImagePath != null ? AssetImage(profileImagePath!) : null,
                      //   child: profileImagePath == null ? Icon(Icons.person, size: AppSpacing.iconXl, color: AppColors.maroonPrimary) : null,
                      // ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: surfaceColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    AppStrings.kyc.addProfilePicture,
                    style: AppTypography.labelMedium(
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xxl),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.kyc.personalDetailsTitle,
                  style: AppTypography.sectionTitleSM(
                    color: primaryTextColor,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: AppStrings.kyc.fullNameLabel,
                  isRequired: true,
                  hintText: AppStrings.kyc.fullNameHint,
                  controller: nameController,
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Full name is required'
                      : null,
                ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        key: ValueKey(_dobText),
                        label: AppStrings.kyc.dobLabel,
                        isRequired: true,
                        hintText: AppStrings.kyc.dobHint,
                        initialValue: _dobText,
                        readOnly: true,
                        onTap: () => _pickDob(context),
                        suffixIcon: Icon(
                          Icons.calendar_today_outlined,
                          size: AppSpacing.iconSm,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.mutedGray,
                        ),
                        validator: (_) => dob == null ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppDropdownField<String>(
                        label: AppStrings.kyc.genderLabel,
                        isRequired: true,
                        value: gender,
                        hintText: AppStrings.kyc.genderHint,
                        items: _genders,
                        itemLabel: (g) => g,
                        onChanged: onGenderChanged,
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: AppStrings.kyc.emailLabel,
                  isRequired: true,
                  hintText: AppStrings.kyc.emailHint,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Email is required';
                    final ok = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value);
                    return ok ? null : 'Enter a valid email address';
                  },
                ),
                SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: AppStrings.kyc.mobileLabel,
                  hintText: AppStrings.kyc.mobileHint,
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KycBanner extends StatelessWidget {
  const _KycBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.goldSurfaceDark
        : AppColors.goldSurfaceLight;

    final titleColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textMutedLight;
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: backgroundColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.primaryGold,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.textOnGold,
              size: AppSpacing.iconMd,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.sectionTitleSM(
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTypography.caption(color: subtitleColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
