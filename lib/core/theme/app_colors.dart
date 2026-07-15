import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Brand ─────────────────────────────────────────────────────
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color primaryGoldLight = Color(0xFFE8D070);
  static const Color primaryGoldDark = Color(0xFFB8962E);
  static const Color darkNavy = Color(0xFF1A1A2E);
  static const Color darkNavyLight = Color(0xFF252545);
  static const Color darkNavyDeep = Color(0xFF0F0F1A);
  static const Color mutedGray = Color(0xFF757575);

  // ── Backgrounds ───────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F5F0); // Warm White
  static const Color backgroundDark = Color(0xFF0D0D1A);

  // ── Surfaces ──────────────────────────────────────────────────
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceVariantLight = Color(0xFFF3EFE8);
  static const Color surfaceVariantDark = Color(0xFF242438);

  // ── Gold surface (tinted) ─────────────────────────────────────
  static const Color goldSurfaceLight = Color(0xFFFAF3D3);
  static const Color goldSurfaceDark = Color(0xFF2A2410);
  static const Color goldBorderLight = Color(0xFFE8D070);
  static const Color goldBorderDark = Color(0xFF4A3E18);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color successGreen = Color(0xFF27AE60);
  static const Color successGreenLight = Color(0xFFD4EDDA);
  static const Color successGreenDark = Color(0xFF0D3B20);

  static const Color warningOrange = Color(0xFFE67E22);
  static const Color warningOrangeLight = Color(0xFFFDE8CC);
  static const Color warningOrangeDark = Color(0xFF3D2008);

  static const Color errorRed = Color(0xFFC0392B);
  static const Color errorRedLight = Color(0xFFFAD7D3);
  static const Color errorRedDark = Color(0xFF3D0F0A);

  static const Color infoBlue = Color(0xFF2980B9);
  static const Color infoBlueLight = Color(0xFFD3E8F8);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textPrimaryDark = Color(0xFFF0EDE8);
  static const Color textSecondaryLight = Color(0xFF4A4A6A);
  static const Color textSecondaryDark = Color(0xFFB0ADB8);
  static const Color textMutedLight = Color(0xFF757575);
  static const Color textMutedDark = Color(0xFF757585);
  static const Color textOnGold = Color(0xFF1A1A2E); // always dark on gold

  // ── Borders ───────────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE0D8CC);
  static const Color borderDark = Color(0xFF2E2E4A);
  static const Color borderStrongLight = Color(0xFFC8BFAF);
  static const Color borderStrongDark = Color(0xFF3E3E5A);

  // ── Shimmer ───────────────────────────────────────────────────
  static const Color shimmerBaseLight = Color(0xFFE8E4DC);
  static const Color shimmerHighlightLight = Color(0xFFF8F5F0);
  static const Color shimmerBaseDark = Color(0xFF1E1E32);
  static const Color shimmerHighlightDark = Color(0xFF2A2A40);

  // ── Status badge colors ───────────────────────────────────────
  static const Color paidBg = Color(0xFFD4EDDA);
  static const Color paidText = Color(0xFF1A6B36);
  static const Color overdueBg = Color(0xFFFAD7D3);
  static const Color overdueText = Color(0xFF8B1A10);
  static const Color pendingBg = Color(0xFFFDE8CC);
  static const Color pendingText = Color(0xFF8B4A10);
  static const Color verifiedBg = Color(0xFFD4EDDA);
  static const Color verifiedText = Color(0xFF1A6B36);
  static const Color rejectedBg = Color(0xFFFAD7D3);
  static const Color rejectedText = Color(0xFF8B1A10);
  static const Color processingBg = Color(0xFFD3E8F8);
  static const Color processingText = Color(0xFF134E7A);

  // ── Dark mode badge variants ───────────────────────────────────
  static const Color paidBgDark = Color(0xFF0D3B20);
  static const Color paidTextDark = Color(0xFF6FCF97);
  static const Color overdueBgDark = Color(0xFF3D0F0A);
  static const Color overdueTextDark = Color(0xFFEB5757);
  static const Color pendingBgDark = Color(0xFF3D2008);
  static const Color pendingTextDark = Color(0xFFF2994A);
  static const Color processingBgDark = Color(0xFF0A2E42);
  static const Color processingTextDark = Color(0xFF56B4E9);

  // ── Maroon (splash & onboarding accent brand color) ────────────
  static const Color maroonDark = Color(0xFF4B0622);
  static const Color maroonPrimary = Color(0xFF6D1B36);
  static const Color maroonLight = Color(0xFF8B3352);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient splashGradient = LinearGradient(
    colors: [maroonDark, maroonPrimary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFB8962E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGoldGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF2D2D50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldCardGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFE8C84A), Color(0xFFB8962E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmWhiteGradient = LinearGradient(
    colors: [Color(0xFFF8F5F0), Color(0xFFF0EBE0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
