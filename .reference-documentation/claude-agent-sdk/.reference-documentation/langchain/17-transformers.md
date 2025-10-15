# LangChain - Document Transformers

**Sources:**
- https://python.langchain.com/docs/how_to/#document-transformers
- https://python.langchain.com/docs/concepts/document_transformers/

**Fetched:** 2025-10-11

## What are Document Transformers?

Document transformers **modify, filter, or enrich** documents after loading:

**Common transformations:**
- Filter documents by metadata
- Extract/enrich metadata
- Translate content
- Remove duplicates
- Clean and normalize text
- Add contextual information

## Built-in Transformers

### Document Filters

Filter documents based on criteria:

**Python:**
```python
from langchain_core.documents import Document

documents = [
    Document(page_content="Python tutorial", metadata={"language": "python"}),
    Document(page_content="Java tutorial", metadata={"language": "java"}),
    Document(page_content="JavaScript guide", metadata={"language": "javascript"})
]

# Filter by metadata
python_docs = [doc for doc in documents if doc.metadata.get("language") == "python"]
```

### EmbeddingsRedundantFilter

Remove similar/duplicate documents:

**Python:**
```python
from langchain.retrievers.document_compressors import EmbeddingsFilter
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()

filter = EmbeddingsFilter(
    embeddings=embeddings,
    similarity_threshold=0.8  # Remove docs with >80% similarity
)

# Remove duplicates
unique_docs = filter.compress_documents(documents, query="")
```

### LongContextReorder

Reorder documents for better context:

**Python:**
```python
from langchain.document_transformers import LongContextReorder

documents = [doc1, doc2, doc3, doc4, doc5]

# Reorder: most relevant at beginning and end
reorderer = LongContextReorder()
reordered_docs = reorderer.transform_documents(documents)

# Output order: [doc1, doc3, doc5, doc4, doc2]
# Most relevant first and last
```

## Metadata Extraction

### BeautifulSoup Transformer

Extract metadata from HTML:

**Python:**
```python
from langchain_community.document_transformers import BeautifulSoupTransformer

html_docs = [
    Document(page_content="<html><title>Page Title</title><body>Content</body></html>")
]

transformer = BeautifulSoupTransformer()
transformed = transformer.transform_documents(
    html_docs,
    tags_to_extract=["title", "body"]
)

print(transformed[0].metadata)
# {"title": "Page Title"}
```

### HTML to Text

**Python:**
```python
from langchain_community.document_transformers import Html2TextTransformer

html_docs = [
    Document(page_content="<html><h1>Title</h1><p>Paragraph</p></html>")
]

transformer = Html2TextTransformer()
text_docs = transformer.transform_documents(html_docs)

print(text_docs[0].page_content)
# "# Title\n\nParagraph"
```

## Custom Transformers

### Basic Transformer

**Python:**
```python
from langchain_core.documents import Document
from typing import List, Sequence

class CustomTransformer:
    def transform_documents(
        self,
        documents: Sequence[Document],
        **kwargs
    ) -> Sequence[Document]:
        """Transform documents."""
        transformed = []

        for doc in documents:
            # Custom transformation logic
            new_content = doc.page_content.upper()

            transformed.append(
                Document(
                    page_content=new_content,
                    metadata=doc.metadata
                )
            )

        return transformed

# Usage
transformer = CustomTransformer()
transformed_docs = transformer.transform_documents(documents)
```

### Metadata Enricher

**Python:**
```python
class MetadataEnricher:
    def transform_documents(
        self,
        documents: Sequence[Document],
        **kwargs
    ) -> Sequence[Document]:
        """Add metadata to documents."""
        transformed = []

        for i, doc in enumerate(documents):
            # Calculate metadata
            word_count = len(doc.page_content.split())
            char_count = len(doc.page_content)

            # Add to existing metadata
            new_metadata = {
                **doc.metadata,
                "word_count": word_count,
                "char_count": char_count,
                "index": i
            }

            transformed.append(
                Document(
                    page_content=doc.page_content,
                    metadata=new_metadata
                )
            )

        return transformed

# Usage
enricher = MetadataEnricher()
enriched_docs = enricher.transform_documents(documents)
```

### Content Cleaner

**Python:**
```python
import re

class ContentCleaner:
    def __init__(self, remove_urls=True, remove_emails=True):
        self.remove_urls = remove_urls
        self.remove_emails = remove_emails

    def transform_documents(
        self,
        documents: Sequence[Document],
        **kwargs
    ) -> Sequence[Document]:
        """Clean document content."""
        transformed = []

        for doc in documents:
            content = doc.page_content

            # Remove URLs
            if self.remove_urls:
                content = re.sub(r'http\S+', '', content)

            # Remove emails
            if self.remove_emails:
                content = re.sub(r'\S+@\S+', '', content)

            # Remove extra whitespace
            content = re.sub(r'\s+', ' ', content).strip()

            transformed.append(
                Document(
                    page_content=content,
                    metadata=doc.metadata
                )
            )

        return transformed

# Usage
cleaner = ContentCleaner()
cleaned_docs = cleaner.transform_documents(documents)
```

