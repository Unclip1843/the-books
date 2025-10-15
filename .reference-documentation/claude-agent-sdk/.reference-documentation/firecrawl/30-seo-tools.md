# Firecrawl - SEO Tools Use Case

**Sources:**
- https://docs.firecrawl.dev/
- https://www.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Build SEO analysis and auditing tools with Firecrawl.

## Basic Pattern

```
Website → Crawl → Extract Metadata → Analyze → Report
```

## Simple Example

```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

def seo_audit(url):
    result = firecrawl.crawl(
        url=url,
        limit=100,
        scrapeOptions={"formats": ["html", "markdown"]}
    )
    
    issues = []
    for page in result['data']:
        metadata = page['metadata']
        
        # Check for missing titles
        if not metadata.get('title'):
            issues.append(f"Missing title: {page['url']}")
        
        # Check for missing descriptions
        if not metadata.get('description'):
            issues.append(f"Missing description: {page['url']}")
        
        # Check status codes
        if metadata.get('statusCode') != 200:
            issues.append(f"Error {metadata['statusCode']}: {page['url']}")
    
    return issues

# Usage
issues = seo_audit("https://example.com")
for issue in issues:
    print(issue)
```

## Related Documentation

- [Crawling](./05-crawling.md)
- [Mapping](./06-mapping.md)
