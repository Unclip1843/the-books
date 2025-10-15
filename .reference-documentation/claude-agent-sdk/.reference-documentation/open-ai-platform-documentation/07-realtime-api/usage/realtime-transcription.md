# OpenAI Platform - Realtime Transcription

**Source:** https://platform.openai.com/docs/guides/realtime/transcription
**Fetched:** 2025-10-11

## Overview

Real-time audio transcription with Realtime API.

---

## Enable Transcription

```javascript
// Configure session for transcription
ws.send(JSON.stringify({
    type: "session.update",
    session: {
        modalities: ["audio"],
        input_audio_transcription: {
            model: "whisper-1"
        }
    }
}));
```

---

## Receive Transcripts

```javascript
// Listen for transcription events
ws.on('message', (data) => {
    const event = JSON.parse(data);
    if (event.type === "conversation.item.input_audio_transcription.completed") {
        console.log("Transcript:", event.transcript);
    }
});
```

---

**Source:** https://platform.openai.com/docs/guides/realtime/transcription
