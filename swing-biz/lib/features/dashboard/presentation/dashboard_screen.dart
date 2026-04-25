import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../../arena/services/arena_profile_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(onOpenProfile: () => setState(() => _index = 2)),
      const _ArenasTab(),
      const _UserProfileTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEFF4FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.stadium_outlined),
            selectedIcon: Icon(Icons.stadium_rounded),
            label: 'Arena',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab({required this.onOpenProfile});

  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);
    final session = ref.watch(sessionControllerProvider);
    final name = meAsync.valueOrNull?.user.name ?? 'User';
    final dateStr = DateFormat('EEEE, d MMM').format(DateTime.now());
    final profileType = session.activeProfile?.name.toUpperCase() ?? 'BIZ';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onOpenProfile,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF2F4F7),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101828),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF667085),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.go(AppRoutes.roleSelection),
              icon: const Icon(Icons.switch_account_rounded),
              tooltip: 'Switch Profile',
            ),
          ],
        ),
        const SizedBox(height: 22),
        _WorkspacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBadge(profileType),
              const SizedBox(height: 14),
              const Text(
                'Business workspace',
                style: TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your business profile and role-specific modules from the bottom navigation.',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArenasTab extends ConsumerWidget {
  const _ArenasTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);

    return Column(
      children: [
        _PageHeader(
          title: 'Arenas',
          subtitle: 'Manage venues, photos, facilities and booking rules.',
          action: FilledButton.icon(
            onPressed: () => context.push(AppRoutes.createArena),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Arena'),
          ),
        ),
        Expanded(
          child: arenasAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _CenteredMessage(
              title: 'Could not load arenas',
              message: '$error',
            ),
            data: (arenas) {
              if (arenas.isEmpty) {
                return _CenteredMessage(
                  title: 'No arenas yet',
                  message: 'Add your first arena to start managing bookings.',
                  action: FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.createArena),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Arena'),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.refresh(ownedArenasProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: arenas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final arena = arenas[index];
                    return _ArenaListItem(arena: arena);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ArenaListItem extends StatelessWidget {
  const _ArenaListItem({required this.arena});

  final ArenaListing arena;

  @override
  Widget build(BuildContext context) {
    final location = _joinNonEmpty([arena.city, arena.state, arena.pincode]);
    final imageUrl = arena.photoUrls.isEmpty ? null : arena.photoUrls.first;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.push('${AppRoutes.arenaProfile}/${arena.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 56,
                height: 56,
                child: imageUrl == null
                    ? Container(
                        color: const Color(0xFFF2F4F7),
                        child: const Icon(Icons.stadium_rounded),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF2F4F7),
                          child: const Icon(Icons.stadium_rounded),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    arena.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF101828),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.isEmpty ? 'Location not set' : location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${arena.units.length} units • ${arena.openTime}-${arena.closeTime}',
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A2B3)),
          ],
        ),
      ),
    );
  }
}

class _UserProfileTab extends ConsumerWidget {
  const _UserProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);

    return meAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _CenteredMessage(
        title: 'Could not load profile',
        message: '$error',
      ),
      data: (me) {
        if (me == null) {
          return const _CenteredMessage(
            title: 'Profile unavailable',
            message: 'Login again to refresh your business profile.',
          );
        }

        final business = me.businessAccount;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const _PageTitle(
              title: 'Profile',
              subtitle: 'User and business account',
            ),
            const SizedBox(height: 16),
            _WorkspacePanel(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFF2F4F7),
                    child: Text(
                      (me.user.name ?? 'U').isNotEmpty
                          ? (me.user.name ?? 'U')[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          me.user.name ?? 'User',
                          style: const TextStyle(
                            color: Color(0xFF101828),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          me.user.phone,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _InfoTable(
              title: 'User',
              rows: [
                _InfoRow('Name', me.user.name ?? 'Not set'),
                _InfoRow('Phone', me.user.phone),
                _InfoRow('Email', me.user.email ?? 'Not set'),
              ],
            ),
            const SizedBox(height: 14),
            _InfoTable(
              title: 'Business',
              rows: [
                _InfoRow('Business name', business?.businessName ?? 'Not set'),
                _InfoRow('Contact name', business?.contactName ?? 'Not set'),
                _InfoRow('Phone', business?.phone ?? 'Not set'),
                _InfoRow('Email', business?.email ?? 'Not set'),
                _InfoRow('Address', business?.address ?? 'Not set'),
                _InfoRow('GST', business?.gstNumber ?? 'Not set'),
                _InfoRow('PAN', business?.panNumber ?? 'Not set'),
              ],
            ),
            const SizedBox(height: 14),
            _InfoTable(
              title: 'Profiles',
              rows: [
                _InfoRow(
                  'Active profiles',
                  me.businessStatus.availableProfiles.isEmpty
                      ? 'None'
                      : me.businessStatus.availableProfiles
                          .map(_profileName)
                          .join(', '),
                ),
              ],
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(sessionControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(child: _PageTitle(title: title, subtitle: subtitle)),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF101828),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WorkspacePanel extends StatelessWidget {
  const _WorkspacePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _InfoTable extends StatelessWidget {
  const _InfoTable({required this.title, required this.rows});

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return _WorkspacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF344054),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...rows.map((row) => _TableRowView(row: row)),
        ],
      ),
    );
  }
}

class _TableRowView extends StatelessWidget {
  const _TableRowView({required this.row});

  final _InfoRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF2F4F7))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              row.label,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              row.value,
              style: const TextStyle(
                color: Color(0xFF101828),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF667085)),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF344054),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _joinNonEmpty(List<String?> values, {String separator = ', '}) {
  return values
      .where((value) => value != null && value.trim().isNotEmpty)
      .map((value) => value!.trim())
      .join(separator);
}

String _profileName(BizProfileType type) => switch (type) {
      BizProfileType.academy => 'Academy',
      BizProfileType.coach => 'Coach',
      BizProfileType.arena => 'Arena',
      BizProfileType.arenaManager => 'Arena Manager',
      BizProfileType.store => 'Store',
    };
