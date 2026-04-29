import 'package:drift/drift.dart';

class CallSessions extends Table {
  TextColumn get id => text()();
  TextColumn get elevenLabsSessionId => text().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get status => text()();
  IntColumn get turnCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class ConversationTurns extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(CallSessions, #id)();
  IntColumn get sequenceNumber => integer()();
  TextColumn get speaker => text()();
  TextColumn get text_ => text().named('text')();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
