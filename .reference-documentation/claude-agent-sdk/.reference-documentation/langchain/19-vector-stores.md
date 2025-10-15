# LangChain - Vector Stores

**Sources:**
- https://python.langchain.com/docs/concepts/vectorstores/
- https://python.langchain.com/docs/integrations/vectorstores/
- https://js.langchain.com/docs/integrations/vectorstores/

**Fetched:** 2025-10-11

## What are Vector Stores?

Vector stores **store and search embeddings** efficiently:

```
Text → Embeddings → Vector Store → Similarity Search
```

**Key capabilities:**
- Store document embeddings
- Fast similarity search
- Metadata filtering
- Hybrid search (keyword + semantic)

## Chroma (Local)

Fast, in-memory/persistent vector database:

**Python:**
```python
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()

# From texts
texts = [
    "LangChain is a framework for LLM applications",
    "It supports chains, agents, and retrieval",
    "Vector stores enable semantic search"
]

vectorstore = Chroma.from_texts(
    texts,
    embeddings,
    collection_name="my_collection"
)

# Search
results = vectorstore.similarity_search("What is LangChain?", k=2)

for doc in results:
    print(doc.page_content)
```

**TypeScript:**
```typescript
import { Chroma } from "@langchain/community/vectorstores/chroma";
import { OpenAIEmbeddings } from "@langchain/openai";

const embeddings = new OpenAIEmbeddings();

const texts = [
  "LangChain is a framework for LLM applications",
  "It supports chains, agents, and retrieval"
];

const vectorstore = await Chroma.fromTexts(
  texts,
  {},
  embeddings,
  { collectionName: "my_collection" }
);

const results = await vectorstore.similaritySearch("What is LangChain?", 2);
```

### Persistent Chroma

**Python:**
```python
# Save to disk
vectorstore = Chroma.from_texts(
    texts,
    embeddings,
    persist_directory="./chroma_db"
)

# Load from disk
vectorstore = Chroma(
    persist_directory="./chroma_db",
    embedding_function=embeddings
)
```

### From Documents

**Python:**
```python
from langchain_community.document_loaders import TextLoader
from langchain.text_splitters import RecursiveCharacterTextSplitter

# Load and split
loader = TextLoader("document.txt")
documents = loader.load()

splitter = RecursiveCharacterTextSplitter(chunk_size=1000)
splits = splitter.split_documents(documents)

# Create vector store
vectorstore = Chroma.from_documents(
    splits,
    embeddings,
    persist_directory="./chroma_db"
)
```

## FAISS (Facebook AI)

High-performance similarity search:

**Python:**
```python
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()

# Create
vectorstore = FAISS.from_texts(
    texts,
    embeddings
)

# Search
results = vectorstore.similarity_search("query", k=3)

# Save
vectorstore.save_local("faiss_index")

# Load
vectorstore = FAISS.load_local(
    "faiss_index",
    embeddings,
    allow_dangerous_deserialization=True
)
```

## Pinecone (Cloud)

Managed vector database:

**Python:**
```python
from langchain_pinecone import PineconeVectorStore
from langchain_openai import OpenAIEmbeddings
from pinecone import Pinecone, ServerlessSpec

# Initialize Pinecone
pc = Pinecone(api_key="your-api-key")

# Create index (one-time setup)
index_name = "langchain-index"

if index_name not in pc.list_indexes().names():
    pc.create_index(
        name=index_name,
        dimension=1536,  # OpenAI embedding dimension
        metric="cosine",
        spec=ServerlessSpec(cloud="aws", region="us-east-1")
    )

# Create vector store
embeddings = OpenAIEmbeddings()

vectorstore = PineconeVectorStore.from_texts(
    texts,
    embeddings,
    index_name=index_name
)

# Search
results = vectorstore.similarity_search("query", k=3)
```

**TypeScript:**
```typescript
import { PineconeStore } from "@langchain/pinecone";
import { OpenAIEmbeddings } from "@langchain/openai";
import { Pinecone } from "@pinecone-database/pinecone";

const pinecone = new Pinecone({ apiKey: "your-api-key" });
const index = pinecone.Index("langchain-index");

const embeddings = new OpenAIEmbeddings();

const vectorstore = await PineconeStore.fromTexts(
  texts,
  {},
  embeddings,
  { pineconeIndex: index }
);
```

## Qdrant

Open-source vector search engine:

