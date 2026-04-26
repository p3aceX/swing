import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swing_admin/core/auth/auth_controller.dart';
import 'package:swing_admin/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('Login screen renders branding and form', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('SwingAdmin'), findsOneWidget);
    expect(find.text('Internal ERP · Team access only'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  test('Auth controller rejects wrong password without network', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final err = await container.read(authControllerProvider.notifier).login(
          email: 'adi@swingcricketapp.com',
          password: 'wrong',
        );
    expect(err, isNotNull);
    expect(container.read(authControllerProvider).isLoggedIn, isFalse);
  });

  test('Auth controller rejects unknown email without network', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final err = await container.read(authControllerProvider.notifier).login(
          email: 'random@gmail.com',
          password: 'Swing#123',
        );
    expect(err, isNotNull);
    expect(container.read(authControllerProvider).isLoggedIn, isFalse);
  });
}
