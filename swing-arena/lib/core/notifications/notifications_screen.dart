import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'biz_notifications_repository.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final _notificationsProvider =
    FutureProvider.autoDispose<BizNotificationsPage>((ref) {
  final repo = ref.watch(bizNotificationsRepositoryProvider);
  return repo.fetchNotifications(
    limit: 50,
    types: kArenaOwnerNotificationTypes,
  );
});

final bizUnreadCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(bizNotificationsRepositoryProvider);
  final page = await repo.fetchNotifications(limit: 1);
  return page.unreadCount;
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class BizNotificationsScreen extends ConsumerStatefulWidget {
  const BizNotificationsScreen({super.key});

  @override
  ConsumerState<BizNotificationsScreen> createState() =>
      _BizNotificationsScreenState();
}

class _BizNotificationsScreenState
    extends ConsumerState<BizNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _markingAll = false;
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Set<String> get _currentTypes =>
      _tab.index == 0 ? kBookingNotificationTypes : kMatchupNotificationTypes;

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all notifications?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: const Text(
            'This will permanently delete all notifications. This cannot be undone.',
            style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6E7685))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all',
                style: TextStyle(
                    color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _clearing = true);
    try {
      await ref
          .read(bizNotificationsRepositoryProvider)
          .clearAll(types: _currentTypes);
      ref.invalidate(_notificationsProvider);
      ref.invalidate(bizUnreadCountProvider);
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  Future<void> _markAllRead() async {
    setState(() => _markingAll = true);
    try {
      await ref
          .read(bizNotificationsRepositoryProvider)
          .markAllRead(types: _currentTypes);
      ref.invalidate(_notificationsProvider);
      ref.invalidate(bizUnreadCountProvider);
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  Future<void> _markRead(BizNotificationItem item) async {
    if (item.isRead) return;
    try {
      await ref.read(bizNotificationsRepositoryProvider).markRead(item.id);
      ref.invalidate(_notificationsProvider);
      ref.invalidate(bizUnreadCountProvider);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Notifications',
          style: TextStyle(
              color: Color(0xFF0D1117),
              fontSize: 17,
              fontWeight: FontWeight.w900),
        ),
        actions: [
          async.maybeWhen(
            data: (page) {
              final tabItems = _itemsForTab(page.items);
              final hasUnread = tabItems.any((n) => !n.isRead);
              return hasUnread
                  ? TextButton(
                      onPressed: _markingAll ? null : _markAllRead,
                      child: Text(
                        _markingAll ? 'Marking…' : 'Mark all read',
                        style: const TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  : const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
          async.maybeWhen(
            data: (page) {
              final tabItems = _itemsForTab(page.items);
              return tabItems.isNotEmpty
                  ? IconButton(
                      onPressed: _clearing ? null : _clearAll,
                      icon: _clearing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Color(0xFFDC2626), strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_sweep_rounded,
                              color: Color(0xFFDC2626), size: 22),
                      tooltip: 'Clear all',
                    )
                  : const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: const Color(0xFF059669),
          labelColor: const Color(0xFF059669),
          unselectedLabelColor: const Color(0xFF6E7685),
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Booking'),
            Tab(text: 'Match-Up'),
          ],
        ),
      ),
      body: async.when(
        loading: () => const Center(
            child: CircularProgressIndicator(
                color: Color(0xFF059669), strokeWidth: 2)),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded,
                color: Color(0xFF6E7685), size: 40),
            const SizedBox(height: 12),
            Text('Could not load notifications\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF6E7685),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.invalidate(_notificationsProvider),
              child: const Text('Retry'),
            ),
          ]),
        ),
        data: (page) => TabBarView(
          controller: _tab,
          children: [
            _NotificationList(
              items: _itemsForTab(page.items,
                  types: kBookingNotificationTypes),
              onTap: _markRead,
              onRefresh: () async {
                ref.invalidate(_notificationsProvider);
                await ref.read(_notificationsProvider.future);
              },
              emptyIcon: Icons.calendar_month_rounded,
              emptyTitle: 'No booking notifications',
              emptySubtitle: 'Booking alerts will appear here',
            ),
            _NotificationList(
              items: _itemsForTab(page.items,
                  types: kMatchupNotificationTypes),
              onTap: _markRead,
              onRefresh: () async {
                ref.invalidate(_notificationsProvider);
                await ref.read(_notificationsProvider.future);
              },
              emptyIcon: Icons.sports_cricket_rounded,
              emptyTitle: 'No match-up notifications',
              emptySubtitle: 'Match interest alerts will appear here',
            ),
          ],
        ),
      ),
    );
  }

  List<BizNotificationItem> _itemsForTab(
    List<BizNotificationItem> all, {
    Set<String>? types,
  }) {
    final filter = types ?? _currentTypes;
    return all.where((n) => filter.contains(n.type)).toList();
  }
}

