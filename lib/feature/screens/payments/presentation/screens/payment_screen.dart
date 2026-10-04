import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/constants/image_string/image_strings.dart';
import 'package:swarna_bindu/core/formatter/app_formatters.dart';
import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../global_widgets/dashboard_bottom_nav.dart';
import '../data/models/payment_dues_model.dart';
import '../viewmodels/payment_dues_viewmodel.dart';

/// Payment landing page. `enrollmentId` is kept for compatibility with the
/// existing route shape (`/app/pay/:enrollmentId`) but is no longer the
/// only scheme shown — the dues list now covers every scheme the user has,
/// each with its own "Pay" entry point into the checkout flow.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, this.enrollmentId});

  final String? enrollmentId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int navIndex = 2;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(paymentDuesProvider.notifier).loadDues());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentDuesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF6),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: navIndex,
        onTap: (i) => setState(() => navIndex = i),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onBack: () =>
              context.canPop() ? context.pop() : context.go(RouteName.dashboard),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(paymentDuesProvider.notifier).refresh(),
                child: _buildBody(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PaymentDuesState state) {
    if (state.isLoading && state.dues == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isError && state.dues == null) {
      return ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          SizedBox(height: 80.h),
          Center(
            child: Column(
              children: [
                Text(
                  state.errorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall(color: AppColors.mutedGray),
                ),
                SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () => ref.read(paymentDuesProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final dues = state.dues;
    final schemes = dues?.schemes ?? const <DueSchemeModel>[];
    final primaryScheme = dues?.primaryDueScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DueAmountCard(
            nextDueAmount: dues?.nextDueAmount ?? 0,
            nextDueDate: dues?.nextDueDateTime,
            onPay: primaryScheme == null
                ? null
                : () => context.push(
              RouteName.paymentCheckoutPath(primaryScheme.userSchemeId),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text('Quick Actions', style: AppTypography.sectionTitleSM(color: Colors.black)),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _QuickAction(
                icon: Icons.description_outlined,
                tint: const Color(0xFFDDF5E3),
                iconColor: const Color(0xFF2E9F4B),
                title: 'View History',
                subtitle: 'All Payments',
                onTap: () => context.push(RouteName.paymentHistory),
              ),
              SizedBox(width: AppSpacing.sm),
              _QuickAction(
                icon: Icons.file_download_outlined,
                tint: const Color(0xFFDCEEFF),
                iconColor: const Color(0xFF1680E8),
                title: 'Receipts',
                subtitle: 'Get Your Receipts',
                onTap: () => context.push(RouteName.paymentReceipt),
              ),
              SizedBox(width: AppSpacing.sm),
              _QuickAction(
                icon: Icons.calendar_month_outlined,
                tint: const Color(0xFFF0E2FF),
                iconColor: const Color(0xFF9747DC),
                title: 'Upcoming Dues',
                subtitle: 'See Due Schedule',
                onTap: () => _comingSoon(context, 'Upcoming dues'),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Text('Your Schemes', style: AppTypography.sectionTitleSM(color: Colors.black)),
          SizedBox(height: AppSpacing.sm),
          if (schemes.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  'No active schemes yet',
                  style: AppTypography.bodySmall(color: AppColors.mutedGray),
                ),
              ),
            )
          else
            ...schemes.map(
                  (scheme) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: _SchemeCard(
                  scheme: scheme,
                  onPay: () => context.push(
                    RouteName.paymentCheckoutPath(scheme.userSchemeId),
                  ),
                ),
              ),
            ),
          const _SecurityCard(),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label will be available soon.')),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
    child: Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
        ),
        Text('Payments', style: AppTypography.headingSM(color: Colors.black)),
      ],
    ),
  );
}

class _DueAmountCard extends StatelessWidget {
  const _DueAmountCard({
    required this.nextDueAmount,
    required this.nextDueDate,
    required this.onPay,
  });

  final num nextDueAmount;
  final DateTime? nextDueDate;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(color: AppColors.maroonDark),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next Due Amount',
                style: AppTypography.labelLarge(color: const Color(0xFFE9D7DD)),
              ),
              const SizedBox(height: 2),
              Text(
                AppFormatters.currency(nextDueAmount),
                style: AppTypography.goldAmountSM(color: const Color(0xFFEFC744)),
              ),
              const SizedBox(height: 11),
              const Divider(color: Color(0xFF9A4564), height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFF7E9BF),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      size: 17,
                      color: AppColors.maroonDark,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: AppTypography.labelSmall(color: const Color(0xFFE9D7DD)),
                      ),
                      Text(
                        nextDueDate == null ? '—' : AppFormatters.date(nextDueDate!),
                        style: AppTypography.labelMedium(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: onPay,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.maroonDark,
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  ),
                  child: Text(
                    'Pay Now',
                    style: AppTypography.sectionTitleSM(color: AppColors.maroonDark),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: -6,
            right: -20,
            child: Image.asset(
              AppAssetImage.goldCoin,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 94,
          padding: const EdgeInsets.fromLTRB(8, 8, 5, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            boxShadow: const [
              BoxShadow(color: Color(0x12000000), blurRadius: 7, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 19, backgroundColor: tint, child: Icon(icon, color: iconColor, size: 22)),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(title, maxLines: 1, style: AppTypography.labelSmall(color: Colors.black)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  maxLines: 1,
                  style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 9),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SchemeCard extends StatelessWidget {
  const _SchemeCard({required this.scheme, required this.onPay});

  final DueSchemeModel scheme;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [BoxShadow(color: Color(0x15000000), blurRadius: 7, offset: Offset(0, 2))],
    ),
    child: InkWell(
      onTap: onPay,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Container(
              width: 59.w,
              height: 59.h,
              decoration: BoxDecoration(
                color: AppColors.darkNavy,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(AppAssetImage.jewellery),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(scheme.schemeName, style: AppTypography.labelMedium(color: Colors.black)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Investment',
                              style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 9),
                            ),
                            Text(
                              AppFormatters.currencyDecimal(scheme.monthlyInvestment),
                              style: AppTypography.labelMedium(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 27, color: AppColors.borderLight),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Due date',
                              style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 9),
                            ),
                            Text(
                              scheme.nextDueDateTime == null
                                  ? '—'
                                  : AppFormatters.dateShort(scheme.nextDueDateTime!),
                              style: AppTypography.labelMedium(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 1),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.hasPendingDues ? AppColors.overdueBg : const Color(0xFFDDF6E4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  scheme.hasPendingDues ? '${scheme.pendingDuesCount} Due' : scheme.status,
                  style: AppTypography.bodyXSmall(
                    color: scheme.hasPendingDues ? AppColors.overdueText : const Color(0xFF258B44),
                  ).copyWith(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF5E9),
      border: Border.all(color: const Color(0xFFF6DEC1)),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.maroonDark,
          child: Icon(Icons.verified_user_outlined, color: AppColors.primaryGoldLight, size: 29),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Safe & Secure Payments', style: AppTypography.labelMedium(color: Colors.black)),
              const SizedBox(height: 2),
              Text(
                'Your Payments Are Encrypted And\n100% Secure With Trusted Partners.',
                style: AppTypography.bodyXSmall(color: AppColors.mutedGray).copyWith(fontSize: 10, height: 1.25),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}