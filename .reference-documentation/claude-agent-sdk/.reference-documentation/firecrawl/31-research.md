# Firecrawl - Research Use Case

**Sources:**
- https://docs.firecrawl.dev/
- https://www.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Conduct deep research by aggregating data from multiple web sources.

## Basic Pattern

```
Topic → Search → Scrape Results → Extract Data → Synthesize
```

## Simple Example

```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

def research_topic(topic, num_sources=10):
    # Search for sources
    results = firecrawl.search(
        query=topic,
        limit=num_sources,
        searchType="web"
    )
    
    # Collect information
    research_data = []
    for result in results['data']:
        research_data.append({
            'title': result['metadata']['title'],
            'url': result['url'],
            'content': result['markdown']
        })
    
    return research_data

# Usage
data = research_topic("AI transformers", num_sources=5)
for item in data:
    print(f"{item['title']}")
    print(f"URL: {item['url']}")
    print(f"Content: {item['content'][:200]}...")
    print("---")
```

## Related Documentation

- [Search](./07-search.md)
- [Extract](./08-extract.md)
- [Python SDK](./15-python-sdk.md)
