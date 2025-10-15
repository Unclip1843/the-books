# OpenAI Platform - Assistants API Tools

**Source:** https://platform.openai.com/docs/assistants/tools
**Fetched:** 2025-10-11

## Overview

Built-in tools available in Assistants API.

---

## Available Tools

### Code Interpreter

Execute Python code:

```python
assistant = client.beta.assistants.create(
    model="gpt-4o",
    tools=[{"type": "code_interpreter"}]
)
```

### File Search

Search uploaded files:

```python
assistant = client.beta.assistants.create(
    model="gpt-4o",
    tools=[{"type": "file_search"}]
)
```

### Function Calling

Call custom functions:

```python
assistant = client.beta.assistants.create(
    model="gpt-4o",
    tools=[{
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get weather",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {"type": "string"}
                }
            }
        }
    }]
)
```

---

**Source:** https://platform.openai.com/docs/assistants/tools
