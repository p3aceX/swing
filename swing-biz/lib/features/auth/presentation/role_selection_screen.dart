import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../controller/auth_controller.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final meAsync = ref.watch(meProvider);
    final session = ref.watch(sessionControllerProvider);
    final availableProfiles =
        meAsync.valueOrNull?.businessStatus.availableProfiles.toSet().toList() ??
            const <BizProfileType>[];
    final cameFromDashboard = session.status == AuthStatus.authenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            if (cameFromDashboard) {
              if (context.mounted) context.go(AppRoutes.dashboard);
              return;
            }
            ref.read(authControllerProvider.notifier).resetToPhone();
            await ref.read(sessionControllerProvider.notifier).signOut();
            if (context.mounted) context.go(AppRoutes.login);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFF8F5), Colors.white],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF134E4A)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.layers_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Choose your profile',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      availableProfiles.isEmpty
                          ? 'No active business profiles found yet.'
                          : 'One user can use multiple business profiles. Pick the workspace you want right now.',
                      style: const TextStyle(
                        color: Color(0xFFD7E1DE),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (meAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (availableProfiles.isEmpty)
                _EmptyState(
                  onTap: () => context.go(AppRoutes.chooseProfile),
                )
              else
                ...availableProfiles.map(
                  (profile) => _RoleCard(
                    title: _titleFor(profile),
                    subtitle: _subtitleFor(profile),
                    icon: _iconFor(profile),
                    color: _colorFor(profile),
                    selected: session.activeProfile == profile,
                    onTap: () => _selectRole(
                      context,
                      ref,
                      profile,
                      AppRoutes.dashboard,
                    ),
                  ),
                ),
              if (availableProfiles.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go(AppRoutes.chooseProfile),
                  child: const Text('Add Another Profile'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectRole(
    BuildContext context,
    WidgetRef ref,
    BizProfileType role,
    String route,
  ) async {
    await ref.read(sessionControllerProvider.notifier).setActiveProfile(role);
    if (context.mounted) context.go(route);
  }

  String _titleFor(BizProfileType role) => switch (role) {
        BizProfileType.academy => 'Academy Owner',
        BizProfileType.coach => 'Coach',
        BizProfileType.arena => 'Arena Owner',
        BizProfileType.arenaManager => 'Arena Manager',
        BizProfileType.store => 'Store',
      };

  String _subtitleFor(BizProfileType role) => switch (role) {
        BizProfileType.academy =>
          'Manage academy, players, coaches and finances',
        BizProfileType.coach =>
          'Track students, conduct sessions and training',
        BizProfileType.arena =>
          'Manage bookings, slots, pricing and revenue',
        BizProfileType.arenaManager =>
          'Operate courts, schedules and daily activity',
        BizProfileType.store =>
          'Manage products, inventory and orders',
      };

  IconData _iconFor(BizProfileType role) => switch (role) {
        BizProfileType.academy => Icons.school_rounded,
        BizProfileType.coach => Icons.sports_rounded,
        BizProfileType.arena => Icons.stadium_rounded,
        BizProfileType.arenaManager => Icons.manage_accounts_rounded,
        BizProfileType.store => Icons.storefront_rounded,
      };

  Color _colorFor(BizProfileType role) => switch (role) {
        BizProfileType.academy => const Color(0xFF0EA5A4),
        BizProfileType.coach => const Color(0xFFF97316),
        BizProfileType.arena => const Color(0xFF22C55E),
        BizProfileType.arenaManager => const Color(0xFF2563EB),
        BizProfileType.store => const Color(0xFFA855F7),
      };
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected ? color : const Color(0xFFD8E3E0),
                width: selected ? 1.4 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F0F172A),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                  color: selected ? color : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD8E3E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No profiles available yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first business profile to start using Swing Biz.',
            style: TextStyle(
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onTap,
            child: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }
}
