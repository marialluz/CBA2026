# Feature Specification: Renault Voice Assistant

**Feature Branch**: `002-renault-voice-assistant`
**Created**: 2026-03-30
**Status**: Draft
**Input**: User description: "Build a mobile voice assistant for Renault customers in Brazil. The main interaction is a real-time voice conversation with an AI agent — the interface resembles a phone call, where the user taps to start a call, speaks naturally, and the agent responds with spoken audio in Brazilian Portuguese. The agent's knowledge base covers all 10 vehicles in the Renault lineup — combustion (Kwid, Logan, Oroch, Duster, Kardian), electric (Kwid E-Tech, Zoe, Kangoo, Megane), and the Boreal hybrid — plus the Renault multimedia system manual. The user is expected to mention which vehicle they own; if they do not, the agent is configured to ask before answering. After the conversation ends, the user can view a full transcript of the call and copy or export it. All AI capabilities — speech recognition, language understanding, knowledge retrieval, and voice synthesis — are handled by an ElevenLabs Conversational AI Agent with no custom backend."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ask the Agent About the Vehicle (Priority: P1)

A Renault customer opens the app and taps a "call" button to start a
voice conversation. The interface presents a phone-call-like screen.
The user speaks naturally in Brazilian Portuguese — for example,
"Tenho um Kwid. Como faço para ativar o piloto automático?" — and
the agent responds with spoken audio, drawing from the Renault
knowledge base. If the user does not mention which model they own,
the agent will ask before answering. The conversation flows back and
forth like a phone call until the user hangs up.

**Why this priority**: This is the core value proposition. The entire
app exists to let owners ask questions about their car and get
immediate, conversational answers in their language. Without this,
the app delivers no value.

**Independent Test**: Can be fully tested by opening the app, tapping
the call button, asking a question about a Renault model (e.g.,
"Tenho um Duster. Qual é a pressão recomendada dos pneus?"), hearing
the agent's spoken response, and ending the call. Delivers the
complete voice-assistant experience.

**Acceptance Scenarios**:

1. **Given** the user is on the home screen, **When** they tap the
   call button and microphone permission is granted, **Then** the app
   displays a call-in-progress screen and connects to the voice agent
   within 3 seconds.
2. **Given** a call is active and the agent is listening, **When**
   the user asks a question about their Renault vehicle in Brazilian
   Portuguese (stating the model, or being prompted to identify it),
   **Then** the agent responds with a spoken answer in Brazilian
   Portuguese, sourcing information from the relevant owner manual
   in the Renault knowledge base.
3. **Given** a call is active, **When** the user asks a follow-up
   question related to the previous answer, **Then** the agent
   maintains conversational context and responds coherently.
4. **Given** a call is active, **When** the user taps the "hang up"
   button, **Then** the call ends gracefully and the user returns to
   the home screen.
5. **Given** the user has not yet granted microphone permission,
   **When** they tap the call button, **Then** the app displays a
   clear explanation (in Portuguese) of why microphone access is
   needed and prompts the user to grant it.

---

### User Story 2 - View Conversation Transcript (Priority: P2)

After ending a voice call, the user can view a full written
transcript of the conversation they just had. The transcript shows
each exchange (user utterance and agent response) in readable text
format, allowing the user to review the information discussed.

**Why this priority**: Spoken information is hard to remember. A
transcript turns the ephemeral voice interaction into a persistent,
searchable reference. This is especially valuable for technical
details from the owner manual (tire pressures, maintenance
intervals, warning light meanings).

**Independent Test**: Can be tested by completing a voice call, then
navigating to the transcript view and verifying that the text
accurately reflects the spoken conversation, with clear attribution
of who said what.

**Acceptance Scenarios**:

1. **Given** a voice call has just ended, **When** the user is
   returned to the post-call screen, **Then** they see an option to
   view the transcript of that conversation.
2. **Given** the user opens the transcript, **When** the transcript
   loads, **Then** it displays the full conversation with each turn
   clearly labeled (user vs. agent) and ordered chronologically.
3. **Given** the user is viewing a transcript, **When** they scroll
   through it, **Then** all exchanges from the call are present and
   the text accurately reflects what was spoken.

---

### User Story 3 - Copy or Export Transcript (Priority: P3)

While viewing a conversation transcript, the user can copy the full
text to the clipboard or share/export it via the device's standard
sharing capabilities (e.g., WhatsApp, email, notes app). This lets
the user save important information from the conversation for later
reference or share it with a mechanic, family member, or dealership.

**Why this priority**: Adds practical utility to transcripts but is
not required for the core experience. Users can already read
transcripts (P2); export makes them portable. Can be built
independently on top of the transcript view.

**Independent Test**: Can be tested by opening a transcript, tapping
the copy button and verifying the text is on the clipboard, then
tapping the share button and verifying the system share sheet appears
with the transcript content.

**Acceptance Scenarios**:

1. **Given** the user is viewing a transcript, **When** they tap the
   "copy" button, **Then** the full transcript text is copied to the
   device clipboard and a confirmation message is shown.
2. **Given** the user is viewing a transcript, **When** they tap the
   "share" button, **Then** the device's native share sheet appears
   with the transcript text pre-loaded, allowing the user to send it
   via any installed app (WhatsApp, email, etc.).
3. **Given** the user has copied the transcript, **When** they paste
   it into another app, **Then** the pasted text is readable and
   properly formatted with turn labels and line breaks.

---

### Edge Cases

- What happens when the user asks a question unrelated to Renault
  vehicles? The agent MUST respond politely, indicating that it
  specializes in Renault vehicle topics, and guide the user back to
  vehicle-related questions.
