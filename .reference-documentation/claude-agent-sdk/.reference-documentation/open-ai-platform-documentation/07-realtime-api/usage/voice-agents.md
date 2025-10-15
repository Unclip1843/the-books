# OpenAI Platform - Voice Agents

**Source:** https://platform.openai.com/docs/guides/realtime/voice-agents
**Fetched:** 2025-10-11

## Overview

Build voice-enabled agents with Realtime API.

---

## Voice Configuration

```javascript
// Set voice and configuration
ws.send(JSON.stringify({
    type: "session.update",
    session: {
        voice: "alloy",  // alloy, echo, fable, onyx, nova, shimmer
        turn_detection: {
            type: "server_vad",
            threshold: 0.5,
            prefix_padding_ms: 300,
            silence_duration_ms: 500
        }
    }
}));
```

---

## Voice Activity Detection

```javascript
// Server-side VAD automatically detects speech
// No manual turn management needed
```

---

**Source:** https://platform.openai.com/docs/guides/realtime/voice-agents
