/// Auth-related response models. All parsing is null-safe by design:
/// a malformed/missing required field throws a [FormatException] which
/// ApiClient already catches and surfaces as an UnknownApiException —
/// so a bad payload becomes a normal error state, never a crash.

enum KycStatus { notSubmitted, pending, approved, rejected, unknown }

extension KycStatusX on KycStatus {
  static KycStatus fromApi(String? raw) {
    switch (raw) {
      case 'APPROVED':
        return KycStatus.approved;
      case 'PENDING':
        return KycStatus.pending;
      case 'REJECTED':
        return KycStatus.rejected;
      case 'NOT_SUBMITTED':
      case null:
        return KycStatus.notSubmitted;
      default:
        return KycStatus.unknown;
    }
  }

  String get apiValue => switch (this) {
    KycStatus.approved => 'APPROVED',
    KycStatus.pending => 'PENDING',
    KycStatus.rejected => 'REJECTED',
    KycStatus.notSubmitted => 'NOT_SUBMITTED',
    KycStatus.unknown => 'UNKNOWN',
  };
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.mobileNumber,
    required this.kycStatus,
  });

  final String id;
  final String mobileNumber;
  final KycStatus kycStatus;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final mobile = json['mobileNumber'] as String?;
    if (id == null || id.isEmpty) {
      throw const FormatException('AuthUser: missing "id" in response');
    }
    if (mobile == null || mobile.isEmpty) {
      throw const FormatException('AuthUser: missing "mobileNumber" in response');
    }
    return AuthUser(
      id: id,
      mobileNumber: mobile,
      kycStatus: KycStatusX.fromApi(json['kycStatus'] as String?),
    );
  }
}

class SendOtpResponse {
  const SendOtpResponse({required this.otpSent, required this.expiresInSeconds});

  final bool otpSent;
  final int expiresInSeconds;

  factory SendOtpResponse.fromJson(Map<String, dynamic>? json) {
    return SendOtpResponse(
      otpSent: (json?['otpSent'] as bool?) ?? false,
      expiresInSeconds: (json?['expiresInSeconds'] as num?)?.toInt() ?? 300,
    );
  }
}

class VerifyOtpResponse {
  const VerifyOtpResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final AuthUser user;
  final String accessToken;
  final String refreshToken;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    final access = json['accessToken'] as String?;
    final refresh = json['refreshToken'] as String?;
    if (userJson == null) {
      throw const FormatException('VerifyOtpResponse: missing "user" in response');
    }
    if (access == null || access.isEmpty) {
      throw const FormatException('VerifyOtpResponse: missing "accessToken"');
    }
    if (refresh == null || refresh.isEmpty) {
      throw const FormatException('VerifyOtpResponse: missing "refreshToken"');
    }
    return VerifyOtpResponse(
      user: AuthUser.fromJson(userJson),
      accessToken: access,
      refreshToken: refresh,
    );
  }
}

class RefreshTokenResponse {
  const RefreshTokenResponse({required this.accessToken});

  final String accessToken;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    final access = json['accessToken'] as String?;
    if (access == null || access.isEmpty) {
      throw const FormatException('RefreshTokenResponse: missing "accessToken"');
    }
    return RefreshTokenResponse(accessToken: access);
  }
}
