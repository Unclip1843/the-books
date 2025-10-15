# OpenAI Platform - File Search

**Source:** https://platform.openai.com/docs/guides/tools-file-search
**Fetched:** 2025-10-11

## Overview

File Search enables semantic search across uploaded documents using vector embeddings and keyword search. It automatically parses, chunks, embeds, and retrieves relevant content to answer user queries with citations.

**Key Features:**
- Automatic document parsing and chunking
- Hybrid search (vector + keyword)
- Multi-file search
- Metadata filtering
- Citation tracking
- Reranking for relevance

**Pricing**:
- Vector storage: $0.10/GB per day (first 1GB free)
- Search operations: $2.50/1k tool calls

---

## Quick Start

### Basic File Search

```python
from openai import OpenAI

client = OpenAI()

# Upload files
file1 = client.files.create(
    file=open("product_manual.pdf", "rb"),
    purpose="assistants"
)

file2 = client.files.create(
    file=open("specifications.pdf", "rb"),
    purpose="assistants"
)

# Create vector store
vector_store = client.vector_stores.create(
    name="Product Documentation",
    file_ids=[file1.id, file2.id]
)

# Use file search
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "What are the safety specifications for the product?"
        }
    ],
    tools=[{"type": "file_search"}],
    tool_resources={
        "file_search": {
            "vector_store_ids": [vector_store.id]
        }
    }
)

print(response.choices[0].message.content)
```

---

## Vector Stores

### What is a Vector Store?

A vector store is a database that stores document chunks as vector embeddings for semantic search.

**Capabilities:**
- Stores up to 10,000 files
- Automatic parsing and chunking
- Vector and keyword search
- Metadata filtering
- Persistent storage

### Create Vector Store

```python
# Create empty vector store
vector_store = client.vector_stores.create(
    name="Customer Support KB",
    metadata={
        "category": "support",
        "version": "v2"
    }
)

# Add files to vector store
client.vector_stores.files.create(
    vector_store_id=vector_store.id,
    file_id=file.id
)

# Or create with files
vector_store = client.vector_stores.create(
    name="Customer Support KB",
    file_ids=[file1.id, file2.id, file3.id]
)
```

### List and Manage Vector Stores

```python
# List vector stores
vector_stores = client.vector_stores.list()
for vs in vector_stores:
    print(f"{vs.name}: {vs.file_counts['total']} files")

# Retrieve vector store
vector_store = client.vector_stores.retrieve(vector_store.id)

# Update vector store
client.vector_stores.update(
    vector_store.id,
    name="Updated Name",
    metadata={"version": "v3"}
)

# Delete vector store
client.vector_stores.delete(vector_store.id)
```

### Vector Store Files

```python
# List files in vector store
files = client.vector_stores.files.list(
    vector_store_id=vector_store.id
)

for file in files:
    print(f"File: {file.id}, Status: {file.status}")

# Add file
client.vector_stores.files.create(
    vector_store_id=vector_store.id,
    file_id=new_file.id
)

# Remove file
client.vector_stores.files.delete(
    vector_store_id=vector_store.id,
    file_id=file.id
)
```

---

## Supported File Types

### Document Formats

- **PDF**: Extractable text PDFs
- **Word**: .doc, .docx
- **PowerPoint**: .ppt, .pptx
- **Text**: .txt, .md, .rtf
- **HTML**: .html
- **CSV**: Structured data

### File Limits

- **Max file size**: 512 MB
- **Max files per vector store**: 10,000
- **Total storage**: 1 GB free, then $0.10/GB/day

### Upload Files

```python
# Upload single file
file = client.files.create(
    file=open("document.pdf", "rb"),
    purpose="assistants"
)

# Upload multiple files
files = []
for path in ["doc1.pdf", "doc2.pdf", "doc3.pdf"]:
    file = client.files.create(
        file=open(path, "rb"),
        purpose="assistants"
    )
    files.append(file.id)

# Add to vector store
vector_store = client.vector_stores.create(
    name="Documents",
    file_ids=files
)
```

