import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarna_bindu/core/network/api_client.dart';
import 'package:swarna_bindu/core/network/api_endpoints.dart';
import 'package:swarna_bindu/core/network/api_result.dart';

import '../models/auth_models.dart';

/// Normalizes a 10-digit Indian number (or one already carrying a +91/91
/// prefix) into the E.164 format the backend expects: "+917041653088".
String normalizeMobileNumber(String raw) {
  final trimmed = raw.trim();
  if (trimmed.startsWith('+')) return trimmed;
  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('91')) return '+$digits';
  return '+91$digits';
}

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<SendOtpResponse>> sendOtp(String mobileNumber) {
    return _apiClient.post(
      ApiEndpoints.sendOtp,
      data: {'mobileNumber': normalizeMobileNumber(mobileNumber)},
      parser: (json) => SendOtpResponse.fromJson(json as Map<String, dynamic>?),
    );
  }

  Future<ApiResult<VerifyOtpResponse>> verifyOtp({
    required String mobileNumber,
    required String otp,
    String? deviceToken,
  }) {
    return _apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {
        'mobileNumber': normalizeMobileNumber(mobileNumber),
        'otp': otp,
        // TODO(fcm): populate once FCM device-token registration lands.
        if (deviceToken != null && deviceToken.isNotEmpty) 'deviceToken': deviceToken,
      },
      parser: (json) => VerifyOtpResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<RefreshTokenResponse>> refreshAccessToken(String refreshToken) {
    return _apiClient.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
      parser: (json) => RefreshTokenResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Ready for when Settings/Profile gets a logout button — not wired to
  /// any screen yet since neither exists in Phase 2 so far.
  Future<ApiResult<void>> logout(String refreshToken) {
    return _apiClient.post(
      ApiEndpoints.logout,
      data: {'refreshToken': refreshToken},
      parser: (_) {},
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});
