# Research: Renault Voice Assistant

**Date**: 2026-03-30
**Feature Branch**: `002-voice-assistant`

## R1: ElevenLabs Flutter SDK

**Decision**: Use the official `elevenlabs_agents` package (v0.4.0)
from pub.dev.

**Rationale**: ElevenLabs provides a first-party Flutter SDK that
wraps the Conversational AI WebRTC protocol via LiveKit. It handles
audio capture, streaming, and playback natively, abstracting the
low-level WebSocket and WebRTC complexity. Using the official SDK
aligns with the Simplicity First principle — no need to implement
raw WebSocket audio streaming manually.

**Alternatives considered**:
- Raw WebSocket integration (`wss://api.elevenlabs.io/v1/convai/conversation`):
  rejected because it requires manual audio encoding/decoding,
  VAD handling, and connection management that the SDK already provides.
- Community packages (`elevenlabs_flutter`, `elevenlabs`): rejected
  because they are stale/TTS-only and not maintained by ElevenLabs.

## R2: Audio Protocol

**Decision**: WebRTC via LiveKit (as used by the official SDK).

**Rationale**: The `elevenlabs_agents` SDK depends on `livekit_client`
(^2.6.0) for full-duplex audio streaming. WebRTC provides low-latency,
bidirectional audio natively on both iOS and Android. The SDK handles
all codec negotiation, audio session management, and reconnection
logic internally.

**Alternatives considered**:
- Raw WebSocket with base64 audio chunks: rejected because it would
  require manual audio capture, encoding, buffering, and playback —
  significant complexity with no benefit over the SDK's built-in
  WebRTC layer.

## R3: Transcript Availability

**Decision**: Capture transcripts from SDK callbacks — no separate
STT service needed.

**Rationale**: The ElevenLabs SDK provides transcript data natively
via callbacks:
- `onUserTranscript({transcript})`: finalized user speech-to-text
- `onTentativeUserTranscript({transcript})`: real-time partial
  transcription as the user speaks
- `onMessage({message, source})`: unified callback for both user
  and agent messages
- `onAgentResponseCorrection(correction)`: corrected text when the
  user interrupts the agent

The agent performs STT server-side and returns text alongside audio.
The app only needs to collect and persist these events.

**Alternatives considered**:
- Client-side STT (e.g., `speech_to_text` package): rejected because
  ElevenLabs already provides transcription, and running a parallel
  STT would waste resources and create transcript divergence.

## R4: Authentication Strategy

**Decision**: Use public agent mode (agent ID only, no backend).

**Rationale**: The spec explicitly states "no custom backend." For
public agents, the Flutter app connects directly using the agent ID:
```
await client.startSession(agentId: 'your-agent-id');
```
This is the simplest viable approach for v1. The agent ID is not a
secret — it identifies a publicly accessible agent.

**Alternatives considered**:
- Signed URL with backend: rejected because the spec requires no
  custom backend. This is the recommended production approach and
  should be adopted if/when a backend is added in a future version.

**Risk**: The API key is not exposed (public agents don't need one),
but the agent ID could be extracted from the app binary and used to
make calls outside the app. This is acceptable for v1 given the
no-backend constraint. Document as a known limitation.

## R5: State Management

**Decision**: Use Riverpod for state management.

**Rationale**: The constitution requires a single, explicit state
management approach chosen before feature work begins. Riverpod is
selected because:
- It provides compile-time safety and testability (aligns with
  Test-First principle).
- It supports dependency injection natively, making it easy to mock
  the ElevenLabs client in tests.
- `ConversationClient` extends `ChangeNotifier`, which integrates
  naturally with Riverpod's `ChangeNotifierProvider`.
- It does not require code generation (simpler setup than Bloc).

**Alternatives considered**:
- Bloc: rejected because it requires more boilerplate (events,
  states, blocs) for what is primarily a single-screen call flow.
  Violates Simplicity First for this scope.
- Provider: rejected because Riverpod supersedes it with better
  testability and no `BuildContext` dependency for accessing state.

## R6: Local Transcript Storage

**Decision**: Use SQLite via the `drift` package for local
transcript persistence.

**Rationale**: Transcripts need to persist across app restarts
(multiple calls generate separate transcripts, each independently
accessible). SQLite provides structured queries, is mature on both
platforms, and `drift` offers type-safe Dart code generation with
minimal boilerplate.

**Alternatives considered**:
- Shared preferences / flat JSON files: rejected because querying
  and managing multiple transcripts with ordered turns is better
  suited to a relational model.
- Hive/Isar: viable but `drift` (SQLite) is more widely adopted
  and has a clearer migration path if a backend is added later.

## R7: Platform Permissions

**Decision**: Use `permission_handler` package for cross-platform
microphone permission management.

**Rationale**: The app needs microphone permission on both iOS and
Android. `permission_handler` provides a unified Dart API for
requesting and checking permissions, with platform-specific
configuration via Info.plist (iOS) and AndroidManifest.xml (Android).

**Platform-specific requirements**:
- **iOS**: Add `NSMicrophoneUsageDescription` to Info.plist
- **Android**: Add `RECORD_AUDIO`, `INTERNET`,
  `MODIFY_AUDIO_SETTINGS` permissions to AndroidManifest.xml

## R8: Structured Logging

**Decision**: Use the `logging` package from the Dart SDK.

**Rationale**: The constitution requires structured, leveled logging.
The `logging` package is part of the Dart ecosystem, requires no
additional dependencies, supports severity levels (fine, info,
warning, severe), and can be configured with custom handlers for
structured output. Aligns with Simplicity First — no need for a
heavier logging framework.

**Alternatives considered**:
- `logger` package: rejected because it adds a dependency for
  formatting features not needed in a production mobile app (emoji
  log levels, color output).

## R9: UI Language

**Decision**: Hardcode all UI strings in Brazilian Portuguese (pt-BR)
for v1. No i18n framework.

**Rationale**: The spec targets a single language (Brazilian
Portuguese). Adding an i18n framework (e.g., `flutter_localizations`,
`intl`) for a single language violates Simplicity First. Strings will
be centralized in a single constants file for easy future extraction
if multi-language support is ever needed.

**Alternatives considered**:
- `flutter_localizations` + ARB files: rejected as over-engineering
  for a single-language app. Easy to adopt later if needed.
