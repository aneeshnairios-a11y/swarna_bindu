import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for Gold Scheme app.
/// Uses Noto Sans for Latin content. Noto Serif Malayalam for ML locale.
/// All sizes sourced from the design specification.
abstract class AppTypography {
  // ── Display ───────────────────────────────────────────────────
  static TextStyle displayLarge({Color? color}) => GoogleFonts.notoSans(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: color,
  );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.notoSans(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: color,
  );

  // ── Headings ──────────────────────────────────────────────────
  static TextStyle headingXL({Color? color}) => GoogleFonts.notoSans(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: color,
  );

  static TextStyle headingLG({Color? color}) => GoogleFonts.notoSans(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle headingMD({Color? color}) => GoogleFonts.notoSans(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle headingSM({Color? color}) => GoogleFonts.notoSans(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // ── Section titles ────────────────────────────────────────────
  static TextStyle sectionTitle({Color? color}) => GoogleFonts.notoSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle sectionTitleSM({Color? color}) => GoogleFonts.notoSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // ── Body ──────────────────────────────────────────────────────
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.notoSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: color,
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.notoSans(
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: color,
  );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.notoSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: color,
  );

  static TextStyle bodyXSmall({Color? color}) => GoogleFonts.notoSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: color,
  );

  // ── Labels ────────────────────────────────────────────────────
  static TextStyle labelLarge({Color? color}) => GoogleFonts.notoSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.notoSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.notoSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  // ── Status badges (uppercase with spacing) ───────────────────
  static TextStyle statusBadge({Color? color}) => GoogleFonts.notoSans(
    fontSize: 10.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: color,
  );

  // ── Gold amounts (prominent financial figures) ────────────────
  static TextStyle goldAmount({Color? color}) => GoogleFonts.notoSans(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: color ?? AppColors.primaryGold,
  );

  static TextStyle goldAmountSM({Color? color}) => GoogleFonts.notoSans(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.primaryGold,
  );

  static TextStyle currencyAmount({Color? color}) => GoogleFonts.notoSans(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: color,
  );

  static TextStyle currencyAmountSM({Color? color}) => GoogleFonts.notoSans(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // ── Caption / hint ────────────────────────────────────────────
  static TextStyle caption({Color? color}) => GoogleFonts.notoSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: color,
  );

  static TextStyle hint({Color? color}) => GoogleFonts.notoSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: color,
  );

  // ── Buttons ───────────────────────────────────────────────────
  static TextStyle buttonLarge({Color? color}) => GoogleFonts.notoSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: color,
  );

  static TextStyle buttonMedium({Color? color}) => GoogleFonts.notoSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: color,
  );

  static TextStyle buttonSmall({Color? color}) => GoogleFonts.notoSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: color,
  );

  // ── Malayalam (Noto Serif Malayalam fallback) ─────────────────
  static TextStyle malayalamBody({Color? color}) => TextStyle(
    fontFamily: 'NotoSerifMalayalam',
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: color,
  );

  static TextStyle malayalamHeading({Color? color}) => TextStyle(
    fontFamily: 'NotoSerifMalayalam',
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: color,
  );

  // ── TextTheme for MaterialApp ─────────────────────────────────
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge(),
    displayMedium: displayMedium(),
    headlineLarge: headingLG(),
    headlineMedium: headingMD(),
    headlineSmall: headingSM(),
    titleLarge: sectionTitle(),
    titleMedium: sectionTitleSM(),
    titleSmall: labelLarge(),
    bodyLarge: bodyLarge(),
    bodyMedium: bodySmall(),
    bodySmall: caption(),
    labelLarge: labelLarge(),
    labelMedium: labelMedium(),
    labelSmall: labelSmall(),
  );
}
