import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CallSessions, ConversationTurns])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // Query: Get all sessions ordered by startTime descending
  Future<List<CallSession>> getAllSessions() {
    return (select(callSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  // Query: Get session by ID
  Future<CallSession?> getSessionById(String id) {
    return (select(callSessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // Query: Get turns for session ordered by sequenceNumber
  Future<List<ConversationTurn>> getTurnsForSession(String sessionId) {
    return (select(conversationTurns)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.sequenceNumber)]))
        .get();
  }

  // Query: Insert session
  Future<void> insertSession(CallSessionsCompanion session) {
    return into(callSessions).insert(session);
  }

  // Query: Update session
  Future<void> updateSession(String id, CallSessionsCompanion session) {
    return (update(callSessions)..where((t) => t.id.equals(id)))
        .write(session);
  }

  // Query: Insert turn
  Future<void> insertTurn(ConversationTurnsCompanion turn) {
    return into(conversationTurns).insert(turn);
  }

  // Query: Get latest session
  Future<CallSession?> getLatestSession() {
    return (select(callSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(1))
        .getSingleOrNull();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cba2026.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
