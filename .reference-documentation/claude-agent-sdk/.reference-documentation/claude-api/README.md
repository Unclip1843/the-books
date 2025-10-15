# Claude API Documentation

**Comprehensive reference documentation for the Claude Messages API and Client SDKs**

**Sources:**
- Official Claude Documentation: https://docs.claude.com/en/api/
- GitHub Python SDK: https://github.com/anthropics/anthropic-sdk-python
- GitHub TypeScript SDK: https://github.com/anthropics/anthropic-sdk-typescript

**Last Updated:** 2025-10-11

---

## Quick Links

### Getting Started
- [01. Overview](./01-overview.md) - API overview, authentication, and basics
- [02. Getting Started](./02-getting-started.md) - Quick start guide for Python, TypeScript, and cURL

### Core API
- [03. Messages API Reference](./03-messages-api.md) - Complete Messages API documentation

### Client SDKs
- [04. Python SDK](./04-python-sdk.md) - Python SDK reference with examples
- [05. TypeScript SDK](./05-typescript-sdk.md) - TypeScript/Node.js SDK reference

### Features
- [06. Streaming](./06-streaming.md) - Real-time streaming responses
- [07. Vision](./07-vision.md) - Image understanding and analysis
- [08. Tool Use](./08-tool-use.md) - Function calling and tools
- [09. Prompt Caching](./09-prompt-caching.md) - Cost optimization with caching

### Reference
- [10. Models](./10-models.md) - All available models and comparison
- [11. Examples](./11-examples.md) - Practical examples and use cases

### Advanced Features
- [12. Message Batches](./12-batches-api.md) - Async bulk processing with 50% cost savings
- [13. Extended Thinking](./13-extended-thinking.md) - Deep reasoning mode
- [14. Computer Use](./14-computer-use.md) - Desktop automation (Beta)
- [15. Token Counting](./15-token-counting.md) - Estimate tokens before requests
- [16. Embeddings](./16-embeddings.md) - Text embeddings with Voyage AI
- [17. Files API](./17-files-api.md) - Upload and manage files (Beta)
- [18. PDF Support](./18-pdf-support.md) - Direct PDF processing

### Best Practices
- [19. Prompt Engineering](./19-prompt-engineering.md) - Techniques and patterns
- [20. Testing & Evaluation](./20-testing-evaluation.md) - Quality assurance strategies
- [21. Integrations](./21-integrations.md) - AWS Bedrock, GCP Vertex AI, OpenAI SDK

### What is the Claude API?

The Claude API provides programmatic access to Anthropic's Claude AI models through a REST API. Unlike the Claude Agent SDK (which builds autonomous agents), the Claude API is for direct model interaction:

**Core capabilities:**
- Text generation and analysis
- Multi-turn conversations
- Vision (image understanding)
- Tool use (function calling)
- Streaming responses
- Prompt caching for cost optimization

---

## Installation

### Python
```bash
pip install anthropic
```

### TypeScript/Node.js
```bash
npm install @anthropic-ai/sdk
```

### Other SDKs
- **Java:** Maven/Gradle available
- **Go:** `go get` available
- **C#:** NuGet package (beta)
- **Ruby:** Gem available
- **PHP:** Composer package (beta)

---

## Quick Examples

### Python: Basic Request
```python
import anthropic

client = anthropic.Anthropic(
    api_key="your-api-key-here"
)

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Hello, Claude"}
    ]
)

print(message.content[0].text)
```

### TypeScript: Basic Request
```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic({
  apiKey: 'your-api-key-here',
});

const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [
    { role: 'user', content: 'Hello, Claude' }
  ],
});

console.log(message.content[0].text);
```

