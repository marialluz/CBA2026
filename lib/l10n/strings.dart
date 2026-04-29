class Strings {
  Strings._();

  // App
  static const appTitle = 'Renault';

  // Home Screen
  static const homeCallButton = 'Ligar';
  static const homeSubtitle = 'Assistente de Voz';

  // Call Screen
  static const callConnecting = 'Conectando...';
  static const callListening = 'Ouvindo...';
  static const callAgentSpeaking = 'Respondendo...';
  static const callEnded = 'Chamada encerrada';
  static const callError = 'Erro na chamada';
  static const callHangUp = 'Desligar';
  static const callReconnecting = 'Reconectando...';

  // Transcript Screen
  static const transcriptTitle = 'Transcrição';
  static const transcriptEmpty = 'Nenhuma transcrição disponível.';
  static const transcriptCopied = 'Copiado!';
  static const transcriptShareSubject = 'Transcrição - Renault';

  // Speakers
  static const speakerUser = 'Você';
  static const speakerAgent = 'Assistente';

  // Permissions
  static const micPermissionTitle = 'Permissão do Microfone';
  static const micPermissionMessage =
      'O aplicativo precisa de acesso ao microfone para conversar com o '
      'assistente de voz da Renault. '
      'Por favor, habilite o acesso ao microfone nas configurações.';
  static const micPermissionButton = 'Abrir Configurações';

  // Errors
  static const errorConnectionLost = 'Conexão perdida';
  static const errorConnectionFailed = 'Não foi possível conectar ao assistente.';
  static const errorMicPermissionDenied =
      'Acesso ao microfone negado. O assistente de voz precisa do '
      'microfone para funcionar.';
  static const errorUnexpected = 'Ocorreu um erro inesperado.';
  static const errorAgentUnavailable =
      'O assistente está temporariamente indisponível. Tente novamente mais tarde.';
}