## Real-World Examples

### 1. Language Filter

**Python:**
```python
from langdetect import detect

class LanguageFilter:
    def __init__(self, target_language="en"):
        self.target_language = target_language

    def transform_documents(
        self,
        documents: Sequence[Document],
        **kwargs
    ) -> Sequence[Document]:
        """Filter documents by language."""
        filtered = []

        for doc in documents:
            try:
                lang = detect(doc.page_content)
                if lang == self.target_language:
                    doc.metadata["language"] = lang
                    filtered.append(doc)
            except:
                # If language detection fails, skip
                pass

        return filtered

# Usage
filter = LanguageFilter(target_language="en")
english_docs = filter.transform_documents(documents)
```

### 2. Date Extractor

**Python:**
```python
import re
from datetime import datetime

class DateExtractor:
    def transform_documents(
        self,
        documents: Sequence[Document],
        **kwargs
    ) -> Sequence[Document]:
        """Extract dates from content."""
        date_pattern = r'\d{4}-\d{2}-\d{2}'

        transformed = []

        for doc in documents:
            dates = re.findall(date_pattern, doc.page_content)

            new_metadata = {
                **doc.metadata,
                "dates": dates,
                "date_count": len(dates)
            }

            if dates:
                new_metadata["first_date"] = dates[0]

            transformed.append(
                Document(
                    page_content=doc.page_content,
                    metadata=new_metadata
                )
            )

        return transformed
```

### 3. Summary Generator

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate

class SummaryTransformer:
    def __init__(self):
        self.llm = ChatOpenAI()
        self.prompt = ChatPromptTemplate.from_template(
            "Summarize this text in one sentence:\n\n{text}"
        )

    def transform_documents(
        self,
        documents: Sequence[Document],
        **kwargs
    ) -> Sequence[Document]:
        """Add summaries to metadata."""
        transformed = []

        for doc in documents:
            # Generate summary
            chain = self.prompt | self.llm
            summary = chain.invoke({"text": doc.page_content[:1000]})

            new_metadata = {
                **doc.metadata,
                "summary": summary.content
            }

            transformed.append(
                Document(
                    page_content=doc.page_content,
                    metadata=new_metadata
                )
            )

        return transformed
```

### 4. Code Block Extractor

**Python:**
```python
import re

class CodeBlockExtractor:
    def transform_documents(
        self,
        documents: Sequence[Document],
        **kwargs
    ) -> Sequence[Document]:
        """Extract code blocks from markdown."""
        code_pattern = r'```(\w+)?\n(.*?)\n```'

        transformed = []

        for doc in documents:
            matches = re.findall(
                code_pattern,
                doc.page_content,
                re.DOTALL
            )

            code_blocks = []
            for lang, code in matches:
                code_blocks.append({
                    "language": lang or "unknown",
                    "code": code.strip()
                })

            new_metadata = {
                **doc.metadata,
                "code_blocks": code_blocks,
                "code_block_count": len(code_blocks)
            }

            transformed.append(
                Document(
                    page_content=doc.page_content,
                    metadata=new_metadata
                )
            )

        return transformed
```

### 5. Length Filter

**Python:**
```python
class LengthFilter:
    def __init__(self, min_length=100, max_length=10000):
        self.min_length = min_length
        self.max_length = max_length

    def transform_documents(
        self,
        documents: Sequence[Document],
        **kwargs
    ) -> Sequence[Document]:
        """Filter documents by length."""
        filtered = []

        for doc in documents:
            length = len(doc.page_content)

            if self.min_length <= length <= self.max_length:
                doc.metadata["length"] = length
                filtered.append(doc)

        return filtered

# Usage
filter = LengthFilter(min_length=200, max_length=5000)
filtered_docs = filter.transform_documents(documents)
```

## Chaining Transformers

### Sequential Transformation

**Python:**
```python
def chain_transformers(documents, transformers):
    """Apply multiple transformers in sequence."""
    result = documents

    for transformer in transformers:
        result = transformer.transform_documents(result)

    return result

# Usage
transformers = [
    ContentCleaner(),
    MetadataEnricher(),
    LengthFilter(min_length=100),
    LanguageFilter(target_language="en")
]

