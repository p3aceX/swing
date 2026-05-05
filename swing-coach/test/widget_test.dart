import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:swing_coach/main.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows OTP login screen and theme toggle', (tester) async {
    await tester.pumpWidget(const SwingCoachApp());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Swing Coach'), findsWidgets);
    expect(find.text('Login with OTP'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.byType(ThemeToggle), findsOneWidget);

    await tester.tap(find.byType(ThemeToggle));
    await tester.pump();
  });

  testWidgets('post-auth coach shell builds without dirty build assertion', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAuthSessionProvider.overrideWithValue(
            const AuthSession(
              accessToken: 'access',
              refreshToken: 'refresh',
              phone: '+919999999999',
              needsCoachRegistration: false,
            ),
          ),
          settingsStoreProvider.overrideWithValue(LocalSettingsStore()),
        ],
        child: CoachRouterApp(
          session: const AuthSession(
            accessToken: 'access',
            refreshToken: 'refresh',
            phone: '+919999999999',
            needsCoachRegistration: false,
          ),
          isDarkMode: false,
          themeMode: ThemeMode.light,
          lightTheme: ThemeData(),
          darkTheme: ThemeData(),
          onThemeToggle: _noop,
          onThemeModeChanged: _ignoreThemeMode,
          onSessionChanged: _ignoreSession,
          onLogout: _noop,
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Home'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}

void _ignoreThemeMode(ThemeMode mode) {}

void _ignoreSession(AuthSession? session) {}
