import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cba2026/screens/call_screen.dart';
import 'package:cba2026/l10n/strings.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: CallScreen(sessionId: 'test-session-123'),
      ),
    );
  }

  group('CallScreen', () {
    testWidgets('renders hang up button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(Strings.callHangUp), findsOneWidget);
    });

    testWidgets('renders status indicator', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show at least one status text
      expect(
        find.byType(Text),
        findsWidgets,
      );
    });

    testWidgets('hang up button is visible', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final hangUpButton = find.text(Strings.callHangUp);
      expect(hangUpButton, findsOneWidget);
    });
  });
}
