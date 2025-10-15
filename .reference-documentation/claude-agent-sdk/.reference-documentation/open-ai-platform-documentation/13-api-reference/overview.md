# OpenAI Platform - API Reference Overview

**Source:** https://platform.openai.com/docs/api-reference
**Fetched:** 2025-10-11

## Overview

Complete API reference for all OpenAI endpoints.

---

## Endpoints

- [Chat](./chat.md) - Chat Completions API
- [Completions](./completions.md) - Legacy Completions API
- [Embeddings](./embeddings.md) - Text embeddings
- [Fine-tuning](./fine-tuning.md) - Model fine-tuning
- [Images](./images.md) - Image generation
- [Audio](./audio.md) - Speech and transcription
- [Moderation](./moderation.md) - Content moderation
- [Models](./models.md) - Model management

---

## Authentication

```bash
curl https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{...}'
```

---

**Source:** https://platform.openai.com/docs/api-reference
