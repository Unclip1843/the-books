# LangChain - Installation

**Sources:**
- https://python.langchain.com/docs/get_started/installation
- https://js.langchain.com/docs/get_started/installation

**Fetched:** 2025-10-11

## Python Installation

### Basic Installation

```bash
pip install langchain
```

### With OpenAI

```bash
pip install langchain langchain-openai
```

### With Anthropic (Claude)

```bash
pip install langchain langchain-anthropic
```

### Complete Installation

```bash
pip install langchain langchain-openai langchain-anthropic langchain-community
```

## TypeScript Installation

### Basic Installation

```bash
npm install langchain
```

### With OpenAI

```bash
npm install langchain @langchain/openai
```

### With Anthropic

```bash
npm install langchain @langchain/anthropic
```

### Complete Installation

```bash
npm install langchain @langchain/openai @langchain/anthropic @langchain/community
```

## Package Structure

### Python Packages

| Package | Purpose |
|---------|---------|
| `langchain-core` | Base abstractions (auto-installed) |
| `langchain` | Chains, agents, retrieval |
| `langchain-openai` | OpenAI integration |
| `langchain-anthropic` | Anthropic/Claude integration |
| `langchain-community` | Community integrations |

### TypeScript Packages

| Package | Purpose |
|---------|---------|
| `@langchain/core` | Base abstractions (auto-installed) |
| `langchain` | Chains, agents, retrieval |
| `@langchain/openai` | OpenAI integration |
| `@langchain/anthropic` | Anthropic integration |
| `@langchain/community` | Community integrations |

## Optional Dependencies

### Python

**Document Loaders:**
```bash
pip install unstructured
pip install pypdf
pip install firecrawl-py
```

**Vector Stores:**
```bash
pip install chromadb
pip install pinecone-client
pip install qdrant-client
```

**Embeddings:**
```bash
pip install voyageai
```

**Tools:**
```bash
pip install google-search-results  # SerpAPI
```

### TypeScript

**Document Loaders:**
```bash
npm install pdf-parse
npm install @mendable/firecrawl-js
```

**Vector Stores:**
```bash
npm install chromadb
npm install @pinecone-database/pinecone
```

## Environment Setup

### API Keys

Create `.env` file:

```bash
# LLM Providers
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# LangSmith (optional)
LANGCHAIN_TRACING_V2=true
LANGCHAIN_API_KEY=ls-...

# Tools
SERPAPI_API_KEY=...

# Vector Stores
PINECONE_API_KEY=...
```

### Python - Load Environment Variables

```python
from dotenv import load_dotenv
load_dotenv()

# Or install python-dotenv
# pip install python-dotenv
```

### TypeScript - Load Environment Variables

```typescript
import * as dotenv from 'dotenv';
dotenv.config();

// Or install dotenv
// npm install dotenv
```

## Verification

### Python

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()
result = llm.invoke("Hello!")
print(result.content)
```

### TypeScript

```typescript
import { ChatOpenAI } from "@langchain/openai";

const llm = new ChatOpenAI();
const result = await llm.invoke("Hello!");
console.log(result.content);
```

## Virtual Environments

### Python

```bash
# Create virtual environment
python -m venv venv

# Activate (macOS/Linux)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Install packages
pip install langchain langchain-openai
```

### Node.js

```bash
# Create new project
npm init -y

# Install dependencies
npm install langchain @langchain/openai
```

## Troubleshooting

### Python - Import Errors

```bash
# Ensure langchain-core is installed
pip install langchain-core

# Reinstall if needed
pip install --upgrade --force-reinstall langchain
```

### TypeScript - Module Errors

```bash
# Clear cache
npm cache clean --force

# Reinstall
rm -rf node_modules package-lock.json
npm install
```

## Version Compatibility

### Python

```bash
# Check version
python --version  # Requires Python 3.8+

# Check langchain version
pip show langchain
```

### TypeScript

```bash
# Check version
node --version  # Requires Node.js 18+

# Check langchain version
npm list langchain
```

## Related Documentation

- [Quickstart](./03-quickstart.md)
- [Chat Models](./06-chat-models.md)
- [Python SDK](./44-python-installation.md)
- [TypeScript SDK](./49-typescript-installation.md)