---

## How File Search Works

### Document Processing Pipeline

1. **Upload**: Files uploaded via Files API
2. **Parsing**: Extract text from documents
3. **Chunking**: Split into semantic chunks
4. **Embedding**: Convert chunks to vectors
5. **Indexing**: Store in vector database
6. **Search**: Query at runtime

### Chunking Strategy

OpenAI automatically chunks documents using:
- Semantic boundaries (paragraphs, sections)
- Optimal chunk size (typically 800-1000 tokens)
- Overlap between chunks for context
- Preservation of document structure

**Example chunking:**
```
Original Document (5000 words)
↓
Chunk 1: Pages 1-2 (800 tokens)
Chunk 2: Pages 2-3 (800 tokens) [overlap with chunk 1]
Chunk 3: Pages 3-4 (800 tokens) [overlap with chunk 2]
...
Chunk N: Last page
```

### Search Process

1. **Query**: User asks question
2. **Rewrite**: Query optimized for search
3. **Parallel Search**:
   - Vector search (semantic similarity)
   - Keyword search (exact matches)
4. **Retrieval**: Top chunks retrieved
5. **Reranking**: Chunks scored for relevance
6. **Context**: Best chunks added to prompt
7. **Generation**: Model generates answer with citations

---

## Metadata Filtering

### Add Metadata to Files

```python
# Upload file with metadata
file = client.files.create(
    file=open("product_spec_v2.pdf", "rb"),
    purpose="assistants",
    metadata={
        "category": "specifications",
        "product": "widget-pro",
        "version": "2.0",
        "department": "engineering"
    }
)
```

### Filter by Metadata

```python
# Search with metadata filter
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Find specifications for widget-pro version 2.0"
        }
    ],
    tools=[{"type": "file_search"}],
    tool_resources={
        "file_search": {
            "vector_store_ids": [vector_store.id],
            "metadata_filter": {
                "product": "widget-pro",
                "version": "2.0"
            }
        }
    }
)
```

### Complex Filters

```python
# Multiple conditions
metadata_filter = {
    "category": "specifications",
    "department": ["engineering", "product"],  # OR condition
    "version": "2.0"
}

# Array filters
metadata_filter = {
    "tags": {"$contains": "important"}  # Check if array contains value
}
```

---

## Citations and Sources

### Enable Citations

Citations are automatically included when file search returns results.

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "What are the safety guidelines?"
        }
    ],
    tools=[{"type": "file_search"}],
    tool_resources={
        "file_search": {
            "vector_store_ids": [vector_store.id]
        }
    }
)

# Access citations
message = response.choices[0].message

if message.annotations:
    for annotation in message.annotations:
        print(f"Citation: {annotation.text}")
        print(f"File: {annotation.file_citation.file_id}")
        print(f"Quote: {annotation.file_citation.quote}")
```

### Format Citations

```python
def format_response_with_citations(response):
    """Format response with inline citations."""
    message = response.choices[0].message
    content = message.content

    if message.annotations:
        # Replace citation markers with formatted citations
        for i, annotation in enumerate(message.annotations):
            citation_num = i + 1
            citation_text = f"[{citation_num}]"

            # Replace in content
            content = content.replace(
                annotation.text,
                f"{annotation.text}{citation_text}"
            )

        # Add citation list
        content += "\n\nSources:\n"
        for i, annotation in enumerate(message.annotations):
            citation_num = i + 1
            file_id = annotation.file_citation.file_id
            quote = annotation.file_citation.quote[:100] + "..."

            content += f"[{citation_num}] File {file_id}: \"{quote}\"\n"

    return content
```

---

## Advanced Usage

### Multi-Vector Store Search

Search across multiple vector stores simultaneously.

```python
# Create multiple vector stores
product_docs = client.vector_stores.create(
    name="Product Docs",
    file_ids=[...]
)

