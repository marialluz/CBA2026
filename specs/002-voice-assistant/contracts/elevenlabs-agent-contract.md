# Contract: ElevenLabs Agent Integration

**Date**: 2026-03-30
**Type**: External service integration (client-side only)

## Overview

The Flutter app integrates with the ElevenLabs Conversational AI
Agent via the official `elevenlabs_agents` SDK. The app is a **client
only** — it does not host any server-side logic. All LLM, RAG, and
TTS processing happens on the ElevenLabs platform.

## SDK Interface

### ConversationClient

The primary integration surface. Used to manage the voice session
lifecycle.

**Initialization**:
```
ConversationClient(
  callbacks: ConversationCallbacks(
    onConnect:                   () → void,
    onDisconnect:                () → void,
    onMessage:                   ({message, source}) → void,
    onUserTranscript:            ({transcript}) → void,
    onTentativeUserTranscript:   ({transcript}) → void,
    onAgentResponseCorrection:   (correction) → void,
    onStatusChange:              (status) → void,
    onModeChange:                (mode) → void,
    onError:                     (message, status) → void,
  ),
)
```

**Session lifecycle**:
```
startSession(agentId: String, userId: String?) → Future<void>
endSession()                                   → Future<void>
dispose()                                      → void
```

**Controls**:
```
setMicMuted(bool)    → void
toggleMute()         → void
sendUserMessage(String) → void   // send text as if spoken
```

### Status Enum

```
ConversationStatus: disconnected | connecting | connected | disconnecting
```

### Mode Enum

```
ConversationMode: listening | speaking
```

## Callback Event Flow (Typical Call)

```
1. startSession(agentId)
2. onStatusChange(connecting)
3. onConnect()
4. onStatusChange(connected)
5. [user speaks]
6. onTentativeUserTranscript({transcript: "Como faço..."})
7. onUserTranscript({transcript: "Como faço para ligar o ar?"})
8. onModeChange(speaking)
9. onMessage({message: "Para ligar o ar...", source: agent})
10. onModeChange(listening)
11. [repeat 5-10 for each turn]
12. endSession()
13. onStatusChange(disconnecting)
14. onDisconnect()
15. onStatusChange(disconnected)
```

## Error Scenarios

| Scenario | SDK Behavior | App Response |
|----------|-------------|--------------|
| Network loss | onError callback fires | Show "Conexão perdida", attempt reconnect up to 30s |
| Agent unavailable | onError with status code | Show error message, return to home |
| Mic permission revoked | Platform audio error | End call, show permission explanation |
| Session timeout | onDisconnect fires | Show "Chamada encerrada", preserve transcript |

## Configuration

Agent configuration is managed on the ElevenLabs platform:
- System prompt (Renault automotive assistant persona; if the user does not state which vehicle they own, the agent asks before answering)
- Knowledge base (owner manuals for the 10 Renault models — Kwid, Logan, Oroch, Duster, Kardian, Kwid E-Tech, Zoe, Kangoo, Megane, Boreal — plus the Renault multimedia system manual)
- Voice settings (Brazilian Portuguese voice)
- Language (pt-BR)

The app MUST NOT hard-code or override any agent configuration.
The only app-side parameter is the agent ID.

## Authentication

**v1**: Public agent mode — no API key needed, connect with agent ID
only.

**Future**: Signed URL mode via a backend service for production
security.
