import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_string/app_strings.dart';

enum OtpStatus { idle, verifying, success, error }

class OtpState {
  const OtpState({this.status = OtpStatus.idle, this.errorMessage});

  final OtpStatus status;
  final String? errorMessage;

  bool get isVerifying => status == OtpStatus.verifying;

  OtpState copyWith({OtpStatus? status, String? errorMessage}) {
    return OtpState(status: status ?? this.status, errorMessage: errorMessage);
  }
}

class OtpNotifier extends Notifier<OtpState> {
  @override
  OtpState build() => const OtpState();

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(status: OtpStatus.idle, errorMessage: null);
    }
  }

  Future<void> verify(String otp, {required int expectedLength}) async {
    if (otp.length != expectedLength) {
      state = state.copyWith(status: OtpStatus.error, errorMessage: AppStrings.otp.invalidOtp);
      return;
    }

    state = state.copyWith(status: OtpStatus.verifying, errorMessage: null);

    // TODO(T2): replace with real "verify OTP" API call.
    await Future.delayed(const Duration(milliseconds: 400));

    // On success:
    state = state.copyWith(status: OtpStatus.success);

    // On failure instead, you'd do:
    // state = state.copyWith(status: OtpStatus.error, errorMessage: 'Invalid OTP');
  }
}

final otpProvider = NotifierProvider.autoDispose<OtpNotifier, OtpState>(OtpNotifier.new);
