# OpenAI Platform - Migrate to Responses API

**Source:** https://platform.openai.com/docs/guides/migrate-to-responses
**Fetched:** 2025-10-11

## Overview

The Responses API is OpenAI's next-generation conversational AI infrastructure, designed for GPT-5 and future models. It combines the best of Chat Completions and Assistants APIs into a unified, stateful experience.

**Migration Timeline**: Assistants API will be sunset in 2026. Migrate to Responses API to ensure uninterrupted service.

---

## Why Migrate?

### Benefits of Responses API

✅ **Unified Experience**: Combines Chat Completions + Assistants capabilities
✅ **Built for GPT-5**: Optimized for latest models
✅ **Stateful by Default**: Automatic conversation management
✅ **All Tools Supported**: Web search, file search, code execution
✅ **Better Performance**: Faster, more reliable
✅ **Future-Proof**: Foundation for upcoming features

---

## Key Differences

| Feature | Assistants API | Responses API |
|---------|---------------|---------------|
| State Management | Manual threads | Automatic |
| Conversation Context | Explicit thread_id | Built-in |
| Tools | Separate endpoints | Unified |
| Model Support | GPT-4 family | GPT-5 optimized |
| Pricing | Higher | More efficient |
| Complexity | More verbose | Simplified |

---

## Migration Overview

### Before (Assistants API)

```python
# 1. Create assistant
assistant = client.beta.assistants.create(
    name="My Assistant",
    instructions="You are a helpful assistant",
    model="gpt-4-turbo",
    tools=[{"type": "code_interpreter"}]
)

# 2. Create thread
thread = client.beta.threads.create()

# 3. Add message
message = client.beta.threads.messages.create(
    thread_id=thread.id,
    role="user",
    content="Hello!"
)

# 4. Run assistant
run = client.beta.threads.runs.create(
    thread_id=thread.id,
    assistant_id=assistant.id
)

# 5. Wait for completion
while run.status != "completed":
    run = client.beta.threads.runs.retrieve(
        thread_id=thread.id,
        run_id=run.id
    )
    time.sleep(1)

# 6. Get messages
messages = client.beta.threads.messages.list(thread_id=thread.id)
```

### After (Responses API)

```python
# Much simpler!
response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {
            "role": "system",
            "content": "You are a helpful assistant"
        },
        {"role": "user", "content": "Hello!"}
    ],
    tools=[{"type": "code_interpreter"}]
)

print(response.choices[0].message.content)
```

---

## Migration Patterns

### 1. Simple Assistant

**Before**:
```python
assistant = client.beta.assistants.create(
    name="Helper",
    instructions="You are helpful",
    model="gpt-4-turbo"
)

thread = client.beta.threads.create()

client.beta.threads.messages.create(
    thread_id=thread.id,
    role="user",
    content="What's 2+2?"
)

run = client.beta.threads.runs.create_and_poll(
    thread_id=thread.id,
    assistant_id=assistant.id
)

messages = client.beta.threads.messages.list(thread_id=thread.id)
```

**After**:
```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "system", "content": "You are helpful"},
        {"role": "user", "content": "What's 2+2?"}
    ]
)

print(response.choices[0].message.content)
```

---

### 2. Assistant with Tools

**Before**:
```python
assistant = client.beta.assistants.create(
    name="Code Helper",
    instructions="Help with code",
    model="gpt-4-turbo",
    tools=[
        {"type": "code_interpreter"},
        {"type": "file_search"}
    ]
)

thread = client.beta.threads.create()

client.beta.threads.messages.create(
    thread_id=thread.id,
    role="user",
    content="Analyze this data"
)

run = client.beta.threads.runs.create_and_poll(
    thread_id=thread.id,
    assistant_id=assistant.id
)
```

**After**:
```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "system", "content": "Help with code"},
        {"role": "user", "content": "Analyze this data"}
    ],
    tools=[
        {"type": "code_interpreter"},
        {"type": "file_search"}
    ]
)
```

---

### 3. Multi-Turn Conversations

**Before**:
```python
# Create and maintain thread
thread = client.beta.threads.create()

# Message 1
client.beta.threads.messages.create(
    thread_id=thread.id,
    role="user",
    content="What's Python?"
)
run1 = client.beta.threads.runs.create_and_poll(
    thread_id=thread.id,
    assistant_id=assistant.id
)

# Message 2 (context maintained via thread)
client.beta.threads.messages.create(
    thread_id=thread.id,
    role="user",
    content="Give me an example"
)
run2 = client.beta.threads.runs.create_and_poll(
    thread_id=thread.id,
    assistant_id=assistant.id
)
```

