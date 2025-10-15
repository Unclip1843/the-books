# LangChain - Key Concepts

**Sources:**
- https://python.langchain.com/docs/concepts/
- https://python.langchain.com/docs/concepts/architecture/
- https://js.langchain.com/docs/concepts/

**Fetched:** 2025-10-11

## Core Concepts

### 1. Components

LangChain applications are built from composable components:

```
┌─────────────────────────────────────┐
│        LangChain Components         │
├─────────────────────────────────────┤
│ • Chat Models & LLMs                │
│ • Prompt Templates                  │
│ • Output Parsers                    │
│ • Document Loaders                  │
│ • Text Splitters                    │
│ • Embedding Models                  │
│ • Vector Stores                     │
│ • Retrievers                        │
│ • Tools                             │
│ • Agents                            │
│ • Memory                            │
│ • Callbacks                         │
└─────────────────────────────────────┘
```

### 2. Runnable Interface

Everything in LangChain implements the `Runnable` interface:

**Python:**
```python
from langchain_core.runnables import Runnable

# All components support these methods
result = component.invoke(input)           # Synchronous
result = await component.ainvoke(input)    # Async
results = component.batch([input1, input2]) # Batch

# Streaming
for chunk in component.stream(input):
    print(chunk)

# Async streaming
async for chunk in component.astream(input):
    print(chunk)
```

**TypeScript:**
```typescript
import { Runnable } from "@langchain/core/runnables";

// All components support these methods
const result = await component.invoke(input);
const results = await component.batch([input1, input2]);

// Streaming
const stream = await component.stream(input);
for await (const chunk of stream) {
  console.log(chunk);
}
```

### 3. Composition with LCEL

LangChain Expression Language enables declarative composition:

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Compose components with pipe operator
chain = (
    ChatPromptTemplate.from_template("Tell me about {topic}")
    | ChatOpenAI()
    | StrOutputParser()
)

result = chain.invoke({"topic": "LangChain"})
```

**TypeScript:**
```typescript
import { ChatOpenAI } from "@langchain/openai";
import { ChatPromptTemplate } from "@langchain/core/prompts";
import { StringOutputParser } from "@langchain/core/output_parsers";

const chain = ChatPromptTemplate
  .fromTemplate("Tell me about {topic}")
  .pipe(new ChatOpenAI())
  .pipe(new StringOutputParser());

const result = await chain.invoke({ topic: "LangChain" });
```

## Chains vs Agents

### Chains

**Deterministic sequences** of operations:

```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate

# Chain: Fixed sequence
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant"),
    ("user", "{input}")
])

chain = prompt | ChatOpenAI()

# Always follows the same path
result = chain.invoke({"input": "Hello"})
```

**When to use:**
- Predictable workflows
- Simple transformations
- Fixed processing steps
- Direct input → output mapping

### Agents

**Dynamic decision-makers** that choose actions:

```python
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.tools import tool

@tool
def search(query: str) -> str:
    """Search for information."""
    return f"Results for: {query}"

@tool
def calculator(expression: str) -> str:
    """Calculate math expressions."""
    return str(eval(expression))

tools = [search, calculator]

# Agent: Decides which tool to use
agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)

# Agent chooses the right tool
result = agent_executor.invoke({
    "input": "What is 25 * 4, then search for that number"
})
```

**When to use:**
- Multi-step reasoning
- Tool selection needed
- Dynamic workflows
- Autonomous decision-making

## Memory and State

### Conversation Memory

Track conversation history:

**Python:**
```python
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain

memory = ConversationBufferMemory()
conversation = ConversationChain(
    llm=llm,
    memory=memory
)

# First message
conversation.invoke({"input": "Hi, I'm Alice"})

# Memory retained
conversation.invoke({"input": "What's my name?"})
# Output: "Your name is Alice"
```

### Memory Types

**Buffer Memory** - Stores all messages:
```python
from langchain.memory import ConversationBufferMemory
memory = ConversationBufferMemory()
```

**Window Memory** - Stores last N messages:
```python
from langchain.memory import ConversationBufferWindowMemory
memory = ConversationBufferWindowMemory(k=5)  # Last 5 messages
```

**Summary Memory** - Summarizes conversation:
```python
from langchain.memory import ConversationSummaryMemory
memory = ConversationSummaryMemory(llm=llm)
```

**Vector Store Memory** - Semantic retrieval:
```python
from langchain.memory import VectorStoreRetrieverMemory
memory = VectorStoreRetrieverMemory(retriever=retriever)
```

## Streaming and Async

### Streaming

Stream tokens as they're generated:

**Python:**
```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()

# Stream tokens
for chunk in llm.stream("Tell me a story"):
    print(chunk.content, end="", flush=True)
```

**TypeScript:**
```typescript
import { ChatOpenAI } from "@langchain/openai";

const llm = new ChatOpenAI();

const stream = await llm.stream("Tell me a story");
for await (const chunk of stream) {
  process.stdout.write(chunk.content);
}
```

### Async Operations

Non-blocking execution:

**Python:**
```python
import asyncio
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()

async def main():
    # Async invoke
    result = await llm.ainvoke("Hello")

    # Async stream
    async for chunk in llm.astream("Tell me a story"):
        print(chunk.content, end="")

    # Async batch
    results = await llm.abatch(["Hello", "Hi", "Hey"])

asyncio.run(main())
```

**TypeScript:**
```typescript
import { ChatOpenAI } from "@langchain/openai";

const llm = new ChatOpenAI();

// All operations are async by default
const result = await llm.invoke("Hello");

const results = await llm.batch(["Hello", "Hi", "Hey"]);

