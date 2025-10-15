# Firecrawl - Async Operations

**Sources:**
- https://docs.firecrawl.dev/features/crawl
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Async operations allow long-running crawls without blocking your application. Essential for crawling large websites (>50 pages).

## When to Use Async

| Pages | Method | Why |
|-------|--------|-----|
| < 10 | Sync crawl | Fast, immediate results |
| 10-50 | Sync crawl | Manageable wait time |
| > 50 | Async crawl | Avoid timeouts |
| > 500 | Async + webhook | Best for large operations |

## Async Crawl Pattern

```python
# 1. Start crawl
job = firecrawl.start_crawl(url, limit=500)

# 2. Poll for status
while True:
    status = firecrawl.get_crawl_status(job['id'])
    if status['status'] in ['completed', 'failed']:
        break
    time.sleep(10)

# 3. Process results
pages = status['data']
```

## WebSocket Streaming

Real-time updates as pages are scraped:

### Python
```python
import asyncio
import websockets
import json

async def stream_crawl(url):
    job = firecrawl.start_crawl(url, limit=100)
    
    ws_url = f"wss://api.firecrawl.dev/v1/crawl/{job['id']}/stream"
    
    async with websockets.connect(ws_url, extra_headers={
        "Authorization": f"Bearer {api_key}"
    }) as ws:
        async for message in ws:
            data = json.loads(message)
            
            if data['type'] == 'page_completed':
                print(f"✓ {data['url']}")
            elif data['type'] == 'crawl_completed':
                print("Crawl finished!")
                break
            elif data['type'] == 'error':
                print(f"✗ Error: {data['message']}")

asyncio.run(stream_crawl("https://example.com"))
```

### Node.js
```javascript
import WebSocket from 'ws';

const job = await firecrawl.asyncCrawlUrl('https://example.com', {
  limit: 100
});

const ws = new WebSocket(
  `wss://api.firecrawl.dev/v1/crawl/${job.id}/stream`,
  {
    headers: {
      'Authorization': `Bearer ${apiKey}`
    }
  }
);

ws.on('message', (data) => {
  const message = JSON.parse(data);
  
  if (message.type === 'page_completed') {
    console.log(`✓ ${message.url}`);
  } else if (message.type === 'crawl_completed') {
    console.log('Crawl finished!');
    ws.close();
  } else if (message.type === 'error') {
    console.error(`✗ Error: ${message.message}`);
  }
});
```

## Webhook Notifications

HTTP callbacks when crawl completes:

```python
# Start with webhook
job = firecrawl.start_crawl(
    url="https://example.com",
    limit=500,
    webhook="https://your-api.com/firecrawl-webhook"
)

# Your webhook endpoint
@app.post("/firecrawl-webhook")
def handle_crawl(data: dict):
    if data['status'] == 'completed':
        pages = data['data']
        process_pages(pages)
```

## Status Polling

### Basic Polling
```python
import time

job = firecrawl.start_crawl(url, limit=100)

while True:
    status = firecrawl.get_crawl_status(job['id'])
    
    if status['status'] == 'completed':
        print(f"Done! {len(status['data'])} pages")
        break
    
    print(f"{status['completed']}/{status['total']}")
    time.sleep(10)
```

### Smart Polling with Backoff
```python
import time

def smart_poll(job_id, initial_delay=5, max_delay=60):
    delay = initial_delay
    
    while True:
        status = firecrawl.get_crawl_status(job_id)
        
        if status['status'] in ['completed', 'failed']:
            return status
        
        time.sleep(delay)
        delay = min(delay * 1.5, max_delay)  # Exponential backoff
```

## Complete Examples

### 1. Async with Progress Bar
```python
from tqdm import tqdm
import time

job = firecrawl.start_crawl(url="https://example.com", limit=200)

with tqdm(total=200, desc="Crawling") as pbar:
    last_completed = 0
    
    while True:
        status = firecrawl.get_crawl_status(job['id'])
        
        # Update progress bar
        new_completed = status['completed'] - last_completed
        pbar.update(new_completed)
        last_completed = status['completed']
        
        if status['status'] == 'completed':
            print("\nCrawl completed!")
            break
        
        time.sleep(5)

