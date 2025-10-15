# OpenAI Platform - Prompt Caching

**Source:** https://platform.openai.com/docs/guides/prompt-caching
**Fetched:** 2025-10-11

## Overview

Prompt caching automatically reduces costs and latency by reusing recently processed input tokens. When you send similar prompts with repeated content, OpenAI caches the processed tokens and provides a 50% discount on cached inputs.

**Benefits:**
- 💰 50% cost reduction on cached tokens
- ⚡ Up to 80% latency reduction for long prompts
- 🔄 Automatic—no code changes required
- 🎯 Works with all supported models

**Enabled Since:** October 1, 2024 (automatic)

---

## How Prompt Caching Works

### Automatic Caching

Caching is automatically applied to all requests—no extra configuration needed.

```python
from openai import OpenAI

client = OpenAI()

large_system_prompt = """You are a customer service expert...
[Large prompt with company policies, FAQs, etc. - 5,000 tokens]
"""

# First request: pays full price
response1 = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": large_system_prompt},  # Not cached yet
        {"role": "user", "content": "How do I return a product?"}
    ]
)

print(f"Prompt tokens: {response1.usage.prompt_tokens}")
print(f"Cached tokens: {response1.usage.prompt_tokens_details.cached_tokens}")

# Second request (within 5-10 minutes): uses cache
response2 = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": large_system_prompt},  # Cached!
        {"role": "user", "content": "What's your shipping policy?"}
    ]
)

print(f"Prompt tokens: {response2.usage.prompt_tokens}")
print(f"Cached tokens: {response2.usage.prompt_tokens_details.cached_tokens}")
# cached_tokens will be ~5,000 (50% discount applied)
```

### Cache Requirements

**Minimum Size:**
- Caching starts at 1,024 tokens
- Adds in increments of 128 tokens

**Cache Duration:**
- Cleared after 5-10 minutes of inactivity
- Always removed within 1 hour of last use

**What Gets Cached:**
- The longest prefix of your prompt that exceeds 1,024 tokens
- System messages and early conversation history
- Not the most recent user message (usually unique)

---

## Supported Models

### Models with Caching

All latest versions support automatic caching:

| Model | Input Price | Cached Price | Savings |
|-------|-------------|--------------|---------|
| GPT-4o | $2.50 / 1M | $1.25 / 1M | 50% |
| GPT-4o-mini | $0.15 / 1M | $0.075 / 1M | 50% |
| O1-preview | $15.00 / 1M | $7.50 / 1M | 50% |
| O1-mini | $3.00 / 1M | $1.50 / 1M | 50% |
| Fine-tuned GPT-4o | Custom | 50% off | 50% |

**Note:** Output tokens are not cached and cost the same.

---

## Identifying Cached Tokens

### Response Usage Field

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages
)

usage = response.usage

print(f"Total prompt tokens: {usage.prompt_tokens}")
print(f"Cached tokens: {usage.prompt_tokens_details.cached_tokens}")
print(f"Non-cached tokens: {usage.prompt_tokens - usage.prompt_tokens_details.cached_tokens}")
print(f"Completion tokens: {usage.completion_tokens}")

# Calculate actual cost
input_cost = (usage.prompt_tokens - usage.prompt_tokens_details.cached_tokens) * 2.50 / 1_000_000
cached_cost = usage.prompt_tokens_details.cached_tokens * 1.25 / 1_000_000
output_cost = usage.completion_tokens * 10.00 / 1_000_000

