# Firecrawl - Limits & Quotas

**Sources:**
- https://docs.firecrawl.dev/
- https://www.firecrawl.dev/

**Fetched:** 2025-10-11

## Rate Limits

| Tier | Requests/Min | Concurrent |
|------|--------------|------------|
| Free | 10 | 2 |
| Starter | 60 | 10 |
| Growth | 300 | 50 |
| Scale | 600 | 100 |
| Enterprise | Custom | Custom |

## Request Limits

- **Timeout:** 60 seconds (default)
- **Max timeout:** 120 seconds
- **Page size:** 10MB max
- **PDF size:** 32MB max
- **PDF pages:** 100 max

## Crawl Limits

- **Max depth:** 10 levels (default)
- **Max pages:** Tier-dependent
- **Crawl duration:** 24 hours max
- **Results expiration:** 24 hours

## Best Practices

### 1. Stay Within Limits
```python
# Check your tier limits
# Adjust concurrency accordingly
```

### 2. Use Async for Large Operations
```python
# For > 50 pages
job = firecrawl.start_crawl(url, limit=500)
```

### 3. Monitor Usage
```python
# Track credits used
# Set budget alerts
```

## Related Documentation

- [Pricing](./36-pricing.md)
- [Authentication](./03-authentication.md)
- [Error Handling](./18-error-handling.md)
