import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/providers.dart';

class BizNotificationItem {
  const BizNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.entityType,
    this.entityId,
  });

  final String id;
  final String type;
  final String? title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? entityType;
  final String? entityId;

  factory BizNotificationItem.fromJson(Map<String, dynamic> json) {
    return BizNotificationItem(
      id: '${json['id'] ?? ''}',
      type: '${json['type'] ?? 'SYSTEM'}',
      title: _stringOrNull(json['title']),
      body: '${json['body'] ?? ''}',
      isRead: json['isRead'] == true,
      createdAt:
          DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
      entityType: _stringOrNull(json['entityType']),
      entityId: _stringOrNull(json['entityId']),
    );
  }
}

class BizNotificationsPage {
  const BizNotificationsPage({
    required this.items,
    required this.total,
    required this.unreadCount,
    required this.page,
    required this.limit,
  });

  final List<BizNotificationItem> items;
  final int total;
  final int unreadCount;
  final int page;
  final int limit;

  factory BizNotificationsPage.fromJson(Map<String, dynamic> json) {
    final notifications = (json['notifications'] as List? ?? const [])
        .whereType<Map>()
        .map((row) =>
            BizNotificationItem.fromJson(Map<String, dynamic>.from(row)))
        .toList();
    return BizNotificationsPage(
      items: notifications,
      total: _intValue(json['total']),
      unreadCount: _intValue(json['unreadCount']),
      page: _intValue(json['page']).clamp(1, 1 << 30),
      limit: _intValue(json['limit']).clamp(1, 1 << 30),
    );
  }
}

class OneSignalSyncPayload {
  const OneSignalSyncPayload({
    required this.notificationId,
    required this.body,
    this.type,
    this.title,
    this.entityType,
    this.entityId,
    this.data,
  });

  final String notificationId;
  final String? type;
  final String? title;
  final String body;
  final String? entityType;
  final String? entityId;
  final Map<String, dynamic>? data;
}

const Set<String> kArenaOwnerNotificationTypes = {
  'NEW_BOOKING',
  'BOOKING_CANCELLED',
};

class BizNotificationsRepository {
  BizNotificationsRepository(this._dio);

  final Dio _dio;

  Future<BizNotificationsPage> fetchNotifications({
    int page = 1,
    int limit = 12,
    Set<String>? types,
  }) async {
    final allowedTypes =
        types == null || types.isEmpty ? <String>[] : (types.toList()..sort());
    final response = await _dio.get(
      '/notifications',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (allowedTypes.isNotEmpty) 'types': allowedTypes.join(','),
        'audience': 'BIZ_OWNER',
      },
    );
    final payload = _extractMap(response.data);
    final pageData =
        BizNotificationsPage.fromJson(_extractMap(payload['data'] ?? payload));
    return BizNotificationsPage(
      items: pageData.items
          .where((item) =>
              types == null || types.isEmpty || types.contains(item.type))
          .toList(),
      total: pageData.total,
      unreadCount: pageData.unreadCount,
      page: pageData.page,
      limit: pageData.limit,
    );
  }

  Future<void> markRead(String id) async {
    await _dio.post('/notifications/$id/read');
  }

  Future<void> markAllRead({Set<String>? types}) async {
    final allowedTypes =
        types == null || types.isEmpty ? <String>[] : (types.toList()..sort());
    await _dio.post(
      '/notifications/read-all',
      queryParameters: {
        if (allowedTypes.isNotEmpty) 'types': allowedTypes.join(','),
        'audience': 'BIZ_OWNER',
      },
    );
  }

  Future<void> syncOneSignalNotification(OneSignalSyncPayload payload) async {
    final data = <String, dynamic>{
      'notificationId': payload.notificationId,
      'body': payload.body,
      if (payload.type != null) 'type': payload.type,
      if (payload.title != null) 'title': payload.title,
      if (payload.entityType != null) 'entityType': payload.entityType,
      if (payload.entityId != null) 'entityId': payload.entityId,
      if (payload.data != null) 'data': payload.data,
    };
    await _dio.post('/notifications/sync', data: data);
  }

  Map<String, dynamic> _extractMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }
}

final bizNotificationsRepositoryProvider = Provider<BizNotificationsRepository>(
  (ref) => BizNotificationsRepository(ref.watch(dioProvider)),
);

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;

String? _stringOrNull(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}
