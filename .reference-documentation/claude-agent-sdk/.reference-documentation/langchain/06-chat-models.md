# LangChain - Chat Models

**Sources:**
- https://python.langchain.com/docs/concepts/chat_models/
- https://python.langchain.com/docs/integrations/chat/
- https://js.langchain.com/docs/integrations/chat/

**Fetched:** 2025-10-11

## What are Chat Models?

Chat models are LLMs optimized for conversational interfaces. They:
- Accept messages as input (not just strings)
- Return structured message responses
- Support system messages, chat history, and roles
- Enable function/tool calling
- Provide better conversation context handling

**Chat Model vs LLM:**
- **Chat Model:** Message-based interface (preferred)
- **LLM:** String-based interface (legacy)

## Basic Usage

### Python - OpenAI

```python
from langchain_openai import ChatOpenAI

# Initialize
llm = ChatOpenAI(model="gpt-4")

# String input (auto-converted to message)
response = llm.invoke("What is LangChain?")
print(response.content)

# Message input
from langchain_core.messages import HumanMessage, SystemMessage

messages = [
    SystemMessage(content="You are a helpful assistant"),
    HumanMessage(content="What is LangChain?")
]

response = llm.invoke(messages)
print(response.content)
```

### TypeScript - OpenAI

```typescript
import { ChatOpenAI } from "@langchain/openai";
import { HumanMessage, SystemMessage } from "@langchain/core/messages";

const llm = new ChatOpenAI({ model: "gpt-4" });

// String input
const response1 = await llm.invoke("What is LangChain?");
console.log(response1.content);

// Message input
const messages = [
  new SystemMessage("You are a helpful assistant"),
  new HumanMessage("What is LangChain?")
];

const response2 = await llm.invoke(messages);
console.log(response2.content);
```

## Model Providers

### OpenAI (GPT-4, GPT-3.5)

**Python:**
```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    model="gpt-4",  # or "gpt-4-turbo", "gpt-3.5-turbo"
    temperature=0.7,
    api_key="sk-..."  # Or set OPENAI_API_KEY env var
)
```

**TypeScript:**
```typescript
import { ChatOpenAI } from "@langchain/openai";

const llm = new ChatOpenAI({
  model: "gpt-4",
  temperature: 0.7,
  openAIApiKey: "sk-..."  // Or set OPENAI_API_KEY
});
```

### Anthropic (Claude)

**Python:**
```python
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(
    model="claude-3-5-sonnet-20241022",
    temperature=0.7,
    anthropic_api_key="sk-ant-..."  # Or set ANTHROPIC_API_KEY
)

response = llm.invoke("What is LangChain?")
```

**TypeScript:**
```typescript
import { ChatAnthropic } from "@langchain/anthropic";

const llm = new ChatAnthropic({
  model: "claude-3-5-sonnet-20241022",
  temperature: 0.7,
  anthropicApiKey: "sk-ant-..."
});

const response = await llm.invoke("What is LangChain?");
```

### Local Models (Ollama)

**Python:**
```python
from langchain_ollama import ChatOllama

llm = ChatOllama(
    model="llama3.1",
    base_url="http://localhost:11434"
)

response = llm.invoke("What is LangChain?")
```

**TypeScript:**
```typescript
import { ChatOllama } from "@langchain/ollama";

const llm = new ChatOllama({
  model: "llama3.1",
  baseUrl: "http://localhost:11434"
});

const response = await llm.invoke("What is LangChain?");
```

### Google (Gemini)

**Python:**
```python
from langchain_google_genai import ChatGoogleGenerativeAI

llm = ChatGoogleGenerativeAI(
    model="gemini-pro",
    google_api_key="..."
)
```

### Cohere

**Python:**
```python
from langchain_cohere import ChatCohere

llm = ChatCohere(
    model="command",
    cohere_api_key="..."
)
```

## Model Parameters

### Temperature

Controls randomness (0.0 = deterministic, 1.0 = creative):

```python
# Deterministic (good for facts)
llm = ChatOpenAI(temperature=0.0)

# Balanced
llm = ChatOpenAI(temperature=0.7)

# Creative (good for stories)
llm = ChatOpenAI(temperature=1.0)
```

### Max Tokens

Limit response length:

```python
llm = ChatOpenAI(
    max_tokens=100  # Limit to 100 tokens
)
```

### Top P (Nucleus Sampling)

