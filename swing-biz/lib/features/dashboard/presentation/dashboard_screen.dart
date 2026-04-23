import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);
    final session = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swing Biz'),
        actions: [
          meAsync.maybeWhen(
            data: (me) {
              if (me == null) return const SizedBox.shrink();
              return _ProfileSwitcher(
                profiles: me.businessStatus.availableProfiles,
                active: session.activeProfile ??
                    (me.businessStatus.availableProfiles.isNotEmpty
                        ? me.businessStatus.availableProfiles.first
                        : null),
                onSelect: (p) async {
                  await ref
                      .read(sessionControllerProvider.notifier)
                      .setActiveProfile(p);
                },
                onAdd: () => context.push(AppRoutes.chooseProfile),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(sessionControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load your account: $err'),
          ),
        ),
        data: (me) {
          if (me == null) return const SizedBox.shrink();
          final profiles = me.businessStatus.availableProfiles;
          final active = session.activeProfile != null &&
                  profiles.contains(session.activeProfile)
              ? session.activeProfile!
              : (profiles.isNotEmpty ? profiles.first : null);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Hello, ${me.user.name ?? 'there'}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              if (active != null)
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                    children: [
                      const TextSpan(text: 'Signed in as '),
                      TextSpan(
                        text: bizProfileTypeLabel(active),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                )
              else
                const Text('Add a business profile to get started.'),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your profiles',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.chooseProfile),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add another'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...profiles.map((p) => _ProfileTile(
                    type: p,
                    status: me.businessStatus,
                  )),
              if (me.businessAccount != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Business',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: Text(me.businessAccount!.businessName),
                    subtitle: Text(
                      [me.businessAccount!.city, me.businessAccount!.state]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(', ')
                              .isNotEmpty
                          ? '${me.businessAccount!.city ?? ''}${me.businessAccount!.city != null && me.businessAccount!.state != null ? ', ' : ''}${me.businessAccount!.state ?? ''}'
                          : 'No location set',
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.type, required this.status});

  final BizProfileType type;
  final BusinessStatus status;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      BizProfileType.academy => Icons.school_outlined,
      BizProfileType.coach => Icons.sports_cricket_outlined,
      BizProfileType.arena || BizProfileType.arenaManager => Icons.place_outlined,
      BizProfileType.store => Icons.store_outlined,
    };
    final subtitle = switch (type) {
      BizProfileType.academy =>
        status.academyId == null ? 'Academy' : 'Academy ID ${_short(status.academyId!)}',
      BizProfileType.coach => 'Coach profile active',
      BizProfileType.arena =>
        status.arenaId == null ? 'Arena' : 'Arena ID ${_short(status.arenaId!)}',
      BizProfileType.arenaManager => 'Arena manager',
      BizProfileType.store => '${status.storeIds.length} store(s)',
    };
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(bizProfileTypeLabel(type)),
        subtitle: Text(subtitle),
      ),
    );
  }

  String _short(String id) => id.length <= 8 ? id : '${id.substring(0, 8)}…';
}

class _ProfileSwitcher extends StatelessWidget {
  const _ProfileSwitcher({
    required this.profiles,
    required this.active,
    required this.onSelect,
    required this.onAdd,
  });

  final List<BizProfileType> profiles;
  final BizProfileType? active;
  final ValueChanged<BizProfileType> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) return const SizedBox.shrink();
    return PopupMenuButton<_MenuAction>(
      tooltip: 'Switch profile',
      onSelected: (a) {
        if (a is _SelectProfile) onSelect(a.profile);
        if (a is _AddProfile) onAdd();
      },
      itemBuilder: (context) => [
        ...profiles.map(
          (p) => PopupMenuItem<_MenuAction>(
            value: _SelectProfile(p),
            child: Row(
              children: [
                Expanded(child: Text(bizProfileTypeLabel(p))),
                if (p == active) const Icon(Icons.check, size: 18),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<_MenuAction>(
          value: _AddProfile(),
          child: Row(children: [
            Icon(Icons.add, size: 18),
            SizedBox(width: 8),
            Text('Add another profile'),
          ]),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(
              active == null ? 'Profiles' : bizProfileTypeLabel(active!),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

sealed class _MenuAction {
  const _MenuAction();
}

class _SelectProfile extends _MenuAction {
  const _SelectProfile(this.profile);
  final BizProfileType profile;
}

class _AddProfile extends _MenuAction {
  const _AddProfile();
}
