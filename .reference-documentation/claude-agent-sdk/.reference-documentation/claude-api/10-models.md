# Claude API - Models Reference

**Sources:**
- https://docs.claude.com/en/docs/about-claude/models
- https://docs.claude.com/en/api/

**Fetched:** 2025-10-11

## Overview

Claude is available in several model families, each optimized for different use cases. The Claude 4 and Claude 3 families offer various intelligence levels, speed, and cost tradeoffs.

## Current Models

### Claude Sonnet 4.5

**API Name:** `claude-sonnet-4-5-20250929`

**Description:** Our best model for complex agents and coding

**Capabilities:**
- ✅ 200K context window (1M beta available)
- ✅ Highest intelligence across most tasks
- ✅ Vision (image understanding)
- ✅ Tool use / function calling
- ✅ Streaming
- ✅ Prompt caching
- ✅ Extended thinking (beta)
- ✅ Multilingual

**Pricing:**
- **Input:** $3.00 per million tokens
- **Output:** $15.00 per million tokens
- **Cache Write:** $3.75 per million tokens
- **Cache Read:** $0.30 per million tokens

**Best For:**
- Complex agentic workflows
- Advanced coding tasks
- Multi-step reasoning
- Data analysis and visualization
- Document understanding

---

### Claude Opus 4.1

**API Name:** `claude-opus-4-1-20250805`

**Description:** Exceptional model for specialized complex tasks

**Capabilities:**
- ✅ 200K context window
- ✅ Superior reasoning capabilities
- ✅ Vision (image understanding)
- ✅ Tool use / function calling
- ✅ Streaming
- ✅ Prompt caching
- ✅ Extended thinking (beta)
- ✅ Multilingual

**Pricing:**
- **Input:** $15.00 per million tokens
- **Output:** $75.00 per million tokens
- **Cache Write:** $18.75 per million tokens
- **Cache Read:** $1.50 per million tokens

**Best For:**
- Most challenging tasks requiring maximum intelligence
- Research and strategy
- Advanced mathematics and analysis
- Complex decision-making
- High-stakes applications

---

### Claude Sonnet 4

**API Name:** `claude-sonnet-4-20250514`

**Description:** High intelligence with balanced performance

**Capabilities:**
- ✅ 200K context window
- ✅ Vision (image understanding)
- ✅ Tool use / function calling
- ✅ Streaming
- ✅ Prompt caching
- ✅ Extended thinking (beta)
- ✅ Multilingual

**Pricing:**
- **Input:** $3.00 per million tokens
- **Output:** $15.00 per million tokens
- **Cache Write:** $3.75 per million tokens
- **Cache Read:** $0.30 per million tokens

**Best For:**
- General-purpose AI applications
- Conversational agents
- Content generation
- Analysis tasks

---

### Claude Sonnet 3.7

**API Name:** `claude-3-7-sonnet-20250219`

**Description:** High intelligence with extended thinking

**Capabilities:**
- ✅ 200K context window
- ✅ Vision (image understanding)
- ✅ Tool use / function calling
- ✅ Streaming
- ✅ Prompt caching
- ✅ Extended thinking
- ✅ Multilingual

**Pricing:**
- **Input:** $3.00 per million tokens
- **Output:** $15.00 per million tokens
- **Cache Write:** $3.75 per million tokens
- **Cache Read:** $0.30 per million tokens

**Best For:**
- Tasks requiring deep analysis
- Complex reasoning workflows
- Research applications

---

### Claude Haiku 3.5

**API Name:** `claude-3-5-haiku-20241022`

**Description:** Fastest model with intelligence at high speeds

**Capabilities:**
- ✅ 200K context window
- ✅ Vision (image understanding)
- ✅ Tool use / function calling
- ✅ Streaming
- ✅ Prompt caching
- ❌ Extended thinking (not available)
- ✅ Multilingual

**Pricing:**
- **Input:** $0.80 per million tokens
- **Output:** $4.00 per million tokens
- **Cache Write:** $1.00 per million tokens
- **Cache Read:** $0.08 per million tokens

**Best For:**
- High-volume, low-latency applications
- Real-time chat applications
- Simple classification and extraction
- Cost-sensitive deployments

---

### Claude Haiku 3

**API Name:** `claude-3-haiku-20240307`

**Description:** Fast and compact model

**Capabilities:**
- ✅ 200K context window
- ✅ Vision (image understanding)
- ✅ Tool use / function calling
- ✅ Streaming
- ✅ Prompt caching
- ❌ Extended thinking (not available)
- ✅ Multilingual

**Pricing:**
- **Input:** $0.80 per million tokens
- **Output:** $4.00 per million tokens
- **Cache Write:** $1.00 per million tokens
- **Cache Read:** $0.08 per million tokens

**Best For:**
- Budget-conscious applications
- Simple, fast interactions
- High-throughput processing

