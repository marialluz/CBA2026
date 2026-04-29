import 'package:flutter_test/flutter_test.dart';
import 'package:cba2026/models/call_session.dart';

void main() {
  group('CallStatus', () {
    test('has exactly three values', () {
      expect(CallStatus.values.length, 3);
    });

    test('contains active, ended, and error', () {
      expect(CallStatus.values, contains(CallStatus.active));
      expect(CallStatus.values, contains(CallStatus.ended));
      expect(CallStatus.values, contains(CallStatus.error));
    });
  });

  group('CallSession', () {
    test('creates with required fields', () {
      final now = DateTime.now();
      final session = CallSession(
        id: 'test-id-123',
        startTime: now,
        status: CallStatus.active,
      );

      expect(session.id, 'test-id-123');
      expect(session.startTime, now);
      expect(session.status, CallStatus.active);
      expect(session.elevenLabsSessionId, isNull);
      expect(session.endTime, isNull);
      expect(session.turnCount, 0);
    });

    test('creates with all fields', () {
      final start = DateTime(2026, 3, 30, 10, 0);
      final end = DateTime(2026, 3, 30, 10, 5);
      final session = CallSession(
        id: 'test-id-456',
        elevenLabsSessionId: 'el-session-789',
        startTime: start,
        endTime: end,
        status: CallStatus.ended,
        turnCount: 5,
      );

      expect(session.id, 'test-id-456');
      expect(session.elevenLabsSessionId, 'el-session-789');
      expect(session.startTime, start);
      expect(session.endTime, end);
      expect(session.status, CallStatus.ended);
      expect(session.turnCount, 5);
    });

    test('duration returns difference between start and end', () {
      final start = DateTime(2026, 3, 30, 10, 0);
      final end = DateTime(2026, 3, 30, 10, 5);
      final session = CallSession(
        id: 'test-id',
        startTime: start,
        endTime: end,
        status: CallStatus.ended,
      );

      expect(session.duration, const Duration(minutes: 5));
    });

    test('duration returns null when endTime is null', () {
      final session = CallSession(
        id: 'test-id',
        startTime: DateTime.now(),
        status: CallStatus.active,
      );

      expect(session.duration, isNull);
    });

    test('copyWith creates modified copy', () {
      final session = CallSession(
        id: 'test-id',
        startTime: DateTime(2026, 3, 30),
        status: CallStatus.active,
      );

      final ended = session.copyWith(
        status: CallStatus.ended,
        endTime: DateTime(2026, 3, 30, 0, 5),
        turnCount: 3,
      );

      expect(ended.id, session.id);
      expect(ended.startTime, session.startTime);
      expect(ended.status, CallStatus.ended);
      expect(ended.endTime, isNotNull);
      expect(ended.turnCount, 3);
    });
  });
}
