import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';


import 'package:cba2026/database/app_database.dart';
import 'package:cba2026/providers/transcript_provider.dart';
import 'package:cba2026/services/transcript_service.dart';

@GenerateNiceMocks([MockSpec<TranscriptService>()])
import 'transcript_provider_test.mocks.dart';

void main() {
  late TranscriptNotifier notifier;
  late MockTranscriptService mockService;

  setUp(() {
    mockService = MockTranscriptService();
    notifier = TranscriptNotifier(transcriptService: mockService);
  });

  group('TranscriptNotifier', () {
    test('initial turns list is empty', () {
      expect(notifier.turns, isEmpty);
    });

    test('initial isLoading is false', () {
      expect(notifier.isLoading, isFalse);
    });

    test('loadTranscript populates turns', () async {
      final mockTurns = [
        ConversationTurn(
          id: 'turn-1',
          sessionId: 'session-1',
          sequenceNumber: 1,
          speaker: 'user',
          text_: 'Pergunta',
          timestamp: DateTime(2026, 3, 30, 10, 0),
        ),
        ConversationTurn(
          id: 'turn-2',
          sessionId: 'session-1',
          sequenceNumber: 2,
          speaker: 'agent',
          text_: 'Resposta',
          timestamp: DateTime(2026, 3, 30, 10, 0, 3),
        ),
      ];

      when(mockService.getTranscriptForSession('session-1'))
          .thenAnswer((_) async => mockTurns);

      await notifier.loadTranscript('session-1');

      expect(notifier.turns.length, 2);
      expect(notifier.turns[0].speaker, 'user');
      expect(notifier.turns[1].speaker, 'agent');
    });

    test('loadTranscript handles empty transcript', () async {
      when(mockService.getTranscriptForSession('session-empty'))
          .thenAnswer((_) async => []);

      await notifier.loadTranscript('session-empty');

      expect(notifier.turns, isEmpty);
    });
  });
}
