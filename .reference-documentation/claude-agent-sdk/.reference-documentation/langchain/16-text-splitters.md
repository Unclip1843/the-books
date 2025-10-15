# LangChain - Text Splitters

**Sources:**
- https://python.langchain.com/docs/concepts/text_splitters/
- https://python.langchain.com/docs/how_to/recursive_text_splitter/
- https://js.langchain.com/docs/how_to/recursive_text_splitter/

**Fetched:** 2025-10-11

## Why Split Documents?

LLMs have **token limits**. Long documents need to be split into smaller chunks:

**Reasons to split:**
1. **Fit context window** - Stay within model limits (e.g., 4K, 8K, 128K tokens)
2. **Better retrieval** - Smaller chunks = more precise semantic search
3. **Cost reduction** - Process only relevant chunks
4. **Better embeddings** - Each chunk embedded independently

**Key parameters:**
- `chunk_size`: Maximum chunk length
- `chunk_overlap`: Overlap between chunks (preserves context)

## RecursiveCharacterTextSplitter

**Most commonly used** - tries separators in order:

**Python:**
```python
from langchain.text_splitters import RecursiveCharacterTextSplitter

text = """
# Chapter 1

This is the first paragraph of chapter one.

This is the second paragraph.

## Section 1.1

Some content in the first section.
"""

splitter = RecursiveCharacterTextSplitter(
    chunk_size=100,        # Maximum chunk size
    chunk_overlap=20,      # Overlap between chunks
    length_function=len,   # How to measure length
    is_separator_regex=False
)

chunks = splitter.split_text(text)

for i, chunk in enumerate(chunks):
    print(f"Chunk {i + 1}:")
    print(chunk)
    print("---")
```

**TypeScript:**
```typescript
import { RecursiveCharacterTextSplitter } from "langchain/text_splitter";

const text = `...`;

const splitter = new RecursiveCharacterTextSplitter({
  chunkSize: 100,
  chunkOverlap: 20
});

const chunks = await splitter.splitText(text);
```

**How it works:**
1. Tries to split on `\n\n` (paragraphs)
2. Falls back to `\n` (lines)
3. Falls back to ` ` (words)
4. Falls back to `` (characters)

## CharacterTextSplitter

Simple splitter using single separator:

**Python:**
```python
from langchain.text_splitters import CharacterTextSplitter

splitter = CharacterTextSplitter(
    separator="\n\n",      # Split on double newlines
    chunk_size=100,
    chunk_overlap=20
)

chunks = splitter.split_text(text)
```

**When to use:**
- Simple, uniform text structure
- Single separator is sufficient
- Fast splitting needed

## Token-Based Splitters

### TokenTextSplitter

Split by actual token count:

**Python:**
```python
from langchain.text_splitters import TokenTextSplitter

splitter = TokenTextSplitter(
    chunk_size=100,        # 100 tokens
    chunk_overlap=10
)

chunks = splitter.split_text(text)
```

### Tiktoken Splitter (OpenAI)

**Python:**
```python
from langchain.text_splitters import CharacterTextSplitter
import tiktoken

# Count tokens using tiktoken
encoding = tiktoken.encoding_for_model("gpt-4")

def tiktoken_len(text):
    tokens = encoding.encode(text)
    return len(tokens)

splitter = RecursiveCharacterTextSplitter(
    chunk_size=100,
    chunk_overlap=20,
    length_function=tiktoken_len  # Use tiktoken
)

chunks = splitter.split_text(text)
```

**TypeScript:**
```typescript
import { RecursiveCharacterTextSplitter } from "langchain/text_splitter";
import { encodingForModel } from "js-tiktoken";

const encoding = encodingForModel("gpt-4");

const splitter = new RecursiveCharacterTextSplitter({
  chunkSize: 100,
  chunkOverlap: 20,
  lengthFunction: (text: string) => encoding.encode(text).length
});
```

## Splitting Documents

### Split Loaded Documents

**Python:**
```python
from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitters import RecursiveCharacterTextSplitter

# Load documents
loader = PyPDFLoader("document.pdf")
documents = loader.load()

# Split
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)

splits = splitter.split_documents(documents)

# Each split preserves metadata
for split in splits:
    print(split.page_content[:100])
    print(split.metadata)
```

**Metadata is preserved:**
```python
# Original document
{
    "page_content": "Long text...",
    "metadata": {"source": "doc.pdf", "page": 1}
}

# After splitting - each chunk keeps metadata
[
    {
        "page_content": "First chunk...",
        "metadata": {"source": "doc.pdf", "page": 1}
    },
    {
        "page_content": "Second chunk...",
        "metadata": {"source": "doc.pdf", "page": 1}
    }
]
```

## Code Splitters

### Python Code

