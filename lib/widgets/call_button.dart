import 'package:flutter/material.dart';

import '../l10n/strings.dart';

class CallButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CallButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: Colors.green,
            child: const Icon(
              Icons.phone,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          Strings.homeCallButton,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
