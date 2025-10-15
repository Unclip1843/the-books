# Firecrawl - Cost Optimization

**Sources:**
- https://docs.firecrawl.dev/
- https://www.firecrawl.dev/

**Fetched:** 2025-10-11

## Credit System

- Base scrape: 1 credit
- Screenshot: Included
- Stealth mode: +1 credit
- PDF parsing: +1 credit
- Extract: 2-5 credits

## Optimization Strategies

### 1. Use Cache
```python
# Saves credits on repeated requests
result = firecrawl.scrape(url)  # cache=True by default
```

### 2. Set Limits
```python
# Always limit crawls
result = firecrawl.crawl(url, limit=100)
```

### 3. Use Crawl Not Individual Scrapes
```python
# Good - 100 credits
result = firecrawl.crawl(url, limit=100)

# Bad - 100 individual requests
for url in urls:
    result = firecrawl.scrape(url)
```

### 4. Filter Paths
```python
# Only crawl what you need
result = firecrawl.crawl(
    url=url,
    includePaths=["/docs/*"],
    limit=50
)
```

### 5. Avoid Stealth When Not Needed
```python
# Only use stealth for protected sites
stealth=True  # +1 credit per page
```

## Related Documentation

- [Pricing](./36-pricing.md)
- [Best Practices](./32-best-practices.md)
