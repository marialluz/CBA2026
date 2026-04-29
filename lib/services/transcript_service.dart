import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/conversation_turn.dart' as model;

class TranscriptService {
  final AppDatabase _database;
  int _turnCounter = 0;

  TranscriptService({required AppDatabase database}) : _database = database;

  Future<void> createSession({
    required String sessionId,
    required DateTime startTime,
  }) async {
    _turnCounter = 0;
    await _database.insertSession(
      CallSessionsCompanion.insert(
        id: sessionId,
        startTime: startTime,
        status: 'active',
      ),
    );
  }

  Future<void> addTurn({
    required String sessionId,
    required model.Speaker speaker,
    required String text,
  }) async {
    _turnCounter++;
    await _database.insertTurn(
      ConversationTurnsCompanion.insert(
        id: const Uuid().v4(),
        sessionId: sessionId,
        sequenceNumber: _turnCounter,
        speaker: speaker.name,
        text_: text,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> updateSessionStatus({
    required String sessionId,
    required String status,
    DateTime? endTime,
    int? turnCount,
  }) async {
    await _database.updateSession(
      sessionId,
      CallSessionsCompanion(
        status: Value(status),
        endTime: Value(endTime),
        turnCount: Value(turnCount ?? _turnCounter),
      ),
    );
  }

  Future<List<ConversationTurn>> getTranscriptForSession(
    String sessionId,
  ) async {
    return _database.getTurnsForSession(sessionId);
  }

  Future<CallSession?> getLatestSession() async {
    return _database.getLatestSession();
  }
}
