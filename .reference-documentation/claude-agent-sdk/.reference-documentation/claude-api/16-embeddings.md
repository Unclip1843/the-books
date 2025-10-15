# Claude API - Embeddings

**Sources:**
- https://docs.claude.com/en/docs/build-with-claude/embeddings
- https://www.voyageai.com/

**Fetched:** 2025-10-11

## Overview

Text embeddings are numerical representations of text that enable semantic similarity comparisons. While **Claude itself does not provide embeddings**, Anthropic recommends **Voyage AI** as the preferred embeddings provider.

## What are Embeddings?

Embeddings convert text into dense vectors (arrays of numbers) that capture semantic meaning:

```
"cat" → [0.2, 0.8, -0.3, ...]
"dog" → [0.3, 0.7, -0.2, ...]  (similar vector - both animals)
"car" → [-0.5, 0.1, 0.9, ...]  (different vector)
```

### Use Cases

✅ **Semantic Search** - Find relevant documents
✅ **Recommendations** - Similar items/content
✅ **Clustering** - Group related content
✅ **Classification** - Categorize text
✅ **Anomaly Detection** - Find outliers
✅ **RAG Systems** - Retrieval Augmented Generation

## Why Voyage AI?

Anthropic recommends Voyage AI because:

- **High Quality** - State-of-the-art embedding models
- **Domain-Specific Models** - Specialized for code, finance, legal
- **Flexible** - Multiple model sizes and dimensions
- **Well-Integrated** - Works seamlessly with Claude workflows

## Voyage AI Models

### General Purpose Models

| Model | Description | Context | Dimensions |
|-------|-------------|---------|------------|
| `voyage-3-large` | Best overall quality | 32K tokens | 1024 (default) |
| `voyage-3.5` | Balanced performance | 32K tokens | 1024 (default) |
| `voyage-3.5-lite` | Lowest latency/cost | 32K tokens | 1024 (default) |

### Domain-Specific Models

| Model | Domain | Context | Dimensions |
|-------|--------|---------|------------|
| `voyage-code-3` | Code & technical | 32K tokens | 1024 |
| `voyage-finance-2` | Finance & business | 32K tokens | 1024 |
| `voyage-law-2` | Legal documents | 32K tokens | 1024 |

### Dimension Options

All models support:
- 256 dimensions (compact)
- 512 dimensions (balanced)
- 1024 dimensions (default, best quality)
- 2048 dimensions (maximum quality)

## Python Implementation

### Installation

```bash
pip install voyageai
```

### Basic Usage

```python
import voyageai

client = voyageai.Client(api_key="your-voyage-api-key")

# Generate embeddings
texts = [
    "Machine learning is a subset of artificial intelligence",
    "Deep learning uses neural networks",
    "Natural language processing enables computers to understand text"
]

result = client.embed(
    texts,
    model="voyage-3.5",
    input_type="document"
)

# Access embeddings
for i, embedding in enumerate(result.embeddings):
    print(f"Text {i}: {len(embedding)} dimensions")
    print(f"First 5 values: {embedding[:5]}")
```

### With Different Dimensions

```python
# Compact embeddings (faster, less storage)
result = client.embed(
    texts,
    model="voyage-3.5",
    input_type="document",
    output_dimension=256
)

print(f"Embedding dimension: {len(result.embeddings[0])}")  # 256
```

### Domain-Specific Models

```python
# For code
code_texts = [
    "def fibonacci(n): return n if n <= 1 else fibonacci(n-1) + fibonacci(n-2)",
    "function factorial(n) { return n <= 1 ? 1 : n * factorial(n-1); }"
]

code_embeddings = client.embed(
    code_texts,
    model="voyage-code-3",
    input_type="document"
)

# For finance
financial_texts = [
    "Q3 revenue increased 15% YoY to $2.5B",
    "EBITDA margins improved to 23.5% from 21.2%"
]

finance_embeddings = client.embed(
    financial_texts,
    model="voyage-finance-2",
    input_type="document"
)
```

## Input Types

Specify `input_type` for optimized embeddings:

```python
# For documents (to be searched)
doc_embeddings = client.embed(
    documents,
    model="voyage-3.5",
    input_type="document"
)

# For queries (to search with)
query_embeddings = client.embed(
    queries,
    model="voyage-3.5",
    input_type="query"
)
```

## Semantic Search

### Building a Search System

