import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cba2026/services/call_service.dart';
import 'package:cba2026/providers/call_provider.dart';

@GenerateNiceMocks([MockSpec<CallService>()])
import 'call_provider_test.mocks.dart';

void main() {
  late CallNotifier callNotifier;
  late MockCallService mockCallService;

  setUp(() {
    mockCallService = MockCallService();
    when(mockCallService.callState).thenReturn(CallState.idle);
    when(mockCallService.mode).thenReturn(null);
    when(mockCallService.sessionId).thenReturn(null);
    callNotifier = CallNotifier(callService: mockCallService);
  });

  group('CallNotifier', () {
    test('initial state is idle', () {
      expect(callNotifier.callState, CallState.idle);
    });

    test('initial mode is null', () {
      expect(callNotifier.mode, isNull);
    });

    test('startCall delegates to CallService', () async {
      when(mockCallService.startCall()).thenAnswer((_) async {});

      await callNotifier.startCall();

      verify(mockCallService.startCall()).called(1);
    });

    test('endCall delegates to CallService', () async {
      when(mockCallService.endCall()).thenAnswer((_) async {});

      await callNotifier.endCall();

      verify(mockCallService.endCall()).called(1);
    });

    test('isCallActive returns true when state is active', () {
      when(mockCallService.callState).thenReturn(CallState.active);
      callNotifier = CallNotifier(callService: mockCallService);

      expect(callNotifier.isCallActive, isTrue);
    });

    test('isCallActive returns false when state is idle', () {
      expect(callNotifier.isCallActive, isFalse);
    });
  });
}
