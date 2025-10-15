# Claude API - Prompt Caching Guide

**Sources:**
- https://docs.claude.com/en/docs/build-with-claude/prompt-caching
- https://github.com/anthropics/anthropic-sdk-python
- https://github.com/anthropics/anthropic-sdk-typescript

**Fetched:** 2025-10-11

## Overview

Prompt caching allows you to reduce costs and latency by reusing large portions of prompts across multiple API calls. When you mark sections of your prompt with `cache_control`, Claude caches that content and reuses it for subsequent requests.

## How It Works

1. Mark prompt sections with `cache_control`
2. On first request: Content is processed and cached (cache write)
3. On subsequent requests: Cached content is loaded instantly (cache read)
4. Cache persists for the TTL duration (5 minutes or 1 hour)

## Supported Models

| Model | Prompt Caching |
|-------|----------------|
| Claude Sonnet 4.5 | ✅ Yes |
| Claude Opus 4.1 | ✅ Yes |
| Claude Opus 4 | ✅ Yes |
| Claude Sonnet 4 | ✅ Yes |
| Claude Sonnet 3.7 | ✅ Yes |
| Claude Haiku 3.5 | ✅ Yes |
| Claude Haiku 3 | ✅ Yes |

## Pricing

### Cost Structure

- **Cache Writes:** 25% more expensive than base input tokens
- **Cache Reads:** 90% cheaper than base input tokens (10% of base price)
- **Regular Input Tokens:** Standard pricing

### Example Pricing (Claude Sonnet 4.5)

| Token Type | Price per MTok | Relative Cost |
|------------|----------------|---------------|
| Input tokens | $3.00 | 1.0× |
| Cache write tokens | $3.75 | 1.25× |
| Cache read tokens | $0.30 | 0.1× |
| Output tokens | $15.00 | 5.0× |

### Savings Calculator

```python
# Scenario: 10,000 token prompt used 100 times

# Without caching:
cost_without = (10_000 * 100 / 1_000_000) * 3.00 = $3.00

# With caching:
cache_write = (10_000 / 1_000_000) * 3.75 = $0.0375
cache_reads = (10_000 * 99 / 1_000_000) * 0.30 = $0.297
cost_with = cache_write + cache_reads = $0.3345

# Savings: $2.67 (89% reduction)
```

## Cache Control

### TTL Options

```python
"cache_control": {
    "type": "ephemeral",
    "ttl": "5m"   # or "1h"
}
```

- **`"5m"`** - 5 minute cache (default)
- **`"1h"`** - 1 hour cache (beta)

### Cache Hierarchy

Caching follows this order:
1. **Tools** - Cached first
2. **System** - Cached second
3. **Messages** - Cached last

## Python Implementation

### Basic Caching

```python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": "You are an AI assistant with expertise in Python programming...",
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=[
        {"role": "user", "content": "Write a hello world program"}
    ]
)

# Check cache usage
print(f"Cache creation: {message.usage.cache_creation_input_tokens}")
print(f"Cache read: {message.usage.cache_read_input_tokens}")
print(f"Input tokens: {message.usage.input_tokens}")
```

### Caching with 1-Hour TTL

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": "Large system prompt...",
            "cache_control": {"type": "ephemeral", "ttl": "1h"}
        }
    ],
    messages=[{"role": "user", "content": "Hello"}]
)
```

### Multi-Level Caching

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": "Base instructions that rarely change...",
        },
        {
            "type": "text",
            "text": "Context-specific instructions...",
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=[
        {"role": "user", "content": "Question here"}
    ]
)
```

### Caching Large Documents

```python
def query_document(document_content, question):
    """Query a large document efficiently with caching"""
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        system=[
            {
                "type": "text",
                "text": "You are a document analysis assistant. Answer questions based on the provided document."
            },
            {
                "type": "text",
                "text": f"<document>\n{document_content}\n</document>",
                "cache_control": {"type": "ephemeral"}
            }
        ],
        messages=[
            {"role": "user", "content": question}
        ]
    )

    return message.content[0].text

# First call - creates cache
answer1 = query_document(large_doc, "What is the main topic?")

# Subsequent calls - use cache
answer2 = query_document(large_doc, "Who are the key people mentioned?")
answer3 = query_document(large_doc, "What are the conclusions?")
```

