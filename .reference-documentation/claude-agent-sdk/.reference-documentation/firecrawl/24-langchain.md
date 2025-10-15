# Firecrawl - LangChain Integration

**Sources:**
- https://docs.firecrawl.dev/integrations/langchain
- https://python.langchain.com/docs/integrations/document_loaders/firecrawl

**Fetched:** 2025-10-11

## Overview

Firecrawl integrates with LangChain as a document loader for RAG (Retrieval Augmented Generation) systems.

## Installation

```bash
pip install langchain langchain-community firecrawl-py
```

## FirecrawlLoader

### Basic Usage
```python
from langchain_community.document_loaders import FirecrawlLoader

loader = FirecrawlLoader(
    api_key="fc-YOUR-API-KEY",
    url="https://docs.example.com",
    mode="scrape"
)

documents = loader.load()

for doc in documents:
    print(f"Content: {doc.page_content[:200]}...")
    print(f"Metadata: {doc.metadata}")
```

### Scrape Mode
Load single page:

```python
loader = FirecrawlLoader(
    api_key="fc-YOUR-API-KEY",
    url="https://example.com/article",
    mode="scrape"
)

docs = loader.load()
# Returns list with single document
```

### Crawl Mode
Load entire website:

```python
loader = FirecrawlLoader(
    api_key="fc-YOUR-API-KEY",
    url="https://docs.example.com",
    mode="crawl",
    params={
        "limit": 100,
        "includePaths": ["/docs/*"]
    }
)

docs = loader.load()
# Returns list of documents (one per page)
```

## RAG Pipeline

### Complete Example
```python
from langchain_community.document_loaders import FirecrawlLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import OpenAIEmbeddings
from langchain.chains import RetrievalQA
from langchain_community.llms import OpenAI

# 1. Load documents
loader = FirecrawlLoader(
    api_key="fc-YOUR-API-KEY",
    url="https://docs.example.com",
    mode="crawl",
    params={"limit": 50}
)

documents = loader.load()
print(f"Loaded {len(documents)} documents")

# 2. Split into chunks
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)

splits = text_splitter.split_documents(documents)

# 3. Create vector store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(
    documents=splits,
    embedding=embeddings
)

# 4. Create retrieval chain
qa_chain = RetrievalQA.from_chain_type(
    llm=OpenAI(),
    chain_type="stuff",
    retriever=vectorstore.as_retriever()
)

# 5. Query
response = qa_chain.run("How do I authenticate with the API?")
print(response)
```

## With Claude (Anthropic)

```python
from langchain_community.document_loaders import FirecrawlLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import VoyageEmbeddings
from langchain.chains import RetrievalQA
from langchain_anthropic import ChatAnthropic

# Load documents with Firecrawl
loader = FirecrawlLoader(
    api_key="fc-YOUR-API-KEY",
    url="https://docs.example.com",
    mode="crawl"
)

docs = loader.load()

# Split documents
splitter = RecursiveCharacterTextSplitter(
    chunk_size=2000,
    chunk_overlap=200
)

splits = splitter.split_documents(docs)

# Create vector store with Voyage embeddings
embeddings = VoyageEmbeddings(
    voyage_api_key="your-voyage-key",
    model="voyage-3.5"
)

vectorstore = Chroma.from_documents(splits, embeddings)

# Create QA chain with Claude
llm = ChatAnthropic(model="claude-sonnet-4-5-20250929")

qa = RetrievalQA.from_chain_type(
    llm=llm,
    retriever=vectorstore.as_retriever(search_kwargs={"k": 5})
)

# Query
answer = qa.run("Explain the pricing model")
print(answer)
```

## Crawl Options

### Limit Pages
```python
loader = FirecrawlLoader(
    api_key="fc-YOUR-API-KEY",
    url="https://docs.example.com",
    mode="crawl",
    params={"limit": 50}
)
```

### Filter Paths
```python
loader = FirecrawlLoader(
    api_key="fc-YOUR-API-KEY",
    url="https://example.com",
    mode="crawl",
    params={
        "includePaths": ["/blog/*", "/docs/*"],
        "excludePaths": ["/admin/*"]
    }
)
```

### Scrape Options
```python
loader = FirecrawlLoader(
    api_key="fc-YOUR-API-KEY",
    url="https://example.com",
    mode="crawl",
    params={
        "limit": 100,
        "scrapeOptions": {
            "onlyMainContent": True,
            "excludeTags": ["nav", "footer"]
        }
    }
)
```

## Document Structure

Loaded documents have this structure:

```python
doc = {
    "page_content": "# Page Title\n\nContent...",
    "metadata": {
        "title": "Page Title",
        "description": "Description",
        "url": "https://example.com/page",
        "statusCode": 200,
        "language": "en"
    }
}
```

