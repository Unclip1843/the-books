# Claude API - Messages API Reference

**Source:** https://docs.claude.com/en/api/messages
**Fetched:** 2025-10-11

## Endpoint

```
POST https://api.anthropic.com/v1/messages
```

## Overview

The Messages API is the primary interface for interacting with Claude. It accepts a list of input messages along with optional parameters and returns Claude's response.

**Key characteristics:**
- Stateless (each request is independent)
- Supports both single queries and multi-turn conversations
- Can process text and images
- Supports streaming responses
- Enables tool use (function calling)

## Request Format

### Headers

| Header | Required | Description |
|--------|----------|-------------|
| `x-api-key` | Yes | Your API key |
| `anthropic-version` | Yes | API version (e.g., "2023-06-01") |
| `content-type` | Yes | Must be "application/json" |

### Request Body Parameters

#### Required Parameters

```json
{
  "model": "claude-sonnet-4-5-20250929",
  "max_tokens": 1024,
  "messages": [
    {"role": "user", "content": "Hello, Claude"}
  ]
}
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | string | Model identifier (see [Models](./10-models.md)) |
| `max_tokens` | integer | Maximum tokens to generate (minimum: 1) |
| `messages` | array | Array of message objects |

#### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `system` | string or array | - | System prompt/instructions |
| `temperature` | float | 1.0 | Sampling temperature (0.0-1.0) |
| `top_p` | float | - | Nucleus sampling threshold |
| `top_k` | integer | - | Top-k sampling parameter |
| `stop_sequences` | array | - | Custom stop sequences |
| `stream` | boolean | false | Enable streaming |
| `metadata` | object | - | Custom metadata |
| `tools` | array | - | Available tools (for function calling) |

### Message Structure

Each message must have a `role` and `content`:

```json
{
  "role": "user",  // or "assistant"
  "content": "Message text"
}
```

**Role types:**
- `user` - Messages from the user
- `assistant` - Messages from Claude

**Content types:**
- String (simple text)
- Array (for multimodal content with text and images)

### Multimodal Content

For images, use an array of content blocks:

```json
{
  "role": "user",
  "content": [
    {
      "type": "text",
      "text": "What's in this image?"
    },
    {
      "type": "image",
      "source": {
        "type": "base64",
        "media_type": "image/jpeg",
        "data": "/9j/4AAQSkZJRg..."
      }
    }
  ]
}
```

## Response Format

### Success Response

```json
{
  "id": "msg_01XFDUDYJgAACzvnptvVoYEL",
  "type": "message",
  "role": "assistant",
  "content": [
    {
      "type": "text",
      "text": "Hello! How can I help you today?"
    }
  ],
  "model": "claude-sonnet-4-5-20250929",
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 12,
    "output_tokens": 15
  }
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique message identifier |
| `type` | string | Always "message" |
| `role` | string | Always "assistant" |
| `content` | array | Response content blocks |
| `model` | string | Model used |
| `stop_reason` | string | Why generation stopped |
| `stop_sequence` | string | Stop sequence that triggered |
| `usage` | object | Token usage statistics |

### Stop Reasons

| Reason | Description |
|--------|-------------|
| `end_turn` | Natural completion point |
| `max_tokens` | Reached max_tokens limit |
| `stop_sequence` | Hit a stop sequence |
| `tool_use` | Claude wants to use a tool |

### Content Blocks

Response content is an array of blocks:

**Text block:**
```json
{
  "type": "text",
  "text": "Response text here"
}
```

**Tool use block:**
```json
{
  "type": "tool_use",
  "id": "toolu_01T1x1fJ34qAmk2tNTrN7Up6",
  "name": "get_weather",
  "input": {"location": "San Francisco"}
}
```

## Complete Request Examples

### Basic Text Request

```bash
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "Explain quantum computing"}
    ]
  }'
```

### With System Prompt

