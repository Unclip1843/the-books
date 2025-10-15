# OpenAI Platform - Managing Conversations

**Source:** https://platform.openai.com/docs/guides/realtime/conversations
**Fetched:** 2025-10-11

## Overview

Manage multi-turn conversations in Realtime API.

---

## Conversation Management

```javascript
// Add message to conversation
ws.send(JSON.stringify({
    type: "conversation.item.create",
    item: {
        type: "message",
        role: "user",
        content: [{ type: "input_text", text: "Message" }]
    }
}));

// List conversation items
ws.send(JSON.stringify({
    type: "conversation.item.list"
}));

// Delete conversation item
ws.send(JSON.stringify({
    type: "conversation.item.delete",
    item_id: "msg_001"
}));
```

---

**Source:** https://platform.openai.com/docs/guides/realtime/conversations