```python
import numpy as np
from voyageai import Client

class SemanticSearch:
    def __init__(self, model="voyage-3.5"):
        self.client = Client()
        self.model = model
        self.documents = []
        self.embeddings = []

    def add_documents(self, documents):
        """Add documents to search index"""
        self.documents.extend(documents)

        # Generate embeddings
        result = self.client.embed(
            documents,
            model=self.model,
            input_type="document"
        )

        self.embeddings.extend(result.embeddings)

    def search(self, query, top_k=5):
        """Search for similar documents"""
        # Embed query
        query_result = self.client.embed(
            [query],
            model=self.model,
            input_type="query"
        )
        query_embedding = query_result.embeddings[0]

        # Calculate similarities
        similarities = []
        for i, doc_embedding in enumerate(self.embeddings):
            similarity = np.dot(query_embedding, doc_embedding)
            similarities.append((i, similarity))

        # Sort by similarity
        similarities.sort(key=lambda x: x[1], reverse=True)

        # Return top k
        results = []
        for i, score in similarities[:top_k]:
            results.append({
                "document": self.documents[i],
                "score": score
            })

        return results

# Usage
search = SemanticSearch()

documents = [
    "Python is a high-level programming language",
    "Machine learning algorithms can learn from data",
    "Neural networks are inspired by the human brain",
    "JavaScript is used for web development",
    "Cloud computing provides on-demand resources"
]

search.add_documents(documents)

results = search.search("What is AI?", top_k=3)
for result in results:
    print(f"Score: {result['score']:.3f} - {result['document']}")
```

## RAG with Claude and Voyage

### Complete RAG System

```python
import anthropic
import voyageai
import numpy as np

class RAGSystem:
    def __init__(self):
        self.claude_client = anthropic.Anthropic()
        self.voyage_client = voyageai.Client()
        self.knowledge_base = []
        self.embeddings = []

    def ingest_documents(self, documents):
        """Add documents to knowledge base"""
        self.knowledge_base.extend(documents)

        # Generate embeddings
        result = self.voyage_client.embed(
            documents,
            model="voyage-3.5",
            input_type="document"
        )

        self.embeddings.extend(result.embeddings)

    def retrieve(self, query, top_k=3):
        """Retrieve relevant documents"""
        # Embed query
        query_result = self.voyage_client.embed(
            [query],
            model="voyage-3.5",
            input_type="query"
        )
        query_embedding = query_result.embeddings[0]

        # Find most similar
        similarities = [
            (i, np.dot(query_embedding, emb))
            for i, emb in enumerate(self.embeddings)
        ]
        similarities.sort(key=lambda x: x[1], reverse=True)

        return [self.knowledge_base[i] for i, _ in similarities[:top_k]]

    def answer(self, question):
        """Answer question using RAG"""
        # Retrieve relevant docs
        relevant_docs = self.retrieve(question)

        # Build context
        context = "\n\n".join([
            f"Document {i+1}:\n{doc}"
            for i, doc in enumerate(relevant_docs)
        ])

        # Ask Claude
        message = self.claude_client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            system="Answer questions based on the provided documents.",
            messages=[{
                "role": "user",
                "content": f"""Context:
{context}

Question: {question}"""
            }]
        )

        return message.content[0].text

# Usage
rag = RAGSystem()

# Ingest knowledge
documents = [
    "Claude is an AI assistant created by Anthropic",
    "Claude can understand and generate text, analyze images, and use tools",
    "Claude Sonnet 4.5 is optimized for complex reasoning and coding",
    "The Claude API uses a Messages endpoint for interactions"
]

rag.ingest_documents(documents)

# Ask questions
answer = rag.answer("What is Claude good at?")
print(answer)
```

## Cosine Similarity

Calculate similarity between embeddings:

```python
import numpy as np

def cosine_similarity(embedding1, embedding2):
    """Calculate cosine similarity between two embeddings"""
    dot_product = np.dot(embedding1, embedding2)
    norm1 = np.linalg.norm(embedding1)
    norm2 = np.linalg.norm(embedding2)
    return dot_product / (norm1 * norm2)

# Example
texts = ["cat", "dog", "car"]
result = client.embed(texts, model="voyage-3.5", input_type="document")

sim_cat_dog = cosine_similarity(result.embeddings[0], result.embeddings[1])
sim_cat_car = cosine_similarity(result.embeddings[0], result.embeddings[2])

print(f"cat-dog similarity: {sim_cat_dog:.3f}")  # High
print(f"cat-car similarity: {sim_cat_car:.3f}")  # Low
```

## Clustering

Group similar documents:

```python
from sklearn.cluster import KMeans
import numpy as np

def cluster_documents(documents, n_clusters=3):
    """Cluster documents by similarity"""
    # Get embeddings
    result = client.embed(
        documents,
        model="voyage-3.5",
        input_type="document"
    )

    embeddings = np.array(result.embeddings)

    # Cluster
    kmeans = KMeans(n_clusters=n_clusters)
    labels = kmeans.fit_predict(embeddings)

    # Group by cluster
    clusters = {i: [] for i in range(n_clusters)}
    for doc, label in zip(documents, labels):
        clusters[label].append(doc)

    return clusters

# Usage
documents = [
    "Python programming tutorial",
    "JavaScript web development",
    "Machine learning algorithms",
    "Deep learning with PyTorch",
    "React.js components",
    "Neural network training"
]

clusters = cluster_documents(documents, n_clusters=2)

for cluster_id, docs in clusters.items():
    print(f"\nCluster {cluster_id}:")
    for doc in docs:
        print(f"  - {doc}")
```