**Python:**
```python
from langchain.text_splitters import PythonCodeTextSplitter

python_code = """
def hello_world():
    print("Hello, world!")

class MyClass:
    def __init__(self):
        self.value = 42

    def method(self):
        return self.value
"""

splitter = PythonCodeTextSplitter(
    chunk_size=100,
    chunk_overlap=0
)

chunks = splitter.split_text(python_code)
```

### JavaScript Code

**Python:**
```python
from langchain.text_splitters import JavaScriptTextSplitter

js_code = """
function helloWorld() {
    console.log("Hello, world!");
}

class MyClass {
    constructor() {
        this.value = 42;
    }
}
"""

splitter = JavaScriptTextSplitter(
    chunk_size=100,
    chunk_overlap=0
)

chunks = splitter.split_text(js_code)
```

### Language-Specific Splitters

**Python:**
```python
from langchain.text_splitters import (
    RecursiveCharacterTextSplitter,
    Language
)

# Get separators for specific language
python_splitter = RecursiveCharacterTextSplitter.from_language(
    language=Language.PYTHON,
    chunk_size=100,
    chunk_overlap=0
)

# Supported languages
# Language.PYTHON, Language.JAVASCRIPT, Language.JAVA,
# Language.GO, Language.CPP, Language.RUST, etc.
```

## Markdown Splitter

Split markdown by headers:

**Python:**
```python
from langchain.text_splitters import MarkdownHeaderTextSplitter

markdown_text = """
# Main Title

Some intro text.

## Section 1

Content for section 1.

### Subsection 1.1

Detailed content.

## Section 2

Content for section 2.
"""

headers_to_split_on = [
    ("#", "Header 1"),
    ("##", "Header 2"),
    ("###", "Header 3")
]

splitter = MarkdownHeaderTextSplitter(
    headers_to_split_on=headers_to_split_on
)

splits = splitter.split_text(markdown_text)

for split in splits:
    print(split.page_content)
    print(split.metadata)  # Contains header hierarchy
```

**Output:**
```python
# Metadata includes header context
{
    "Header 1": "Main Title",
    "Header 2": "Section 1",
    "Header 3": "Subsection 1.1"
}
```

## HTML Splitters

### HTML Header Splitter

**Python:**
```python
from langchain.text_splitters import HTMLHeaderTextSplitter

html_text = """
<html>
<body>
    <h1>Main Title</h1>
    <p>Introduction paragraph.</p>

    <h2>Section 1</h2>
    <p>Section 1 content.</p>

    <h3>Subsection 1.1</h3>
    <p>Subsection content.</p>
</body>
</html>
"""

headers_to_split_on = [
    ("h1", "Header 1"),
    ("h2", "Header 2"),
    ("h3", "Header 3")
]

splitter = HTMLHeaderTextSplitter(
    headers_to_split_on=headers_to_split_on
)

splits = splitter.split_text(html_text)
```

## Semantic Chunking

Split based on semantic similarity:

**Python:**
```python
from langchain_experimental.text_splitter import SemanticChunker
from langchain_openai import OpenAIEmbeddings

text = """
The first topic is about cats. Cats are great pets.
They are independent and clean.

Now let's talk about dogs. Dogs are loyal companions.
They love to play and go for walks.

Finally, birds are interesting too. Many birds can fly.
Some birds are colorful and can mimic sounds.
"""

# Split when semantic similarity drops
splitter = SemanticChunker(
    OpenAIEmbeddings(),
    breakpoint_threshold_type="percentile"  # or "standard_deviation", "interquartile"
)

chunks = splitter.split_text(text)

# Results in semantically coherent chunks:
# Chunk 1: All about cats
# Chunk 2: All about dogs
# Chunk 3: All about birds
```

## Custom Splitters

### Basic Custom Splitter

**Python:**
```python
from langchain.text_splitters import TextSplitter
from typing import List

class CustomSplitter(TextSplitter):
    def __init__(self, chunk_size: int = 1000, chunk_overlap: int = 200):
        super().__init__(chunk_size=chunk_size, chunk_overlap=chunk_overlap)

    def split_text(self, text: str) -> List[str]:
        """Custom splitting logic."""
        # Example: Split on sentences
        import re
        sentences = re.split(r'[.!?]+', text)

        chunks = []
        current_chunk = []
        current_size = 0

        for sentence in sentences:
            sentence = sentence.strip()
            if not sentence:
                continue

            sentence_size = len(sentence)

            if current_size + sentence_size > self._chunk_size:
                # Start new chunk
                if current_chunk:
                    chunks.append(". ".join(current_chunk) + ".")
                current_chunk = [sentence]
                current_size = sentence_size
            else:
                current_chunk.append(sentence)
                current_size += sentence_size

        # Add last chunk
        if current_chunk:
            chunks.append(". ".join(current_chunk) + ".")

        return chunks

# Usage
splitter = CustomSplitter(chunk_size=100)
chunks = splitter.split_text(text)
```