total_cost = input_cost + cached_cost + output_cost
print(f"Total cost: ${total_cost:.6f}")
```

### Example Response

```json
{
  "usage": {
    "prompt_tokens": 5234,
    "completion_tokens": 150,
    "total_tokens": 5384,
    "prompt_tokens_details": {
      "cached_tokens": 5120,  // 50% discount on these
      "audio_tokens": 0
    },
    "completion_tokens_details": {
      "reasoning_tokens": 0,
      "audio_tokens": 0,
      "accepted_prediction_tokens": 0,
      "rejected_prediction_tokens": 0
    }
  }
}
```

---

## Optimization Strategies

### 1. Structure for Caching

**Put static content first:**

```python
# ✅ Good: Static system prompt cached
messages = [
    {
        "role": "system",
        "content": large_static_prompt  # 5,000 tokens - will be cached
    },
    {
        "role": "user",
        "content": user_question  # 50 tokens - not cached (unique each time)
    }
]
```

**❌ Bad: Dynamic content prevents caching:**

```python
# ❌ Bad: Including timestamp prevents caching
messages = [
    {
        "role": "system",
        "content": f"Current time: {datetime.now()}. {large_static_prompt}"
        # Content changes every request, cache unusable
    },
    {
        "role": "user",
        "content": user_question
    }
]
```

### 2. Share Context Across Users

```python
# Shared company knowledge base (cached for all users)
COMPANY_CONTEXT = """
[Large company knowledge base - 10,000 tokens]
Product catalog, policies, FAQs, etc.
"""

def handle_customer_query(user_id, question):
    """Handle query with shared cached context."""
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "system",
                "content": COMPANY_CONTEXT  # Cached across all users
            },
            {
                "role": "user",
                "content": question  # Unique per request
            }
        ]
    )
    return response.choices[0].message.content
```

### 3. Maintain Conversation History

```python
class CachedConversation:
    def __init__(self, system_prompt):
        self.system_prompt = system_prompt  # Will be cached
        self.history = []

    def chat(self, user_message):
        """Chat with cached system prompt."""
        # Add user message
        self.history.append({"role": "user", "content": user_message})

        # Build messages (system prompt + history)
        messages = [
            {"role": "system", "content": self.system_prompt},
            *self.history
        ]

        response = client.chat.completions.create(
            model="gpt-4o",
            messages=messages
        )

        # Add assistant response
        assistant_message = response.choices[0].message.content
        self.history.append({"role": "assistant", "content": assistant_message})

        return assistant_message, response.usage

# Usage
conv = CachedConversation(large_system_prompt)

# First message: system prompt not cached yet
response1, usage1 = conv.chat("Hello")
print(f"Cached: {usage1.prompt_tokens_details.cached_tokens}")  # 0

# Second message: system prompt cached!
response2, usage2 = conv.chat("Tell me more")
print(f"Cached: {usage2.prompt_tokens_details.cached_tokens}")  # ~5,000
```

### 4. Batch Similar Requests

```python
async def process_batch_with_caching(items, system_prompt):
    """Process batch with shared cached prompt."""
    import asyncio

    async def process_one(item):
        response = await async_client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": system_prompt},  # Cached
                {"role": "user", "content": f"Process: {item}"}
            ]
        )
        return response

    # Process concurrently - all share cached system prompt
    results = await asyncio.gather(*[process_one(item) for item in items])
    return results

# All requests use the same cached system prompt
items = ["Item 1", "Item 2", "Item 3", ...]
results = asyncio.run(process_batch_with_caching(items, large_system_prompt))
```

---

## Cache Behavior

### What Gets Cached

**Cached:**
- ✅ System messages
- ✅ Early conversation history
- ✅ Static context (knowledge bases, examples)
- ✅ Repeated prompt prefixes

**Not Cached:**
- ❌ Most recent user message (usually unique)
- ❌ Dynamic timestamps or session IDs in prompts
- ❌ Prompts under 1,024 tokens
- ❌ Output tokens (completions)

### Cache Invalidation

Cache is cleared when:
- 5-10 minutes of inactivity
- Maximum 1 hour from last use
- Any character in the cached portion changes

```python
# Cache persists
prompt1 = "Long context... [5,000 tokens]" + "Question 1"
prompt2 = "Long context... [5,000 tokens]" + "Question 2"  # Cache hit

