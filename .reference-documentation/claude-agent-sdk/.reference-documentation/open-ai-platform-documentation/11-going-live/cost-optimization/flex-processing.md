# OpenAI Platform - Flex Processing

**Source:** https://platform.openai.com/docs/guides/flex-processing
**Fetched:** 2025-10-11

## Overview

Lower-priority processing at reduced cost.

---

## Usage

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Query"}],
    priority="flex"  # Flex processing
)
```

---

## Benefits

- Reduced cost (similar to batch)
- Still synchronous (unlike batch)
- Good for non-urgent real-time requests

---

## Trade-offs

- Longer wait times during high demand
- May be queued behind priority requests

---

**Source:** https://platform.openai.com/docs/guides/flex-processing