---

## Model Comparison

### By Intelligence

| Model | Intelligence Level | Best Use Case |
|-------|-------------------|---------------|
| Claude Opus 4.1 | Highest | Complex reasoning, research |
| Claude Sonnet 4.5 | Very High | Agents, coding, analysis |
| Claude Sonnet 4 | High | General-purpose AI |
| Claude Sonnet 3.7 | High | Deep analysis |
| Claude Haiku 3.5 | Moderate | Fast, intelligent responses |
| Claude Haiku 3 | Moderate | Fast, cost-effective |

### By Speed

| Model | Speed | Latency |
|-------|-------|---------|
| Claude Haiku 3.5 | Fastest | Lowest |
| Claude Haiku 3 | Very Fast | Very Low |
| Claude Sonnet 4.5 | Fast | Low |
| Claude Sonnet 4 | Fast | Low |
| Claude Sonnet 3.7 | Fast | Low |
| Claude Opus 4.1 | Moderate | Moderate |

### By Cost (Input Tokens)

| Model | Price per MTok | Relative Cost |
|-------|----------------|---------------|
| Claude Haiku 3/3.5 | $0.80 | 1× |
| Claude Sonnet 4.5/4/3.7 | $3.00 | 3.75× |
| Claude Opus 4.1 | $15.00 | 18.75× |

### Feature Matrix

| Feature | Opus 4.1 | Sonnet 4.5 | Sonnet 4 | Sonnet 3.7 | Haiku 3.5 | Haiku 3 |
|---------|----------|------------|----------|------------|-----------|---------|
| Context Window | 200K | 200K (1M beta) | 200K | 200K | 200K | 200K |
| Vision | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Tool Use | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Extended Thinking | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Streaming | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Prompt Caching | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Multilingual | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Model Selection Guide

### Choose Claude Opus 4.1 When:
- Maximum intelligence is required
- Working on research or strategic planning
- Cost is less important than quality
- Task requires deep reasoning and analysis
- Accuracy is critical

### Choose Claude Sonnet 4.5 When:
- Building complex agents
- Working on coding tasks
- Need high intelligence with good speed
- Building production applications
- Require extended context (beta 1M)

### Choose Claude Sonnet 4/3.7 When:
- Need balanced performance
- Building conversational applications
- Working on general-purpose tasks
- Cost-performance balance is important

### Choose Claude Haiku 3.5 When:
- Speed is critical
- Processing high volumes
- Tasks are straightforward
- Budget constraints exist
- Need fast responses at scale

### Choose Claude Haiku 3 When:
- Maximum cost efficiency needed
- Simple classification/extraction
- High-throughput applications
- Latency must be minimized

## Using Models

### Python

```python
import anthropic

client = anthropic.Anthropic()

# Claude Sonnet 4.5 (recommended)
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}]
)

# Claude Opus 4.1 (most capable)
message = client.messages.create(
    model="claude-opus-4-1-20250805",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Solve this complex problem..."}]
)

# Claude Haiku 3.5 (fastest)
message = client.messages.create(
    model="claude-3-5-haiku-20241022",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Quick question"}]
)
```

### TypeScript

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

// Claude Sonnet 4.5
const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Hello' }],
});

// Claude Opus 4.1
const message = await client.messages.create({
  model: 'claude-opus-4-1-20250805',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Complex problem...' }],
});

// Claude Haiku 3.5
const message = await client.messages.create({
  model: 'claude-3-5-haiku-20241022',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Quick question' }],
});
```

### cURL

```bash
# Claude Sonnet 4.5
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "Hello, Claude"}
    ]
  }'
```

## Context Windows

All current Claude models support:
- **Standard:** 200,000 tokens (~150,000 words or ~500 pages)
- **Beta (Sonnet 4.5 only):** 1,000,000 tokens

### Token Estimation

Rough estimates for English text:
- **1 token** ≈ 0.75 words
- **100 tokens** ≈ 75 words
- **1,000 tokens** ≈ 750 words
- **10,000 tokens** ≈ 7,500 words (15 pages)
- **200,000 tokens** ≈ 150,000 words (500 pages)

### Using Extended Context

```python
# Request extended context window (Sonnet 4.5 only)
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    messages=[{
        "role": "user",
        "content": very_large_document  # Up to ~1M tokens
    }]
)
```

## Migration Guide

### From Claude 3.5 Sonnet → Claude Sonnet 4.5

```python
# Old
model="claude-3-5-sonnet-20241022"

# New
model="claude-sonnet-4-5-20250929"
```

**Changes:**
- Improved coding capabilities
- Better agentic performance
- Same pricing
- Extended context available (beta)

### From Claude 3 Opus → Claude Opus 4.1

```python
# Old
model="claude-3-opus-20240229"

