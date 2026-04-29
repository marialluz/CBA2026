import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:cba2026/services/logger_service.dart';

void main() {
  group('LoggerService', () {
    late LoggerService loggerService;
    late List<LogRecord> capturedRecords;

    setUp(() {
      capturedRecords = [];
      loggerService = LoggerService();
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        capturedRecords.add(record);
      });
    });

    test('logs call start with session ID', () {
      loggerService.logCallStart(sessionId: 'session-123');

      expect(capturedRecords, isNotEmpty);
      final record = capturedRecords.last;
      expect(record.level, Level.INFO);
      expect(record.message, contains('session-123'));
      expect(record.message, contains('start'));
    });

    test('logs call end with session ID', () {
      loggerService.logCallEnd(sessionId: 'session-123');

      expect(capturedRecords, isNotEmpty);
      final record = capturedRecords.last;
      expect(record.level, Level.INFO);
      expect(record.message, contains('session-123'));
      expect(record.message, contains('end'));
    });

    test('logs call error with severity error', () {
      loggerService.logCallError(
        sessionId: 'session-123',
        error: 'Connection timeout',
      );

      expect(capturedRecords, isNotEmpty);
      final record = capturedRecords.last;
      expect(record.level, Level.SEVERE);
      expect(record.message, contains('session-123'));
      expect(record.message, contains('Connection timeout'));
    });

    test('logs turn event with turn details', () {
      loggerService.logTurnEvent(
        sessionId: 'session-123',
        turnNumber: 3,
        speaker: 'user',
      );

      expect(capturedRecords, isNotEmpty);
      final record = capturedRecords.last;
      expect(record.level, Level.INFO);
      expect(record.message, contains('session-123'));
      expect(record.message, contains('3'));
      expect(record.message, contains('user'));
    });

    test('logs reconnection attempt', () {
      loggerService.logReconnectionAttempt(
        sessionId: 'session-123',
        attemptNumber: 2,
      );

      expect(capturedRecords, isNotEmpty);
      final record = capturedRecords.last;
      expect(record.level, Level.WARNING);
      expect(record.message, contains('session-123'));
      expect(record.message, contains('reconnect'));
    });

    test('does not log sensitive data', () {
      loggerService.logTurnEvent(
        sessionId: 'session-123',
        turnNumber: 1,
        speaker: 'user',
      );

      final record = capturedRecords.last;
      // Should not contain audio content or personal info
      expect(record.message, isNot(contains('audio')));
    });
  });
}
