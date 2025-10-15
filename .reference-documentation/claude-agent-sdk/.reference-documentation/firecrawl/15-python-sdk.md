# Firecrawl - Python SDK

**Sources:**
- https://github.com/mendableai/firecrawl-py
- https://pypi.org/project/firecrawl-py/
- https://docs.firecrawl.dev/

**Fetched:** 2025-10-11

## Installation

```bash
pip install firecrawl-py
```

## Initialization

### Basic
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")
```

### From Environment Variable (Recommended)
```python
import os
from firecrawl import Firecrawl

api_key = os.environ.get("FIRECRAWL_API_KEY")
firecrawl = Firecrawl(api_key=api_key)
```

### With Custom Options
```python
firecrawl = Firecrawl(
    api_key="fc-YOUR-API-KEY",
    base_url="https://api.firecrawl.dev",  # Custom API endpoint
    timeout=120  # Request timeout in seconds
)
```

## Methods

### scrape()

Scrape a single URL.

```python
result = firecrawl.scrape(
    url: str,
    formats: List[str] = ["markdown"],
    **options
)
```

**Parameters:**
- `url` (str): URL to scrape
- `formats` (list): Output formats - `["markdown", "html", "screenshot"]`
- `onlyMainContent` (bool): Extract only main content
- `includeTags` (list): HTML tags to include
- `excludeTags` (list): HTML tags to exclude
- `headers` (dict): Custom HTTP headers
- `waitFor` (int): Milliseconds to wait for JS
- `timeout` (int): Request timeout in ms
- `stealth` (bool): Use stealth mode (+1 credit)
- `location` (str): Scrape from location (e.g. "US")

**Returns:**
```python
{
    "markdown": "# Page content...",
    "html": "<html>...</html>",
    "metadata": {
        "title": "Page Title",
        "description": "Description",
        "statusCode": 200
    },
    "links": ["https://...", ...]
}
```

**Example:**
```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["markdown", "html"],
    onlyMainContent=True,
    waitFor=2000
)

print(result['markdown'])
```

### crawl()

Crawl entire website (sync).

```python
result = firecrawl.crawl(
    url: str,
    limit: int = None,
    **options
)
```

**Parameters:**
- `url` (str): Starting URL
- `limit` (int): Max pages to crawl
- `maxDepth` (int): Max crawl depth
- `includePaths` (list): Paths to include (e.g. `["/blog/*"]`)
- `excludePaths` (list): Paths to exclude
- `allowSubdomains` (bool): Include subdomains
- `ignoreSitemap` (bool): Skip sitemap.xml
- `scrapeOptions` (dict): Options for scraping each page

**Returns:**
```python
{
    "data": [
        {
            "url": "https://example.com",
            "markdown": "Content...",
            "metadata": {...}
        },
        ...
    ]
}
```

**Example:**
```python
result = firecrawl.crawl(
    url="https://example.com",
    limit=50,
    includePaths=["/blog/*", "/docs/*"],
    scrapeOptions={
        "formats": ["markdown"],
        "onlyMainContent": True
    }
)

for page in result['data']:
    print(f"URL: {page['url']}")
    print(f"Title: {page['metadata']['title']}")
```

### start_crawl()

Start async crawl.

```python
job = firecrawl.start_crawl(
    url: str,
    **options
)
```

**Returns:**
```python
{
    "id": "crawl_abc123",
    "url": "https://example.com"
}
```

**Example:**
```python
job = firecrawl.start_crawl(
    url="https://example.com",
    limit=500
)

print(f"Crawl started: {job['id']}")
```

### get_crawl_status()

Check crawl status.

```python
status = firecrawl.get_crawl_status(job_id: str)
```

**Returns:**
```python
{
    "status": "scraping",  # or "completed", "failed"
    "total": 100,
    "completed": 45,
    "creditsUsed": 45,
    "data": [...]  # Only when completed
}
```

**Example:**
```python
import time

job = firecrawl.start_crawl(url="https://example.com", limit=100)

while True:
    status = firecrawl.get_crawl_status(job['id'])
    
    print(f"Status: {status['status']}")
    print(f"Progress: {status['completed']}/{status['total']}")
    
    if status['status'] == 'completed':
        for page in status['data']:
            print(f"Scraped: {page['url']}")
        break
    elif status['status'] == 'failed':
        print(f"Error: {status.get('error')}")
        break
    
    time.sleep(10)
