# OpenAI Platform - Embeddings API Reference

**Source:** https://platform.openai.com/docs/api-reference/embeddings
**Fetched:** 2025-10-11

## Create Embeddings

**POST** `/v1/embeddings`

```python
client.embeddings.create(
    model="text-embedding-3-large",
    input="Your text here"
)
```

## Parameters

- `model` (string, required): Embedding model ID
- `input` (string/array, required): Text to embed
- `encoding_format` (string, optional): "float" or "base64"
- `dimensions` (integer, optional): Output dimensions

## Response

```json
{
  "object": "list",
  "data": [{
    "object": "embedding",
    "embedding": [0.0023, -0.009, ...],
    "index": 0
  }],
  "model": "text-embedding-3-large",
  "usage": {
    "prompt_tokens": 8,
    "total_tokens": 8
  }
}
```

---

**Source:** https://platform.openai.com/docs/api-reference/embeddings
