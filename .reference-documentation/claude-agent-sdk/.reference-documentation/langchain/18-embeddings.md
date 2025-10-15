# LangChain - Embeddings

**Sources:**
- https://python.langchain.com/docs/concepts/embedding_models/
- https://python.langchain.com/docs/how_to/embed_text/
- https://js.langchain.com/docs/concepts/embedding_models/

**Fetched:** 2025-10-11

## What are Embeddings?

Embeddings are **numerical representations of text** as vectors (lists of numbers):

```python
"Hello world" → [0.123, -0.456, 0.789, ...]  # 1536 dimensions for OpenAI
```

**Why use embeddings:**
- **Semantic search** - Find similar meaning, not just keywords
- **Clustering** - Group similar documents
- **Classification** - Categorize text
- **Recommendations** - Find related content

## OpenAI Embeddings

### Basic Usage

**Python:**
```python
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings(
    model="text-embedding-3-small"  # or text-embedding-3-large
)

# Embed a single text
text = "This is a sample text"
vector = embeddings.embed_query(text)

print(f"Dimensions: {len(vector)}")  # 1536
print(f"First 5 values: {vector[:5]}")
```

**TypeScript:**
```typescript
import { OpenAIEmbeddings } from "@langchain/openai";

const embeddings = new OpenAIEmbeddings({
  model: "text-embedding-3-small"
});

const text = "This is a sample text";
const vector = await embeddings.embedQuery(text);

console.log(`Dimensions: ${vector.length}`);
```

### Embed Multiple Documents

**Python:**
```python
documents = [
    "First document",
    "Second document",
    "Third document"
]

# Batch embed
vectors = embeddings.embed_documents(documents)

print(f"Embedded {len(vectors)} documents")
print(f"Each vector has {len(vectors[0])} dimensions")
```

### Model Options

**Python:**
```python
# Small model (cheap, fast)
small_embeddings = OpenAIEmbeddings(
    model="text-embedding-3-small"  # 1536 dimensions, $0.02/1M tokens
)

# Large model (expensive, better quality)
large_embeddings = OpenAIEmbeddings(
    model="text-embedding-3-large"  # 3072 dimensions, $0.13/1M tokens
)

# Legacy model
ada_embeddings = OpenAIEmbeddings(
    model="text-embedding-ada-002"  # 1536 dimensions
)
```

## Other Embedding Providers

### HuggingFace Embeddings

**Python:**
```python
from langchain_huggingface import HuggingFaceEmbeddings

embeddings = HuggingFaceEmbeddings(
    model_name="sentence-transformers/all-MiniLM-L6-v2"
)

vector = embeddings.embed_query("Sample text")
print(f"Dimensions: {len(vector)}")  # 384
```

**Popular models:**
- `all-MiniLM-L6-v2` - Fast, 384 dimensions
- `all-mpnet-base-v2` - Better quality, 768 dimensions
- `multi-qa-mpnet-base-dot-v1` - Q&A optimized

### Cohere Embeddings

**Python:**
```python
from langchain_cohere import CohereEmbeddings

embeddings = CohereEmbeddings(
    model="embed-english-v3.0",
    cohere_api_key="..."
)

vector = embeddings.embed_query("Sample text")
```

### Voyage AI Embeddings

**Python:**
```python
from langchain_voyageai import VoyageAIEmbeddings

embeddings = VoyageAIEmbeddings(
    model="voyage-2",
    voyage_api_key="..."
)

vector = embeddings.embed_query("Sample text")
```

### Google Vertex AI Embeddings

**Python:**
```python
from langchain_google_vertexai import VertexAIEmbeddings

embeddings = VertexAIEmbeddings(
    model_name="textembedding-gecko@001"
)

vector = embeddings.embed_query("Sample text")
```

### Ollama Embeddings (Local)

**Python:**
```python
from langchain_ollama import OllamaEmbeddings

embeddings = OllamaEmbeddings(
    model="llama2",
    base_url="http://localhost:11434"
)

vector = embeddings.embed_query("Sample text")
```

## Embedding Documents

### From Loader to Embeddings

**Python:**
```python
from langchain_community.document_loaders import TextLoader
from langchain.text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings

# Load
loader = TextLoader("document.txt")
documents = loader.load()

# Split
splitter = RecursiveCharacterTextSplitter(chunk_size=1000)
splits = splitter.split_documents(documents)

# Embed
embeddings = OpenAIEmbeddings()

# Get embeddings for all splits
texts = [doc.page_content for doc in splits]
vectors = embeddings.embed_documents(texts)

print(f"Created {len(vectors)} embeddings")
```

## Caching Embeddings

### In-Memory Cache

