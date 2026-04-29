import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/strings.dart';
import '../providers/call_provider.dart';
import '../widgets/call_button.dart';
import 'call_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const bgColor = Color(0xFF00122A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 48),
              Image.asset(
                'assets/images/logo_conect2ai.png',
                height: 80,
              ),
              const Spacer(),
              Text(
                Strings.homeSubtitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 48),
              CallButton(
                onPressed: () => _startCall(context, ref),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startCall(BuildContext context, WidgetRef ref) async {
    var status = await Permission.microphone.status;

    // Se nunca perguntou, pedir permissão via diálogo nativo do sistema
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }

    if (!context.mounted) return;

    if (status.isGranted) {
      final notifier = ref.read(callProvider);
      // Inicia a chamada de forma assíncrona — navega imediatamente
      // para o CallScreen que mostrará "Conectando..."
      notifier.startCall();

      if (!context.mounted) return;

      final sessionId = notifier.sessionId;
      if (sessionId != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CallScreen(sessionId: sessionId),
          ),
        );
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      // Já negou permanentemente — precisa ir nas configurações
      _showPermissionDeniedDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(Strings.errorMicPermissionDenied),
        ),
      );
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.micPermissionTitle),
        content: const Text(Strings.micPermissionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text(Strings.micPermissionButton),
          ),
        ],
      ),
    );
  }
}