final_docs = chain_transformers(documents, transformers)
```

### Parallel Transformation

**Python:**
```python
def parallel_transformers(documents, transformers):
    """Apply transformers in parallel and combine results."""
    all_results = []

    for transformer in transformers:
        results = transformer.transform_documents(documents)
        all_results.extend(results)

    # Remove duplicates
    seen = set()
    unique_results = []

    for doc in all_results:
        content_hash = hash(doc.page_content)
        if content_hash not in seen:
            seen.add(content_hash)
            unique_results.append(doc)

    return unique_results
```

## Transformation Pipelines

### Complete Pipeline

**Python:**
```python
from langchain_community.document_loaders import DirectoryLoader, TextLoader
from langchain.text_splitters import RecursiveCharacterTextSplitter

def document_pipeline(directory):
    """Complete document processing pipeline."""

    # 1. Load
    loader = DirectoryLoader(directory, glob="**/*.txt", loader_cls=TextLoader)
    documents = loader.load()

    # 2. Clean
    cleaner = ContentCleaner()
    documents = cleaner.transform_documents(documents)

    # 3. Filter by language
    lang_filter = LanguageFilter(target_language="en")
    documents = lang_filter.transform_documents(documents)

    # 4. Enrich metadata
    enricher = MetadataEnricher()
    documents = enricher.transform_documents(documents)

    # 5. Filter by length
    length_filter = LengthFilter(min_length=200)
    documents = length_filter.transform_documents(documents)

    # 6. Split
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=200
    )
    documents = splitter.split_documents(documents)

    return documents

# Usage
processed_docs = document_pipeline("./data")
```

## Best Practices

### 1. Order Matters

```python
# Good: Filter before enriching (faster)
transformers = [
    LengthFilter(),      # Filter first
    MetadataEnricher()   # Then enrich remaining
]

# Avoid: Enrich before filtering (wastes computation)
transformers = [
    MetadataEnricher(),  # Enriches all docs
    LengthFilter()       # Then filters some out
]
```

### 2. Preserve Important Metadata

```python
# Good: Preserve existing metadata
new_metadata = {
    **doc.metadata,  # Keep existing
    "new_field": value
}

# Avoid: Overwriting metadata
new_metadata = {"new_field": value}  # Lost existing metadata
```

### 3. Handle Errors Gracefully

```python
class RobustTransformer:
    def transform_documents(self, documents, **kwargs):
        transformed = []

        for doc in documents:
            try:
                # Transformation logic
                new_doc = self._transform(doc)
                transformed.append(new_doc)
            except Exception as e:
                # Log error but continue
                print(f"Error transforming doc: {e}")
                # Optionally keep original
                transformed.append(doc)

        return transformed
```

### 4. Log Transformation Stats

```python
class TransformerWithStats:
    def transform_documents(self, documents, **kwargs):
        original_count = len(documents)
        transformed = self._do_transform(documents)
        final_count = len(transformed)

        print(f"Transformed: {original_count} → {final_count}")
        print(f"Removed: {original_count - final_count}")

        return transformed
```

### 5. Make Transformers Configurable

```python
class ConfigurableTransformer:
    def __init__(self, **config):
        self.config = config

    def transform_documents(self, documents, **kwargs):
        # Use self.config for behavior
        if self.config.get("uppercase", False):
            # Transform to uppercase
            pass

# Usage
transformer = ConfigurableTransformer(
    uppercase=True,
    remove_urls=True
)
```

## Performance Tips

### 1. Batch Processing

```python
def batch_transform(documents, transformer, batch_size=100):
    results = []

    for i in range(0, len(documents), batch_size):
        batch = documents[i:i + batch_size]
        batch_results = transformer.transform_documents(batch)
        results.extend(batch_results)

    return results
```

### 2. Parallel Processing

```python
from concurrent.futures import ThreadPoolExecutor

def parallel_transform(documents, transformer, max_workers=4):
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        # Split into chunks
        chunk_size = len(documents) // max_workers
        chunks = [
            documents[i:i + chunk_size]
            for i in range(0, len(documents), chunk_size)
        ]

        # Transform in parallel
        futures = [
            executor.submit(transformer.transform_documents, chunk)
            for chunk in chunks
        ]

        # Collect results
        results = []
        for future in futures:
            results.extend(future.result())

    return results
```

### 3. Cache Expensive Operations

```python
from functools import lru_cache

class CachedTransformer:
    @lru_cache(maxsize=1000)
    def _expensive_operation(self, text):
        # Expensive operation
        return result

    def transform_documents(self, documents, **kwargs):
        # Use cached operation
        for doc in documents:
            result = self._expensive_operation(doc.page_content)
```

## Related Documentation

- [Document Loaders](./15-document-loaders.md)
- [Text Splitters](./16-text-splitters.md)
- [Embeddings](./18-embeddings.md)
- [Vector Stores](./19-vector-stores.md)
- [Retrievers](./20-retrievers.md)
