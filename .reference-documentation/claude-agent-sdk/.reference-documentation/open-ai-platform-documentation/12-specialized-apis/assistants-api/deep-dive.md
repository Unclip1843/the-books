# OpenAI Platform - Assistants API Deep Dive

**Source:** https://platform.openai.com/docs/assistants/deep-dive
**Fetched:** 2025-10-11

## Overview

Advanced concepts and patterns for Assistants API.

---

## Advanced Features

### Run Steps

Track individual steps in a run:

```python
run_steps = client.beta.threads.runs.steps.list(
    thread_id=thread.id,
    run_id=run.id
)

for step in run_steps.data:
    print(f"Step: {step.type}")
    print(f"Status: {step.status}")
```

### Streaming

Stream assistant responses:

```python
with client.beta.threads.runs.stream(
    thread_id=thread.id,
    assistant_id=assistant.id
) as stream:
    for event in stream:
        if event.event == "thread.message.delta":
            print(event.data.delta.content, end="")
```

### Function Calling

```python
assistant = client.beta.assistants.create(
    model="gpt-4o",
    tools=[{
        "type": "function",
        "function": {
            "name": "get_weather",
            "parameters": {...}
        }
    }]
)
```

---

**Source:** https://platform.openai.com/docs/assistants/deep-dive
