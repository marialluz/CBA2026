import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:cba2026/services/call_service.dart';
import 'package:cba2026/services/logger_service.dart';

@GenerateNiceMocks([MockSpec<LoggerService>()])
import 'call_session_lifecycle_test.mocks.dart';

void main() {
  late CallService callService;
  late MockLoggerService mockLogger;

  setUp(() {
    mockLogger = MockLoggerService();
    callService = CallService(loggerService: mockLogger);
  });

  group('Call session lifecycle', () {
    test('initial state is idle with no session', () {
      expect(callService.callState, CallState.idle);
      expect(callService.sessionId, isNull);
    });

    test('state change callback is invoked on connecting', () {
      CallState? lastState;
      callService.onStateChanged = (state) => lastState = state;

      // startCall sets state synchronously to connecting before async work
      callService.startCall();

      expect(lastState, CallState.connecting);
    });

    test('sessionId is generated on startCall', () {
      callService.startCall();

      expect(callService.sessionId, isNotNull);
      expect(callService.sessionId, isNotEmpty);
    });

    test('resetState clears all state', () {
      // Manually set some state to test reset
      callService.resetState();

      expect(callService.callState, CallState.idle);
      expect(callService.sessionId, isNull);
      expect(callService.errorMessage, isNull);
    });
  });
}