### Caching Tools

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
        },
        "cache_control": {"type": "ephemeral"}
    },
    # More tools...
]

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "What's the weather in SF?"}]
)
```

### Caching Conversation History

```python
def chat_with_history(conversation_history, new_message):
    """Maintain conversation with cached history"""
    messages = conversation_history + [
        {"role": "user", "content": new_message}
    ]

    # Mark last user message for caching
    if len(messages) >= 2:
        # Cache the conversation up to the last message
        messages[-2]["cache_control"] = {"type": "ephemeral"}

    response = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=messages
    )

    return response

# Usage
history = []
response1 = chat_with_history(history, "Tell me about Python")
history.append({"role": "user", "content": "Tell me about Python"})
history.append({"role": "assistant", "content": response1.content[0].text})

response2 = chat_with_history(history, "What about its syntax?")
```

## TypeScript Implementation

### Basic Caching

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  system: [
    {
      type: 'text',
      text: 'You are an AI assistant with expertise in TypeScript programming...',
      cache_control: { type: 'ephemeral' },
    },
  ],
  messages: [
    { role: 'user', content: 'Write a hello world program' },
  ],
});

// Check cache usage
console.log(`Cache creation: ${message.usage.cache_creation_input_tokens}`);
console.log(`Cache read: ${message.usage.cache_read_input_tokens}`);
console.log(`Input tokens: ${message.usage.input_tokens}`);
```

### Caching with 1-Hour TTL

```typescript
const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  system: [
    {
      type: 'text',
      text: 'Large system prompt...',
      cache_control: { type: 'ephemeral', ttl: '1h' },
    },
  ],
  messages: [{ role: 'user', content: 'Hello' }],
});
```

### Document Query with Caching

```typescript
async function queryDocument(
  documentContent: string,
  question: string
): Promise<string> {
  const message = await client.messages.create({
    model: 'claude-sonnet-4-5-20250929',
    max_tokens: 2048,
    system: [
      {
        type: 'text',
        text: 'You are a document analysis assistant.',
      },
      {
        type: 'text',
        text: `<document>\n${documentContent}\n</document>`,
        cache_control: { type: 'ephemeral' },
      },
    ],
    messages: [{ role: 'user', content: question }],
  });

  return message.content[0].text;
}

// First call - creates cache
const answer1 = await queryDocument(largeDoc, 'What is the main topic?');

// Subsequent calls - use cache
const answer2 = await queryDocument(largeDoc, 'Who are mentioned?');
```

### Streaming with Caching

```typescript
const stream = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  system: [
    {
      type: 'text',
      text: 'Large system prompt...',
      cache_control: { type: 'ephemeral' },
    },
  ],
  messages: [{ role: 'user', content: 'Hello' }],
  stream: true,
});

for await (const event of stream) {
  if (event.type === 'message_start') {
    console.log('Cache stats:', event.message.usage);
  } else if (event.type === 'content_block_delta') {
    process.stdout.write(event.delta.text || '');
  }
}
```

## Best Practices

### 1. Cache Stable Content

```python
# Good - Cache stable instructions
system=[
    {
        "type": "text",
        "text": "Base instructions that don't change",
        "cache_control": {"type": "ephemeral"}
    }
]

# Bad - Don't cache dynamic content
system=[
    {
        "type": "text",
        "text": f"Current time: {datetime.now()}",  # Changes every call
        "cache_control": {"type": "ephemeral"}
    }
]
```

### 2. Place Cached Content Early

```python
# Good - Cached content at the beginning
system=[
    {
        "type": "text",
        "text": "Large document...",
        "cache_control": {"type": "ephemeral"}
    },
    {
        "type": "text",
        "text": "Dynamic instructions..."
    }
]

# Less efficient - Cached content at the end
system=[
    {
        "type": "text",
        "text": "Dynamic instructions..."
    },
    {
        "type": "text",
        "text": "Large document...",
        "cache_control": {"type": "ephemeral"}
    }
]
```

### 3. Minimum Cacheable Size

Different models have different minimum cacheable token counts:

| Model | Minimum Tokens |
|-------|----------------|
| Claude Sonnet 4.5 | 1024 |
| Claude Opus 4.1 | 1024 |
| Claude Haiku 3.5 | 2048 |

### 4. Strategic Cache Breakpoints

