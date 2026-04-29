import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cba2026/database/app_database.dart';
import 'package:cba2026/models/conversation_turn.dart' as model;
import 'package:cba2026/services/transcript_service.dart';

void main() {
  late AppDatabase db;
  late TranscriptService transcriptService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    transcriptService = TranscriptService(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TranscriptService', () {
    test('creates a session and retrieves it', () async {
      await transcriptService.createSession(
        sessionId: 'session-1',
        startTime: DateTime(2026, 3, 30, 10, 0),
      );

      final session = await db.getSessionById('session-1');
      expect(session, isNotNull);
      expect(session!.id, 'session-1');
    });

    test('adds turns to a session', () async {
      await transcriptService.createSession(
        sessionId: 'session-1',
        startTime: DateTime(2026, 3, 30, 10, 0),
      );

      await transcriptService.addTurn(
        sessionId: 'session-1',
        speaker: model.Speaker.user,
        text: 'Qual é a pressão dos pneus?',
      );

      await transcriptService.addTurn(
        sessionId: 'session-1',
        speaker: model.Speaker.agent,
        text: 'A pressão recomendada é 32 PSI.',
      );

      final turns = await transcriptService.getTranscriptForSession(
        'session-1',
      );
      expect(turns.length, 2);
      expect(turns[0].speaker, 'user');
      expect(turns[1].speaker, 'agent');
    });

    test('turns are ordered by sequence number', () async {
      await transcriptService.createSession(
        sessionId: 'session-1',
        startTime: DateTime(2026, 3, 30, 10, 0),
      );

      await transcriptService.addTurn(
        sessionId: 'session-1',
        speaker: model.Speaker.user,
        text: 'Primeira pergunta',
      );
      await transcriptService.addTurn(
        sessionId: 'session-1',
        speaker: model.Speaker.agent,
        text: 'Primeira resposta',
      );
      await transcriptService.addTurn(
        sessionId: 'session-1',
        speaker: model.Speaker.user,
        text: 'Segunda pergunta',
      );

      final turns = await transcriptService.getTranscriptForSession(
        'session-1',
      );
      expect(turns[0].sequenceNumber, 1);
      expect(turns[1].sequenceNumber, 2);
      expect(turns[2].sequenceNumber, 3);
    });

    test('updates session status', () async {
      await transcriptService.createSession(
        sessionId: 'session-1',
        startTime: DateTime(2026, 3, 30, 10, 0),
      );

      await transcriptService.updateSessionStatus(
        sessionId: 'session-1',
        status: 'ended',
        endTime: DateTime(2026, 3, 30, 10, 5),
        turnCount: 4,
      );

      final session = await db.getSessionById('session-1');
      expect(session!.status, 'ended');
      expect(session.turnCount, 4);
    });

    test('gets latest session', () async {
      await transcriptService.createSession(
        sessionId: 'session-1',
        startTime: DateTime(2026, 3, 30, 9, 0),
      );
      await transcriptService.createSession(
        sessionId: 'session-2',
        startTime: DateTime(2026, 3, 30, 10, 0),
      );

      final latest = await transcriptService.getLatestSession();
      expect(latest, isNotNull);
      expect(latest!.id, 'session-2');
    });

    test('handles partial transcript from interrupted call', () async {
      await transcriptService.createSession(
        sessionId: 'session-1',
        startTime: DateTime(2026, 3, 30, 10, 0),
      );

      await transcriptService.addTurn(
        sessionId: 'session-1',
        speaker: model.Speaker.user,
        text: 'Pergunta antes da queda',
      );

      // Simulate error — session ends with error status
      await transcriptService.updateSessionStatus(
        sessionId: 'session-1',
        status: 'error',
        endTime: DateTime(2026, 3, 30, 10, 1),
        turnCount: 1,
      );

      // Partial transcript should still be retrievable
      final turns = await transcriptService.getTranscriptForSession(
        'session-1',
      );
      expect(turns.length, 1);
      expect(turns[0].text_, 'Pergunta antes da queda');
    });
  });
}
