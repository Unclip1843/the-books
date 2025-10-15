# OpenAI Platform - Safety Checks

**Source:** https://platform.openai.com/docs/guides/safety-checks
**Fetched:** 2025-10-11

## Overview

Implement automated safety checks in your application.

---

## Pre-Request Checks

```python
# Check input before sending to API
moderation = client.moderations.create(input=user_input)

if moderation.results[0].flagged:
    return "Content violates policy"
```

---

## Post-Response Checks

```python
# Check output before showing to user
response = client.chat.completions.create(...)
output = response.choices[0].message.content

moderation = client.moderations.create(input=output)

if moderation.results[0].flagged:
    return "Response filtered for safety"
```

---

## Content Policies

Follow OpenAI usage policies:
- No illegal content
- No harmful content
- Respect privacy
- No misleading information

---

**Source:** https://platform.openai.com/docs/guides/safety-checks
