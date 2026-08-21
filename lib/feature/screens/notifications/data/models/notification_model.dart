/// Single item from `GET /notifications`:
/// ```json
/// {
///   "_id": "6a7035ccece5e6fdea2c5c0b",
///   "title": "Gold Purchase Successful",
///   "message": "You purchased 0.714 g gold successfully.",
///   "type": "GOLD_PURCHASE",
///   "isRead": false
/// }
/// ```
///
/// Note: the server does not currently return a timestamp field for
/// notifications, so there is no "2h ago" / date label to show yet — the
/// UI omits it rather than fabricating one. Add a `createdAt` field here
/// once the backend starts returning it.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationsPagination {
  const NotificationsPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  final int page;
  final int limit;
  final int total;
  final int pages;

  bool get hasMore => page < pages;

  factory NotificationsPagination.fromJson(Map<String, dynamic> json) {
    return NotificationsPagination(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 15,
      total: json['total'] as int? ?? 0,
      pages: json['pages'] as int? ?? 1,
    );
  }
}

/// Combined parse result for one page of `GET /notifications`.
class NotificationsPageResult {
  const NotificationsPageResult({
    required this.notifications,
    required this.pagination,
  });

  final List<NotificationModel> notifications;
  final NotificationsPagination pagination;

  factory NotificationsPageResult.fromJson(Map<String, dynamic> json) {
    final list = (json['notifications'] as List<dynamic>? ?? [])
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return NotificationsPageResult(
      notifications: list,
      pagination: NotificationsPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}