# Claude API - Extended Thinking

**Sources:**
- https://docs.claude.com/en/docs/build-with-claude/extended-thinking
- https://docs.claude.com/en/api/messages

**Fetched:** 2025-10-11

## Overview

Extended Thinking is a feature that allows Claude to generate detailed reasoning processes before producing a final answer. It provides transparency into Claude's step-by-step thought process for complex tasks requiring deep analysis.

## What is Extended Thinking?

Extended Thinking enables Claude to:
- Generate explicit reasoning steps before answering
- Show its thought process transparently
- Tackle complex problems with deeper analysis
- Provide insight into how conclusions are reached

**Think of it as:** Claude "thinking out loud" before giving you an answer.

## Supported Models

| Model | Extended Thinking | Thinking Summary |
|-------|-------------------|------------------|
| Claude Opus 4.1 | ✅ Yes | ✅ Yes (automatic) |
| Claude Opus 4 | ✅ Yes | ✅ Yes (automatic) |
| Claude Sonnet 4.5 | ✅ Yes | ✅ Yes (automatic) |
| Claude Sonnet 4 | ✅ Yes | ✅ Yes (automatic) |
| Claude Sonnet 3.7 | ✅ Yes | ❌ No |
| Claude Haiku 3.5 | ❌ No | ❌ No |
| Claude Haiku 3 | ❌ No | ❌ No |

## When to Use Extended Thinking

### Good Use Cases
✅ Complex mathematical problems
✅ Advanced coding tasks
✅ Multi-step reasoning
✅ Research and analysis
✅ Strategic planning
✅ Technical problem-solving
✅ Debugging complex issues

### Not Ideal For
❌ Simple queries
❌ Quick factual lookups
❌ Latency-sensitive applications
❌ Cost-sensitive high-volume tasks

## How It Works

### Response Structure

With Extended Thinking enabled, responses contain:

1. **Thinking Block** - Claude's reasoning process (hidden by default in Claude 4 models)
2. **Text Block** - Final answer to your question

**Claude 4 models** also provide:
- Automatic summarization of thinking
- Thinking summary in the response

## Python Implementation

### Basic Extended Thinking

```python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={
        "type": "enabled",
        "budget_tokens": 10000
    },
    messages=[{
        "role": "user",
        "content": "Solve this complex math problem: If f(x) = x^3 - 3x^2 + 2x + 1, find all critical points and classify them."
    }]
)

# Access thinking content
for block in message.content:
    if block.type == "thinking":
        print("Claude's Thinking:")
        print(block.thinking)
    elif block.type == "text":
        print("\nFinal Answer:")
        print(block.text)
```

### With Streaming

```python
with client.messages.stream(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={
        "type": "enabled",
        "budget_tokens": 10000
    },
    messages=[{
        "role": "user",
        "content": "Design a scalable microservices architecture for an e-commerce platform"
    }]
) as stream:
    thinking_content = ""
    text_content = ""

    for event in stream:
        if event.type == "content_block_start":
            if event.content_block.type == "thinking":
                print("--- Thinking Process ---")
        elif event.type == "content_block_delta":
            if event.delta.type == "thinking_delta":
                thinking_content += event.delta.thinking
                print(event.delta.thinking, end="", flush=True)
            elif event.delta.type == "text_delta":
                if not text_content:  # First text block
                    print("\n\n--- Final Answer ---")
                text_content += event.delta.text
                print(event.delta.text, end="", flush=True)
```

### Accessing Thinking Summary (Claude 4)

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={
        "type": "enabled",
        "budget_tokens": 16000
    },
    messages=[{
        "role": "user",
        "content": "Analyze the time complexity of quicksort and explain why it can degrade to O(n^2)"
    }]
)

# Claude 4 models provide a summary
for block in message.content:
    if block.type == "thinking":
        # Full thinking process (can be long)
        print(f"Thinking tokens: {len(block.thinking)}")

        # Summary (if available on Claude 4)
        if hasattr(block, 'summary'):
            print(f"Summary: {block.summary}")