```python
# Multiple cache points for different update frequencies
system=[
    {
        "type": "text",
        "text": "Core instructions (never change)",
    },
    {
        "type": "text",
        "text": "Domain knowledge (changes monthly)",
        "cache_control": {"type": "ephemeral", "ttl": "1h"}
    },
    {
        "type": "text",
        "text": "Recent context (changes per session)",
        "cache_control": {"type": "ephemeral", "ttl": "5m"}
    }
]
```

### 5. Monitor Cache Hit Rates

```python
def track_cache_performance(response):
    """Track cache efficiency"""
    usage = response.usage

    cache_hit_rate = 0
    if usage.cache_read_input_tokens + usage.input_tokens > 0:
        cache_hit_rate = (
            usage.cache_read_input_tokens /
            (usage.cache_read_input_tokens + usage.input_tokens)
        )

    return {
        "cache_creation": usage.cache_creation_input_tokens,
        "cache_reads": usage.cache_read_input_tokens,
        "input_tokens": usage.input_tokens,
        "hit_rate": f"{cache_hit_rate:.1%}"
    }

response = client.messages.create(...)
stats = track_cache_performance(response)
print(stats)
```

## Common Use Cases

### 1. RAG (Retrieval Augmented Generation)

```python
def rag_with_caching(knowledge_base, query):
    """Use cached knowledge base for multiple queries"""
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        system=[
            {
                "type": "text",
                "text": "You answer questions using the provided knowledge base."
            },
            {
                "type": "text",
                "text": f"<knowledge_base>\n{knowledge_base}\n</knowledge_base>",
                "cache_control": {"type": "ephemeral"}
            }
        ],
        messages=[{"role": "user", "content": query}]
    )

    return message.content[0].text
```

### 2. Code Analysis

```python
def analyze_codebase(codebase_content, analysis_request):
    """Analyze code with cached codebase"""
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        system=[
            {
                "type": "text",
                "text": "You are a code analysis assistant."
            },
            {
                "type": "text",
                "text": f"<codebase>\n{codebase_content}\n</codebase>",
                "cache_control": {"type": "ephemeral"}
            }
        ],
        messages=[{"role": "user", "content": analysis_request}]
    )

    return message.content[0].text

# Multiple analyses on same codebase
analyze_codebase(code, "Find security issues")
analyze_codebase(code, "Identify performance bottlenecks")
analyze_codebase(code, "Suggest refactoring opportunities")
```

### 3. Multi-Turn Conversations

```python
class CachedConversation:
    def __init__(self, system_prompt, knowledge_base):
        self.system_prompt = system_prompt
        self.knowledge_base = knowledge_base
        self.messages = []

    def send_message(self, user_message):
        self.messages.append({"role": "user", "content": user_message})

        response = client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            system=[
                {
                    "type": "text",
                    "text": self.system_prompt
                },
                {
                    "type": "text",
                    "text": self.knowledge_base,
                    "cache_control": {"type": "ephemeral"}
                }
            ],
            messages=self.messages
        )

        assistant_message = response.content[0].text
        self.messages.append({"role": "assistant", "content": assistant_message})

        return assistant_message, response.usage

# Usage
conv = CachedConversation(
    "You are a helpful assistant",
    "Large knowledge base..."
)

response1, usage1 = conv.send_message("Question 1")
response2, usage2 = conv.send_message("Question 2")
```

### 4. Agentic Tools with Caching

```python
tools = [
    {
        "name": "search_database",
        "description": "Search the product database",
        "input_schema": {
            "type": "object",
            "properties": {
                "query": {"type": "string"}
            },
            "required": ["query"]
        }
    },
    {
        "name": "get_user_info",
        "description": "Get user account information",
        "input_schema": {
            "type": "object",
            "properties": {
                "user_id": {"type": "string"}
            },
            "required": ["user_id"]
        }
    },
    {
        "name": "create_order",
        "description": "Create a new order",
        "input_schema": {
            "type": "object",
            "properties": {
                "user_id": {"type": "string"},
                "product_id": {"type": "string"},
                "quantity": {"type": "integer"}
            },
            "required": ["user_id", "product_id", "quantity"]
        },
        "cache_control": {"type": "ephemeral"}  # Cache all tools
    }
]

response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "Help me place an order"}]
)
```

## Cache Invalidation

Caches are invalidated when:

1. **TTL expires** - 5 minutes or 1 hour
2. **Exact content changes** - Any modification invalidates cache
3. **Order changes** - Rearranging cached blocks invalidates cache

### Exact Match Required

