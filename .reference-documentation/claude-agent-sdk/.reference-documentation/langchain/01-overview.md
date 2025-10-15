# LangChain - Overview

**Sources:**
- https://python.langchain.com/docs/introduction/
- https://python.langchain.com/docs/concepts/
- https://js.langchain.com/docs/introduction/
- https://github.com/langchain-ai/langchain

**Fetched:** 2025-10-11

## What is LangChain?

LangChain is a framework for developing applications powered by large language models (LLMs). It simplifies the entire LLM application lifecycle from development to productionization and deployment.

**Mission:** Enable developers to build context-aware, reasoning applications with LLMs.

## Key Capabilities

### 1. **Composable Components**
Build complex LLM applications from simple, reusable components:
- Chat models and LLMs
- Prompt templates
- Output parsers
- Document loaders
- Text splitters
- Embedding models
- Vector stores
- Retrievers
- Tools and agents

### 2. **Chains**
Combine components into sequences:
```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate

llm = ChatOpenAI()
prompt = ChatPromptTemplate.from_template("Tell me a joke about {topic}")

chain = prompt | llm
result = chain.invoke({"topic": "programming"})
```

### 3. **Agents**
Build applications that reason and take actions:
- Autonomous decision-making
- Tool calling
- Multi-step reasoning
- Dynamic workflows

### 4. **Retrieval Augmented Generation (RAG)**
Ground LLM responses in your data:
```python
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain.chains import RetrievalQA

vectorstore = Chroma.from_documents(documents, OpenAIEmbeddings())
qa_chain = RetrievalQA.from_chain_type(llm, retriever=vectorstore.as_retriever())
```

### 5. **Memory**
Add conversational context:
- Chat history management
- Summary memory
- Vector store memory
- Custom memory implementations

## Architecture

### Core Packages

```
┌─────────────────────────────────────┐
│          Your Application           │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│         langchain                   │
│  (Chains, Agents, Retrieval)        │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│       langchain-core                │
│    (Base Abstractions)              │
└─────────────────────────────────────┘
```

**`langchain-core`**: Base abstractions and LangChain Expression Language (LCEL)
- Interfaces for chat models, LLMs, embeddings
- Runnable interface
- Base classes

**`langchain`**: Chains, agents, and retrieval strategies
- Pre-built chains
- Agent executors
- Retrieval strategies
- Cognitive architecture

**`langchain-community`**: Third-party integrations
- 100+ LLM providers
- Vector store integrations
- Tool integrations
- Document loaders

**`langgraph`**: Multi-actor orchestration (separate but integrated)
- Stateful agents
- Complex workflows
- Persistence
- Streaming

## Core Concepts

### 1. Runnable Interface
Everything in LangChain implements the `Runnable` interface:

```python
# All of these are Runnables
llm.invoke(input)
prompt.invoke(input)
chain.invoke(input)
agent.invoke(input)

# Enables composition
chain = prompt | llm | output_parser
```

### 2. LangChain Expression Language (LCEL)
Declarative way to compose chains:

```python
chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)
```

### 3. Streaming
Built-in streaming support:

```python
for chunk in chain.stream({"topic": "AI"}):
    print(chunk, end="", flush=True)
```

### 4. Async
Native async support:

```python
result = await chain.ainvoke({"topic": "AI"})
```

## Use Cases

### 1. **Chatbots**
Conversational AI with memory:
```python
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain

memory = ConversationBufferMemory()
conversation = ConversationChain(llm=llm, memory=memory)
```

### 2. **Question Answering**
QA over documents:
```python
from langchain.chains import RetrievalQA

qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    retriever=vectorstore.as_retriever()
)
```

### 3. **Data Extraction**
Structured data from unstructured text:
```python
from langchain.chains import create_extraction_chain

schema = {
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    }
}

chain = create_extraction_chain(schema, llm)
```

### 4. **Summarization**
Document summarization:
```python
from langchain.chains.summarize import load_summarize_chain

chain = load_summarize_chain(llm, chain_type="stuff")
result = chain.invoke(documents)
```