**After**:
```python
# Build conversation with messages array
messages = [
    {"role": "system", "content": "You are a Python expert"}
]

# Message 1
messages.append({"role": "user", "content": "What's Python?"})
response1 = client.chat.completions.create(
    model="gpt-5",
    messages=messages
)
messages.append({
    "role": "assistant",
    "content": response1.choices[0].message.content
})

# Message 2 (context maintained in messages array)
messages.append({"role": "user", "content": "Give me an example"})
response2 = client.chat.completions.create(
    model="gpt-5",
    messages=messages
)
```

---

### 4. Function Calling

**Before**:
```python
assistant = client.beta.assistants.create(
    name="API Helper",
    instructions="Call functions as needed",
    model="gpt-4-turbo",
    tools=[{
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get weather",
            "parameters": {...}
        }
    }]
)

run = client.beta.threads.runs.create_and_poll(
    thread_id=thread.id,
    assistant_id=assistant.id
)

# Handle tool calls
if run.status == "requires_action":
    tool_outputs = []
    for tool_call in run.required_action.submit_tool_outputs.tool_calls:
        output = execute_function(tool_call)
        tool_outputs.append({
            "tool_call_id": tool_call.id,
            "output": output
        })

    run = client.beta.threads.runs.submit_tool_outputs_and_poll(
        thread_id=thread.id,
        run_id=run.id,
        tool_outputs=tool_outputs
    )
```

**After**:
```python
tools = [{
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": "Get weather",
        "parameters": {...}
    }
}]

response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "What's the weather?"}],
    tools=tools
)

# Handle tool calls (same pattern as before)
if response.choices[0].message.tool_calls:
    for tool_call in response.choices[0].message.tool_calls:
        result = execute_function(tool_call)
        messages.append({
            "role": "tool",
            "tool_call_id": tool_call.id,
            "content": json.dumps(result)
        })

    # Get final response
    final_response = client.chat.completions.create(
        model="gpt-5",
        messages=messages
    )
```

---

### 5. File Handling

**Before**:
```python
# Upload file
file = client.files.create(
    file=open("data.csv", "rb"),
    purpose="assistants"
)

# Create assistant with file
assistant = client.beta.assistants.create(
    name="Data Analyst",
    model="gpt-4-turbo",
    tools=[{"type": "code_interpreter"}],
    file_ids=[file.id]
)

# Use in thread
thread = client.beta.threads.create()
client.beta.threads.messages.create(
    thread_id=thread.id,
    role="user",
    content="Analyze the data"
)
```

**After**:
```python
# Upload file (same)
file = client.files.create(
    file=open("data.csv", "rb"),
    purpose="assistants"
)

# Use directly in chat
response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Analyze the data",
            "attachments": [{
                "file_id": file.id,
                "tools": [{"type": "code_interpreter"}]
            }]
        }
    ],
    tools=[{"type": "code_interpreter"}]
)
```

---

## Mapping Guide

### API Endpoints

| Assistants API | Responses API |
|---------------|---------------|
| `/v1/assistants` | Use chat.completions with system message |
| `/v1/threads` | Manage messages array in your code |
| `/v1/threads/messages` | messages parameter |
| `/v1/threads/runs` | Single chat.completions call |

### Concepts

| Assistants Concept | Responses Equivalent |
|-------------------|---------------------|
| Assistant | System message + tools |
| Thread | Messages array |
| Message | Message object |
| Run | Single API call |
| Tool Outputs | Tool role messages |

---

## State Management

### Assistants API (Server-Side State)

```python
# State managed by OpenAI
thread_id = "thread_abc123"  # Store this

# Always use same thread_id
client.beta.threads.messages.create(
    thread_id=thread_id,
    role="user",
    content="..."
)
```

### Responses API (Client-Side State)

```python
# State managed by you
conversation = [
    {"role": "system", "content": "..."}
]

# Build conversation
conversation.append({"role": "user", "content": "..."})
response = client.chat.completions.create(
    model="gpt-5",
    messages=conversation
)
conversation.append({
    "role": "assistant",
    "content": response.choices[0].message.content
})

# Store conversation array (in DB, session, etc.)
save_conversation(user_id, conversation)
```

---

## Migration Checklist

