# OpenAI Platform - Text Generation

**Source:** https://platform.openai.com/docs/guides/text-generation
**Fetched:** 2025-10-11

## Overview

Text generation is the core capability of OpenAI's language models. The Chat Completions API is the primary interface for generating text with models like GPT-5, GPT-4.1, and GPT-4o.

---

## Chat Completions API

The Chat Completions API takes a list of messages as input and returns a model-generated message as output.

### Basic Request

```python
from openai import OpenAI

client = OpenAI()

response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "What is the capital of France?"}
    ]
)

print(response.choices[0].message.content)
# Output: "The capital of France is Paris."
```

### Request Structure

```typescript
{
  "model": "gpt-5",
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant."
    },
    {
      "role": "user",
      "content": "What is the capital of France?"
    }
  ],
  "temperature": 0.7,
  "max_tokens": 150
}
```

---

## Message Roles

### system

Sets the behavior and personality of the assistant.

```python
{"role": "system", "content": "You are a expert Python programmer. Provide concise, working code examples."}
```

**Best practices**:
- Keep system messages clear and specific
- Include constraints and formatting requirements
- Define the tone and expertise level

### user

The input from the end user.

```python
{"role": "user", "content": "Write a function to reverse a string"}
```

### assistant

Previous responses from the model, used for multi-turn conversations.

```python
{"role": "assistant", "content": "Here's a function to reverse a string:\n\n```python\ndef reverse_string(s):\n    return s[::-1]\n```"}
```

### tool (for function calling)

Results from function/tool executions.

```python
{"role": "tool", "tool_call_id": "call_abc123", "content": "{\"temperature\": 72}"}
```

---

## Multi-Turn Conversations

Build conversations by appending messages:

```python
messages = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "What's the weather like?"},
]

response = client.chat.completions.create(
    model="gpt-5",
    messages=messages
)

# Add assistant's response to conversation
messages.append({
    "role": "assistant",
    "content": response.choices[0].message.content
})

# Continue conversation
messages.append({
    "role": "user",
    "content": "Should I bring an umbrella?"
})

response = client.chat.completions.create(
    model="gpt-5",
    messages=messages
)
```

---

## Key Parameters

### model (required)

The model to use for generation:
- `gpt-5` - Most capable
- `gpt-5-mini` - Fast and efficient
- `gpt-4.1` - Extended context
- `gpt-4o` - Multimodal

### messages (required)

Array of message objects with `role` and `content`.

### temperature

Controls randomness (0.0 - 2.0):
- **0.0**: Deterministic, focused
- **0.7**: Balanced (default)
- **1.5**: Creative, varied

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[...],
    temperature=0.2  # More focused
)
```

### max_tokens

Maximum tokens in the response:

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[...],
    max_tokens=100  # Limit response length
)
```

### top_p

Alternative to temperature. Nucleus sampling (0.0 - 1.0):
- **0.1**: Only top 10% probable tokens
- **1.0**: All tokens considered

**Note**: Use temperature OR top_p, not both.

### n

Number of completions to generate:

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[...],
    n=3  # Generate 3 different responses
)

for choice in response.choices:
    print(choice.message.content)
```

### stop

Sequences where generation should stop:

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[...],
    stop=["END", "\n\n"]  # Stop at these sequences
)
```

### presence_penalty

Penalize tokens based on presence (-2.0 to 2.0):
- **Positive**: Encourage new topics
- **Negative**: Stay on topic

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[...],
    presence_penalty=0.6  # Encourage diversity
)
```

### frequency_penalty

Penalize tokens based on frequency (-2.0 to 2.0):
- **Positive**: Reduce repetition
- **Negative**: Allow repetition

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[...],
    frequency_penalty=0.5  # Reduce repetition
)
```

### user

Unique identifier for end-user (for abuse monitoring):

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[...],
    user="user-123456"
)
```

---

## Response Structure

```json
{
  "id": "chatcmpl-abc123",
  "object": "chat.completion",
  "created": 1677858242,
  "model": "gpt-5",
  "usage": {
    "prompt_tokens": 13,
    "completion_tokens": 7,
    "total_tokens": 20
  },
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "The capital of France is Paris."
      },
      "finish_reason": "stop",
      "index": 0
    }
  ]
}
```

### Key Fields

**id**: Unique identifier for the completion

**usage**: Token consumption
- `prompt_tokens`: Input tokens
- `completion_tokens`: Output tokens
- `total_tokens`: Sum

**choices**: Array of generated responses
- `message.content`: The generated text
- `finish_reason`: Why generation stopped
  - `stop`: Natural completion
  - `length`: Hit max_tokens
  - `content_filter`: Filtered by moderation
  - `tool_calls`: Function was called

---

## Streaming Responses

Get tokens as they're generated for real-time output:

### Python

```python
stream = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Write a story"}],
    stream=True
)

for chunk in stream:
    if chunk.choices[0].delta.content is not None:
        print(chunk.choices[0].delta.content, end="")
```

### TypeScript

```typescript
const stream = await client.chat.completions.create({
  model: 'gpt-5',
  messages: [{ role: 'user', content: 'Write a story' }],
  stream: true,
});

