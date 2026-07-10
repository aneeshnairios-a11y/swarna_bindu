import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

abstract class AppTheme {
  // ── Light theme ───────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardTheme: _cardTheme(AppColors.surfaceLight, AppColors.borderLight),
    appBarTheme: _appBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimaryLight,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    bottomNavigationBarTheme: _bottomNavTheme(
      backgroundColor: AppColors.surfaceLight,
      selectedColor: AppColors.primaryGold,
      unselectedColor: AppColors.textMutedLight,
    ),
    inputDecorationTheme: _inputTheme(
      fillColor: AppColors.surfaceLight,
      borderColor: AppColors.borderLight,
      focusBorderColor: AppColors.primaryGold,
      labelColor: AppColors.textMutedLight,
    ),
    elevatedButtonTheme: _elevatedButtonTheme(),
    outlinedButtonTheme: _outlinedButtonTheme(),
    textButtonTheme: _textButtonTheme(),
    chipTheme: _chipTheme(AppColors.surfaceVariantLight),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
      space: 0,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding:  EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),
    switchTheme: _switchTheme(),
    checkboxTheme: _checkboxTheme(),
    radioTheme: _radioTheme(),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryGold,
      linearTrackColor: AppColors.borderLight,
    ),
    snackBarTheme: _snackBarTheme(),
    dialogTheme: _dialogTheme(AppColors.surfaceLight),
    bottomSheetTheme: _bottomSheetTheme(AppColors.surfaceLight),
    extensions: const [AppThemeExtension.light],
  );

  // ── Dark theme ────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardTheme: _cardTheme(AppColors.surfaceDark, AppColors.borderDark),
    appBarTheme: _appBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    bottomNavigationBarTheme: _bottomNavTheme(
      backgroundColor: AppColors.surfaceDark,
      selectedColor: AppColors.primaryGold,
      unselectedColor: AppColors.textMutedDark,
    ),
    inputDecorationTheme: _inputTheme(
      fillColor: AppColors.surfaceVariantDark,
      borderColor: AppColors.borderDark,
      focusBorderColor: AppColors.primaryGold,
      labelColor: AppColors.textMutedDark,
    ),
    elevatedButtonTheme: _elevatedButtonTheme(),
    outlinedButtonTheme: _outlinedButtonTheme(),
    textButtonTheme: _textButtonTheme(),
    chipTheme: _chipTheme(AppColors.surfaceVariantDark),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderDark,
      thickness: 1,
      space: 0,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding:  EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),
    switchTheme: _switchTheme(),
    checkboxTheme: _checkboxTheme(),
    radioTheme: _radioTheme(),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryGold,
      linearTrackColor: AppColors.borderDark,
    ),
    snackBarTheme: _snackBarTheme(),
    dialogTheme: _dialogTheme(AppColors.surfaceDark),
    bottomSheetTheme: _bottomSheetTheme(AppColors.surfaceDark),
    extensions: const [AppThemeExtension.dark],
  );

  // ── Color schemes ─────────────────────────────────────────────
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryGold,
    onPrimary: AppColors.textOnGold,
    secondary: AppColors.darkNavy,
    onSecondary: Colors.white,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    error: AppColors.errorRed,
    onError: Colors.white,
    outline: AppColors.borderLight,
    surfaceContainerHighest: AppColors.surfaceVariantLight,
    onSurfaceVariant: AppColors.textSecondaryLight,
    primaryContainer: AppColors.goldSurfaceLight,
    onPrimaryContainer: AppColors.primaryGoldDark,
    secondaryContainer: AppColors.darkNavyLight,
    onSecondaryContainer: Colors.white,
    tertiary: AppColors.successGreen,
    onTertiary: Colors.white,
    errorContainer: AppColors.errorRedLight,
    onErrorContainer: AppColors.errorRed,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryGold,
    onPrimary: AppColors.textOnGold,
    secondary: AppColors.primaryGoldLight,
    onSecondary: AppColors.darkNavyDeep,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    error: AppColors.errorRed,
    onError: Colors.white,
    outline: AppColors.borderDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    primaryContainer: AppColors.goldSurfaceDark,
    onPrimaryContainer: AppColors.primaryGoldLight,
    secondaryContainer: AppColors.darkNavyLight,
    onSecondaryContainer: AppColors.textPrimaryDark,
    tertiary: AppColors.successGreen,
    onTertiary: Colors.white,
    errorContainer: AppColors.errorRedDark,
    onErrorContainer: AppColors.errorRed,
  );

  // ── Component themes ──────────────────────────────────────────
  static CardThemeData _cardTheme(Color color, Color border) => CardThemeData(
    color: color,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      side: BorderSide(color: border, width: 1),
    ),
    margin: EdgeInsets.zero,
  );

  static AppBarTheme _appBarTheme({
    required Color backgroundColor,
    required Color foregroundColor,
    required SystemUiOverlayStyle systemOverlayStyle,
  }) =>
      AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.sectionTitle(color: foregroundColor),
        iconTheme: IconThemeData(color: foregroundColor, size: AppSpacing.iconLg),
        systemOverlayStyle: systemOverlayStyle,
      );

  static BottomNavigationBarThemeData _bottomNavTheme({
    required Color backgroundColor,
    required Color selectedColor,
    required Color unselectedColor,
  }) =>
      BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.labelSmall(),
        unselectedLabelStyle: AppTypography.labelSmall(),
      );

  static InputDecorationTheme _inputTheme({
    required Color fillColor,
    required Color borderColor,
    required Color focusBorderColor,
    required Color labelColor,
  }) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fillColor,
        contentPadding:  EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: focusBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        labelStyle: AppTypography.bodySmall(color: labelColor),
        hintStyle: AppTypography.bodySmall(color: labelColor),
        errorStyle: AppTypography.caption(color: AppColors.errorRed),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.textOnGold,
          disabledBackgroundColor: AppColors.primaryGold.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.textOnGold.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.buttonLarge(),
          padding:  EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
          side: const BorderSide(color: AppColors.primaryGold),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.buttonLarge(),
          padding:  EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
      );

  static TextButtonThemeData _textButtonTheme() => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryGold,
      textStyle: AppTypography.buttonMedium(),
      minimumSize: const Size(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
    ),
  );

  static ChipThemeData _chipTheme(Color backgroundColor) => ChipThemeData(
    backgroundColor: backgroundColor,
    labelStyle: AppTypography.labelSmall(),
    padding:  EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
    ),
  );

  static SwitchThemeData _switchTheme() => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
          ? AppColors.primaryGold
          : Colors.white,
    ),
    trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
          ? AppColors.primaryGold.withValues(alpha: 0.5)
          : AppColors.mutedGray.withValues(alpha: 0.3),
    ),
  );

  static CheckboxThemeData _checkboxTheme() => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
          ? AppColors.primaryGold
          : Colors.transparent,
    ),
    checkColor: WidgetStateProperty.all(AppColors.textOnGold),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );

  static RadioThemeData _radioTheme() => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
          ? AppColors.primaryGold
          : AppColors.mutedGray,
    ),
  );

  static SnackBarThemeData _snackBarTheme() => SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    ),
    contentTextStyle: AppTypography.bodySmall(color: Colors.white),
    actionTextColor: AppColors.primaryGold,
  );

  static DialogThemeData _dialogTheme(Color backgroundColor) => DialogThemeData(
    backgroundColor: backgroundColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
    ),
    titleTextStyle: AppTypography.headingSM(),
    contentTextStyle: AppTypography.bodySmall(),
  );

  static BottomSheetThemeData _bottomSheetTheme(Color backgroundColor) =>
      BottomSheetThemeData(
        backgroundColor: backgroundColor,
        elevation: 0,
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXxl),
          ),
        ),
      );
}

