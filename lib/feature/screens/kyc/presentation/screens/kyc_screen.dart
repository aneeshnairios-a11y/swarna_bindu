import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:gold_scheme/core/constants/app_string/app_strings.dart';
import 'package:gold_scheme/core/router/route_name.dart';
import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_spacing.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';

import '../../../../global_widgets/common_button.dart';
import '../viewmodels/kyc_viewmodels.dart';
import '../widgets/key_step_identity.dart';
import '../widgets/kyc_progress_header.dart';
import '../widgets/kyc_step_address.dart';
import '../widgets/kyc_step_personal.dart';

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

  /// Number of steps actually built in this screen (Personal, Identity, Address).
  static const _builtSteps = 3;

  late final _sectionLabels = [AppStrings.kyc.personalSectionLabel, AppStrings.kyc.identitySectionLabel, AppStrings.kyc.addressSectionLabel];

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
      default:
        return null;
    }
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
        notifier.updatePersonalInfo(fullName: _nameController.text.trim(), email: _emailController.text.trim(), mobile: _mobileController.text.trim());
        break;
      case 1:
        notifier.updateIdentityInfo(aadhaarNumber: _aadhaarController.text.trim(), panNumber: _panController.text.trim().toUpperCase());
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
    }

    if (step >= _builtSteps - 1) {
      // Steps 4 & 5 (Nominee, Review) land here once built.
      // For now, Phase 1 ends the flow at the dashboard.
      context.go(RouteName.dashboard);
      return;
    }

    notifier.nextStep();
    _pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  void _onBack() {
    final step = ref.read(kycProvider).currentStep;
    if (step == 0) {
      context.pop();
      return;
    }
    ref.read(kycProvider.notifier).previousStep();
    _pageController.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  void _onSkip() => context.go(RouteName.dashboard);

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: KycProgressHeader(currentStep: kycState.currentStep + 1, totalSteps: KycState.totalSteps, sectionLabel: _sectionLabels[kycState.currentStep], onBack: _onBack, onSkip: _onSkip),
            ),
            SizedBox(height: AppSpacing.lg),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
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
                      onDistrictChanged: (d) => ref.read(kycProvider.notifier).updateAddressInfo(district: d),
                      onStateChanged: (s) => ref.read(kycProvider.notifier).updateAddressInfo(stateName: s),
                      onDetectLocation: () {
                        // TODO(Phase 2): geolocator + reverse geocoding.
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
                  AppButton(text: AppStrings.kyc.continueCta, icon: Icons.arrow_forward, iconAfterText: true, onPressed: _onContinue),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 12.sp, color: AppColors.textMutedLight),
                      SizedBox(width: 4.w),
                      Text(AppStrings.kyc.securityNote, style: AppTypography.caption(color: AppColors.textMutedLight)),
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
