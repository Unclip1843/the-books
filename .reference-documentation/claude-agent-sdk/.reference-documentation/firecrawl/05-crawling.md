# Firecrawl - Crawling

**Sources:**
- https://docs.firecrawl.dev/features/crawl
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Crawling recursively extracts data from entire websites, automatically discovering and scraping subpages.

## How Crawling Works

```
Start URL → Discover Links → Scrape Pages → Find More Links → Repeat
```

**Features:**
- Automatic link discovery (no sitemap needed)
- Configurable depth and page limits
- Domain/subdomain filtering
- Async operation with WebSocket streaming
- Webhook notifications

## Basic Crawling

### Python
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

# Crawl with limit
result = firecrawl.crawl(
    url="https://example.com",
    limit=100  # Max 100 pages
)

# Process results
for page in result['data']:
    print(f"URL: {page['url']}")
    print(f"Title: {page['metadata']['title']}")
    print(f"Content: {page['markdown'][:200]}...")
    print("---")
```

### Node.js
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });

const result = await firecrawl.crawlUrl('https://example.com', {
  limit: 100
});

result.data.forEach(page => {
  console.log(`URL: ${page.url}`);
  console.log(`Title: ${page.metadata.title}`);
  console.log(`Content: ${page.markdown.substring(0, 200)}...`);
});
```

### cURL
```bash
curl -X POST https://api.firecrawl.dev/v1/crawl \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "limit": 100,
    "scrapeOptions": {
      "formats": ["markdown"]
    }
  }'
```

## Async Crawling

For large crawls, use async mode to avoid timeouts:

### Python
```python
# Start async crawl
job = firecrawl.start_crawl(
    url="https://example.com",
    limit=500
)

print(f"Crawl started. Job ID: {job['id']}")

# Poll for status
import time

while True:
    status = firecrawl.get_crawl_status(job['id'])
    
    print(f"Status: {status['status']}")
    print(f"Completed: {status['completed']}/{status['total']}")
    
    if status['status'] == 'completed':
        # Get results
        for page in status['data']:
            print(f"URL: {page['url']}")
        break
    elif status['status'] == 'failed':
        print(f"Error: {status['error']}")
        break
    
    time.sleep(10)  # Check every 10 seconds
```

### Node.js
```javascript
// Start async crawl
const job = await firecrawl.asyncCrawlUrl('https://example.com', {
  limit: 500
});

console.log(`Crawl started. Job ID: ${job.id}`);

// Poll for status
while (true) {
  const status = await firecrawl.checkCrawlStatus(job.id);
  
  console.log(`Status: ${status.status}`);
  console.log(`Completed: ${status.completed}/${status.total}`);
  
  if (status.status === 'completed') {
    status.data.forEach(page => {
      console.log(`URL: ${page.url}`);
    });
    break;
  } else if (status.status === 'failed') {
    console.error(`Error: ${status.error}`);
    break;
  }
  
  await new Promise(resolve => setTimeout(resolve, 10000));
}
```

## Crawl Options

### Limit Pages
```python
result = firecrawl.crawl(
    url="https://example.com",
    limit=50  # Stop after 50 pages
)
```

### Include/Exclude Paths
```python
result = firecrawl.crawl(
    url="https://example.com",
    includePaths=["/blog/*", "/docs/*"],  # Only these paths
    excludePaths=["/admin/*", "/private/*"]  # Skip these
)
```

### Max Depth
```python
result = firecrawl.crawl(
    url="https://example.com",
    maxDepth=3  # Only go 3 levels deep
)
```

### Allow Subdomains
```python
result = firecrawl.crawl(
    url="https://example.com",
    allowSubdomains=True  # Include blog.example.com, api.example.com, etc.
)
```

### Ignore Sitemap
```python
result = firecrawl.crawl(
    url="https://example.com",
    ignoreSitemap=True  # Don't use sitemap.xml
)
```

## Scrape Options

Configure how each page is scraped:

```python
result = firecrawl.crawl(
    url="https://example.com",
    limit=100,
    scrapeOptions={
        "formats": ["markdown", "html"],
        "onlyMainContent": True,
        "excludeTags": ["nav", "footer"],
        "waitFor": 2000  # Wait 2s per page
    }
)
```

## WebSocket Streaming

Get real-time updates as pages are crawled:

### Python
```python
import asyncio
import websockets
import json

async def stream_crawl():
    # Start crawl
    job = firecrawl.start_crawl(
        url="https://example.com",
        limit=100,
        webhook="wss://your-websocket-endpoint"
    )
    
    # Connect to WebSocket
    async with websockets.connect(job['websocket_url']) as ws:
        async for message in ws:
            data = json.loads(message)
            
            if data['type'] == 'page_completed':
                print(f"Scraped: {data['url']}")
            elif data['type'] == 'crawl_completed':
                print("Crawl finished!")
                break

asyncio.run(stream_crawl())
```

### Node.js
```javascript
import WebSocket from 'ws';

// Start crawl
const job = await firecrawl.asyncCrawlUrl('https://example.com', {
  limit: 100,
  webhook: 'wss://your-websocket-endpoint'
});

// Connect to WebSocket
const ws = new WebSocket(job.websocket_url);

ws.on('message', (data) => {
  const message = JSON.parse(data);
  
  if (message.type === 'page_completed') {
    console.log(`Scraped: ${message.url}`);
  } else if (message.type === 'crawl_completed') {
    console.log('Crawl finished!');
    ws.close();
  }
});
```

## Webhook Notifications