# Cache invalidated
prompt3 = "Long context modified... [5,000 tokens]" + "Question 3"  # Cache miss
```

---

## Cost Calculations

### Example: Customer Support Bot

```python
# Setup
SYSTEM_PROMPT_TOKENS = 8,000
USER_MESSAGE_TOKENS = 50
RESPONSE_TOKENS = 200

# Without caching (per request)
input_cost = (8,000 + 50) * 2.50 / 1_000_000 = $0.020125
output_cost = 200 * 10.00 / 1_000_000 = $0.002000
total = $0.022125 per request

# With caching (after first request)
cached_cost = 8,000 * 1.25 / 1_000_000 = $0.010000  # 50% off
new_tokens_cost = 50 * 2.50 / 1_000_000 = $0.000125
output_cost = 200 * 10.00 / 1_000_000 = $0.002000
total = $0.012125 per request

# Savings
savings_per_request = $0.010000 (45% overall savings)
savings_per_1000_requests = $10.00
savings_per_100000_requests = $1,000.00
```

### Cost Tracking Utility

```python
class CostTracker:
    def __init__(self):
        self.total_cost = 0
        self.total_savings = 0

    def track_request(self, usage):
        """Track cost and savings."""
        # Calculate costs (GPT-4o pricing)
        regular_input_tokens = usage.prompt_tokens - usage.prompt_tokens_details.cached_tokens
        cached_tokens = usage.prompt_tokens_details.cached_tokens

        regular_cost = regular_input_tokens * 2.50 / 1_000_000
        cached_cost = cached_tokens * 1.25 / 1_000_000
        output_cost = usage.completion_tokens * 10.00 / 1_000_000

        request_cost = regular_cost + cached_cost + output_cost

        # Calculate what it would have cost without caching
        uncached_cost = usage.prompt_tokens * 2.50 / 1_000_000 + output_cost
        savings = uncached_cost - request_cost

        self.total_cost += request_cost
        self.total_savings += savings

        return {
            "cost": request_cost,
            "savings": savings,
            "cached_tokens": cached_tokens
        }

    def report(self):
        """Generate cost report."""
        return {
            "total_cost": self.total_cost,
            "total_savings": self.total_savings,
            "effective_cost": self.total_cost,
            "cost_without_caching": self.total_cost + self.total_savings
        }

# Usage
tracker = CostTracker()

for i in range(100):
    response = client.chat.completions.create(...)
    stats = tracker.track_request(response.usage)
    print(f"Request {i+1}: Cost ${stats['cost']:.6f}, Saved ${stats['savings']:.6f}")

report = tracker.report()
print(f"Total cost: ${report['total_cost']:.2f}")
print(f"Total savings: ${report['total_savings']:.2f}")
```

---

## Advanced Patterns

### Pattern 1: Multi-Tenant with Shared Cache

```python
# Shared knowledge base cached for all tenants
SHARED_KB = """[10,000 token knowledge base]"""

def handle_tenant_request(tenant_id, user_message):
    """Process request with shared cached KB."""
    # Tenant-specific data (not cached, but small)
    tenant_config = get_tenant_config(tenant_id)  # ~100 tokens

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "system",
                "content": SHARED_KB  # Cached across all tenants
            },
            {
                "role": "user",
                "content": f"Tenant: {tenant_config}\n\nQuery: {user_message}"
            }
        ]
    )
    return response
```

### Pattern 2: Document Analysis with Caching

```python
def analyze_document_with_questions(document, questions):
    """Analyze document once, ask multiple questions."""
    # Document content cached after first question
    document_prompt = f"Document to analyze:\n\n{document}\n\n"  # 8,000 tokens

    results = []
    for question in questions:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[{
                "role": "user",
                "content": document_prompt + f"Question: {question}"
            }]
        )

        results.append({
            "question": question,
            "answer": response.choices[0].message.content,
            "cached_tokens": response.usage.prompt_tokens_details.cached_tokens
        })

    return results

