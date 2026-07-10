import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable form data collected across the KYC wizard.
/// Phase 1: kept in memory only.
/// Phase 2: submit via POST /users/:id/kyc.
class KycFormData {
  const KycFormData({
    this.profileImagePath,
    this.fullName = '',
    this.dob,
    this.gender,
    this.email = '',
    this.mobile = '',
    this.aadhaarNumber = '',
    this.aadhaarFrontPath,
    this.aadhaarBackPath,
    this.panNumber = '',
    this.panCardPath,
    this.houseName = '',
    this.streetArea = '',
    this.landmark = '',
    this.city = '',
    this.district,
    this.state = 'Kerala',
    this.pinCode = '',
  });

  final String? profileImagePath;
  final String fullName;
  final DateTime? dob;
  final String? gender;
  final String email;
  final String mobile;

  final String aadhaarNumber;
  final String? aadhaarFrontPath;
  final String? aadhaarBackPath;
  final String panNumber;
  final String? panCardPath;

  final String houseName;
  final String streetArea;
  final String landmark;
  final String city;
  final String? district;
  final String state;
  final String pinCode;

  KycFormData copyWith({
    String? profileImagePath,
    String? fullName,
    DateTime? dob,
    String? gender,
    String? email,
    String? mobile,
    String? aadhaarNumber,
    String? aadhaarFrontPath,
    String? aadhaarBackPath,
    String? panNumber,
    String? panCardPath,
    String? houseName,
    String? streetArea,
    String? landmark,
    String? city,
    String? district,
    String? state,
    String? pinCode,
  }) {
    return KycFormData(
      profileImagePath: profileImagePath ?? this.profileImagePath,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      aadhaarFrontPath: aadhaarFrontPath ?? this.aadhaarFrontPath,
      aadhaarBackPath: aadhaarBackPath ?? this.aadhaarBackPath,
      panNumber: panNumber ?? this.panNumber,
      panCardPath: panCardPath ?? this.panCardPath,
      houseName: houseName ?? this.houseName,
      streetArea: streetArea ?? this.streetArea,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      district: district ?? this.district,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
    );
  }
}

enum KycSubmitStatus { idle, submitting, success, error }

class KycState {
  const KycState({this.currentStep = 0, this.data = const KycFormData(), this.status = KycSubmitStatus.idle, this.errorMessage});

  /// Total steps in the full wizard (Figma shows 5 — this build covers
  /// steps 1–3; steps 4 (Nominee) & 5 (Review) plug in the same way).
  static const totalSteps = 5;

  final int currentStep; // 0-based, drives the PageView
  final KycFormData data;
  final KycSubmitStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == KycSubmitStatus.submitting;

  KycState copyWith({int? currentStep, KycFormData? data, KycSubmitStatus? status, String? errorMessage}) {
    return KycState(currentStep: currentStep ?? this.currentStep, data: data ?? this.data, status: status ?? this.status, errorMessage: errorMessage);
  }
}

class KycNotifier extends Notifier<KycState> {
  @override
  KycState build() => const KycState();

  void nextStep() {
    if (state.currentStep < KycState.totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updatePersonalInfo({String? profileImagePath, String? fullName, DateTime? dob, String? gender, String? email, String? mobile}) {
    state = state.copyWith(
      data: state.data.copyWith(profileImagePath: profileImagePath, fullName: fullName, dob: dob, gender: gender, email: email, mobile: mobile),
    );
  }

  void updateIdentityInfo({String? aadhaarNumber, String? aadhaarFrontPath, String? aadhaarBackPath, String? panNumber, String? panCardPath}) {
    state = state.copyWith(
      data: state.data.copyWith(aadhaarNumber: aadhaarNumber, aadhaarFrontPath: aadhaarFrontPath, aadhaarBackPath: aadhaarBackPath, panNumber: panNumber, panCardPath: panCardPath),
    );
  }

  void updateAddressInfo({String? houseName, String? streetArea, String? landmark, String? city, String? district, String? stateName, String? pinCode}) {
    state = state.copyWith(
      data: state.data.copyWith(houseName: houseName, streetArea: streetArea, landmark: landmark, city: city, district: district, state: stateName, pinCode: pinCode),
    );
  }

  Future<void> submit() async {
    state = state.copyWith(status: KycSubmitStatus.submitting, errorMessage: null);
    // TODO(Phase 2): POST /users/:id/kyc with state.data (multipart for docs).
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(status: KycSubmitStatus.success);
  }
}

final kycProvider = NotifierProvider.autoDispose<KycNotifier, KycState>(KycNotifier.new);
