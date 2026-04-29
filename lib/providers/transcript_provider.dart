import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/transcript_service.dart';

class TranscriptNotifier extends ChangeNotifier {
  final TranscriptService? _transcriptService;

  List<ConversationTurn> _turns = [];
  bool _isLoading = false;

  TranscriptNotifier({required TranscriptService transcriptService})
      : _transcriptService = transcriptService;

  /// Create an empty notifier for testing without a database.
  TranscriptNotifier.empty() : _transcriptService = null;

  List<ConversationTurn> get turns => _turns;
  bool get isLoading => _isLoading;

  Future<void> loadTranscript(String sessionId) async {
    if (_transcriptService == null) return;

    _isLoading = true;
    notifyListeners();

    _turns = await _transcriptService.getTranscriptForSession(sessionId);

    _isLoading = false;
    notifyListeners();
  }
}

final transcriptProvider =
    ChangeNotifierProvider.family<TranscriptNotifier, String>(
  (ref, sessionId) {
    final db = ref.watch(databaseProvider);
    final service = TranscriptService(database: db);
    final notifier = TranscriptNotifier(transcriptService: service);
    notifier.loadTranscript(sessionId);
    return notifier;
  },
);