# First question: no cache
# Subsequent questions: document cached!
questions = [
    "What is the main topic?",
    "Who are the key people mentioned?",
    "What are the action items?",
    "What are the deadlines?",
]

results = analyze_document_with_questions(large_document, questions)
```

### Pattern 3: Few-Shot Learning with Cache

```python
# Large set of examples (cached)
FEW_SHOT_EXAMPLES = """
[100 examples of input/output pairs - 15,000 tokens]
"""

def classify_with_examples(text):
    """Classify using cached few-shot examples."""
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "system",
                "content": FEW_SHOT_EXAMPLES  # Cached!
            },
            {
                "role": "user",
                "content": f"Classify: {text}"
            }
        ]
    )
    return response.choices[0].message.content

# All classifications use the same cached examples
results = [classify_with_examples(item) for item in items]
```

---

## Monitoring Cache Performance

### Cache Hit Rate

```python
class CacheMonitor:
    def __init__(self):
        self.requests = 0
        self.cache_hits = 0
        self.total_cached_tokens = 0

    def record(self, usage):
        """Record cache usage."""
        self.requests += 1
        cached = usage.prompt_tokens_details.cached_tokens

        if cached > 0:
            self.cache_hits += 1
            self.total_cached_tokens += cached

    def stats(self):
        """Get cache statistics."""
        hit_rate = self.cache_hits / self.requests if self.requests > 0 else 0

        return {
            "total_requests": self.requests,
            "cache_hits": self.cache_hits,
            "cache_hit_rate": f"{hit_rate * 100:.1f}%",
            "avg_cached_tokens": self.total_cached_tokens / self.cache_hits if self.cache_hits > 0 else 0
        }

# Usage
monitor = CacheMonitor()

for _ in range(1000):
    response = client.chat.completions.create(...)
    monitor.record(response.usage)

stats = monitor.stats()
print(f"Cache hit rate: {stats['cache_hit_rate']}")
print(f"Average cached tokens per hit: {stats['avg_cached_tokens']:.0f}")
```

---

## Best Practices

### DO:
✅ Put static content (system prompts, knowledge bases) at the beginning
✅ Reuse the same system prompt across requests
✅ Keep prompt structure consistent
✅ Monitor cached token counts
✅ Wait <10 minutes between similar requests for cache persistence

### DON'T:
❌ Include dynamic data (timestamps, session IDs) in system prompts
❌ Change prompt structure frequently
❌ Mix static and dynamic content
❌ Expect caching for prompts under 1,024 tokens
❌ Rely on cache for security (it's a performance feature)

---

## Troubleshooting

**Issue: No tokens being cached**

Possible causes:
- Prompt is under 1,024 tokens
- Prompt structure changes each request
- Cache expired (>10 minutes since last use)
- Dynamic content in early parts of prompt

**Issue: Fewer tokens cached than expected**

Possible causes:
- Only the longest matching prefix is cached
- Cache granularity is 128 tokens
- Recent changes to prompt structure

**Issue: Cache not persisting**

Possible causes:
- More than 10 minutes between requests
- More than 1 hour since cache creation
- Prompt content changed slightly

---

## Next Steps

1. **[Prompt Engineering →](./prompt-engineering.md)** - Advanced techniques
2. **[Prompting Overview →](./overview.md)** - Core concepts
3. **[Batch API →](../batch-api.md)** - Combine with batch processing
4. **[Cost Optimization →](../../09-going-live/cost-optimization/overview.md)** - More cost-saving strategies

---

## Additional Resources

- **Prompt Caching Guide**: https://platform.openai.com/docs/guides/prompt-caching
- **Prompt Caching Announcement**: https://openai.com/index/api-prompt-caching/
- **Cookbook Example**: https://cookbook.openai.com/examples/prompt_caching101
- **Pricing**: https://openai.com/api/pricing/

---

**Next**: [Prompt Engineering →](./prompt-engineering.md)
