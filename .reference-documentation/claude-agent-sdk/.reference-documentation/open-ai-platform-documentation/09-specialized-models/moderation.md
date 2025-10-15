# OpenAI Platform - Moderation

**Source:** https://platform.openai.com/docs/guides/moderation
**Fetched:** 2025-10-11

## Overview

Screen content for harmful or inappropriate material.

---

## Moderate Content

```python
response = client.moderations.create(
    model="omni-moderation-latest",
    input="Text to moderate..."
)

results = response.results[0]
```

---

## Check Results

```python
if results.flagged:
    print("Content flagged")
    print(f"Categories: {results.categories}")
    print(f"Scores: {results.category_scores}")
```

---

## Categories

- hate
- hate/threatening
- harassment
- harassment/threatening
- self-harm
- self-harm/intent
- self-harm/instructions
- sexual
- sexual/minors
- violence
- violence/graphic

---

**Source:** https://platform.openai.com/docs/guides/moderation
