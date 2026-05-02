import 'package:flutter_test/flutter_test.dart';

import 'package:swing_coach/main.dart';

void main() {
  testWidgets('shows OTP login screen and theme toggle', (tester) async {
    await tester.pumpWidget(const SwingCoachApp());

    expect(find.text('Swing Coach'), findsWidgets);
    expect(find.text('Login with OTP'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.byType(ThemeToggle), findsOneWidget);

    await tester.tap(find.byType(ThemeToggle));
    await tester.pump();
  });
}
