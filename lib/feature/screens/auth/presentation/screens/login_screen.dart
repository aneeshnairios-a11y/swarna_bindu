import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../../core/constants/image_string/image_strings.dart';
import '../../../../global_widgets/common_button.dart';
import '../viewmodels/login_viewmodels.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    ref.read(loginProvider.notifier).sendOtp(_phoneController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.status == LoginStatus.sent && previous?.status != LoginStatus.sent) {
        context.push(RouteName.otp, extra: _phoneController.text.trim());
      } else if (next.status == LoginStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(next.errorMessage!), backgroundColor: AppColors.errorRed),
          );
        ref.read(loginProvider.notifier).clearError();
      }
    });

    final isSending = ref.watch(loginProvider.select((s) => s.isSending));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 100.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppSpacing.xl),
                    Text(
                      AppStrings.login.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.headingLG(color: AppColors.textPrimaryLight),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.login.welcomeSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall(color: AppColors.textMutedLight),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xxxl),
              Image.asset(AppAssetImage.welcomeScreen),
              SizedBox(height: AppSpacing.xxxl),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    border: Border.all(width: 1.w, color: AppColors.borderLight),
                    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PhoneField(formKey: _formKey, controller: _phoneController),
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: AppSpacing.iconSm,
                              color: AppColors.textMutedLight,
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                AppStrings.login.otpHint,
                                style: AppTypography.caption(color: AppColors.textMutedLight),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        AppButton(
                          text: AppStrings.login.sendOtp,
                          isLoading: isSending,
                          onPressed: isSending ? null : _sendOtp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.formKey, required this.controller});

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.login.mobileLabel,
            style: AppTypography.labelMedium(color: AppColors.textSecondaryLight),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  '+91',
                  style: AppTypography.bodyMedium(color: AppColors.textPrimaryLight),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: AppTypography.bodyMedium(color: AppColors.textPrimaryLight),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: AppStrings.login.mobileHint,
                    hintStyle: AppTypography.bodyMedium(color: AppColors.textMutedLight),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(color: AppColors.maroonPrimary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(color: AppColors.errorRed),
                    ),
                  ),
                  validator: (value) {
                    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                    if (digits.length != 10) {
                      return AppStrings.login.invalidMobile;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
