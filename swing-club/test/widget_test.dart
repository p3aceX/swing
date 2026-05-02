import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swing_club/main.dart';

void main() {
  testWidgets('Theme toggle test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SwingClubApp());

    // Verify that we start in light mode (check for dark_mode icon)
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.text('Switch to Dark Theme'), findsOneWidget);

    // Tap the theme toggle button in the body
    await tester.tap(find.text('Switch to Dark Theme'));
    await tester.pumpAndSettle();

    // Verify that we switched to dark mode (check for light_mode icon)
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(find.text('Switch to Light Theme'), findsOneWidget);
    
    // Tap the theme toggle icon in the AppBar
    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();
    
    // Verify we are back to light mode
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
}