// ─── Per-tab list ─────────────────────────────────────────────────────────────

class _NotificationList extends StatelessWidget {
  const _NotificationList({
    required this.items,
    required this.onTap,
    required this.onRefresh,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final List<BizNotificationItem> items;
  final Future<void> Function(BizNotificationItem) onTap;
  final Future<void> Function() onRefresh;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(emptyIcon, color: const Color(0xFF6E7685), size: 48),
          const SizedBox(height: 14),
          Text(emptyTitle,
              style: const TextStyle(
                  color: Color(0xFF0D1117),
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(emptySubtitle,
              style: const TextStyle(
                  color: Color(0xFF6E7685),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF059669),
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _NotificationCard(
          item: items[i],
          onTap: () => onTap(items[i]),
        ),
      ),
    );
  }
}

// ─── Notification card ────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final BizNotificationItem item;
  final VoidCallback onTap;

  IconData get _icon {
    return switch (item.type) {
      'NEW_BOOKING' => Icons.calendar_month_rounded,
      'BOOKING_CANCELLED' => Icons.event_busy_rounded,
      'BOOKING_UPDATED' => Icons.edit_calendar_rounded,
      'PAYMENT_RECEIVED' => Icons.payments_rounded,
      'mm_interest_expressed' => Icons.bolt_rounded,
      _ => Icons.notifications_rounded,
    };
  }

  Color get _iconColor {
    return switch (item.type) {
      'NEW_BOOKING' => const Color(0xFF059669),
      'BOOKING_CANCELLED' => const Color(0xFFDC2626),
      'PAYMENT_RECEIVED' => const Color(0xFF0EA5E9),
      'mm_interest_expressed' => const Color(0xFFF59E0B),
      _ => const Color(0xFF6E7685),
    };
  }

  Color get _iconBg {
    return switch (item.type) {
      'NEW_BOOKING' => const Color(0xFFD1FAE5),
      'BOOKING_CANCELLED' => const Color(0xFFFEE2E2),
      'PAYMENT_RECEIVED' => const Color(0xFFE0F2FE),
      'mm_interest_expressed' => const Color(0xFFFEF3C7),
      _ => const Color(0xFFF1F5F9),
    };
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTime(item.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead
                ? const Color(0xFFE5E7EB)
                : const Color(0xFF059669).withValues(alpha: 0.25),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: _iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        item.title ?? _defaultTitle(item.type),
                        style: TextStyle(
                            color: const Color(0xFF0D1117),
                            fontSize: 13,
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(timeStr,
                        style: const TextStyle(
                            color: Color(0xFF6E7685),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 3),
                  Text(
                    item.body,
                    style: const TextStyle(
                        color: Color(0xFF6E7685),
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                  color: Color(0xFF059669), shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }

  String _defaultTitle(String type) => switch (type) {
        'NEW_BOOKING' => 'New Booking',
        'BOOKING_CANCELLED' => 'Booking Cancelled',
        'BOOKING_UPDATED' => 'Booking Updated',
        'PAYMENT_RECEIVED' => 'Payment Received',
        'mm_interest_expressed' => 'Match Interest',
        _ => 'Notification',
      };

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(dt);
  }
}
