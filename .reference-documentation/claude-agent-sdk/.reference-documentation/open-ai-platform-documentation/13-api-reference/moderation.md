# OpenAI Platform - Moderation API Reference

**Source:** https://platform.openai.com/docs/api-reference/moderations
**Fetched:** 2025-10-11

## Create Moderation

**POST** `/v1/moderations`

```python
client.moderations.create(
    model="omni-moderation-latest",
    input="Text to moderate"
)
```

## Response

```json
{
  "id": "modr-abc123",
  "model": "omni-moderation-latest",
  "results": [{
    "flagged": false,
    "categories": {
      "hate": false,
      "sexual": false,
      "violence": false
    },
    "category_scores": {
      "hate": 0.001,
      "sexual": 0.002,
      "violence": 0.0003
    }
  }]
}
```

---

**Source:** https://platform.openai.com/docs/api-reference/moderations