```

### cancel_crawl()

Cancel running crawl.

```python
result = firecrawl.cancel_crawl(job_id: str)
```

**Example:**
```python
job = firecrawl.start_crawl(url="https://example.com", limit=1000)
time.sleep(30)
firecrawl.cancel_crawl(job['id'])
print("Crawl canceled")
```

### map()

Get all URLs from website.

```python
result = firecrawl.map(
    url: str,
    search: str = None,
    **options
)
```

**Parameters:**
- `url` (str): Website to map
- `search` (str): Filter URLs containing this string
- `ignoreSitemap` (bool): Skip sitemap.xml
- `includeSubdomains` (bool): Include subdomains
- `limit` (int): Max URLs to return

**Returns:**
```python
{
    "links": [
        "https://example.com",
        "https://example.com/about",
        ...
    ]
}
```

**Example:**
```python
result = firecrawl.map(
    url="https://example.com",
    search="blog"
)

print(f"Found {len(result['links'])} URLs")
for link in result['links']:
    print(link)
```

### search()

Web search with scraping.

```python
result = firecrawl.search(
    query: str,
    limit: int = 10,
    **options
)
```

**Parameters:**
- `query` (str): Search query
- `limit` (int): Max results
- `searchType` (str): "web", "news", "images", "github", "research"
- `location` (str): Geographic location
- `timeRange` (str): "day", "week", "month", "year"
- `scrapeOptions` (dict): Options for scraping results

**Returns:**
```python
{
    "data": [
        {
            "url": "https://...",
            "markdown": "Content...",
            "metadata": {...}
        },
        ...
    ]
}
```

**Example:**
```python
result = firecrawl.search(
    query="firecrawl tutorials",
    limit=5,
    searchType="web"
)

for item in result['data']:
    print(f"Title: {item['metadata']['title']}")
    print(f"URL: {item['url']}")
    print(f"Content: {item['markdown'][:200]}...")
```

### extract()

LLM-powered extraction.

```python
result = firecrawl.extract(
    urls: List[str],
    schema: dict = None,
    prompt: str = None,
    **options
)
```

**Parameters:**
- `urls` (list): URLs to extract from
- `schema` (dict): JSON schema for output structure
- `prompt` (str): Natural language extraction prompt
- `searchQuery` (str): Search query (alternative to urls)
- `searchType` (str): Search type
- `limit` (int): Max results when using search

**Returns:**
```python
{
    "company_name": "Example Corp",
    "founded": 2010,
    "ceo": "John Smith"
}
```

**Example - Schema:**
```python
schema = {
    "type": "object",
    "properties": {
        "company_name": {"type": "string"},
        "founded": {"type": "number"},
        "ceo": {"type": "string"}
    }
}

result = firecrawl.extract(
    urls=["https://example.com/about"],
    schema=schema
)

print(result['data'])
```

**Example - Prompt:**
```python
result = firecrawl.extract(
    urls=["https://example.com"],
    prompt="Extract the company name, CEO, and founding year"
)

print(result['data'])
```

**Example - Multi-URL:**
```python
urls = [
    "https://example.com/team/person1",
    "https://example.com/team/person2"
]

schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "role": {"type": "string"},
        "email": {"type": "string"}
    }
}

result = firecrawl.extract(urls=urls, schema=schema)

for person in result['data']:
    print(f"{person['name']} - {person['role']}")
```

## Async SDK

For async/await support:

```python
from firecrawl import AsyncFirecrawl
import asyncio

async def main():
    firecrawl = AsyncFirecrawl(api_key="fc-YOUR-API-KEY")
    
    # Scrape
    result = await firecrawl.scrape("https://example.com")
    
    # Crawl
    result = await firecrawl.crawl(url="https://example.com", limit=10)
    
    # Search
    result = await firecrawl.search(query="topic", limit=5)

asyncio.run(main())
```

## Error Handling

```python
from firecrawl import Firecrawl
from firecrawl.exceptions import (
    FirecrawlError,
    AuthenticationError,
    RateLimitError,
    PaymentRequiredError
)

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

try:
    result = firecrawl.scrape("https://example.com")
except AuthenticationError:
    print("Invalid API key")
except PaymentRequiredError:
    print("Out of credits")
except RateLimitError:
    print("Rate limited - slow down")
except FirecrawlError as e:
    print(f"Error: {e}")
```

## Complete Examples

### 1. Scrape with All Options
```python
result = firecrawl.scrape(
    url="https://example.com/article",
    formats=["markdown", "html", "screenshot"],
    onlyMainContent=True,
    excludeTags=["nav", "footer", "aside"],
    waitFor=3000,
    stealth=True,
    headers={
        "User-Agent": "CustomBot/1.0"
    }
)

