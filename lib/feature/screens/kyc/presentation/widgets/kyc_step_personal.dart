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
    final picked = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.maroonPrimary, // Header background & selected date
              onPrimary: Colors.white, // Header text
              surface: Colors.white, // Dialog background
              onSurface: Colors.black87, // Calendar text
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppColors.maroonPrimary,
              headerForegroundColor: Colors.white,
              todayForegroundColor: WidgetStatePropertyAll(
                AppColors.maroonPrimary,
              ),
              todayBorder: BorderSide(color: AppColors.maroonPrimary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onDobChanged(picked);
  }

  String get _dobText => dob == null ? '' : '${dob!.day.toString().padLeft(2, '0')} ${_months[dob!.month - 1]} ${dob!.year}';

  @override
  Widget build(BuildContext context) {
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
                          border: Border.all(
                            color: AppColors.maroonPrimary,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: profileImagePath == null
                              ? Icon(
                                  Icons.person,
                                  size: AppSpacing.iconXl,
                                  color: AppColors.maroonPrimary,
                                )
                              : Image.file(
                                  File(profileImagePath!),
                                  width: AppSpacing.avatarXl,
                                  height: AppSpacing.avatarXl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.person,
                                    size: AppSpacing.iconXl,
                                    color: AppColors.maroonPrimary,
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
                            color: AppColors.maroonPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
                      color: AppColors.maroonPrimary,
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
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.kyc.personalDetailsTitle,
                  style: AppTypography.sectionTitleSM(
                    color: AppColors.textPrimaryLight,
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
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDob(context),
                        child: AbsorbPointer(
                          child: AppTextField(
                            label: AppStrings.kyc.dobLabel,
                            isRequired: true,
                            hintText: AppStrings.kyc.dobHint,
                            controller: TextEditingController(text: _dobText),
                            suffixIcon: Icon(
                              Icons.calendar_today_outlined,
                              size: AppSpacing.iconSm,
                              color: AppColors.mutedGray,
                            ),
                            validator: (_) => dob == null ? 'Required' : null,
                          ),
                        ),
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
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.goldSurfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.goldSurfaceLight, width: 1),
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
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTypography.caption(color: AppColors.textMutedLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
