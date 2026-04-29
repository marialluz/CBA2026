import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/strings.dart';
import '../providers/transcript_provider.dart';
import '../widgets/transcript_actions.dart';
import '../widgets/transcript_message.dart';

class TranscriptScreen extends ConsumerWidget {
  final String sessionId;

  const TranscriptScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transcript = ref.watch(transcriptProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.transcriptTitle),
        actions: [
          if (transcript.turns.isNotEmpty)
            TranscriptActions(turns: transcript.turns),
        ],
      ),
      body: transcript.isLoading
          ? const Center(child: CircularProgressIndicator())
          : transcript.turns.isEmpty
              ? const Center(
                  child: Text(
                    Strings.transcriptEmpty,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: transcript.turns.length,
                  itemBuilder: (context, index) {
                    return TranscriptMessage(
                      turn: transcript.turns[index],
                    );
                  },
                ),
    );
  }
}
