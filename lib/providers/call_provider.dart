import 'dart:async';

import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import '../services/call_service.dart';
import '../services/logger_service.dart';
import '../services/transcript_service.dart';

class CallNotifier extends ChangeNotifier {
  final CallService _callService;
  CallService get callService => _callService;
  Timer? _durationTimer;
  Duration _callDuration = Duration.zero;

  CallNotifier({CallService? callService})
      : _callService = callService ??
            CallService(loggerService: LoggerService()) {
    _callService.onStateChanged = _onStateChanged;
    _callService.onModeChanged = _onModeChanged;
  }

  CallState get callState => _callService.callState;
  ConversationMode? get mode => _callService.mode;
  String? get sessionId => _callService.sessionId;
  String? get errorMessage => _callService.errorMessage;
  Duration get callDuration => _callDuration;

  bool get isCallActive => callState == CallState.active;
  bool get isConnecting => callState == CallState.connecting;

  void _onStateChanged(CallState state) {
    if (state == CallState.active) {
      _startDurationTimer();
    } else if (state == CallState.ended || state == CallState.error) {
      _stopDurationTimer();
    }
    notifyListeners();
  }

  void _onModeChanged(ConversationMode mode) {
    notifyListeners();
  }

  Future<void> startCall() async {
    _callDuration = Duration.zero;
    await _callService.startCall();
  }

  Future<void> endCall() async {
    await _callService.endCall();
  }

  void resetState() {
    _stopDurationTimer();
    _callDuration = Duration.zero;
    _callService.resetState();
    notifyListeners();
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _callDuration += const Duration(seconds: 1);
        notifyListeners();
      },
    );
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  @override
  void dispose() {
    _stopDurationTimer();
    _callService.dispose();
    super.dispose();
  }
}

final callProvider = ChangeNotifierProvider<CallNotifier>((ref) {
  final db = ref.watch(databaseProvider);
  final transcriptService = TranscriptService(database: db);
  final callService = CallService(
    loggerService: LoggerService(),
    transcriptService: transcriptService,
  );
  return CallNotifier(callService: callService);
});
