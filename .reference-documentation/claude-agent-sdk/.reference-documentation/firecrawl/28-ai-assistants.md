# Firecrawl - AI Assistants Use Case

**Sources:**
- https://docs.firecrawl.dev/
- https://www.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Build AI assistants that can access real-time web data with Firecrawl.

## Basic Pattern

```
User Query → Search/Scrape Web → Process with LLM → Response
```

## Simple AI Assistant

```python
from firecrawl import Firecrawl
import anthropic

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")
claude = anthropic.Anthropic()

def answer_question(question):
    # Search for relevant info
    results = firecrawl.search(
        query=question,
        limit=3
    )
    
    # Build context
    context = ""
    for result in results['data']:
        context += f"Source: {result['url']}\n"
        context += f"{result['markdown'][:500]}...\n\n"
    
    # Ask Claude
    response = claude.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": f"Context:\n{context}\n\nQuestion: {question}"
        }]
    )
    
    return response.content[0].text

# Usage
answer = answer_question("What are the latest AI developments?")
print(answer)
```

## Complete Examples at End of File

See full implementations below after the sections.

## Related Documentation

- [Search](./07-search.md)
- [LangChain](./24-langchain.md)
- [LlamaIndex](./25-llamaindex.md)
