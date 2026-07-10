import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_spacing.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';

/// Standard text input used across the app.
/// Relies on the global `InputDecorationTheme` (see AppTheme) for
/// fill/border colors, so it stays consistent in light & dark mode
/// without re-declaring decoration here.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.isRequired = false,
    this.autovalidateMode,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: AppTypography.labelMedium(color: labelColor),
              children: isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: AppTypography.labelMedium(color: AppColors.errorRed),
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          inputFormatters: inputFormatters,
          autovalidateMode: autovalidateMode,
          style: AppTypography.bodySmall(color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            counterText: '',
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: AppSpacing.iconMd, color: AppColors.mutedGray) : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// Standard dropdown field, styled to match [AppTextField].
/// Generic over [T] so it can be used for gender, district, state, etc.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    this.hintText,
    this.prefixIcon,
    this.isRequired = false,
    this.onChanged,
    this.validator,
  });

  final String? label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final String? hintText;
  final IconData? prefixIcon;
  final bool isRequired;
  final void Function(T? value)? onChanged;
  final String? Function(T? value)? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: AppTypography.labelMedium(color: labelColor),
              children: isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: AppTypography.labelMedium(color: AppColors.errorRed),
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.mutedGray),
          style: AppTypography.bodySmall(color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: AppSpacing.iconMd, color: AppColors.mutedGray) : null,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(itemLabel(e), overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