### Step 1: Audit Current Usage

- [ ] List all assistants
- [ ] Document assistant instructions
- [ ] Identify tools used
- [ ] Map conversation flows
- [ ] Note file attachments

### Step 2: Update Code

- [ ] Replace assistant creation with system messages
- [ ] Remove thread management
- [ ] Implement client-side conversation storage
- [ ] Update tool calling patterns
- [ ] Test file handling

### Step 3: Test

- [ ] Test simple conversations
- [ ] Test multi-turn dialogues
- [ ] Test tool/function calling
- [ ] Test file uploads
- [ ] Load test

### Step 4: Deploy

- [ ] Gradual rollout
- [ ] Monitor error rates
- [ ] Compare performance
- [ ] Update documentation

### Step 5: Cleanup

- [ ] Delete old assistants
- [ ] Archive threads
- [ ] Update billing

---

## Common Pitfalls

### 1. Forgetting Context Management

**Problem**: Each call starts fresh without conversation history

**Solution**: Maintain messages array
```python
# Store messages between requests
conversation = load_conversation(user_id)
conversation.append({"role": "user", "content": new_message})

response = client.chat.completions.create(
    model="gpt-5",
    messages=conversation
)

conversation.append({
    "role": "assistant",
    "content": response.choices[0].message.content
})
save_conversation(user_id, conversation)
```

### 2. Not Handling Token Limits

**Problem**: Conversation grows too large

**Solution**: Truncate old messages
```python
def truncate_conversation(messages, max_tokens=100000):
    # Keep system message + recent messages
    system = [m for m in messages if m["role"] == "system"]
    others = [m for m in messages if m["role"] != "system"]

    # Keep most recent that fit in limit
    truncated = system + others[-20:]  # Keep last 20 messages
    return truncated
```

### 3. Missing Tool State

**Problem**: Tool results not properly appended

**Solution**: Always append tool results
```python
# After tool execution
messages.append({
    "role": "tool",
    "tool_call_id": tool_call.id,
    "content": json.dumps(result)
})

# Then get final response
response = client.chat.completions.create(
    model="gpt-5",
    messages=messages
)
```

---

## Performance Improvements

### Before (Assistants API)

- Multiple API calls per response
- Polling overhead
- Server-side state management

### After (Responses API)

✅ **Single API call** for most responses
✅ **No polling** required
✅ **Lower latency** overall
✅ **More control** over state
✅ **Better cost efficiency**

---

## Example: Complete Migration

**Before (Assistants API)**:
```python
class AssistantBot:
    def __init__(self):
        self.assistant = client.beta.assistants.create(
            name="Helper",
            instructions="You are helpful",
            model="gpt-4-turbo"
        )

    def chat(self, user_id, message):
        # Get or create thread
        thread_id = get_thread_id(user_id)
        if not thread_id:
            thread = client.beta.threads.create()
            thread_id = thread.id
            save_thread_id(user_id, thread_id)

        # Add message
        client.beta.threads.messages.create(
            thread_id=thread_id,
            role="user",
            content=message
        )

        # Run
        run = client.beta.threads.runs.create_and_poll(
            thread_id=thread_id,
            assistant_id=self.assistant.id
        )

        # Get response
        messages = client.beta.threads.messages.list(thread_id=thread_id)
        return messages.data[0].content[0].text.value
```

**After (Responses API)**:
```python
class ResponsesBot:
    def __init__(self):
        self.system_message = {
            "role": "system",
            "content": "You are helpful"
        }

    def chat(self, user_id, message):
        # Load conversation
        conversation = get_conversation(user_id) or [self.system_message]

        # Add user message
        conversation.append({"role": "user", "content": message})

        # Get response
        response = client.chat.completions.create(
            model="gpt-5",
            messages=conversation
        )

        # Add assistant response
        assistant_message = response.choices[0].message.content
        conversation.append({
            "role": "assistant",
            "content": assistant_message
        })

        # Save conversation
        save_conversation(user_id, conversation)

        return assistant_message
```

---

## Additional Resources

- **Migration Guide**: https://platform.openai.com/docs/guides/migrate-to-responses
- **Responses API Docs**: https://platform.openai.com/docs/guides/responses
- **Chat Completions**: https://platform.openai.com/docs/guides/text-generation
- **Community Forum**: https://community.openai.com/t/migration-from-assistants-to-responses

---

**Next Section**: [Agents →](../03-agents/overview.md)
