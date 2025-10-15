# LangChain - Retrievers

**Sources:**
- https://python.langchain.com/docs/concepts/retrievers/
- https://python.langchain.com/docs/how_to/#retrievers
- https://js.langchain.com/docs/concepts/retrievers/

**Fetched:** 2025-10-11

## What are Retrievers?

Retrievers **fetch relevant documents** based on a query:

```
Query → Retriever → Relevant Documents
```

**Key interface:**
```python
class Retriever:
    def invoke(self, query: str) -> List[Document]:
        """Retrieve documents for a query."""
        pass
```

## Vector Store Retriever

Most common retriever - wraps a vector store:

**Python:**
```python
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings

# Create vector store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_texts(
    ["Doc 1", "Doc 2", "Doc 3"],
    embeddings
)

# Create retriever
retriever = vectorstore.as_retriever()

# Retrieve
documents = retriever.invoke("query")
```

**TypeScript:**
```typescript
import { Chroma } from "@langchain/community/vectorstores/chroma";
import { OpenAIEmbeddings } from "@langchain/openai";

const embeddings = new OpenAIEmbeddings();
const vectorstore = await Chroma.fromTexts(
  ["Doc 1", "Doc 2", "Doc 3"],
  {},
  embeddings
);

const retriever = vectorstore.asRetriever();
const documents = await retriever.invoke("query");
```

### Search Types

**Python:**
```python
# Similarity search (default)
retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 3}
)

# MMR (Maximal Marginal Relevance) - diverse results
retriever = vectorstore.as_retriever(
    search_type="mmr",
    search_kwargs={"k": 3, "fetch_k": 20}
)

# Similarity score threshold
retriever = vectorstore.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"score_threshold": 0.7, "k": 3}
)
```

### With Metadata Filters

**Python:**
```python
retriever = vectorstore.as_retriever(
    search_kwargs={
        "k": 3,
        "filter": {"category": "technical"}
    }
)

documents = retriever.invoke("query")
```

## Multi-Query Retriever

Generate multiple queries for better retrieval:

**Python:**
```python
from langchain.retrievers import MultiQueryRetriever
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()
base_retriever = vectorstore.as_retriever()

retriever = MultiQueryRetriever.from_llm(
    retriever=base_retriever,
    llm=llm
)

# Generates multiple query variations
documents = retriever.invoke("What is LangChain?")

# Might generate:
# - "What is LangChain?"
# - "Can you explain LangChain?"
# - "Tell me about the LangChain framework"
```

## Contextual Compression

Compress retrieved documents to most relevant parts:

**Python:**
```python
from langchain.retrievers import ContextualCompressionRetriever
from langchain.retrievers.document_compressors import LLMChainExtractor
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()

# Base retriever
base_retriever = vectorstore.as_retriever()

# Compressor - extracts relevant parts
compressor = LLMChainExtractor.from_llm(llm)

# Compression retriever
retriever = ContextualCompressionRetriever(
    base_compressor=compressor,
    base_retriever=base_retriever
)

# Returns compressed documents
documents = retriever.invoke("What is LangChain?")
```

### Embeddings Filter

Filter by relevance:

**Python:**
```python
from langchain.retrievers.document_compressors import EmbeddingsFilter

# Filter out irrelevant documents
embeddings_filter = EmbeddingsFilter(
    embeddings=embeddings,
    similarity_threshold=0.7
)

retriever = ContextualCompressionRetriever(
    base_compressor=embeddings_filter,
    base_retriever=base_retriever
)
```

## Ensemble Retriever

Combine multiple retrievers:

**Python:**
```python
from langchain.retrievers import EnsembleRetriever
from langchain_community.retrievers import BM25Retriever

# Keyword-based retriever
bm25_retriever = BM25Retriever.from_texts(["Doc 1", "Doc 2", "Doc 3"])
bm25_retriever.k = 2

# Semantic retriever
semantic_retriever = vectorstore.as_retriever(search_kwargs={"k": 2})

# Ensemble - combines both
ensemble_retriever = EnsembleRetriever(
    retrievers=[bm25_retriever, semantic_retriever],
    weights=[0.5, 0.5]  # Equal weight
)

documents = ensemble_retriever.invoke("query")
```

