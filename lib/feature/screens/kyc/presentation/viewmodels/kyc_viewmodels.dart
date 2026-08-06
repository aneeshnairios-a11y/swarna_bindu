import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarna_bindu/core/storage/secure_storage_service.dart';
import 'package:swarna_bindu/feature/screens/auth/data/models/auth_models.dart' show KycStatus, KycStatusX;
import 'dart:io';
import '../../data/repository/kyc_repository.dart';

/// Immutable form data collected across the KYC wizard. Each step's fields
/// are pushed to the server the moment the user taps "Continue" on that
/// step (see KycNotifier.saveXStep) — this object is the local mirror used
/// to pre-fill fields, drive the Review screen, and survive step navigation.
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
    this.digiLockerConnected = false,
    this.houseName = '',
    this.streetArea = '',
    this.landmark = '',
    this.city = '',
    this.district,
    this.state = 'Kerala',
    this.pinCode = '',
    this.latitude,
    this.longitude,
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
  final bool digiLockerConnected;

  final String houseName;
  final String streetArea;
  final String landmark;
  final String city;
  final String? district;
  final String state;
  final String pinCode;
  final double? latitude;
  final double? longitude;

  final String accountHolderName;
  final String? bankName;
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  final String branchName;
  final String upiId;

  final String? selfieImagePath;
  final DateTime? selfieCapturedAt;

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
    bool? digiLockerConnected,
    String? houseName,
    String? streetArea,
    String? landmark,
    String? city,
    String? district,
    String? state,
    String? pinCode,
    double? latitude,
    double? longitude,
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
      digiLockerConnected: digiLockerConnected ?? this.digiLockerConnected,
      houseName: houseName ?? this.houseName,
      streetArea: streetArea ?? this.streetArea,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      district: district ?? this.district,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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

/// Separate from [KycSubmitStatus] — this tracks the in-flight PUT for
/// whichever step the user is currently on, so the "Continue" button can
/// show a spinner without touching the final-submit state.
enum KycStepSaveStatus { idle, saving, error }

class KycState {
  const KycState({
    this.currentStep = 0,
    this.data = const KycFormData(),
    this.status = KycSubmitStatus.idle,
    this.errorMessage,
    this.stepStatus = KycStepSaveStatus.idle,
    this.stepErrorMessage,
    this.kycStatus = KycStatus.notSubmitted,
    this.rejectedReason,
  });

  static const totalSteps = 5;

  final int currentStep;
  final KycFormData data;
  final KycSubmitStatus status;
  final String? errorMessage;
  final KycStepSaveStatus stepStatus;
  final String? stepErrorMessage;
  final KycStatus kycStatus;
  final String? rejectedReason;

  bool get isSubmitting => status == KycSubmitStatus.submitting;
  bool get isSavingStep => stepStatus == KycStepSaveStatus.saving;
  bool get isReviewStep => currentStep == totalSteps - 1;