```python
# First request
system=[{"type": "text", "text": "Hello World", "cache_control": {"type": "ephemeral"}}]
# Cache created ✅

# Second request - DIFFERENT TEXT
system=[{"type": "text", "text": "Hello World!", "cache_control": {"type": "ephemeral"}}]
# Cache miss ❌ - Text changed

# Third request - SAME AS FIRST
system=[{"type": "text", "text": "Hello World", "cache_control": {"type": "ephemeral"}}]
# Cache hit ✅ - Exact match
```

## Limitations

- **Minimum size:** Content must meet minimum token threshold
- **Exact matching:** 100% identical content required for cache hit
- **No partial caching:** Can't cache part of a cached block
- **Cannot cache thinking blocks:** Extended thinking not cacheable
- **TTL limits:** Maximum 1 hour cache duration

## Monitoring and Analytics

### Track Cache Performance

```python
class CacheAnalytics:
    def __init__(self):
        self.total_cache_writes = 0
        self.total_cache_reads = 0
        self.total_input_tokens = 0
        self.requests = 0

    def record(self, usage):
        self.total_cache_writes += usage.cache_creation_input_tokens or 0
        self.total_cache_reads += usage.cache_read_input_tokens or 0
        self.total_input_tokens += usage.input_tokens or 0
        self.requests += 1

    def report(self):
        cache_hit_rate = (
            self.total_cache_reads /
            (self.total_cache_reads + self.total_input_tokens)
            if (self.total_cache_reads + self.total_input_tokens) > 0
            else 0
        )

        # Calculate costs (Sonnet 4.5 pricing)
        cache_write_cost = (self.total_cache_writes / 1_000_000) * 3.75
        cache_read_cost = (self.total_cache_reads / 1_000_000) * 0.30
        input_cost = (self.total_input_tokens / 1_000_000) * 3.00
        total_cost = cache_write_cost + cache_read_cost + input_cost

        # Calculate what it would cost without caching
        total_tokens = (
            self.total_cache_writes +
            self.total_cache_reads +
            self.total_input_tokens
        )
        cost_without_cache = (total_tokens / 1_000_000) * 3.00

        savings = cost_without_cache - total_cost

        return {
            "requests": self.requests,
            "cache_hit_rate": f"{cache_hit_rate:.1%}",
            "total_cost": f"${total_cost:.4f}",
            "cost_without_cache": f"${cost_without_cache:.4f}",
            "savings": f"${savings:.4f}",
            "savings_percent": f"{(savings/cost_without_cache*100):.1f}%"
        }

# Usage
analytics = CacheAnalytics()

for query in queries:
    response = client.messages.create(...)
    analytics.record(response.usage)

print(analytics.report())
```

## Complete Example

```python
import anthropic
from pathlib import Path

class CachedDocumentAssistant:
    def __init__(self, document_path):
        self.client = anthropic.Anthropic()
        self.document = Path(document_path).read_text()
        self.cache_stats = {
            "hits": 0,
            "misses": 0,
            "writes": 0
        }

    def query(self, question):
        """Query the document with caching"""
        response = self.client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            system=[
                {
                    "type": "text",
                    "text": "You are a document analysis assistant. Answer questions based solely on the provided document."
                },
                {
                    "type": "text",
                    "text": f"<document>\n{self.document}\n</document>",
                    "cache_control": {"type": "ephemeral"}
                }
            ],
            messages=[{"role": "user", "content": question}]
        )

        # Track cache performance
        if response.usage.cache_creation_input_tokens > 0:
            self.cache_stats["writes"] += 1
            self.cache_stats["misses"] += 1
        elif response.usage.cache_read_input_tokens > 0:
            self.cache_stats["hits"] += 1
        else:
            self.cache_stats["misses"] += 1

        return {
            "answer": response.content[0].text,
            "usage": response.usage,
            "cache_stats": self.cache_stats.copy()
        }

# Usage
assistant = CachedDocumentAssistant("large_document.txt")

result1 = assistant.query("What is the main topic?")
print(f"Answer: {result1['answer']}")
print(f"Cache: {result1['cache_stats']}")

result2 = assistant.query("Who are the key people?")
print(f"Answer: {result2['answer']}")
print(f"Cache: {result2['cache_stats']}")
```

## Related Documentation

- [Messages API](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)
- [TypeScript SDK](./05-typescript-sdk.md)
- [Tool Use](./08-tool-use.md)
- [Examples](./11-examples.md)
