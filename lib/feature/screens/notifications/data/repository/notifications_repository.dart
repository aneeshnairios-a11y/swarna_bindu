import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_result.dart';
import '../models/notification_model.dart';

class NotificationsRepository {
  NotificationsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<NotificationsPageResult>> getNotifications({
    required int page,
    int limit = 15,
  }) {
    return _apiClient.get<NotificationsPageResult>(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'limit': limit},
      parser: (json) =>
          NotificationsPageResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Server only echoes back `{ notification: { _id, isRead } }` on this
  /// call — the caller (Notifier) already has the full item locally and
  /// flips it optimistically, so this just confirms `isRead` came back
  /// true rather than returning a full re-parsed model.
  Future<ApiResult<bool>> markAsRead(String id) {
    return _apiClient.put<bool>(
      ApiEndpoints.markNotificationRead(id),
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final notification = map['notification'] as Map<String, dynamic>?;
        return notification?['isRead'] as bool? ?? true;
      },
    );
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(apiClientProvider));
});