import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../data/models/notification_model.dart';
import '../viewmodels/notifications_viewmodel.dart';

/// Shown when the customer taps the notification bell on the dashboard.
/// Backed by `GET /notifications` (infinite scroll) and
/// `PUT /notifications/:id/read`.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationsProvider.notifier).loadInitial());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger the next page a bit before the actual bottom so it feels
    // seamless rather than showing a spinner-then-wait at the edge.
    const threshold = 200.0;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

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
            Expanded(child: _buildBody(state, textColor, mutedColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(NotificationsState state, Color textColor, Color mutedColor) {
    if (state.isLoadingInitial && state.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      );
    }

    if (state.hasBlockingError) {
      return _ErrorState(
        message: state.errorMessage!,
        onRetry: () => ref.read(notificationsProvider.notifier).loadInitial(),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Text(
          'No notifications yet',
          style: AppTypography.bodySmall(color: mutedColor),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryGold,
      onRefresh: () => ref.read(notificationsProvider.notifier).loadInitial(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.lg),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) {
          if (i >= state.items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
            );
          }

          final n = state.items[i];
          return _NotificationTile(
            notification: n,
            textColor: textColor,
            mutedColor: mutedColor,
            onTap: () => ref.read(notificationsProvider.notifier).markAsRead(n.id),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.textColor,
    required this.mutedColor,
    required this.onTap,
  });

  final NotificationModel notification;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onTap;

  IconData get _icon {
    switch (notification.type) {
      case 'GOLD_PURCHASE':
        return Icons.paid_rounded;
      case 'GOLD_REDEMPTION':
        return Icons.redeem_rounded;
      case 'PAYMENT_REMINDER':
        return Icons.notifications_active_rounded;
      case 'KYC':
        return Icons.badge_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.goldSurfaceDark : AppColors.goldSurfaceLight;
    final cardBorder = isDark ? AppColors.goldBorderDark : AppColors.goldBorderLight;
    final isRead = notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isRead
              ? cardBg.withValues(alpha: 0.2)
              : cardBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: cardBorder.withValues(alpha: isRead ? 0.3 : 0.6),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon, size: AppSpacing.iconMd, color: AppColors.primaryGoldDark),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTypography.labelLarge(color: textColor).copyWith(
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTypography.caption(color: mutedColor),
                  ),
                ],
              ),
            ),
            if (!isRead) ...[
              SizedBox(width: AppSpacing.sm),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGold,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: AppSpacing.iconXl),
            SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(color: AppColors.errorRed),
            ),
            SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.errorRed),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}