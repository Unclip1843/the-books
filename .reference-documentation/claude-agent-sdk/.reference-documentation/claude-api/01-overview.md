# Claude API - Overview

**Source:** https://docs.claude.com/en/api/overview
**Fetched:** 2025-10-11

## What is the Claude API?

The Claude API provides developers with programmatic access to Anthropic's Claude AI models through a REST API. It enables you to integrate Claude's capabilities into your applications for text generation, analysis, vision tasks, and more.

## Key Features

### Core Capabilities
- **Text Generation** - Generate high-quality text responses
- **Conversation** - Multi-turn conversations with context
- **Vision** - Analyze and understand images
- **Tool Use** - Function calling and external tool integration
- **Streaming** - Real-time response streaming
- **Prompt Caching** - Cost optimization for repeated prompts
- **Batch Processing** - Async processing of multiple requests

### API Characteristics
- **REST-based** - Standard HTTP requests and responses
- **JSON format** - Always accepts and returns JSON
- **Stateless** - Each request is independent
- **Streaming support** - Server-sent events (SSE) for real-time responses
- **Rate limits** - Configurable per organization

## Authentication

### API Keys

All API requests require authentication using an API key.

1. **Get your API key** from the [Anthropic Console](https://console.anthropic.com/settings/keys)
2. **Set environment variable:**
   ```bash
   export ANTHROPIC_API_KEY='your-api-key-here'
   ```

3. **Include in requests:**
   ```bash
   curl https://api.anthropic.com/v1/messages \
     -H "x-api-key: $ANTHROPIC_API_KEY" \
     -H "anthropic-version: 2023-06-01" \
     -H "content-type: application/json"
   ```

### Security Best Practices
- Never commit API keys to version control
- Use environment variables or secure vaults
- Rotate keys periodically
- Use different keys for development/production
- Monitor usage in the Console

## API Endpoints

### Base URL
```
https://api.anthropic.com
```

### Main Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v1/messages` | POST | Create a message (main endpoint) |
| `/v1/messages/batches` | POST | Create a batch of messages |
| `/v1/messages/batches/{id}` | GET | Retrieve batch status |
| `/v1/models` | GET | List available models |
| `/v1/complete` | POST | Legacy completions (deprecated) |

## Request Structure

### Required Headers

```http
POST /v1/messages HTTP/1.1
Host: api.anthropic.com
x-api-key: YOUR_API_KEY
anthropic-version: 2023-06-01
content-type: application/json
```

**Header Details:**
- `x-api-key` - Your authentication key (required)
- `anthropic-version` - API version date (required)
- `content-type` - Must be `application/json` (required)

### Request Body

```json
{
  "model": "claude-sonnet-4-5-20250929",
  "max_tokens": 1024,
  "messages": [
    {
      "role": "user",
      "content": "Hello, Claude"
    }
  ]
}
```

**Core Parameters:**
- `model` (required) - Model identifier
- `max_tokens` (required) - Maximum tokens to generate (minimum 1)
- `messages` (required) - Array of message objects

### Optional Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `system` | string or array | System prompt/instructions |
| `temperature` | float | Randomness (0.0-1.0, default 1.0) |
| `top_p` | float | Nucleus sampling (0.0-1.0) |
| `top_k` | integer | Top-k sampling |
| `stop_sequences` | array | Sequences that stop generation |
| `stream` | boolean | Enable streaming (default false) |
| `tools` | array | Available tools for function calling |
| `metadata` | object | Custom metadata |

## Response Structure

### Successful Response

```json
{
  "id": "msg_01XFDUDYJgAACzvnptvVoYEL",
  "type": "message",
  "role": "assistant",
  "content": [
    {
      "type": "text",
      "text": "Hello! I'm Claude, an AI assistant. How can I help you today?"
    }
  ],
  "model": "claude-sonnet-4-5-20250929",
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 12,
    "output_tokens": 20
  }
}
```

**Response Fields:**
- `id` - Unique message identifier
- `type` - Always "message"
- `role` - Always "assistant"
- `content` - Array of content blocks
- `model` - Model used for generation
- `stop_reason` - Why generation stopped
- `usage` - Token usage statistics

### Stop Reasons

| Reason | Description |
|--------|-------------|
| `end_turn` | Natural completion |
| `max_tokens` | Hit token limit |
| `stop_sequence` | Hit stop sequence |
| `tool_use` | Model wants to use a tool |

### Response Headers

```http
HTTP/1.1 200 OK
content-type: application/json
request-id: req_01XFDUDYJgAACzvnptvVoYEL
anthropic-organization-id: org_123456
```

**Important Headers:**
- `request-id` - For debugging and support
- `anthropic-organization-id` - Your organization ID
- `anthropic-ratelimit-*` - Rate limit information

## Error Handling

### Error Response Format

```json
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "max_tokens is required"
  }
}
```

### HTTP Status Codes

| Code | Error Type | Description |
|------|------------|-------------|
| 400 | `invalid_request_error` | Invalid request parameters |
| 401 | `authentication_error` | Invalid or missing API key |
| 403 | `permission_error` | Insufficient permissions |
| 404 | `not_found_error` | Resource not found |
| 429 | `rate_limit_error` | Rate limit exceeded |
| 500 | `api_error` | Internal server error |
| 529 | `overloaded_error` | API overloaded |

### Common Error Examples

**Invalid API Key:**
```http
HTTP/1.1 401 Unauthorized
{
  "type": "error",
  "error": {
    "type": "authentication_error",
    "message": "invalid x-api-key"
  }
}
```

**Rate Limit Exceeded:**
```http
HTTP/1.1 429 Too Many Requests
{
  "type": "error",
  "error": {
    "type": "rate_limit_error",
    "message": "rate limit exceeded"
  }
}
```

## Rate Limits

### Default Limits
- **Requests per minute:** Varies by tier
- **Tokens per minute:** Varies by tier
- **Concurrent requests:** Varies by tier

### Rate Limit Headers
```http
anthropic-ratelimit-requests-limit: 4000
anthropic-ratelimit-requests-remaining: 3999
anthropic-ratelimit-requests-reset: 2024-10-11T12:00:00Z
anthropic-ratelimit-tokens-limit: 400000
anthropic-ratelimit-tokens-remaining: 399500
anthropic-ratelimit-tokens-reset: 2024-10-11T12:00:00Z
```

### Handling Rate Limits
1. Monitor rate limit headers
2. Implement exponential backoff
3. Queue requests during high load
4. Consider request batching
5. Contact sales for limit increases

## Request Size Limits

- **Standard endpoints:** 32 MB
- **Batch endpoints:** Larger limits available
- **Image size:** 8000x8000 pixels max
- **Images per request:** Up to 100

## Versioning

The API uses date-based versioning via the `anthropic-version` header:

```
anthropic-version: 2023-06-01
```

**Version Notes:**
- Always specify a version
- New versions may have breaking changes
- Version determines feature availability
- Check release notes when updating

## SDKs and Libraries

### Official SDKs
- **Python:** `pip install anthropic`
- **TypeScript:** `npm install @anthropic-ai/sdk`
- **Java:** Maven/Gradle available
- **Go:** `go get` available
- **C#:** NuGet package (beta)
- **Ruby:** Gem available
- **PHP:** Composer package (beta)

### Community Libraries
Third-party libraries available for other languages - see documentation.

## Partner Platforms

### Amazon Bedrock
Access Claude via AWS Bedrock:
- Use AWS credentials
- Different endpoint and authentication
- Integration with AWS services

### Google Cloud Vertex AI
Access Claude via GCP Vertex:
- Use GCP credentials
- Different endpoint and authentication
- Integration with GCP services

## Next Steps

1. **Get Started:** [Getting Started Guide](./02-getting-started.md)
2. **Learn Messages API:** [Messages API Reference](./03-messages-api.md)
3. **Choose an SDK:** [Python](./04-python-sdk.md) or [TypeScript](./05-typescript-sdk.md)
4. **Explore Features:**
   - [Streaming](./06-streaming.md)
   - [Vision](./07-vision.md)
   - [Tool Use](./08-tool-use.md)
   - [Prompt Caching](./09-prompt-caching.md)
5. **See Examples:** [Common Use Cases](./11-examples.md)

## Additional Resources

- **Console:** https://console.anthropic.com/
- **Documentation:** https://docs.claude.com/
- **Support:** https://support.anthropic.com/
- **Status:** https://status.anthropic.com/
- **Community:** https://discord.gg/anthropic

## Best Practices

1. **Always handle errors gracefully**
2. **Implement retry logic with exponential backoff**
3. **Monitor token usage and costs**
4. **Use prompt caching for repeated content**
5. **Stream responses for better UX**
6. **Set appropriate max_tokens limits**
7. **Use system prompts for consistency**
8. **Validate input before sending requests**
9. **Log request IDs for debugging**
10. **Test thoroughly in development before production**