**Python:**
```python
from langchain_qdrant import QdrantVectorStore
from langchain_openai import OpenAIEmbeddings
from qdrant_client import QdrantClient

# Local Qdrant
client = QdrantClient(path="./qdrant_db")

# Or cloud Qdrant
# client = QdrantClient(url="https://...", api_key="...")

embeddings = OpenAIEmbeddings()

vectorstore = QdrantVectorStore.from_texts(
    texts,
    embeddings,
    client=client,
    collection_name="my_collection"
)

# Search
results = vectorstore.similarity_search("query", k=3)
```

## Weaviate

GraphQL-based vector database:

**Python:**
```python
from langchain_weaviate import WeaviateVectorStore
from langchain_openai import OpenAIEmbeddings
import weaviate

# Connect to Weaviate
client = weaviate.Client(
    url="http://localhost:8080"
)

embeddings = OpenAIEmbeddings()

vectorstore = WeaviateVectorStore.from_texts(
    texts,
    embeddings,
    client=client,
    index_name="LangChain"
)

# Search
results = vectorstore.similarity_search("query", k=3)
```

## Similarity Search Methods

### Basic Similarity Search

**Python:**
```python
# Top K most similar
results = vectorstore.similarity_search(
    "What is LangChain?",
    k=3  # Return top 3
)

for doc in results:
    print(doc.page_content)
    print(doc.metadata)
```

### Similarity Search with Score

**Python:**
```python
# Get similarity scores
results = vectorstore.similarity_search_with_score(
    "What is LangChain?",
    k=3
)

for doc, score in results:
    print(f"Score: {score:.3f}")
    print(doc.page_content)
```

### Similarity Search with Relevance Scores

**Python:**
```python
# Normalized relevance scores (0-1)
results = vectorstore.similarity_search_with_relevance_scores(
    "What is LangChain?",
    k=3
)

for doc, score in results:
    print(f"Relevance: {score:.3f}")
    print(doc.page_content)
```

### MMR Search

Maximal Marginal Relevance - diverse results:

**Python:**
```python
# MMR search for diversity
results = vectorstore.max_marginal_relevance_search(
    "What is LangChain?",
    k=3,
    fetch_k=20  # Fetch 20, return diverse 3
)
```

## Metadata Filtering

Filter by document metadata:

**Python:**
```python
from langchain_core.documents import Document

# Add documents with metadata
documents = [
    Document(
        page_content="Python tutorial",
        metadata={"language": "python", "level": "beginner"}
    ),
    Document(
        page_content="Advanced Python",
        metadata={"language": "python", "level": "advanced"}
    ),
    Document(
        page_content="JavaScript guide",
        metadata={"language": "javascript", "level": "beginner"}
    )
]

vectorstore = Chroma.from_documents(documents, embeddings)

# Search with filter
results = vectorstore.similarity_search(
    "programming tutorial",
    k=2,
    filter={"language": "python"}  # Only Python docs
)
```

**Advanced filtering:**
```python
# Multiple conditions
results = vectorstore.similarity_search(
    "tutorial",
    k=2,
    filter={
        "language": "python",
        "level": "beginner"
    }
)

# Operator-based (provider-specific)
results = vectorstore.similarity_search(
    "tutorial",
    k=2,
    filter={
        "$and": [
            {"language": {"$eq": "python"}},
            {"level": {"$in": ["beginner", "intermediate"]}}
        ]
    }
)
```

## Adding and Deleting Documents

### Add Documents

**Python:**
```python
# Add more documents
new_docs = [
    Document(page_content="New content 1"),
    Document(page_content="New content 2")
]

ids = vectorstore.add_documents(new_docs)
print(f"Added documents with IDs: {ids}")
```

### Add Texts

**Python:**
```python
# Add texts directly
new_texts = ["Text 1", "Text 2"]
metadatas = [{"source": "manual"}, {"source": "manual"}]

ids = vectorstore.add_texts(
    new_texts,
    metadatas=metadatas
)
```

### Delete Documents

**Python:**
```python
# Delete by IDs
vectorstore.delete(ids=["id1", "id2"])

# Delete all (Chroma)
vectorstore.delete_collection()
```

## As Retriever

Convert vector store to retriever interface:

**Python:**
```python
# Basic retriever
retriever = vectorstore.as_retriever()

# Retrieve documents
docs = retriever.invoke("What is LangChain?")

# Configured retriever
retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 3}
)

# MMR retriever
retriever = vectorstore.as_retriever(
    search_type="mmr",
    search_kwargs={"k": 3, "fetch_k": 20}
)

# Similarity score threshold
retriever = vectorstore.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"score_threshold": 0.5, "k": 3}
)
```

## Complete RAG Example

**Python:**
```python
from langchain_community.document_loaders import TextLoader
from langchain.text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_community.vectorstores import Chroma
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser

# 1. Load documents
loader = TextLoader("document.txt")
documents = loader.load()

# 2. Split
splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = splitter.split_documents(documents)

# 3. Create vector store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(splits, embeddings)

# 4. Create retriever
retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

# 5. Create RAG chain
prompt = ChatPromptTemplate.from_template("""
Answer the question based on the context:

Context: {context}

Question: {question}

Answer:""")

llm = ChatOpenAI()

chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

# 6. Query
answer = chain.invoke("What is this document about?")
print(answer)
```

## Best Practices

### 1. Choose Right Vector Store

```python
# Development / Prototyping
vectorstore = Chroma(...)  # Fast, local, easy

# Production with moderate scale
vectorstore = FAISS(...)  # Fast, cost-effective

# Production at scale
vectorstore = Pinecone(...)  # Managed, scalable
vectorstore = Qdrant(...)    # Scalable, self-hosted option
```

### 2. Use Metadata

```python
# Good: Rich metadata
Document(
    page_content="content",
    metadata={
        "source": "file.pdf",
        "page": 1,
        "author": "Alice",
        "date": "2024-01-15"
    }
)

# Avoid: No metadata
Document(page_content="content")
```

### 3. Batch Operations

```python
# Good: Batch add
vectorstore.add_documents(documents)  # Single operation

# Avoid: Individual adds
for doc in documents:
    vectorstore.add_documents([doc])  # Multiple operations
```

### 4. Use Appropriate K Value

```python
# Good: Reasonable K
results = vectorstore.similarity_search("query", k=3)  # 3-5 is typical

# Avoid: Too many results
results = vectorstore.similarity_search("query", k=50)  # Probably too many
```

### 5. Filter When Possible

```python
# Good: Filter to reduce search space
results = vectorstore.similarity_search(
    "query",
    k=3,
    filter={"category": "technical"}
)

# Avoid: Search everything then filter
all_results = vectorstore.similarity_search("query", k=100)
filtered = [r for r in all_results if r.metadata.get("category") == "technical"]
```

## Vector Store Comparison

| Vector Store | Type | Scalability | Cost | Best For |
|--------------|------|-------------|------|----------|
| Chroma | Local/Cloud | Medium | Free (local) | Development, prototyping |
| FAISS | Local | High | Free | Production, on-premise |
| Pinecone | Cloud | Very High | Paid | Production at scale |
| Qdrant | Local/Cloud | Very High | Free/Paid | Production, hybrid |
| Weaviate | Local/Cloud | High | Free/Paid | Graph + vector needs |

## Performance Tips

### 1. Reuse Vector Store

```python
# Good: Create once, reuse
vectorstore = Chroma.from_documents(documents, embeddings)
retriever = vectorstore.as_retriever()

# Use retriever multiple times
result1 = retriever.invoke("query1")
result2 = retriever.invoke("query2")

# Avoid: Recreating
for query in queries:
    vectorstore = Chroma.from_documents(documents, embeddings)  # Wasteful
    results = vectorstore.similarity_search(query)
```

### 2. Persist Vector Store

```python
# Good: Persist to disk
vectorstore = Chroma.from_documents(
    documents,
    embeddings,
    persist_directory="./db"
)

# Load later
vectorstore = Chroma(persist_directory="./db", embedding_function=embeddings)

# Avoid: Rebuilding every time
for session in sessions:
    vectorstore = Chroma.from_documents(documents, embeddings)  # Slow
```

### 3. Use Batching for Large Datasets

```python
# Good: Batch processing
batch_size = 100

for i in range(0, len(documents), batch_size):
    batch = documents[i:i + batch_size]
    vectorstore.add_documents(batch)
```

## Related Documentation

- [Embeddings](./18-embeddings.md)
- [Retrievers](./20-retrievers.md)
- [RAG Basics](./21-rag-basics.md)
- [RAG Advanced](./22-rag-advanced.md)
- [Document Loaders](./15-document-loaders.md)
- [Text Splitters](./16-text-splitters.md)
