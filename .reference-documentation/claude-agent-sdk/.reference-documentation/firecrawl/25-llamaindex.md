# Firecrawl - LlamaIndex Integration

**Sources:**
- https://docs.firecrawl.dev/integrations/llamaindex
- https://docs.llamaindex.ai/

**Fetched:** 2025-10-11

## Overview

Firecrawl integrates with LlamaIndex for building RAG applications and knowledge bases.

## Installation

```bash
pip install llama-index llama-index-readers-web firecrawl-py
```

## FirecrawlWebReader

### Basic Usage
```python
from llama_index.readers.web import FirecrawlWebReader

reader = FirecrawlWebReader(
    api_key="fc-YOUR-API-KEY"
)

# Scrape single page
documents = reader.load_data(url="https://example.com/article")

for doc in documents:
    print(doc.text[:200])
    print(doc.metadata)
```

### Scrape Mode
```python
from llama_index.readers.web import FirecrawlWebReader

reader = FirecrawlWebReader(api_key="fc-YOUR-API-KEY")

documents = reader.load_data(
    url="https://example.com",
    mode="scrape"
)
```

### Crawl Mode
```python
documents = reader.load_data(
    url="https://docs.example.com",
    mode="crawl",
    params={"limit": 100}
)

print(f"Loaded {len(documents)} pages")
```

## Building an Index

### Basic Index
```python
from llama_index.readers.web import FirecrawlWebReader
from llama_index.core import VectorStoreIndex

# Load documents
reader = FirecrawlWebReader(api_key="fc-YOUR-API-KEY")
documents = reader.load_data(
    url="https://docs.example.com",
    mode="crawl",
    params={"limit": 50}
)

# Create index
index = VectorStoreIndex.from_documents(documents)

# Query
query_engine = index.as_query_engine()
response = query_engine.query("How do I get started?")
print(response)
```

### With Claude
```python
from llama_index.readers.web import FirecrawlWebReader
from llama_index.core import VectorStoreIndex
from llama_index.llms.anthropic import Anthropic
from llama_index.core import Settings

# Configure Claude
Settings.llm = Anthropic(
    model="claude-sonnet-4-5-20250929",
    api_key="your-anthropic-key"
)

# Load documents
reader = FirecrawlWebReader(api_key="fc-YOUR-API-KEY")
documents = reader.load_data(
    url="https://docs.example.com",
    mode="crawl"
)

# Create index
index = VectorStoreIndex.from_documents(documents)

# Query with Claude
query_engine = index.as_query_engine()
response = query_engine.query("Explain the pricing model")
print(response)
```

## Complete RAG Pipeline

```python
from llama_index.readers.web import FirecrawlWebReader
from llama_index.core import VectorStoreIndex, StorageContext
from llama_index.core.node_parser import SentenceSplitter
from llama_index.vector_stores.chroma import ChromaVectorStore
from llama_index.llms.anthropic import Anthropic
from llama_index.embeddings.voyage import VoyageEmbedding
from llama_index.core import Settings
import chromadb

# Configure settings
Settings.llm = Anthropic(model="claude-sonnet-4-5-20250929")
Settings.embed_model = VoyageEmbedding(
    model_name="voyage-3.5",
    voyage_api_key="your-voyage-key"
)
Settings.node_parser = SentenceSplitter(
    chunk_size=1024,
    chunk_overlap=20
)

# Load documents with Firecrawl
reader = FirecrawlWebReader(api_key="fc-YOUR-API-KEY")
documents = reader.load_data(
    url="https://docs.example.com",
    mode="crawl",
    params={
        "limit": 100,
        "scrapeOptions": {
            "onlyMainContent": True
        }
    }
)

print(f"Loaded {len(documents)} documents")

# Create vector store
chroma_client = chromadb.PersistentClient(path="./chroma_db")
chroma_collection = chroma_client.create_collection("docs")

vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
storage_context = StorageContext.from_defaults(vector_store=vector_store)

# Build index
index = VectorStoreIndex.from_documents(
    documents,
    storage_context=storage_context
)

# Create query engine
query_engine = index.as_query_engine(
    similarity_top_k=5,
    response_mode="compact"
)

# Query
response = query_engine.query("How do I authenticate?")
print(f"Answer: {response}")

# Show sources
for node in response.source_nodes:
    print(f"\nSource: {node.metadata.get('url')}")
    print(f"Content: {node.text[:200]}...")
```

## Crawl Options

### With Path Filtering
```python
documents = reader.load_data(
    url="https://example.com",
    mode="crawl",
    params={
        "includePaths": ["/docs/*", "/api/*"],
        "excludePaths": ["/admin/*"],
        "limit": 100
    }
)
```

### With Scrape Options
```python
documents = reader.load_data(
    url="https://example.com",
    mode="crawl",
    params={
        "limit": 50,
        "scrapeOptions": {
            "formats": ["markdown"],
            "onlyMainContent": True,
            "excludeTags": ["nav", "footer", "aside"]
        }
    }
)
```

## Advanced Examples

### 1. Documentation Chatbot
```python
from llama_index.readers.web import FirecrawlWebReader
from llama_index.core import VectorStoreIndex
from llama_index.core.chat_engine import CondensePlusContextChatEngine
from llama_index.llms.anthropic import Anthropic
from llama_index.core import Settings

# Setup
Settings.llm = Anthropic(model="claude-sonnet-4-5-20250929")

# Load docs
reader = FirecrawlWebReader(api_key="fc-YOUR-API-KEY")
documents = reader.load_data(
    url="https://docs.example.com",
    mode="crawl",
    params={"limit": 200}
)

# Build index
index = VectorStoreIndex.from_documents(documents)

# Create chat engine
chat_engine = index.as_chat_engine(
    chat_mode="condense_plus_context",
    verbose=True
)

# Chat
response1 = chat_engine.chat("What is Firecrawl?")
print(response1)

response2 = chat_engine.chat("How much does it cost?")
print(response2)

# Chat history is maintained
```

