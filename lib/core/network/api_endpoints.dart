library;

enum AppEnvironment { dev, staging, prod }

abstract class EnvConfig {
  /// Flip this (or wire to `--dart-define=ENV=prod`) per build flavor.
  static const AppEnvironment current = AppEnvironment.dev;

  static const Map<AppEnvironment, String> _baseUrls = {
    AppEnvironment.dev: 'https://scheme.bindujewellery.com/api/v1',
    AppEnvironment.staging: 'https://scheme.bindujewellery.com/api/v1',
    AppEnvironment.prod: 'https://scheme.bindujewellery.com/api/v1',
  };

  static String get baseUrl => _baseUrls[current]!;

  static bool get isProd => current == AppEnvironment.prod;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);
}

abstract class ApiEndpoints {
  // ── Auth ────────────────────────────────────────────────────
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // ── KYC ─────────────────────────────────────────────────────
  static const String kycPersonal = '/user/kyc/personal';
  static const String kycIdentity = '/user/kyc/identity';
  static const String kycAddress = '/user/kyc/address';
  static const String kycBank = '/user/kyc/bank';
  static const String kycStatus = '/user/kyc/status';
  static const String kycSubmitFull = '/user/kyc/submit-full';
  static const String kycSubmit = '/user/kyc/submit';

  // ── Users ───────────────────────────────────────────────────
  static String userProfile(String id) => '/users/$id';
  static String submitKyc(String id) => '/users/$id/kyc';
  static String verifyKyc(String id) => '/users/$id/kyc/verify';
  static String userEnrollments(String id) => '/users/$id/enrollments';
  static String deviceToken(String id) => '/users/$id/device-token';

  // ── Schemes ─────────────────────────────────────────────────
  static const String schemes = '/schemes';
  static String schemeDetail(String id) => '/schemes/$id';
  static String schemeJoin(String id) => '/schemes/$id/join';
  static const String mySchemes = '/schemes/my-schemes';

  // ── Enrollments ─────────────────────────────────────────────
  static const String enrollments = '/enrollments';
  static String enrollmentDetail(String id) => '/enrollments/$id';
  static String installments(String enrollmentId) => '/enrollments/$enrollmentId/installments';
  static String statement(String enrollmentId) => '/enrollments/$enrollmentId/statement';
  static String enrollmentStatus(String id) => '/enrollments/$id/status';

  // ── Payments ────────────────────────────────────────────────
  static const String createOrder = '/payments/create-order';
  static const String verifyPayment = '/payments/verify';
  static const String recordInstallment = '/installments';
  static const String syncInstallments = '/installments/sync';

  // ── Gold rates ──────────────────────────────────────────────
  static const String goldRateToday = '/gold-rate/today';
  static const String goldRateHistory = '/gold-rates/history';

  // ── Redemptions ─────────────────────────────────────────────
  static const String redemptions = '/redemptions';
  static String redemptionDetail(String id) => '/redemptions/$id';
  static String redemptionStatus(String id) => '/redemptions/$id/status';

  // ── Notifications ───────────────────────────────────────────
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';

  // ── Agent ───────────────────────────────────────────────────
  static String agentDueList(String agentId) => '/agents/$agentId/due-list';
  static String agentCheckIn(String agentId) => '/agents/$agentId/checkin';
  static String agentStats(String agentId) => '/agents/$agentId/stats';
  static String agentCollections(String agentId) => '/agents/$agentId/collections';

  /// Paths that must never carry a stale/expired access token attempt and
  /// must never trigger the 401 → refresh flow (they're either public or
  /// they ARE the refresh call itself).
  static const List<String> publicPaths = [
    sendOtp,
    verifyOtp,
    refreshToken,
  ];
}