### cURL: Basic Request
```bash
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

---

## Available Models

| Model | Best For | Context | Cost |
|-------|----------|---------|------|
| **Claude Sonnet 4.5** | Most tasks, complex reasoning, coding | 200K | Medium |
| **Claude Opus 4.1** | Specialized complex tasks, highest intelligence | 200K | High |
| **Claude Haiku 3.5** | Fast responses, simple tasks | 200K | Low |

**Recommendation:** Start with **Sonnet 4.5** for the best balance of performance and cost.

---

## Core Features

### 1. Streaming Responses

**Python:**
```python
with client.messages.stream(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Write a story"}],
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

**TypeScript:**
```typescript
const stream = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Write a story' }],
  stream: true,
});

for await (const event of stream) {
  if (event.type === 'content_block_delta') {
    process.stdout.write(event.delta.text);
  }
}
```

### 2. Vision (Image Understanding)

**Base64 Image:**
```python
import base64

with open("image.jpg", "rb") as f:
    image_data = base64.b64encode(f.read()).decode("utf-8")

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{
        "role": "user",
        "content": [
            {"type": "text", "text": "What's in this image?"},
            {
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": image_data
                }
            }
        ]
    }]
)
```

**Image URL:**
```typescript
const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{
    role: 'user',
    content: [
      { type: 'text', text: "What's in this image?" },
      {
        type: 'image',
        source: {
          type: 'url',
          url: 'https://example.com/image.jpg'
        }
      }
    ]
  }]
});
```

### 3. Tool Use (Function Calling)

**Python:**
```python
tools = [{
    "name": "get_weather",
    "description": "Get weather for a location",
    "input_schema": {
        "type": "object",
        "properties": {
            "location": {"type": "string"}
        },
        "required": ["location"]
    }
}]

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "What's the weather in SF?"}]
)

if message.stop_reason == "tool_use":
    tool_use = next(block for block in message.content if block.type == "tool_use")
    print(f"Tool: {tool_use.name}")
    print(f"Input: {tool_use.input}")
```

### 4. Prompt Caching

**Python:**
```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": "Long system prompt here...",
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=[{"role": "user", "content": "Question"}]
)

print(f"Cache read tokens: {message.usage.cache_read_input_tokens}")
print(f"Cache creation tokens: {message.usage.cache_creation_input_tokens}")
```

**Benefits:**
- 90% cost reduction on cached content
- 5-minute or 1-hour cache lifetime
- Ideal for system prompts, large documents, tool definitions

### 5. Multi-Turn Conversations

**Python:**
```python
conversation = []

# First turn
conversation.append({"role": "user", "content": "What's 2+2?"})
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=conversation
)
conversation.append({"role": "assistant", "content": response.content[0].text})

# Second turn
conversation.append({"role": "user", "content": "What about 3+3?"})
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=conversation
)
```

---

## Documentation Structure

### 01. Overview
- API introduction
- Authentication and API keys
- Request/response format
- Error handling
- Rate limits

### 02. Getting Started
- Quick start for Python, TypeScript, and cURL
- First API call
- Multi-turn conversations
- System prompts
- Error handling

### 03. Messages API Reference
- Complete endpoint documentation
- Request parameters
- Response format
- Error codes
- Advanced features

---

## Common Use Cases

### Chatbot
```python
def chat(user_input, conversation_history):
    conversation_history.append({
        "role": "user",
        "content": user_input
    })

    response = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=conversation_history
    )

    conversation_history.append({
        "role": "assistant",
        "content": response.content[0].text
    })

    return response.content[0].text
```

### Content Analysis
```python
def analyze_text(text):
    return client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        system="You are an expert content analyst.",
        messages=[{
            "role": "user",
            "content": f"Analyze this text:\n\n{text}"
        }]
    ).content[0].text
```

### Image Description
```python
def describe_image(image_path):
    with open(image_path, "rb") as f:
        image_data = base64.b64encode(f.read()).decode()

    return client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": "Describe this image in detail"},
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/jpeg",
                        "data": image_data
                    }
                }
            ]
        }]
    ).content[0].text
```

### Code Generation
```python
def generate_code(description):
    return client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        system="You are an expert programmer. Write clean, well-documented code.",
        messages=[{
            "role": "user",
            "content": f"Write code for: {description}"
        }]
    ).content[0].text
```

---

## Best Practices

### 1. Authentication
- ✅ Use environment variables for API keys
- ✅ Never commit keys to version control
- ✅ Rotate keys periodically
- ❌ Don't hardcode API keys

### 2. Error Handling
```python
from anthropic import (
    APIError,
    APIConnectionError,
    RateLimitError,
    APIStatusError
)

try:
    message = client.messages.create(...)
except APIConnectionError as e:
    print(f"Connection failed: {e}")
except RateLimitError as e:
    print(f"Rate limited: {e}")
    # Implement exponential backoff
except APIStatusError as e:
    print(f"API error {e.status_code}: {e.response}")
except APIError as e:
    print(f"API error: {e}")
```

### 3. Cost Optimization
- ✅ Use `max_tokens` to limit response length
- ✅ Implement prompt caching for repeated content
- ✅ Choose appropriate model (Haiku for simple tasks)
- ✅ Monitor token usage
- ❌ Don't over-engineer prompts

### 4. Performance
- ✅ Use streaming for better UX
- ✅ Implement connection pooling
- ✅ Cache responses when appropriate
- ✅ Use async clients for concurrent requests
- ❌ Don't make sequential requests when parallel works

### 5. Prompt Engineering
- ✅ Be specific and clear
- ✅ Provide examples when needed
- ✅ Use system prompts for consistency
- ✅ Test different temperatures
- ❌ Don't assume Claude knows implicit context

---

## Rate Limits & Costs

### Rate Limits
Check headers for current limits:
- `anthropic-ratelimit-requests-limit`
- `anthropic-ratelimit-requests-remaining`
- `anthropic-ratelimit-tokens-limit`
- `anthropic-ratelimit-tokens-remaining`

### Pricing (Example - check current rates)

**Claude Sonnet 4.5:**
- Input: $3 per million tokens
- Output: $15 per million tokens
- Cached input: $0.30 per million tokens (90% savings)

**Claude Opus 4.1:**
- Input: $15 per million tokens
- Output: $75 per million tokens

**Claude Haiku 3.5:**
- Input: $0.80 per million tokens
- Output: $4 per million tokens

---

## Additional Resources

### Official Links
- **Console:** https://console.anthropic.com/
- **Documentation:** https://docs.claude.com/
- **API Status:** https://status.anthropic.com/
- **Support:** https://support.anthropic.com/

### GitHub Repositories
- **Python SDK:** https://github.com/anthropics/anthropic-sdk-python
- **TypeScript SDK:** https://github.com/anthropics/anthropic-sdk-typescript
- **Cookbook:** https://github.com/anthropics/anthropic-cookbook

### Community
- **Discord:** https://discord.gg/anthropic
- **Twitter:** https://twitter.com/anthropicai

---

## Troubleshooting

### Common Issues

**"Invalid API Key"**
```bash
# Check your key is set
echo $ANTHROPIC_API_KEY

# Verify it's correct in Console
# https://console.anthropic.com/settings/keys
```

**"Rate Limit Exceeded"**
```python
# Implement exponential backoff
import time

for attempt in range(3):
    try:
        response = client.messages.create(...)
        break
    except RateLimitError:
        if attempt < 2:
            time.sleep(2 ** attempt)
```

**"Request Too Large"**
- Reduce message content
- Use prompt caching for large contexts
- Split into multiple requests

**Import Errors**
```bash
# Python
pip install --upgrade anthropic

# TypeScript
npm install @anthropic-ai/sdk
```

---

## Quick Navigation

**New to Claude API?**
→ Start with [01. Overview](./01-overview.md)

**Want to get coding quickly?**
→ Jump to [02. Getting Started](./02-getting-started.md)

**Need API reference?**
→ See [03. Messages API Reference](./03-messages-api.md)

**Looking for examples?**
→ Check [Anthropic Cookbook](https://github.com/anthropics/anthropic-cookbook)

---

## Updates & Changelog

**2025-10-11:** Documentation created
- Captured from official docs.claude.com
- Includes Messages API, SDKs, and feature guides
- Based on latest API version (2023-06-01)

---

## Contributing to This Documentation

This documentation was compiled from official sources. To update:

1. Check https://docs.claude.com/ for changes
2. Update relevant markdown files
3. Update this README with new sections
4. Update the "Last Updated" date

---

## License

The Claude API client SDKs are released under the MIT License.
This documentation compilation is for reference purposes.