const stream = await llm.stream("Tell me a story");
for await (const chunk of stream) {
  console.log(chunk.content);
}
```

## Callbacks and Tracing

### Callbacks

Monitor execution at every step:

**Python:**
```python
from langchain.callbacks.base import BaseCallbackHandler

class MyCallbackHandler(BaseCallbackHandler):
    def on_llm_start(self, serialized, prompts, **kwargs):
        print(f"LLM started with prompts: {prompts}")

    def on_llm_end(self, response, **kwargs):
        print(f"LLM ended with: {response}")

    def on_chain_start(self, serialized, inputs, **kwargs):
        print(f"Chain started with: {inputs}")

# Use callbacks
chain.invoke(
    {"input": "Hello"},
    config={"callbacks": [MyCallbackHandler()]}
)
```

### LangSmith Tracing

Automatic tracing with LangSmith:

```python
import os

# Enable tracing
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = "your-api-key"

# All invocations automatically traced
chain.invoke({"input": "Hello"})
```

### Verbose Mode

Quick debugging:

```python
from langchain.chains import LLMChain

chain = LLMChain(llm=llm, prompt=prompt, verbose=True)

# Prints detailed execution info
chain.invoke({"input": "Hello"})
```

## Key Design Patterns

### 1. RunnablePassthrough

Pass data through unchanged:

```python
from langchain_core.runnables import RunnablePassthrough

chain = (
    {"question": RunnablePassthrough()}
    | prompt
    | llm
)

chain.invoke("What is LangChain?")
```

### 2. RunnableParallel

Execute multiple runnables in parallel:

```python
from langchain_core.runnables import RunnableParallel

chain = RunnableParallel(
    summary=summarize_chain,
    translation=translate_chain,
    sentiment=sentiment_chain
)

results = chain.invoke({"text": "Some text"})
# Returns: {summary: ..., translation: ..., sentiment: ...}
```

### 3. RunnableBranch

Conditional routing:

```python
from langchain_core.runnables import RunnableBranch

branch = RunnableBranch(
    (lambda x: "code" in x, code_chain),
    (lambda x: "math" in x, math_chain),
    default_chain  # Default
)

result = branch.invoke("Write some code")
```

### 4. RunnableLambda

Custom logic:

```python
from langchain_core.runnables import RunnableLambda

def custom_logic(x):
    return x.upper()

chain = (
    RunnableLambda(custom_logic)
    | prompt
    | llm
)
```

## Input/Output Types

### Chat Models

**Input:** Messages or strings
```python
# String input
llm.invoke("Hello")

# Message input
from langchain_core.messages import HumanMessage
llm.invoke([HumanMessage(content="Hello")])
```

**Output:** AIMessage
```python
response = llm.invoke("Hello")
print(response.content)  # "Hello! How can I help you?"
```

### Chains

**Input:** Dictionary
```python
chain.invoke({"topic": "AI"})
```

**Output:** Depends on output parser
```python
# With StrOutputParser
result = chain.invoke({"topic": "AI"})
print(result)  # String output

# Without parser
result = chain.invoke({"topic": "AI"})
print(result.content)  # AIMessage
```

### Agents

**Input:** Dictionary with "input" key
```python
agent_executor.invoke({"input": "What's the weather?"})
```

**Output:** Dictionary with "output" key
```python
result = agent_executor.invoke({"input": "What's the weather?"})
print(result["output"])
```

## Configuration

### Runtime Configuration

Pass configuration at runtime:

```python
chain.invoke(
    {"input": "Hello"},
    config={
        "callbacks": [handler],
        "tags": ["my-tag"],
        "metadata": {"user_id": "123"},
        "max_concurrency": 5
    }
)
```

### Model Configuration

Configure models:

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    model="gpt-4",
    temperature=0.7,
    max_tokens=1000,
    timeout=30,
    max_retries=3
)
```

## Error Handling

### Try/Except

```python
try:
    result = chain.invoke({"input": "Hello"})
except Exception as e:
    print(f"Error: {e}")
```

### Fallbacks

```python
from langchain_core.runnables import RunnableWithFallbacks

chain_with_fallback = chain.with_fallbacks([backup_chain])

# Tries chain first, falls back to backup_chain on error
result = chain_with_fallback.invoke({"input": "Hello"})
```

### Retry Logic

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    max_retries=3,
    request_timeout=60
)
```

## Best Practices

### 1. Use LCEL for Composition

```python
# Good: LCEL
chain = prompt | llm | parser

# Avoid: Manual composition
def manual_chain(input):
    prompt_result = prompt.invoke(input)
    llm_result = llm.invoke(prompt_result)
    return parser.invoke(llm_result)
```

### 2. Leverage Streaming

```python
# Good: Stream for UX
for chunk in chain.stream(input):
    print(chunk, end="")

# Avoid: Waiting for full response
result = chain.invoke(input)
print(result)
```

### 3. Use Async for Concurrency

```python
# Good: Async for multiple requests
results = await asyncio.gather(
    chain.ainvoke(input1),
    chain.ainvoke(input2),
    chain.ainvoke(input3)
)

# Avoid: Sequential
results = [
    chain.invoke(input1),
    chain.invoke(input2),
    chain.invoke(input3)
]
```

### 4. Enable Tracing

```python
# Good: Always trace in development
os.environ["LANGCHAIN_TRACING_V2"] = "true"

# Helps debug issues
chain.invoke(input)
```

## Related Documentation

- [Architecture](./04-architecture.md)
- [LCEL](./26-lcel.md)
- [Chains Overview](./25-chains-overview.md)
- [Agents Overview](./30-agents-overview.md)
- [Callbacks](./40-callbacks.md)
- [Streaming](./41-streaming.md)
