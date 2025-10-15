# OpenAI Platform - Using GPT-5

**Source:** https://platform.openai.com/docs/guides/gpt-5
**Fetched:** 2025-10-11

## Overview

GPT-5 is OpenAI's most capable model, released in August 2025. It features built-in reasoning, state-of-the-art performance across coding, math, multimodal understanding, and health domains, with improved reliability and efficiency.

---

## Key Features

### Built-in Reasoning

GPT-5 is a unified system that automatically decides when to:
- **Respond quickly** for simple queries
- **Think longer** for complex problems

The model includes a smart router that analyzes:
- Conversation type
- Problem complexity
- Tool requirements
- User intent

### Performance Benchmarks

| Domain | Benchmark | GPT-5 Score |
|--------|-----------|-------------|
| Math | AIME 2025 | **94.6%** |
| Coding | SWE-bench Verified | **74.9%** |
| Coding | Aider Polyglot | **88%** |
| Multimodal | MMMU | **84.2%** |
| Health | HealthBench Hard | **46.2%** |

### Improved Reliability

- **45% fewer factual errors** than GPT-4o (with web search)
- **80% fewer factual errors** than o3 (with thinking mode)
- More consistent structured outputs
- Better instruction following

---

## Basic Usage

```python
from openai import OpenAI

client = OpenAI()

response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Explain quantum entanglement"}
    ]
)

print(response.choices[0].message.content)
```

---

## Reasoning Modes

### Automatic Reasoning

By default, GPT-5 automatically decides when to use reasoning:

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Solve this complex math problem: ..."}
    ]
)
# GPT-5 automatically engages reasoning for complex problems
```

### Manual Reasoning Control

Control reasoning effort explicitly:

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Complex problem"}],
    reasoning_effort="high"  # minimal, low, medium, high
)
```

#### Reasoning Effort Levels

**minimal**
- Fastest responses
- Little to no extended reasoning
- Best for: Simple queries, quick answers

```python
reasoning_effort="minimal"
```

**low**
- Light reasoning
- Balance of speed and thought
- Best for: Moderate complexity

```python
reasoning_effort="low"
```

**medium** (default)
- Balanced reasoning
- Good for most use cases
- Best for: General-purpose tasks

```python
reasoning_effort="medium"
```

**high**
- Deep reasoning
- Slower but most thorough
- Best for: Complex problems, critical decisions

```python
reasoning_effort="high"
```

---

## Verbosity Control

Control response length with the `verbosity` parameter:

```python
# Concise responses
response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "What is Python?"}],
    verbosity="low"  # low, medium, high
)

# Comprehensive responses
response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "What is Python?"}],
    verbosity="high"
)
```

**Verbosity Levels:**
- **low**: Short, to-the-point answers
- **medium**: Balanced detail (default)
- **high**: Comprehensive, detailed explanations

---

## Model Variants

### gpt-5

The flagship model with full capabilities.

```python
model="gpt-5"
```

**Use for:**
- Complex reasoning tasks
- Coding and debugging
- Multimodal analysis
- Research and analysis

**Pricing:** $1.25/1M input tokens, $10/1M output tokens

### gpt-5-mini

Faster, cost-efficient variant with strong performance.

```python
model="gpt-5-mini"
```

**Use for:**
- Production applications
- High-volume requests
- Cost-sensitive deployments
- Real-time interactions

**Pricing:** $0.30/1M input tokens, $1.20/1M output tokens

### gpt-5-nano

Ultra-fast, most cost-effective variant.

```python
model="gpt-5-nano"
```

**Use for:**
- Ultra-high volume
- Simple tasks at scale
- Edge deployments
- Latency-critical apps

**Pricing:** $0.10/1M input tokens, $0.40/1M output tokens

### gpt-5-codex

Optimized for agentic coding.

```python
model="gpt-5-codex"
```

**Use for:**
- Code generation
- IDE integrations
- Automated debugging
- Software engineering agents

**Pricing:** $1.50/1M input tokens, $12/1M output tokens

---

## Advanced Features

### Free-Form Function Calling

GPT-5 supports more flexible function calling patterns:

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "search",
            "description": "Search for information",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {"type": "string"}
                }
            }
        }
    }
]

response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Find info about quantum computing"}],
    tools=tools,
    tool_choice="auto"
)
```

### Context-Free Grammar (CFG)

Control output structure with grammar constraints:

```python
# Available in GPT-5 for structured generation
response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Generate a poem"}],
    response_format={
        "type": "json_schema",
        "json_schema": {...}
    }
)
```

### Multimodal Inputs

GPT-5 supports text, images, audio, and video:

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Analyze this image"},
                {"type": "image_url", "image_url": {"url": "https://..."}}
            ]
        }
    ]
)
```

---

## Best Practices

### 1. Choose the Right Variant

**Complex tasks**: Use `gpt-5`
```python
model="gpt-5"  # Full power
```

**High volume**: Use `gpt-5-mini`
```python
model="gpt-5-mini"  # Efficient
```

**Ultra-fast**: Use `gpt-5-nano`
```python
model="gpt-5-nano"  # Speed
```

**Coding**: Use `gpt-5-codex`
```python
model="gpt-5-codex"  # Specialized
```

### 2. Optimize Reasoning Effort

**Simple queries**: Use minimal reasoning
```python
reasoning_effort="minimal"  # Fast
```

**Complex problems**: Use high reasoning
```python
reasoning_effort="high"  # Thorough
```

### 3. Control Response Length