Alternative to temperature:

```python
llm = ChatOpenAI(
    top_p=0.9  # Consider top 90% probability mass
)
```

### Frequency Penalty

Reduce repetition:

```python
llm = ChatOpenAI(
    frequency_penalty=0.5  # -2.0 to 2.0
)
```

### Presence Penalty

Encourage topic diversity:

```python
llm = ChatOpenAI(
    presence_penalty=0.5  # -2.0 to 2.0
)
```

### Complete Configuration

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    model="gpt-4",
    temperature=0.7,
    max_tokens=1000,
    top_p=0.9,
    frequency_penalty=0.5,
    presence_penalty=0.5,
    timeout=60,
    max_retries=3,
    api_key="sk-..."
)
```

## Streaming

Stream tokens as they're generated:

### Python

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()

# Stream method
for chunk in llm.stream("Tell me a long story"):
    print(chunk.content, end="", flush=True)
```

**With callbacks:**
```python
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler

llm = ChatOpenAI(
    streaming=True,
    callbacks=[StreamingStdOutCallbackHandler()]
)

response = llm.invoke("Tell me a story")
```

### TypeScript

```typescript
import { ChatOpenAI } from "@langchain/openai";

const llm = new ChatOpenAI();

const stream = await llm.stream("Tell me a long story");

for await (const chunk of stream) {
  process.stdout.write(chunk.content);
}
```

## Async Operations

### Python

```python
import asyncio
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()

async def main():
    # Async invoke
    response = await llm.ainvoke("What is LangChain?")
    print(response.content)

    # Async stream
    async for chunk in llm.astream("Tell me a story"):
        print(chunk.content, end="")

    # Async batch
    responses = await llm.abatch([
        "What is AI?",
        "What is ML?",
        "What is DL?"
    ])
    for resp in responses:
        print(resp.content)

asyncio.run(main())
```

### TypeScript

```typescript
import { ChatOpenAI } from "@langchain/openai";

const llm = new ChatOpenAI();

// All operations are async by default
const response = await llm.invoke("What is LangChain?");

// Batch processing
const responses = await llm.batch([
  "What is AI?",
  "What is ML?",
  "What is DL?"
]);

responses.forEach(resp => console.log(resp.content));
```

## Batch Processing

Process multiple inputs efficiently:

**Python:**
```python
llm = ChatOpenAI()

# Batch invoke
inputs = [
    "What is AI?",
    "What is ML?",
    "What is DL?"
]

responses = llm.batch(inputs)

for response in responses:
    print(response.content)
```

**With max concurrency:**
```python
responses = llm.batch(
    inputs,
    config={"max_concurrency": 5}
)
```

## Caching

Reduce costs and latency by caching responses:

### In-Memory Cache

**Python:**
```python
from langchain.cache import InMemoryCache
from langchain.globals import set_llm_cache

# Enable caching globally
set_llm_cache(InMemoryCache())

llm = ChatOpenAI()

# First call - hits API
response1 = llm.invoke("What is 2+2?")

# Second call - returns cached result
response2 = llm.invoke("What is 2+2?")
```

### SQLite Cache

**Python:**
```python
from langchain.cache import SQLiteCache
from langchain.globals import set_llm_cache

set_llm_cache(SQLiteCache(database_path=".langchain.db"))
```

### Redis Cache

**Python:**
```python
from langchain.cache import RedisCache
import redis

set_llm_cache(RedisCache(redis.Redis()))
```

## Function/Tool Calling

Enable structured outputs and tool use:

### Python

```python
from langchain_openai import ChatOpenAI
from langchain_core.tools import tool

@tool
def get_weather(location: str) -> str:
    """Get the current weather for a location."""
    return f"Weather in {location}: Sunny, 72°F"

llm = ChatOpenAI(model="gpt-4")

# Bind tools to model
llm_with_tools = llm.bind_tools([get_weather])

response = llm_with_tools.invoke("What's the weather in San Francisco?")

# Check if tool was called
if response.tool_calls:
    print(response.tool_calls[0])
```

### Structured Output

```python
from langchain_openai import ChatOpenAI
from langchain_core.pydantic_v1 import BaseModel, Field

class Person(BaseModel):
    name: str = Field(description="Person's name")
    age: int = Field(description="Person's age")

llm = ChatOpenAI(model="gpt-4")
structured_llm = llm.with_structured_output(Person)

result = structured_llm.invoke("John is 30 years old")
print(result.name)  # "John"
print(result.age)   # 30
```

