import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart' as db;
import '../l10n/strings.dart';

class TranscriptActions extends StatelessWidget {
  final List<db.ConversationTurn> turns;

  const TranscriptActions({super.key, required this.turns});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.copy),
          tooltip: 'Copiar',
          onPressed: () => _copyTranscript(context),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Compartilhar',
          onPressed: () => _shareTranscript(),
        ),
      ],
    );
  }

  String _formatTranscript() {
    final buffer = StringBuffer();
    buffer.writeln('${Strings.transcriptShareSubject}\n');
    for (final turn in turns) {
      final label =
          turn.speaker == 'user' ? Strings.speakerUser : Strings.speakerAgent;
      buffer.writeln('$label: ${turn.text_}');
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  void _copyTranscript(BuildContext context) {
    final text = _formatTranscript();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(Strings.transcriptCopied),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareTranscript() {
    final text = _formatTranscript();
    Share.share(text, subject: Strings.transcriptShareSubject);
  }
}
