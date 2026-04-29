enum Speaker { user, agent }

class ConversationTurn {
  final String id;
  final String sessionId;
  final int sequenceNumber;
  final Speaker speaker;
  final String text;
  final DateTime timestamp;

  const ConversationTurn({
    required this.id,
    required this.sessionId,
    required this.sequenceNumber,
    required this.speaker,
    required this.text,
    required this.timestamp,
  });

  String get speakerLabel {
    switch (speaker) {
      case Speaker.user:
        return 'Você';
      case Speaker.agent:
        return 'Assistente';
    }
  }
}
