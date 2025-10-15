# OpenAI Platform - Priority Processing

**Source:** https://platform.openai.com/docs/guides/latency/priority
**Fetched:** 2025-10-11

## Overview

Get faster processing for priority requests.

---

## Usage

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Urgent query"}],
    priority="high"  # Priority level
)
```

---

## Priority Levels

- **high**: Fastest processing
- **normal**: Standard queue (default)
- **low**: Lower priority, reduced cost

---

## Pricing

Higher priority may incur additional costs. Check pricing page for details.

---

**Source:** https://platform.openai.com/docs/guides/latency/priority