  KycState copyWith({
    int? currentStep,
    KycFormData? data,
    KycSubmitStatus? status,
    String? errorMessage,
    KycStepSaveStatus? stepStatus,
    String? stepErrorMessage,
    KycStatus? kycStatus,
    String? rejectedReason,
  }) {
    return KycState(
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      status: status ?? this.status,
      errorMessage: errorMessage,
      stepStatus: stepStatus ?? this.stepStatus,
      stepErrorMessage: stepErrorMessage,
      kycStatus: kycStatus ?? this.kycStatus,
      rejectedReason: rejectedReason ?? this.rejectedReason,
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

  void goToStep(int step) {
    if (step >= 0 && step < KycState.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  // ── Local-only field updates (live as the user types/picks) ─────────
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
    bool? digiLockerConnected,
  }) {
    state = state.copyWith(
      data: state.data.copyWith(
        aadhaarNumber: aadhaarNumber,
        aadhaarFrontPath: aadhaarFrontPath,
        aadhaarBackPath: aadhaarBackPath,
        panNumber: panNumber,
        panCardPath: panCardPath,
        digiLockerConnected: digiLockerConnected,
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
    double? latitude,
    double? longitude,
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
        latitude: latitude,
        longitude: longitude,
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

  void clearStepError() {
    if (state.stepErrorMessage != null) {
      state = state.copyWith(stepStatus: KycStepSaveStatus.idle, stepErrorMessage: null);
    }
  }

  // ── Server-persisted step saves ──────────────────────────────────────
  Future<bool> savePersonalStep({
    required String fullName,
    required DateTime dob,
    required String gender,
    required String email,
  }) async {
    if (state.isSavingStep) return false;

    state = state.copyWith(
      data: state.data.copyWith(fullName: fullName, dob: dob, gender: gender, email: email),
      stepStatus: KycStepSaveStatus.saving,
      stepErrorMessage: null,
    );

    final file = _fileOrNull(state.data.profileImagePath);
    final result = await ref
        .read(kycRepositoryProvider)
        .putPersonal(
          fullName: fullName,
          dob: dob,
          gender: gender,
          email: email,
          profilePicture: file,
        );

    return result.when(
      success: (data) {
        state = state.copyWith(stepStatus: KycStepSaveStatus.idle, kycStatus: data.kycStatus);
        _syncKycStatus(data.kycStatus);
        return true;
      },
      failure: (e) {
        state = state.copyWith(stepStatus: KycStepSaveStatus.error, stepErrorMessage: e.message);
        return false;
      },
    );
  }

  Future<bool> saveIdentityStep({
    required String aadhaarNumber,
    required String panNumber,
  }) async {
    if (state.isSavingStep) return false;

    state = state.copyWith(
      data: state.data.copyWith(aadhaarNumber: aadhaarNumber, panNumber: panNumber),
      stepStatus: KycStepSaveStatus.saving,
      stepErrorMessage: null,
    );

    final result = await ref
        .read(kycRepositoryProvider)
        .putIdentity(
          aadhaarNumber: aadhaarNumber,
          panNumber: panNumber,
          digiLockerConnected: state.data.digiLockerConnected,
          aadhaarFront: _fileOrNull(state.data.aadhaarFrontPath),
          aadhaarBack: _fileOrNull(state.data.aadhaarBackPath),
          panCardPhoto: _fileOrNull(state.data.panCardPath),
        );

    return result.when(
      success: (data) {
        state = state.copyWith(stepStatus: KycStepSaveStatus.idle, kycStatus: data.kycStatus);
        _syncKycStatus(data.kycStatus);
        return true;
      },
      failure: (e) {
        state = state.copyWith(stepStatus: KycStepSaveStatus.error, stepErrorMessage: e.message);
        return false;
      },
    );
  }

  Future<bool> saveAddressStep({
    required String houseName,
    required String street,
    String? landmark,
    required String city,
    required String district,
    required String stateName,
    required String pinCode,
  }) async {
    if (state.isSavingStep) return false;

    state = state.copyWith(
      data: state.data.copyWith(
        houseName: houseName,
        streetArea: street,
        landmark: landmark,
        city: city,
        district: district,
        state: stateName,
        pinCode: pinCode,
      ),
      stepStatus: KycStepSaveStatus.saving,
      stepErrorMessage: null,
    );

    final result = await ref
        .read(kycRepositoryProvider)
        .putAddress(
          houseName: houseName,
          street: street,
          landmark: landmark,
          city: city,
          district: district,
          state: stateName,
          pinCode: pinCode,
          latitude: state.data.latitude,
          longitude: state.data.longitude,
        );

    return result.when(
      success: (data) {
        state = state.copyWith(stepStatus: KycStepSaveStatus.idle, kycStatus: data.kycStatus);
        _syncKycStatus(data.kycStatus);
        return true;
      },
      failure: (e) {
        state = state.copyWith(stepStatus: KycStepSaveStatus.error, stepErrorMessage: e.message);
        return false;
      },
    );
  }

  Future<bool> saveBankStep({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String confirmAccountNumber,
    required String ifscCode,
    required String branchName,
    String? upiId,
  }) async {
    if (state.isSavingStep) return false;

    if (accountNumber != confirmAccountNumber) {
      state = state.copyWith(
        stepStatus: KycStepSaveStatus.error,
        stepErrorMessage: 'Account numbers do not match',
      );
      return false;
    }

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
      stepStatus: KycStepSaveStatus.saving,
      stepErrorMessage: null,
    );

    final result = await ref
        .read(kycRepositoryProvider)
        .putBank(
          accountHolderName: accountHolderName,
          bankName: bankName,
          accountNumber: accountNumber,
          confirmAccountNumber: confirmAccountNumber,
          ifscCode: ifscCode,
          branchName: branchName,
          upiId: upiId,
        );

    return result.when(
      success: (data) {
        state = state.copyWith(stepStatus: KycStepSaveStatus.idle, kycStatus: data.kycStatus);
        _syncKycStatus(data.kycStatus);
        return true;
      },
      failure: (e) {
        state = state.copyWith(stepStatus: KycStepSaveStatus.error, stepErrorMessage: e.message);
        return false;
      },
    );
  }

  /// Interim "Submit" behavior for the Review step: the real
  /// POST /user/kyc/submit endpoint is deferred, so this instead confirms
  /// the authoritative status via GET /user/kyc/status — every step's data
  /// is already persisted server-side by this point anyway.
  Future<void> finalizeAndCheckStatus() async {
    state = state.copyWith(status: KycSubmitStatus.submitting, errorMessage: null);

    final result = await ref.read(kycRepositoryProvider).getStatus();

    await result.when(
      success: (data) async {
        await _syncKycStatus(data.kycStatus);
        state = state.copyWith(
          status: KycSubmitStatus.success,
          kycStatus: data.kycStatus,
          rejectedReason: data.rejectedReason,
        );
      },
      failure: (e) async {
        state = state.copyWith(status: KycSubmitStatus.error, errorMessage: e.message);
      },
    );
  }

  void resetSubmitStatus() {
    state = state.copyWith(status: KycSubmitStatus.idle, errorMessage: null);
  }

  Future<void> _syncKycStatus(KycStatus status) async {
    await ref.read(secureStorageProvider).saveKycStatus(status.apiValue);
  }

  File? _fileOrNull(String? path) => (path == null || path.isEmpty) ? null : File(path);
}

// Local import kept at the bottom deliberately narrow in scope — only
// KycNotifier needs dart:io, everything else in this file is pure state.
// ignore: unused_import

final kycProvider = NotifierProvider.autoDispose<KycNotifier, KycState>(
  KycNotifier.new,
);
