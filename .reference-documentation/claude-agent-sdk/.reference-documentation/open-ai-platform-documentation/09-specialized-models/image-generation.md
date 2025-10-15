# OpenAI Platform - Image Generation

**Source:** https://platform.openai.com/docs/guides/images
**Fetched:** 2025-10-11

## Overview

Generate images using DALL-E models.

---

## Generate Images

```python
response = client.images.generate(
    model="dall-e-3",
    prompt="A serene mountain landscape at sunset",
    size="1024x1024",
    quality="standard",  # or "hd"
    n=1
)

image_url = response.data[0].url
```

---

## Models

- **DALL-E 3**: Latest, highest quality
- **DALL-E 2**: Faster, more affordable

---

## Sizes

- 1024x1024 (square)
- 1792x1024 (landscape)
- 1024x1792 (portrait)

---

**Source:** https://platform.openai.com/docs/guides/images