Receive HTTP callbacks when crawl completes:

```python
result = firecrawl.start_crawl(
    url="https://example.com",
    limit=100,
    webhook="https://your-api.com/webhook"
)

# Your webhook endpoint receives:
# POST https://your-api.com/webhook
# {
#   "status": "completed",
#   "job_id": "crawl_abc123",
#   "total_pages": 87,
#   "data": [...]
# }
```

## Canceling Crawls

Stop a running crawl:

### Python
```python
# Start crawl
job = firecrawl.start_crawl(url="https://example.com", limit=1000)

# Cancel after some time
time.sleep(30)
firecrawl.cancel_crawl(job['id'])

print("Crawl canceled")
```

### Node.js
```javascript
// Start crawl
const job = await firecrawl.asyncCrawlUrl('https://example.com', {
  limit: 1000
});

// Cancel after some time
await new Promise(resolve => setTimeout(resolve, 30000));
await firecrawl.cancelCrawl(job.id);

console.log('Crawl canceled');
```

## Response Format

```json
{
  "success": true,
  "id": "crawl_abc123",
  "status": "completed",
  "total": 87,
  "completed": 87,
  "creditsUsed": 87,
  "expiresAt": "2025-10-12T10:00:00Z",
  "data": [
    {
      "url": "https://example.com",
      "markdown": "# Home Page\n\nContent...",
      "html": "<html>...</html>",
      "metadata": {
        "title": "Home Page",
        "description": "Welcome",
        "statusCode": 200
      },
      "links": ["https://example.com/about", "https://example.com/contact"]
    },
    {
      "url": "https://example.com/about",
      "markdown": "# About Us\n\nContent...",
      "metadata": {...}
    }
  ]
}
```

## Pricing

- **Base crawl:** 1 credit per page
- **Screenshot per page:** +0 credits (included)
- **Stealth mode per page:** +1 credit
- **PDF parsing per page:** +1 credit

**Example:** Crawling 100 pages with stealth mode = 200 credits

## Use Cases

### 1. Site Backup
```python
def backup_website(url):
    result = firecrawl.crawl(
        url=url,
        limit=1000,
        scrapeOptions={"formats": ["markdown", "html"]}
    )
    
    for page in result['data']:
        filename = page['url'].replace('https://', '').replace('/', '_')
        with open(f"backup/{filename}.md", 'w') as f:
            f.write(page['markdown'])
```

### 2. Competitor Analysis
```python
def analyze_competitor(url):
    result = firecrawl.crawl(
        url=url,
        limit=50,
        includePaths=["/products/*", "/pricing/*"]
    )
    
    products = []
    for page in result['data']:
        if '/products/' in page['url']:
            products.append({
                'url': page['url'],
                'title': page['metadata']['title'],
                'content': page['markdown']
            })
    
    return products
```

### 3. Documentation Scraper
```python
def scrape_docs(url):
    result = firecrawl.crawl(
        url=url,
        includePaths=["/docs/*"],
        scrapeOptions={
            "formats": ["markdown"],
            "onlyMainContent": True,
            "excludeTags": ["nav", "footer", "aside"]
        }
    )
    
    docs = {page['url']: page['markdown'] for page in result['data']}
    return docs
```

### 4. SEO Audit
```python
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
        
        # Check for broken links (status != 200)
        if metadata.get('statusCode') != 200:
            issues.append(f"Broken page: {page['url']} ({metadata['statusCode']})")
    
    return issues
```

## Best Practices

### 1. Always Set Limits
```python
# Good - controlled crawl
result = firecrawl.crawl(url="https://example.com", limit=100)

# Bad - could crawl thousands of pages
result = firecrawl.crawl(url="https://example.com")
```

### 2. Use Async for Large Crawls
```python
# For > 50 pages, use async
if expected_pages > 50:
    job = firecrawl.start_crawl(url, limit=expected_pages)
    # Poll for status
else:
    result = firecrawl.crawl(url, limit=expected_pages)
```

### 3. Filter Paths
```python
# Only crawl relevant sections
result = firecrawl.crawl(
    url="https://example.com",
    includePaths=["/blog/*", "/products/*"],
    excludePaths=["/admin/*", "/login/*"]
)
```

### 4. Monitor Progress
```python
def monitored_crawl(url, limit):
    job = firecrawl.start_crawl(url, limit=limit)
    
    while True:
        status = firecrawl.get_crawl_status(job['id'])
        progress = (status['completed'] / status['total']) * 100
        print(f"Progress: {progress:.1f}%")
        
        if status['status'] in ['completed', 'failed']:
            break
        
        time.sleep(10)
    
    return status['data']
```

### 5. Handle Errors
```python
try:
    result = firecrawl.crawl(url="https://example.com", limit=100)
except Exception as e:
    if '429' in str(e):
        print("Rate limited - try again later")
    elif '402' in str(e):
        print("Out of credits")
    else:
        print(f"Error: {e}")
```

## Limitations

- **Max depth:** 10 levels (configurable, tier-dependent)
- **Timeout:** 24 hours per crawl
- **Max pages:** Varies by tier (Free: 50, Starter: 1000, Growth: 10000+)
- **Rate limits:** Apply per page scraped
- **Memory:** Very large crawls may need async mode

## Related Documentation

- [Scraping](./04-scraping.md)
- [Mapping](./06-mapping.md)
- [Python SDK](./15-python-sdk.md)
- [Async Operations](./17-async-operations.md)
- [API Reference](./12-crawl-endpoint.md)
