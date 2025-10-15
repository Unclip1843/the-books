# LangChain - Chains Overview

**Sources:**
- https://python.langchain.com/docs/concepts/runnables/
- https://python.langchain.com/docs/how_to/#langchain-expression-language-lcel
- https://js.langchain.com/docs/concepts/runnables/

**Fetched:** 2025-10-11

## What are Chains?

Chains **compose components** into sequences:

```
Input → Component 1 → Component 2 → Component 3 → Output
```

**Modern approach:** Use LCEL (LangChain Expression Language)

## Runnable Interface

All components implement `Runnable`:

**Python:**
```python
# Every component has these methods
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

## LCEL - Pipe Operator

Chain components with `|`:

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

prompt = ChatPromptTemplate.from_template("Tell me about {topic}")
llm = ChatOpenAI()
parser = StrOutputParser()

# Compose with pipe
chain = prompt | llm | parser

# Invoke
result = chain.invoke({"topic": "AI"})
print(result)  # String output
```

**TypeScript:**
```typescript
import { ChatOpenAI } from "@langchain/openai";
import { ChatPromptTemplate } from "@langchain/core/prompts";
import { StringOutputParser } from "@langchain/core/output_parsers";

const prompt = ChatPromptTemplate.fromTemplate("Tell me about {topic}");
const llm = new ChatOpenAI();
const parser = new StringOutputParser();

const chain = prompt.pipe(llm).pipe(parser);

const result = await chain.invoke({ topic: "AI" });
```

## Common Chain Patterns

### 1. Prompt + LLM + Parser

**Python:**
```python
chain = prompt | llm | StrOutputParser()

result = chain.invoke({"variable": "value"})
```

### 2. Retrieval Chain

**Python:**
```python
from langchain_core.runnables import RunnablePassthrough

chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

result = chain.invoke("What is LangChain?")
```

### 3. Multiple Inputs

**Python:**
```python
from langchain_core.runnables import RunnableParallel

chain = RunnableParallel(
    {
        "summary": summarize_chain,
        "translation": translate_chain
    }
)

result = chain.invoke({"text": "Some text"})
# Returns: {summary: "...", translation: "..."}
```

### 4. Conditional Logic

**Python:**
```python
from langchain_core.runnables import RunnableBranch

branch = RunnableBranch(
    (lambda x: "code" in x, code_chain),
    (lambda x: "math" in x, math_chain),
    default_chain
)

result = branch.invoke("Write some code")
```

### 5. Sequential Steps

**Python:**
```python
# Step 1: Extract entities
extract_chain = extract_prompt | llm | parser

# Step 2: Classify
classify_chain = classify_prompt | llm | parser

# Combine
full_chain = extract_chain | classify_chain
```

## RunnablePassthrough

Pass data through unchanged:

**Python:**
```python
chain = (
    {"question": RunnablePassthrough()}  # Pass input as "question"
    | prompt
    | llm
)

result = chain.invoke("What is AI?")
```

**With transformation:**
```python
chain = (
    RunnablePassthrough().assign(
        upper=lambda x: x["text"].upper()
    )
    | prompt
    | llm
)
```

## RunnableParallel

Execute multiple chains in parallel:

**Python:**
```python
parallel_chain = RunnableParallel(
    joke=joke_chain,
    poem=poem_chain,
    story=story_chain
)

result = parallel_chain.invoke({"topic": "AI"})
# Returns: {joke: "...", poem: "...", story: "..."}
```

## RunnableLambda

Custom logic as a runnable:

**Python:**
```python
from langchain_core.runnables import RunnableLambda

def custom_logic(x):
    # Custom processing
    return x.upper()

chain = (
    RunnableLambda(custom_logic)
    | prompt
    | llm
)
```

## Streaming

**Python:**
```python
chain = prompt | llm | StrOutputParser()

# Stream output
for chunk in chain.stream({"topic": "AI"}):
    print(chunk, end="", flush=True)
```

## Async Chains

**Python:**
```python
import asyncio

async def main():
    result = await chain.ainvoke({"topic": "AI"})

    # Async streaming
    async for chunk in chain.astream({"topic": "AI"}):
        print(chunk)

    # Async batch
    results = await chain.abatch([
        {"topic": "AI"},
        {"topic": "ML"}
    ])

asyncio.run(main())
```

## Batch Processing

**Python:**
```python
inputs = [
    {"topic": "AI"},
    {"topic": "ML"},
    {"topic": "DL"}
]

results = chain.batch(inputs)

for result in results:
    print(result)
```

## Error Handling

### With Fallbacks

**Python:**
```python
chain_with_fallback = chain.with_fallbacks([backup_chain])

# Tries chain first, uses backup_chain on error
result = chain_with_fallback.invoke(input)
```

### Try/Except

**Python:**
```python
try:
    result = chain.invoke(input)
except Exception as e:
    print(f"Error: {e}")
```

## Configuration

**Python:**
```python
# Configure at runtime
result = chain.invoke(
    input,
    config={
        "callbacks": [handler],
        "tags": ["my-tag"],
        "metadata": {"user_id": "123"},
        "max_concurrency": 5
    }
)
```

## Complete Examples

### RAG Chain

**Python:**
```python
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser

# Setup
vectorstore = Chroma.from_texts(["Doc 1", "Doc 2"], OpenAIEmbeddings())
retriever = vectorstore.as_retriever()

prompt = ChatPromptTemplate.from_template("""
Answer based on context:

Context: {context}

Question: {question}
""")

# Chain
rag_chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | ChatOpenAI()
    | StrOutputParser()
)

# Use
answer = rag_chain.invoke("What is in the documents?")
```

### Multi-Step Chain

**Python:**
```python
# Step 1: Generate outline
outline_prompt = ChatPromptTemplate.from_template("Create outline for: {topic}")
outline_chain = outline_prompt | llm | StrOutputParser()

# Step 2: Write content
content_prompt = ChatPromptTemplate.from_template("Write content for: {outline}")
content_chain = content_prompt | llm | StrOutputParser()

# Combined chain
full_chain = (
    {"topic": RunnablePassthrough()}
    | RunnablePassthrough().assign(outline=outline_chain)
    | content_chain
)

result = full_chain.invoke({"topic": "AI"})
```

## Best Practices

### 1. Use LCEL

```python
# Good: LCEL
chain = prompt | llm | parser

# Avoid: Manual composition
def manual_chain(input):
    p = prompt.invoke(input)
    l = llm.invoke(p)
    return parser.invoke(l)
```

### 2. Leverage Streaming

```python
# Good: Stream for UX
for chunk in chain.stream(input):
    print(chunk, end="")

# Avoid: Wait for full response
result = chain.invoke(input)
```

### 3. Use Async for Concurrency

```python
# Good: Parallel execution
results = await asyncio.gather(
    chain.ainvoke(input1),
    chain.ainvoke(input2)
)

# Avoid: Sequential
results = [
    chain.invoke(input1),
    chain.invoke(input2)
]
```

### 4. Add Fallbacks

```python
# Good: Graceful degradation
chain = main_chain.with_fallbacks([backup_chain])

# Avoid: No error handling
chain = main_chain
```

## Related Documentation

- [LCEL](./26-lcel.md)
- [Prompt Templates](./11-prompt-templates.md)
- [Chat Models](./06-chat-models.md)
- [RAG Basics](./21-rag-basics.md)
- [Agents](./30-agents-overview.md)