pages = status['data']
```

### 2. Multiple Concurrent Crawls
```python
import asyncio

async def crawl_site(url, limit):
    job = firecrawl.start_crawl(url, limit=limit)
    
    while True:
        status = firecrawl.get_crawl_status(job['id'])
        if status['status'] in ['completed', 'failed']:
            return status
        await asyncio.sleep(10)

async def crawl_multiple(sites):
    tasks = [crawl_site(url, 100) for url in sites]
    results = await asyncio.gather(*tasks)
    return results

sites = [
    "https://example1.com",
    "https://example2.com",
    "https://example3.com"
]

results = asyncio.run(crawl_multiple(sites))
```

### 3. Webhook Server (Flask)
```python
from flask import Flask, request
import json

app = Flask(__name__)

@app.route('/firecrawl-webhook', methods=['POST'])
def handle_webhook():
    data = request.json
    
    job_id = data['id']
    status = data['status']
    
    if status == 'completed':
        pages = data['data']
        print(f"Job {job_id} completed with {len(pages)} pages")
        
        # Process pages
        for page in pages:
            process_page(page)
    
    elif status == 'failed':
        error = data.get('error')
        print(f"Job {job_id} failed: {error}")
    
    return {'status': 'received'}, 200

if __name__ == '__main__':
    app.run(port=8000)
```

### 4. Retry Logic
```python
def async_crawl_with_retry(url, limit, max_retries=3):
    for attempt in range(max_retries):
        try:
            job = firecrawl.start_crawl(url, limit=limit)
            
            while True:
                status = firecrawl.get_crawl_status(job['id'])
                
                if status['status'] == 'completed':
                    return status['data']
                
                elif status['status'] == 'failed':
                    error = status.get('error')
                    print(f"Attempt {attempt + 1} failed: {error}")
                    break
                
                time.sleep(10)
        
        except Exception as e:
            print(f"Attempt {attempt + 1} error: {e}")
        
        if attempt < max_retries - 1:
            wait_time = (2 ** attempt) * 60  # Exponential backoff
            print(f"Retrying in {wait_time}s...")
            time.sleep(wait_time)
    
    raise Exception("Max retries exceeded")
```

## Best Practices

### 1. Use Webhooks for Large Crawls
```python
# Good - for 500+ pages
job = firecrawl.start_crawl(
    url=url,
    limit=1000,
    webhook="https://your-api.com/webhook"
)

# Less ideal - polling 1000 pages
job = firecrawl.start_crawl(url=url, limit=1000)
# ... poll for hours
```

### 2. Implement Exponential Backoff
```python
# Good
delay = 5
while True:
    status = get_status()
    time.sleep(delay)
    delay = min(delay * 1.5, 60)  # Cap at 60s

# Bad - constant polling
while True:
    status = get_status()
    time.sleep(1)  # Too frequent
```

### 3. Handle All Status States
```python
status = get_crawl_status(job_id)

if status['status'] == 'completed':
    # Process results
elif status['status'] == 'failed':
    # Handle error
elif status['status'] == 'cancelled':
    # Handle cancellation
else:  # scraping
    # Continue waiting
```

### 4. Set Timeouts
```python
import time

job = start_crawl(url, limit=100)
start_time = time.time()
timeout = 3600  # 1 hour

while True:
    if time.time() - start_time > timeout:
        cancel_crawl(job['id'])
        raise TimeoutError("Crawl took too long")
    
    status = get_status(job['id'])
    if status['status'] in ['completed', 'failed']:
        break
    
    time.sleep(10)
```

### 5. Store Job IDs
```python
import json

# Start crawl
job = firecrawl.start_crawl(url, limit=500)

# Save job ID
with open('crawl_jobs.json', 'a') as f:
    json.dump({'id': job['id'], 'url': url, 'started': time.time()}, f)
    f.write('\n')

# Can resume later
with open('crawl_jobs.json') as f:
    for line in f:
        job_data = json.loads(line)
        status = firecrawl.get_crawl_status(job_data['id'])
        # Check status
```

## Related Documentation

- [Crawling](./05-crawling.md)
- [Monitoring](./23-monitoring.md)
- [Python SDK](./15-python-sdk.md)
- [API Reference](./12-crawl-endpoint.md)
