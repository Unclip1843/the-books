# Firecrawl - Best Practices

**Sources:**
- https://docs.firecrawl.dev/
- https://www.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Best practices for using Firecrawl effectively.

## 1. Choose the Right Method

| Method | Use When |
|--------|----------|
| Scrape | Single page needed |
| Crawl | Entire site or section |
| Map | Just need URL list |
| Search | Finding information |
| Extract | Need structured data |

## 2. Always Set Limits

```python
# Good
result = firecrawl.crawl(url, limit=100)

# Bad - could cost thousands
result = firecrawl.crawl(url)
```

## 3. Use Cache

```python
# Default behavior - uses cache
result = firecrawl.scrape(url)

# Only bypass when needed
result = firecrawl.scrape(url, cache=False)
```

## 4. Filter Content

```python
result = firecrawl.scrape(
    url=url,
    onlyMainContent=True,
    excludeTags=["nav", "footer"]
)
```

## 5. Handle Errors

```python
try:
    result = firecrawl.scrape(url)
except Exception as e:
    logging.error(f"Error: {e}")
```

## 6. Monitor Rate Limits

Check your tier and stay within limits.

## 7. Use Async for Large Operations

```python
if pages > 50:
    job = firecrawl.start_crawl(url, limit=pages)
    # Poll for status
```

## Related Documentation

- [Cost Optimization](./33-cost-optimization.md)
- [Performance](./34-performance.md)
- [Error Handling](./18-error-handling.md)
