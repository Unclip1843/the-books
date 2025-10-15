# OpenAI Platform - Images API Reference

**Source:** https://platform.openai.com/docs/api-reference/images
**Fetched:** 2025-10-11

## Create Image

**POST** `/v1/images/generations`

```python
client.images.generate(
    model="dall-e-3",
    prompt="A white cat",
    size="1024x1024",
    quality="standard",
    n=1
)
```

## Edit Image

**POST** `/v1/images/edits`

```python
client.images.edit(
    image=open("original.png", "rb"),
    mask=open("mask.png", "rb"),
    prompt="Add a hat",
    size="1024x1024"
)
```

## Create Variation

**POST** `/v1/images/variations`

```python
client.images.create_variation(
    image=open("image.png", "rb"),
    n=2,
    size="1024x1024"
)
```

---

**Source:** https://platform.openai.com/docs/api-reference/images
