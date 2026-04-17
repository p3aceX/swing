import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';

/// Handles FCM token registration and incoming push message routing.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  /// Call after a successful login. Registers the FCM token with the backend.
  Future<void> registerToken() async {
    if (Firebase.apps.isEmpty) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await messaging.getToken();
      if (token == null || token.isEmpty) return;
      await ApiClient.instance.dio.post(
        ApiEndpoints.fcmToken,
        data: {'token': token},
      );
      if (kDebugMode) debugPrint('[FCM] token registered');
      // Re-register if the token rotates
      messaging.onTokenRefresh.listen((newToken) async {
        try {
          await ApiClient.instance.dio.post(
            ApiEndpoints.fcmToken,
            data: {'token': newToken},
          );
          if (kDebugMode) debugPrint('[FCM] token refreshed');
        } catch (_) {}
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] registerToken error: $e');
    }
  }

  /// Call on sign-out. Removes the FCM token from the backend.
  Future<void> removeToken() async {
    if (Firebase.apps.isEmpty) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      await ApiClient.instance.dio.delete(
        ApiEndpoints.fcmToken,
        data: {'token': token},
      );
      await FirebaseMessaging.instance.deleteToken();
      if (kDebugMode) debugPrint('[FCM] token removed');
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] removeToken error: $e');
    }
  }
}
