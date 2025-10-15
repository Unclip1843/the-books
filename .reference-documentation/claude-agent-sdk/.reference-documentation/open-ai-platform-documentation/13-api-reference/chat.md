# OpenAI Platform - Chat API Reference

**Source:** https://platform.openai.com/docs/api-reference/chat
**Fetched:** 2025-10-11

## Create Chat Completion

**POST** `/v1/chat/completions`

```python
client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Hello"}],
    temperature=0.7,
    max_tokens=100,
    stream=False
)
```

## Parameters

- `model` (string, required): Model ID
- `messages` (array, required): List of messages
- `temperature` (number, optional): 0-2, default 1
- `max_tokens` (integer, optional): Max tokens to generate
- `stream` (boolean, optional): Stream response
- `top_p` (number, optional): Nucleus sampling
- `frequency_penalty` (number, optional): -2.0 to 2.0
- `presence_penalty` (number, optional): -2.0 to 2.0

## Response

```json
{
  "id": "chatcmpl-123",
  "object": "chat.completion",
  "created": 1677652288,
  "model": "gpt-4o",
  "choices": [{
    "index": 0,
    "message": {
      "role": "assistant",
      "content": "Hello! How can I help?"
    },
    "finish_reason": "stop"
  }],
  "usage": {
    "prompt_tokens": 9,
    "completion_tokens": 12,
    "total_tokens": 21
  }
}
```

---

**Source:** https://platform.openai.com/docs/api-reference/chat
