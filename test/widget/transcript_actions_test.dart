import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cba2026/database/app_database.dart' as db;
import 'package:cba2026/widgets/transcript_actions.dart';

void main() {
  final mockTurns = [
    db.ConversationTurn(
      id: 'turn-1',
      sessionId: 'session-1',
      sequenceNumber: 1,
      speaker: 'user',
      text_: 'Qual é a pressão dos pneus?',
      timestamp: DateTime(2026, 3, 30, 10, 0),
    ),
    db.ConversationTurn(
      id: 'turn-2',
      sessionId: 'session-1',
      sequenceNumber: 2,
      speaker: 'agent',
      text_: 'A pressão recomendada é 32 PSI.',
      timestamp: DateTime(2026, 3, 30, 10, 0, 3),
    ),
  ];

  group('TranscriptActions', () {
    testWidgets('renders copy and share buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TranscriptActions(turns: mockTurns),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('copy button copies text to clipboard', (tester) async {
      String? clipboardContent;

      // Mock clipboard
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            clipboardContent =
                (methodCall.arguments as Map)['text'] as String;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TranscriptActions(turns: mockTurns),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      expect(clipboardContent, isNotNull);
      expect(clipboardContent, contains('Você'));
      expect(clipboardContent, contains('Assistente'));
      expect(clipboardContent, contains('pressão dos pneus'));
      expect(clipboardContent, contains('32 PSI'));
    });

    testWidgets('shows snackbar after copy', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (methodCall) async => null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TranscriptActions(turns: mockTurns),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      expect(find.text('Copiado!'), findsOneWidget);
    });
  });
}
