# Data Model: Renault Voice Assistant

**Date**: 2026-03-30
**Feature Branch**: `002-voice-assistant`

## Entities

### CallSession

Represents a single voice conversation between the user and the
ElevenLabs agent.

| Field | Type | Constraints |
|-------|------|-------------|
| id | String (UUID) | Primary key, generated locally |
| elevenLabsSessionId | String | Session ID from ElevenLabs SDK, nullable (set after connection) |
| startTime | DateTime | Required, set when call begins |
| endTime | DateTime | Nullable, set when call ends |
| status | CallStatus | Required (active, ended, error) |
| duration | Duration | Computed from startTime and endTime |
| turnCount | int | Number of completed turns, default 0 |

**State transitions**:
```
[initial] → active → ended
                  → error
```
- `active`: call is in progress (connected to agent)
- `ended`: call completed normally (user hung up)
- `error`: call terminated due to an error (network failure,
  permission revocation, agent unavailability)

### ConversationTurn

A single message within a call session — either a user utterance or
an agent response.

| Field | Type | Constraints |
|-------|------|-------------|
| id | String (UUID) | Primary key, generated locally |
| sessionId | String | Foreign key → CallSession.id, required |
| sequenceNumber | int | Order within the session, starting at 1 |
| speaker | Speaker | Required (user, agent) |
| text | String | The transcribed text content, required |
| timestamp | DateTime | When this turn was captured, required |

**Relationships**:
- A `CallSession` has zero or more `ConversationTurn` records
  (ordered by sequenceNumber).
- A `ConversationTurn` belongs to exactly one `CallSession`.

### Enums

**CallStatus**:
- `active` — call in progress
- `ended` — call completed normally
- `error` — call terminated by error

**Speaker**:
- `user` — the human user
- `agent` — the ElevenLabs AI agent

## Storage

Transcripts are stored locally on-device using SQLite (via the
`drift` package). Two tables map directly to the entities above:

- `call_sessions` table
- `conversation_turns` table with a foreign key to `call_sessions`

No cloud synchronization or remote storage in v1.

## Queries

The following queries are needed:

1. **Get all sessions** — list all call sessions ordered by
   startTime descending (for potential future session list screen).
2. **Get session by ID** — retrieve a single call session.
3. **Get turns for session** — retrieve all turns for a given
   session ID, ordered by sequenceNumber ascending.
4. **Insert session** — create a new call session when a call starts.
5. **Update session** — update status, endTime, turnCount when a
   call ends or errors.
6. **Insert turn** — append a turn during an active call.
7. **Get latest session** — retrieve the most recent call session
   (for the post-call transcript screen).
