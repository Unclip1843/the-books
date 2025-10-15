# Firecrawl - Caching

**Sources:**
- https://docs.firecrawl.dev/
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Caching allows reusing previously scraped content to reduce costs and improve performance.

## How Caching Works

```
Request → Check Cache → Return Cached (if fresh) OR Scrape & Cache
```

**Default behavior:** Firecrawl automatically caches scraped content.

## Cache Duration

**Default TTL:** 24 hours

Content is cached for 24 hours by default. Subsequent requests within this window return cached data.

## Cache Control

### Bypass Cache
Force fresh scrape:

```python
result = firecrawl.scrape(
    url="https://example.com",
    cache=False  # Bypass cache, force fresh scrape
)
```

### Use Cache (Default)
```python
result = firecrawl.scrape(
    url="https://example.com"
    # cache=True is default
)
```

## Cost Savings

### Without Cache
```python
# First request: 1 credit
result1 = firecrawl.scrape("https://example.com", cache=False)

# Second request: 1 credit (total: 2 credits)
result2 = firecrawl.scrape("https://example.com", cache=False)
```

### With Cache
```python
# First request: 1 credit
result1 = firecrawl.scrape("https://example.com")

# Second request within 24h: 0 credits (total: 1 credit)
result2 = firecrawl.scrape("https://example.com")
```

## When to Use Cache

### Good Use Cases

**1. Static Content**
```python
# Documentation pages
result = firecrawl.scrape("https://docs.example.com/api")

# About pages
result = firecrawl.scrape("https://example.com/about")
```

**2. Infrequently Updated Content**
```python
# Company information
result = firecrawl.scrape("https://example.com/company")

# Product catalogs (updated daily)
result = firecrawl.scrape("https://example.com/products")
```

**3. Development/Testing**
```python
# During development
result = firecrawl.scrape("https://example.com", cache=True)
# Repeat scrapes use cache - saves credits
```

## When to Bypass Cache

### Force Fresh Data

**1. Real-Time Data**
```python
# Stock prices
result = firecrawl.scrape(
    "https://example.com/stock-price",
    cache=False
)

# Live news
result = firecrawl.scrape(
    "https://news.example.com",
    cache=False
)
```

**2. Dynamic Content**
```python
# Social media feeds
result = firecrawl.scrape(
    "https://twitter.com/user",
    cache=False
)

# Search results
result = firecrawl.scrape(
    "https://example.com/search?q=query",
    cache=False
)
```

**3. Frequent Updates**
```python
# Job listings (updated hourly)
result = firecrawl.scrape(
    "https://example.com/jobs",
    cache=False
)
```

## Cache Strategy Examples

### 1. Smart Caching
```python
from datetime import datetime, timedelta

class SmartScraper:
    def __init__(self):
        self.last_scrape = {}
    
    def scrape(self, url, max_age_hours=24):
        now = datetime.now()
        
        # Check if we have recent scrape
        if url in self.last_scrape:
            age = now - self.last_scrape[url]
            if age < timedelta(hours=max_age_hours):
                # Use cache
                return firecrawl.scrape(url, cache=True)
        
        # Force fresh scrape
        result = firecrawl.scrape(url, cache=False)
        self.last_scrape[url] = now
        return result
```

### 2. Conditional Caching
```python
def scrape_with_conditional_cache(url, content_type):
    cache_config = {
        'static': True,      # Use cache
        'dynamic': False,    # Force fresh
        'news': False,       # Force fresh
        'docs': True         # Use cache
    }
    
    use_cache = cache_config.get(content_type, True)
    
    return firecrawl.scrape(url, cache=use_cache)

# Usage
docs_result = scrape_with_conditional_cache(
    "https://example.com/docs",
    content_type='docs'
)

news_result = scrape_with_conditional_cache(
    "https://example.com/news",
    content_type='news'
)
```

### 3. Time-Based Cache Control
```python
from datetime import datetime

def scrape_with_time_cache(url):
    hour = datetime.now().hour
    
    # Fresh data during business hours
    if 9 <= hour <= 17:
        cache = False
    else:
        cache = True
    
    return firecrawl.scrape(url, cache=cache)
```

### 4. Local Cache Layer
```python
import json
import os
from datetime import datetime, timedelta

class LocalCachedScraper:
    def __init__(self, cache_dir='./cache'):
        self.cache_dir = cache_dir
        os.makedirs(cache_dir, exist_ok=True)
        self.firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")
    
    def get_cache_path(self, url):
        # Create safe filename from URL
        filename = url.replace('https://', '').replace('/', '_')
        return os.path.join(self.cache_dir, f"{filename}.json")
    
    def scrape(self, url, max_age_hours=24):
        cache_path = self.get_cache_path(url)
        
        # Check local cache
        if os.path.exists(cache_path):
            with open(cache_path, 'r') as f:
                cached = json.load(f)
            
            cached_time = datetime.fromisoformat(cached['timestamp'])
            age = datetime.now() - cached_time
            
            if age < timedelta(hours=max_age_hours):
                print(f"Using local cache for {url}")
                return cached['data']
        
        # Scrape fresh
        print(f"Scraping fresh: {url}")
        result = self.firecrawl.scrape(url)
        
        # Save to local cache
        with open(cache_path, 'w') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'url': url,
                'data': result
            }, f)
        
        return result

# Usage
scraper = LocalCachedScraper()
result = scraper.scrape("https://example.com", max_age_hours=12)
```

## Monitoring Cache Usage

```python
def scrape_with_cache_monitoring(url, use_cache=True):
    import time
    
    start = time.time()
    result = firecrawl.scrape(url, cache=use_cache)
    elapsed = time.time() - start
    
    # Cached responses are typically much faster
    if elapsed < 0.5:
        print(f"✓ Cache hit: {url} ({elapsed:.2f}s)")
    else:
        print(f"○ Fresh scrape: {url} ({elapsed:.2f}s)")
    
    return result
```

## Best Practices

### 1. Default to Cache
```python
# Good - saves credits
result = firecrawl.scrape(url)

# Only bypass when needed
if need_fresh_data:
    result = firecrawl.scrape(url, cache=False)
```

### 2. Document Cache Strategy
```python
# Clear documentation
CACHE_SETTINGS = {
    'docs': {'cache': True, 'reason': 'Updated weekly'},
    'news': {'cache': False, 'reason': 'Real-time data'},
    'about': {'cache': True, 'reason': 'Static content'}
}
```

### 3. Monitor Cache Effectiveness
```python
cache_hits = 0
cache_misses = 0

# Track cache usage
# Adjust strategy based on hit rate
```

### 4. Combine with Local Caching
```python
# Layer 1: Local cache (instant, free)
# Layer 2: Firecrawl cache (fast, free)
# Layer 3: Fresh scrape (slow, 1 credit)
```

## Cost Comparison

### Example: 100 URLs, Scraped 10 Times Each

**Without Cache:**
- Total requests: 1,000
- Cost: 1,000 credits

**With Cache (24h TTL):**
- First scrapes: 100 credits
- Cached scrapes: 0 credits
- Total: 100 credits
- **Savings: 900 credits (90%)**

## Related Documentation

- [Scraping](./04-scraping.md)
- [Cost Optimization](./33-cost-optimization.md)
- [Best Practices](./32-best-practices.md)
