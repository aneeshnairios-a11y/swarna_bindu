import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';
import 'package:swarna_bindu/core/utils/image_picker_helper.dart';
import 'package:swarna_bindu/feature/screens/auth/data/models/auth_models.dart' show KycStatus;

import '../../../../global_widgets/common_button.dart';
import '../viewmodels/kyc_viewmodels.dart';
import '../widgets/key_step_identity.dart';
import '../widgets/kyc_progress_header.dart';
import '../widgets/kyc_status_screen.dart';
import '../widgets/kyc_step_address.dart';
import '../widgets/kyc_step_bank.dart';
import '../widgets/kyc_step_personal.dart';
import '../widgets/kyc_step_review.dart';

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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.errorRed));
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onSubmit() async {
    final notifier = ref.read(kycProvider.notifier);
    await notifier.finalizeAndCheckStatus();
    if (!mounted) return;

    final result = ref.read(kycProvider);
    if (result.status == KycSubmitStatus.error) {
      _showError(result.errorMessage ?? AppStrings.common.genericError);
      return;
    }

    final outcome = switch (result.kycStatus) {
      KycStatus.approved => KycOutcome.success,
      KycStatus.rejected => KycOutcome.rejected,
      _ => KycOutcome.pending,
    };
    if (!mounted) return;
    context.push(RouteName.kycStatus, extra: outcome);
  }

  Future<void> _onContinue() async {
    final notifier = ref.read(kycProvider.notifier);
    final step = ref.read(kycProvider).currentStep;
    final formKey = _formKeyForStep(step);

    if (formKey != null && !(formKey.currentState?.validate() ?? true)) {
      return;
    }

    bool ok = true;

    switch (step) {
      case 0:
        final data = ref.read(kycProvider).data;
        if (data.dob == null || data.gender == null) {
          _showError('Please select your date of birth and gender');
          return;
        }
        ok = await notifier.savePersonalStep(
          fullName: _nameController.text.trim(),
          dob: data.dob!,
          gender: data.gender!,
          email: _emailController.text.trim(),
        );
        break;
      case 1:
        ok = await notifier.saveIdentityStep(
          aadhaarNumber: _aadhaarController.text.trim(),
          panNumber: _panController.text.trim().toUpperCase(),
        );
        break;
      case 2:
        final data = ref.read(kycProvider).data;
        if (data.district == null) {
          _showError('Please select your district');
          return;
        }
        ok = await notifier.saveAddressStep(
          houseName: _houseController.text.trim(),
          street: _streetController.text.trim(),
          landmark: _landmarkController.text.trim(),
          city: _cityController.text.trim(),
          district: data.district!,
          stateName: data.state,
          pinCode: _pinController.text.trim(),
        );
        break;
      case 3:
        final data = ref.read(kycProvider).data;
        if (data.bankName == null) {
          _showError('Please select your bank');
          return;
        }
        ok = await notifier.saveBankStep(
          accountHolderName: _accountHolderController.text.trim(),
          bankName: data.bankName!,
          accountNumber: _accountNumberController.text.trim(),
          confirmAccountNumber: _confirmAccountNumberController.text.trim(),
          ifscCode: _ifscController.text.trim().toUpperCase(),
          branchName: _branchController.text.trim(),
          upiId: _upiController.text.trim(),
        );
        break;
      case 4:
        await _onSubmit();
        return;
    }

    if (!mounted) return;

    if (!ok) {
      final message = ref.read(kycProvider).stepErrorMessage ?? AppStrings.common.genericError;
      _showError(message);
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

  Future<void> _onDetectLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showInfo('Location permission denied. You can still enter your address manually.');
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showInfo('Please enable location services to auto-detect your address.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      ref
          .read(kycProvider.notifier)
          .updateAddressInfo(
            latitude: position.latitude,
            longitude: position.longitude,
          );
      _showInfo('Location captured. Please confirm the address fields below.');
    } catch (_) {
      _showInfo('Could not detect location. Please enter your address manually.');
    }
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
    final isBusy = kycState.isSavingStep || kycState.isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: KycProgressHeader(
                currentStep: kycState.currentStep + 1,
                totalSteps: KycState.totalSteps,
                sectionLabel: _sectionLabels[kycState.currentStep],
                onBack: isBusy ? null : _onBack,
                onSkip: isBusy ? null : _onSkip,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
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
                      onDobChanged: (d) => ref.read(kycProvider.notifier).updatePersonalInfo(dob: d),
                      onGenderChanged: (g) => ref.read(kycProvider.notifier).updatePersonalInfo(gender: g),
                      onPickProfileImage: () async {
                        final file = await ImagePickerHelper.pickAndCompress(context);
                        if (file != null) {
                          ref.read(kycProvider.notifier).updatePersonalInfo(profileImagePath: file.path);
                        }
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
                      onUploadAadhaarFront: () async {
                        final file = await ImagePickerHelper.pickAndCompress(context);
                        if (file != null) {
                          ref.read(kycProvider.notifier).updateIdentityInfo(aadhaarFrontPath: file.path);
                        }
                      },
                      onUploadAadhaarBack: () async {
                        final file = await ImagePickerHelper.pickAndCompress(context);
                        if (file != null) {
                          ref.read(kycProvider.notifier).updateIdentityInfo(aadhaarBackPath: file.path);
                        }
                      },
                      onUploadPanCard: () async {
                        final file = await ImagePickerHelper.pickAndCompress(context);
                        if (file != null) {
                          ref.read(kycProvider.notifier).updateIdentityInfo(panCardPath: file.path);
                        }
                      },
                      onConnectDigiLocker: () {
                        // TODO(Phase 2): DigiLocker OAuth flow.
                        _showInfo('DigiLocker connect is coming soon.');
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
                      onDistrictChanged: (d) => ref.read(kycProvider.notifier).updateAddressInfo(district: d),
                      onStateChanged: (s) => ref.read(kycProvider.notifier).updateAddressInfo(stateName: s),
                      onDetectLocation: _onDetectLocation,
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: KycStepBank(
                      formKey: _bankFormKey,
                      accountHolderController: _accountHolderController,
                      accountNumberController: _accountNumberController,
                      confirmAccountNumberController: _confirmAccountNumberController,
                      ifscController: _ifscController,
                      branchController: _branchController,
                      upiController: _upiController,
                      bankName: kycState.data.bankName,
                      onBankChanged: (b) => ref.read(kycProvider.notifier).updateBankInfo(bankName: b),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: KycStepReview(
                      data: kycState.data,
                      onEditStep: _onEditStep,
                      onCaptureSelfie: () async {
                        final picker = ImagePicker();
                        final photo = await picker.pickImage(
                          source: ImageSource.camera,
                          preferredCameraDevice: CameraDevice.front,
                          imageQuality: 85,
                        );
                        if (photo != null) {
                          ref
                              .read(kycProvider.notifier)
                              .updateSelfie(
                                selfieImagePath: photo.path,
                                selfieCapturedAt: DateTime.now(),
                              );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                children: [
                  AppButton(
                    text: isReview ? AppStrings.kyc.submitKycCta : AppStrings.kyc.continueCta,
                    icon: isReview ? null : Icons.arrow_forward,
                    iconAfterText: true,
                    isLoading: isBusy,
                    onPressed: isBusy ? null : _onContinue,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 12.sp, color: AppColors.textMutedLight),
                      SizedBox(width: 4.w),
                      Text(
                        AppStrings.kyc.securityNote,
                        style: AppTypography.caption(color: AppColors.textMutedLight),
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
