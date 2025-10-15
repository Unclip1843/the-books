# OpenAI Platform - Assistants API Migration Guide

**Source:** https://platform.openai.com/docs/assistants/migration
**Fetched:** 2025-10-11

## Overview

Migrate from Assistants API to Responses API or Agents SDK.

---

## Migration Paths

### To Responses API

For simpler use cases:

```python
# Old: Assistants API
assistant = client.beta.assistants.create(...)
thread = client.beta.threads.create()

# New: Responses API
response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages
)
```

### To Agents SDK

For complex agent workflows:

```python
# New: Agents SDK
from openai_agents import Agent

agent = Agent(
    name="Assistant",
    instructions="...",
    model="gpt-4o",
    tools=[...]
)
```

---

## Key Differences

- **Threads**: Manage conversation state yourself with Responses API
- **Tools**: Use function calling instead of built-in tools
- **Files**: Upload via Files API separately

---

**Source:** https://platform.openai.com/docs/assistants/migration
