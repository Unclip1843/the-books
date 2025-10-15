# Firecrawl - Monitoring

**Sources:**
- https://docs.firecrawl.dev/
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Monitor crawls, track progress, and handle long-running operations.

## Crawl Status

### Status Values

| Status | Description |
|--------|-------------|
| `scraping` | Crawl in progress |
| `completed` | Crawl finished successfully |
| `failed` | Crawl encountered error |
| `cancelled` | Crawl was cancelled |

### Checking Status

```python
job = firecrawl.start_crawl(url="https://example.com", limit=100)

status = firecrawl.get_crawl_status(job['id'])

print(f"Status: {status['status']}")
print(f"Progress: {status['completed']}/{status['total']}")
print(f"Credits used: {status['creditsUsed']}")
```

## Progress Monitoring

### Basic Polling
```python
import time

job = firecrawl.start_crawl(url="https://example.com", limit=100)

while True:
    status = firecrawl.get_crawl_status(job['id'])
    
    print(f"Status: {status['status']}")
    print(f"Completed: {status['completed']}/{status['total']}")
    
    if status['status'] in ['completed', 'failed', 'cancelled']:
        break
    
    time.sleep(10)
```

### Progress Bar
```python
from tqdm import tqdm
import time

job = firecrawl.start_crawl(url="https://example.com", limit=200)

with tqdm(total=200, desc="Crawling") as pbar:
    last_completed = 0
    
    while True:
        status = firecrawl.get_crawl_status(job['id'])
        
        # Update progress
        new_completed = status['completed'] - last_completed
        pbar.update(new_completed)
        last_completed = status['completed']
        
        if status['status'] in ['completed', 'failed']:
            break
        
        time.sleep(5)
```

### Real-Time Dashboard
```python
import time
import os

def monitor_crawl(job_id):
    while True:
        os.system('clear')  # Clear screen
        
        status = firecrawl.get_crawl_status(job_id)
        
        # Display dashboard
        print("=" * 50)
        print("FIRECRAWL MONITORING DASHBOARD")
        print("=" * 50)
        print(f"\nJob ID: {job_id}")
        print(f"Status: {status['status']}")
        print(f"Progress: {status['completed']}/{status['total']}")
        
        progress_pct = (status['completed'] / status['total']) * 100
        bar_length = 40
        filled = int(bar_length * progress_pct / 100)
        bar = '█' * filled + '░' * (bar_length - filled)
        print(f"\n[{bar}] {progress_pct:.1f}%")
        
        print(f"\nCredits Used: {status['creditsUsed']}")
        print(f"Expires At: {status.get('expiresAt', 'N/A')}")
        
        if status['status'] in ['completed', 'failed', 'cancelled']:
            print(f"\n✓ Crawl {status['status']}!")
            break
        
        time.sleep(5)
```

## WebSocket Monitoring

Real-time updates:

```python
import asyncio
import websockets
import json

async def monitor_with_websocket(job_id, api_key):
    ws_url = f"wss://api.firecrawl.dev/v1/crawl/{job_id}/stream"
    
    async with websockets.connect(ws_url, extra_headers={
        "Authorization": f"Bearer {api_key}"
    }) as ws:
        async for message in ws:
            data = json.loads(message)
            
            if data['type'] == 'page_started':
                print(f"→ Starting: {data['url']}")
            
            elif data['type'] == 'page_completed':
                print(f"✓ Completed: {data['url']}")
            
            elif data['type'] == 'page_failed':
                print(f"✗ Failed: {data['url']} - {data['error']}")
            
            elif data['type'] == 'crawl_completed':
                print("\n✓ Crawl finished!")
                break
            
            elif data['type'] == 'progress':
                print(f"Progress: {data['completed']}/{data['total']}")

# Usage
job = firecrawl.start_crawl("https://example.com", limit=100)
asyncio.run(monitor_with_websocket(job['id'], "fc-YOUR-API-KEY"))
```

## Webhook Monitoring

Receive HTTP callbacks:

```python
from flask import Flask, request
import json

app = Flask(__name__)

# Store crawl info
crawls = {}

@app.route('/webhook', methods=['POST'])
def handle_webhook():
    data = request.json
    
    job_id = data['id']
    status = data['status']
    
    if status == 'completed':
        pages = len(data['data'])
        print(f"✓ Crawl {job_id} completed: {pages} pages")
        
        crawls[job_id] = {
            'status': 'completed',
            'pages': pages,
            'data': data['data']
        }
    
    elif status == 'failed':
        error = data.get('error')
        print(f"✗ Crawl {job_id} failed: {error}")
        
        crawls[job_id] = {
            'status': 'failed',
            'error': error
        }
    
    return {'status': 'received'}, 200

if __name__ == '__main__':
    app.run(port=8000)

# Start crawl with webhook
job = firecrawl.start_crawl(
    url="https://example.com",
    limit=100,
    webhook="http://your-server.com/webhook"
)
```

## Error Monitoring

### Track Failed Pages
```python
def monitor_with_error_tracking(job_id):
    failed_pages = []
    
    while True:
        status = firecrawl.get_crawl_status(job_id)
        
        # Check for errors
        if 'errors' in status:
            for error in status['errors']:
                if error not in failed_pages:
                    failed_pages.append(error)
                    print(f"✗ Error: {error['url']} - {error['message']}")
        
        if status['status'] in ['completed', 'failed']:
            break
        
        time.sleep(10)
    
    return failed_pages
```

