# OpenAI Platform - Webhooks and Server-Side Controls

**Source:** https://platform.openai.com/docs/guides/realtime/webhooks
**Fetched:** 2025-10-11

## Overview

Server-side controls for Realtime API sessions.

---

## Session Configuration

```javascript
// Update session
ws.send(JSON.stringify({
    type: "session.update",
    session: {
        modalities: ["text", "audio"],
        instructions: "You are a helpful assistant",
        voice: "alloy",
        temperature: 0.8
    }
}));
```

---

## Event Handling

```javascript
// Handle server events
ws.on('message', (data) => {
    const event = JSON.parse(data);

    switch(event.type) {
        case "session.created":
            // Session initialized
            break;
        case "response.done":
            // Response complete
            break;
    }
});
```

---

**Source:** https://platform.openai.com/docs/guides/realtime/webhooks
