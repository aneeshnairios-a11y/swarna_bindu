import 'package:flutter/material.dart';

import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

class QuickAction {
  const QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions
          .map((a) => Expanded(child: _QuickActionItem(action: a)))
          .toList(),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({required this.action});
  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: isDark ? 0.22 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.color),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall(color: labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