support_docs = client.vector_stores.create(
    name="Support Docs",
    file_ids=[...]
)

# Search across both
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "How do I troubleshoot connection issues?"
        }
    ],
    tools=[{"type": "file_search"}],
    tool_resources={
        "file_search": {
            "vector_store_ids": [product_docs.id, support_docs.id]
        }
    }
)
```

### Batch File Upload

```python
# Upload many files efficiently
import os

file_ids = []
docs_directory = "knowledge_base/"

for filename in os.listdir(docs_directory):
    if filename.endswith(('.pdf', '.docx', '.txt')):
        with open(os.path.join(docs_directory, filename), "rb") as f:
            file = client.files.create(
                file=f,
                purpose="assistants",
                metadata={
                    "source_directory": docs_directory,
                    "filename": filename
                }
            )
            file_ids.append(file.id)

# Add all to vector store
vector_store = client.vector_stores.create(
    name="Complete Knowledge Base",
    file_ids=file_ids
)
```

### Incremental Updates

```python
# Add new files without recreating vector store
new_file = client.files.create(
    file=open("new_doc.pdf", "rb"),
    purpose="assistants"
)

# Add to existing vector store
client.vector_stores.files.create(
    vector_store_id=existing_vector_store.id,
    file_id=new_file.id
)

# Remove outdated file
client.vector_stores.files.delete(
    vector_store_id=existing_vector_store.id,
    file_id=old_file_id
)
```

---

## Use Cases

### Customer Support Knowledge Base

```python
# Build support KB
support_files = [
    "faq.pdf",
    "troubleshooting_guide.pdf",
    "product_manual.pdf",
    "return_policy.pdf"
]

file_ids = []
for path in support_files:
    file = client.files.create(
        file=open(path, "rb"),
        purpose="assistants",
        metadata={"category": "support"}
    )
    file_ids.append(file.id)

support_kb = client.vector_stores.create(
    name="Customer Support KB",
    file_ids=file_ids
)

# Answer support questions
def answer_support_question(question):
    response = client.responses.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": "You are a helpful support agent. Answer questions using the knowledge base and provide citations."
            },
            {
                "role": "user",
                "content": question
            }
        ],
        tools=[{"type": "file_search"}],
        tool_resources={
            "file_search": {
                "vector_store_ids": [support_kb.id]
            }
        }
    )
    return response.choices[0].message.content
```

### Document Q&A

```python
# Upload contract
contract_file = client.files.create(
    file=open("contract.pdf", "rb"),
    purpose="assistants",
    metadata={"type": "legal", "date": "2025-10-11"}
)

contract_store = client.vector_stores.create(
    name="Contract Analysis",
    file_ids=[contract_file.id]
)

# Ask questions about contract
questions = [
    "What is the termination notice period?",
    "What are the payment terms?",
    "Are there any non-compete clauses?"
]

for question in questions:
    response = client.responses.create(
        model="gpt-5",
        messages=[{"role": "user", "content": question}],
        tools=[{"type": "file_search"}],
        tool_resources={
            "file_search": {
                "vector_store_ids": [contract_store.id]
            }
        }
    )
    print(f"Q: {question}")
    print(f"A: {response.choices[0].message.content}\n")
```

### Research Assistant

```python
# Upload research papers
papers = ["paper1.pdf", "paper2.pdf", "paper3.pdf"]
file_ids = []

for paper in papers:
    file = client.files.create(
        file=open(paper, "rb"),
        purpose="assistants",
        metadata={"type": "research_paper"}
    )
    file_ids.append(file.id)

research_store = client.vector_stores.create(
    name="Research Papers",
    file_ids=file_ids
)

