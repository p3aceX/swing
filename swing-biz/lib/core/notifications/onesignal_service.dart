import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../api/api_client.dart';
import '../auth/token_storage.dart';
import '../router/app_router.dart';

class OneSignalService {
  OneSignalService._();

  static final OneSignalService instance = OneSignalService._();

  static const String appId = '4f536fab-eda8-4612-a9f3-4936028fb6ff';

  bool _initialized = false;
  String? _loggedInUserId;

  // Set by the app after the router is ready
  GoRouter? router;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      OneSignal.Debug.setLogLevel(
          kDebugMode ? OSLogLevel.verbose : OSLogLevel.none);
      OneSignal.initialize(appId);
      OneSignal.Notifications.addForegroundWillDisplayListener(
          _handleWillDisplay);
      OneSignal.Notifications.addClickListener(_handleClick);
      await OneSignal.Notifications.requestPermission(true);
      _initialized = true;
      await identifyFromStoredToken();
    } catch (e) {
      if (kDebugMode) debugPrint('[OneSignal] initialize error: $e');
    }
  }

  Future<void> identifyFromStoredToken() async {
    final token = await TokenStorage.getAccessToken();
    final userId = _userIdFromJwt(token);
    if (userId == null || userId.isEmpty) return;
    await identifyUser(userId);
  }

  Future<void> identifyUser(String userId) async {
    if (!_initialized || _loggedInUserId == userId) return;
    try {
      OneSignal.login(userId);
      _loggedInUserId = userId;
      if (kDebugMode) debugPrint('[OneSignal] identified user=$userId');
    } catch (e) {
      if (kDebugMode) debugPrint('[OneSignal] identify error: $e');
    }
  }

  Future<void> logout() async {
    if (!_initialized) return;
    try {
      OneSignal.logout();
      _loggedInUserId = null;
      if (kDebugMode) debugPrint('[OneSignal] logged out');
    } catch (e) {
      if (kDebugMode) debugPrint('[OneSignal] logout error: $e');
    }
  }

  Future<void> _handleWillDisplay(OSNotificationWillDisplayEvent event) async {
    await _syncNotification(event.notification);
  }

  Future<void> _handleClick(OSNotificationClickEvent event) async {
    await _syncNotification(event.notification);
    // Navigate to notifications screen so the user sees the tapped notification
    router?.push(AppRoutes.arenaNotifications);
  }

  Future<void> _syncNotification(OSNotification notification) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return;
    final payloadData = notification.additionalData;
    if (payloadData != null && payloadData['source'] == 'backend') return;

    final body = notification.body?.trim();
    if (body == null || body.isEmpty) return;

    try {
      final client = ApiClient.instance.dio;
      await client.post(
        '/notifications/sync',
        data: {
          'notificationId': notification.notificationId,
          'type': payloadData?['type'],
          'title': notification.title,
          'body': body,
          'entityType': payloadData?['entityType'],
          'entityId': payloadData?['entityId'],
          if (payloadData != null) 'data': payloadData,
        }..removeWhere((key, value) => value == null),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[OneSignal] sync error: $e');
    }
  }

  String? _userIdFromJwt(String? token) {
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        final userId = data['userId'];
        if (userId is String && userId.isNotEmpty) return userId;
      }
    } catch (_) {}
    return null;
  }
}
