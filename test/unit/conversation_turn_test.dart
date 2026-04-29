import 'package:flutter_test/flutter_test.dart';
import 'package:cba2026/models/conversation_turn.dart';

void main() {
  group('Speaker', () {
    test('has exactly two values', () {
      expect(Speaker.values.length, 2);
    });

    test('contains user and agent', () {
      expect(Speaker.values, contains(Speaker.user));
      expect(Speaker.values, contains(Speaker.agent));
    });
  });

  group('ConversationTurn', () {
    test('creates with all required fields', () {
      final now = DateTime.now();
      final turn = ConversationTurn(
        id: 'turn-1',
        sessionId: 'session-1',
        sequenceNumber: 1,
        speaker: Speaker.user,
        text: 'Qual é a pressão dos pneus?',
        timestamp: now,
      );

      expect(turn.id, 'turn-1');
      expect(turn.sessionId, 'session-1');
      expect(turn.sequenceNumber, 1);
      expect(turn.speaker, Speaker.user);
      expect(turn.text, 'Qual é a pressão dos pneus?');
      expect(turn.timestamp, now);
    });

    test('user and agent turns have correct speaker', () {
      final now = DateTime.now();
      final userTurn = ConversationTurn(
        id: 'turn-1',
        sessionId: 'session-1',
        sequenceNumber: 1,
        speaker: Speaker.user,
        text: 'Pergunta do usuário',
        timestamp: now,
      );

      final agentTurn = ConversationTurn(
        id: 'turn-2',
        sessionId: 'session-1',
        sequenceNumber: 2,
        speaker: Speaker.agent,
        text: 'Resposta do assistente',
        timestamp: now.add(const Duration(seconds: 3)),
      );

      expect(userTurn.speaker, Speaker.user);
      expect(agentTurn.speaker, Speaker.agent);
      expect(agentTurn.sequenceNumber, greaterThan(userTurn.sequenceNumber));
    });

    test('speakerLabel returns correct pt-BR label', () {
      final now = DateTime.now();
      final userTurn = ConversationTurn(
        id: 'turn-1',
        sessionId: 'session-1',
        sequenceNumber: 1,
        speaker: Speaker.user,
        text: 'teste',
        timestamp: now,
      );
      final agentTurn = ConversationTurn(
        id: 'turn-2',
        sessionId: 'session-1',
        sequenceNumber: 2,
        speaker: Speaker.agent,
        text: 'teste',
        timestamp: now,
      );

      expect(userTurn.speakerLabel, 'Você');
      expect(agentTurn.speakerLabel, 'Assistente');
    });
  });
}
