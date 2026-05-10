import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';

class ArenaHomeScreen extends ConsumerWidget {
  const ArenaHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RoleHomeScaffold(
      title: 'Arena Home',
      icon: Icons.stadium_rounded,
      color: const Color(0xFF34D399),
      onSignOut: () => ref.read(sessionControllerProvider.notifier).signOut(),
    );
  }
}

class _RoleHomeScaffold extends StatelessWidget {
  const _RoleHomeScaffold({
    required this.title,
    required this.icon,
    required this.color,
    required this.onSignOut,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: onSignOut,
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
