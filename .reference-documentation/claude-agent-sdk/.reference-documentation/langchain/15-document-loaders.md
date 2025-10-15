# LangChain - Document Loaders

**Sources:**
- https://python.langchain.com/docs/concepts/document_loaders/
- https://python.langchain.com/docs/how_to/#document-loaders
- https://js.langchain.com/docs/integrations/document_loaders/

**Fetched:** 2025-10-11

## What are Document Loaders?

Document loaders **load data from various sources** into LangChain `Document` objects:

```python
from langchain_core.documents import Document

# Document structure
doc = Document(
    page_content="The actual text content",
    metadata={
        "source": "file.pdf",
        "page": 1,
        "author": "John Doe"
    }
)
```

## Document Object

### Structure

**Python:**
```python
from langchain_core.documents import Document

doc = Document(
    page_content="This is the main text content of the document.",
    metadata={
        "source": "example.txt",
        "created_at": "2024-01-15",
        "author": "Alice"
    }
)

# Access content
print(doc.page_content)

# Access metadata
print(doc.metadata["source"])
```

## Text File Loaders

### TextLoader

Load plain text files:

**Python:**
```python
from langchain_community.document_loaders import TextLoader

loader = TextLoader("file.txt")
documents = loader.load()

print(documents[0].page_content)
print(documents[0].metadata)
# {'source': 'file.txt'}
```

**TypeScript:**
```typescript
import { TextLoader } from "langchain/document_loaders/fs/text";

const loader = new TextLoader("file.txt");
const documents = await loader.load();

console.log(documents[0].pageContent);
console.log(documents[0].metadata);
```

### DirectoryLoader

Load all files from a directory:

**Python:**
```python
from langchain_community.document_loaders import DirectoryLoader, TextLoader

loader = DirectoryLoader(
    "./docs",
    glob="**/*.txt",  # Pattern to match
    loader_cls=TextLoader
)

documents = loader.load()
print(f"Loaded {len(documents)} documents")
```

### CSV Loader

**Python:**
```python
from langchain_community.document_loaders import CSVLoader

loader = CSVLoader(
    file_path="data.csv",
    csv_args={
        "delimiter": ",",
        "quotechar": '"'
    }
)

documents = loader.load()
```

### JSON Loader

**Python:**
```python
from langchain_community.document_loaders import JSONLoader

loader = JSONLoader(
    file_path="data.json",
    jq_schema=".messages[].content",  # JQ filter
    text_content=False
)

documents = loader.load()
```

## PDF Loaders

### PyPDFLoader

**Python:**
```python
from langchain_community.document_loaders import PyPDFLoader

loader = PyPDFLoader("document.pdf")
documents = loader.load()

# Each page is a separate document
for i, doc in enumerate(documents):
    print(f"Page {i + 1}: {doc.page_content[:100]}...")
    print(f"Metadata: {doc.metadata}")
```

**TypeScript:**
```typescript
import { PDFLoader } from "langchain/document_loaders/fs/pdf";

const loader = new PDFLoader("document.pdf");
const documents = await loader.load();
```

### PyPDF Directory Loader

**Python:**
```python
from langchain_community.document_loaders import PyPDFDirectoryLoader

loader = PyPDFDirectoryLoader("./pdfs")
documents = loader.load()
```

### Unstructured PDF Loader

**Python:**
```python
from langchain_community.document_loaders import UnstructuredPDFLoader

loader = UnstructuredPDFLoader(
    "document.pdf",
    mode="elements"  # or "single" for whole doc
)

documents = loader.load()
```

## Web Loaders

### WebBaseLoader

**Python:**
```python
from langchain_community.document_loaders import WebBaseLoader

loader = WebBaseLoader("https://example.com")
documents = loader.load()

print(documents[0].page_content)
print(documents[0].metadata)
# {'source': 'https://example.com', 'title': '...'}
```

### Multiple URLs

**Python:**
```python
loader = WebBaseLoader([
    "https://example.com/page1",
    "https://example.com/page2"
])

documents = loader.load()
```

### Firecrawl Loader

**Python:**
```python
from langchain_community.document_loaders import FirecrawlLoader

loader = FirecrawlLoader(
    url="https://example.com",
    api_key="fc-...",
    mode="scrape"  # or "crawl"
)

documents = loader.load()
```

**With crawl mode:**
```python
loader = FirecrawlLoader(
    url="https://example.com",
    api_key="fc-...",
    mode="crawl",
    params={
        "limit": 100,
        "scrapeOptions": {"formats": ["markdown", "html"]}
    }
)

documents = loader.load()
```