## Parent Document Retriever

Retrieve larger context:

**Python:**
```python
from langchain.retrievers import ParentDocumentRetriever
from langchain.storage import InMemoryStore
from langchain.text_splitters import RecursiveCharacterTextSplitter

# Parent splitter (larger chunks)
parent_splitter = RecursiveCharacterTextSplitter(chunk_size=2000)

# Child splitter (smaller chunks for search)
child_splitter = RecursiveCharacterTextSplitter(chunk_size=400)

# Store for parent documents
store = InMemoryStore()

retriever = ParentDocumentRetriever(
    vectorstore=vectorstore,
    docstore=store,
    child_splitter=child_splitter,
    parent_splitter=parent_splitter
)

# Add documents
retriever.add_documents(documents)

# Searches with small chunks, returns large chunks
results = retriever.invoke("query")
```

## Time-Weighted Retriever

Favor recent documents:

**Python:**
```python
from langchain.retrievers import TimeWeightedVectorStoreRetriever
import datetime

retriever = TimeWeightedVectorStoreRetriever(
    vectorstore=vectorstore,
    decay_rate=0.01,  # How quickly relevance decays
    k=3
)

# Add documents with timestamps
retriever.add_documents(
    documents,
    times=[
        datetime.datetime.now() - datetime.timedelta(days=1),
        datetime.datetime.now() - datetime.timedelta(days=7)
    ]
)

# Retrieves recent docs with higher weight
results = retriever.invoke("query")
```

## Self-Query Retriever

Extract metadata filters from natural language:

**Python:**
```python
from langchain.retrievers.self_query.base import SelfQueryRetriever
from langchain.chains.query_constructor.base import AttributeInfo

metadata_field_info = [
    AttributeInfo(
        name="genre",
        description="The genre of the movie",
        type="string"
    ),
    AttributeInfo(
        name="year",
        description="The year the movie was released",
        type="integer"
    )
]

document_content_description = "Brief summary of a movie"

llm = ChatOpenAI()

retriever = SelfQueryRetriever.from_llm(
    llm,
    vectorstore,
    document_content_description,
    metadata_field_info
)

# Query: "I want a comedy from 2020"
# Automatically extracts: filter={genre: "comedy", year: 2020}
results = retriever.invoke("I want a comedy from 2020")
```

## Custom Retriever

**Python:**
```python
from langchain_core.retrievers import BaseRetriever
from langchain_core.documents import Document
from typing import List

class CustomRetriever(BaseRetriever):
    documents: List[Document]
    k: int = 3

    def _get_relevant_documents(
        self,
        query: str,
        *,
        run_manager
    ) -> List[Document]:
        """Custom retrieval logic."""
        # Simple keyword matching example
        relevant = []

        for doc in self.documents:
            if query.lower() in doc.page_content.lower():
                relevant.append(doc)

        return relevant[:self.k]

# Usage
documents = [
    Document(page_content="LangChain is great"),
    Document(page_content="Python is a programming language"),
    Document(page_content="LangChain uses Python")
]

retriever = CustomRetriever(documents=documents, k=2)
results = retriever.invoke("LangChain")
```

## Retriever Chains

### With LCEL

**Python:**
```python
from langchain_core.runnables import RunnablePassthrough

retriever = vectorstore.as_retriever()

# Simple retrieval chain
chain = RunnablePassthrough() | retriever

results = chain.invoke("query")
```

### With Prompt

**Python:**
```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser

prompt = ChatPromptTemplate.from_template("""
Answer based on context:

Context: {context}

Question: {question}
""")

llm = ChatOpenAI()

chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

answer = chain.invoke("What is LangChain?")
```

