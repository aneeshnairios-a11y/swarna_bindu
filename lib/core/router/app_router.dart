import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gold_scheme/core/router/route_name.dart';

import '../../feature/screens/auth/presentation/screens/login_screen.dart';
import '../../feature/screens/auth/presentation/screens/otp_screen.dart';
import '../../feature/screens/kyc/presentation/screens/kyc_screen.dart';
import '../../feature/screens/onboarding/presentation/screens/onboarding_screen.dart';
import '../../feature/screens/splash/presentation/splash_screen.dart';

/// Navigator keys
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// GoRouter instance — provided via Riverpod so it can be refreshed on
/// auth state change in Phase 2.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteName.splash,
    debugLogDiagnostics: true,

    routes: [
      // Splash
      GoRoute(path: RouteName.splash, pageBuilder: (ctx, state) => _fadeTransition(state, const SplashScreen())),

      // Onboarding
      GoRoute(path: RouteName.onboarding, pageBuilder: (ctx, state) => _fadeTransition(state, const OnboardingScreen())),

      // Auth
      GoRoute(path: RouteName.login, pageBuilder: (ctx, state) => _slideTransition(state, const LoginScreen())),
      GoRoute(
        path: RouteName.otp,
        pageBuilder: (ctx, state) {
          final phone = state.extra as String? ?? '';
          return _slideTransition(state, OtpScreen(phoneNumber: phone));
        },
      ),
      GoRoute(path: RouteName.kycSubmit, pageBuilder: (ctx, state) => _slideTransition(state, const KycScreen())),
    ],

    // ── Routes (Phase 1 — remaining screens, to be added as built) ──
    // routes: [
    //   GoRoute(
    //     path: RouteName.otp,
    //     pageBuilder: (ctx, state) {
    //       final phone = state.extra as String? ?? '';
    //       return _slideTransition(state, OtpScreen(phoneNumber: phone));
    //     },
    //   ),
    //
    //   // ── Main shell with bottom nav ──────────────────────────
    //   ShellRoute(
    //     navigatorKey: _shellNavigatorKey,
    //     builder: (ctx, state, child) => MainShell(child: child),
    //     routes: [
    //       GoRoute(
    //         path: RouteName.dashboard,
    //         pageBuilder: (ctx, state) =>
    //             _noTransition(state, const DashboardScreen()),
    //       ),
    //       GoRoute(
    //         path: RouteName.schemes,
    //         pageBuilder: (ctx, state) =>
    //             _noTransition(state, const SchemesScreen()),
    //         routes: [
    //           GoRoute(
    //             path: ':id',
    //             parentNavigatorKey: _rootNavigatorKey,
    //             pageBuilder: (ctx, state) {
    //               final id = state.pathParameters['id']!;
    //               return _slideTransition(state, SchemeDetailScreen(id: id));
    //             },
    //           ),
    //         ],
    //       ),
    //       GoRoute(
    //         path: RouteName.enrollments,
    //         pageBuilder: (ctx, state) =>
    //             _noTransition(state, const EnrollmentsScreen()),
    //         routes: [
    //           GoRoute(
    //             path: ':id/passbook',
    //             parentNavigatorKey: _rootNavigatorKey,
    //             pageBuilder: (ctx, state) {
    //               final id = state.pathParameters['id']!;
    //               return _slideTransition(state, PassbookScreen(enrollmentId: id));
    //             },
    //           ),
    //         ],
    //       ),
    //       GoRoute(
    //         path: RouteName.notifications,
    //         pageBuilder: (ctx, state) =>
    //             _noTransition(state, const NotificationsScreen()),
    //       ),
    //       GoRoute(
    //         path: RouteName.profile,
    //         pageBuilder: (ctx, state) =>
    //             _noTransition(state, const ProfileScreen()),
    //       ),
    //     ],
    //   ),
    //
    //   // ── Payment (full-screens, no shell) ────────────────────
    //   GoRoute(
    //     path: '/app/pay/:enrollmentId',
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) {
    //       final id = state.pathParameters['enrollmentId']!;
    //       return _slideTransition(state, PaymentScreen(enrollmentId: id));
    //     },
    //   ),
    //   GoRoute(
    //     path: RouteName.paymentSuccess,
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) =>
    //         _fadeTransition(state, const PaymentSuccessScreen()),
    //   ),
    //
    //   // ── Profile extras ─────────────────────────────────────
    //   GoRoute(
    //     path: RouteName.editProfile,
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) =>
    //         _slideTransition(state, const EditProfileScreen()),
    //   ),
    //   GoRoute(
    //     path: RouteName.kycSubmit,
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) =>
    //         _slideTransition(state, const KycSubmitScreen()),
    //   ),
    //   GoRoute(
    //     path: RouteName.kycStatus,
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) =>
    //         _slideTransition(state, const KycStatusScreen()),
    //   ),
    //
    //   // ── Redemption ─────────────────────────────────────────
    //   GoRoute(
    //     path: '/app/redemption/:enrollmentId',
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) {
    //       final id = state.pathParameters['enrollmentId']!;
    //       return _slideTransition(state, RedemptionScreen(enrollmentId: id));
    //     },
    //   ),
    //   GoRoute(
    //     path: '/app/redemption/:id/status',
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) {
    //       final id = state.pathParameters['id']!;
    //       return _slideTransition(state, RedemptionStatusScreen(redemptionId: id));
    //     },
    //   ),
    //
    //   // ── Agent ──────────────────────────────────────────────
    //   GoRoute(
    //     path: RouteName.agentDashboard,
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) =>
    //         _slideTransition(state, const AgentDashboardScreen()),
    //   ),
    //   GoRoute(
    //     path: RouteName.agentDueList,
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) =>
    //         _slideTransition(state, const AgentDueListScreen()),
    //   ),
    //   GoRoute(
    //     path: '/app/agent/collect/:customerId',
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) {
    //       final id = state.pathParameters['customerId']!;
    //       return _slideTransition(state, AgentCollectScreen(customerId: id));
    //     },
    //   ),
    //   GoRoute(
    //     path: RouteName.agentStats,
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) =>
    //         _slideTransition(state, const AgentStatsScreen()),
    //   ),
    //
    //   // ── Settings ───────────────────────────────────────────
    //   GoRoute(
    //     path: RouteName.settings,
    //     parentNavigatorKey: _rootNavigatorKey,
    //     pageBuilder: (ctx, state) =>
    //         _slideTransition(state, const SettingsScreen()),
    //   ),
    // ],
    errorBuilder: (ctx, state) => _ErrorScreen(error: state.error.toString()),
  );
});

// ── Page transition helpers ─────────────────────────────────────
CustomTransitionPage<void> _slideTransition(GoRouterState state, Widget child) => CustomTransitionPage(
  key: state.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 280),
  reverseTransitionDuration: const Duration(milliseconds: 220),
  transitionsBuilder: (ctx, animation, secondary, child) => SlideTransition(
    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  ),
);

CustomTransitionPage<void> _fadeTransition(GoRouterState state, Widget child) => CustomTransitionPage(
  key: state.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 400),
  transitionsBuilder: (ctx, animation, secondary, child) => FadeTransition(opacity: animation, child: child),
);

CustomTransitionPage<void> _noTransition(GoRouterState state, Widget child) => CustomTransitionPage(key: state.pageKey, child: child, transitionsBuilder: (ctx, animation, secondary, child) => child);

// ── Error screens ────────────────────────────────────────────────
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Navigation error:\n$error', textAlign: TextAlign.center),
      ),
    ),
  );
}
