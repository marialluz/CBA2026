import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/call_service.dart';

class CallStatusIndicator extends StatelessWidget {
  final CallState callState;

  const CallStatusIndicator({super.key, required this.callState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      _statusText,
      style: theme.textTheme.titleLarge?.copyWith(
        color: _statusColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String get _statusText {
    switch (callState) {
      case CallState.idle:
        return '';
      case CallState.connecting:
        return Strings.callConnecting;
      case CallState.active:
        return Strings.callListening;
      case CallState.ended:
        return Strings.callEnded;
      case CallState.error:
        return Strings.callError;
    }
  }

  Color get _statusColor {
    switch (callState) {
      case CallState.idle:
        return Colors.grey;
      case CallState.connecting:
        return Colors.orange;
      case CallState.active:
        return Colors.green;
      case CallState.ended:
        return Colors.grey;
      case CallState.error:
        return Colors.red;
    }
  }
}
