# Claude API - Getting Started

**Source:** https://docs.claude.com/en/docs/get-started
**Fetched:** 2025-10-11

## Prerequisites

Before you begin, you'll need:

1. **Anthropic Console Account**
   - Sign up at [console.anthropic.com](https://console.anthropic.com/)
   - Verify your email address

2. **API Key**
   - Navigate to [Account Settings > API Keys](https://console.anthropic.com/settings/keys)
   - Click "Create Key"
   - Copy and securely store your API key
   - **Important:** Keys are only shown once!

3. **Development Environment**
   - Python 3.8+ or Node.js 16+
   - Terminal/command line access
   - Text editor or IDE

## Quick Start (cURL)

### Step 1: Set Your API Key

```bash
export ANTHROPIC_API_KEY='your-api-key-here'
```

### Step 2: Make Your First Request

```bash
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "messages": [
      {
        "role": "user",
        "content": "Hello, Claude! How are you today?"
      }
    ]
  }'
```

### Expected Response

```json
{
  "id": "msg_01XFDUDYJgAACzvnptvVoYEL",
  "type": "message",
  "role": "assistant",
  "content": [
    {
      "type": "text",
      "text": "Hello! I'm doing well, thank you for asking. I'm Claude, an AI assistant created by Anthropic. How can I help you today?"
    }
  ],
  "model": "claude-sonnet-4-5-20250929",
  "stop_reason": "end_turn",
  "usage": {
    "input_tokens": 12,
    "output_tokens": 29
  }
}
```

## Quick Start (Python)

### Step 1: Install the SDK

```bash
pip install anthropic
```

### Step 2: Set Your API Key

```bash
export ANTHROPIC_API_KEY='your-api-key-here'
```

### Step 3: Create Your First Script

Create a file `claude_example.py`:

```python
import anthropic
import os

# Initialize the client
client = anthropic.Anthropic(
    api_key=os.environ.get("ANTHROPIC_API_KEY")
)

# Create a message
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": "Hello, Claude! How are you today?"
        }
    ]
)

# Print the response
print(message.content[0].text)
```

### Step 4: Run Your Script

```bash
python claude_example.py
```

### Expected Output

```
Hello! I'm doing well, thank you for asking. I'm Claude, an AI assistant created by Anthropic. How can I help you today?
```

## Quick Start (TypeScript)

### Step 1: Install the SDK

```bash
npm install @anthropic-ai/sdk
```

### Step 2: Set Your API Key

```bash
export ANTHROPIC_API_KEY='your-api-key-here'
```

### Step 3: Create Your First Script

Create a file `claude-example.ts`:

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

async function main() {
  const message = await client.messages.create({
    model: 'claude-sonnet-4-5-20250929',
    max_tokens: 1024,
    messages: [
      {
        role: 'user',
        content: 'Hello, Claude! How are you today?'
      }
    ],
  });

  console.log(message.content[0].text);
}

main();
```

### Step 4: Run Your Script

```bash
npx ts-node claude-example.ts
# or with Node.js
node claude-example.js
```

## Understanding the Request

### Required Parameters

```python
client.messages.create(
    model="claude-sonnet-4-5-20250929",  # Which Claude model to use
    max_tokens=1024,                      # Maximum tokens to generate
    messages=[                            # Conversation history
        {
            "role": "user",
            "content": "Your message here"
        }
    ]
)
```

**Parameter Details:**

1. **`model`** - The Claude model to use:
   - `claude-sonnet-4-5-20250929` - Best for most tasks (recommended)
   - `claude-opus-4-20250514` - Most capable, highest cost
   - `claude-haiku-3-5-20241022` - Fastest, lowest cost

2. **`max_tokens`** - Maximum response length:
   - Minimum: 1
   - Maximum: Varies by model (200K context)
   - Recommendation: Start with 1024-2048

3. **`messages`** - Conversation turns:
   - Array of message objects
   - Each has `role` ("user" or "assistant") and `content`
   - Alternating user/assistant pattern

## Multi-Turn Conversations

The API is stateless, so you must send the entire conversation history:

```python
import anthropic

client = anthropic.Anthropic()

# First turn
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "What's the capital of France?"}
    ]
)
print(message.content[0].text)  # "Paris"

# Second turn - include previous conversation
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "What's the capital of France?"},
        {"role": "assistant", "content": "The capital of France is Paris."},
        {"role": "user", "content": "What about Germany?"}
    ]
)
print(message.content[0].text)  # "The capital of Germany is Berlin."
```

## Adding a System Prompt

System prompts provide context and instructions:

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    system="You are a helpful assistant that always responds in haiku.",
    messages=[
        {"role": "user", "content": "Tell me about the ocean"}
    ]
)
```

**System Prompt Best Practices:**
- Be specific and clear
- Define the assistant's role
- Set tone and style
- Specify constraints
- Provide examples if helpful

## Controlling Randomness

Use `temperature` to control response randomness:

```python
# More deterministic (0.0 - 0.5)
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    temperature=0.0,  # Most deterministic
    messages=[{"role": "user", "content": "Count to 10"}]
)

# More creative (0.5 - 1.0)
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    temperature=1.0,  # Most creative
    messages=[{"role": "user", "content": "Write a creative story"}]
)
```

**Temperature Guidelines:**
- `0.0` - Deterministic, focused
- `0.3-0.7` - Balanced (default: 1.0)
- `1.0` - Creative, varied

## Error Handling

### Python

```python
import anthropic

client = anthropic.Anthropic()

try:
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{"role": "user", "content": "Hello"}]
    )
    print(message.content[0].text)

except anthropic.APIConnectionError as e:
    print(f"Connection error: {e}")
except anthropic.RateLimitError as e:
    print(f"Rate limit exceeded: {e}")
except anthropic.APIStatusError as e:
    print(f"API error: {e.status_code} - {e.response}")
except Exception as e:
    print(f"Unexpected error: {e}")
```

### TypeScript

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

try {
  const message = await client.messages.create({
    model: 'claude-sonnet-4-5-20250929',
    max_tokens: 1024,
    messages: [{ role: 'user', content: 'Hello' }],
  });
  console.log(message.content[0].text);

} catch (error) {
  if (error instanceof Anthropic.APIError) {
    console.error(`API Error: ${error.status} - ${error.message}`);
  } else {
    console.error('Unexpected error:', error);
  }
}
```

## Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `authentication_error` | Invalid API key | Check API key is correct |
| `invalid_request_error` | Missing required param | Add `max_tokens` |
| `rate_limit_error` | Too many requests | Implement retry with backoff |
| `overloaded_error` | API overloaded | Retry after delay |

## Monitoring Usage

### Check Token Usage

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}]
)

print(f"Input tokens: {message.usage.input_tokens}")
print(f"Output tokens: {message.usage.output_tokens}")
print(f"Total tokens: {message.usage.input_tokens + message.usage.output_tokens}")
```

### Calculate Costs

```python
# Example pricing (check current rates)
INPUT_COST_PER_1M = 3.00  # $3 per 1M input tokens
OUTPUT_COST_PER_1M = 15.00  # $15 per 1M output tokens

input_cost = (message.usage.input_tokens / 1_000_000) * INPUT_COST_PER_1M
output_cost = (message.usage.output_tokens / 1_000_000) * OUTPUT_COST_PER_1M
total_cost = input_cost + output_cost

print(f"Estimated cost: ${total_cost:.6f}")
```

## Next Steps

### Learn Core Features
1. **[Streaming Responses](./06-streaming.md)** - Real-time response streaming
2. **[Vision](./07-vision.md)** - Analyze images
3. **[Tool Use](./08-tool-use.md)** - Function calling
4. **[Prompt Caching](./09-prompt-caching.md)** - Reduce costs

### Explore SDKs
- **[Python SDK Guide](./04-python-sdk.md)** - Full Python SDK documentation
- **[TypeScript SDK Guide](./05-typescript-sdk.md)** - Full TypeScript SDK documentation

### See Examples
- **[Common Use Cases](./11-examples.md)** - Real-world examples

### Additional Resources
- **[API Reference](./03-messages-api.md)** - Complete API documentation
- **[Model Overview](./10-models.md)** - Choose the right model
- **[Anthropic Console](https://console.anthropic.com/)** - Manage your account
- **[Claude Cookbook](https://github.com/anthropics/anthropic-cookbook)** - Code examples

## Troubleshooting

### Issue: "Invalid API Key"
**Solution:** Ensure your API key is set correctly:
```bash
echo $ANTHROPIC_API_KEY  # Should display your key
```

### Issue: "Rate Limit Exceeded"
**Solution:** Implement exponential backoff:
```python
import time
from anthropic import RateLimitError

max_retries = 3
for attempt in range(max_retries):
    try:
        message = client.messages.create(...)
        break
    except RateLimitError:
        if attempt < max_retries - 1:
            time.sleep(2 ** attempt)  # Exponential backoff
        else:
            raise
```

### Issue: "Request Too Large"
**Solution:** Reduce message size or use prompt caching for large contexts.

### Issue: Import Errors
**Solution:**
```bash
# Python: Ensure package is installed
pip install --upgrade anthropic

# TypeScript: Ensure package is installed
npm install @anthropic-ai/sdk
```

## Best Practices

1. **Always set `max_tokens`** - Required parameter, prevents runaway costs
2. **Use environment variables** - Never hardcode API keys
3. **Implement error handling** - Handle rate limits and API errors
4. **Monitor token usage** - Track costs and optimize
5. **Start with Sonnet** - Best balance of performance and cost
6. **Use system prompts** - Consistent behavior across requests
7. **Test in Console** - Use Workbench to test prompts before coding
8. **Log request IDs** - Useful for debugging with support