**TypeScript:**
```typescript
import { FireCrawlLoader } from "@langchain/community/document_loaders/web/firecrawl";

const loader = new FireCrawlLoader({
  url: "https://example.com",
  apiKey: "fc-...",
  mode: "crawl",
  params: {
    limit: 100
  }
});

const documents = await loader.load();
```

### Sitemap Loader

**Python:**
```python
from langchain_community.document_loaders import SitemapLoader

loader = SitemapLoader("https://example.com/sitemap.xml")
documents = loader.load()
```

## API Loaders

### Notion Loader

**Python:**
```python
from langchain_community.document_loaders import NotionDirectoryLoader

loader = NotionDirectoryLoader("./notion_export")
documents = loader.load()
```

### GitHub Loader

**Python:**
```python
from langchain_community.document_loaders import GithubFileLoader

loader = GithubFileLoader(
    repo="langchain-ai/langchain",
    access_token="ghp_...",
    github_api_url="https://api.github.com",
    file_filter=lambda file_path: file_path.endswith(".py")
)

documents = loader.load()
```

### Google Drive Loader

**Python:**
```python
from langchain_community.document_loaders import GoogleDriveLoader

loader = GoogleDriveLoader(
    folder_id="folder_id_here",
    recursive=False
)

documents = loader.load()
```

## Database Loaders

### SQL Database

**Python:**
```python
from langchain_community.document_loaders import SQLDatabaseLoader

loader = SQLDatabaseLoader(
    query="SELECT * FROM products",
    db_engine=engine  # SQLAlchemy engine
)

documents = loader.load()
```

### MongoDB

**Python:**
```python
from langchain_community.document_loaders import MongodbLoader

loader = MongodbLoader(
    connection_string="mongodb://localhost:27017",
    db_name="mydb",
    collection_name="mycollection",
    filter_criteria={"status": "active"}
)

documents = loader.load()
```

## Specialized Loaders

### Markdown

**Python:**
```python
from langchain_community.document_loaders import UnstructuredMarkdownLoader

loader = UnstructuredMarkdownLoader("README.md")
documents = loader.load()
```

### HTML

**Python:**
```python
from langchain_community.document_loaders import UnstructuredHTMLLoader

loader = UnstructuredHTMLLoader("page.html")
documents = loader.load()
```

### Microsoft Word

**Python:**
```python
from langchain_community.document_loaders import Docx2txtLoader

loader = Docx2txtLoader("document.docx")
documents = loader.load()
```

### Excel

**Python:**
```python
from langchain_community.document_loaders import UnstructuredExcelLoader

loader = UnstructuredExcelLoader("spreadsheet.xlsx")
documents = loader.load()
```

### PowerPoint

**Python:**
```python
from langchain_community.document_loaders import UnstructuredPowerPointLoader

loader = UnstructuredPowerPointLoader("presentation.pptx")
documents = loader.load()
```

### YouTube Transcripts

**Python:**
```python
from langchain_community.document_loaders import YoutubeLoader

loader = YoutubeLoader.from_youtube_url(
    "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    add_video_info=True
)

documents = loader.load()
```

## Custom Loaders

### Basic Custom Loader

**Python:**
```python
from langchain_core.document_loaders import BaseLoader
from langchain_core.documents import Document
from typing import List

class CustomLoader(BaseLoader):
    def __init__(self, file_path: str):
        self.file_path = file_path

    def load(self) -> List[Document]:
        """Load documents from file."""
        with open(self.file_path) as f:
            content = f.read()

        # Custom parsing logic
        sections = content.split("\n\n")

        documents = []
        for i, section in enumerate(sections):
            doc = Document(
                page_content=section,
                metadata={
                    "source": self.file_path,
                    "section": i
                }
            )
            documents.append(doc)

        return documents

# Usage
loader = CustomLoader("data.txt")
documents = loader.load()
```

### Lazy Loading

**Python:**
```python
from typing import Iterator

class LazyLoader(BaseLoader):
    def __init__(self, file_path: str):
        self.file_path = file_path

    def lazy_load(self) -> Iterator[Document]:
        """Lazy load documents one at a time."""
        with open(self.file_path) as f:
            for i, line in enumerate(f):
                yield Document(
                    page_content=line.strip(),
                    metadata={
                        "source": self.file_path,
                        "line": i + 1
                    }
                )

# Usage - loads documents on demand
loader = LazyLoader("large_file.txt")
for doc in loader.lazy_load():
    process(doc)  # Process one at a time
```

