# OpenAI Platform - Predicted Outputs

**Source:** https://platform.openai.com/docs/guides/latency/predicted-outputs
**Fetched:** 2025-10-11

## Overview

Provide predicted output to reduce latency for edits and regenerations.

---

## Usage

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Fix typos: Hello wrold"}],
    prediction={
        "type": "content",
        "content": "Hello world"  # Predicted output
    }
)
```

---

## When to Use

- Text edits and corrections
- Format conversions
- Minor modifications
- Regenerations with small changes

---

**Source:** https://platform.openai.com/docs/guides/latency/predicted-outputs
