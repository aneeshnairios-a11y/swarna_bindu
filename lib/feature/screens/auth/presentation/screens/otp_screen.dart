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
import '../../../kyc/presentation/widgets/kyc_status_screen.dart';
import '../../data/models/auth_models.dart' show KycStatus;
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
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _verify() {
    if (_pinController.text.length != _kOtpLength) return;
    if (ref.read(otpProvider).isVerifying) return;
    FocusScope.of(context).unfocus();

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
    if (digits.length < 10) return e164;
    final mobile = digits.substring(digits.length - 10);

    return '+91 ${mobile.substring(0, 6)} ${mobile.substring(6)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final surfaceColor = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceLight;

    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textMutedLight;

    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final accentColor = isDark
        ? AppColors.primaryGold
        : AppColors.maroonPrimary;

    ref.listen<OtpState>(otpProvider, (previous, next) {
      if (next.status == OtpStatus.success) {
        switch (next.kycStatus) {
          case KycStatus.approved:
            context.go(RouteName.dashboard);
          case KycStatus.submitted:
            context.go(RouteName.kycStatus, extra: KycOutcome.pending);
          default:
            context.push(RouteName.kycSubmit).then((_) {
              if (!mounted) return;

              _pinController.clear();
              _pinFocusNode.unfocus();

              ref.read(otpProvider.notifier).resetOtpState();
            });
        }
      } else if (next.status == OtpStatus.resent &&
          previous?.status != OtpStatus.resent) {
        _startResendTimer();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'OTP resent successfully',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryLight
                      : AppColors.textPrimaryDark,
                ),
              ),
            ),
          );
      }
    });

    final otpState = ref.watch(otpProvider);
    final isVerifying = otpState.isVerifying;
    final isResending = otpState.isResending;
    final error = otpState.errorMessage;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
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
                  image: DecorationImage(
                    image: AssetImage(
                      AppAssetImage.otpBg,
                    ),
                    fit: BoxFit.cover,
                    opacity: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      AppStrings.otp.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.headingLG(
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      '${AppStrings.otp.subtitle.split('\n').first} ${_maskedNumber()}',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall(
                        color: primaryTextColor,
                      ),
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
                      style: AppTypography.labelMedium(
                        color: secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Pinput(
                      length: _kOtpLength,
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) =>
                          ref.read(otpProvider.notifier).clearError(),
                      onCompleted: (_) => _verify(),
                      defaultPinTheme: buildPinTheme(
                        background: surfaceColor,
                        textColor: primaryTextColor,
                        borderColor: borderColor,
                      ),
                      focusedPinTheme:
                          buildPinTheme(
                            background: surfaceColor,
                            textColor: primaryTextColor,
                            borderColor: accentColor,
                          ).copyWith(
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              border: Border.all(
                                color: accentColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                      errorPinTheme: buildPinTheme(
                        background: surfaceColor,
                        textColor: primaryTextColor,
                        borderColor: AppColors.errorRed,
                      ),
                    ),
                    if (error != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        error,
                        style: AppTypography.caption(color: AppColors.errorRed),
                      ),
                    ],
                    SizedBox(height: AppSpacing.md),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTypography.bodySmall(
                            color: secondaryTextColor,
                          ),
                          children: [
                            TextSpan(text: AppStrings.otp.resendPrefix),
                            if (isResending)
                              TextSpan(
                                text: 'Sending…',
                                style: AppTypography.labelMedium(
                                  color: secondaryTextColor,
                                ),
                              )
                            else if (_secondsLeft > 0)
                              TextSpan(
                                text:
                                    '${AppStrings.otp.resendCountingLabel}${_formatSeconds(_secondsLeft)}',
                                style: AppTypography.labelMedium(
                                  color: primaryTextColor,
                                ),
                              )
                            else
                              TextSpan(
                                text: AppStrings.otp.resendCta,
                                style: AppTypography.labelMedium(
                                  color: accentColor,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _resendOtp,
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

PinTheme buildPinTheme({
  required Color background,
  required Color textColor,
  required Color borderColor,
}) {
  return PinTheme(
    width: 44,
    height: 52,
    textStyle: AppTypography.headingSM(color: textColor),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: borderColor),
    ),
  );
}
