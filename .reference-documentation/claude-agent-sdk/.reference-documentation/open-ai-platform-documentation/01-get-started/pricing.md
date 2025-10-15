# OpenAI Platform - Pricing

**Source:** https://openai.com/api/pricing
**Fetched:** 2025-10-11

## Overview

OpenAI API pricing is based on **token usage**. You pay for:
- **Input tokens**: Text, images, or audio you send to the API
- **Output tokens**: Text, images, or audio the API generates
- **Cached tokens** (where applicable): Reduced cost for cached prompts

Pricing varies by model, with more capable models costing more per token.

---

## What is a Token?

- A token is a mathematical representation of text
- **1 token ≈ 0.75 words** in English
- **1 token ≈ 4 characters** on average
- Example: "Hello, world!" = ~3 tokens

**Token Counter**: Use https://platform.openai.com/tokenizer to count tokens in your text.

---

## GPT-5 Series Pricing

### gpt-5

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$1.25** / 1M tokens | **$10.00** / 1M tokens | **$0.625** / 1M tokens |

### gpt-5-mini

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$0.30** / 1M tokens | **$1.20** / 1M tokens | **$0.15** / 1M tokens |

### gpt-5-nano

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$0.10** / 1M tokens | **$0.40** / 1M tokens | **$0.05** / 1M tokens |

### gpt-5-chat

| Input | Output |
|-------|--------|
| **$1.25** / 1M tokens | **$10.00** / 1M tokens |

### gpt-5-codex

| Input | Output |
|-------|--------|
| **$1.50** / 1M tokens | **$12.00** / 1M tokens |

---

## GPT-4.1 Series Pricing

### gpt-4.1

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$2.50** / 1M tokens | **$10.00** / 1M tokens | **$1.25** / 1M tokens |

### gpt-4.1-mini

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$0.15** / 1M tokens | **$0.60** / 1M tokens | **$0.075** / 1M tokens |

### gpt-4.1-nano

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$0.05** / 1M tokens | **$0.20** / 1M tokens | **$0.025** / 1M tokens |

---

## GPT-4o Series Pricing

### gpt-4o

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$2.50** / 1M tokens | **$10.00** / 1M tokens | **$1.25** / 1M tokens |

**Image Input**: $0.00150 per image (high-res adds $0.00085 per 512px tile)

**Audio**:
- Input: $100 / 1M tokens (~13.3 hours)
- Output: $200 / 1M tokens (~6.7 hours)

### gpt-4o-mini

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$0.15** / 1M tokens | **$0.60** / 1M tokens | **$0.075** / 1M tokens |

**Image Input**: $0.0000725 per image (high-res adds $0.00003625 per 512px tile)

---

## O-Series Pricing (Reasoning Models)

### o3

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$10.00** / 1M tokens | **$40.00** / 1M tokens | **$5.00** / 1M tokens |

### o3-mini

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$1.10** / 1M tokens | **$4.40** / 1M tokens | **$0.55** / 1M tokens |

### o4-mini

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$1.10** / 1M tokens | **$4.40** / 1M tokens | **$0.55** / 1M tokens |

---

## GPT-4 Series Pricing (Previous Generation)

### gpt-4-turbo

| Input | Output | Cached Input |
|-------|--------|--------------|
| **$10.00** / 1M tokens | **$30.00** / 1M tokens | **$5.00** / 1M tokens |

### gpt-4

| Input | Output |
|-------|--------|
| **$30.00** / 1M tokens | **$60.00** / 1M tokens |

### gpt-4-32k

| Input | Output |
|-------|--------|
| **$60.00** / 1M tokens | **$120.00** / 1M tokens |

---

## GPT-3.5 Pricing (Legacy)

### gpt-3.5-turbo

| Input | Output |
|-------|--------|
| **$0.50** / 1M tokens | **$1.50** / 1M tokens |

---

## Specialized Models Pricing

### Image Generation

**gpt-image-1 (DALL-E 3 replacement)**:
- Standard (1024×1024): **$0.040** per image
- Standard (1024×1792, 1792×1024): **$0.080** per image
- HD (1024×1024): **$0.080** per image
- HD (1024×1792, 1792×1024): **$0.120** per image

**DALL-E 2** (Legacy):
- 1024×1024: **$0.020** per image
- 512×512: **$0.018** per image
- 256×256: **$0.016** per image

### Video Generation

**sora-2**:
- Pricing varies by duration and resolution
- Contact sales for details

### Audio

**Whisper (Speech-to-Text)**:
- **$0.006** per minute

**TTS (Text-to-Speech)**:
- tts-1: **$15.00** / 1M characters
- tts-1-hd: **$30.00** / 1M characters

### Embeddings

| Model | Price |
|-------|-------|
| text-embedding-3-large | **$0.13** / 1M tokens |
| text-embedding-3-small | **$0.02** / 1M tokens |
| text-embedding-ada-002 | **$0.10** / 1M tokens |

### Moderation

**text-moderation-latest**: **Free**

---

## Batch API Pricing

Get 50% off by using the Batch API for asynchronous requests with 24-hour turnaround.

| Model | Batch Input | Batch Output |
|-------|-------------|--------------|
| gpt-5 | **$0.625** / 1M tokens | **$5.00** / 1M tokens |
| gpt-5-mini | **$0.15** / 1M tokens | **$0.60** / 1M tokens |
| gpt-4.1 | **$1.25** / 1M tokens | **$5.00** / 1M tokens |
| gpt-4o | **$1.25** / 1M tokens | **$5.00** / 1M tokens |

---

## Prompt Caching

Reduce costs by caching system prompts and long contexts.

**Cached tokens cost 50% less** than regular input tokens.

