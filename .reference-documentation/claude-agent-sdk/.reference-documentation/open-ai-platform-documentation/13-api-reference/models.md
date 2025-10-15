# OpenAI Platform - Models API Reference

**Source:** https://platform.openai.com/docs/api-reference/models
**Fetched:** 2025-10-11

## List Models

**GET** `/v1/models`

```python
client.models.list()
```

## Retrieve Model

**GET** `/v1/models/{model}`

```python
client.models.retrieve("gpt-4o")
```

## Delete Fine-tuned Model

**DELETE** `/v1/models/{model}`

```python
client.models.delete("ft:gpt-4o:org:suffix")
```

## Response Example

```json
{
  "id": "gpt-4o",
  "object": "model",
  "created": 1686935002,
  "owned_by": "openai"
}
```

---

**Source:** https://platform.openai.com/docs/api-reference/models