## Complete RAG Examples

### 1. Documentation Chatbot
```python
from langchain_community.document_loaders import FirecrawlLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import OpenAIEmbeddings
from langchain.chains import ConversationalRetrievalChain
from langchain_anthropic import ChatAnthropic

class DocsChatbot:
    def __init__(self, docs_url, firecrawl_key):
        # Load docs
        loader = FirecrawlLoader(
            api_key=firecrawl_key,
            url=docs_url,
            mode="crawl",
            params={"limit": 200}
        )
        
        docs = loader.load()
        
        # Split
        splitter = RecursiveCharacterTextSplitter(
            chunk_size=1500,
            chunk_overlap=200
        )
        
        splits = splitter.split_documents(docs)
        
        # Create vector store
        embeddings = OpenAIEmbeddings()
        self.vectorstore = FAISS.from_documents(splits, embeddings)
        
        # Create chain
        llm = ChatAnthropic(model="claude-sonnet-4-5-20250929")
        self.chain = ConversationalRetrievalChain.from_llm(
            llm=llm,
            retriever=self.vectorstore.as_retriever(search_kwargs={"k": 5}),
            return_source_documents=True
        )
        
        self.chat_history = []
    
    def ask(self, question):
        result = self.chain({
            "question": question,
            "chat_history": self.chat_history
        })
        
        self.chat_history.append((question, result["answer"]))
        
        return {
            "answer": result["answer"],
            "sources": [doc.metadata["url"] for doc in result["source_documents"]]
        }

# Usage
chatbot = DocsChatbot(
    docs_url="https://docs.firecrawl.dev",
    firecrawl_key="fc-YOUR-API-KEY"
)

response = chatbot.ask("How do I scrape a website?")
print(f"Answer: {response['answer']}")
print(f"Sources: {response['sources']}")
```

### 2. Multi-Site Knowledge Base
```python
from langchain_community.document_loaders import FirecrawlLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import OpenAIEmbeddings

def build_knowledge_base(sites, firecrawl_key):
    all_docs = []
    
    for site in sites:
        print(f"Loading {site}...")
        
        loader = FirecrawlLoader(
            api_key=firecrawl_key,
            url=site,
            mode="crawl",
            params={"limit": 50}
        )
        
        docs = loader.load()
        all_docs.extend(docs)
    
    print(f"Loaded {len(all_docs)} total documents")
    
    # Split
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=100
    )
    
    splits = splitter.split_documents(all_docs)
    
    # Create vector store
    embeddings = OpenAIEmbeddings()
    vectorstore = Chroma.from_documents(
        documents=splits,
        embedding=embeddings,
        persist_directory="./knowledge_base"
    )
    
    return vectorstore

# Build from multiple sites
sites = [
    "https://docs.firecrawl.dev",
    "https://docs.langchain.com",
    "https://docs.anthropic.com"
]

kb = build_knowledge_base(sites, "fc-YOUR-API-KEY")
```

### 3. Semantic Search
```python
from langchain_community.document_loaders import FirecrawlLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import OpenAIEmbeddings

# Load and index documentation
loader = FirecrawlLoader(
    api_key="fc-YOUR-API-KEY",
    url="https://docs.example.com",
    mode="crawl"
)

docs = loader.load()

splitter = RecursiveCharacterTextSplitter(chunk_size=1000)
splits = splitter.split_documents(docs)

embeddings = OpenAIEmbeddings()
vectorstore = FAISS.from_documents(splits, embeddings)

# Semantic search
query = "How do I handle rate limits?"
results = vectorstore.similarity_search(query, k=5)

for i, doc in enumerate(results, 1):
    print(f"\n{i}. {doc.metadata['title']}")
    print(f"URL: {doc.metadata['url']}")
    print(f"Content: {doc.page_content[:200]}...")
```

## Best Practices

### 1. Limit Crawl Scope
```python
# Good - targeted crawl
params={"limit": 100, "includePaths": ["/docs/*"]}

# Bad - unlimited crawl
params={}
```

### 2. Filter Content
```python
# Good - clean content
params={
    "scrapeOptions": {
        "onlyMainContent": True,
        "excludeTags": ["nav", "footer"]
    }
}
```

### 3. Use Appropriate Chunk Size
```python
# For Claude with 200K context
chunk_size=2000

# For smaller models
chunk_size=500
```

### 4. Add Metadata Filtering
```python
retriever = vectorstore.as_retriever(
    search_kwargs={
        "k": 5,
        "filter": {"language": "en"}
    }
)
```

## Related Documentation

- [Scraping](./04-scraping.md)
- [Crawling](./05-crawling.md)
- [AI Assistants](./28-ai-assistants.md)
- [Python SDK](./15-python-sdk.md)