```

## TypeScript Implementation

### Basic Extended Thinking

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 4096,
  thinking: {
    type: 'enabled',
    budget_tokens: 10000,
  },
  messages: [{
    role: 'user',
    content: 'Prove that the square root of 2 is irrational',
  }],
});

// Access thinking and response
for (const block of message.content) {
  if (block.type === 'thinking') {
    console.log('Claude\'s Thinking:');
    console.log(block.thinking);
  } else if (block.type === 'text') {
    console.log('\nFinal Answer:');
    console.log(block.text);
  }
}
```

### With Streaming

```typescript
const stream = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 4096,
  thinking: {
    type: 'enabled',
    budget_tokens: 10000,
  },
  messages: [{
    role: 'user',
    content: 'Design an algorithm to detect cycles in a directed graph',
  }],
  stream: true,
});

for await (const event of stream) {
  if (event.type === 'content_block_start') {
    if (event.content_block.type === 'thinking') {
      console.log('--- Thinking Process ---');
    }
  } else if (event.type === 'content_block_delta') {
    if (event.delta.type === 'thinking_delta') {
      process.stdout.write(event.delta.thinking);
    } else if (event.delta.type === 'text_delta') {
      process.stdout.write(event.delta.text);
    }
  }
}
```

## Configuration

### Thinking Budget

The `budget_tokens` parameter sets the maximum tokens for thinking:

```python
thinking={
    "type": "enabled",
    "budget_tokens": 10000  # 1,024 to 65,536
}
```

**Recommendations:**
- **Minimum:** 1,024 tokens (required)
- **Simple tasks:** 4,000-8,000 tokens
- **Complex tasks:** 16,000-32,000 tokens
- **Very complex:** 32,000-65,536 tokens

### Budget Exhaustion

If thinking budget is exhausted:
- Claude stops thinking
- Returns what it has reasoned so far
- May provide a partial or incomplete answer
- Response includes `stop_reason: "max_tokens"`

## Multi-Turn Conversations

Extended thinking works with conversations:

```python
conversation = []

# First turn with thinking
conversation.append({
    "role": "user",
    "content": "Explain the halting problem"
})

response1 = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={"type": "enabled", "budget_tokens": 10000},
    messages=conversation
)

# Add response to conversation (including thinking blocks)
conversation.append({
    "role": "assistant",
    "content": response1.content
})

# Second turn
conversation.append({
    "role": "user",
    "content": "Now explain the relationship to Gödel's incompleteness theorems"
})

response2 = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={"type": "enabled", "budget_tokens": 10000},
    messages=conversation
)
```

## Tool Use with Thinking

Extended thinking works with tools:

```python
tools = [{
    "name": "calculate",
    "description": "Perform calculations",
    "input_schema": {
        "type": "object",
        "properties": {
            "expression": {"type": "string"}
        },
        "required": ["expression"]
    }
}]

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={"type": "enabled", "budget_tokens": 10000},
    tools=tools,
    messages=[{
        "role": "user",
        "content": "Calculate the compound interest on $10,000 at 5% annual rate for 10 years"
    }]
)

# Response may include:
# 1. Thinking block (reasoning about approach)
# 2. Tool use block (calling calculator)
# 3. Text block (final answer)
```

## Pricing

Extended thinking incurs token costs:

**Token Costs:**
- Thinking tokens charged at **input token rate**
- Output tokens charged at **output token rate**
- Budget doesn't include final answer tokens

**Example (Sonnet 4.5):**
```
Thinking: 10,000 tokens × $3.00/MTok = $0.03
Answer: 500 tokens × $15.00/MTok = $0.0075
Total: $0.0375
```

**In Conversations:**
- Thinking blocks in message history charged as input tokens
- Can get expensive in long conversations

## Best Practices

### 1. Start with Larger Budgets

```python
# Good - generous budget for complex task
thinking={"type": "enabled", "budget_tokens": 16000}

# Bad - too small for complex reasoning
thinking={"type": "enabled", "budget_tokens": 1024}
```

### 2. Use for Complex Tasks Only

