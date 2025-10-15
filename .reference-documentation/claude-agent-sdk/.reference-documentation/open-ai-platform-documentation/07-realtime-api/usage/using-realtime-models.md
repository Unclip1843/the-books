# OpenAI Platform - Using Realtime Models

**Source:** https://platform.openai.com/docs/guides/realtime/usage
**Fetched:** 2025-10-11

## Overview

Guide to using realtime models effectively.

---

## Available Models

- `gpt-4o-realtime-preview-2024-12-17` - Latest realtime model

---

## Basic Usage

```javascript
// Send text input
ws.send(JSON.stringify({
    type: "conversation.item.create",
    item: {
        type: "message",
        role: "user",
        content: [{
            type: "input_text",
            text: "Hello!"
        }]
    }
}));

// Trigger response
ws.send(JSON.stringify({
    type: "response.create"
}));
```

---

**Source:** https://platform.openai.com/docs/guides/realtime/usage
