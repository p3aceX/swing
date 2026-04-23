import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/router/app_router.dart';

class ChooseProfileScreen extends ConsumerWidget {
  const ChooseProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final existing = me.valueOrNull?.businessStatus.availableProfiles.toSet() ??
        <BizProfileType>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a profile'),
        actions: [
          if (existing.isNotEmpty)
            TextButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Skip'),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'One user can own multiple businesses — add more anytime.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _Option(
              icon: Icons.school_outlined,
              title: 'Academy Owner',
              desc: 'Run batches, enroll students, collect fees.',
              alreadyHave: existing.contains(BizProfileType.academy),
              onTap: () => context.push(AppRoutes.createAcademy),
            ),
            const SizedBox(height: 12),
            _Option(
              icon: Icons.sports_cricket_outlined,
              title: 'Coach',
              desc: 'Take sessions, gigs and 1-on-1 lessons.',
              alreadyHave: existing.contains(BizProfileType.coach),
              onTap: () => context.push(AppRoutes.createCoach),
            ),
            const SizedBox(height: 12),
            _Option(
              icon: Icons.place_outlined,
              title: 'Arena Owner',
              desc: 'List your pitch or turf and take bookings.',
              alreadyHave: existing.contains(BizProfileType.arena),
              onTap: () => context.push(AppRoutes.createArena),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.desc,
    required this.alreadyHave,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String desc;
  final bool alreadyHave;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: alreadyHave ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                    const SizedBox(height: 2),
                    Text(
                      alreadyHave ? 'Already set up' : desc,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                alreadyHave ? Icons.check_circle : Icons.arrow_forward_ios,
                size: 18,
                color: alreadyHave ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