```python
# Good - complex reasoning needed
"Analyze the security implications of this authentication system..."

# Bad - simple query doesn't need thinking
"What is the capital of France?"
```

### 3. Monitor Token Usage

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={"type": "enabled", "budget_tokens": 10000},
    messages=[...]
)

print(f"Input tokens: {message.usage.input_tokens}")
print(f"Output tokens: {message.usage.output_tokens}")

# Calculate thinking tokens
thinking_tokens = sum(
    len(block.thinking) // 4  # Rough estimate
    for block in message.content
    if block.type == "thinking"
)
print(f"Approximate thinking tokens: {thinking_tokens}")
```

### 4. Cache Thinking for Conversations

```python
# For long conversations, cache thinking blocks
conversation.append({
    "role": "assistant",
    "content": response.content,
    "cache_control": {"type": "ephemeral"}  # Cache thinking + answer
})
```

### 5. Hide Thinking from End Users

```python
def get_answer_only(response):
    """Extract just the final answer"""
    for block in response.content:
        if block.type == "text":
            return block.text
    return None

answer = get_answer_only(message)
```

## Common Use Cases

### 1. Code Debugging

```python
code = """
def binary_search(arr, target):
    left, right = 0, len(arr)
    while left < right:
        mid = (left + right) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid
        else:
            right = mid
    return -1
"""

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={"type": "enabled", "budget_tokens": 10000},
    messages=[{
        "role": "user",
        "content": f"Debug this code and explain the bugs:\n\n{code}"
    }]
)
```

### 2. Algorithm Design

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={"type": "enabled", "budget_tokens": 16000},
    messages=[{
        "role": "user",
        "content": "Design an efficient algorithm to find the longest palindromic substring"
    }]
)
```

### 3. Mathematical Proofs

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={"type": "enabled", "budget_tokens": 20000},
    messages=[{
        "role": "user",
        "content": "Prove that there are infinitely many prime numbers"
    }]
)
```

### 4. System Design

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={"type": "enabled", "budget_tokens": 16000},
    messages=[{
        "role": "user",
        "content": "Design a distributed caching system that handles 1M requests/second with 99.99% availability"
    }]
)
```

## Limitations

- ❌ **Not compatible with temperature changes** - Must use default temperature
- ❌ **Cannot prefill responses** - No prefill when thinking is enabled
- ❌ **Cache invalidation** - Changing thinking budget invalidates cached prompts
- ❌ **Not on Haiku models** - Only Opus and Sonnet 4+ models
- ❌ **Minimum budget** - Must be at least 1,024 tokens
- ❌ **Increases latency** - Thinking takes time before answer appears

## Comparison: With vs Without Thinking

**Without Extended Thinking:**
```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=2048,
    messages=[{
        "role": "user",
        "content": "Solve x^2 - 5x + 6 = 0"
    }]
)
# Response: Direct answer with minimal explanation
```

**With Extended Thinking:**
```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=2048,
    thinking={"type": "enabled", "budget_tokens": 5000},
    messages=[{
        "role": "user",
        "content": "Solve x^2 - 5x + 6 = 0"
    }]
)
# Response includes:
# 1. Thinking: "Let me identify this as a quadratic equation..."
# 2. Answer: "The solutions are x = 2 and x = 3"
```

## Troubleshooting

### Issue: Budget Exhausted Quickly

**Cause:** Complex task needs more reasoning
**Solution:** Increase budget_tokens to 16,000-32,000

### Issue: High Costs

**Cause:** Large thinking budgets
**Solution:** Use thinking only for complex tasks, reduce budget

### Issue: Slow Responses

**Cause:** Thinking process takes time
**Solution:** Use streaming to show progress, or disable for simple tasks

### Issue: Cache Invalidation

**Cause:** Changing thinking budget
**Solution:** Keep thinking budget consistent across requests

## Related Documentation

- [Messages API](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)
- [TypeScript SDK](./05-typescript-sdk.md)
- [Streaming](./06-streaming.md)
- [Tool Use](./08-tool-use.md)
- [Prompt Caching](./09-prompt-caching.md)
- [Models](./10-models.md)
