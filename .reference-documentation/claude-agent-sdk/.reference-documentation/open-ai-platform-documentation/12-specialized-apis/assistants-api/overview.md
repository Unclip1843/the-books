# OpenAI Platform - Assistants API Overview

**Source:** https://platform.openai.com/docs/assistants
**Fetched:** 2025-10-11

## Overview

Build AI assistants with persistent threads and built-in tools.

---

## Key Features

- **Persistent Threads**: Conversation history management
- **Built-in Tools**: Code Interpreter, File Search, Function Calling
- **File Handling**: Upload and process files
- **Runs**: Asynchronous execution

---

## Basic Usage

```python
# Create assistant
assistant = client.beta.assistants.create(
    name="Math Tutor",
    instructions="You help with math problems",
    model="gpt-4o",
    tools=[{"type": "code_interpreter"}]
)

# Create thread
thread = client.beta.threads.create()

# Add message
message = client.beta.threads.messages.create(
    thread_id=thread.id,
    role="user",
    content="Solve: 3x + 11 = 14"
)

# Run assistant
run = client.beta.threads.runs.create(
    thread_id=thread.id,
    assistant_id=assistant.id
)

# Wait for completion
while run.status != "completed":
    run = client.beta.threads.runs.retrieve(
        thread_id=thread.id,
        run_id=run.id
    )

# Get response
messages = client.beta.threads.messages.list(thread_id=thread.id)
```

---

## Next Steps

- [Migration Guide](./migration-guide.md)
- [Deep Dive](./deep-dive.md)
- [Tools](./tools.md)

---

**Source:** https://platform.openai.com/docs/assistants
