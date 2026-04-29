import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/strings.dart';
import '../providers/call_provider.dart';
import '../services/call_service.dart';
import '../widgets/audio_wave_indicator.dart';
import '../widgets/call_status_indicator.dart';
import '../widgets/hang_up_button.dart';
import 'transcript_screen.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const CallScreen({super.key, required this.sessionId});

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen>
    with WidgetsBindingObserver {
  bool _wasEverActive = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final notifier = ref.read(callProvider);
      if (notifier.isCallActive || notifier.isConnecting) {
        notifier.endCall();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final call = ref.watch(callProvider);
    final isActive = call.isCallActive || call.isConnecting;

    // Rastrear se a chamada chegou a ficar ativa
    if (call.callState == CallState.active) {
      _wasEverActive = true;
    }

    // Só navegar para transcrição se a chamada já esteve ativa e terminou
    if (!_hasNavigated && _wasEverActive && call.callState == CallState.ended) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  TranscriptScreen(sessionId: widget.sessionId),
            ),
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              CallStatusIndicator(callState: call.callState),
              const SizedBox(height: 8),
              Text(
                _formatDuration(call.callDuration),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 48),
              AudioWaveIndicator(isActive: isActive),
              const SizedBox(height: 24),
              if (call.mode != null)
                Text(
                  call.mode!.name == 'listening'
                      ? Strings.callListening
                      : Strings.callAgentSpeaking,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              const Spacer(),
            // Erro: mostrar mensagem e botão de voltar
            if (call.callState == CallState.error) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  call.errorMessage ?? Strings.errorConnectionFailed,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  ref.read(callProvider).resetState();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Voltar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
            if (call.callState != CallState.error)
              HangUpButton(
                onPressed: () async {
                  await ref.read(callProvider).endCall();
                },
              ),
            const SizedBox(height: 48),
          ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
