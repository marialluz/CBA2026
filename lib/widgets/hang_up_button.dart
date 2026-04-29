import 'package:flutter/material.dart';

import '../l10n/strings.dart';

class HangUpButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HangUpButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: Colors.red,
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          Strings.callHangUp,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
