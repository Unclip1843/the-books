# OpenAI Platform - Reasoning Models

**Source:** https://platform.openai.com/docs/guides/reasoning
**Fetched:** 2025-10-11

## Overview

Reasoning models like O1 are designed for complex problem-solving that requires extended thinking and multi-step analysis.

---

## O1 Model Family

### O1-preview
- Extended reasoning capabilities
- Best for complex problems
- Higher cost, longer response times

### O1-mini
- Faster reasoning
- More cost-effective
- Good for many reasoning tasks

---

## Usage

```python
from openai import OpenAI

client = OpenAI()

response = client.chat.completions.create(
    model="o1-preview",
    messages=[{
        "role": "user",
        "content": "Solve this complex problem with detailed reasoning..."
    }]
)
```

---

## Next Steps

- [Reasoning Best Practices](./reasoning-best-practices.md)
- [Run and Scale Overview](../overview.md)

---

**Source:** https://platform.openai.com/docs/guides/reasoning
