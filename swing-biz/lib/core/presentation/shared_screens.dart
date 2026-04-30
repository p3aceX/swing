import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/session_controller.dart';
import '../router/app_router.dart';

const _bg = Color(0xFF101418);
const _card = Color(0xFF1B2229);
const _border = Color(0xFF2A3540);
const _text = Color(0xFFFFFFFF);
const _muted = Color(0xFFB7C1CC);
const _success = Color(0xFF22C55E);
const _error = Color(0xFFEF4444);
const _accent = Color(0xFF38BDF8);

class AppNotificationItem {
  const AppNotificationItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.unread,
    required this.actionLabel,
  });

  final String type;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final bool unread;
  final String actionLabel;
}

class SearchResultItem {
  const SearchResultItem({
    required this.section,
    required this.title,
    required this.meta,
    required this.route,
    required this.icon,
  });

  final String section;
  final String title;
  final String meta;
  final String route;
  final IconData icon;
}

const _notifications = [
  AppNotificationItem(
    type: 'Payments',
    title: 'Payment received from Arjun',
    subtitle: 'Rs 2,000 paid for March batch',
    time: '2 hours ago',
    icon: Icons.payments_rounded,
    unread: true,
    actionLabel: 'View Receipt',
  ),
  AppNotificationItem(
    type: 'Sessions',
    title: 'Session reminder',
    subtitle: 'Batch A1 starts at 6:00 PM',
    time: '4 hours ago',
    icon: Icons.event_available_rounded,
    unread: true,
    actionLabel: 'View Session',
  ),
  AppNotificationItem(
    type: 'Alerts',
    title: 'Maintenance slot blocked',
    subtitle: 'Football Ground blocked for evening maintenance',
    time: 'Yesterday',
    icon: Icons.warning_amber_rounded,
    unread: false,
    actionLabel: 'View Details',
  ),
  AppNotificationItem(
    type: 'Updates',
    title: 'System update available',
    subtitle: 'New booking and attendance improvements are ready',
    time: '2 days ago',
    icon: Icons.system_update_alt_rounded,
    unread: false,
    actionLabel: 'Review Update',
  ),
];

final _ownerSearchResults = [
  SearchResultItem(
    section: 'Players',
    title: 'Arjun Sharma',
    meta: 'Batch A1 • Pending fee',
    route: AppRoutes.students,
    icon: Icons.groups_rounded,
  ),
  SearchResultItem(
    section: 'Coaches',
    title: 'Rohit Mehta',
    meta: 'Cricket • Active',
    route: AppRoutes.coaches,
    icon: Icons.sports_rounded,
  ),
  SearchResultItem(
    section: 'Batches',
    title: 'Cricket Beginner A1',
    meta: '12/15 players',
    route: AppRoutes.batches,
    icon: Icons.calendar_month_rounded,
  ),
];

final _coachSearchResults = [
  SearchResultItem(
    section: 'Students',
    title: 'Aarav Sharma',
    meta: 'Batch A1 • 95% attendance',
    route: AppRoutes.coachStudents,
    icon: Icons.groups_rounded,
  ),
  SearchResultItem(
    section: 'Sessions',
    title: 'Batch A1 Evening Session',
    meta: 'Today • 6:00 PM',
    route: AppRoutes.coachSessions,
    icon: Icons.event_rounded,
  ),
  SearchResultItem(
    section: 'Training Plans',
    title: 'Cricket Foundation Build',
    meta: '8 weeks • Active',
    route: AppRoutes.coachTraining,
    icon: Icons.fitness_center_rounded,
  ),
];

final _arenaSearchResults = [
  SearchResultItem(
    section: 'Bookings',
    title: 'Rahul Verma',
    meta: 'Turf Field 1 • 6:00 PM',
    route: AppRoutes.arenaProfile,
    icon: Icons.book_online_rounded,
  ),
  SearchResultItem(
    section: 'Courts',
    title: 'Turf Field 1',
    meta: 'Active • Rs 500/hour',
    route: AppRoutes.arenaProfile,
    icon: Icons.stadium_rounded,
  ),
  SearchResultItem(
    section: 'Slots',
    title: 'Football Ground 8:00 PM',
    meta: 'Blocked • Maintenance',
    route: AppRoutes.arenaProfile,
    icon: Icons.schedule_rounded,
  ),
];