### Retry Failed Pages
```python
def monitor_and_retry(job_id, max_retries=3):
    while True:
        status = firecrawl.get_crawl_status(job_id)
        
        if status['status'] == 'failed':
            failed_urls = status.get('failedUrls', [])
            
            if failed_urls and max_retries > 0:
                print(f"Retrying {len(failed_urls)} failed URLs...")
                
                for url in failed_urls:
                    try:
                        result = firecrawl.scrape(url)
                        print(f"✓ Retry successful: {url}")
                    except Exception as e:
                        print(f"✗ Retry failed: {url} - {e}")
                
                max_retries -= 1
            break
        
        elif status['status'] == 'completed':
            break
        
        time.sleep(10)
```

## Performance Monitoring

### Track Speed
```python
import time

def monitor_with_performance(job_id):
    start_time = time.time()
    last_check = start_time
    last_completed = 0
    
    while True:
        status = firecrawl.get_crawl_status(job_id)
        now = time.time()
        
        # Calculate metrics
        elapsed = now - start_time
        new_completed = status['completed'] - last_completed
        time_since_last = now - last_check
        
        if time_since_last > 0:
            rate = new_completed / time_since_last
            
            print(f"Progress: {status['completed']}/{status['total']}")
            print(f"Rate: {rate:.2f} pages/sec")
            print(f"Elapsed: {elapsed:.1f}s")
            
            if rate > 0:
                remaining = status['total'] - status['completed']
                eta = remaining / rate
                print(f"ETA: {eta:.1f}s")
        
        if status['status'] in ['completed', 'failed']:
            total_time = time.time() - start_time
            avg_rate = status['completed'] / total_time
            print(f"\nCompleted in {total_time:.1f}s")
            print(f"Average: {avg_rate:.2f} pages/sec")
            break
        
        last_completed = status['completed']
        last_check = now
        time.sleep(10)
```

## Credit Monitoring

### Track Usage
```python
def monitor_with_credits(job_id):
    initial_credits = get_account_credits()
    
    while True:
        status = firecrawl.get_crawl_status(job_id)
        
        print(f"Credits used: {status['creditsUsed']}")
        print(f"Estimated total: {status['total']} credits")
        print(f"Remaining balance: {initial_credits - status['creditsUsed']}")
        
        if status['status'] in ['completed', 'failed']:
            break
        
        time.sleep(10)
```

### Budget Alerts
```python
def monitor_with_budget(job_id, max_credits=1000):
    while True:
        status = firecrawl.get_crawl_status(job_id)
        
        if status['creditsUsed'] > max_credits * 0.9:
            print(f"⚠️ WARNING: 90% of budget used!")
        
        if status['creditsUsed'] >= max_credits:
            print(f"🛑 Budget exceeded! Cancelling crawl...")
            firecrawl.cancel_crawl(job_id)
            break
        
        if status['status'] in ['completed', 'failed']:
            break
        
        time.sleep(10)
```

## Complete Monitoring Example

```python
import time
import logging
from datetime import datetime

logging.basicConfig(level=logging.INFO)

class CrawlMonitor:
    def __init__(self, job_id):
        self.job_id = job_id
        self.start_time = time.time()
        self.last_check = self.start_time
        self.last_completed = 0
    
    def monitor(self):
        logging.info(f"Monitoring crawl: {self.job_id}")
        
        while True:
            try:
                status = firecrawl.get_crawl_status(self.job_id)
                self.log_status(status)
                
                if status['status'] in ['completed', 'failed', 'cancelled']:
                    self.log_completion(status)
                    break
                
                time.sleep(10)
            
            except Exception as e:
                logging.error(f"Monitoring error: {e}")
                time.sleep(30)
    
    def log_status(self, status):
        now = time.time()
        elapsed = now - self.start_time
        new_completed = status['completed'] - self.last_completed
        time_since_last = now - self.last_check
        
        if time_since_last > 0:
            rate = new_completed / time_since_last
            
            logging.info(
                f"Progress: {status['completed']}/{status['total']} | "
                f"Rate: {rate:.2f} p/s | "
                f"Credits: {status['creditsUsed']} | "
                f"Elapsed: {elapsed:.0f}s"
            )
        
        self.last_completed = status['completed']
        self.last_check = now
    
    def log_completion(self, status):
        total_time = time.time() - self.start_time
        avg_rate = status['completed'] / total_time if total_time > 0 else 0
        
        logging.info(
            f"\n{'='*60}\n"
            f"Crawl {status['status']}!\n"
            f"Total pages: {status['completed']}\n"
            f"Total time: {total_time:.1f}s\n"
            f"Average rate: {avg_rate:.2f} pages/sec\n"
            f"Credits used: {status['creditsUsed']}\n"
            f"{'='*60}"
        )

# Usage
job = firecrawl.start_crawl("https://example.com", limit=200)
monitor = CrawlMonitor(job['id'])
monitor.monitor()
```

## Best Practices

### 1. Poll Reasonably
```python
# Good - 10 second intervals
time.sleep(10)

# Bad - too frequent
time.sleep(1)
```

### 2. Handle Errors
```python
try:
    status = get_crawl_status(job_id)
except Exception as e:
    logging.error(f"Error: {e}")
    time.sleep(30)  # Wait longer on error
```

### 3. Log Everything
```python
logging.info(f"Started: {job_id}")
logging.info(f"Progress: {completed}/{total}")
logging.error(f"Failed: {error}")
```

### 4. Set Timeouts
```python
max_time = 3600  # 1 hour
if elapsed > max_time:
    cancel_crawl(job_id)
```

## Related Documentation

- [Async Operations](./17-async-operations.md)
- [Crawling](./05-crawling.md)
- [Error Handling](./18-error-handling.md)
