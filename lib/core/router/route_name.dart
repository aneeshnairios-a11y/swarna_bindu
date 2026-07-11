/// All route path constants for the app.
/// Never use raw strings for navigation — always use this class.
abstract class RouteName {
  // ── Auth ──────────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';

  // ── Main shell (bottom nav) ───────────────────────────────────
  static const String shell = '/app';
  static const String dashboard = '/app/dashboard';
  static const String schemes = '/app/schemes';
  static const String enrollments = '/app/enrollments';
  static const String profile = '/app/profile';




  // ── Scheme ────────────────────────────────────────────────────

  static const String schemeDetail = '/app/schemes/:id';
  // ── Dashboard ────────────────────────────────────────────────────

  static const String notifications = '/app/dashboard/notifications';
  static const String redeemGold = '/app/dashboard/redeemGold';


  // ── Enrollment & passbook ─────────────────────────────────────

  static const String passbook = '/app/enrollments/:id/passbook';
  // ── Payments ──────────────────────────────────────────────────

  static const String payment = '/app/pay/:enrollmentId';
  static const String paymentCheckout = '/app/pay/:enrollmentId/checkout';
  static const String paymentSuccess = '/app/pay/success';
  static const String paymentHistory = '/app/paymentHistory';
  static const String paymentReceipt = '/app/paymentReceipt';
  // ── Profile & KYC ────────────────────────────────────────────

  static const String kycSubmit = '/app/profile/kyc';
  static const String kycStatus = '/app/profile/kyc/status';
  static const String editProfile = '/app/profile/edit';
  static const String myScheme = '/app/profile/mySchemes';

  // ── Redemption ────────────────────────────────────────────────
  static const String redemption = '/app/redemption/:enrollmentId';
  static const String redemptionStatus = '/app/redemption/:id/status';

  // ── Gold rates ────────────────────────────────────────────────
  static const String goldRates = '/app/gold-rates';

  // ── Agent ─────────────────────────────────────────────────────
  static const String agentDashboard = '/app/agent/dashboard';
  static const String agentDueList = '/app/agent/due-list';
  static const String agentCollect = '/app/agent/collect/:customerId';
  static const String agentStats = '/app/agent/stats';
  static const String agentCheckIn = '/app/agent/checkin';

  // ── Settings ──────────────────────────────────────────────────
  static const String settings = '/app/settings';

  // ── Helpers ───────────────────────────────────────────────────
  static String schemeDetailPath(String id) => '/app/schemes/$id';
  static String passbookPath(String id) => '/app/enrollments/$id/passbook';
  static String paymentPath(String enrollmentId) => '/app/pay/$enrollmentId';
  static String paymentCheckoutPath(String enrollmentId) =>
      '/app/pay/$enrollmentId/checkout';
  static String redemptionPath(String enrollmentId) =>
      '/app/redemption/$enrollmentId';
  static String redemptionStatusPath(String id) => '/app/redemption/$id/status';
  static String agentCollectPath(String customerId) =>
      '/app/agent/collect/$customerId';
}
