# OpenAI Platform - Direct Preference Optimization (DPO)

**Source:** https://platform.openai.com/docs/guides/fine-tuning/dpo
**Fetched:** 2025-10-11

## Overview

Fine-tune models based on preference comparisons.

---

## Training Data Format

```python
dpo_example = {
    "prompt": "Explain quantum computing",
    "chosen": "Quantum computing uses quantum bits...",  # Preferred response
    "rejected": "It's just computers..."  # Less preferred response
}
```

---

## When to Use DPO

- Improving response quality
- Aligning with specific preferences
- Style and tone adjustments

---

**Source:** https://platform.openai.com/docs/guides/fine-tuning/dpo
