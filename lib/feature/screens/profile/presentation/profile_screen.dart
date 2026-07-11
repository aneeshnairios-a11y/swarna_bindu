import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/formatter/app_formatters.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../core/router/route_name.dart';
import '../../../global_widgets/dashboard_bottom_nav.dart';

/// Profile screen — maroon hero (avatar, name, mobile), an investment
/// summary that overlaps the hero, and a "General" settings list.
///
/// Phase 1: static placeholder data. In Phase 2, hydrate from
/// `GET /users/:id` via a Riverpod AsyncNotifier.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _navIndex = 4;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHero(
              name: 'John Mathew',
              mobile: '+91 9876543210',
              onBack: () => context.go(RouteName.dashboard),
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _InvestmentSummaryCard(
                  totalInvestment: 245000,
                  currentValue: 265540,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('General', style: AppTypography.sectionTitleSM(color: AppColors.textPrimaryLight)),
                  SizedBox(height: AppSpacing.sm),
                  _SettingsRow(
                    icon: Icons.flag_rounded,
                    title: 'My Scheme',
                    subtitle: 'Learn About Our Schemes',
                    onTap: () {},
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
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
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
  const _ProfileHero({required this.name, required this.mobile, required this.onBack});

  final String name;
  final String mobile;
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
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    onTap: onBack,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text('Profile', style: AppTypography.headingSM(color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.person_rounded, color: AppColors.maroonPrimary, size: 48),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.maroonPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(name, style: AppTypography.sectionTitle(color: Colors.white)),
            SizedBox(height: 2),
            Text('Mobile $mobile', style: AppTypography.bodyXSmall(color: Colors.white.withValues(alpha: 0.75))),
          ],
        ),
      ),
    );
  }
}

class _InvestmentSummaryCard extends StatelessWidget {
  const _InvestmentSummaryCard({required this.totalInvestment, required this.currentValue});

  final double totalInvestment;
  final double currentValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Total Investment',
                value: AppFormatters.currency(totalInvestment),
              ),
            ),
            Container(width: 1, color: AppColors.borderLight, margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm)),
            Expanded(
              child: _SummaryItem(
                icon: Icons.show_chart_rounded,
                label: 'Current Value',
                value: AppFormatters.currency(currentValue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.icon, required this.label, required this.value});

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
          decoration: BoxDecoration(color: AppColors.infoBlueLight, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.infoBlue, size: 17),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption(color: AppColors.textMutedLight)),
              Text(value, style: AppTypography.sectionTitleSM(color: AppColors.textPrimaryLight)),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.goldSurfaceLight.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
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
                    Text(title, style: AppTypography.labelLarge(color: AppColors.textPrimaryLight)),
                    SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.caption(color: AppColors.textMutedLight)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}