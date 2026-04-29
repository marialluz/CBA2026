import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cba2026/services/call_service.dart';
import 'package:cba2026/services/logger_service.dart';

@GenerateNiceMocks([MockSpec<LoggerService>()])
import 'call_service_test.mocks.dart';

void main() {
  late CallService callService;
  late MockLoggerService mockLogger;

  setUp(() {
    mockLogger = MockLoggerService();
    callService = CallService(loggerService: mockLogger);
  });

  group('state', () {
    test('initial state is idle', () {
      expect(callService.callState, CallState.idle);
    });

    test('sessionId is null initially', () {
      expect(callService.sessionId, isNull);
    });
  });

  group('startCall', () {
    test('sets state to connecting and generates sessionId', () {
      // Start call without awaiting — we just check the sync state change
      callService.startCall();

      expect(callService.callState, CallState.connecting);
      expect(callService.sessionId, isNotNull);
    });

    test('logs call start event', () {
      callService.startCall();

      verify(mockLogger.logCallStart(sessionId: anyNamed('sessionId')))
          .called(1);
    });
  });

  group('resetState', () {
    test('resets to idle', () {
      callService.startCall();
      callService.resetState();

      expect(callService.callState, CallState.idle);
      expect(callService.sessionId, isNull);
      expect(callService.errorMessage, isNull);
    });
  });
}