# Access different formats
markdown = result['markdown']
html = result['html']
screenshot = result['screenshot']  # Base64 encoded
metadata = result['metadata']
```

### 2. Monitored Async Crawl
```python
import time

def monitored_crawl(url, limit):
    job = firecrawl.start_crawl(url, limit=limit)
    print(f"Started crawl: {job['id']}")
    
    while True:
        status = firecrawl.get_crawl_status(job['id'])
        
        if status['status'] == 'completed':
            print(f"✓ Completed! Scraped {len(status['data'])} pages")
            return status['data']
        elif status['status'] == 'failed':
            print(f"✗ Failed: {status.get('error')}")
            return None
        
        progress = (status['completed'] / status['total']) * 100
        print(f"Progress: {progress:.1f}% ({status['completed']}/{status['total']})")
        
        time.sleep(10)

pages = monitored_crawl("https://example.com", limit=100)
```

### 3. Search and Extract
```python
# Search for companies
search_results = firecrawl.search(
    query="Y Combinator companies 2024",
    limit=10
)

# Extract structured data
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "description": {"type": "string"},
        "year": {"type": "number"}
    }
}

urls = [item['url'] for item in search_results['data']]
companies = firecrawl.extract(urls=urls, schema=schema)

for company in companies['data']:
    print(f"{company['name']} ({company['year']})")
```

### 4. Complete Site Backup
```python
import json
import os

def backup_website(url, output_dir="backup"):
    os.makedirs(output_dir, exist_ok=True)
    
    # Crawl entire site
    print(f"Crawling {url}...")
    result = firecrawl.crawl(
        url=url,
        limit=1000,
        scrapeOptions={
            "formats": ["markdown", "html"]
        }
    )
    
    # Save each page
    for i, page in enumerate(result['data']):
        filename = page['url'].replace('https://', '').replace('/', '_')
        
        # Save markdown
        with open(f"{output_dir}/{filename}.md", 'w') as f:
            f.write(page['markdown'])
        
        # Save metadata
        with open(f"{output_dir}/{filename}.json", 'w') as f:
            json.dump(page['metadata'], f, indent=2)
    
    print(f"Backed up {len(result['data'])} pages to {output_dir}/")

backup_website("https://example.com")
```

### 5. Batch Scraping with Rate Limiting
```python
import time

def batch_scrape(urls, delay=1):
    results = []
    
    for i, url in enumerate(urls):
        try:
            print(f"Scraping {i+1}/{len(urls)}: {url}")
            result = firecrawl.scrape(url)
            results.append(result)
            
            # Rate limiting
            if i < len(urls) - 1:
                time.sleep(delay)
        
        except Exception as e:
            print(f"Error scraping {url}: {e}")
            continue
    
    return results

urls = [
    "https://example.com/page1",
    "https://example.com/page2",
    "https://example.com/page3"
]

results = batch_scrape(urls, delay=2)
```

## Best Practices

### 1. Use Environment Variables
```python
import os
from firecrawl import Firecrawl

# Good
api_key = os.environ.get("FIRECRAWL_API_KEY")
firecrawl = Firecrawl(api_key=api_key)

# Bad - hardcoded
firecrawl = Firecrawl(api_key="fc-abc123...")
```

### 2. Handle Errors
```python
try:
    result = firecrawl.scrape(url)
except Exception as e:
    print(f"Error: {e}")
    # Implement retry logic
```

### 3. Set Limits
```python
# Always limit crawls
result = firecrawl.crawl(url, limit=100)

# Not: result = firecrawl.crawl(url)  # Could scrape thousands
```

### 4. Use Async for Large Operations
```python
# For > 50 pages
if expected_pages > 50:
    job = firecrawl.start_crawl(url, limit=expected_pages)
    # Poll for status
else:
    result = firecrawl.crawl(url, limit=expected_pages)
```

### 5. Monitor Progress
```python
job = firecrawl.start_crawl(url, limit=500)

while True:
    status = firecrawl.get_crawl_status(job['id'])
    print(f"Progress: {status['completed']}/{status['total']}")
    
    if status['status'] in ['completed', 'failed']:
        break
    
    time.sleep(10)
```

## Related Documentation

- [Quickstart](./02-quickstart.md)
- [Scraping](./04-scraping.md)
- [Crawling](./05-crawling.md)
- [API Reference](./10-api-overview.md)
- [Error Handling](./18-error-handling.md)
