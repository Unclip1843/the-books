# OpenAI Platform - Embeddings

**Source:** https://platform.openai.com/docs/guides/embeddings
**Fetched:** 2025-10-11

## Overview

Generate text embeddings for semantic search and similarity.

---

## Generate Embeddings

```python
response = client.embeddings.create(
    model="text-embedding-3-large",
    input="Your text here"
)

embedding = response.data[0].embedding  # 1536-dimensional vector
```

---

## Models

- **text-embedding-3-large**: Highest quality
- **text-embedding-3-small**: Faster, more affordable
- **text-embedding-ada-002**: Legacy model

---

## Use Cases

- Semantic search
- Clustering
- Recommendations
- Anomaly detection
- Classification

---

## Similarity

```python
import numpy as np

def cosine_similarity(a, b):
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

# Compare embeddings
similarity = cosine_similarity(embedding1, embedding2)
```

---

**Source:** https://platform.openai.com/docs/guides/embeddings
