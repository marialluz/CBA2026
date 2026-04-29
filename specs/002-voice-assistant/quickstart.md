# Quickstart: Renault Voice Assistant

**Date**: 2026-03-30
**Feature Branch**: `002-voice-assistant`

## Prerequisites

- Flutter SDK (latest stable channel)
- Dart SDK (latest stable, included with Flutter)
- Xcode 15+ (for iOS builds)
- Android Studio or Android SDK (API 26+)
- An ElevenLabs account with a configured Conversational AI Agent
  (agent ID required)
- A physical device for testing (microphone access required —
  simulators have limited audio support)

## Setup

1. Clone the repository and check out the feature branch:
   ```bash
   git clone <repo-url>
   cd CBA2026
   git checkout 002-voice-assistant
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure the ElevenLabs agent ID:
   - Create a file `lib/config/env.dart` with:
     ```dart
     const String elevenLabsAgentId = 'YOUR_AGENT_ID_HERE';
     ```
   - Replace `YOUR_AGENT_ID_HERE` with your actual ElevenLabs agent
     ID.

4. iOS setup — add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>O aplicativo precisa de acesso ao microfone para
   conversar com o assistente de voz da Renault.</string>
   ```

5. Android setup — verify these permissions exist in
   `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO"/>
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
   ```

## Run

```bash
# Run on a connected device
flutter run

# Run tests
flutter test

# Run linting
flutter analyze
```

## Verify

1. Launch the app on a physical device.
2. Tap the call button on the home screen.
3. Grant microphone permission when prompted.
4. Ask a question in Portuguese: "Tenho um Kwid. Qual é a pressão recomendada dos pneus?"
5. Verify the agent responds with spoken audio in Brazilian
   Portuguese.
6. Hang up the call.
7. Verify the transcript is displayed on the post-call screen.
8. Tap copy — verify the text is on the clipboard.
9. Tap share — verify the system share sheet appears.

## Troubleshooting

| Issue | Solution |
|-------|---------|
| "Conexão perdida" on call start | Check internet connection and verify the agent ID is correct |
| No audio from agent | Check device volume and audio output routing (speaker vs. Bluetooth) |
| Microphone permission denied | Go to device Settings > App > Permissions and enable microphone |
| Call drops immediately | Verify the ElevenLabs agent is active and configured on the platform |
| Transcript is empty | Check that the agent is returning transcript events (verify agent config) |
