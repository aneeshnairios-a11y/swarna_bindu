import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing constants — use these everywhere for consistent layout.
/// Never hardcode padding/margin values outside this file.
abstract final class AppSpacing {
  static  double get xs => 4.w;
  static  double get sm => 8.w;
  static  double get md => 12.w;
  static  double get lg => 16.0.w;
  static  double get xl => 20.0.w;
  static  double get xxl => 24.0.w;
  static  double get xxxl => 32.0.w;
  static  double get huge => 40.0.w;
  static  double get massive => 48.0.w;

  /// Standard horizontal screens padding
  static  double get screenH => 16.w;

  /// Standard vertical screens padding
  static  double get screenV => 20.h;

  /// Card internal padding
  static const double cardPadding = 16.0;

  /// Gap between list items
  static const double itemGap = 12.0;

  /// Section gap (between two content blocks)
  static const double sectionGap = 24.0;

  /// Bottom nav bar height
  static const double bottomNavHeight = 64.0;

  /// Bottom safe area extra
  static const double bottomSafe = 16.0;

  /// Standard border radius
  static  double get radiusSm => 8.0.r;
  static  double get radiusMd => 12.0.r;
  static  double get radiusLg => 16.0.r;
  static  double get radiusXl => 20.0.r;
  static  double get radiusXxl => 24.0.r;
  static  double get radiusFull => 100.0.r;

  /// Min tap target size (accessibility)
  static const double minTapTarget = 48.0;

  /// Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 72.0;

  /// Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
}