### 5. **Code Generation**
Generate and execute code:
```python
from langchain.tools import PythonREPLTool
from langchain.agents import create_react_agent

python_repl = PythonREPLTool()
agent = create_react_agent(llm, [python_repl], prompt)
```

### 6. **Autonomous Agents**
Self-directed agents with tools:
```python
from langchain.agents import create_openai_functions_agent

tools = [search_tool, calculator_tool, weather_tool]
agent = create_openai_functions_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)
```

## Ecosystem

### LangSmith
Tracing, evaluation, and monitoring platform:
- Debug LLM applications
- Trace execution
- Evaluate performance
- A/B testing

### LangGraph
Build stateful, multi-actor applications:
- Complex workflows
- Cyclic graphs
- Human-in-the-loop
- Persistence

### Integrations
100+ integrations including:
- **LLMs:** OpenAI, Anthropic, Cohere, HuggingFace
- **Vector Stores:** Chroma, Pinecone, Weaviate, Qdrant
- **Tools:** SerpAPI, Zapier, Wikipedia
- **Data Loaders:** Firecrawl, Unstructured, PDFs

## Example Application

Complete RAG chatbot:

```python
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_community.vectorstores import Chroma
from langchain.chains import ConversationalRetrievalChain
from langchain.memory import ConversationBufferMemory

# Load documents
from langchain_community.document_loaders import TextLoader
loader = TextLoader("data.txt")
documents = loader.load()

# Split and embed
from langchain.text_splitters import RecursiveCharacterTextSplitter
splitter = RecursiveCharacterTextSplitter(chunk_size=1000)
splits = splitter.split_documents(documents)

# Create vector store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(splits, embeddings)

# Create conversational chain
llm = ChatOpenAI(model="gpt-4")
memory = ConversationBufferMemory(
    memory_key="chat_history",
    return_messages=True
)

chain = ConversationalRetrievalChain.from_llm(
    llm=llm,
    retriever=vectorstore.as_retriever(),
    memory=memory
)

# Chat
response = chain.invoke({"question": "What is this document about?"})
print(response["answer"])
```

## Why LangChain?

### ✅ Composability
Build complex applications from simple components.

### ✅ Standardization
Unified interfaces across 100+ integrations.

### ✅ Production-Ready
Built-in observability, streaming, and async support.

### ✅ Ecosystem
Rich ecosystem of tools, integrations, and extensions.

### ✅ Active Development
Regular updates, strong community, extensive documentation.

## When to Use LangChain

**Good Fit:**
- Building LLM applications with multiple components
- Need RAG (Retrieval Augmented Generation)
- Want standardized interfaces
- Building agents with tools
- Need production observability

**Maybe Not:**
- Simple single LLM calls (use provider SDK directly)
- Highly custom workflows (might be overengineered)
- Need absolute control over every detail

## Getting Started

```bash
# Python
pip install langchain langchain-openai

# TypeScript
npm install langchain @langchain/openai
```

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()
response = llm.invoke("Hello, world!")
print(response.content)
```

## Supported Languages

### Python
- Full framework support
- Most mature implementation
- Best documentation

### TypeScript/JavaScript
- Feature-complete
- Node.js and browser support
- Growing ecosystem

## Performance

- **Speed:** Async and streaming support for responsiveness
- **Cost:** Caching reduces LLM API calls
- **Scale:** Battle-tested in production by 1000s of companies

## Community

- **GitHub:** 90k+ stars
- **Discord:** Active community
- **Docs:** Comprehensive documentation
- **Examples:** 100+ example applications

## Next Steps

- [Installation](./02-installation.md) - Set up LangChain
- [Quickstart](./03-quickstart.md) - Your first LangChain app
- [Chat Models](./06-chat-models.md) - Work with LLMs
- [RAG Basics](./21-rag-basics.md) - Build RAG applications
- [Agents](./30-agents-overview.md) - Create autonomous agents

## Related Documentation

- [Architecture](./04-architecture.md)
- [Key Concepts](./05-key-concepts.md)
- [Python SDK](./44-python-installation.md)
- [TypeScript SDK](./49-typescript-installation.md)
