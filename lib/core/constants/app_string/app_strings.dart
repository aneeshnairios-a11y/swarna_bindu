/// Centralized text constants for the Gold Scheme app.
///
/// PHASE 1: English only. Every getter here is written so that migrating to
/// ARB-based i18n later (T11 — en, hi, ta, ml) is a mechanical find/replace:
///   AppStrings.onboarding.skip   →   context.l10n.onboardingSkip
///
/// Never hardcode user-facing text inside widgets — always add it here first.
library;

abstract class AppStrings {
  static const app = _AppStrings();
  static const onboarding = _OnboardingStrings();
  static const login = _LoginStrings();
  static const otp = _OtpStrings();
  static const common = _CommonStrings();
  static const kyc = _KycStrings();
}

class _AppStrings {
  const _AppStrings();

  final String appName = 'Swarna Bindu';
  final String tagline = "It's a promise of lifetime";
}

class _OnboardingStrings {
  const _OnboardingStrings();

  // ── Actions ─────────────────────────────────────────────────
  final String skip = 'Skip';
  final String next = 'Next';
  final String getStarted = 'Get Started';

  // ── Page 1 ──────────────────────────────────────────────────
  final String page1TitleLine1 = 'Smart Gold Savings';
  final String page1TitleLine2 = 'for a Secure Future';
  final String page1Description =
      'Start your gold savings journey with flexible plans designed to '
      'help you build wealth, the smart way.';

  // ── Page 2 ──────────────────────────────────────────────────
  final String page2TitleLine1 = 'Safe, Secure & Trusted';
  final String page2TitleLine2 = 'Every Time';
  final String page2Description =
      'Your transactions and personal information are protected with '
      'bank-grade 256-bit security.';

  // ── Page 3 ──────────────────────────────────────────────────
  final String page3TitleLine1 = 'Simple. Flexible.';
  final String page3TitleLine2 = 'Built for You.';
  final String page3Description =
      'Choose from a range of plans and enjoy a seamless experience '
      'from start to growing your gold.';
}

class _LoginStrings {
  const _LoginStrings();

  final String welcomeTitle = 'Welcome Back!';
  final String welcomeSubtitle = 'Login to your account using OTP';
  final String mobileLabel = 'Enter Mobile Number';
  final String mobileHint = '98765 43210';
  final String otpHint = "We'll send a 6-digit OTP to your mobile number";
  final String sendOtp = 'Send OTP';
  final String invalidMobile = 'Enter a valid 10-digit mobile number';
}

class _OtpStrings {
  const _OtpStrings();

  final String title = 'Verify OTP';
  final String subtitle = 'Enter the 6-digit OTP sent to\nyour mobile number';
  final String fieldLabel = 'Enter 6-digit OTP';
  final String verifyAndLogin = 'Verify & Login';
  final String resendPrefix = "Didn't receive OTP? ";
  final String resendCta = 'Resend OTP';
  final String resendCountingLabel = 'Resend OTP in ';
  final String invalidOtp = 'Enter the complete 6-digit OTP';
}

class _KycStrings {
  const _KycStrings();

  // ── Common (shared across all steps) ──────────────────────────
  final String appBarTitle = 'Complete KYC';
  final String skip = 'Skip';
  final String continueCta = 'Continue';
  final String securityNote = 'Your data is encrypted and securely stored.';
  final String requiredTag = 'Required';

  // ── Step 1 — Personal Information ──────────────────────────────
  final String personalSectionLabel = 'Personal Information';
  final String bannerTitle = 'Complete Your KYC';
  final String bannerSubtitle = 'Complete your profile to securely access all Gold Scheme services.';
  final String addProfilePicture = 'Add Profile Picture';
  final String personalDetailsTitle = 'Personal Details';
  final String fullNameLabel = 'Full Name';
  final String fullNameHint = 'John Mathew';
  final String dobLabel = 'Date of Birth';
  final String dobHint = '15 May 1995';
  final String genderLabel = 'Gender';
  final String genderHint = 'Select';
  final String emailLabel = 'Email Address';
  final String emailHint = 'john@gmail.com';
  final String mobileLabel = 'Mobile Number (Optional)';
  final String mobileHint = '+91 98765 43210';

