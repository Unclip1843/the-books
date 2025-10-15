# Claude API - Token Counting

**Sources:**
- https://docs.claude.com/en/docs/build-with-claude/token-counting
- https://docs.claude.com/en/api/messages-count-tokens

**Fetched:** 2025-10-11

## Overview

The Token Counting API allows you to determine the number of tokens in a request **before** sending it to Claude. This helps you:

- Manage rate limits
- Estimate costs
- Optimize prompts
- Route requests to appropriate models
- Avoid exceeding context windows

## Key Features

- **Free to use** - No cost for counting tokens
- **Accurate estimates** - Close to actual token counts
- **Supports all message types** - Text, images, tools, PDFs
- **Model-specific** - Get counts for specific models
- **Separate rate limits** - Independent from message creation

## Why Count Tokens?

### 1. Cost Estimation

```python
# Estimate cost before sending
token_count = count_tokens(message)
cost = (token_count / 1_000_000) * 3.00  # Sonnet 4.5 pricing
print(f"Estimated cost: ${cost:.4f}")
```

### 2. Stay Within Context Limits

```python
# Check if message fits in context window
if token_count > 200_000:
    print("Message exceeds context window")
    # Truncate or split message
```

### 3. Rate Limit Management

```python
# Track tokens per minute
tokens_this_minute += count_tokens(message)
if tokens_this_minute > limit:
    wait_before_sending()
```

### 4. Model Selection

```python
# Route based on size
if token_count < 1000:
    model = "claude-3-5-haiku-20241022"  # Fast, cheap
else:
    model = "claude-sonnet-4-5-20250929"  # Better quality
```

## Python Implementation

### Basic Token Counting

```python
import anthropic

client = anthropic.Anthropic()

# Count tokens
response = client.messages.count_tokens(
    model="claude-sonnet-4-5-20250929",
    messages=[{
        "role": "user",
        "content": "Hello, Claude! How are you today?"
    }]
)

print(f"Input tokens: {response.input_tokens}")
```

### With System Prompt

```python
response = client.messages.count_tokens(
    model="claude-sonnet-4-5-20250929",
    system="You are a helpful assistant",
    messages=[{
        "role": "user",
        "content": "Tell me a joke"
    }]
)

print(f"Total input tokens: {response.input_tokens}")
```

### Multi-Turn Conversation

```python
conversation = [
    {"role": "user", "content": "What's 2+2?"},
    {"role": "assistant", "content": "2+2 equals 4"},
    {"role": "user", "content": "What about 3+3?"}
]

response = client.messages.count_tokens(
    model="claude-sonnet-4-5-20250929",
    messages=conversation
)

print(f"Conversation tokens: {response.input_tokens}")
```

### With Tools

```python
tools = [
    {
        "name": "get_weather",
        "description": "Get weather for a location",
        "input_schema": {
            "type": "object",
            "properties": {
                "location": {"type": "string"}
            },
            "required": ["location"]
        }
    }
]

response = client.messages.count_tokens(
    model="claude-sonnet-4-5-20250929",
    tools=tools,
    messages=[{
        "role": "user",
        "content": "What's the weather in SF?"
    }]
)

print(f"Tokens with tools: {response.input_tokens}")
```

### With Images

```python
import base64

with open("image.jpg", "rb") as img:
    image_data = base64.b64encode(img.read()).decode()

response = client.messages.count_tokens(
    model="claude-sonnet-4-5-20250929",
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

print(f"Tokens with image: {response.input_tokens}")
```

### With Extended Thinking

```python
response = client.messages.count_tokens(
    model="claude-sonnet-4-5-20250929",
    thinking={
        "type": "enabled",
        "budget_tokens": 10000
    },
    messages=[{
        "role": "user",
        "content": "Solve this complex problem..."
    }]
)

print(f"Input tokens: {response.input_tokens}")
# Note: Thinking budget tokens not included in count
```

## TypeScript Implementation

### Basic Token Counting

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

const response = await client.messages.countTokens({
  model: 'claude-sonnet-4-5-20250929',
  messages: [{
    role: 'user',
    content: 'Hello, Claude! How are you today?',
  }],
});

console.log(`Input tokens: ${response.input_tokens}`);
```

### Complete Example

```typescript
async function estimateRequestCost(
  messages: Anthropic.MessageParam[],
  model: string = 'claude-sonnet-4-5-20250929'
): Promise<number> {
  const response = await client.messages.countTokens({
    model,
    messages,
  });

  // Pricing for Sonnet 4.5
  const inputCost = (response.input_tokens / 1_000_000) * 3.00;

  return inputCost;
}

