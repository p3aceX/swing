import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../controller/health_integration_controller.dart';
import '../../domain/health_integration_models.dart';

class HealthSourceCard extends ConsumerWidget {
  const HealthSourceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(healthIntegrationProvider);
    final isAndroid = Platform.isAndroid;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isAndroid ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAndroid ? Icons.health_and_safety_rounded : Icons.favorite_rounded,
                  color: isAndroid ? Colors.green : Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAndroid ? 'Health Connect' : 'Apple Health',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStatusText(syncState.status),
                      style: TextStyle(color: context.fgSub, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (syncState.status == HealthSyncStatus.synced)
                Icon(Icons.check_circle_rounded, color: context.success, size: 20)
            ],
          ),
          const SizedBox(height: 16),
          if (syncState.status == HealthSyncStatus.disconnected || syncState.status == HealthSyncStatus.permissionsDenied)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => ref.read(healthIntegrationProvider.notifier).connect(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Connect Health Source'),
                  ),
                ),
                if (syncState.status == HealthSyncStatus.permissionsDenied) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => ref.read(healthIntegrationProvider.notifier).openSettings(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Open Settings'),
                    ),
                  ),
                ],
              ],
            )
          else if (syncState.status == HealthSyncStatus.syncing)
            const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ))
          else if (syncState.status == HealthSyncStatus.synced)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last synced: ${_formatTime(syncState.lastSync)}',
                  style: TextStyle(color: context.fgSub, fontSize: 12),
                ),
                TextButton.icon(
                  onPressed: () => ref.read(healthIntegrationProvider.notifier).sync(),
                  icon: const Icon(Icons.sync_rounded, size: 16),
                  label: const Text('Sync Now', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: context.accent,
                  ),
                ),
              ],
            ),
          if (syncState.errorMessage != null)
             Padding(
               padding: const EdgeInsets.only(top: 8),
               child: Text(
                 syncState.errorMessage!,
                 style: TextStyle(color: context.danger, fontSize: 12),
               ),
             ),
        ],
      ),
    );
  }

  String _getStatusText(HealthSyncStatus status) {
    return switch (status) {
      HealthSyncStatus.disconnected => 'Not connected',
      HealthSyncStatus.syncing => 'Syncing data...',
      HealthSyncStatus.synced => 'Connected & Synced',
      HealthSyncStatus.error => 'Sync failed',
      HealthSyncStatus.permissionsDenied => 'Permissions required',
    };
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
