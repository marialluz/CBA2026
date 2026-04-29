import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cba2026/screens/transcript_screen.dart';
import 'package:cba2026/providers/transcript_provider.dart';
import 'package:cba2026/l10n/strings.dart';

void main() {
  Widget createTestWidget() {
    // Override the provider to avoid real database creation
    return ProviderScope(
      overrides: [
        transcriptProvider('test-session').overrideWith(
          (ref) {
            return TranscriptNotifier.empty();
          },
        ),
      ],
      child: const MaterialApp(
        home: TranscriptScreen(sessionId: 'test-session'),
      ),
    );
  }

  group('TranscriptScreen', () {
    testWidgets('renders transcript title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(Strings.transcriptTitle), findsOneWidget);
    });

    testWidgets('shows empty state when no turns', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(Strings.transcriptEmpty), findsOneWidget);
    });
  });
}
