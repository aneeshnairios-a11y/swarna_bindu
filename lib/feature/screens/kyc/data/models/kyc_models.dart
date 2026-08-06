import 'package:swarna_bindu/feature/screens/auth/data/models/auth_models.dart' show KycStatus, KycStatusX;

/// Every KYC step response echoes the account's overall kycStatus, which
/// we resync into secure storage after each successful step — see
/// KycNotifier. Parsing stays defensive: a missing/malformed field never
/// crashes, it just falls back sensibly (see KycStatusX.fromApi).

class PersonalInfoStepResult {
  const PersonalInfoStepResult({required this.kycStatus, this.profilePictureUrl});

  final KycStatus kycStatus;
  final String? profilePictureUrl;

  factory PersonalInfoStepResult.fromJson(Map<String, dynamic> json) {
    final info = json['personalInfo'] as Map<String, dynamic>?;
    return PersonalInfoStepResult(
      kycStatus: KycStatusX.fromApi(json['kycStatus'] as String?),
      profilePictureUrl: info?['profilePicture'] as String?,
    );
  }
}

class IdentityStepResult {
  const IdentityStepResult({required this.kycStatus});

  final KycStatus kycStatus;

  factory IdentityStepResult.fromJson(Map<String, dynamic> json) {
    return IdentityStepResult(kycStatus: KycStatusX.fromApi(json['kycStatus'] as String?));
  }
}

class AddressStepResult {
  const AddressStepResult({required this.kycStatus});

  final KycStatus kycStatus;

  factory AddressStepResult.fromJson(Map<String, dynamic> json) {
    return AddressStepResult(kycStatus: KycStatusX.fromApi(json['kycStatus'] as String?));
  }
}

class BankStepResult {
  const BankStepResult({required this.kycStatus, this.accountLast4});

  final KycStatus kycStatus;
  final String? accountLast4;

  factory BankStepResult.fromJson(Map<String, dynamic> json) {
    final bank = json['bankDetails'] as Map<String, dynamic>?;
    return BankStepResult(
      kycStatus: KycStatusX.fromApi(json['kycStatus'] as String?),
      accountLast4: bank?['accountLast4'] as String?,
    );
  }
}

class KycStatusResult {
  const KycStatusResult({required this.kycStatus, this.rejectedReason});

  final KycStatus kycStatus;
  final String? rejectedReason;

  factory KycStatusResult.fromJson(Map<String, dynamic>? json) {
    return KycStatusResult(
      kycStatus: KycStatusX.fromApi(json?['kycStatus'] as String?),
      rejectedReason: json?['rejectedReason'] as String?,
    );
  }
}
