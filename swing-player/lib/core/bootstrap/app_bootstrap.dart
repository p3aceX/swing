import 'package:hive_flutter/hive_flutter.dart';

class AppBootstrap {
  AppBootstrap._();

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>('ball_event_queue'),
      Hive.openBox<String>('app_cache'),
    ]);
  }
}