## Loader Patterns

### Load and Split

**Python:**
```python
from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter

# Load
loader = PyPDFLoader("document.pdf")
documents = loader.load()

# Split
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)
splits = splitter.split_documents(documents)
```

### Load Multiple Sources

**Python:**
```python
def load_from_multiple_sources():
    all_documents = []

    # Load PDFs
    pdf_loader = DirectoryLoader("./pdfs", glob="**/*.pdf", loader_cls=PyPDFLoader)
    all_documents.extend(pdf_loader.load())

    # Load text files
    text_loader = DirectoryLoader("./texts", glob="**/*.txt", loader_cls=TextLoader)
    all_documents.extend(text_loader.load())

    # Load web pages
    web_loader = WebBaseLoader(["https://example.com/page1", "https://example.com/page2"])
    all_documents.extend(web_loader.load())

    return all_documents

documents = load_from_multiple_sources()
```

### Async Loading

**Python:**
```python
import asyncio
from langchain_community.document_loaders import WebBaseLoader

async def load_documents_async(urls):
    loader = WebBaseLoader(urls)
    # Some loaders support async
    documents = await loader.aload()
    return documents

# Usage
urls = ["https://example.com/page1", "https://example.com/page2"]
documents = asyncio.run(load_documents_async(urls))
```

## Error Handling

**Python:**
```python
from langchain_community.document_loaders import DirectoryLoader, TextLoader

def load_with_error_handling(directory):
    documents = []
    errors = []

    loader = DirectoryLoader(
        directory,
        glob="**/*.txt",
        loader_cls=TextLoader,
        show_progress=True,
        use_multithreading=True
    )

    try:
        documents = loader.load()
    except Exception as e:
        errors.append(str(e))

    return documents, errors

docs, errors = load_with_error_handling("./data")
print(f"Loaded {len(docs)} documents")
if errors:
    print(f"Errors: {errors}")
```

## Best Practices

### 1. Use Appropriate Loader

```python
# Good: Use specific loader
pdf_loader = PyPDFLoader("doc.pdf")

# Avoid: Generic loader for specialized formats
generic_loader = TextLoader("doc.pdf")  # Won't parse properly
```

### 2. Handle Large Files

```python
# Good: Use lazy loading for large files
loader = CustomLoader("huge_file.txt")
for doc in loader.lazy_load():
    process(doc)

# Avoid: Loading entire file
all_docs = loader.load()  # Could cause memory issues
```

### 3. Add Metadata

```python
# Good: Rich metadata
doc = Document(
    page_content=content,
    metadata={
        "source": file_path,
        "page": page_num,
        "author": author,
        "created_at": timestamp
    }
)

# Avoid: Minimal metadata
doc = Document(page_content=content)
```

### 4. Validate Documents

```python
# Good: Validate after loading
documents = loader.load()

for doc in documents:
    if not doc.page_content.strip():
        print(f"Empty document from {doc.metadata.get('source')}")
```

### 5. Use Directory Loaders

```python
# Good: Batch load with DirectoryLoader
loader = DirectoryLoader("./docs", glob="**/*.pdf", loader_cls=PyPDFLoader)
documents = loader.load()

# Avoid: Manual iteration
import os
documents = []
for file in os.listdir("./docs"):
    if file.endswith(".pdf"):
        loader = PyPDFLoader(file)
        documents.extend(loader.load())
```

## Performance Tips

### 1. Use Multithreading

```python
loader = DirectoryLoader(
    "./docs",
    glob="**/*.pdf",
    loader_cls=PyPDFLoader,
    use_multithreading=True  # Parallel loading
)
```

### 2. Filter Files

```python
# Only load relevant files
loader = DirectoryLoader(
    "./docs",
    glob="**/*.pdf",
    loader_cls=PyPDFLoader,
    exclude=["**/archive/**", "**/old/**"]
)
```

### 3. Lazy Load When Possible

```python
# For processing without storing all in memory
for doc in loader.lazy_load():
    process_and_store(doc)
```

## Related Documentation

- [Text Splitters](./16-text-splitters.md)
- [Document Transformers](./17-transformers.md)
- [Embeddings](./18-embeddings.md)
- [Vector Stores](./19-vector-stores.md)
- [RAG Basics](./21-rag-basics.md)
