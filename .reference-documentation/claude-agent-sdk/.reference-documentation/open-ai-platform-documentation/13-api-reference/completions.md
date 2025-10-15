# OpenAI Platform - Completions API Reference

**Source:** https://platform.openai.com/docs/api-reference/completions
**Fetched:** 2025-10-11

## Create Completion (Legacy)

**POST** `/v1/completions`

**Note:** This is the legacy completion endpoint. Use Chat Completions for new applications.

```python
client.completions.create(
    model="gpt-3.5-turbo-instruct",
    prompt="Say hello",
    max_tokens=10
)
```

## Parameters

- `model` (string, required): Model ID
- `prompt` (string/array, required): Input text
- `max_tokens` (integer, optional): Max tokens
- `temperature` (number, optional): 0-2
- `stream` (boolean, optional): Stream response

---

**Source:** https://platform.openai.com/docs/api-reference/completions
