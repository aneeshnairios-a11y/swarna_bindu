import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../global_widgets/common_button.dart';
import '../viewmodels/kyc_viewmodels.dart';
import '../widgets/key_step_identity.dart';
import '../widgets/kyc_progress_header.dart';
import '../widgets/kyc_status_screen.dart';
import '../widgets/kyc_step_address.dart';
import '../widgets/kyc_step_bank.dart';
import '../widgets/kyc_step_personal.dart';
import '../widgets/kyc_step_review.dart';

/// KYC wizard. Figma shows 5 steps total; this build wires steps 1–3
/// (Personal, Identity, Address). Steps 4 (Nominee) & 5 (Review & Submit)
/// slot into the same PageView/_sectionLabels pattern once designed.
class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final _pageController = PageController();

  final _personalFormKey = GlobalKey<FormState>();
  final _identityFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _bankFormKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController();
  late final _emailController = TextEditingController();
  late final _mobileController = TextEditingController();
  late final _aadhaarController = TextEditingController();
  late final _panController = TextEditingController();
  late final _houseController = TextEditingController();
  late final _streetController = TextEditingController();
  late final _landmarkController = TextEditingController();
  late final _cityController = TextEditingController();
  late final _pinController = TextEditingController();
  late final _accountHolderController = TextEditingController();
  late final _accountNumberController = TextEditingController();
  late final _confirmAccountNumberController = TextEditingController();
  late final _ifscController = TextEditingController();
  late final _branchController = TextEditingController();
  late final _upiController = TextEditingController();

  /// Number of steps actually built in this screen (Personal, Identity, Address).
  // static const _builtSteps = 3;

  late final _sectionLabels = [
    AppStrings.kyc.personalSectionLabel,
    AppStrings.kyc.identitySectionLabel,
    AppStrings.kyc.addressSectionLabel,
    AppStrings.kyc.bankSectionLabel,
    AppStrings.kyc.reviewSectionLabel,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    _houseController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pinController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  GlobalKey<FormState>? _formKeyForStep(int step) {
    switch (step) {
      case 0:
        return _personalFormKey;
      case 1:
        return _identityFormKey;
      case 2:
        return _addressFormKey;
      case 3:
        return _bankFormKey;
      default:
        return null;
    }
  }

  void _goToPage(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _onSubmit() async {
    final notifier = ref.read(kycProvider.notifier);
    await notifier.submit();
    if (!mounted) return;
    // TODO(Phase 2): branch on the real API result instead of always
    // showing success — e.g. KycOutcome.rejected when verification fails.
    context.push(RouteName.kycStatus, extra: KycOutcome.success);
  }

  void _onContinue() {
    final notifier = ref.read(kycProvider.notifier);
    final step = ref.read(kycProvider).currentStep;
    final formKey = _formKeyForStep(step);

    if (formKey != null && !(formKey.currentState?.validate() ?? true)) {
      return;
    }

    switch (step) {
      case 0:
        notifier.updatePersonalInfo(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          mobile: _mobileController.text.trim(),
        );
        break;
      case 1:
        notifier.updateIdentityInfo(
          aadhaarNumber: _aadhaarController.text.trim(),
          panNumber: _panController.text.trim().toUpperCase(),
        );
        break;
      case 2:
        notifier.updateAddressInfo(
          houseName: _houseController.text.trim(),
          streetArea: _streetController.text.trim(),
          landmark: _landmarkController.text.trim(),
          city: _cityController.text.trim(),
          pinCode: _pinController.text.trim(),
        );
        break;
      case 3:
        notifier.updateBankInfo(
          accountHolderName: _accountHolderController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          confirmAccountNumber: _confirmAccountNumberController.text.trim(),
          ifscCode: _ifscController.text.trim().toUpperCase(),
          branchName: _branchController.text.trim(),
          upiId: _upiController.text.trim(),
        );
        break;
      case 4:
        _onSubmit();
        return;
    }

    notifier.nextStep();
    _goToPage(step + 1);
  }

  void _onBack() {
    final step = ref.read(kycProvider).currentStep;
    if (step == 0) {
      context.pop();
      return;
    }
    ref.read(kycProvider.notifier).previousStep();
    _goToPage(step - 1);
  }

  void _onSkip() => context.go(RouteName.dashboard);

  void _onEditStep(int step) {
    ref.read(kycProvider.notifier).goToStep(step);
    _goToPage(step);
  }

  void _syncControllersFromState(KycFormData data) {
    _nameController.text = data.fullName;
    _emailController.text = data.email;
    _mobileController.text = data.mobile;
    _aadhaarController.text = data.aadhaarNumber;
    _panController.text = data.panNumber;
    _houseController.text = data.houseName;
    _streetController.text = data.streetArea;
    _landmarkController.text = data.landmark;
    _cityController.text = data.city;
    _pinController.text = data.pinCode;
    _accountHolderController.text = data.accountHolderName;
    _accountNumberController.text = data.accountNumber;
    _confirmAccountNumberController.text = data.confirmAccountNumber;
    _ifscController.text = data.ifscCode;
    _branchController.text = data.branchName;
    _upiController.text = data.upiId;
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycProvider);
    final isReview = kycState.isReviewStep;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: KycProgressHeader(
                currentStep: kycState.currentStep + 1,
                totalSteps: KycState.totalSteps,
                sectionLabel: _sectionLabels[kycState.currentStep],
                onBack: _onBack,
                onSkip: _onSkip,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  // Fired when Review's Edit links jump the PageView directly.
                  if (page != ref.read(kycProvider).currentStep) {
                    ref.read(kycProvider.notifier).goToStep(page);
                  }
                  _syncControllersFromState(ref.read(kycProvider).data);
                },
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: KycStepPersonal(
                      formKey: _personalFormKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      mobileController: _mobileController,
                      dob: kycState.data.dob,
                      gender: kycState.data.gender,
                      profileImagePath: kycState.data.profileImagePath,
                      onDobChanged: (d) => ref
                          .read(kycProvider.notifier)
                          .updatePersonalInfo(dob: d),
                      onGenderChanged: (g) => ref
                          .read(kycProvider.notifier)
                          .updatePersonalInfo(gender: g),
                      onPickProfileImage: () {
                        // TODO(Phase 2): image_picker → flutter_image_compress → upload.
                      },
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: KycStepIdentity(
                      formKey: _identityFormKey,
                      aadhaarController: _aadhaarController,
                      panController: _panController,
                      aadhaarFrontPath: kycState.data.aadhaarFrontPath,
                      aadhaarBackPath: kycState.data.aadhaarBackPath,
                      panCardPath: kycState.data.panCardPath,
                      onUploadAadhaarFront: () {
                        // TODO(Phase 2): image_picker for Aadhaar front.
                      },
                      onUploadAadhaarBack: () {
                        // TODO(Phase 2): image_picker for Aadhaar back.
                      },
                      onUploadPanCard: () {
                        // TODO(Phase 2): image_picker for PAN card.
                      },
                      onConnectDigiLocker: () {
                        // TODO(Phase 2): DigiLocker OAuth flow.
                      },
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: KycStepAddress(
                      formKey: _addressFormKey,
                      houseController: _houseController,
                      streetController: _streetController,
                      landmarkController: _landmarkController,
                      cityController: _cityController,
                      pinController: _pinController,
                      district: kycState.data.district,
                      state: kycState.data.state,
                      onDistrictChanged: (d) => ref
                          .read(kycProvider.notifier)
                          .updateAddressInfo(district: d),
                      onStateChanged: (s) => ref
                          .read(kycProvider.notifier)
                          .updateAddressInfo(stateName: s),
                      onDetectLocation: () {
                        // TODO(Phase 2): geolocator + reverse geocoding.
                      },
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: KycStepBank(
                      formKey: _bankFormKey,
                      accountHolderController: _accountHolderController,
                      accountNumberController: _accountNumberController,
                      confirmAccountNumberController:
                          _confirmAccountNumberController,
                      ifscController: _ifscController,
                      branchController: _branchController,
                      upiController: _upiController,
                      bankName: kycState.data.bankName,
                      onBankChanged: (b) => ref
                          .read(kycProvider.notifier)
                          .updateBankInfo(bankName: b),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: KycStepReview(
                      data: kycState.data,
                      onEditStep: _onEditStep,
                      onCaptureSelfie: () {
                        // TODO(Phase 2): camera capture + liveness check.
                        // Mocked here so Review has something to display:
                        ref
                            .read(kycProvider.notifier)
                            .updateSelfie(
                              selfieImagePath: 'mock',
                              selfieCapturedAt: DateTime.now(),
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  AppButton(
                    text: isReview
                        ? AppStrings.kyc.submitKycCta
                        : AppStrings.kyc.continueCta,
                    icon: isReview ? null : Icons.arrow_forward,
                    iconAfterText: true,
                    isLoading: kycState.isSubmitting,
                    onPressed: _onContinue,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 12.sp,
                        color: AppColors.textMutedLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppStrings.kyc.securityNote,
                        style: AppTypography.caption(
                          color: AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