class NotificationsHubScreen extends StatelessWidget {
  const NotificationsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((item) => item.unread).toList();
    return DefaultTabController(
      length: 3,
      child: _SharedScaffold(
        title: 'Notifications',
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.sharedNotificationPrefs),
            child: const Text('Preferences'),
          ),
        ],
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'Unread'),
            Tab(text: 'All'),
            Tab(text: 'By Type'),
          ],
        ),
        child: TabBarView(
          children: [
            _NotificationList(items: unread),
            _NotificationList(items: _notifications),
            ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _TypeGroup(type: 'Sessions'),
                _TypeGroup(type: 'Payments'),
                _TypeGroup(type: 'Updates'),
                _TypeGroup(type: 'Alerts'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SharedScaffold(
      title: 'Notification Preferences',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle('Notification Categories'),
                SizedBox(height: 12),
                _ToggleRow('Session Reminders', true),
                _ToggleRow('Payment Notifications', true),
                _ToggleRow('Student Updates', true),
                _ToggleRow('Team Messages', true),
                _ToggleRow('System Alerts', true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle('Delivery Method'),
                SizedBox(height: 12),
                _CheckRow('Push notifications', true),
                _CheckRow('Email', true),
                _CheckRow('SMS', false),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle('Quiet Hours'),
                SizedBox(height: 12),
                _ToggleRow('Enable quiet hours', true),
                SizedBox(height: 12),
                _ReadOnlyField('Time range', '10:00 PM - 8:00 AM'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: _buttonStyle(),
                  onPressed: () => _showSuccessToast(
                    context,
                    'Notification preferences saved',
                  ),
                  child: const Text('Save Preferences'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GlobalSearchScreen extends ConsumerWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(sessionControllerProvider).activeProfile;
    final results = _resultsForRole(role);
    return _SharedScaffold(
      title: 'Search',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            style: const TextStyle(color: _text),
            decoration: InputDecoration(
              hintText: _placeholderForRole(role),
              hintStyle: const TextStyle(color: _muted),
              prefixIcon: const Icon(Icons.search_rounded, color: _muted),
              filled: true,
              fillColor: _card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _border),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle('Recent Searches'),
                SizedBox(height: 12),
                Text('Arjun Sharma', style: TextStyle(color: _muted)),
                SizedBox(height: 8),
                Text('Batch A1', style: TextStyle(color: _muted)),
                SizedBox(height: 8),
                Text('Pending payments', style: TextStyle(color: _muted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (results.isEmpty)
            const EmptyStatesScreen(query: 'query')
          else
            ..._groupSearchResults(results, context),
        ],
      ),
    );
  }
}

class UserProfileMenuScreen extends ConsumerWidget {
  const UserProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(sessionControllerProvider).activeProfile;
    return _SharedScaffold(
      title: 'Account',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userNameForRole(role),
                  style: const TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _roleLabel(role),
                  style: const TextStyle(color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...[
            _MenuAction('Edit Profile', Icons.edit_rounded, _editRoute(role)),
            _MenuAction(
                'Settings', Icons.settings_rounded, _settingsRoute(role)),
            const _MenuAction('Help Center', Icons.help_outline_rounded, null),
            const _MenuAction('Logout', Icons.logout_rounded, null),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Panel(
                onTap: () {
                  if (item.label == 'Logout') {
                    context.push(AppRoutes.sharedLogoutConfirm);
                  } else if (item.route != null) {
                    context.push(item.route!);
                  }
                },
                child: Row(
                  children: [
                    Icon(item.icon, color: _accent),
                    const SizedBox(width: 12),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutConfirmationScreen extends ConsumerWidget {
  const LogoutConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SharedScaffold(
      title: 'Logout',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _Panel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded, color: _accent, size: 36),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _buttonStyle(),
                        onPressed: () async {
                          await ref
                              .read(sessionControllerProvider.notifier)
                              .signOut();
                          if (context.mounted) context.go(AppRoutes.welcome);
                        },
                        child: const Text('Logout'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeedbackMessagesScreen extends StatelessWidget {
  const FeedbackMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SharedScaffold(
      title: 'Messages',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ToastCard(
            color: _success,
            title: "Player 'Arjun' added successfully",
            actionLabel: 'View Player',
          ),
          const SizedBox(height: 12),
          _ToastCard(
            color: _error,
            title: 'Failed to save. Please check your internet connection.',
            actionLabel: 'Retry',
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle('Validation Error'),
                SizedBox(height: 12),
                Text('Phone number is invalid',
                    style: TextStyle(color: _error)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStatesScreen extends StatelessWidget {
  const EmptyStatesScreen({super.key, this.query});

  final String? query;

  @override
  Widget build(BuildContext context) {
    return _SharedScaffold(
      title: 'Empty States',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (query != null)
            _EmptyPanel(
              icon: Icons.search_off_rounded,
              heading: "No results found for '$query'",
              message: 'Try different keywords',
              button: 'Search Again',
            ),
          const SizedBox(height: 12),
          const _EmptyPanel(
            icon: Icons.groups_rounded,
            heading: 'No players yet',
            message: 'Get started by adding your first player.',
            button: 'Add Player',
          ),
          const SizedBox(height: 12),
          const _EmptyPanel(
            icon: Icons.sports_rounded,
            heading: 'No coaches',
            message: 'Add a coach to assign batches.',
            button: 'Add Coach',
          ),
          const SizedBox(height: 12),
          const _EmptyPanel(
            icon: Icons.event_busy_rounded,
            heading: 'No sessions today',
            message: "Check out tomorrow's schedule.",
            button: 'View Schedule',
          ),
        ],
      ),
    );
  }
}

class LoadingStatesScreen extends StatelessWidget {
  const LoadingStatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SharedScaffold(
      title: 'Loading States',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle('Skeleton Loader'),
                SizedBox(height: 12),
                _SkeletonLine(widthFactor: .7),
                SizedBox(height: 10),
                _SkeletonLine(widthFactor: 1),
                SizedBox(height: 10),
                _SkeletonLine(widthFactor: .85),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              children: [
                CircularProgressIndicator(color: _accent),
                SizedBox(height: 12),
                Text('Loading...', style: TextStyle(color: _muted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle('Progress Bar'),
                SizedBox(height: 12),
                LinearProgressIndicator(
                  value: .5,
                  backgroundColor: _border,
                  color: _accent,
                ),
                SizedBox(height: 10),
                Text('Loading 50% complete', style: TextStyle(color: _muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SharedScaffold(
      title: 'Connection Error',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _Panel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, color: _error, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted),
                ),
                const SizedBox(height: 12),
                const Text(
                  "You're viewing cached data",
                  style: TextStyle(color: _accent),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _buttonStyle(),
                        onPressed: () => context.pop(),
                        child: const Text('Retry'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SharedScaffold(
      title: 'Session Expired',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _Panel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_off_rounded, color: _accent, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'Session Expired',
                  style: TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your session has expired. Please log in again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  style: _buttonStyle(),
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PermissionRequestScreen extends StatelessWidget {
  const PermissionRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SharedScaffold(
      title: 'Permissions',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _Panel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_alt_rounded, color: _accent, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'Camera Access Needed',
                  style: TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We need access to your camera to upload photos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _buttonStyle(),
                        onPressed: () => context.pop(),
                        child: const Text('Allow'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Deny'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumUpgradeScreen extends StatelessWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SharedScaffold(
      title: 'Upgrade',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _Panel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium_rounded,
                    color: _accent, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'Unlock Advanced Analytics',
                  style: TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get detailed player performance insights with our Premium plan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _buttonStyle(),
                        onPressed: () => context.pop(),
                        child: const Text('Upgrade Now'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Learn More'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SharedScaffold extends StatelessWidget {
  const _SharedScaffold({
    required this.title,
    required this.child,
    this.actions,
    this.bottom,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        title: Text(title),
        actions: actions,
        bottom: bottom,
      ),
      body: child,
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items});

  final List<AppNotificationItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ValueKey('${item.title}-${item.time}'),
                child: _Panel(
                  onTap: () => _showNotificationDetail(context, item),
                  child: Row(
                    children: [
                      Icon(item.icon, color: _accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                color: _text,
                                fontWeight: item.unread
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: const TextStyle(color: _muted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.time,
                              style:
                                  const TextStyle(color: _muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.close_rounded, color: _muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TypeGroup extends StatelessWidget {
  const _TypeGroup({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final items = _notifications.where((item) => item.type == type).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(type),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(item.title, style: const TextStyle(color: _muted)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: child,
    );
    if (onTap == null) return panel;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: panel,
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _text,
        fontWeight: FontWeight.w900,
        fontSize: 16,
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow(this.label, this.value);

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: _accent,
      value: value,
      onChanged: (_) {},
      title: Text(label, style: const TextStyle(color: _text)),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow(this.label, this.value);

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      activeColor: _accent,
      value: value,
      onChanged: (_) {},
      title: Text(label, style: const TextStyle(color: _text)),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _muted),
        filled: true,
        fillColor: _bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
      ),
      child: Text(value, style: const TextStyle(color: _text)),
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.color,
    required this.title,
    required this.actionLabel,
  });

  final Color color;
  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          Icon(
            color == _success
                ? Icons.check_circle_rounded
                : Icons.warning_rounded,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: _text)),
          ),
          TextButton(onPressed: () {}, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.heading,
    required this.message,
    required this.button,
  });

  final IconData icon;
  final String heading;
  final String message;
  final String button;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          Icon(icon, color: _accent, size: 38),
          const SizedBox(height: 12),
          Text(
            heading,
            style: const TextStyle(
              color: _text,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted),
          ),
          const SizedBox(height: 14),
          FilledButton(
            style: _buttonStyle(),
            onPressed: () {},
            child: Text(button),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 14,
        decoration: BoxDecoration(
          color: _border,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class _MenuAction {
  const _MenuAction(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String? route;
}

List<Widget> _groupSearchResults(
    List<SearchResultItem> results, BuildContext context) {
  final grouped = <String, List<SearchResultItem>>{};
  for (final item in results) {
    grouped.putIfAbsent(item.section, () => []).add(item);
  }

  return grouped.entries
      .map(
        (entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle(entry.key),
                const SizedBox(height: 12),
                ...entry.value.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(item.icon, color: _accent),
                    title:
                        Text(item.title, style: const TextStyle(color: _text)),
                    subtitle:
                        Text(item.meta, style: const TextStyle(color: _muted)),
                    onTap: () => context.push(item.route),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
      .toList();
}

List<SearchResultItem> _resultsForRole(BizProfileType? role) {
  return switch (role) {
    BizProfileType.academy => _ownerSearchResults,
    BizProfileType.coach => _coachSearchResults,
    BizProfileType.arena || BizProfileType.arenaManager => _arenaSearchResults,
    _ => _ownerSearchResults,
  };
}

String _placeholderForRole(BizProfileType? role) {
  return switch (role) {
    BizProfileType.academy => 'Search for players, coaches, batches...',
    BizProfileType.coach => 'Search for students, sessions, training plans...',
    BizProfileType.arena ||
    BizProfileType.arenaManager =>
      'Search for courts, bookings, slots...',
    _ => 'Search...',
  };
}

String _userNameForRole(BizProfileType? role) {
  return switch (role) {
    BizProfileType.academy => 'Owner Account',
    BizProfileType.coach => 'Coach Account',
    BizProfileType.arena || BizProfileType.arenaManager => 'Arena Account',
    _ => 'User Account',
  };
}

String _roleLabel(BizProfileType? role) {
  return switch (role) {
    BizProfileType.academy => 'Academy Owner',
    BizProfileType.coach => 'Coach',
    BizProfileType.arena || BizProfileType.arenaManager => 'Arena Manager',
    _ => 'Business User',
  };
}

String _settingsRoute(BizProfileType? role) {
  return switch (role) {
    BizProfileType.academy => AppRoutes.settings,
    BizProfileType.coach => AppRoutes.coachSettings,
    BizProfileType.arena ||
    BizProfileType.arenaManager =>
      AppRoutes.arenaProfile,
    _ => AppRoutes.welcome,
  };
}

String _editRoute(BizProfileType? role) {
  return switch (role) {
    BizProfileType.academy => AppRoutes.academyProfile,
    BizProfileType.coach => AppRoutes.coachProfileEdit,
    BizProfileType.arena ||
    BizProfileType.arenaManager =>
      AppRoutes.arenaProfile,
    _ => AppRoutes.welcome,
  };
}

void _showNotificationDetail(BuildContext context, AppNotificationItem item) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: _card,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              color: _text,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(item.subtitle, style: const TextStyle(color: _muted)),
          const SizedBox(height: 8),
          Text(item.time, style: const TextStyle(color: _muted)),
          const SizedBox(height: 16),
          FilledButton(
            style: _buttonStyle(),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(item.actionLabel),
          ),
        ],
      ),
    ),
  );
}

void _showSuccessToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

ButtonStyle _buttonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: _accent,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
