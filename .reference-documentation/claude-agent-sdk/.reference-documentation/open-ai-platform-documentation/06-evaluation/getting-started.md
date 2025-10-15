# OpenAI Platform - Evaluation Getting Started

**Source:** https://platform.openai.com/docs/guides/evals
**Fetched:** 2025-10-11

## Overview

Evaluations (evals) help you systematically test and improve your AI applications.

---

## Quick Start

```python
from openai import OpenAI

client = OpenAI()

# Create eval dataset
eval_data = [
    {"input": "Question 1", "expected": "Answer 1"},
    {"input": "Question 2", "expected": "Answer 2"},
]

# Run eval
for item in eval_data:
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": item["input"]}]
    )
    # Compare response to expected
```

---

## Next Steps

- [Working with Evals](./working-with-evals.md)
- [Best Practices](./best-practices.md)

---

**Source:** https://platform.openai.com/docs/guides/evals
