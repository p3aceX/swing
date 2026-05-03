import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(settingsProvider)),
        data: (data) {
          final user = data['user'] as Map<String, dynamic>? ?? {};
          final biz = data['businessAccount'] as Map<String, dynamic>? ?? {};
          final academies = (biz['academyOwnerProfile']?['academies'] as List? ?? []);
          final academy = academies.isNotEmpty
              ? Map<String, dynamic>.from(academies.first as Map)
              : <String, dynamic>{};

          return ListView(
            children: [
              _Section('Account', [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(user['name'] as String? ?? '—'),
                  subtitle: Text(user['phone'] as String? ?? ''),
                ),
              ]),
              const Divider(),
              _Section('Academy', [
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: Text(academy['name'] as String? ?? '—'),
                  subtitle: Text(academy['city'] as String? ?? ''),
                  trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                  onTap: () => context.push('/more/settings/profile'),
                ),
              ]),
              const Divider(),
              _Section('Account', [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                  onTap: () => _confirmLogout(context, ref),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(settingsProvider.notifier).logout();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(title.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey,
                    fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          ),
          ...children,
        ],
      );
}
