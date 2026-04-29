import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cba2026/screens/home_screen.dart';
import 'package:cba2026/l10n/strings.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(Strings.homeSubtitle), findsOneWidget);
    });

    testWidgets('renders call button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(Strings.homeCallButton), findsOneWidget);
    });

    testWidgets('call button is tappable', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final callButton = find.text(Strings.homeCallButton);
      expect(callButton, findsOneWidget);

      await tester.tap(callButton);
      await tester.pump();
    });
  });
}