**Python:**
```python
from langchain.embeddings import CacheBackedEmbeddings
from langchain.storage import InMemoryStore

# Underlying embeddings
underlying_embeddings = OpenAIEmbeddings()

# Create cache
store = InMemoryStore()

# Cached embeddings
cached_embeddings = CacheBackedEmbeddings.from_bytes_store(
    underlying_embeddings,
    store,
    namespace="my_embeddings"
)

# First call - hits API
vector1 = cached_embeddings.embed_query("Hello")

# Second call - uses cache
vector2 = cached_embeddings.embed_query("Hello")
```

### File System Cache

**Python:**
```python
from langchain.storage import LocalFileStore

# File-based cache
store = LocalFileStore("./embeddings_cache")

cached_embeddings = CacheBackedEmbeddings.from_bytes_store(
    underlying_embeddings,
    store,
    namespace="my_embeddings"
)
```

### Redis Cache

**Python:**
```python
from langchain.storage import RedisStore
import redis

# Redis cache
redis_client = redis.Redis(host='localhost', port=6379)
store = RedisStore(redis_client=redis_client)

cached_embeddings = CacheBackedEmbeddings.from_bytes_store(
    underlying_embeddings,
    store,
    namespace="my_embeddings"
)
```

## Similarity Search

### Cosine Similarity

**Python:**
```python
import numpy as np

def cosine_similarity(vec1, vec2):
    """Calculate cosine similarity between two vectors."""
    dot_product = np.dot(vec1, vec2)
    norm1 = np.linalg.norm(vec1)
    norm2 = np.linalg.norm(vec2)
    return dot_product / (norm1 * norm2)

# Example
embeddings = OpenAIEmbeddings()

query_vector = embeddings.embed_query("Python programming")
doc1_vector = embeddings.embed_query("Learn Python coding")
doc2_vector = embeddings.embed_query("Cooking recipes")

sim1 = cosine_similarity(query_vector, doc1_vector)
sim2 = cosine_similarity(query_vector, doc2_vector)

print(f"Similarity to doc1: {sim1}")  # Higher
print(f"Similarity to doc2: {sim2}")  # Lower
```

### Finding Most Similar

**Python:**
```python
def find_most_similar(query, documents, embeddings, top_k=3):
    """Find top K most similar documents."""
    # Embed query
    query_vector = embeddings.embed_query(query)

    # Embed documents
    doc_vectors = embeddings.embed_documents(documents)

    # Calculate similarities
    similarities = []
    for i, doc_vector in enumerate(doc_vectors):
        similarity = cosine_similarity(query_vector, doc_vector)
        similarities.append((i, similarity))

    # Sort by similarity
    similarities.sort(key=lambda x: x[1], reverse=True)

    # Return top K
    return [(documents[i], sim) for i, sim in similarities[:top_k]]

# Usage
query = "machine learning"
documents = [
    "Introduction to neural networks",
    "Cooking pasta recipes",
    "Deep learning fundamentals",
    "Gardening tips"
]

results = find_most_similar(query, documents, embeddings)

for doc, sim in results:
    print(f"{sim:.3f}: {doc}")
```

## Batch Processing

**Python:**
```python
def embed_in_batches(texts, embeddings, batch_size=100):
    """Embed texts in batches to avoid rate limits."""
    all_vectors = []

    for i in range(0, len(texts), batch_size):
        batch = texts[i:i + batch_size]
        vectors = embeddings.embed_documents(batch)
        all_vectors.extend(vectors)

        print(f"Embedded {len(all_vectors)}/{len(texts)}")

        # Optional: add delay to avoid rate limits
        import time
        time.sleep(1)

    return all_vectors

# Usage
large_text_list = [...]  # 1000s of texts
vectors = embed_in_batches(large_text_list, embeddings, batch_size=50)
```

## Best Practices

### 1. Choose Appropriate Model

```python
# For Q&A / semantic search
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")

# For high accuracy needs
embeddings = OpenAIEmbeddings(model="text-embedding-3-large")

# For cost optimization (local)
embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
```

### 2. Use Caching

```python
# Good: Cache embeddings
from langchain.embeddings import CacheBackedEmbeddings
from langchain.storage import InMemoryStore

store = InMemoryStore()
cached_embeddings = CacheBackedEmbeddings.from_bytes_store(
    OpenAIEmbeddings(),
    store
)

# Avoid: Re-embedding same text
embeddings = OpenAIEmbeddings()
vector1 = embeddings.embed_query("same text")  # API call
vector2 = embeddings.embed_query("same text")  # Another API call
```

### 3. Batch When Possible

```python
# Good: Batch embed
documents = ["doc1", "doc2", "doc3"]
vectors = embeddings.embed_documents(documents)

# Avoid: Individual embeds
vectors = [embeddings.embed_query(doc) for doc in documents]
```