- What happens when the user does not state which Renault model they
  own? The agent MUST ask the user to identify the vehicle before
  providing model-specific information (handled by the agent's
  configured prompt on the ElevenLabs platform).
- What happens when the network connection drops during a call? The
  app MUST display a clear message ("Conexão perdida"), attempt
  automatic reconnection for up to 30 seconds, and if unsuccessful,
  end the call gracefully and preserve any transcript generated so
  far.
- What happens when the user backgrounds the app during a call? The
  call MUST end and any partial transcript MUST be preserved.
- What happens when the agent cannot find relevant information in the
  knowledge base? The agent MUST acknowledge the gap honestly rather
  than fabricating an answer (e.g., "Não encontrei essa informação
  no manual. Recomendo consultar a concessionária Renault.").
- What happens when microphone permission is revoked mid-call? The
  call MUST end immediately with a clear message explaining that
  microphone access was lost.
- What happens when the device speaker/audio output is unavailable
  (e.g., Bluetooth disconnected mid-call)? The app MUST respect
  system audio routing changes and continue through whatever output
  is currently active.
- What happens when multiple calls are completed in a session? Each
  call MUST generate its own separate transcript, accessible
  independently.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST provide a single, prominent "call" button
  on the home screen to start a voice conversation.
- **FR-002**: The app MUST request microphone permission before the
  first call, with an explanation in Brazilian Portuguese.
- **FR-003**: The app MUST display a call-in-progress interface
  resembling a phone call (call timer, hang-up button, visual audio
  indicator).
- **FR-004**: The app MUST stream the user's voice input to the
  ElevenLabs Conversational AI Agent in real time.
- **FR-005**: The app MUST play the agent's spoken responses through
  the device's active audio output in real time.
- **FR-006**: All agent responses MUST be in Brazilian Portuguese.
- **FR-007**: The agent MUST draw answers from the Renault knowledge
  base configured on the ElevenLabs platform, which contains the
  owner manuals for all 10 Renault models in scope plus the Renault
  multimedia system manual.
- **FR-008**: The app MUST display the current call state at all
  times (connecting, listening, agent responding, call ended, error).
- **FR-009**: The app MUST allow the user to end a call at any time
  via a clearly visible "hang up" control.
- **FR-010**: The app MUST detect network interruptions during a call
  and attempt automatic reconnection for up to 30 seconds before
  ending the call.
- **FR-011**: The app MUST display user-facing error messages in
  Brazilian Portuguese when errors occur (never a blank screen or
  silent failure).
- **FR-012**: The app MUST end the call when the app moves to the
  background.
- **FR-013**: The app MUST generate and store a text transcript for
  each completed call, with each turn labeled (user vs. agent).
- **FR-014**: The app MUST provide a post-call screen where the user
  can view the full transcript.
- **FR-015**: The app MUST allow the user to copy the full transcript
  text to the device clipboard.
- **FR-016**: The app MUST allow the user to share/export the
  transcript via the device's native share sheet.
- **FR-017**: The app MUST log all call events (start, turn events,
  errors, end) with structured metadata for observability.

### Key Entities

- **Call Session**: A single voice conversation between the user and
  the agent. Key attributes: session identifier, start time, end
  time, status (active, ended, error), total duration, number of
  turns.
- **Conversation Turn**: A single exchange within a call (user
  utterance followed by agent response). Key attributes: turn
  sequence number, speaker (user or agent), spoken text content,
  timestamp.
- **Transcript**: The complete written record of a call session. Key
  attributes: associated call session, ordered list of conversation
  turns, creation timestamp.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can start a voice call within 5 seconds of
  tapping the call button (including connection setup).
- **SC-002**: 90% of voice calls complete without errors or
  interruptions requiring user intervention.
- **SC-003**: Users can hold a multi-turn conversation (at least 5
  back-and-forth exchanges) without the call dropping.
- **SC-004**: When a network interruption occurs, the app displays
  feedback to the user within 2 seconds.
- **SC-005**: 95% of users who grant microphone permission
  successfully complete their first voice call on the first attempt.
- **SC-006**: Transcripts are available for viewing within 2 seconds
  of a call ending.
- **SC-007**: Copied or shared transcripts are readable and properly
  formatted (clear turn labels, line breaks, chronological order).
- **SC-008**: The app's entire user-facing interface (labels, error
  messages, prompts) is in Brazilian Portuguese.

## Assumptions

- Users are Renault customers in Brazil who own one of the 10
  in-scope models (Kwid, Logan, Oroch, Duster, Kardian, Kwid E-Tech,
  Zoe, Kangoo, Megane, or Boreal) and speak Brazilian Portuguese.
- Users have a stable internet connection (Wi-Fi or cellular data)
  sufficient for real-time audio streaming.
- The ElevenLabs Conversational AI Agent is pre-configured on the
  ElevenLabs platform with: the owner manuals for all 10 Renault
  models plus the Renault multimedia system manual as the knowledge
  base, Brazilian Portuguese as the conversation language, and a
  system prompt that asks the user to identify their vehicle before
  answering model-specific questions if not already stated.
- There is no custom backend; the mobile app connects directly to the
  ElevenLabs agent.
- No user authentication is required; any user who installs the app
  can start a call.
- Transcripts are stored locally on the device only (no cloud sync
  or cross-device access in this version).
- The app supports a single concurrent call per device.
- The ElevenLabs agent provides transcript data (spoken text for each
  turn) as part of its conversation events, which the app captures
  and stores locally.