Example savings with GPT-5:
- Regular input: $1.25 / 1M tokens
- Cached input: $0.625 / 1M tokens
- **50% savings on repeated content**

**How it works**:
- Automatically caches prompts >1,024 tokens
- Cache lifetime: 5-10 minutes
- Ideal for: System prompts, few-shot examples, long contexts

---

## Fine-Tuning Pricing

### Training Costs

| Model | Training Price |
|-------|----------------|
| gpt-5-nano | **$8.00** / 1M tokens |
| gpt-4.1-mini | **$3.00** / 1M tokens |
| gpt-3.5-turbo | **$8.00** / 1M tokens |

### Usage Costs (Fine-Tuned Models)

| Model | Input | Output |
|-------|-------|--------|
| gpt-5-nano-ft | **$0.30** / 1M tokens | **$1.20** / 1M tokens |
| gpt-4.1-mini-ft | **$0.30** / 1M tokens | **$1.20** / 1M tokens |
| gpt-3.5-turbo-ft | **$3.00** / 1M tokens | **$6.00** / 1M tokens |

---

## Realtime API Pricing

For bidirectional audio/text streaming:

### Audio Costs

**Input audio**: $100 / 1M tokens (~13.3 hours)
**Output audio**: $200 / 1M tokens (~6.7 hours)

### Text Costs

Use standard model pricing for text tokens.

---

## Cost Optimization Strategies

### 1. Choose the Right Model

**High volume, simple tasks**: Use gpt-5-nano or gpt-4.1-nano
**Complex reasoning**: Use o3-mini instead of o3
**Balance**: Use gpt-5-mini or gpt-4.1-mini

### 2. Use Prompt Caching

Cache system prompts and examples to save 50%:
```python
# Long system prompt gets cached automatically
system_prompt = "..." * 1000  # Long instructions

response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "system", "content": system_prompt},  # Cached!
        {"role": "user", "content": "New user query"}
    ]
)
```

### 3. Use Batch API

Save 50% for non-urgent requests:
```python
# Regular API: $1.25/1M input tokens
# Batch API: $0.625/1M input tokens
```

### 4. Limit max_tokens

Set appropriate limits to avoid unnecessary generation:
```python
response = client.chat.completions.create(
    model="gpt-5",
    max_tokens=150,  # Limit output length
    messages=[...]
)
```

### 5. Use Streaming

Stop generation early if you have enough:
```python
for chunk in client.chat.completions.create(
    model="gpt-5",
    stream=True,
    messages=[...]
):
    # Can stop early to save costs
    if should_stop():
        break
```

### 6. Compress Prompts

Remove unnecessary whitespace and formatting:
```python
# Bad: "The    user     wants..."
# Good: "The user wants..."
```

### 7. Use Embeddings for Search

Don't send entire documents to GPT-5. Use embeddings + retrieval:
- Embeddings: $0.13/1M tokens
- Then send only relevant chunks to GPT-5

---

## Usage Limits and Billing

### Rate Limits

Rate limits vary by:
- **Usage tier**: Free, Tier 1-5 (based on spend)
- **Model**: Different limits per model
- **Request type**: RPM (requests/min) and TPM (tokens/min)

View your limits: https://platform.openai.com/account/rate-limits

### Billing

- **Prepaid credits**: Purchase in advance
- **Usage-based**: Pay as you go
- **Monthly invoicing**: Available for enterprise

### Setting Limits

1. Go to https://platform.openai.com/account/billing/limits
2. Set monthly budget cap
3. Configure email alerts at 50%, 75%, 90%
4. Set hard limit to prevent overages

---

## Pricing Calculator

Estimate your costs:

**Example: Chatbot**
- 1,000 users/day
- 10 messages/user
- 100 tokens/message input
- 150 tokens/message output
- Model: gpt-5-mini

**Calculation**:
```
Daily tokens:
- Input: 1,000 × 10 × 100 = 1M tokens
- Output: 1,000 × 10 × 150 = 1.5M tokens

Daily cost:
- Input: 1M × $0.30 = $0.30
- Output: 1.5M × $1.20 = $1.80
- Total: $2.10/day

Monthly cost: $2.10 × 30 = $63
```

Use official calculator: https://platform.openai.com/playground

---

## Price Comparison (per 1M tokens)

| Model | Input | Output | Total (1M in + 1M out) |
|-------|-------|--------|------------------------|
| gpt-5 | $1.25 | $10.00 | $11.25 |
| gpt-5-mini | $0.30 | $1.20 | $1.50 |
| gpt-5-nano | $0.10 | $0.40 | $0.50 |
| gpt-4.1 | $2.50 | $10.00 | $12.50 |
| gpt-4.1-mini | $0.15 | $0.60 | $0.75 |
| gpt-4o | $2.50 | $10.00 | $12.50 |
| gpt-4o-mini | $0.15 | $0.60 | $0.75 |
| o3 | $10.00 | $40.00 | $50.00 |
| gpt-3.5-turbo | $0.50 | $1.50 | $2.00 |

---

## Free Tier

OpenAI no longer offers free credits for new accounts. You must purchase credits to use the API.

**Free features**:
- Moderation API (free)
- Playground (limited testing)

---

## Enterprise Pricing

For high-volume usage, contact sales for:
- Custom pricing
- Dedicated capacity
- SLA guarantees
- Priority support
- Flexible invoicing

Contact: https://openai.com/enterprise

---

## Additional Resources

- **Official Pricing**: https://openai.com/api/pricing
- **Usage Dashboard**: https://platform.openai.com/usage
- **Billing Settings**: https://platform.openai.com/account/billing
- **Token Counter**: https://platform.openai.com/tokenizer

---

**Next**: [Libraries →](./libraries.md)
