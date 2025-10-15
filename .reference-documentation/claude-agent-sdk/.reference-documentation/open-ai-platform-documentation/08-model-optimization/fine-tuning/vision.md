# OpenAI Platform - Vision Fine-Tuning

**Source:** https://platform.openai.com/docs/guides/fine-tuning/vision
**Fetched:** 2025-10-11

## Overview

Fine-tune vision models for custom image understanding tasks.

---

## Training Data Format

```python
training_example = {
    "messages": [
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "What's in this image?"},
                {"type": "image_url", "image_url": {"url": "https://..."}}
            ]
        },
        {
            "role": "assistant",
            "content": "This is a photo of..."
        }
    ]
}
```

---

## Create Fine-Tuning Job

```python
job = client.fine_tuning.jobs.create(
    training_file=training_file.id,
    model="gpt-4o-2024-08-06"  # Vision-capable model
)
```

---

**Source:** https://platform.openai.com/docs/guides/fine-tuning/vision
