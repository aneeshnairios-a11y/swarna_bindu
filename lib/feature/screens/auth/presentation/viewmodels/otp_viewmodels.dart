import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarna_bindu/core/storage/secure_storage_service.dart';

import '../../../../../core/constants/app_string/app_strings.dart';
import '../../data/models/auth_models.dart';
import '../../data/repository/auth_repository.dart';

enum OtpStatus { idle, verifying, success, error, resending, resent }

class OtpState {
  const OtpState({this.status = OtpStatus.idle, this.errorMessage});

  final OtpStatus status;
  final String? errorMessage;

  bool get isVerifying => status == OtpStatus.verifying;
  bool get isResending => status == OtpStatus.resending;

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

  Future<void> verify(
    String otp, {
    required String mobileNumber,
    required int expectedLength,
    String? deviceToken,
  }) async {
    if (state.isVerifying) return; // guard against double-submit

    if (otp.length != expectedLength) {
      state = state.copyWith(status: OtpStatus.error, errorMessage: AppStrings.otp.invalidOtp);
      return;
    }

    state = state.copyWith(status: OtpStatus.verifying, errorMessage: null);

    final result = await ref
        .read(authRepositoryProvider)
        .verifyOtp(
          mobileNumber: mobileNumber,
          otp: otp,
          deviceToken: deviceToken,
        );

    await result.when(
      success: (data) async {
        final secureStorage = ref.read(secureStorageProvider);
        await secureStorage.saveTokens(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
        );
        await secureStorage.saveUserId(data.user.id);
        await secureStorage.saveUserRole('customer');
        await secureStorage.saveKycStatus(data.user.kycStatus.apiValue);
        state = state.copyWith(status: OtpStatus.success);
      },
      failure: (exception) async {
        state = state.copyWith(status: OtpStatus.error, errorMessage: exception.message);
      },
    );
  }

  Future<void> resendOtp(String mobileNumber) async {
    if (state.isResending) return;

    state = state.copyWith(status: OtpStatus.resending, errorMessage: null);
    final result = await ref.read(authRepositoryProvider).sendOtp(mobileNumber);

    result.when(
      success: (_) => state = state.copyWith(status: OtpStatus.resent),
      failure: (exception) => state = state.copyWith(status: OtpStatus.error, errorMessage: exception.message),
    );
  }
}

final otpProvider = NotifierProvider.autoDispose<OtpNotifier, OtpState>(
  OtpNotifier.new,
);