for await (const chunk of stream) {
  process.stdout.write(chunk.choices[0]?.delta?.content || '');
}
```

### Streaming Response Structure

```json
{
  "id": "chatcmpl-abc123",
  "object": "chat.completion.chunk",
  "created": 1677858242,
  "model": "gpt-5",
  "choices": [
    {
      "index": 0,
      "delta": {
        "content": "The"
      },
      "finish_reason": null
    }
  ]
}
```

---

## Token Management

### Counting Tokens

```python
import tiktoken

def count_tokens(text, model="gpt-5"):
    encoding = tiktoken.encoding_for_model(model)
    return len(encoding.encode(text))

text = "Hello, world!"
tokens = count_tokens(text)
print(f"{tokens} tokens")  # 3 tokens
```

### Managing Context Length

```python
def truncate_to_token_limit(messages, max_tokens=100000):
    """Keep messages within token limit."""
    encoding = tiktoken.encoding_for_model("gpt-5")

    total_tokens = 0
    truncated = []

    # Keep system message
    if messages[0]["role"] == "system":
        truncated.append(messages[0])
        total_tokens += len(encoding.encode(messages[0]["content"]))
        messages = messages[1:]

    # Add messages from most recent
    for msg in reversed(messages):
        msg_tokens = len(encoding.encode(msg["content"]))
        if total_tokens + msg_tokens > max_tokens:
            break
        truncated.insert(0, msg)
        total_tokens += msg_tokens

    return truncated
```

---

## Best Practices

### 1. Clear Instructions

**Bad**:
```python
{"role": "user", "content": "Translate this"}
```

**Good**:
```python
{"role": "user", "content": "Translate the following English text to French: 'Hello, how are you?'"}
```

### 2. Use System Messages Effectively

```python
messages = [
    {
        "role": "system",
        "content": """You are a customer support agent. Follow these rules:
        1. Be polite and professional
        2. Provide concise answers
        3. If unsure, offer to escalate to a human
        4. Never make up information"""
    },
    {"role": "user", "content": "How do I reset my password?"}
]
```

### 3. Few-Shot Examples

Provide examples in the prompt:

```python
messages = [
    {"role": "system", "content": "Extract the name and email from text."},
    {"role": "user", "content": "John Doe (john@example.com) signed up"},
    {"role": "assistant", "content": '{"name": "John Doe", "email": "john@example.com"}'},
    {"role": "user", "content": "Jane Smith <jane@test.com> registered"}
]
```

### 4. Temperature Selection

**Deterministic tasks** (code, math, extraction):
```python
temperature=0.0
```

**Creative tasks** (stories, brainstorming):
```python
temperature=0.8
```

**Balanced** (general chat):
```python
temperature=0.7
```

### 5. Handle Errors Gracefully

```python
from openai import OpenAI, APIError, RateLimitError

client = OpenAI()

try:
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[...]
    )
except RateLimitError:
    print("Rate limit hit, waiting...")
    time.sleep(60)
except APIError as e:
    print(f"API error: {e}")
```

---

## Advanced Techniques

### Chain of Thought

Encourage step-by-step reasoning:

```python
messages = [
    {
        "role": "system",
        "content": "Think step-by-step before answering. Show your reasoning."
    },
    {
        "role": "user",
        "content": "If a store has 15 apples and sells 7, then receives 12 more, how many does it have?"
    }
]
```

### Self-Consistency

Generate multiple responses and pick the most common:

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[...],
    n=5,  # Generate 5 responses
    temperature=0.7
)

# Analyze and pick most consistent answer
answers = [choice.message.content for choice in response.choices]
```

### Prompt Chaining

Break complex tasks into steps:

```python
# Step 1: Extract key points
response1 = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": f"Extract key points from: {article}"}
    ]
)

# Step 2: Summarize key points
response2 = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": f"Summarize these points: {response1.choices[0].message.content}"}
    ]
)
```

---

## Common Use Cases

### Chatbot

```python
conversation = [
    {"role": "system", "content": "You are a helpful assistant."}
]

while True:
    user_input = input("You: ")
    if user_input.lower() == "quit":
        break

    conversation.append({"role": "user", "content": user_input})

    response = client.chat.completions.create(
        model="gpt-5-mini",
        messages=conversation
    )

    assistant_message = response.choices[0].message.content
    conversation.append({"role": "assistant", "content": assistant_message})

    print(f"Assistant: {assistant_message}")
```

### Content Summarization

```python
def summarize(text, max_words=100):
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": f"Summarize the following text in {max_words} words or less."
            },
            {"role": "user", "content": text}
        ],
        temperature=0.3
    )
    return response.choices[0].message.content
```

### Code Generation

```python
def generate_code(description):
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": "You are an expert programmer. Generate clean, working code with comments."
            },
            {"role": "user", "content": description}
        ],
        temperature=0.2
    )
    return response.choices[0].message.content
```

### Data Extraction

```python
def extract_structured_data(text):
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": "Extract structured data as JSON from the text."
            },
            {"role": "user", "content": text}
        ],
        temperature=0.0
    )
    return response.choices[0].message.content
```

---

## Additional Resources

- **API Reference**: https://platform.openai.com/docs/api-reference/chat
- **Streaming Guide**: https://platform.openai.com/docs/guides/streaming
- **Best Practices**: https://platform.openai.com/docs/guides/prompt-engineering
- **Cookbook**: https://cookbook.openai.com

---

**Next**: [Images and Vision →](./images-and-vision.md)
