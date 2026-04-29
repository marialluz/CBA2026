import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import 'package:uuid/uuid.dart';

import '../config/env.dart';
import '../models/conversation_turn.dart' as model;
import 'logger_service.dart';
import 'transcript_service.dart';

enum CallState { idle, connecting, active, ended, error }

class CallService {
  final LoggerService _loggerService;
  TranscriptService? _transcriptService;
  ConversationClient? _client;

  CallState _callState = CallState.idle;
  ConversationMode? _mode;
  String? _sessionId;
  String? _errorMessage;
  int _turnCount = 0;

  void Function(CallState state)? onStateChanged;
  void Function(ConversationMode mode)? onModeChanged;

  CallState get callState => _callState;
  ConversationMode? get mode => _mode;
  String? get sessionId => _sessionId;
  String? get errorMessage => _errorMessage;
  ConversationClient? get client => _client;

  CallService({
    LoggerService? loggerService,
    TranscriptService? transcriptService,
  })  : _loggerService = loggerService ?? LoggerService(),
        _transcriptService = transcriptService;

  void setTranscriptService(TranscriptService service) {
    _transcriptService = service;
  }

  Future<void> startCall() async {
    // Clean up any previous client
    _client?.dispose();
    _client = null;

    _sessionId = const Uuid().v4();
    _callState = CallState.connecting;
    _errorMessage = null;
    _turnCount = 0;
    onStateChanged?.call(_callState);

    _loggerService.logCallStart(sessionId: _sessionId!);

    await _transcriptService?.createSession(
      sessionId: _sessionId!,
      startTime: DateTime.now(),
    );

    // Create a fresh client for this call
    _client = ConversationClient(
      callbacks: ConversationCallbacks(
        onConnect: ({required String conversationId}) {
          debugPrint('[CBA2026] Connected: $conversationId');
          _callState = CallState.active;
          onStateChanged?.call(_callState);
          if (_sessionId != null) {
            _loggerService.logStatusChange(
              sessionId: _sessionId!,
              status: 'connected',
            );
          }
        },
        onDisconnect: (details) {
          debugPrint('[CBA2026] Disconnected: ${details.reason}');
          if (_callState != CallState.error) {
            _callState = CallState.ended;
            _mode = null;
            onStateChanged?.call(_callState);
          }
          if (_sessionId != null) {
            _loggerService.logCallEnd(sessionId: _sessionId!);
            _transcriptService?.updateSessionStatus(
              sessionId: _sessionId!,
              status: _callState == CallState.error ? 'error' : 'ended',
              endTime: DateTime.now(),
              turnCount: _turnCount,
            );
          }
        },
        onStatusChange: ({required ConversationStatus status}) {
          debugPrint('[CBA2026] Status: ${status.name}');
        },
        onModeChange: ({required ConversationMode mode}) {
          debugPrint('[CBA2026] Mode: ${mode.name}');
          _mode = mode;
          onModeChanged?.call(mode);
        },
        onError: (message, [context]) {
          debugPrint('[CBA2026] Error: $message');
          _errorMessage = _friendlyError(message);
          _callState = CallState.error;
          onStateChanged?.call(_callState);
          if (_sessionId != null) {
            _loggerService.logCallError(
              sessionId: _sessionId!,
              error: message,
            );
          }
        },
        onMessage: ({required String message, required Role source}) {
          debugPrint('[CBA2026] ${source.name}: $message');
          if (source == Role.ai) {
            _persistTurn(model.Speaker.agent, message);
          }
        },
        onUserTranscript: ({
          required String transcript,
          required int eventId,
        }) {
          debugPrint('[CBA2026] User said: "$transcript"');
          _persistTurn(model.Speaker.user, transcript);
        },
        onTentativeUserTranscript: ({
          required String transcript,
          required int eventId,
        }) {
          debugPrint('[CBA2026] User speaking: "$transcript"');
        },
      ),
    );

    try {
      debugPrint('[CBA2026] Starting session with agent: $elevenLabsAgentId');
      await _client!.startSession(agentId: elevenLabsAgentId);
      debugPrint('[CBA2026] startSession returned');
    } catch (e) {
      debugPrint('[CBA2026] startSession error: $e');
      _callState = CallState.error;
      _errorMessage = _friendlyError(e.toString());
      onStateChanged?.call(_callState);
      if (_sessionId != null) {
        _loggerService.logCallError(
          sessionId: _sessionId!,
          error: e.toString(),
        );
      }
    }
  }

  Future<void> endCall() async {
    if (_callState == CallState.idle || _callState == CallState.ended) return;

    try {
      await _client?.endSession();
    } catch (e) {
      debugPrint('[CBA2026] endSession error: $e');
    }

    if (_callState != CallState.ended) {
      _callState = CallState.ended;
      _mode = null;
      onStateChanged?.call(_callState);
    }
  }

  Future<void> _persistTurn(model.Speaker speaker, String text) async {
    if (_sessionId == null) return;
    _turnCount++;
    _loggerService.logTurnEvent(
      sessionId: _sessionId!,
      turnNumber: _turnCount,
      speaker: speaker.name,
    );
    await _transcriptService?.addTurn(
      sessionId: _sessionId!,
      speaker: speaker,
      text: text,
    );
  }

  String _friendlyError(String error) {
    if (error.contains('ice connectivity') ||
        error.contains('PeerConnection')) {
      return 'Não foi possível conectar. Verifique sua conexão com a internet e tente novamente.';
    }
    if (error.contains('timeout') || error.contains('Timed out')) {
      return 'A conexão demorou muito. Tente novamente.';
    }
    if (error.contains('data stream') || error.contains('DataStream')) {
      return 'Erro na transmissão de dados. Verifique sua conexão e tente novamente.';
    }
    return 'Não foi possível conectar ao assistente. Tente novamente.';
  }

  void resetState() {
    _callState = CallState.idle;
    _mode = null;
    _sessionId = null;
    _errorMessage = null;
    onStateChanged?.call(_callState);
  }

  void dispose() {
    _client?.dispose();
    _client = null;
  }
}
