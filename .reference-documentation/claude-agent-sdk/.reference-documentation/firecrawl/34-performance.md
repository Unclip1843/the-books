# Firecrawl - Performance

**Sources:**
- https://docs.firecrawl.dev/
- https://www.firecrawl.dev/

**Fetched:** 2025-10-11

## Speed Optimization

### 1. Use Async for Large Crawls
```python
# Faster for 50+ pages
job = firecrawl.start_crawl(url, limit=500)
```

### 2. Parallel Scraping
```python
from concurrent.futures import ThreadPoolExecutor

with ThreadPoolExecutor(max_workers=5) as executor:
    results = list(executor.map(scrape_url, urls))
```

### 3. Reduce waitFor
```python
# Only wait when necessary
waitFor=2000  # Good
waitFor=10000  # Too long
```

### 4. Use Map for URL Discovery
```python
# Fast URL list
urls = firecrawl.map(site_url)
# Then scrape specific URLs
```

## Related Documentation

- [Async Operations](./17-async-operations.md)
- [Batch Operations](./21-batch-operations.md)