# Synthesize insights
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Summarize the main findings across all papers regarding neural architecture search"
        }
    ],
    tools=[{"type": "file_search"}],
    tool_resources={
        "file_search": {
            "vector_store_ids": [research_store.id]
        }
    }
)
```

---

## Best Practices

### 1. Organize with Multiple Vector Stores

```python
# ✅ Good: Separate by category
product_docs = client.vector_stores.create(name="Product Docs", file_ids=[...])
legal_docs = client.vector_stores.create(name="Legal Docs", file_ids=[...])
internal_docs = client.vector_stores.create(name="Internal Docs", file_ids=[...])

# ❌ Poor: Everything in one store
all_docs = client.vector_stores.create(name="All Documents", file_ids=[...])
```

### 2. Use Metadata for Filtering

```python
# Add rich metadata
file = client.files.create(
    file=open("doc.pdf", "rb"),
    purpose="assistants",
    metadata={
        "category": "product",
        "subcategory": "specifications",
        "product_line": "widgets",
        "version": "2.0",
        "date": "2025-10-11",
        "department": "engineering",
        "confidentiality": "internal"
    }
)
```

### 3. Structure Documents Well

```python
# ✅ Good document structure for chunking
"""
# Clear Heading

Introduction paragraph with context.

## Section 1
Content for section 1.

## Section 2
Content for section 2.
"""

# ❌ Poor: No structure
"""
Wall of text with no paragraphs or headings making it hard to chunk
properly and find relevant information...
"""
```

### 4. Monitor Storage Usage

```python
# Check vector store size
vector_store = client.vector_stores.retrieve(vector_store.id)

print(f"Total files: {vector_store.file_counts['total']}")
print(f"In progress: {vector_store.file_counts['in_progress']}")
print(f"Completed: {vector_store.file_counts['completed']}")
print(f"Failed: {vector_store.file_counts['failed']}")

# Estimate storage cost
# Typical PDF: ~500KB after chunking
# 1GB free, then $0.10/GB/day
estimated_gb = (vector_store.file_counts['total'] * 0.5) / 1024
if estimated_gb > 1:
    cost_per_day = (estimated_gb - 1) * 0.10
    print(f"Estimated daily cost: ${cost_per_day:.2f}")
```

---

## Troubleshooting

### File Processing Issues

```python
# Check file status
files = client.vector_stores.files.list(vector_store_id=vector_store.id)

for file in files:
    if file.status == "failed":
        print(f"File {file.id} failed to process")
        # Remove and re-upload
        client.vector_stores.files.delete(
            vector_store_id=vector_store.id,
            file_id=file.id
        )
```

### Poor Search Results

```python
# Tips for better results:
# 1. Use specific questions
# ✅ "What is the warranty period for product X?"
# ❌ "Tell me about warranties"

# 2. Add metadata filters
response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": query}],
    tools=[{"type": "file_search"}],
    tool_resources={
        "file_search": {
            "vector_store_ids": [vector_store.id],
            "metadata_filter": {"category": "warranty"}  # Narrow scope
        }
    }
)

# 3. Organize files into focused vector stores
```

---

## Pricing Example

```python
# Example calculation
# 100 PDF files, average 200 pages each
# Estimated size after chunking: 50MB

files_count = 100
avg_size_mb = 0.5
total_size_gb = (files_count * avg_size_mb) / 1024  # ~0.05 GB

# Storage cost (1GB free)
if total_size_gb <= 1:
    storage_cost_per_day = 0
else:
    storage_cost_per_day = (total_size_gb - 1) * 0.10

# Search cost
# 1000 queries per month
queries_per_month = 1000
search_cost_per_month = (queries_per_month / 1000) * 2.50  # $2.50

print(f"Storage: ${storage_cost_per_day:.2f}/day")
print(f"Search: ${search_cost_per_month:.2f}/month")
```

---

## Additional Resources

- **File Search Docs**: https://platform.openai.com/docs/guides/tools-file-search
- **Vector Stores API**: https://platform.openai.com/docs/api-reference/vector-stores
- **File Upload Guide**: https://platform.openai.com/docs/api-reference/files

---

**Next**: [Knowledge Graphs →](./knowledge-graphs.md)
