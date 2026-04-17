import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_service.dart';
import '../domain/health_integration_models.dart';
import 'health_controller.dart';

final healthServiceProvider = Provider((ref) => HealthService());

final healthIntegrationProvider =
    StateNotifierProvider<HealthIntegrationNotifier, HealthSyncState>((ref) {
  return HealthIntegrationNotifier(ref.watch(healthServiceProvider), ref);
});

class HealthIntegrationNotifier extends StateNotifier<HealthSyncState> {
  HealthIntegrationNotifier(this._service, this._ref)
      : super(HealthSyncState.initial()) {
    _initAutoSync();
  }

  final HealthService _service;
  final Ref _ref;

  Future<void> _initAutoSync() async {
    final hasPermissions = await _service.checkPermissions();
    if (hasPermissions) {
      await sync();
    }
  }

  Future<void> connect() async {
    debugPrint('HealthIntegrationNotifier: Starting connect flow...');

    final isAvailable = await _service.isAvailable();
    if (!isAvailable) {
      state = state.copyWith(
        status: HealthSyncStatus.error,
        errorMessage: Platform.isAndroid
            ? 'Health Connect not found. Please install it.'
            : 'Health data not available.',
      );
      return;
    }

    state = state.copyWith(status: HealthSyncStatus.syncing);
    try {
      final hasPermissions = await _service.requestPermissions();
      if (hasPermissions) {
        await sync();
      } else {
        state = state.copyWith(
          status: HealthSyncStatus.permissionsDenied,
          errorMessage: 'Permissions required. Check settings.',
        );
      }
    } catch (e) {
      debugPrint('HealthIntegrationNotifier: connect error: $e');
      state = state.copyWith(
        status: HealthSyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> sync() async {
    state = state.copyWith(status: HealthSyncStatus.syncing);
    try {
      final data = await _service.fetchRecentData();
      state = state.copyWith(
        status: HealthSyncStatus.synced,
        lastSync: DateTime.now(),
        errorMessage: null,
      );

      try {
        await _ref.read(healthRepositoryProvider).ingestWearableData(data);
        await _ref.read(healthDashboardProvider.notifier).load();
      } catch (e) {
        debugPrint('HealthIntegrationNotifier: backend sync warning: $e');
        state = state.copyWith(errorMessage: e.toString());
      }
    } catch (e) {
      state = state.copyWith(
        status: HealthSyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> openSettings() async {
    await _service.openSettings();
    await _initAutoSync();
  }

  void updateManualBodyComp(double weight, double height, {double? bodyFatPercent}) {
    _ref.read(manualBodyCompProvider.notifier).state = BodyComposition(
      weight: weight,
      height: height,
      bodyFatPercent: bodyFatPercent,
      updatedAt: DateTime.now(),
    );
  }
}

final manualBodyCompProvider = StateProvider<BodyComposition?>((ref) => null);

final recentHealthDataProvider = FutureProvider<HealthDataPayload>((ref) async {
  final syncState = ref.watch(healthIntegrationProvider);
  if (syncState.status == HealthSyncStatus.synced) {
    return await ref.read(healthServiceProvider).fetchRecentData();
  }
  return const HealthDataPayload();
});
