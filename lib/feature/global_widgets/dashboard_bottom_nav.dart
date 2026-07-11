import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';

import '../../core/router/route_name.dart';

/// Bottom navigation bar with a raised center action button.
///
/// Layout notes (why this fixes the old overflow):
/// - The bar height and the nav-item content height are both fixed,
///   independent of ScreenUtil's `.sp`/`.w` scaling, so text/icon growth
///   can never exceed the space Row gives each item.
/// - The center button is rendered in a `Stack` positioned *above* the
///   bar (not squeezed inside the Row), with `clipBehavior: Clip.none`,
///   which is what produces the "poking out of a halo" look in the design.
class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _barHeight = 64;
  static const double _centerButtonSize = 56;
  static const double _haloSize = 72;

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteName.dashboard);
      case 1:
        context.go(RouteName.schemes);
      case 2:
        context.go(RouteName.payment);
      case 3:
        context.go(RouteName.goldRates);
      case 4:
        context.go(RouteName.profile);
      default:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Coming soon'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
    }
  }

  void _handleTap(BuildContext context, int index) {
    onTap(index);
    _navigate(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : const Color(0xFFF8F5EC);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // ── Bar ──────────────────────────────────────────────
        Container(
          height: _barHeight + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: currentIndex == 0,
                  onTap: () => _handleTap(context, 0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.card_giftcard_rounded,
                  label: 'Schemes',
                  selected: currentIndex == 1,
                  onTap: () => _handleTap(context, 1),
                ),
              ),
              // Empty gap — the raised center button floats above this.
              const SizedBox(width: _centerButtonSize),
              Expanded(
                child: _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Gold Rate',
                  selected: currentIndex == 3,
                  onTap: () => _handleTap(context, 3),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  selected: currentIndex == 4,
                  onTap: () => _handleTap(context, 4),
                ),
              ),
            ],
          ),
        ),

        // ── Raised center button + halo ─────────────────────
        Positioned(
          top: -_haloSize / 2 + 14,
          child: _CenterAction(
            selected: currentIndex == 2,
            haloColor: bg,
            onTap: () => _handleTap(context, 2),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? AppColors.maroonDark
        : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        // Fixed, unscaled height so ScreenUtil text/icon growth can never
        // overflow the Row's stretched cross-axis space.
        height: DashboardBottomNav._barHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall(color: color).copyWith(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Active indicator line
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: selected ? 1 : 0,
              child: Container(
                width: 18,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAction extends StatelessWidget {
  const _CenterAction({
    required this.selected,
    required this.haloColor,
    required this.onTap,
  });

  final bool selected;
  final Color haloColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: DashboardBottomNav._haloSize,
            height: DashboardBottomNav._haloSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: haloColor, shape: BoxShape.circle),
            child: Container(
              width: DashboardBottomNav._centerButtonSize,
              height: DashboardBottomNav._centerButtonSize,
              decoration: const BoxDecoration(
                gradient: AppColors.splashGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.currency_rupee_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Payments',
            style: AppTypography.labelSmall(
              color: AppColors.mutedGray,
            ).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
