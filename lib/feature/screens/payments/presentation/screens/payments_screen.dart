import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gold_scheme/core/formatter/app_formatters.dart';
import 'package:gold_scheme/core/router/route_name.dart';
import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_spacing.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';

import '../../../../global_widgets/dashboard_bottom_nav.dart';

/// Payment landing page matching the supplied reference design.
class PaymentScreen extends StatefulWidget {
   const PaymentScreen({super.key, required this.enrollmentId});

  final String enrollmentId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int navIndex = 1;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFFCF6),
    bottomNavigationBar: DashboardBottomNav(currentIndex: navIndex,  onTap: (i) => setState(() => navIndex = i),),
    body: SafeArea(
      child: Column(
        children: [
          _Header(
            onBack: () => context.canPop()
                ? context.pop()
                : context.go(RouteName.dashboard),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DueAmountCard(
                    onPay: () => context.push(
                      RouteName.paymentCheckoutPath(widget.enrollmentId),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Quick Actions',
                    style: AppTypography.sectionTitleSM(color: Colors.black),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _QuickAction(
                        icon: Icons.description_outlined,
                        tint: const Color(0xFFDDF5E3),
                        iconColor: const Color(0xFF2E9F4B),
                        title: 'View History',
                        subtitle: 'All Payments',
                        onTap: () => _comingSoon(context, 'Payment history'),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      _QuickAction(
                        icon: Icons.file_download_outlined,
                        tint: const Color(0xFFDCEEFF),
                        iconColor: const Color(0xFF1680E8),
                        title: 'Receipts',
                        subtitle: 'Get Your Receipts',
                        onTap: () => _comingSoon(context, 'Receipts'),
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
                  Text(
                    'Your Schemes',
                    style: AppTypography.sectionTitleSM(color: Colors.black),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  const _SchemeCard(),
                  SizedBox(height: AppSpacing.sm),
                  const _SecurityCard(),
                ],
              ),
            ),
          ),

        ],
      ),
    ),

  );

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label will be available soon.')));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      AppSpacing.xs,
      AppSpacing.sm,
      AppSpacing.lg,
      AppSpacing.sm,
    ),
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
  const _DueAmountCard({required this.onPay});
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.maroonDark,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Due Amount',
                    style: AppTypography.labelLarge(color: const Color(0xFFE9D7DD)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.currency(5000),
                    style: AppTypography.goldAmountSM(color: const Color(0xFFEFC744)),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 90,
              height: 76,
              child: _CoinStack(),
            ),
          ],
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
                  '05 Jun 2025',
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: Text(
              'Pay Now',
              style: AppTypography.sectionTitleSM(color: AppColors.maroonDark),
            ),
          ),
        ),
      ],
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
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: tint,
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 1,
                  style: AppTypography.labelSmall(color: Colors.black),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  maxLines: 1,
                  style: AppTypography.bodyXSmall(
                    color: AppColors.mutedGray,
                  ).copyWith(fontSize: 9),
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
  const _SchemeCard();
  @override
  Widget build(BuildContext context) => Container(
    height: 73.h,
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x15000000),
          blurRadius: 7,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 59,
          height: 59,
          decoration: BoxDecoration(
            color: AppColors.darkNavy,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            size: 34,
            color: AppColors.primaryGold,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Swarna Bindu',
                style: AppTypography.labelMedium(color: Colors.black),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Investment',
                          style: AppTypography.bodyXSmall(
                            color: AppColors.mutedGray,
                          ).copyWith(fontSize: 9),
                        ),
                        Text(
                          '₹ 5,000.00',
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
                          style: AppTypography.bodyXSmall(
                            color: AppColors.mutedGray,
                          ).copyWith(fontSize: 9),
                        ),
                        Text(
                          '05 Feb 2025',
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
              color: const Color(0xFFDDF6E4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Active',
              style: AppTypography.bodyXSmall(
                color: const Color(0xFF258B44),
              ).copyWith(fontSize: 10),
            ),
          ),
        ),
      ],
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
          child: Icon(
            Icons.verified_user_outlined,
            color: AppColors.primaryGoldLight,
            size: 29,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Safe & Secure Payments',
                style: AppTypography.labelMedium(color: Colors.black),
              ),
              const SizedBox(height: 2),
              Text(
                'Your Payments Are Encrypted And\n100% Secure With Trusted Partners.',
                style: AppTypography.bodyXSmall(
                  color: AppColors.mutedGray,
                ).copyWith(fontSize: 10, height: 1.25),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CoinStack extends StatelessWidget {
  const _CoinStack();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _CoinStackPainter());
}

class _CoinStackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadow = Paint()..color = const Color(0x55000000);
    final side = Paint()..color = const Color(0xFFB77812);
    final top = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE77B), Color(0xFFD19A25), Color(0xFFFFD966)],
      ).createShader(Offset.zero & size);
    for (final item in [
      (78.0, 72.0, 33.0),
      (57.0, 60.0, 34.0),
      (84.0, 48.0, 35.0),
      (62.0, 36.0, 35.0),
      (39.0, 25.0, 34.0),
    ]) {
      final rect = Rect.fromCenter(
        center: Offset(item.$1, item.$2),
        width: item.$3 * 1.6,
        height: item.$3 * .42,
      );
      canvas.drawOval(rect.shift(const Offset(2, 7)), shadow);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            rect.left,
            rect.center.dy,
            rect.right,
            rect.center.dy + 10,
          ),
          const Radius.circular(8),
        ),
        side,
      );
      canvas.drawOval(rect, top);
      canvas.drawOval(
        rect.deflate(5),
        Paint()
          ..color = const Color(0x55FFF3AE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CoinStackPainter oldDelegate) => false;
}
