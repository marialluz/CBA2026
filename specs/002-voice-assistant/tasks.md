# Tasks: 

**Input**: Design documents from `/specs/002-voice-assistant/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: REQUIRED — Constitution principle II (Test-First) is NON-NEGOTIABLE. All production code MUST be preceded by a failing test.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter project**: `lib/` for source, `test/` for tests at repository root

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Flutter project initialization and dependency configuration

- [x] T001 Create Flutter project structure with `flutter create` and set up directory layout per plan.md (lib/config/, lib/models/, lib/database/, lib/services/, lib/providers/, lib/screens/, lib/widgets/, lib/l10n/)
- [x] T002 Configure dependencies in pubspec.yaml: `elevenlabs_agents` ^0.4.0, `flutter_riverpod` ^2.x, `drift` ^2.x, `sqlite3_flutter_libs`, `permission_handler` ^11.x, `logging` ^1.x, `mockito` (dev), `build_runner` (dev), `drift_dev` (dev)
- [x] T003 [P] Configure iOS permissions: add `NSMicrophoneUsageDescription` in ios/Runner/Info.plist with pt-BR explanation
- [x] T004 [P] Configure Android permissions: add `RECORD_AUDIO`, `INTERNET`, `MODIFY_AUDIO_SETTINGS` in android/app/src/main/AndroidManifest.xml, set minSdkVersion to 26
- [x] T005 [P] Configure linting rules in analysis_options.yaml with Flutter recommended rules and zero-warning policy

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

### Tests for Foundational

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T006 [P] Unit test for CallSession model and CallStatus enum in test/unit/call_session_test.dart
- [x] T007 [P] Unit test for ConversationTurn model and Speaker enum in test/unit/conversation_turn_test.dart
- [x] T008 [P] Unit test for LoggerService structured logging output in test/unit/logger_service_test.dart

### Implementation for Foundational

- [x] T009 [P] Create CallSession model and CallStatus enum in lib/models/call_session.dart (fields: id, elevenLabsSessionId, startTime, endTime, status, turnCount)
- [x] T010 [P] Create ConversationTurn model and Speaker enum in lib/models/conversation_turn.dart (fields: id, sessionId, sequenceNumber, speaker, text, timestamp)
- [x] T011 Create Drift database tables definition in lib/database/tables.dart (call_sessions and conversation_turns tables with foreign key)
- [x] T012 Create AppDatabase class with Drift in lib/database/app_database.dart (database open, migration strategy, query methods for all 7 queries from data-model.md)
- [x] T013 [P] Create LoggerService with structured logging in lib/services/logger_service.dart (severity levels, session ID metadata, no sensitive data logging)
- [x] T014 [P] Create environment config with ElevenLabs agent ID in lib/config/env.dart
- [x] T015 [P] Create centralized pt-BR UI strings in lib/l10n/strings.dart (all labels, error messages, permission explanations in Brazilian Portuguese)
- [x] T016 Create app entry point in lib/main.dart and root widget with Riverpod ProviderScope in lib/app.dart

**Checkpoint**: Foundation ready — user story implementation can now begin

---

## Phase 3: User Story 1 - Ask the Agent About the Vehicle (Priority: P1) MVP

**Goal**: User taps a call button, speaks in Brazilian Portuguese, and the ElevenLabs agent responds with spoken audio using the owner manual knowledge base. Conversation flows like a phone call.

**Independent Test**: Open app, tap call button, ask "Qual é a pressão recomendada dos pneus?", hear agent response, hang up.

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T017 [P] [US1] Unit test for CallService (session lifecycle: start, status changes, end, error handling, reconnection) with mocked ElevenLabs client in test/unit/call_service_test.dart
- [x] T018 [P] [US1] Unit test for CallProvider (state management: idle → connecting → active → ended, error states) in test/unit/call_provider_test.dart
- [x] T019 [P] [US1] Widget test for HomeScreen (renders call button, taps trigger call) in test/widget/home_screen_test.dart
- [x] T020 [P] [US1] Widget test for CallScreen (displays status indicator, timer, hang-up button; responds to state changes) in test/widget/call_screen_test.dart
- [x] T021 [P] [US1] Integration test for call session lifecycle (connect → speak → agent responds → hang up) with mocked SDK in test/integration/call_session_lifecycle_test.dart

### Implementation for User Story 1

- [x] T022 [US1] Implement CallService wrapping ElevenLabs SDK in lib/services/call_service.dart (startCall, endCall, SDK callbacks: onConnect, onDisconnect, onStatusChange, onModeChange, onUserTranscript, onMessage, onError; reconnection logic up to 30s; microphone permission check via permission_handler)
- [x] T023 [US1] Implement CallProvider with Riverpod in lib/providers/call_provider.dart (exposes call state: idle/connecting/active/ended/error, current mode: listening/speaking, call duration timer, delegates to CallService)
- [x] T024 [P] [US1] Create CallButton widget in lib/widgets/call_button.dart (prominent circular button, pt-BR label)
- [x] T025 [P] [US1] Create CallStatusIndicator widget in lib/widgets/call_status_indicator.dart (displays current state text: "Conectando...", "Ouvindo...", "Respondendo...", "Chamada encerrada", "Erro")
- [x] T026 [P] [US1] Create AudioWaveIndicator widget in lib/widgets/audio_wave_indicator.dart (animated visual feedback for listening and speaking states)
- [x] T027 [P] [US1] Create HangUpButton widget in lib/widgets/hang_up_button.dart (red circular button to end call)
- [x] T028 [US1] Implement HomeScreen in lib/screens/home_screen.dart (app bar with title, centered CallButton, handles microphone permission request with pt-BR explanation, navigates to CallScreen on call start)
- [x] T029 [US1] Implement CallScreen in lib/screens/call_screen.dart (call timer, CallStatusIndicator, AudioWaveIndicator, HangUpButton; handles background lifecycle → ends call; displays reconnection state; navigates back on call end)
- [x] T030 [US1] Add structured logging for all call events in CallService (session start/end, each turn, errors, reconnection attempts) using LoggerService

**Checkpoint**: User Story 1 fully functional — user can have a voice conversation with the agent and hang up

---

## Phase 4: User Story 2 - View Conversation Transcript (Priority: P2)

**Goal**: After ending a call, the user can view a full transcript showing each turn labeled (user vs. agent) in chronological order.

**Independent Test**: Complete a voice call, navigate to transcript screen, verify all turns are displayed with correct speaker labels and chronological order.

### Tests for User Story 2

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T031 [P] [US2] Unit test for TranscriptService (save turns during call, retrieve transcript for session, handle partial transcripts from interrupted calls) in test/unit/transcript_service_test.dart
- [x] T032 [P] [US2] Unit test for TranscriptProvider (loads transcript data, exposes turns list) in test/unit/transcript_provider_test.dart
- [x] T033 [P] [US2] Widget test for TranscriptScreen (renders turn list with speaker labels, scrolls, handles empty transcript) in test/widget/transcript_screen_test.dart

### Implementation for User Story 2

- [x] T034 [US2] Implement TranscriptService in lib/services/transcript_service.dart (createSession, addTurn, updateSessionStatus, getTranscriptForSession, getLatestSession; uses AppDatabase)
- [x] T035 [US2] Implement TranscriptProvider with Riverpod in lib/providers/transcript_provider.dart (loads turns for a session ID, exposes ordered list of ConversationTurn)
- [x] T036 [P] [US2] Create TranscriptMessage widget in lib/widgets/transcript_message.dart (chat bubble style, speaker label "Você" / "Assistente", text content, timestamp)
- [x] T037 [US2] Implement TranscriptScreen in lib/screens/transcript_screen.dart (app bar with "Transcrição" title, scrollable list of TranscriptMessage widgets, empty state message)
- [x] T038 [US2] Integrate transcript capture into CallService: on each onUserTranscript and onMessage callback, persist turn via TranscriptService in lib/services/call_service.dart
- [x] T039 [US2] Add post-call navigation: after call ends on CallScreen, navigate to TranscriptScreen with the session ID in lib/screens/call_screen.dart

**Checkpoint**: User Stories 1 AND 2 both work independently — user can call and then review the transcript

---

## Phase 5: User Story 3 - Copy or Export Transcript (Priority: P3)

**Goal**: While viewing a transcript, the user can copy the full text to the clipboard or share it via the device's native share sheet.

**Independent Test**: Open a transcript, tap copy → verify clipboard content, tap share → verify native share sheet appears with formatted transcript text.

### Tests for User Story 3

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T040 [P] [US3] Widget test for TranscriptActions (copy button triggers clipboard write with confirmation snackbar, share button triggers share sheet) in test/widget/transcript_actions_test.dart

### Implementation for User Story 3

- [x] T041 [P] [US3] Create TranscriptActions widget in lib/widgets/transcript_actions.dart (row with copy icon button and share icon button, formats transcript as readable text with "Você:" / "Assistente:" labels and line breaks)
- [x] T042 [US3] Integrate TranscriptActions into TranscriptScreen (add to app bar or bottom of screen) in lib/screens/transcript_screen.dart
- [x] T043 [US3] Implement copy action: format transcript as plain text, write to clipboard via Flutter Clipboard API, show "Copiado!" snackbar in lib/widgets/transcript_actions.dart
- [x] T044 [US3] Implement share action: format transcript as plain text, invoke platform share sheet via Flutter Share API in lib/widgets/transcript_actions.dart

**Checkpoint**: All user stories independently functional — call, view transcript, copy/share

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T045 [P] Run `flutter analyze` and fix all lint warnings across all files
- [x] T046 [P] Run `flutter test` and verify all tests pass
- [ ] T047 Run quickstart.md validation on a physical iOS device
- [ ] T048 Run quickstart.md validation on a physical Android device
- [x] T049 Review app lifecycle handling: verify call ends on background, transcript persists on interruption across all screens

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational (Phase 2)
- **User Story 2 (Phase 4)**: Depends on Foundational (Phase 2). Integrates with US1 (T038 modifies CallService) but can be tested independently with mock data
- **User Story 3 (Phase 5)**: Depends on US2 (Phase 4) — builds on TranscriptScreen
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational — No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational — Integrates with US1's CallService but transcript viewing is independently testable with test data
- **User Story 3 (P3)**: Depends on US2's TranscriptScreen — adds copy/share actions to it

### Within Each User Story

- Tests MUST be written and FAIL before implementation (Constitution II)
- Models before services
- Services before providers
- Providers before screens
- Widgets (marked [P]) can be built in parallel with each other
- Core implementation before integration points

### Parallel Opportunities

- T003, T004, T005 can run in parallel (Setup phase)
- T006, T007, T008 can run in parallel (Foundational tests)
- T009, T010, T013, T014, T015 can run in parallel (Foundational models/config)
- T017, T018, T019, T020, T021 can run in parallel (US1 tests)
- T024, T025, T026, T027 can run in parallel (US1 widgets)
- T031, T032, T033 can run in parallel (US2 tests)
- T040 independent (US3 test)
- T045, T046 can run in parallel (Polish)

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Unit test for CallService in test/unit/call_service_test.dart"
Task: "Unit test for CallProvider in test/unit/call_provider_test.dart"
Task: "Widget test for HomeScreen in test/widget/home_screen_test.dart"
Task: "Widget test for CallScreen in test/widget/call_screen_test.dart"
Task: "Integration test for call lifecycle in test/integration/call_session_lifecycle_test.dart"

# Launch all widgets for User Story 1 together:
Task: "Create CallButton in lib/widgets/call_button.dart"
Task: "Create CallStatusIndicator in lib/widgets/call_status_indicator.dart"
Task: "Create AudioWaveIndicator in lib/widgets/audio_wave_indicator.dart"
Task: "Create HangUpButton in lib/widgets/hang_up_button.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test on physical device — call the agent, ask about the car, hang up
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test on device → Deploy/Demo (MVP!)
3. Add User Story 2 → Test transcript view → Deploy/Demo
4. Add User Story 3 → Test copy/share → Deploy/Demo
5. Each story adds value without breaking previous stories

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Tests MUST fail before implementation (Constitution principle II)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- All UI strings MUST be in Brazilian Portuguese (from lib/l10n/strings.dart)
- All call events MUST be logged with structured metadata (Constitution principle III)
