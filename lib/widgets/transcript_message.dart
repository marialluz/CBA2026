import 'package:flutter/material.dart';

import '../database/app_database.dart' as db;
import '../l10n/strings.dart';

class TranscriptMessage extends StatelessWidget {
  final db.ConversationTurn turn;

  const TranscriptMessage({super.key, required this.turn});

  bool get _isUser => turn.speaker == 'user';

  String get _label => _isUser ? Strings.speakerUser : Strings.speakerAgent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!_isUser) _avatar(theme),
          if (!_isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: _isUser
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(_isUser ? 16 : 4),
                  bottomRight: Radius.circular(_isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _isUser
                          ? theme.colorScheme.primary
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    turn.text_,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          if (_isUser) const SizedBox(width: 8),
          if (_isUser) _avatar(theme),
        ],
      ),
    );
  }

  Widget _avatar(ThemeData theme) {
    return CircleAvatar(
      radius: 16,
      backgroundColor:
          _isUser ? theme.colorScheme.primary : Colors.grey.shade400,
      child: Icon(
        _isUser ? Icons.person : Icons.smart_toy,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}
