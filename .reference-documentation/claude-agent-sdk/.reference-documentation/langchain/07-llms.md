# LangChain - LLMs (Legacy)

**Sources:**
- https://python.langchain.com/docs/concepts/llms/
- https://python.langchain.com/docs/integrations/llms/
- https://js.langchain.com/docs/integrations/llms/

**Fetched:** 2025-10-11

## What are LLMs?

LLMs in LangChain refer to **string-in, string-out** language models. This is a **legacy interface** - modern applications should use **Chat Models** instead.

**Key Difference:**
- **LLM:** String → String (legacy)
- **Chat Model:** Messages → Message (preferred)

## When to Use LLMs vs Chat Models

### Use Chat Models (Recommended)

```python
from langchain_openai import ChatOpenAI

# Preferred: Chat models
llm = ChatOpenAI()
response = llm.invoke("What is AI?")
```

**Advantages:**
- Message-based interface
- System messages support
- Chat history management
- Function/tool calling
- Better conversation context

### Use LLMs (Legacy)

```python
from langchain_openai import OpenAI

# Legacy: String-based LLMs
llm = OpenAI()
response = llm.invoke("What is AI?")
```

**Only use when:**
- Working with completion-only models
- Maintaining legacy code
- Specific use cases requiring raw completions

## Basic Usage

### Python

```python
from langchain_openai import OpenAI

# Initialize
llm = OpenAI(
    model="gpt-3.5-turbo-instruct",  # Completion model
    temperature=0.7
)

# String input
response = llm.invoke("What is LangChain?")
print(response)  # String output
```

### TypeScript

```typescript
import { OpenAI } from "@langchain/openai";

const llm = new OpenAI({
  model: "gpt-3.5-turbo-instruct",
  temperature: 0.7
});

const response = await llm.invoke("What is LangChain?");
console.log(response);  // String output
```

## LLM Providers

### OpenAI Completions

**Python:**
```python
from langchain_openai import OpenAI

llm = OpenAI(
    model="gpt-3.5-turbo-instruct",
    temperature=0.7,
    max_tokens=256
)

response = llm.invoke("Complete this: Once upon a time")
```

### HuggingFace

**Python:**
```python
from langchain_huggingface import HuggingFaceEndpoint

llm = HuggingFaceEndpoint(
    repo_id="google/flan-t5-large",
    huggingfacehub_api_token="hf_..."
)

response = llm.invoke("What is 2+2?")
```

### Cohere

**Python:**
```python
from langchain_cohere import Cohere

llm = Cohere(
    model="command",
    cohere_api_key="..."
)

response = llm.invoke("Explain quantum computing")
```

### AI21

**Python:**
```python
from langchain_ai21 import AI21

llm = AI21(
    model="j2-ultra",
    ai21_api_key="..."
)

response = llm.invoke("Write a poem")
```

## Model Parameters

### Temperature

```python
# Deterministic
llm = OpenAI(temperature=0.0)

# Creative
llm = OpenAI(temperature=1.0)
```

### Max Tokens

```python
llm = OpenAI(max_tokens=100)  # Limit response length
```

### Top P

```python
llm = OpenAI(top_p=0.9)
```

### Frequency Penalty

```python
llm = OpenAI(frequency_penalty=0.5)
```

### Complete Configuration

```python
from langchain_openai import OpenAI

llm = OpenAI(
    model="gpt-3.5-turbo-instruct",
    temperature=0.7,
    max_tokens=256,
    top_p=1.0,
    frequency_penalty=0.0,
    presence_penalty=0.0,
    n=1,  # Number of completions
    best_of=1
)
```

## Streaming

**Python:**
```python
from langchain_openai import OpenAI

llm = OpenAI()

for chunk in llm.stream("Tell me a story"):
    print(chunk, end="", flush=True)
```

**TypeScript:**
```typescript
import { OpenAI } from "@langchain/openai";

const llm = new OpenAI();

const stream = await llm.stream("Tell me a story");

for await (const chunk of stream) {
  process.stdout.write(chunk);
}
```

## Async Operations

**Python:**
```python
import asyncio
from langchain_openai import OpenAI

llm = OpenAI()

async def main():
    # Async invoke
    response = await llm.ainvoke("What is AI?")
    print(response)

    # Async stream
    async for chunk in llm.astream("Tell a story"):
        print(chunk, end="")

    # Async batch
    responses = await llm.abatch([
        "What is AI?",
        "What is ML?",
        "What is DL?"
    ])

asyncio.run(main())
```