## Retriever Configuration

### Search Parameters

**Python:**
```python
# Number of documents
retriever = vectorstore.as_retriever(
    search_kwargs={"k": 5}
)

# Score threshold
retriever = vectorstore.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={
        "score_threshold": 0.8,
        "k": 3
    }
)

# MMR parameters
retriever = vectorstore.as_retriever(
    search_type="mmr",
    search_kwargs={
        "k": 3,           # Final results
        "fetch_k": 20,    # Candidates to consider
        "lambda_mult": 0.5  # Diversity factor (0=diverse, 1=similar)
    }
)
```

## Best Practices

### 1. Choose Appropriate Retriever

```python
# Simple use case: Vector store retriever
retriever = vectorstore.as_retriever()

# Need diverse results: MMR
retriever = vectorstore.as_retriever(search_type="mmr")

# Multiple retrieval methods: Ensemble
retriever = EnsembleRetriever(retrievers=[bm25, semantic])

# Complex queries: Multi-query
retriever = MultiQueryRetriever.from_llm(base_retriever, llm)
```

### 2. Set Appropriate K Value

```python
# Good: 3-5 for most use cases
retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

# Avoid: Too many (expensive, noisy)
retriever = vectorstore.as_retriever(search_kwargs={"k": 50})

# Avoid: Too few (might miss relevant docs)
retriever = vectorstore.as_retriever(search_kwargs={"k": 1})
```

### 3. Use Compression for Long Documents

```python
# Good: Compress to relevant parts
compressor = LLMChainExtractor.from_llm(llm)
retriever = ContextualCompressionRetriever(
    base_compressor=compressor,
    base_retriever=base_retriever
)

# Avoid: Returning full long documents
retriever = vectorstore.as_retriever()  # Might return very long docs
```

### 4. Filter When Possible

```python
# Good: Filter by metadata
retriever = vectorstore.as_retriever(
    search_kwargs={
        "k": 3,
        "filter": {"source": "official_docs"}
    }
)
```

### 5. Test Different Retrievers

```python
# Test and compare
retrievers = {
    "basic": vectorstore.as_retriever(),
    "mmr": vectorstore.as_retriever(search_type="mmr"),
    "multi_query": MultiQueryRetriever.from_llm(base_retriever, llm)
}

for name, retriever in retrievers.items():
    docs = retriever.invoke("test query")
    print(f"{name}: {len(docs)} documents")
```

## Performance Tips

### 1. Cache Retrieval Results

```python
from functools import lru_cache

@lru_cache(maxsize=100)
def cached_retrieve(query: str):
    return retriever.invoke(query)
```

### 2. Batch Retrieval

```python
# Retrieve for multiple queries
queries = ["query1", "query2", "query3"]
results = retriever.batch(queries)
```

### 3. Use Async for Parallel Retrieval

```python
import asyncio

async def retrieve_async(queries):
    tasks = [retriever.ainvoke(q) for q in queries]
    results = await asyncio.gather(*tasks)
    return results

queries = ["query1", "query2"]
results = asyncio.run(retrieve_async(queries))
```

## Retriever Comparison

| Retriever | Best For | Pros | Cons |
|-----------|----------|------|------|
| Vector Store | General semantic search | Fast, simple | Single method only |
| Multi-Query | Complex queries | Better recall | Slower, more LLM calls |
| Ensemble | Hybrid search | Combines semantic + keyword | More complex |
| Contextual Compression | Long documents | Returns relevant parts | Slower, needs LLM |
| Parent Document | Need context | Full context | More storage |
| Self-Query | Natural language filters | User-friendly | Complex setup |

## Related Documentation

- [Vector Stores](./19-vector-stores.md)
- [RAG Basics](./21-rag-basics.md)
- [RAG Advanced](./22-rag-advanced.md)
- [Embeddings](./18-embeddings.md)
- [Chains](./25-chains-overview.md)