### 4. Handle Errors

```python
def safe_embed(text, embeddings):
    """Embed with error handling."""
    try:
        return embeddings.embed_query(text)
    except Exception as e:
        print(f"Error embedding: {e}")
        return None

vector = safe_embed("text", embeddings)
if vector:
    # Use vector
    pass
```

### 5. Normalize Text

```python
def normalize_text(text):
    """Normalize before embedding."""
    # Lowercase
    text = text.lower()

    # Remove extra whitespace
    text = " ".join(text.split())

    # Remove special characters
    text = re.sub(r'[^\w\s]', '', text)

    return text

# Good: Normalize first
clean_text = normalize_text(text)
vector = embeddings.embed_query(clean_text)
```

## Embedding Comparison

| Provider | Model | Dimensions | Cost (per 1M tokens) | Quality |
|----------|-------|------------|----------------------|---------|
| OpenAI | text-embedding-3-small | 1536 | $0.02 | Good |
| OpenAI | text-embedding-3-large | 3072 | $0.13 | Excellent |
| Cohere | embed-english-v3.0 | 1024 | $0.10 | Excellent |
| Voyage AI | voyage-2 | 1024 | $0.10 | Excellent |
| HuggingFace | all-MiniLM-L6-v2 | 384 | Free (local) | Good |
| HuggingFace | all-mpnet-base-v2 | 768 | Free (local) | Very Good |
| Ollama | llama2 | Varies | Free (local) | Good |

## Use Cases

### 1. Semantic Search

```python
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS

embeddings = OpenAIEmbeddings()

# Index documents
documents = ["Doc 1", "Doc 2", "Doc 3"]
vectorstore = FAISS.from_texts(documents, embeddings)

# Search
results = vectorstore.similarity_search("query", k=2)
```

### 2. Document Clustering

```python
from sklearn.cluster import KMeans
import numpy as np

# Embed documents
docs = ["Doc 1", "Doc 2", "Doc 3", ...]
vectors = embeddings.embed_documents(docs)

# Cluster
kmeans = KMeans(n_clusters=3)
clusters = kmeans.fit_predict(vectors)

print(f"Document clusters: {clusters}")
```

### 3. Duplicate Detection

```python
def find_duplicates(documents, embeddings, threshold=0.95):
    """Find duplicate documents using embeddings."""
    vectors = embeddings.embed_documents(documents)
    duplicates = []

    for i in range(len(vectors)):
        for j in range(i + 1, len(vectors)):
            similarity = cosine_similarity(vectors[i], vectors[j])
            if similarity > threshold:
                duplicates.append((i, j, similarity))

    return duplicates

duplicates = find_duplicates(documents, embeddings)
print(f"Found {len(duplicates)} duplicates")
```

### 4. Classification

```python
# Training examples with labels
examples = [
    ("Python tutorial", "programming"),
    ("Cooking recipe", "food"),
    ("Machine learning", "programming"),
    ("Pasta dish", "food")
]

# Embed training data
train_vectors = embeddings.embed_documents([ex[0] for ex in examples])
labels = [ex[1] for ex in examples]

# Classify new text
new_text = "JavaScript guide"
new_vector = embeddings.embed_query(new_text)

# Find most similar
similarities = [cosine_similarity(new_vector, tv) for tv in train_vectors]
most_similar_idx = np.argmax(similarities)

predicted_label = labels[most_similar_idx]
print(f"Predicted: {predicted_label}")
```

## Performance Tips

### 1. Use Smaller Models for Development

```python
# Development: Fast and cheap
dev_embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")

# Production: Better quality
prod_embeddings = OpenAIEmbeddings(model="text-embedding-3-large")
```

### 2. Batch and Cache

```python
from langchain.embeddings import CacheBackedEmbeddings
from langchain.storage import LocalFileStore

store = LocalFileStore("./cache")
cached_embeddings = CacheBackedEmbeddings.from_bytes_store(
    OpenAIEmbeddings(),
    store
)

# Batch embed
texts = [...]
vectors = cached_embeddings.embed_documents(texts)  # Cached after first run
```

### 3. Use Async for Multiple Queries

```python
import asyncio

async def embed_async(texts, embeddings):
    """Async embedding."""
    tasks = [embeddings.aembed_query(text) for text in texts]
    vectors = await asyncio.gather(*tasks)
    return vectors

# Usage
texts = ["text1", "text2", "text3"]
vectors = asyncio.run(embed_async(texts, embeddings))
```

## Related Documentation

- [Vector Stores](./19-vector-stores.md)
- [Retrievers](./20-retrievers.md)
- [RAG Basics](./21-rag-basics.md)
- [Document Loaders](./15-document-loaders.md)
- [Text Splitters](./16-text-splitters.md)
