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
    this.accountHolderName = '',
    this.bankName,
    this.accountNumber = '',
    this.confirmAccountNumber = '',
    this.ifscCode = '',
    this.branchName = '',
    this.upiId = '',
    this.selfieImagePath,
    this.selfieCapturedAt,
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

  final String accountHolderName;
  final String? bankName;
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  final String branchName;
  final String upiId;

  final String? selfieImagePath;
  final DateTime? selfieCapturedAt;

  /// Combined single-line address used on the Review step.
  String get formattedAddress {
    final parts = [
      houseName,
      streetArea,
      if (landmark.trim().isNotEmpty) landmark,
      city,
      if (district != null) district,
      state,
    ].where((p) => p != null && p.toString().trim().isNotEmpty).join(', ');
    return parts;
  }

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
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
    String? confirmAccountNumber,
    String? ifscCode,
    String? branchName,
    String? upiId,
    String? selfieImagePath,
    DateTime? selfieCapturedAt,
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
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      confirmAccountNumber: confirmAccountNumber ?? this.confirmAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      upiId: upiId ?? this.upiId,
      selfieImagePath: selfieImagePath ?? this.selfieImagePath,
      selfieCapturedAt: selfieCapturedAt ?? this.selfieCapturedAt,
    );
  }
}

enum KycSubmitStatus { idle, submitting, success, error }

class KycState {
  const KycState({
    this.currentStep = 0,
    this.data = const KycFormData(),
    this.status = KycSubmitStatus.idle,
    this.errorMessage,
  });

  /// Personal, Identity, Address, Bank, Review — matches the Figma wizard.
  static const totalSteps = 5;

  final int currentStep; // 0-based, drives the PageView
  final KycFormData data;
  final KycSubmitStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == KycSubmitStatus.submitting;
  bool get isReviewStep => currentStep == totalSteps - 1;

  KycState copyWith({
    int? currentStep,
    KycFormData? data,
    KycSubmitStatus? status,
    String? errorMessage,
  }) {
    return KycState(
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
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

  /// Jumps directly to a step — used by the "Edit" links on the Review step.
  void goToStep(int step) {
    if (step >= 0 && step < KycState.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  void updatePersonalInfo({
    String? profileImagePath,
    String? fullName,
    DateTime? dob,
    String? gender,
    String? email,
    String? mobile,
  }) {
    state = state.copyWith(
      data: state.data.copyWith(
        profileImagePath: profileImagePath,
        fullName: fullName,
        dob: dob,
        gender: gender,
        email: email,
        mobile: mobile,
      ),
    );
  }

  void updateIdentityInfo({
    String? aadhaarNumber,
    String? aadhaarFrontPath,
    String? aadhaarBackPath,
    String? panNumber,
    String? panCardPath,
  }) {
    state = state.copyWith(
      data: state.data.copyWith(
        aadhaarNumber: aadhaarNumber,
        aadhaarFrontPath: aadhaarFrontPath,
        aadhaarBackPath: aadhaarBackPath,
        panNumber: panNumber,
        panCardPath: panCardPath,
      ),
    );
  }

  void updateAddressInfo({
    String? houseName,
    String? streetArea,
    String? landmark,
    String? city,
    String? district,
    String? stateName,
    String? pinCode,
  }) {
    state = state.copyWith(
      data: state.data.copyWith(
        houseName: houseName,
        streetArea: streetArea,
        landmark: landmark,
        city: city,
        district: district,
        state: stateName,
        pinCode: pinCode,
      ),
    );
  }

  void updateBankInfo({
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
    String? confirmAccountNumber,
    String? ifscCode,
    String? branchName,
    String? upiId,
  }) {
    state = state.copyWith(
      data: state.data.copyWith(
        accountHolderName: accountHolderName,
        bankName: bankName,
        accountNumber: accountNumber,
        confirmAccountNumber: confirmAccountNumber,
        ifscCode: ifscCode,
        branchName: branchName,
        upiId: upiId,
      ),
    );
  }

  void updateSelfie({String? selfieImagePath, DateTime? selfieCapturedAt}) {
    state = state.copyWith(
      data: state.data.copyWith(
        selfieImagePath: selfieImagePath,
        selfieCapturedAt: selfieCapturedAt,
      ),
    );
  }

  Future<void> submit() async {
    state = state.copyWith(
      status: KycSubmitStatus.submitting,
      errorMessage: null,
    );
    // TODO(Phase 2): POST /users/:id/kyc with state.data (multipart for docs).
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(status: KycSubmitStatus.success);
  }

  /// Resets submission status so the wizard can be retried after a
  /// rejection, without losing the data already entered.
  void resetSubmitStatus() {
    state = state.copyWith(status: KycSubmitStatus.idle, errorMessage: null);
  }
}

final kycProvider = NotifierProvider.autoDispose<KycNotifier, KycState>(
  KycNotifier.new,
);
