import 'package:logging/logging.dart';

class LoggerService {
  final Logger _logger = Logger('CBA2026');

  LoggerService() {
    Logger.root.level = Level.ALL;
  }

  void logCallStart({required String sessionId}) {
    _logger.info('[call:start] sessionId=$sessionId');
  }

  void logCallEnd({required String sessionId}) {
    _logger.info('[call:end] sessionId=$sessionId');
  }

  void logCallError({
    required String sessionId,
    required String error,
  }) {
    _logger.severe('[call:error] sessionId=$sessionId error=$error');
  }

  void logTurnEvent({
    required String sessionId,
    required int turnNumber,
    required String speaker,
  }) {
    _logger.info(
      '[call:turn] sessionId=$sessionId turn=$turnNumber speaker=$speaker',
    );
  }

  void logReconnectionAttempt({
    required String sessionId,
    required int attemptNumber,
  }) {
    _logger.warning(
      '[call:reconnect] sessionId=$sessionId attempt=$attemptNumber',
    );
  }

  void logStatusChange({
    required String sessionId,
    required String status,
  }) {
    _logger.info('[call:status] sessionId=$sessionId status=$status');
  }

  void logModeChange({
    required String sessionId,
    required String mode,
  }) {
    _logger.fine('[call:mode] sessionId=$sessionId mode=$mode');
  }
}
