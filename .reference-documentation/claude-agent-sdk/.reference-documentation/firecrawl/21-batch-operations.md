# Firecrawl - Batch Operations

**Sources:**
- https://docs.firecrawl.dev/
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Batch operations allow scraping multiple URLs efficiently while managing rate limits and costs.

## Basic Batch Scraping

### Python
```python
from firecrawl import Firecrawl
import time

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

urls = [
    "https://example.com/page1",
    "https://example.com/page2",
    "https://example.com/page3"
]

results = []
for url in urls:
    result = firecrawl.scrape(url)
    results.append(result)
    time.sleep(1)  # Rate limiting
```

### Node.js
```javascript
const urls = [
  'https://example.com/page1',
  'https://example.com/page2',
  'https://example.com/page3'
];

const results = [];
for (const url of urls) {
  const result = await firecrawl.scrapeUrl(url);
  results.push(result);
  await new Promise(resolve => setTimeout(resolve, 1000));
}
```

## Concurrent Batch Scraping

### Python with ThreadPoolExecutor
```python
from concurrent.futures import ThreadPoolExecutor, as_completed
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

def scrape_url(url):
    try:
        return firecrawl.scrape(url)
    except Exception as e:
        return {"url": url, "error": str(e)}

urls = [f"https://example.com/page{i}" for i in range(1, 51)]

# Scrape 5 URLs concurrently
with ThreadPoolExecutor(max_workers=5) as executor:
    futures = {executor.submit(scrape_url, url): url for url in urls}
    
    results = []
    for future in as_completed(futures):
        result = future.result()
        results.append(result)
        print(f"Completed: {futures[future]}")
```

### Python with asyncio
```python
import asyncio
from firecrawl import AsyncFirecrawl

async def scrape_batch(urls, concurrency=5):
    firecrawl = AsyncFirecrawl(api_key="fc-YOUR-API-KEY")
    
    semaphore = asyncio.Semaphore(concurrency)
    
    async def scrape_with_limit(url):
        async with semaphore:
            return await firecrawl.scrape(url)
    
    tasks = [scrape_with_limit(url) for url in urls]
    return await asyncio.gather(*tasks)

urls = [f"https://example.com/page{i}" for i in range(1, 51)]
results = asyncio.run(scrape_batch(urls, concurrency=5))
```

### Node.js with Promise.all
```javascript
async function scrapeBatch(urls, concurrency = 5) {
  const results = [];
  
  for (let i = 0; i < urls.length; i += concurrency) {
    const batch = urls.slice(i, i + concurrency);
    const batchResults = await Promise.all(
      batch.map(url => firecrawl.scrapeUrl(url))
    );
    results.push(...batchResults);
  }
  
  return results;
}

const urls = Array.from({length: 50}, (_, i) => 
  `https://example.com/page${i+1}`
);

const results = await scrapeBatch(urls, 5);
```

## Rate Limit Management

### Token Bucket Algorithm
```python
import time
from collections import deque

class RateLimiter:
    def __init__(self, max_requests, time_window):
        self.max_requests = max_requests
        self.time_window = time_window
        self.requests = deque()
    
    def wait_if_needed(self):
        now = time.time()
        
        # Remove old requests
        while self.requests and self.requests[0] < now - self.time_window:
            self.requests.popleft()
        
        # Wait if at limit
        if len(self.requests) >= self.max_requests:
            sleep_time = self.time_window - (now - self.requests[0])
            if sleep_time > 0:
                time.sleep(sleep_time)
            self.requests.popleft()
        
        self.requests.append(now)

# Usage: 10 requests per minute
limiter = RateLimiter(max_requests=10, time_window=60)

for url in urls:
    limiter.wait_if_needed()
    result = firecrawl.scrape(url)
```

### Adaptive Rate Limiting
```python
def adaptive_batch_scrape(urls):
    delay = 1.0  # Start with 1 second delay
    results = []
    
    for url in urls:
        try:
            result = firecrawl.scrape(url)
            results.append(result)
            
            # Success - reduce delay
            delay = max(0.5, delay * 0.9)
        
        except RateLimitError:
            # Rate limited - increase delay
            delay = min(10, delay * 2)
            time.sleep(delay)
            
            # Retry
            result = firecrawl.scrape(url)
            results.append(result)
        
        time.sleep(delay)
    
    return results
```

## Error Handling in Batches

### Collect Errors
```python
def batch_scrape_with_errors(urls):
    results = []
    errors = []
    
    for url in urls:
        try:
            result = firecrawl.scrape(url)
            results.append({
                'url': url,
                'status': 'success',
                'data': result
            })
        except Exception as e:
            errors.append({
                'url': url,
                'status': 'failed',
                'error': str(e)
            })
    
    return {
        'successful': len(results),
        'failed': len(errors),
        'results': results,
        'errors': errors
    }
```

### Retry Failed URLs
```python
def batch_scrape_with_retry(urls, max_retries=3):
    results = []
    failed_urls = urls.copy()
    
    for attempt in range(max_retries):
        if not failed_urls:
            break
        
        print(f"Attempt {attempt + 1}: {len(failed_urls)} URLs")
        
        retry_urls = []
        for url in failed_urls:
            try:
                result = firecrawl.scrape(url)
                results.append(result)
            except Exception as e:
                print(f"Failed: {url} - {e}")
                retry_urls.append(url)
        
        failed_urls = retry_urls
        
        if failed_urls and attempt < max_retries - 1:
            wait_time = (2 ** attempt) * 60
            print(f"Waiting {wait_time}s before retry...")
            time.sleep(wait_time)
    
    return results
