import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/constants/image_string/image_strings.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../../core/router/route_name.dart';
import '../../../../global_widgets/common_button.dart';
import '../../data/repository/auth_repository.dart' show normalizeMobileNumber;
import '../viewmodels/otp_viewmodels.dart';

const int _kOtpLength = 6;
const int _kResendSeconds = 30;

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  Timer? _timer;
  int _secondsLeft = _kResendSeconds;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _kResendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _verify() {
    ref
        .read(otpProvider.notifier)
        .verify(
          _pinController.text,
          mobileNumber: widget.phoneNumber,
          expectedLength: _kOtpLength,
          // TODO(fcm): pass the real FCM device token once push registration
          // is wired up; omitted for now, backend treats it as optional.
        );
  }

  void _resendOtp() {
    final state = ref.read(otpProvider);
    if (_secondsLeft > 0 || state.isResending) return;
    ref.read(otpProvider.notifier).resendOtp(widget.phoneNumber);
  }

  String _maskedNumber() {
    final e164 = normalizeMobileNumber(widget.phoneNumber);
    final digits = e164.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return e164;
    return '+91 ${digits.substring(digits.length - 10, digits.length - 4)} ${digits.substring(digits.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OtpState>(otpProvider, (previous, next) {
      if (next.status == OtpStatus.success) {
        context.go(RouteName.kycSubmit);
      } else if (next.status == OtpStatus.resent && previous?.status != OtpStatus.resent) {
        _startResendTimer();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('OTP resent successfully')));
      }
    });

    final otpState = ref.watch(otpProvider);
    final isVerifying = otpState.isVerifying;
    final isResending = otpState.isResending;
    final error = otpState.errorMessage;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 100.h),
              Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage(AppAssetImage.otpBg), fit: BoxFit.cover),
                ),
                child: Column(
                  children: [
                    Text(
                      AppStrings.otp.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.headingLG(color: AppColors.textPrimaryLight),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      '${AppStrings.otp.subtitle.split('\n').first} ${_maskedNumber()}',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall(color: AppColors.textMutedLight),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xxxl),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  children: [
                    Text(
                      AppStrings.otp.fieldLabel,
                      style: AppTypography.labelMedium(color: AppColors.textSecondaryLight),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Pinput(
                      length: _kOtpLength,
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => ref.read(otpProvider.notifier).clearError(),
                      onCompleted: (_) => _verify(),
                      defaultPinTheme: PinTheme(
                        width: 44,
                        height: 52,
                        textStyle: AppTypography.headingSM(color: AppColors.textPrimaryLight),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: error != null ? AppColors.errorRed : AppColors.borderLight,
                          ),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 44,
                        height: 52,
                        textStyle: AppTypography.headingSM(color: AppColors.textPrimaryLight),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: AppColors.maroonPrimary, width: 1.5),
                        ),
                      ),
                      errorPinTheme: PinTheme(
                        width: 44,
                        height: 52,
                        textStyle: AppTypography.headingSM(color: AppColors.textPrimaryLight),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: AppColors.errorRed),
                        ),
                      ),
                    ),
                    if (error != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      Text(error, style: AppTypography.caption(color: AppColors.errorRed)),
                    ],
                    SizedBox(height: AppSpacing.md),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTypography.bodySmall(color: AppColors.textMutedLight),
                          children: [
                            TextSpan(text: AppStrings.otp.resendPrefix),
                            if (isResending)
                              TextSpan(
                                text: 'Sending…',
                                style: AppTypography.labelMedium(color: AppColors.textMutedLight),
                              )
                            else if (_secondsLeft > 0)
                              TextSpan(
                                text: '${AppStrings.otp.resendCountingLabel}${_formatSeconds(_secondsLeft)}',
                                style: AppTypography.labelMedium(color: AppColors.textPrimaryLight),
                              )
                            else
                              TextSpan(
                                text: AppStrings.otp.resendCta,
                                style: AppTypography.labelMedium(color: AppColors.maroonPrimary),
                                recognizer: TapGestureRecognizer()..onTap = _resendOtp,
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    AppButton(
                      text: AppStrings.otp.verifyAndLogin,
                      isLoading: isVerifying,
                      onPressed: isVerifying ? null : _verify,
                    ),
                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSeconds(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
