/// `GET /user/profile` → `data`.
///
/// Every field is null-safe: a missing/odd value in the response never
/// throws, it falls back to an empty string / 0 / null.

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

int _toInt(dynamic v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

DateTime? _toDate(dynamic v) => v is String ? DateTime.tryParse(v) : null;

String? _toStr(dynamic v) {
  if (v is! String) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
}

class ProfilePersonalInfo {
  const ProfilePersonalInfo({
    this.fullName,
    this.dob,
    this.gender,
    this.email,
    this.profilePicture,
  });

  final String? fullName;
  final DateTime? dob;
  final String? gender;
  final String? email;
  final String? profilePicture;

  factory ProfilePersonalInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProfilePersonalInfo();
    return ProfilePersonalInfo(
      fullName: _toStr(json['fullName']),
      dob: _toDate(json['dob']),
      gender: _toStr(json['gender']),
      email: _toStr(json['email']),
      profilePicture: _toStr(json['profilePicture']),
    );
  }
}

class ProfileBankDetails {
  const ProfileBankDetails({
    this.accountHolderName,
    this.bankName,
    this.branchName,
    this.upiId,
  });

  final String? accountHolderName;
  final String? bankName;
  final String? branchName;
  final String? upiId;

  factory ProfileBankDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProfileBankDetails();
    return ProfileBankDetails(
      accountHolderName: _toStr(json['accountHolderName']),
      bankName: _toStr(json['bankName']),
      branchName: _toStr(json['branchName']),
      upiId: _toStr(json['upiId']),
    );
  }
}

class ProfileInfo {
  const ProfileInfo({
    required this.id,
    required this.mobileNumber,
    required this.kycStatus,
    required this.personalInfo,
    required this.bankDetails,
  });

  final String id;
  final String mobileNumber;

  /// Raw API value, e.g. `APPROVED`.
  final String kycStatus;
  final ProfilePersonalInfo personalInfo;
  final ProfileBankDetails bankDetails;

  bool get isKycApproved => kycStatus.toUpperCase() == 'APPROVED';

  factory ProfileInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProfileInfo(
        id: '',
        mobileNumber: '',
        kycStatus: '',
        personalInfo: ProfilePersonalInfo(),
        bankDetails: ProfileBankDetails(),
      );
    }
    return ProfileInfo(
      id: json['id'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      kycStatus: json['kycStatus'] as String? ?? '',
      personalInfo: ProfilePersonalInfo.fromJson(json['personalInfo'] as Map<String, dynamic>?),
      bankDetails: ProfileBankDetails.fromJson(json['bankDetails'] as Map<String, dynamic>?),
    );
  }
}

class ProfileInvestments {
  const ProfileInvestments({
    this.totalSavingsValue = 0,
    this.currentGoldValue = 0,
    this.totalGoldAccumulated = 0,
    this.goalGoldGram = 0,
    this.progressPercent = 0,
    this.nextInstallmentDue = 0,
    this.nextDueDate,
    this.activeSchemesCount = 0,
    this.redeemedSchemesCount = 0,
  });

  final double totalSavingsValue;
  final double currentGoldValue;
  final double totalGoldAccumulated;
  final double goalGoldGram;
  final int progressPercent;
  final double nextInstallmentDue;
  final DateTime? nextDueDate;
  final int activeSchemesCount;
  final int redeemedSchemesCount;

  factory ProfileInvestments.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProfileInvestments();
    return ProfileInvestments(
      totalSavingsValue: _toDouble(json['totalSavingsValue']),
      currentGoldValue: _toDouble(json['currentGoldValue']),
      totalGoldAccumulated: _toDouble(json['totalGoldAccumulated']),
      goalGoldGram: _toDouble(json['goalGoldGram']),
      progressPercent: _toInt(json['progressPercent']),
      nextInstallmentDue: _toDouble(json['nextInstallmentDue']),
      nextDueDate: _toDate(json['nextDueDate']),
      activeSchemesCount: _toInt(json['activeSchemesCount']),
      redeemedSchemesCount: _toInt(json['redeemedSchemesCount']),
    );
  }
}

class ProfileData {
  const ProfileData({required this.profile, required this.investments});

  final ProfileInfo profile;
  final ProfileInvestments investments;

  factory ProfileData.fromJson(Map<String, dynamic>? json) {
    return ProfileData(
      profile: ProfileInfo.fromJson(json?['profile'] as Map<String, dynamic>?),
      investments: ProfileInvestments.fromJson(json?['investments'] as Map<String, dynamic>?),
    );
  }
}