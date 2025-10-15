# Firecrawl - Scraping

**Sources:**
- https://docs.firecrawl.dev/features/scrape
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Scraping converts a single URL into clean, structured data in your chosen format.

## Basic Scraping

### Python
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

# Simple scrape
result = firecrawl.scrape("https://firecrawl.dev")
print(result['markdown'])
```

### Node.js
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });

const result = await firecrawl.scrapeUrl('https://firecrawl.dev');
console.log(result.markdown);
```

### cURL
```bash
curl -X POST https://api.firecrawl.dev/v1/scrape \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://firecrawl.dev",
    "formats": ["markdown"]
  }'
```

## Output Formats

### Markdown (Default)
```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["markdown"]
)
print(result['markdown'])
```

### HTML
```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["html"]
)
print(result['html'])
```

### Multiple Formats
```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["markdown", "html", "screenshot"]
)
```

### Screenshots
```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["screenshot"]
)
# Returns base64 encoded image
```

## Advanced Options

### Wait for Content
```python
result = firecrawl.scrape(
    url="https://example.com",
    wait_for=5000  # Wait 5 seconds for JS to load
)
```

### Custom Headers
```python
result = firecrawl.scrape(
    url="https://example.com",
    headers={
        "User-Agent": "Custom Bot",
        "Accept-Language": "en-US"
    }
)
```

### Include/Exclude Tags
```python
result = firecrawl.scrape(
    url="https://example.com",
    onlyMainContent=True,  # Extract main content only
    excludeTags=["nav", "footer", "aside"]
)
```

### Stealth Mode
```python
result = firecrawl.scrape(
    url="https://example.com",
    stealth=True  # +1 credit - bypass anti-bot
)
```

### Location-Based Scraping
```python
result = firecrawl.scrape(
    url="https://example.com",
    location="US"  # Scrape from US location
)
```

## Batch Scraping

```python
urls = [
    "https://example.com/page1",
    "https://example.com/page2",
    "https://example.com/page3"
]

results = []
for url in urls:
    result = firecrawl.scrape(url, formats=["markdown"])
    results.append(result)
```

## Response Format

```json
{
  "success": true,
  "data": {
    "markdown": "# Page Title\n\nContent...",
    "html": "<html>...</html>",
    "metadata": {
      "title": "Page Title",
      "description": "Page description",
      "language": "en",
      "sourceURL": "https://example.com",
      "statusCode": 200
    },
    "links": ["https://link1.com", "https://link2.com"],
    "screenshot": "base64-encoded-image"
  }
}
```

## Pricing

- **Base scrape:** 1 credit
- **Screenshot:** +0 credits (included)
- **Stealth mode:** +1 credit
- **PDF parsing:** +1 credit

## Use Cases

### 1. Content Extraction
```python
def extract_article(url):
    result = firecrawl.scrape(
        url=url,
        formats=["markdown"],
        onlyMainContent=True
    )
    return result['markdown']
```

### 2. Monitoring
```python
def check_website_changes(url, last_content):
    result = firecrawl.scrape(url)
    current_content = result['markdown']
    
    if current_content != last_content:
        print("Website changed!")
        return current_content
    return last_content
```

### 3. SEO Analysis
```python
def analyze_seo(url):
    result = firecrawl.scrape(url, formats=["markdown", "html"])
    
    metadata = result['metadata']
    links = result['links']
    
    return {
        "title": metadata['title'],
        "description": metadata['description'],
        "internal_links": len([l for l in links if url in l]),
        "external_links": len([l for l in links if url not in l])
    }
```

## Related Documentation

- [Crawling](./05-crawling.md)
- [Python SDK](./15-python-sdk.md)
- [API Reference](./11-scrape-endpoint.md)
