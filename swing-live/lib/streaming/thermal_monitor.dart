import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Mirrors Android's `PowerManager` thermal-status constants
/// (API 29+). Integer values match the platform's `THERMAL_STATUS_*`
/// constants so we can map the EventChannel int directly.
enum ThermalLevel {
  none,
  light,
  moderate,
  severe,
  critical,
  emergency,
  shutdown;

  /// Built-in [index] (declaration order) already matches Android's
  /// `THERMAL_STATUS_*` constants (0..6), so we read from the platform
  /// directly.
  static ThermalLevel fromIndex(int i) {
    if (i < 0 || i >= ThermalLevel.values.length) return ThermalLevel.none;
    return ThermalLevel.values[i];
  }
}

/// Listens to the platform thermal-status stream and exposes the current
/// [ThermalLevel] reactively. The platform side is Android-only; on iOS
/// or when the channel hasn't been registered yet, this monitor stays at
/// [ThermalLevel.none] and silently no-ops.
class ThermalMonitor extends ChangeNotifier {
  ThermalMonitor() {
    _subscribe();
  }

  static const EventChannel _channel = EventChannel('swing.thermal');

  ThermalLevel _level = ThermalLevel.none;
  ThermalLevel get level => _level;

  StreamSubscription<dynamic>? _sub;

  void _subscribe() {
    if (!Platform.isAndroid) return;
    try {
      _sub = _channel.receiveBroadcastStream().listen(
        (event) {
          if (event is int) {
            final next = ThermalLevel.fromIndex(event);
            if (next != _level) {
              _level = next;
              notifyListeners();
            }
          }
        },
        onError: (_) {
          // Channel not registered yet or platform refused — stay at none.
        },
        cancelOnError: false,
      );
    } catch (_) {
      // Defensive: don't crash the app over a missing channel.
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }
}
