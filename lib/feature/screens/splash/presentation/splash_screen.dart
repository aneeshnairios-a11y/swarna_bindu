import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/image_string/image_strings.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../auth/data/repository/auth_repository.dart';

/// Animated gold logo splash — fades/scales in, then auto-navigates
/// to onboarding after a short delay.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 2400), _resolveDestination);
  }

  Future<void> _resolveDestination() async {
    if (!mounted) return;

    final secureStorage = ref.read(secureStorageProvider);
    final hasSession = await secureStorage.hasSession;

    if (!hasSession) {
      if (mounted) context.go(RouteName.onboarding);
      return;
    }

    // Confirm the refresh token is still valid before landing the user on
    // an authenticated screen — an expired/revoked token should send them
    // back to Login, not into a broken session.
    final refreshToken = await secureStorage.refreshToken;
    final result = await ref.read(authRepositoryProvider).refreshAccessToken(refreshToken!);

    if (!mounted) return;

    await result.when(
      success: (data) async {
        await secureStorage.updateAccessToken(data.accessToken);
        // TODO(dashboard): route to Dashboard once that screen/route
        // exists. KycSubmit is the only authenticated route registered
        // in app_router.dart right now, so it's the temporary landing
        // spot for a valid, returning session.
        if (mounted) context.go(RouteName.kycSubmit);
      },
      failure: (_) async {
        await secureStorage.clearAll();
        if (mounted) context.go(RouteName.login);
      },
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.splashGradient,
          image: DecorationImage(
            image: AssetImage(AppAssetImage.splashBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Image.asset(AppAssetImage.appLogo, width: 200.w),
            ),
          ),
        ),
      ),
    );
  }
}
