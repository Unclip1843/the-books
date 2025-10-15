# LangChain Documentation

Complete reference documentation for LangChain - a framework for building LLM-powered applications.

**Last Updated:** 2025-10-11
**Version:** Covers LangChain Python & TypeScript SDKs
**Status:** Core documentation complete

## Quick Navigation

### 🚀 Getting Started

Essential documentation to get up and running:

- [01 - Overview](./01-overview.md) - What is LangChain, core concepts, architecture
- [02 - Installation](./02-installation.md) - Python and TypeScript installation
- [03 - Quickstart](./03-quickstart.md) - First LLM call, chain, RAG app, agent
- [04 - Architecture](./04-architecture.md) - Package structure, design principles
- [05 - Key Concepts](./05-key-concepts.md) - Runnables, composition, streaming, async

### 💬 Language Models

Working with LLMs and chat models:

- [06 - Chat Models](./06-chat-models.md) - ChatOpenAI, ChatAnthropic, parameters, streaming
- [07 - LLMs (Legacy)](./07-llms.md) - String-based LLMs, when to use
- [08 - Multimodal](./08-multimodal.md) - Vision, images, audio processing
- [09 - Model I/O](./09-model-io.md) - Prompts, messages, output parsers
- [10 - Structured Outputs](./10-structured-outputs.md) - Pydantic models, JSON mode, validation

### 📝 Prompts & Messages

Crafting effective prompts:

- [11 - Prompt Templates](./11-prompt-templates.md) - Creating reusable prompts
- [12 - Messages](./12-messages.md) - SystemMessage, HumanMessage, AIMessage
- [13 - Few-Shot Prompting](./13-few-shot-prompting.md) - Examples for better outputs
- [14 - Example Selectors](./14-example-selectors.md) - Semantic similarity, dynamic selection

### 📄 Document Processing

Loading and preparing documents:

- [15 - Document Loaders](./15-document-loaders.md) - PDF, web, API, database loaders
- [16 - Text Splitters](./16-text-splitters.md) - Chunking strategies, RecursiveCharacterTextSplitter
- [17 - Transformers](./17-transformers.md) - Filtering, enriching, cleaning documents
- [18 - Embeddings](./18-embeddings.md) - OpenAI, HuggingFace, Cohere, Voyage embeddings
- [19 - Vector Stores](./19-vector-stores.md) - Chroma, FAISS, Pinecone, Qdrant

### 🔍 Retrieval & RAG

Building RAG applications:

- [20 - Retrievers](./20-retrievers.md) - Vector store, multi-query, contextual compression
- [21 - RAG Basics](./21-rag-basics.md) - Complete RAG pipeline, conversational RAG
- [25 - Chains Overview](./25-chains-overview.md) - LCEL, pipe operator, composition patterns

### 🤖 Agents

Autonomous decision-making:

- [30 - Agents Overview](./30-agents-overview.md) - Creating agents, tools, agent types

## Documentation Structure

This documentation covers LangChain comprehensively with:

✅ **Working Code Examples** - Python and TypeScript
✅ **Real-World Use Cases** - Practical applications
✅ **Best Practices** - Production-ready patterns
✅ **Complete Coverage** - Core features documented
✅ **Source Attribution** - All sources cited

## Quick Examples

### Simple LLM Call

**Python:**
```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4")
response = llm.invoke("What is LangChain?")
print(response.content)
```

**TypeScript:**
```typescript
import { ChatOpenAI } from "@langchain/openai";

const llm = new ChatOpenAI({ model: "gpt-4" });
const response = await llm.invoke("What is LangChain?");
console.log(response.content);
```

### Simple Chain

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

prompt = ChatPromptTemplate.from_template("Tell me about {topic}")
llm = ChatOpenAI()
parser = StrOutputParser()

chain = prompt | llm | parser

result = chain.invoke({"topic": "AI"})
```

### Basic RAG

**Python:**
```python
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser

# Create vector store
vectorstore = Chroma.from_texts(["Doc 1", "Doc 2"], OpenAIEmbeddings())
retriever = vectorstore.as_retriever()

# Create RAG chain
prompt = ChatPromptTemplate.from_template("""
Answer based on context:

Context: {context}

Question: {question}
""")

chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | ChatOpenAI()
    | StrOutputParser()
)

answer = chain.invoke("Your question")
```

### Simple Agent

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.tools import tool

@tool
def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b

tools = [multiply]
llm = ChatOpenAI(model="gpt-4")

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant"),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}")
])

agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)

result = agent_executor.invoke({"input": "What is 5 times 3?"})
```

## Core Concepts

### Runnable Interface

Every component implements these methods:

```python
result = component.invoke(input)           # Synchronous
result = await component.ainvoke(input)    # Async
results = component.batch([input1, input2]) # Batch
for chunk in component.stream(input): ...  # Streaming
```

### LCEL (LangChain Expression Language)

Compose components with the pipe operator:

```python
chain = component1 | component2 | component3
```

### Common Patterns

**Retrieval:** `{"context": retriever, "question": RunnablePassthrough()}`
**Parallel:** `RunnableParallel({key1: chain1, key2: chain2})`
**Conditional:** `RunnableBranch((condition, chain), default)`

## Package Structure

```
langchain-core       # Base abstractions, Runnable interface
langchain            # Chains, agents, retrieval strategies
langchain-community  # Third-party integrations (100+)
langgraph            # Multi-actor orchestration (separate)
```

## SDK Support

### Python
- Full framework support
- Most mature implementation
- `pip install langchain langchain-openai`

### TypeScript
- Feature-complete
- Node.js and browser support
- `npm install langchain @langchain/openai`

## Key Integrations

**LLM Providers:**
- OpenAI (GPT-4, GPT-3.5)
- Anthropic (Claude)
- Ollama (Local models)
- HuggingFace
- Cohere, Google Vertex AI

**Vector Stores:**
- Chroma (Local/Cloud)
- FAISS (Local)
- Pinecone (Cloud)
- Qdrant (Local/Cloud)
- Weaviate

**Document Loaders:**
- PDF (PyPDF, Unstructured)
- Web (Firecrawl, WebBaseLoader)
- Databases (SQL, MongoDB)
- APIs (GitHub, Notion, Google Drive)

## Use Cases

✅ **Chatbots** - Conversational AI with memory
✅ **Question Answering** - QA over documents
✅ **RAG Applications** - Ground responses in your data
✅ **Agents** - Autonomous tool-using systems
✅ **Summarization** - Document summarization
✅ **Data Extraction** - Structured data from text
✅ **Code Generation** - Generate and execute code

## Resources

### Official Documentation
- Python: https://python.langchain.com/
- TypeScript: https://js.langchain.com/
- API Reference: https://python.langchain.com/api_reference/

### GitHub
- Python: https://github.com/langchain-ai/langchain
- TypeScript: https://github.com/langchain-ai/langchainjs

### Community
- Discord: Active community support
- GitHub Discussions: Q&A and feature requests

## Contributing

This documentation is maintained as part of the Agent Playbook Cookbook reference documentation collection.

**Attribution:** All content is sourced from official LangChain documentation and properly attributed in each file and in [SOURCES.md](./SOURCES.md).

## License

This documentation compilation follows the original LangChain MIT License.

---

**Need help?** Start with [01-overview.md](./01-overview.md) for a comprehensive introduction, or jump to [03-quickstart.md](./03-quickstart.md) to start building immediately.