```

## Progress Tracking

### Python with tqdm
```python
from tqdm import tqdm

urls = [f"https://example.com/page{i}" for i in range(1, 101)]
results = []

for url in tqdm(urls, desc="Scraping"):
    result = firecrawl.scrape(url)
    results.append(result)
    time.sleep(1)
```

### Custom Progress Reporter
```python
def batch_scrape_with_progress(urls):
    total = len(urls)
    results = []
    
    for i, url in enumerate(urls, 1):
        try:
            result = firecrawl.scrape(url)
            results.append(result)
            status = "✓"
        except Exception as e:
            status = f"✗ {e}"
        
        progress = (i / total) * 100
        print(f"[{i}/{total}] ({progress:.1f}%) {url} - {status}")
    
    return results
```

## Batch Optimization

### Use Crawl Instead
```python
# Bad - scraping 100 related URLs individually
urls = get_blog_post_urls()  # 100 URLs
for url in urls:
    result = firecrawl.scrape(url)

# Good - crawl instead
result = firecrawl.crawl(
    url="https://example.com/blog",
    limit=100
)
```

### Batch by Domain
```python
from urllib.parse import urlparse
from collections import defaultdict

def batch_by_domain(urls):
    by_domain = defaultdict(list)
    
    for url in urls:
        domain = urlparse(url).netloc
        by_domain[domain].append(url)
    
    results = []
    for domain, domain_urls in by_domain.items():
        print(f"Scraping {len(domain_urls)} URLs from {domain}")
        
        for url in domain_urls:
            result = firecrawl.scrape(url)
            results.append(result)
            time.sleep(0.5)  # Per-domain rate limit
    
    return results
```

## Complete Examples

### 1. Production Batch Scraper
```python
import time
import logging
from concurrent.futures import ThreadPoolExecutor

logging.basicConfig(level=logging.INFO)

class BatchScraper:
    def __init__(self, api_key, max_workers=5, delay=1.0):
        self.firecrawl = Firecrawl(api_key=api_key)
        self.max_workers = max_workers
        self.delay = delay
    
    def scrape_url(self, url):
        try:
            time.sleep(self.delay)
            result = self.firecrawl.scrape(url)
            logging.info(f"✓ {url}")
            return {"url": url, "status": "success", "data": result}
        except Exception as e:
            logging.error(f"✗ {url}: {e}")
            return {"url": url, "status": "failed", "error": str(e)}
    
    def scrape_batch(self, urls):
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            return list(executor.map(self.scrape_url, urls))

# Usage
scraper = BatchScraper(api_key="fc-YOUR-API-KEY", max_workers=3)
urls = [f"https://example.com/page{i}" for i in range(1, 51)]
results = scraper.scrape_batch(urls)

# Analyze results
successful = [r for r in results if r['status'] == 'success']
failed = [r for r in results if r['status'] == 'failed']

print(f"Successful: {len(successful)}, Failed: {len(failed)}")
```

### 2. CSV Batch Processor
```python
import csv

def process_url_csv(input_file, output_file):
    with open(input_file, 'r') as f:
        reader = csv.DictReader(f)
        urls = [row['url'] for row in reader]
    
    results = []
    for i, url in enumerate(urls, 1):
        print(f"Processing {i}/{len(urls)}: {url}")
        
        try:
            result = firecrawl.scrape(url)
            results.append({
                'url': url,
                'status': 'success',
                'title': result['metadata']['title'],
                'content_length': len(result['markdown'])
            })
        except Exception as e:
            results.append({
                'url': url,
                'status': 'failed',
                'error': str(e)
            })
        
        time.sleep(1)
    
    with open(output_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['url', 'status', 'title', 'content_length', 'error'])
        writer.writeheader()
        writer.writerows(results)

process_url_csv('urls.csv', 'results.csv')
```

### 3. Resumable Batch Scraper
```python
import json
import os

def resumable_batch_scrape(urls, checkpoint_file='checkpoint.json'):
    # Load checkpoint
    completed = set()
    if os.path.exists(checkpoint_file):
        with open(checkpoint_file, 'r') as f:
            completed = set(json.load(f))
    
    results = []
    for url in urls:
        if url in completed:
            print(f"Skipping (already done): {url}")
            continue
        
        try:
            result = firecrawl.scrape(url)
            results.append(result)
            completed.add(url)
            
            # Save checkpoint
            with open(checkpoint_file, 'w') as f:
                json.dump(list(completed), f)
            
            print(f"✓ {url}")
        except Exception as e:
            print(f"✗ {url}: {e}")
        
        time.sleep(1)
    
    return results
```

## Best Practices

### 1. Respect Rate Limits
```python
# Check your tier limits
# Free: 10 req/min
# Starter: 60 req/min
# Scale requests accordingly
```

### 2. Use Appropriate Concurrency
```python
# Free tier
max_workers=2

# Starter tier
max_workers=5

# Growth tier
max_workers=20
```

### 3. Implement Retries
```python
# Always retry failed URLs
# Use exponential backoff
```

### 4. Track Progress
```python
# Log successes and failures
# Save checkpoints
# Monitor rate limits
```

### 5. Optimize Costs
```python
# Use crawl for related URLs
# Batch by domain
# Filter unnecessary requests
```

## Related Documentation

- [Crawling](./05-crawling.md)
- [Error Handling](./18-error-handling.md)
- [Performance](./34-performance.md)
- [Cost Optimization](./33-cost-optimization.md)
