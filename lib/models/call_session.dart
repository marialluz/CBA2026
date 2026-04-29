enum CallStatus { active, ended, error }

class CallSession {
  final String id;
  final String? elevenLabsSessionId;
  final DateTime startTime;
  final DateTime? endTime;
  final CallStatus status;
  final int turnCount;

  const CallSession({
    required this.id,
    this.elevenLabsSessionId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.turnCount = 0,
  });

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  CallSession copyWith({
    String? id,
    String? elevenLabsSessionId,
    DateTime? startTime,
    DateTime? endTime,
    CallStatus? status,
    int? turnCount,
  }) {
    return CallSession(
      id: id ?? this.id,
      elevenLabsSessionId: elevenLabsSessionId ?? this.elevenLabsSessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      turnCount: turnCount ?? this.turnCount,
    );
  }
}
