import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('router declares session routes', () async {
    final file = File('lib/router.dart');
    expect(await file.exists(), isTrue);

    final source = await file.readAsString();
    expect(source, contains("path: '/sessions'"));
    expect(source, contains("path: '/sessions/report'"));
    expect(source, contains("path: '/sessions/:sessionId'"));
  });
}
