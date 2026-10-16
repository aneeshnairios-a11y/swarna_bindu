import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/formatter/app_formatters.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../../core/router/route_name.dart';
import '../../../../global_widgets/dashboard_bottom_nav.dart';
import '../../../auth/presentation/viewmodels/logout_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';



/// Profile screen — maroon hero (avatar, name, mobile, KYC chip), an
/// investment summary that overlaps the hero, and a "General" settings list.
///
/// Hydrated from `GET /user/profile` via [profileProvider]. The layout is
/// always rendered (so Log Out stays reachable even if the API fails);
/// values show "—" until data arrives.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _navIndex = 4;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).load());
  }

  Future<void> _onLogoutTap() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final bodyColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        // Explicit color required here — AppTheme's DialogThemeData sets
        // titleTextStyle/contentTextStyle via AppTypography.xxx() with no
        // `color:` arg, so a bare Text() with no style of its own inherits
        // a null color and renders invisible. Every other screen avoids
        // this by always passing color explicitly at the call site.
        title: Text('Log Out', style: AppTypography.headingSM(color: titleColor)),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: AppTypography.bodySmall(color: bodyColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;
    await ref.read(logoutProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    // React once logout completes — navigate to Login and clear the
    // navigation stack so back-button can't return to authenticated
    // screens. A failed /auth/logout network call still logs the user
    // out locally (see LogoutNotifier), so this fires either way.
    ref.listen<LogoutState>(logoutProvider, (previous, next) {
      if (next.status == LogoutStatus.done &&
          previous?.status != LogoutStatus.done) {
        if (next.serverCallFailed) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text("Logged out. Couldn't reach the server, but your session was cleared."),
              ),
            );
        }
        context.go(RouteName.login);
      }
    });

    // A pull-to-refresh that fails keeps the old data and tells the user.
    ref.listen<ProfileState>(profileProvider, (previous, next) {
      final refreshFailed = (previous?.isRefreshing ?? false) &&
          !next.isRefreshing &&
          next.errorMessage != null &&
          next.hasData;
      if (refreshFailed) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final profile = ref.watch(profileProvider);
    final isLoggingOut = ref.watch(logoutProvider).isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHero(
                name: profile.name,
                mobile: profile.mobile,
                pictureUrl: profile.profilePictureUrl,
                kycStatus: profile.hasData ? profile.kycStatus : '',
                onBack: () => context.go(RouteName.dashboard),
              ),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _InvestmentSummaryCard(
                    totalInvestment:
                    profile.hasData ? AppFormatters.currency(profile.totalInvestment) : '—',
                    currentValue:
                    profile.hasData ? AppFormatters.currency(profile.currentValue) : '—',
                  ),
                ),
              ),
              if (profile.isError)
                Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                  child: _InlineError(
                    message: profile.errorMessage ?? 'Could not load your profile.',
                    onRetry: () => ref.read(profileProvider.notifier).load(),
                  ),
                )
              else if (profile.isLoading && !profile.hasData)
                Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                  child: const LinearProgressIndicator(minHeight: 2),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'General',
                      style: AppTypography.sectionTitleSM(
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _SettingsRow(
                      icon: Icons.flag_rounded,
                      title: 'My Scheme',
                      subtitle: 'Learn About Our Schemes',
                      onTap: () => context.push(RouteName.myScheme),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _SettingsRow(
                      icon: Icons.badge_rounded,
                      title: 'Privacy Policy',
                      subtitle: 'Read Our Privacy Policy',
                      onTap: () {},
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _SettingsRow(
                      icon: Icons.logout_rounded,
                      title: 'Log Out',
                      subtitle: 'Securely Log Out From Your Account',
                      isLoading: isLoggingOut,
                      onTap: isLoggingOut ? null : _onLogoutTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.mobile,
    required this.pictureUrl,
    required this.kycStatus,
    required this.onBack,
  });

  final String name;
  final String mobile;
  final String? pictureUrl;
  final String kycStatus;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: AppSpacing.xxxl + 28),
      decoration: const BoxDecoration(gradient: AppColors.splashGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    onTap: onBack,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Profile',
                    style: AppTypography.headingSM(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            // Camera badge intentionally removed until the profile-picture
            // upload API is integrated.
            _Avatar(url: pictureUrl),
            SizedBox(height: AppSpacing.sm),
            Text(name, style: AppTypography.sectionTitle(color: Colors.white)),
            const SizedBox(height: 2),
            Text(
              'Mobile $mobile',
              style: AppTypography.bodyXSmall(
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            if (kycStatus.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              _KycChip(status: kycStatus),
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String? url;

  Widget get _placeholder => Icon(
    Icons.person_rounded,
    color: AppColors.maroonPrimary,
    size: 48,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? _placeholder
          : Image.network(
        url!,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
        progress == null ? child : _placeholder,
        errorBuilder: (_, __, ___) => _placeholder,
      ),
    );
  }
}

class _KycChip extends StatelessWidget {
  const _KycChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
    final verified = s == 'APPROVED';
    final rejected = s == 'REJECTED';

    final label = verified
        ? 'KYC Verified'
        : rejected
        ? 'KYC Rejected'
        : s == 'PENDING' || s == 'SUBMITTED' || s == 'UNDER_REVIEW'
        ? 'KYC Pending'
        : 'KYC Not Verified';

    final IconData icon = verified
        ? Icons.verified_rounded
        : rejected
        ? Icons.error_outline_rounded
        : Icons.schedule_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: verified ? const Color(0xFF7BE495) : Colors.white),
          const SizedBox(width: 5),
          Text(label, style: AppTypography.bodyXSmall(color: Colors.white)),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall(color: AppColors.textMutedLight),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _InvestmentSummaryCard extends StatelessWidget {
  const _InvestmentSummaryCard({
    required this.totalInvestment,
    required this.currentValue,
  });

  final String totalInvestment;
  final String currentValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Total Investment',
                value: totalInvestment,
              ),
            ),
            Container(
              width: 1,
              color: AppColors.borderLight,
              margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            Expanded(
              child: _SummaryItem(
                icon: Icons.show_chart_rounded,
                label: 'Current Value',
                value: currentValue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.infoBlueLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.infoBlue, size: 17),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption(color: AppColors.textMutedLight),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.sectionTitleSM(
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.goldSurfaceLight.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.maroonPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.maroonPrimary, size: 18),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge(
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption(
                        color: AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.maroonPrimary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}