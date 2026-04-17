import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart' show HostCreateEventScreen;
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HostCreateEventScreen(
      title: 'New Event',
      onEventCreated: (context, event) {
        final name = event['name'] as String? ?? 'Event';
        showDialog(
          context: context,
          builder: (_) => _EventCreatedDialog(
            eventName: name,
            onDone: () {
              Navigator.pop(context);
              context.pop();
            },
          ),
        );
      },
    );
  }
}

class _EventCreatedDialog extends StatelessWidget {
  const _EventCreatedDialog({
    required this.eventName,
    required this.onDone,
  });

  final String eventName;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  Icon(Icons.check_rounded, color: context.accent, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Event Created!',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '"$eventName" has been created.\nShare it with your players to join.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.fgSub),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onDone,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: context.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Done',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