## Batch Processing

**Python:**
```python
llm = OpenAI()

prompts = [
    "What is AI?",
    "What is ML?",
    "What is DL?"
]

responses = llm.batch(prompts)

for response in responses:
    print(response)
```

## Caching

Same as Chat Models:

```python
from langchain.cache import InMemoryCache
from langchain.globals import set_llm_cache

set_llm_cache(InMemoryCache())

llm = OpenAI()

# First call - hits API
response1 = llm.invoke("What is 2+2?")

# Second call - cached
response2 = llm.invoke("What is 2+2?")
```

## Migration from LLMs to Chat Models

### Before (LLM)

```python
from langchain_openai import OpenAI

llm = OpenAI()
response = llm.invoke("What is AI?")
print(response)
```

### After (Chat Model)

```python
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser

llm = ChatOpenAI()
parser = StrOutputParser()

chain = llm | parser
response = chain.invoke("What is AI?")
print(response)
```

### With Prompts

**Before:**
```python
from langchain import PromptTemplate, LLMChain

prompt = PromptTemplate.from_template("Tell me about {topic}")
chain = LLMChain(llm=llm, prompt=prompt)

response = chain.invoke({"topic": "AI"})
```

**After:**
```python
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_template("Tell me about {topic}")
chain = prompt | llm | StrOutputParser()

response = chain.invoke({"topic": "AI"})
```

## Common Use Cases

### Text Completion

```python
llm = OpenAI()

prompt = "Complete this story: Once upon a time in a land far away"
response = llm.invoke(prompt)
print(response)
```

### Code Completion

```python
llm = OpenAI(temperature=0.0)

prompt = """
def fibonacci(n):
    # Complete this function
"""

response = llm.invoke(prompt)
print(response)
```

### Few-Shot Learning

```python
llm = OpenAI()

prompt = """
Example 1:
Input: apple
Output: fruit

Example 2:
Input: carrot
Output: vegetable

Input: banana
Output:"""

response = llm.invoke(prompt)
print(response)  # "fruit"
```

## Limitations of LLMs

1. **No Message Structure** - Can't use SystemMessage, HumanMessage, etc.
2. **No Tool Calling** - Can't use function calling
3. **Limited Context** - Harder to manage conversation history
4. **Less Control** - Fewer options for structured outputs
5. **Deprecated** - OpenAI is phasing out completion models

## Best Practices

### 1. Migrate to Chat Models

```python
# Avoid: LLM
llm = OpenAI()

# Prefer: Chat Model
llm = ChatOpenAI()
```

### 2. Use Output Parsers

```python
from langchain_core.output_parsers import StrOutputParser

# Convert chat model to string output
chain = ChatOpenAI() | StrOutputParser()
```

### 3. Set Temperature Appropriately

```python
# Facts and deterministic tasks
llm = OpenAI(temperature=0.0)

# Creative tasks
llm = OpenAI(temperature=0.9)
```

### 4. Handle Errors

```python
try:
    response = llm.invoke(prompt)
except Exception as e:
    print(f"Error: {e}")
```

## Comparison: LLM vs Chat Model

| Feature | LLM | Chat Model |
|---------|-----|------------|
| Input | String | Messages |
| Output | String | AIMessage |
| System messages | ❌ | ✅ |
| Chat history | Manual | Built-in |
| Function calling | ❌ | ✅ |
| Streaming | ✅ | ✅ |
| Async | ✅ | ✅ |
| Caching | ✅ | ✅ |
| Status | Legacy | Recommended |

## When LLMs Are Actually Better

**Rare cases where LLMs are preferred:**

1. **Pure Completion Tasks**
   ```python
   # Completing code snippets
   llm = OpenAI()
   code = llm.invoke("def hello():")
   ```

2. **Legacy Systems**
   ```python
   # Maintaining existing LLM-based code
   ```

3. **Specific Models**
   ```python
   # Models that only support completion interface
   ```

## Related Documentation

- [Chat Models](./06-chat-models.md) - Recommended alternative
- [Prompt Templates](./11-prompt-templates.md)
- [Output Parsers](./70-output-parsers.md)
- [Migration Guide](./80-migration-guides.md)
