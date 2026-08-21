import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification_model.dart';
import '../../data/repository/notifications_repository.dart';

class NotificationsState {
  const NotificationsState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<NotificationModel> items;
  final int page;
  final bool hasMore;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  /// True only on a first-load failure with nothing to show yet — a
  /// failed loadMore() keeps the existing list visible instead of
  /// blanking the screen (see NotificationsNotifier.loadMore).
  bool get hasBlockingError => errorMessage != null && items.isEmpty;

  NotificationsState copyWith({
    List<NotificationModel>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}

/// Plain autoDispose Notifier (no family/generator — same rationale as
/// GoldRateNotifier / SchemeDetailNotifier). Always starts empty and is
/// driven by explicit method calls from the screen, never provider args.
class NotificationsNotifier extends Notifier<NotificationsState> {
  static const _pageSize = 15;

  @override
  NotificationsState build() => const NotificationsState();

  /// Fresh fetch from page 1 — called once on screen open. Never trusts
  /// whatever was loaded in a previous visit, same convention as
  /// MySchemesScreen.
  Future<void> loadInitial() async {
    state = state.copyWith(isLoadingInitial: true, errorMessage: null);

    final result = await ref
        .read(notificationsRepositoryProvider)
        .getNotifications(page: 1, limit: _pageSize);

    result.when(
      success: (page) {
        state = state.copyWith(
          items: page.notifications,
          page: 1,
          hasMore: page.pagination.hasMore,
          isLoadingInitial: false,
        );
      },
      failure: (e) {
        state = state.copyWith(
          isLoadingInitial: false,
          errorMessage: e.message,
        );
      },
    );
  }

  /// Appends the next page. Guarded so a fast-scrolling user can't fire
  /// duplicate requests, and so it's a no-op once the server says there's
  /// nothing left.
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoadingInitial || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final result = await ref
        .read(notificationsRepositoryProvider)
        .getNotifications(page: nextPage, limit: _pageSize);

    result.when(
      success: (page) {
        state = state.copyWith(
          items: [...state.items, ...page.notifications],
          page: nextPage,
          hasMore: page.pagination.hasMore,
          isLoadingMore: false,
        );
      },
      failure: (e) {
        // Keep the existing list on screen; just stop the spinner. The
        // user can retry by scrolling again (hasMore stays true).
        state = state.copyWith(isLoadingMore: false, errorMessage: e.message);
      },
    );
  }

  /// Optimistically flips the item locally so the tap feels instant,
  /// then confirms with the server; reverts on failure.
  Future<void> markAsRead(String id) async {
    final index = state.items.indexWhere((n) => n.id == id);
    if (index == -1 || state.items[index].isRead) return;

    final original = state.items[index];
    final optimistic = [...state.items];
    optimistic[index] = original.copyWith(isRead: true);
    state = state.copyWith(items: optimistic);

    final result = await ref.read(notificationsRepositoryProvider).markAsRead(id);

    result.when(
      success: (_) {}, // already applied optimistically
      failure: (_) {
        final reverted = [...state.items];
        final currentIndex = reverted.indexWhere((n) => n.id == id);
        if (currentIndex != -1) {
          reverted[currentIndex] = original;
          state = state.copyWith(items: reverted);
        }
      },
    );
  }
}

final notificationsProvider =
NotifierProvider.autoDispose<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);