**Quick answers**: Use low verbosity
```python
verbosity="low"
```

**In-depth explanations**: Use high verbosity
```python
verbosity="high"
```

### 4. Leverage System Prompts

Provide clear context and constraints:

```python
messages = [
    {
        "role": "system",
        "content": """You are an expert software engineer.
        - Provide working code with explanations
        - Follow best practices
        - Include error handling
        - Use Python 3.10+ features"""
    },
    {"role": "user", "content": "Create a REST API client"}
]
```

### 5. Use Structured Outputs

Ensure reliable parsing:

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[...],
    response_format={
        "type": "json_schema",
        "json_schema": {
            "name": "extraction",
            "strict": True,
            "schema": {...}
        }
    }
)
```

---

## Common Use Cases

### 1. Advanced Coding

```python
def generate_code(description, language="python"):
    """Generate production-ready code."""
    response = client.chat.completions.create(
        model="gpt-5-codex",
        messages=[
            {
                "role": "system",
                "content": f"You are an expert {language} developer. Generate clean, tested code."
            },
            {"role": "user", "content": description}
        ],
        reasoning_effort="medium",
        verbosity="high"
    )
    return response.choices[0].message.content
```

### 2. Complex Problem Solving

```python
def solve_problem(problem):
    """Solve complex math or logic problems."""
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": "Solve step-by-step. Show your reasoning."
            },
            {"role": "user", "content": problem}
        ],
        reasoning_effort="high",  # Deep reasoning
        verbosity="high"  # Detailed explanation
    )
    return response.choices[0].message.content
```

### 3. Research Assistant

```python
def research_query(query):
    """Comprehensive research with sources."""
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": "Provide comprehensive research with citations."
            },
            {"role": "user", "content": query}
        ],
        reasoning_effort="medium",
        verbosity="high"
    )
    return response.choices[0].message.content
```

### 4. High-Volume Chatbot

```python
def chatbot_response(user_message, conversation_history):
    """Fast chatbot responses."""
    messages = conversation_history + [
        {"role": "user", "content": user_message}
    ]

    response = client.chat.completions.create(
        model="gpt-5-mini",  # Cost-efficient
        messages=messages,
        reasoning_effort="minimal",  # Fast
        verbosity="low",  # Concise
        max_tokens=150
    )
    return response.choices[0].message.content
```

### 5. Document Analysis

```python
def analyze_document(document_text):
    """Deep document analysis."""
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": "Analyze this document thoroughly. Extract key insights."
            },
            {"role": "user", "content": document_text}
        ],
        reasoning_effort="high",
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "analysis",
                "strict": True,
                "schema": {
                    "type": "object",
                    "properties": {
                        "summary": {"type": "string"},
                        "key_points": {"type": "array", "items": {"type": "string"}},
                        "sentiment": {"type": "string"},
                        "action_items": {"type": "array", "items": {"type": "string"}}
                    },
                    "required": ["summary", "key_points"],
                    "additionalProperties": False
                }
            }
        }
    )
    return json.loads(response.choices[0].message.content)
```

---

## Performance Optimization

### Minimize Tokens

Use concise prompts and lower verbosity:

```python
response = client.chat.completions.create(
    model="gpt-5-nano",
    messages=[{"role": "user", "content": "Brief: explain ML"}],
    verbosity="low",
    max_tokens=100
)
```

### Use Prompt Caching

Cache long system prompts (50% cost reduction):

```python
# System prompt > 1,024 tokens gets cached automatically
system_prompt = "..." * 2000  # Long instructions

response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "system", "content": system_prompt},  # Cached!
        {"role": "user", "content": "New query"}
    ]
)
```

### Batch Processing

Use Batch API for 50% discount:

```python
# For non-urgent requests
batch = client.batches.create(
    input_file_id=file_id,
    endpoint="/v1/chat/completions",
    completion_window="24h"
)
```

---

## Error Handling

```python
from openai import OpenAI, APIError, RateLimitError

client = OpenAI()

try:
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[...]
    )
except RateLimitError:
    print("Rate limit hit. Consider using gpt-5-mini for high volume.")
except APIError as e:
    print(f"API error: {e}")
```

---

## Comparison with Other Models

| Feature | GPT-5 | GPT-4.1 | GPT-4o | o3 |
|---------|-------|---------|--------|-----|
| Built-in Reasoning | ✅ | ❌ | ❌ | ✅ |
| Coding Performance | Best | Good | Good | Best |
| Multimodal | ✅ | ✅ | ✅ | ❌ |
| Speed | Fast | Fast | Fast | Slow |
| Cost (input) | $1.25 | $2.50 | $2.50 | $10.00 |
| Context Window | 256K | 1M | 128K | Varies |
| Best For | General | Long docs | Multimodal | Pure reasoning |

---

## Migration from GPT-4

```python
# Before (GPT-4o)
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[...],
    temperature=0.7
)

# After (GPT-5)
response = client.chat.completions.create(
    model="gpt-5",
    messages=[...],
    reasoning_effort="medium",  # New parameter
    verbosity="medium",  # New parameter
    temperature=0.7
)
```

---

## Additional Resources

- **GPT-5 Prompting Guide**: https://cookbook.openai.com/examples/gpt-5/gpt-5_prompting_guide
- **API Reference**: https://platform.openai.com/docs/api-reference/chat
- **Pricing**: https://openai.com/api/pricing
- **Model Card**: https://openai.com/gpt-5

---

**Next**: [Migrate to Responses API →](./migrate-responses-api.md)