  // ── Step 2 — Identity Verification ──────────────────────────────
  final String identitySectionLabel = 'Identity Verification';
  final String identityTitle = 'Verify Your Identity';
  final String identitySubtitle = 'Upload your government issued ID for verification.';
  final String aadhaarCardTitle = 'Aadhaar Card';
  final String aadhaarNumberLabel = 'Aadhaar Number';
  final String aadhaarNumberHint = 'XXXX XXXX 4589';
  final String uploadFront = 'Upload Front photo';
  final String uploadBack = 'Upload Back photo';
  final String uploadHint = 'JPG, PNG up to 5MB';
  final String orDivider = 'OR';
  final String digiLockerTitle = 'Verify Instantly using DigiLocker';
  final String digiLockerSubtitle = 'Pull your documents securely from DigiLocker';
  final String digiLockerCta = 'Connect DigiLocker';
  final String panCardTitle = 'PAN Card';
  final String panNumberLabel = 'PAN Number';
  final String panNumberHint = 'ABCDE1234F';
  final String uploadPanCard = 'Upload PAN Card';
  final String documentsSafeNote = 'Your documents are safe with us. All uploaded documents are encrypted and stored securely.';

  // ── Step 3 — Address Information ────────────────────────────────
  final String addressSectionLabel = 'Address Information';
  final String addressTitle = 'Address Information';
  final String addressSubtitle = 'Please enter your current address details.';
  final String houseLabel = 'House / Building Name';
  final String houseHint = 'Green Villa';
  final String streetLabel = 'Street / Area';
  final String streetHint = 'MG Road';
  final String landmarkLabel = 'Landmark (Optional)';
  final String landmarkHint = 'Near Metro Station';
  final String cityLabel = 'City / Town';
  final String cityHint = 'Kochi';
  final String districtLabel = 'District';
  final String stateLabel = 'State';
  final String pinCodeLabel = 'PIN Code';
  final String pinCodeHint = '682001';
  final String detectLocationTitle = 'Detect Current Location';
  final String detectLocationSubtitle = 'Use your current location to fill address';
  final String addressSecureNote = 'Your information is secure. Your address details are encrypted and used only for verification purposes.';

  // ── Step 4 — Bank Account Details ───────────────────────────────
  final String bankSectionLabel = 'Bank Details';
  final String bankTitle = 'Bank Account Details';
  final String bankSubtitle = 'Enter your bank account details for secure transactions.';
  final String accountHolderLabel = 'Account Holder Name';
  final String accountHolderHint = 'John Mathew';
  final String bankNameLabel = 'Bank Name';
  final String accountNumberLabel = 'Account Number';
  final String accountNumberHint = '9198 7654 3210';
  final String confirmAccountNumberLabel = 'Confirm Account Number';
  final String ifscLabel = 'IFSC Code';
  final String ifscHint = 'UTIB0001234';
  final String branchNameLabel = 'Branch Name';
  final String branchNameHint = 'MG Road, Kochi';
  final String bankUsageNote = 'This account will be used to receive maturity amount, redemptions and refunds.';
  final String upiLabel = 'UPI ID (Optional)';
  final String upiSubtitle = 'Receive payment confirmations on your UPI ID';
  final String upiHint = 'john@okaxis';
  final String bankSecureNote = 'Your bank details are safe with us. We use bank-level security to protect your information.';

  // ── Step 5 — Review & Submit ────────────────────────────────────
  final String reviewSectionLabel = 'Review & Submit';
  final String reviewTitle = 'Review Your Details';
  final String reviewSubtitle = 'Please review all the information before submitting your KYC.';
  final String reviewSecureNote = 'Your information is secure. All your details are encrypted and will be used only for verification purposes.';
  final String selfieSectionLabel = 'Selfie Verification';
  final String captureSelfieCta = 'Capture';
  final String selfieNotCaptured = 'Not captured yet';
  final String submitKycCta = 'Submit KYC';

  // ── KYC Status (success / rejected / pending) ───────────────────
  final String statusAppBarTitle = 'KYC Status';
  final String statusStepCaption = 'Step 5 of 5 • Verification';
  final String statusSuccessTitle = 'KYC Submitted Successfully!';
  final String statusSuccessSubtitle = 'Thank you! Your KYC has been submitted. We will verify your details and notify you soon.';
  final String statusRejectedTitle = 'KYC Submitted Rejected';
  final String statusRejectedSubtitle = "Your document didn't pass verification. Re-upload a clear photo to try again.";
  final String statusPendingTitle = 'KYC Under Review';
  final String statusPendingSubtitle = 'Your KYC is being reviewed by our team. This usually takes 24–48 hours.';
  final String statusEtaLabel = 'Estimated verification time';
  final String statusEtaValue = '24 – 48 Hours';
  final String statusReuploadCta = 'Re-upload Document';
  final String statusGoToDashboardCta = 'Go to Dashboard';
}

class _CommonStrings {
  const _CommonStrings();

  final String genericError = 'Something went wrong. Please try again.';
  final String loading = 'Loading...';
}
