import 'package:flutter/material.dart';

import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.body,
    required this.timeLabel,
  });

  final String title;
  final String body;
  final String timeLabel;
}

/// Phase 1 mock data — replace with `GET /notifications` in Phase 2.
final _mockNotifications = <_NotificationItem>[
  _NotificationItem(
    title: 'Gold Redemption Successful',
    body: 'Your Redemption Request Of 5.000 G Gold Has Been Confirmed.',
    timeLabel: 'Today, 09:30 AM',
  ),
  _NotificationItem(
    title: 'Gold Purchase Successful',
    body: 'You Have Purchased 2.000 G Gold Successfully.',
    timeLabel: 'Yesterday, 03:20 PM',
  ),
];

/// Shown when the customer taps the notification bell on the dashboard.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final cardBg = isDark
        ? AppColors.goldSurfaceDark
        : AppColors.goldSurfaceLight;
    final cardBorder = isDark
        ? AppColors.goldBorderDark
        : AppColors.goldBorderLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: textColor,
                        size: AppSpacing.iconLg,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Notification',
                    style: AppTypography.headingSM(color: textColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _mockNotifications.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications yet',
                        style: AppTypography.bodySmall(color: mutedColor),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      itemCount: _mockNotifications.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) {
                        final n = _mockNotifications[i];
                        return Container(
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: cardBg.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                            border: Border.all(
                              color: cardBorder.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      style: AppTypography.labelLarge(
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      n.body,
                                      style: AppTypography.caption(
                                        color: mutedColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                n.timeLabel,
                                style: AppTypography.caption(color: mutedColor),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