### Sentence-Based Splitter

**Python:**
```python
import re

class SentenceSplitter(TextSplitter):
    def split_text(self, text: str) -> List[str]:
        # Split into sentences
        sentences = re.split(r'(?<=[.!?])\s+', text)

        chunks = []
        current_chunk = []
        current_length = 0

        for sentence in sentences:
            sentence_length = len(sentence)

            if current_length + sentence_length > self._chunk_size and current_chunk:
                chunks.append(" ".join(current_chunk))
                # Overlap: keep last sentence
                current_chunk = current_chunk[-1:] if self._chunk_overlap > 0 else []
                current_length = len(current_chunk[0]) if current_chunk else 0

            current_chunk.append(sentence)
            current_length += sentence_length

        if current_chunk:
            chunks.append(" ".join(current_chunk))

        return chunks
```

## Best Practices

### 1. Choose Appropriate Chunk Size

```python
# For Q&A: Smaller chunks (more precise)
qa_splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=50
)

# For summarization: Larger chunks (more context)
summary_splitter = RecursiveCharacterTextSplitter(
    chunk_size=2000,
    chunk_overlap=200
)
```

### 2. Use Overlap

```python
# Good: Overlap preserves context
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200  # 20% overlap
)

# Avoid: No overlap (can lose context)
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=0
)
```

### 3. Use Token-Based for LLMs

```python
# Good: Count actual tokens
import tiktoken

encoding = tiktoken.encoding_for_model("gpt-4")

splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    length_function=lambda x: len(encoding.encode(x))
)

# Avoid: Character count (inaccurate)
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    length_function=len  # Characters, not tokens
)
```

### 4. Use Semantic Chunking for Coherence

```python
# Good: Keep related content together
from langchain_experimental.text_splitter import SemanticChunker

splitter = SemanticChunker(OpenAIEmbeddings())

# Avoid: Arbitrary splits
splitter = CharacterTextSplitter(chunk_size=1000)
```

### 5. Preserve Metadata

```python
# Good: Split documents (preserves metadata)
splits = splitter.split_documents(documents)

# Avoid: Split text (loses metadata)
text = "\n\n".join([doc.page_content for doc in documents])
splits = splitter.split_text(text)  # Metadata lost!
```

## Common Patterns

### Split and Embed

**Python:**
```python
from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma

# Load
loader = PyPDFLoader("document.pdf")
documents = loader.load()

# Split
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)
splits = splitter.split_documents(documents)

# Embed and store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(splits, embeddings)
```

### Multi-Level Splitting

**Python:**
```python
# First split by headers
header_splitter = MarkdownHeaderTextSplitter([
    ("##", "Header 2")
])
header_splits = header_splitter.split_text(markdown_text)

# Then split large sections
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)

final_splits = []
for doc in header_splits:
    splits = text_splitter.split_documents([doc])
    final_splits.extend(splits)
```

### Filter Small Chunks

**Python:**
```python
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)

splits = splitter.split_documents(documents)

# Filter out very small chunks
min_chunk_size = 100
filtered_splits = [s for s in splits if len(s.page_content) >= min_chunk_size]
```

## Performance Tips

### 1. Batch Processing

```python
# Process in batches for large document sets
batch_size = 100

for i in range(0, len(documents), batch_size):
    batch = documents[i:i + batch_size]
    splits = splitter.split_documents(batch)
    process_splits(splits)
```

### 2. Cache Split Results

```python
import pickle

# Save splits
with open("splits.pkl", "wb") as f:
    pickle.dump(splits, f)

# Load splits
with open("splits.pkl", "rb") as f:
    splits = pickle.load(f)
```

### 3. Use Appropriate Splitter

```python
# Fast for simple text
CharacterTextSplitter

# Better for most use cases
RecursiveCharacterTextSplitter

# Most accurate but slowest
SemanticChunker (requires embeddings)
```

## Chunk Size Guidelines

| Use Case | Chunk Size | Overlap | Notes |
|----------|-----------|---------|-------|
| Q&A | 500-1000 | 50-100 | Smaller = more precise |
| Summarization | 2000-4000 | 200-400 | Larger = more context |
| Code | 1000-2000 | 0-200 | Respect function boundaries |
| Chat | 500-1000 | 100-200 | Balance context and cost |
| Semantic Search | 500-1000 | 100-200 | Optimize for embeddings |

## Related Documentation

- [Document Loaders](./15-document-loaders.md)
- [Document Transformers](./17-transformers.md)
- [Embeddings](./18-embeddings.md)
- [Vector Stores](./19-vector-stores.md)
- [RAG Basics](./21-rag-basics.md)