// Usage
const messages = [
  { role: 'user', content: 'Write a story about a robot' },
];

const estimatedCost = await estimateRequestCost(messages);
console.log(`Estimated input cost: $${estimatedCost.toFixed(4)}`);
```

## Token Estimation Formulas

### Text

Rough approximation:
```
tokens ≈ words × 1.3
tokens ≈ characters / 4
```

**Example:**
- "Hello world" = 2 words ≈ 3 tokens
- 1,000 words ≈ 1,300 tokens
- 10,000 characters ≈ 2,500 tokens

### Images

```
tokens = (width_px × height_px) / 750
```

**Examples:**
- 400×400 image = ~213 tokens
- 1000×1000 image = ~1,333 tokens
- 1920×1080 image = ~2,765 tokens

### PDFs

```
tokens ≈ 1,500-3,000 per page
```

## Rate Limits

Token counting has separate rate limits:

| Tier | Requests/Minute |
|------|-----------------|
| Free | 100 |
| Build Tier 1 | 1,000 |
| Build Tier 2 | 4,000 |
| Build Tier 3 | 8,000 |
| Build Tier 4 | 8,000 |

Check response headers:
- `anthropic-ratelimit-tokens-requests-limit`
- `anthropic-ratelimit-tokens-requests-remaining`

## Use Cases

### 1. Pre-flight Cost Check

```python
def estimate_and_confirm(message, model="claude-sonnet-4-5-20250929"):
    """Estimate cost and ask for confirmation"""
    # Count tokens
    response = client.messages.count_tokens(
        model=model,
        messages=[message]
    )

    # Calculate cost (rough estimate for output)
    input_cost = (response.input_tokens / 1_000_000) * 3.00
    estimated_output = 1000  # Guess
    output_cost = (estimated_output / 1_000_000) * 15.00
    total_cost = input_cost + output_cost

    print(f"Estimated cost: ${total_cost:.4f}")

    confirm = input("Proceed? (y/n): ")
    if confirm.lower() == 'y':
        return client.messages.create(
            model=model,
            max_tokens=2048,
            messages=[message]
        )
```

### 2. Smart Truncation

```python
def truncate_to_fit(text, max_tokens=200000, model="claude-sonnet-4-5-20250929"):
    """Truncate text to fit in context window"""
    response = client.messages.count_tokens(
        model=model,
        messages=[{"role": "user", "content": text}]
    )

    if response.input_tokens <= max_tokens:
        return text

    # Binary search for right length
    words = text.split()
    left, right = 0, len(words)

    while left < right:
        mid = (left + right + 1) // 2
        truncated = " ".join(words[:mid])

        response = client.messages.count_tokens(
            model=model,
            messages=[{"role": "user", "content": truncated}]
        )

        if response.input_tokens <= max_tokens:
            left = mid
        else:
            right = mid - 1

    return " ".join(words[:left])
```

### 3. Batch Size Optimization

```python
def optimal_batch_size(requests, max_tokens_per_batch=100000):
    """Group requests into optimal batches"""
    batches = []
    current_batch = []
    current_tokens = 0

    for request in requests:
        response = client.messages.count_tokens(
            model="claude-sonnet-4-5-20250929",
            messages=[request]
        )

        if current_tokens + response.input_tokens > max_tokens_per_batch:
            batches.append(current_batch)
            current_batch = [request]
            current_tokens = response.input_tokens
        else:
            current_batch.append(request)
            current_tokens += response.input_tokens

    if current_batch:
        batches.append(current_batch)

    return batches
```

### 4. Rate Limit Management

```python
import time

class TokenRateLimiter:
    def __init__(self, tokens_per_minute=100000):
        self.tokens_per_minute = tokens_per_minute
        self.tokens_used = []

    def can_send(self, token_count):
        """Check if we can send without exceeding limit"""
        now = time.time()

        # Remove tokens older than 1 minute
        self.tokens_used = [
            (tokens, timestamp)
            for tokens, timestamp in self.tokens_used
            if now - timestamp < 60
        ]

        # Calculate current usage
        current_usage = sum(tokens for tokens, _ in self.tokens_used)

        return current_usage + token_count <= self.tokens_per_minute

    def wait_if_needed(self, token_count):
        """Wait if necessary to stay under limit"""
        while not self.can_send(token_count):
            time.sleep(1)

        self.tokens_used.append((token_count, time.time()))

# Usage
limiter = TokenRateLimiter(tokens_per_minute=100000)

for message in messages:
    response = client.messages.count_tokens(
        model="claude-sonnet-4-5-20250929",
        messages=[message]
    )

    limiter.wait_if_needed(response.input_tokens)

    # Now safe to send
    result = client.messages.create(...)