### 2. Multi-Document Agent
```python
from llama_index.readers.web import FirecrawlWebReader
from llama_index.core import VectorStoreIndex
from llama_index.core.tools import QueryEngineTool
from llama_index.core.agent import ReActAgent
from llama_index.llms.anthropic import Anthropic

reader = FirecrawlWebReader(api_key="fc-YOUR-API-KEY")

# Load multiple doc sites
firecrawl_docs = reader.load_data(
    url="https://docs.firecrawl.dev",
    mode="crawl",
    params={"limit": 50}
)

langchain_docs = reader.load_data(
    url="https://python.langchain.com",
    mode="crawl",
    params={"limit": 50}
)

# Create indexes
firecrawl_index = VectorStoreIndex.from_documents(firecrawl_docs)
langchain_index = VectorStoreIndex.from_documents(langchain_docs)

# Create tools
tools = [
    QueryEngineTool.from_defaults(
        query_engine=firecrawl_index.as_query_engine(),
        name="firecrawl_docs",
        description="Firecrawl documentation for web scraping"
    ),
    QueryEngineTool.from_defaults(
        query_engine=langchain_index.as_query_engine(),
        name="langchain_docs",
        description="LangChain documentation for LLM apps"
    )
]

# Create agent
llm = Anthropic(model="claude-sonnet-4-5-20250929")
agent = ReActAgent.from_tools(tools, llm=llm, verbose=True)

# Query across docs
response = agent.chat(
    "How do I use Firecrawl with LangChain?"
)
print(response)
```

### 3. Semantic Search with Metadata Filtering
```python
from llama_index.readers.web import FirecrawlWebReader
from llama_index.core import VectorStoreIndex
from llama_index.core.vector_stores import MetadataFilters, ExactMatchFilter

reader = FirecrawlWebReader(api_key="fc-YOUR-API-KEY")
documents = reader.load_data(
    url="https://docs.example.com",
    mode="crawl"
)

index = VectorStoreIndex.from_documents(documents)

# Query with metadata filter
filters = MetadataFilters(
    filters=[
        ExactMatchFilter(key="language", value="en")
    ]
)

query_engine = index.as_query_engine(
    filters=filters,
    similarity_top_k=10
)

response = query_engine.query("API authentication")
print(response)
```

### 4. Persistent Storage
```python
from llama_index.readers.web import FirecrawlWebReader
from llama_index.core import VectorStoreIndex, StorageContext, load_index_from_storage
import os

PERSIST_DIR = "./storage"

# Build index if doesn't exist
if not os.path.exists(PERSIST_DIR):
    # Load documents
    reader = FirecrawlWebReader(api_key="fc-YOUR-API-KEY")
    documents = reader.load_data(
        url="https://docs.example.com",
        mode="crawl",
        params={"limit": 100}
    )
    
    # Create and persist index
    index = VectorStoreIndex.from_documents(documents)
    index.storage_context.persist(persist_dir=PERSIST_DIR)
    print("Index created and saved")
else:
    # Load existing index
    storage_context = StorageContext.from_defaults(persist_dir=PERSIST_DIR)
    index = load_index_from_storage(storage_context)
    print("Index loaded from disk")

# Query
query_engine = index.as_query_engine()
response = query_engine.query("How do I get started?")
print(response)
```

### 5. Streaming Responses
```python
from llama_index.readers.web import FirecrawlWebReader
from llama_index.core import VectorStoreIndex
from llama_index.llms.anthropic import Anthropic
from llama_index.core import Settings

Settings.llm = Anthropic(model="claude-sonnet-4-5-20250929")

reader = FirecrawlWebReader(api_key="fc-YOUR-API-KEY")
documents = reader.load_data(
    url="https://docs.example.com",
    mode="crawl"
)

index = VectorStoreIndex.from_documents(documents)

# Create streaming query engine
query_engine = index.as_query_engine(streaming=True)

# Stream response
response = query_engine.query("Explain the pricing model")

# Print as it streams
for text in response.response_gen:
    print(text, end="", flush=True)
```

## Document Structure

LlamaIndex documents have this structure:

```python
doc = Document(
    text="Page content in markdown...",
    metadata={
        "title": "Page Title",
        "url": "https://example.com/page",
        "statusCode": 200,
        "language": "en"
    }
)
```

## Best Practices

### 1. Limit Crawl Scope
```python
# Good
params={"limit": 100, "includePaths": ["/docs/*"]}

# Bad
params={}  # Could crawl thousands
```

### 2. Use Appropriate Chunk Size
```python
from llama_index.core.node_parser import SentenceSplitter

Settings.node_parser = SentenceSplitter(
    chunk_size=1024,  # Adjust based on model
    chunk_overlap=20
)
```

### 3. Filter Content Early
```python
params={
    "scrapeOptions": {
        "onlyMainContent": True,
        "excludeTags": ["nav", "footer"]
    }
}
```

### 4. Persist Indexes
```python
# Save to disk
index.storage_context.persist(persist_dir="./storage")

# Load later
index = load_index_from_storage(storage_context)
```

## Related Documentation

- [LangChain Integration](./24-langchain.md)
- [AI Assistants](./28-ai-assistants.md)
- [Crawling](./05-crawling.md)
- [Python SDK](./15-python-sdk.md)