# New
model="claude-opus-4-1-20250805"
```

**Changes:**
- Superior reasoning
- Better at complex tasks
- Same pricing
- All Claude 4 improvements

### From Claude 3.5 Haiku → Claude Haiku 3.5

```python
# Old
model="claude-3-5-haiku-20241022"

# New - No change
model="claude-3-5-haiku-20241022"  # Current version
```

## Cost Calculator

### Example Costs

**10,000 input tokens, 1,000 output tokens:**

| Model | Input Cost | Output Cost | Total |
|-------|------------|-------------|-------|
| Haiku 3/3.5 | $0.008 | $0.004 | $0.012 |
| Sonnet 4.5/4/3.7 | $0.030 | $0.015 | $0.045 |
| Opus 4.1 | $0.150 | $0.075 | $0.225 |

### With Caching

**100,000 token document used 10 times:**

**Without Caching (Sonnet 4.5):**
```
10 requests × 100,000 tokens × $3.00/MTok = $3.00
```

**With Caching (Sonnet 4.5):**
```
1st request (cache write): 100,000 × $3.75/MTok = $0.375
9 more requests (cache read): 9 × 100,000 × $0.30/MTok = $0.270
Total: $0.645
Savings: $2.36 (79%)
```

## Performance Benchmarks

### Task Performance (Relative Comparison)

| Task | Opus 4.1 | Sonnet 4.5 | Sonnet 3.7 | Haiku 3.5 |
|------|----------|------------|------------|-----------|
| Coding | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Reasoning | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Speed | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Cost Efficiency | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Vision | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Agents | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

## Best Practices

### 1. Start with Sonnet 4.5

For most applications, Claude Sonnet 4.5 provides the best balance:
```python
model = "claude-sonnet-4-5-20250929"  # Good default choice
```

### 2. Use Haiku for Simple Tasks

If your task is straightforward, save costs with Haiku:
```python
if task_complexity == "simple":
    model = "claude-3-5-haiku-20241022"
else:
    model = "claude-sonnet-4-5-20250929"
```

### 3. Reserve Opus for Complex Tasks

Only use Opus when you need maximum intelligence:
```python
if requires_max_intelligence:
    model = "claude-opus-4-1-20250805"
```

### 4. Implement Fallbacks

```python
def create_message_with_fallback(messages, max_tokens=1024):
    models = [
        "claude-sonnet-4-5-20250929",  # Try best first
        "claude-sonnet-4-20250514",     # Fallback 1
        "claude-3-5-haiku-20241022"     # Fallback 2
    ]

    for model in models:
        try:
            return client.messages.create(
                model=model,
                max_tokens=max_tokens,
                messages=messages
            )
        except anthropic.RateLimitError:
            continue  # Try next model

    raise Exception("All models rate limited")
```

### 5. Monitor Costs

```python
def calculate_cost(usage, model_name):
    """Calculate cost based on model and usage"""
    pricing = {
        "claude-opus-4-1-20250805": {"input": 15.00, "output": 75.00},
        "claude-sonnet-4-5-20250929": {"input": 3.00, "output": 15.00},
        "claude-3-5-haiku-20241022": {"input": 0.80, "output": 4.00},
    }

    prices = pricing.get(model_name)
    input_cost = (usage.input_tokens / 1_000_000) * prices["input"]
    output_cost = (usage.output_tokens / 1_000_000) * prices["output"]

    return input_cost + output_cost

response = client.messages.create(...)
cost = calculate_cost(response.usage, "claude-sonnet-4-5-20250929")
print(f"Request cost: ${cost:.4f}")
```

## Version History

### Current Versions

- **Claude Sonnet 4.5:** `claude-sonnet-4-5-20250929` (Released: Sep 29, 2025)
- **Claude Opus 4.1:** `claude-opus-4-1-20250805` (Released: Aug 5, 2025)
- **Claude Sonnet 4:** `claude-sonnet-4-20250514` (Released: May 14, 2025)
- **Claude Sonnet 3.7:** `claude-3-7-sonnet-20250219` (Released: Feb 19, 2025)
- **Claude Haiku 3.5:** `claude-3-5-haiku-20241022` (Released: Oct 22, 2024)
- **Claude Haiku 3:** `claude-3-haiku-20240307` (Released: Mar 7, 2024)

### Legacy Models

The following models are deprecated:
- `claude-3-5-sonnet-20241022` → Migrate to `claude-sonnet-4-5-20250929`
- `claude-3-opus-20240229` → Migrate to `claude-opus-4-1-20250805`
- `claude-3-sonnet-20240229` → Migrate to `claude-sonnet-4-20250514`

## Related Documentation

- [Getting Started](./02-getting-started.md)
- [Messages API](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)
- [TypeScript SDK](./05-typescript-sdk.md)
- [Prompt Caching](./09-prompt-caching.md)
