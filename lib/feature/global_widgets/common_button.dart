import 'package:flutter/material.dart';



import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  /// Optional
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  /// Icon
  final IconData? icon;
  final double iconSize;
  final bool iconAfterText;

  /// Styling
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Gradient? gradient;
  final Color textColor;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 52,
    this.padding,
    this.icon,
    this.iconSize = 20,
    this.iconAfterText = false,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.gradient,
    this.textColor = Colors.white,
    this.borderRadius = 12.0,
  });

  bool get _enabled => !isDisabled && onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: InkWell(
        onTap: _enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: gradient == null
                ? (_enabled
                ? backgroundColor ?? AppColors.maroonDark
                : disabledBackgroundColor ?? AppColors.borderStrongLight)
                : null,
            gradient: _enabled ? gradient : null,
          ),
          child: Padding(
            padding: padding ??
                 EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Center(child: _buildContent()),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: AppTypography.buttonLarge(color: textColor),
    );

    if (icon == null) return textWidget;

    final iconWidget = Icon(icon, size: iconSize, color: textColor);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconAfterText
          ? [textWidget,  SizedBox(width: AppSpacing.sm), iconWidget]
          : [iconWidget,  SizedBox(width: AppSpacing.sm), textWidget],
    );
  }
}