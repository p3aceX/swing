import 'package:health/health.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../domain/health_integration_models.dart';

class HealthService {
  final Health _health = Health();

  HealthService() {
    _health.configure();
  }

  static final List<HealthDataType> _allTypes = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.WORKOUT,
  ];

  static final List<HealthDataType> _androidPermissionTypes = [
    HealthDataType.STEPS,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.HEART_RATE,
    HealthDataType.WEIGHT,
    HealthDataType.WORKOUT,
  ];

  List<HealthDataType> _getPlatformTypes() {
    if (Platform.isAndroid) {
      // Filter out problematic types for Health Connect to ensure dialog shows
      final androidTypes = [
        HealthDataType.STEPS,
        HealthDataType.SLEEP_SESSION,
        HealthDataType.HEART_RATE,
        HealthDataType.RESTING_HEART_RATE,
        HealthDataType.HEART_RATE_VARIABILITY_SDNN,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.EXERCISE_TIME,
        HealthDataType.WEIGHT,
        HealthDataType.WORKOUT,
      ];
      debugPrint('HealthService: Using Android-optimized types: $androidTypes');
      return androidTypes;
    }
    return _allTypes;
  }

  Future<void> openSettings() async {
    if (Platform.isAndroid) {
      await _health.getHealthConnectSdkStatus();
      // This will trigger the Health Connect app or rationale if available
      await _health.requestAuthorization(_getPermissionTypes());
    }
  }

  List<HealthDataType> _getPermissionTypes() {
    if (Platform.isAndroid) {
      return _androidPermissionTypes;
    }
    return _allTypes;
  }

  Future<bool> checkPermissions() async {
    try {
      await _health.configure();
      final types = _getPermissionTypes();
      final permissions = types.map((e) => HealthDataAccess.READ).toList();
      return await _health.hasPermissions(types, permissions: permissions) ??
          false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    final types = _getPermissionTypes();
    final permissions = types.map((e) => HealthDataAccess.READ).toList();

    try {
      debugPrint('HealthService: Configuring health plugin...');
      await _health.configure();

      debugPrint(
          'HealthService: Checking existing permissions for types: $types');
      bool? hasPermissions =
          await _health.hasPermissions(types, permissions: permissions);
      debugPrint('HealthService: hasPermissions result: $hasPermissions');

      if (hasPermissions == true) {
        debugPrint('HealthService: Permissions already granted.');
        return true;
      }

      debugPrint('HealthService: Requesting authorization for $types...');
      final authorized =
          await _health.requestAuthorization(types, permissions: permissions);
      debugPrint('HealthService: Authorization result: $authorized');
      return authorized;
    } catch (e, stack) {
      debugPrint('HealthService.requestPermissions error: $e');
      debugPrint('$stack');
      return false;
    }
  }

  Future<HealthDataPayload> fetchRecentData() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final types = _getPlatformTypes();

    final metrics = <HealthMetric>[];
    final sleep = <SleepData>[];
    final workouts = <WorkoutData>[];
    Object? firstError;

    for (final type in types) {
      try {
        final healthData = await _health.getHealthDataFromTypes(
          startTime: midnight,
          endTime: now,
          types: [type],
        );
        _appendHealthData(
          healthData: healthData,
          metrics: metrics,
          sleep: sleep,
          workouts: workouts,
        );
      } catch (e) {
        firstError ??= e;
        debugPrint('HealthService: Skipping $type due to fetch error: $e');
      }
    }

    if (metrics.isEmpty &&
        sleep.isEmpty &&
        workouts.isEmpty &&
        firstError != null) {
      throw firstError;
    }

    return HealthDataPayload(
      metrics: metrics,
      sleep: sleep,
      workouts: workouts,
    );
  }

  void _appendHealthData({
    required List<HealthDataPoint> healthData,
    required List<HealthMetric> metrics,
    required List<SleepData> sleep,
    required List<WorkoutData> workouts,
  }) {
    for (final point in healthData) {
      if (point.type == HealthDataType.SLEEP_SESSION) {
        sleep.add(SleepData(
          start: point.dateFrom,
          end: point.dateTo,
          durationMinutes: point.dateTo.difference(point.dateFrom).inMinutes,
        ));
      } else if (point.type == HealthDataType.WORKOUT) {
        final workoutValue = point.value;
        workouts.add(WorkoutData(
          type: workoutValue is WorkoutHealthValue
              ? workoutValue.workoutActivityType.name
              : point.value.toString(),
          durationMinutes: point.dateTo.difference(point.dateFrom).inMinutes,
          calories: workoutValue is WorkoutHealthValue
              ? (workoutValue.totalEnergyBurned ?? 0).toDouble()
              : 0,
          timestamp: point.dateFrom,
        ));
      } else {
        double val = 0;
        if (point.value is NumericHealthValue) {
          val = (point.value as NumericHealthValue).numericValue.toDouble();
        } else {
          val = double.tryParse(point.value.toString()) ?? 0;
        }

        metrics.add(HealthMetric(
          type: point.typeString,
          value: val,
          unit: point.unitString,
          timestamp: point.dateFrom,
        ));
      }
    }
  }

  Future<bool> isAvailable() async {
    if (Platform.isAndroid) {
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable;
    }
    return true;
  }
}