```

## Best Practices

### 1. Count Before Every Large Request

```python
# Good
token_count = client.messages.count_tokens(...)
if token_count.input_tokens > 100000:
    print("Warning: Large request")

result = client.messages.create(...)

# Bad - sending without checking
result = client.messages.create(...)  # Might fail!
```

### 2. Cache Token Counts for Static Content

```python
# Cache counts for reused prompts
prompt_cache = {}

def get_token_count(prompt):
    if prompt not in prompt_cache:
        response = client.messages.count_tokens(
            model="claude-sonnet-4-5-20250929",
            messages=[{"role": "user", "content": prompt}]
        )
        prompt_cache[prompt] = response.input_tokens

    return prompt_cache[prompt]
```

### 3. Account for Output Tokens

```python
def estimate_total_cost(message, expected_output_tokens=1000):
    """Estimate total cost including output"""
    input_response = client.messages.count_tokens(
        model="claude-sonnet-4-5-20250929",
        messages=[message]
    )

    input_cost = (input_response.input_tokens / 1_000_000) * 3.00
    output_cost = (expected_output_tokens / 1_000_000) * 15.00

    return {
        "input_cost": input_cost,
        "output_cost": output_cost,
        "total_cost": input_cost + output_cost
    }
```

### 4. Model-Specific Counts

```python
# Different models may tokenize differently
models = [
    "claude-sonnet-4-5-20250929",
    "claude-opus-4-1-20250805",
    "claude-3-5-haiku-20241022"
]

for model in models:
    response = client.messages.count_tokens(
        model=model,
        messages=[message]
    )
    print(f"{model}: {response.input_tokens} tokens")
```

## Important Notes

### Token Count is an Estimate

```python
# Counted tokens
count_response = client.messages.count_tokens(
    model="claude-sonnet-4-5-20250929",
    messages=[{"role": "user", "content": "Hello"}]
)
print(f"Counted: {count_response.input_tokens}")

# Actual tokens
message_response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}]
)
print(f"Actual: {message_response.usage.input_tokens}")

# These may differ slightly
```

### System Tokens Not Billed

Some system-added tokens don't count toward billing but may appear in counts.

### Caching Not Counted

Token counting doesn't account for prompt caching:

```python
# Token count doesn't include cache savings
response = client.messages.count_tokens(
    model="claude-sonnet-4-5-20250929",
    system=[{
        "type": "text",
        "text": "Large prompt...",
        "cache_control": {"type": "ephemeral"}
    }],
    messages=[{"role": "user", "content": "Question"}]
)

# Actual request may use cached tokens
```

## Error Handling

```python
from anthropic import APIError

try:
    response = client.messages.count_tokens(
        model="claude-sonnet-4-5-20250929",
        messages=[message]
    )
except APIError as e:
    if e.status_code == 400:
        print(f"Invalid request: {e.message}")
    elif e.status_code == 429:
        print("Rate limited - wait before counting again")
    else:
        print(f"Error: {e}")
```

## Complete Example: Smart Request Handler

```python
class SmartRequestHandler:
    def __init__(self, model="claude-sonnet-4-5-20250929", max_cost=0.10):
        self.client = anthropic.Anthropic()
        self.model = model
        self.max_cost = max_cost

    def count_and_validate(self, messages):
        """Count tokens and validate request"""
        response = self.client.messages.count_tokens(
            model=self.model,
            messages=messages
        )

        return {
            "input_tokens": response.input_tokens,
            "valid": response.input_tokens < 200000,
            "estimated_cost": (response.input_tokens / 1_000_000) * 3.00
        }

    def send_if_safe(self, messages, max_tokens=2048):
        """Send request only if it passes checks"""
        validation = self.count_and_validate(messages)

        if not validation["valid"]:
            return {"error": "Exceeds context window"}

        if validation["estimated_cost"] > self.max_cost:
            return {"error": f"Estimated cost ${validation['estimated_cost']:.4f} exceeds limit"}

        print(f"Sending request ({validation['input_tokens']} tokens)")

        return self.client.messages.create(
            model=self.model,
            max_tokens=max_tokens,
            messages=messages
        )

# Usage
handler = SmartRequestHandler(max_cost=0.05)
result = handler.send_if_safe([
    {"role": "user", "content": "Write a story"}
])
```

## Related Documentation

- [Messages API](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)
- [TypeScript SDK](./05-typescript-sdk.md)
- [Models](./10-models.md)
- [Prompt Caching](./09-prompt-caching.md)
- [Batches API](./12-batches-api.md)
