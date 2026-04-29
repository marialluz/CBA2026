<!--
  Sync Impact Report
  ==================
  Version change: 0.0.0 → 1.0.0 (initial ratification)

  Modified principles: N/A (first version)

  Added sections:
    - Core Principles: Simplicity First, Test-First, Observability,
      Voice Agent Integration, Cross-Platform Consistency
    - Technology Constraints
    - Development Workflow
    - Governance

  Removed sections: N/A

  Templates requiring updates:
    - .specify/templates/plan-template.md        ✅ compatible (no changes needed)
    - .specify/templates/spec-template.md         ✅ compatible (no changes needed)
    - .specify/templates/tasks-template.md        ✅ compatible (no changes needed)
    - .specify/templates/commands/*.md             ✅ compatible (no changes needed)

  Follow-up TODOs: none
-->

# CBA2026 Constitution

## Core Principles

### I. Simplicity First

Every design decision MUST favor the simplest viable solution.

- YAGNI: features and abstractions MUST NOT be added until a concrete
  requirement demands them.
- No premature abstraction: three similar code paths are preferable to
  a speculative generic helper.
- Widget trees MUST remain shallow and readable; extract widgets only
  when reuse is proven.
- Third-party packages MUST be justified by a clear need that the
  Flutter SDK or Dart standard library cannot satisfy.

**Rationale**: A cross-platform mobile app integrated with an external
voice agent already has significant inherent complexity. Keeping the
application layer simple reduces cognitive load and maintenance cost.

### II. Test-First (NON-NEGOTIABLE)

All production code MUST be preceded by a failing test.

- Red-Green-Refactor cycle is strictly enforced: write a failing test,
  make it pass with minimal code, then refactor.
- Widget tests MUST cover each screen's critical interaction paths.
- Unit tests MUST cover business logic, state management, and data
  transformations.
- Integration tests MUST cover ElevenLabs agent session lifecycle
  (connect, converse, disconnect) using mocked API responses.
- Tests MUST be independently runnable via `flutter test`.

**Rationale**: Voice-agent interactions are inherently difficult to
debug in production. Catching regressions early through disciplined
TDD prevents hard-to-reproduce runtime failures.

### III. Observability

The application MUST produce structured, actionable diagnostic output
at every layer.

- All ElevenLabs agent interactions (session start, turn events,
  errors, session end) MUST be logged with structured metadata
  (session ID, timestamp, event type).
- State transitions in the app MUST be traceable through logs.
- Errors MUST include sufficient context for reproduction: stack
  trace, relevant IDs, and the operation that triggered the failure.
- Logs MUST use severity levels (debug, info, warning, error) and
  MUST NOT log sensitive user data (audio content, personal info).

**Rationale**: Voice agent sessions are ephemeral and real-time.
Without structured observability, diagnosing failures in LLM
responses, TTS playback, or RAG retrieval becomes guesswork.

### IV. Voice Agent Integration

All interaction with the ElevenLabs Conversational AI Agent MUST
follow clear boundary rules.

- The Flutter app is the **client**; the ElevenLabs agent owns LLM
  reasoning, RAG retrieval, and TTS synthesis.
- The app MUST NOT duplicate LLM or RAG logic locally.
- Agent configuration (system prompt, knowledge base, voice settings)
  MUST be managed via the ElevenLabs platform, not hard-coded in the
  Flutter app.
- Network failures and agent unavailability MUST be handled gracefully
  with user-facing feedback (never a silent failure or crash).
- Audio permissions and microphone access MUST be requested
  explicitly and handled for both iOS and Android.

**Rationale**: Clear ownership boundaries between the mobile client
and the cloud-hosted voice agent prevent architectural drift and
ensure each component can evolve independently.

### V. Cross-Platform Consistency

The app MUST deliver a consistent user experience on both iOS and
Android.

- Platform-specific code MUST be isolated behind a clean interface
  (e.g., method channels, platform plugins) so the Dart layer
  remains platform-agnostic.
- UI MUST adapt to platform conventions (Material on Android,
  Cupertino on iOS) where appropriate, but core interaction flows
  MUST remain identical.
- All features MUST be tested on both platforms before release.

**Rationale**: Flutter's cross-platform promise only holds if
platform divergence is actively managed rather than left to drift.

## Technology Constraints

- **Language**: Dart (latest stable) with Flutter SDK.
- **Target platforms**: iOS 15+ and Android API 26+ (minimum).
- **Voice agent**: ElevenLabs Conversational AI Agent (WebSocket-based
  streaming API).
- **State management**: MUST use a single, explicit approach chosen
  before feature work begins (e.g., Riverpod, Bloc, or Provider).
  Mixing state management patterns is prohibited.
- **Dependencies**: Every pub.dev package MUST be actively maintained
  (updated within the last 6 months) and MUST have a clear removal
  path if abandoned.

## Development Workflow

- All code changes MUST go through pull request review before merging
  to the main branch.
- Each PR MUST pass all existing tests (`flutter test`) and lint
  checks (`flutter analyze`) with zero warnings.
- Commits MUST be atomic: one logical change per commit with a
  descriptive message.
- Feature branches MUST be short-lived (merged or rebased within one
  week).

## Governance

This constitution is the highest-authority document for CBA2026
development practices. It supersedes informal conventions,
verbal agreements, and ad-hoc decisions.

- **Amendments** require: (1) a written proposal describing the
  change and its rationale, (2) review by at least one other
  contributor, and (3) an updated version number following SemVer
  rules (MAJOR for principle removals/redefinitions, MINOR for
  additions/expansions, PATCH for clarifications/typos).
- **Compliance**: all PRs and code reviews MUST verify adherence to
  the principles defined above. Violations MUST be resolved before
  merge.
- **Complexity justification**: any deviation from the Simplicity
  First principle MUST be documented in the relevant plan's
  Complexity Tracking table with the rejected simpler alternative.

**Version**: 1.0.0 | **Ratified**: 2026-03-30 | **Last Amended**: 2026-03-30