## Caching Embeddings

Save compute and costs:

```python
import json
import hashlib

class EmbeddingCache:
    def __init__(self, cache_file="embeddings_cache.json"):
        self.cache_file = cache_file
        self.cache = self.load_cache()
        self.client = voyageai.Client()

    def load_cache(self):
        try:
            with open(self.cache_file, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {}

    def save_cache(self):
        with open(self.cache_file, 'w') as f:
            json.dump(self.cache, f)

    def get_embedding(self, text, model="voyage-3.5"):
        """Get embedding with caching"""
        # Create cache key
        cache_key = hashlib.md5(f"{model}:{text}".encode()).hexdigest()

        if cache_key in self.cache:
            return self.cache[cache_key]

        # Generate new embedding
        result = self.client.embed([text], model=model, input_type="document")
        embedding = result.embeddings[0]

        # Cache it
        self.cache[cache_key] = embedding
        self.save_cache()

        return embedding
```

## Best Practices

### 1. Use Appropriate Model

```python
# For general text
general_embeddings = client.embed(texts, model="voyage-3.5")

# For code
code_embeddings = client.embed(code, model="voyage-code-3")

# For legal docs
legal_embeddings = client.embed(legal_docs, model="voyage-law-2")
```

### 2. Batch Embeddings

```python
# Good - batch processing
result = client.embed(many_texts, model="voyage-3.5")

# Bad - individual requests
for text in many_texts:
    result = client.embed([text], model="voyage-3.5")  # Slow!
```

### 3. Choose Right Dimension

```python
# Fast retrieval, less storage
lightweight = client.embed(texts, model="voyage-3.5", output_dimension=256)

# Better quality
high_quality = client.embed(texts, model="voyage-3.5", output_dimension=1024)
```

### 4. Normalize for Cosine Similarity

```python
def normalize_embedding(embedding):
    """Normalize embedding to unit length"""
    return embedding / np.linalg.norm(embedding)

# Then dot product = cosine similarity
normalized = normalize_embedding(embedding)
similarity = np.dot(normalized1, normalized2)
```

## Pricing

Check Voyage AI's current pricing at https://www.voyageai.com/pricing

Typical factors:
- Model size (lite vs large)
- Output dimensions
- Volume discounts

## Alternative Providers

While Anthropic recommends Voyage AI, other options exist:

- **OpenAI** - `text-embedding-3-small`, `text-embedding-3-large`
- **Cohere** - `embed-english-v3.0`, `embed-multilingual-v3.0`
- **Google** - Vertex AI embeddings
- **Hugging Face** - Open source models

## Complete Example: Document Q&A System

```python
import anthropic
import voyageai
import numpy as np

class DocumentQA:
    def __init__(self):
        self.claude = anthropic.Anthropic()
        self.voyage = voyageai.Client()
        self.chunks = []
        self.embeddings = []

    def load_document(self, text, chunk_size=500):
        """Split document into chunks and embed"""
        # Simple chunking
        words = text.split()
        chunks = []

        for i in range(0, len(words), chunk_size):
            chunk = " ".join(words[i:i+chunk_size])
            chunks.append(chunk)

        self.chunks.extend(chunks)

        # Embed chunks
        result = self.voyage.embed(
            chunks,
            model="voyage-3.5",
            input_type="document"
        )

        self.embeddings.extend(result.embeddings)

    def ask(self, question, top_k=3):
        """Answer question about document"""
        # Find relevant chunks
        query_result = self.voyage.embed(
            [question],
            model="voyage-3.5",
            input_type="query"
        )
        query_emb = query_result.embeddings[0]

        # Rank chunks
        scores = [
            (i, np.dot(query_emb, emb))
            for i, emb in enumerate(self.embeddings)
        ]
        scores.sort(key=lambda x: x[1], reverse=True)

        # Get top chunks
        context = "\n\n".join([
            self.chunks[i] for i, _ in scores[:top_k]
        ])

        # Ask Claude
        message = self.claude.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=1024,
            messages=[{
                "role": "user",
                "content": f"Context:\n{context}\n\nQuestion: {question}"
            }]
        )

        return message.content[0].text

# Usage
qa = DocumentQA()
qa.load_document("Long document text here...")
answer = qa.ask("What is the main topic?")
print(answer)
```

## Related Documentation

- [Messages API](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)
- [Vision](./07-vision.md)
- [Tool Use](./08-tool-use.md)
- [Examples](./11-examples.md)
