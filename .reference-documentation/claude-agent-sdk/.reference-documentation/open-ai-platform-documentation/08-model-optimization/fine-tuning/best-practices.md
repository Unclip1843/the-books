# OpenAI Platform - Fine-Tuning Best Practices

**Source:** https://platform.openai.com/docs/guides/fine-tuning/best-practices
**Fetched:** 2025-10-11

## Overview

Best practices for successful fine-tuning.

---

## Key Practices

### 1. Data Quality

- **Quantity**: Minimum 50-100 examples, ideally 500+
- **Quality**: Clean, consistent, representative
- **Diversity**: Cover edge cases and variations

### 2. Data Format

```python
# Correct format
{
    "messages": [
        {"role": "system", "content": "..."},
        {"role": "user", "content": "..."},
        {"role": "assistant", "content": "..."}
    ]
}
```

### 3. Validation

- Split data into train/validation sets
- Monitor validation loss
- Avoid overfitting

### 4. Iteration

- Start with base model eval
- Fine-tune incrementally
- Compare results systematically

---

**Source:** https://platform.openai.com/docs/guides/fine-tuning/best-practices
