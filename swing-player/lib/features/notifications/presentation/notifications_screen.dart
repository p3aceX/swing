import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.entityType,
    required this.entityId,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String? entityType;
  final String? entityId;
  final DateTime createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    String s(String k) => (j[k] ?? '').toString().trim();
    return AppNotification(
      id: s('id'),
      type: s('type'),
      title: s('title'),
      body: s('body'),
      isRead: j['isRead'] == true,
      entityType: j['entityType']?.toString().trim(),
      entityId: j['entityId']?.toString().trim(),
      createdAt:
          (DateTime.tryParse(s('createdAt')) ?? DateTime.now()).toLocal(),
    );
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

const _playerNotificationTypes = {
  'BOOKING_CONFIRMED',
  'BOOKING_CANCELLED',
  'CHAT_MESSAGE',
  'NEW_FOLLOWER',
  'TOURNAMENT_UPDATE',
  'MATCH_LIVE',
};

final notificationSummaryProvider =
    FutureProvider.autoDispose<int>((ref) async {
  try {
    final res = await ApiClient.instance.dio.get(
      ApiEndpoints.notificationsSummary,
      queryParameters: {'types': _playerNotificationTypes.join(',')},
    );
    final body = res.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'] ?? body;
      return (data['unreadCount'] as num? ?? 0).toInt();
    }
    return 0;
  } catch (_) {
    return 0;
  }
});

final notificationsProvider = StateNotifierProvider.autoDispose<
    _NotificationsNotifier, _NotificationsState>(
  (_) => _NotificationsNotifier(),
);

class _NotificationsState {
  const _NotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.isMarkingAll = false,
    this.error,
  });
  final List<AppNotification> items;
  final bool isLoading;
  final bool isMarkingAll;
  final String? error;

  _NotificationsState copyWith({
    List<AppNotification>? items,
    bool? isLoading,
    bool? isMarkingAll,
    String? error,
  }) =>
      _NotificationsState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isMarkingAll: isMarkingAll ?? this.isMarkingAll,
        error: error,
      );
}

class _NotificationsNotifier extends StateNotifier<_NotificationsState> {
  _NotificationsNotifier() : super(const _NotificationsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiClient.instance.dio.get(
        ApiEndpoints.notifications,
        queryParameters: {
          'page': 1,
          'limit': 50,
          'types': _playerNotificationTypes.join(','),
        },
      );
      final body = res.data;
      List<dynamic> raw = [];
      if (body is Map<String, dynamic>) {
        final d = body['data'];
        if (d is List) {
          raw = d;
        } else if (d is Map<String, dynamic>) {
          final inner = d['data'] ?? d['items'] ?? [];
          if (inner is List) raw = inner;
        }
      } else if (body is List) {
        raw = body;
      }
      final items = raw
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markRead(String id) async {
    // Optimistic
    state = state.copyWith(
      items: state.items
          .map((n) => n.id == id
              ? AppNotification(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  body: n.body,
                  isRead: true,
                  entityType: n.entityType,
                  entityId: n.entityId,
                  createdAt: n.createdAt)
              : n)
          .toList(),
    );
    try {
      await ApiClient.instance.dio.post(ApiEndpoints.notificationRead(id));
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    state = state.copyWith(isMarkingAll: true);
    try {
      await ApiClient.instance.dio.post(
        ApiEndpoints.notificationsReadAll,
        queryParameters: {'types': _playerNotificationTypes.join(',')},
      );
      state = state.copyWith(
        isMarkingAll: false,
        items: state.items
            .map((n) => AppNotification(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                isRead: true,
                entityType: n.entityType,
                entityId: n.entityId,
                createdAt: n.createdAt))
            .toList(),
      );
    } catch (_) {
      state = state.copyWith(isMarkingAll: false);
    }
  }
}

// ─── Notification Bell Badge (used in home header) ────────────────────────────

class NotificationBellBadge extends ConsumerWidget {
  const NotificationBellBadge({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(notificationSummaryProvider);
    final unread = countAsync.valueOrNull ?? 0;

    return Tooltip(
      message: 'Alerts',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.notifications_outlined,
                  color: context.fgSub, size: 20),
              if (unread > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Notifications Screen ─────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _onTap(BuildContext context, WidgetRef ref, AppNotification n) {
    if (!n.isRead) ref.read(notificationsProvider.notifier).markRead(n.id);
    final type = n.entityType?.toUpperCase();
    final id = n.entityId;
    if (id == null || id.isEmpty) return;
    switch (type) {
      case 'MATCH':
        context.push('/match/$id');
      case 'PLAYER':
        context.push('/player/$id');
      case 'TOURNAMENT':
        context.push('/tournament/$id');
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final hasUnread = state.items.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Notifications',
          style: TextStyle(
              color: context.fg, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.fg, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: state.isMarkingAll ? null : notifier.markAllRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                    color: context.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: Builder(builder: (context) {
        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 40, color: context.fgSub),
                const SizedBox(height: 12),
                Text('Could not load notifications',
                    style: TextStyle(color: context.fgSub)),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: notifier.load, child: const Text('Retry')),
              ],
            ),
          );
        }
        if (state.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none_rounded,
                    size: 52, color: context.fgSub),
                const SizedBox(height: 12),
                Text('No notifications yet',
                    style: TextStyle(color: context.fgSub, fontSize: 14)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: notifier.load,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: context.stroke),
            itemBuilder: (_, i) {
              final n = state.items[i];
              return _NotificationTile(
                notification: n,
                onTap: () => _onTap(context, ref, n),
              );
            },
          ),
        );
      }),
    );
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  IconData _iconFor(String? type) {
    switch (type?.toUpperCase()) {
      case 'MATCH':
        return Icons.sports_cricket_rounded;
      case 'TOURNAMENT':
        return Icons.emoji_events_rounded;
      case 'PLAYER':
        return Icons.person_rounded;
      case 'CHAT_CONVERSATION':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread
            ? context.accent.withValues(alpha: 0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.cardBg,
                shape: BoxShape.circle,
                border: unread
                    ? Border.all(color: context.accent, width: 1.5)
                    : null,
              ),
              child: Icon(
                _iconFor(notification.entityType),
                color: unread ? context.accent : context.fgSub,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 13,
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: TextStyle(color: context.fgSub, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: TextStyle(
                        color: context.fgSub.withValues(alpha: 0.6),
                        fontSize: 11),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                margin: const EdgeInsets.only(top: 4, left: 8),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: context.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