```bash
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "system": "You are a physics teacher explaining concepts to high school students",
    "messages": [
      {"role": "user", "content": "Explain quantum computing"}
    ]
  }'
```

### Multi-Turn Conversation

```bash
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "What is the capital of France?"},
      {"role": "assistant", "content": "The capital of France is Paris."},
      {"role": "user", "content": "What about its population?"}
    ]
  }'
```

### With Temperature Control

```bash
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "temperature": 0.0,
    "messages": [
      {"role": "user", "content": "Count from 1 to 10"}
    ]
  }'
```

### With Stop Sequences

```bash
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "stop_sequences": ["\n\n"],
    "messages": [
      {"role": "user", "content": "Write a short story"}
    ]
  }'
```

### With Metadata

```bash
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "metadata": {
      "user_id": "user_12345",
      "session_id": "session_67890"
    },
    "messages": [
      {"role": "user", "content": "Hello"}
    ]
  }'
```

## Error Responses

### 400 - Invalid Request

```json
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "max_tokens is required"
  }
}
```

### 401 - Authentication Error

```json
{
  "type": "error",
  "error": {
    "type": "authentication_error",
    "message": "invalid x-api-key"
  }
}
```

### 429 - Rate Limit

```json
{
  "type": "error",
  "error": {
    "type": "rate_limit_error",
    "message": "rate limit exceeded"
  }
}
```

### 500 - Server Error

```json
{
  "type": "error",
  "error": {
    "type": "api_error",
    "message": "internal server error"
  }
}
```

## Rate Limiting

### Rate Limit Headers

```http
anthropic-ratelimit-requests-limit: 4000
anthropic-ratelimit-requests-remaining: 3999
anthropic-ratelimit-requests-reset: 2024-10-11T12:00:00Z
anthropic-ratelimit-tokens-limit: 400000
anthropic-ratelimit-tokens-remaining: 399500
anthropic-ratelimit-tokens-reset: 2024-10-11T12:00:00Z
```

### Best Practices

1. **Monitor headers:** Check remaining requests/tokens
2. **Implement backoff:** Exponential backoff on 429 errors
3. **Queue requests:** Batch during high load
4. **Cache responses:** Reduce duplicate requests
5. **Use streaming:** Better UX for long responses

## Advanced Features

### Prefilling Assistant Response

You can start Claude's response:

```json
{
  "model": "claude-sonnet-4-5-20250929",
  "max_tokens": 1024,
  "messages": [
    {"role": "user", "content": "Complete this: The capital of France is"},
    {"role": "assistant", "content": "Paris"}
  ]
}
```

Claude will continue from "Paris" or stop if it's complete.

### System Prompt Array

For complex instructions:

```json
{
  "system": [
    {
      "type": "text",
      "text": "You are a helpful assistant",
      "cache_control": {"type": "ephemeral"}
    }
  ]
}
```

### Vision (Images)

See [Vision Guide](./07-vision.md) for detailed image handling.

### Tool Use

See [Tool Use Guide](./08-tool-use.md) for function calling.

### Streaming

See [Streaming Guide](./06-streaming.md) for real-time responses.

### Prompt Caching

See [Prompt Caching Guide](./09-prompt-caching.md) for cost optimization.

## SDK Examples

### Python

```python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Hello, Claude"}
    ]
)

print(message.content[0].text)
```

### TypeScript

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [
    { role: 'user', content: 'Hello, Claude' }
  ],
});

console.log(message.content[0].text);
```

## Related Documentation

- [Getting Started](./02-getting-started.md) - Quick start guide
- [Python SDK](./04-python-sdk.md) - Python SDK reference
- [TypeScript SDK](./05-typescript-sdk.md) - TypeScript SDK reference
- [Streaming](./06-streaming.md) - Streaming responses
- [Vision](./07-vision.md) - Image understanding
- [Tool Use](./08-tool-use.md) - Function calling
- [Models](./10-models.md) - Available models
- [Examples](./11-examples.md) - Common use cases