## Message Types

### System Message

Set behavior and context:

```python
from langchain_core.messages import SystemMessage

SystemMessage(content="You are a helpful AI assistant specialized in Python")
```

### Human Message

User input:

```python
from langchain_core.messages import HumanMessage

HumanMessage(content="How do I use LangChain?")
```

### AI Message

Assistant response:

```python
from langchain_core.messages import AIMessage

AIMessage(content="LangChain is a framework for...")
```

### Function Message

Function/tool results:

```python
from langchain_core.messages import FunctionMessage

FunctionMessage(
    name="get_weather",
    content="Sunny, 72°F"
)
```

### Complete Conversation

```python
from langchain_openai import ChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage

llm = ChatOpenAI()

messages = [
    SystemMessage(content="You are a helpful assistant"),
    HumanMessage(content="Hi, I'm Alice"),
    AIMessage(content="Hello Alice! How can I help you?"),
    HumanMessage(content="What's my name?")
]

response = llm.invoke(messages)
print(response.content)  # "Your name is Alice"
```

## Error Handling

### Retry Logic

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    max_retries=3,  # Retry up to 3 times
    timeout=60       # 60 second timeout
)
```

### Try/Except

```python
try:
    response = llm.invoke("Hello")
except Exception as e:
    print(f"Error: {e}")
```

### Rate Limiting

```python
from langchain_openai import ChatOpenAI
import time

llm = ChatOpenAI()

def invoke_with_rate_limit(prompt, delay=1):
    try:
        response = llm.invoke(prompt)
        time.sleep(delay)  # Delay between calls
        return response
    except Exception as e:
        if "rate_limit" in str(e):
            print("Rate limited, waiting...")
            time.sleep(60)
            return invoke_with_rate_limit(prompt, delay)
        raise e
```

## Callbacks

Monitor execution:

```python
from langchain.callbacks.base import BaseCallbackHandler

class MyHandler(BaseCallbackHandler):
    def on_llm_start(self, serialized, prompts, **kwargs):
        print(f"Starting LLM with {len(prompts)} prompts")

    def on_llm_end(self, response, **kwargs):
        print(f"LLM finished")

llm = ChatOpenAI(callbacks=[MyHandler()])
response = llm.invoke("Hello")
```

## Model Comparison

| Provider | Best For | Speed | Cost | Context Window |
|----------|----------|-------|------|----------------|
| GPT-4 | Complex reasoning | Medium | High | 128K |
| GPT-3.5 | Fast responses | Fast | Low | 16K |
| Claude 3.5 Sonnet | Code, analysis | Fast | Medium | 200K |
| Claude 3 Opus | Complex tasks | Slow | High | 200K |
| Gemini Pro | Multimodal | Fast | Low | 32K |
| Llama 3.1 | Local/private | Fast | Free | 128K |

## Best Practices

### 1. Choose the Right Model

```python
# Simple tasks: Use faster/cheaper models
llm_simple = ChatOpenAI(model="gpt-3.5-turbo")

# Complex reasoning: Use advanced models
llm_complex = ChatOpenAI(model="gpt-4")
```

### 2. Use Streaming for UX

```python
# Good: Stream for real-time feedback
for chunk in llm.stream("Write an essay"):
    print(chunk.content, end="")

# Avoid: Wait for full response
response = llm.invoke("Write an essay")
print(response.content)
```

### 3. Enable Caching

```python
from langchain.cache import InMemoryCache
from langchain.globals import set_llm_cache

set_llm_cache(InMemoryCache())
```

### 4. Set Appropriate Timeouts

```python
llm = ChatOpenAI(
    timeout=30,      # 30 second timeout
    max_retries=2    # Retry twice
)
```

### 5. Use Batch for Multiple Requests

```python
# Good: Batch processing
responses = llm.batch(["Question 1", "Question 2", "Question 3"])

# Avoid: Sequential calls
responses = [llm.invoke(q) for q in questions]
```

## Related Documentation

- [Prompts](./11-prompt-templates.md)
- [Messages](./12-messages.md)
- [Structured Outputs](./10-structured-outputs.md)
- [Streaming](./41-streaming.md)
- [Callbacks](./40-callbacks.md)
- [LLM Integrations](./54-llm-integrations.md)