// ── Theme extension for custom tokens ─────────────────────────────
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.goldSurface,
    required this.goldBorder,
    required this.cardBorder,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  static const AppThemeExtension light = AppThemeExtension(
    goldSurface: AppColors.goldSurfaceLight,
    goldBorder: AppColors.goldBorderLight,
    cardBorder: AppColors.borderLight,
    shimmerBase: AppColors.shimmerBaseLight,
    shimmerHighlight: AppColors.shimmerHighlightLight,
  );

  static const AppThemeExtension dark = AppThemeExtension(
    goldSurface: AppColors.goldSurfaceDark,
    goldBorder: AppColors.goldBorderDark,
    cardBorder: AppColors.borderDark,
    shimmerBase: AppColors.shimmerBaseDark,
    shimmerHighlight: AppColors.shimmerHighlightDark,
  );

  final Color goldSurface;
  final Color goldBorder;
  final Color cardBorder;
  final Color shimmerBase;
  final Color shimmerHighlight;

  @override
  AppThemeExtension copyWith({
    Color? goldSurface,
    Color? goldBorder,
    Color? cardBorder,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) =>
      AppThemeExtension(
        goldSurface: goldSurface ?? this.goldSurface,
        goldBorder: goldBorder ?? this.goldBorder,
        cardBorder: cardBorder ?? this.cardBorder,
        shimmerBase: shimmerBase ?? this.shimmerBase,
        shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      );

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      goldSurface: Color.lerp(goldSurface, other.goldSurface, t)!,
      goldBorder: Color.lerp(goldBorder, other.goldBorder, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

// Convenience getter — used inside widgets
final Color mutedGray = AppColors.mutedGray;
extension on AppColors {
  static const Color mutedGray = Color(0xFF757575);
}

// Expose muted gray at top level for use in AppTheme class
extension AppColorsMutedGray on AppColors {
  static Color get mutedGray => const Color(0xFF757575);
}