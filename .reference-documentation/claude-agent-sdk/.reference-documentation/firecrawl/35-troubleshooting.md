# Firecrawl - Troubleshooting

**Sources:**
- https://docs.firecrawl.dev/
- https://www.firecrawl.dev/

**Fetched:** 2025-10-11

## Common Issues

### 1. Authentication Error (401)
**Problem:** Invalid API key

**Solution:**
- Check key format (starts with `fc-`)
- Verify key is active
- Check for extra spaces

### 2. Out of Credits (402)
**Problem:** Insufficient credits

**Solution:**
- Add credits to account
- Upgrade subscription tier

### 3. Rate Limited (429)
**Problem:** Too many requests

**Solution:**
- Slow down request rate
- Add delays between requests
- Upgrade tier

### 4. Timeout
**Problem:** Request taking too long

**Solution:**
- Increase timeout parameter
- Use async mode for large crawls
- Reduce waitFor value

### 5. Empty Content
**Problem:** Page returns no content

**Solution:**
- Check if page requires JavaScript
- Add waitFor parameter
- Use stealth mode

### 6. Missing Elements
**Problem:** Content not captured

**Solution:**
- Increase waitFor
- Use actions to trigger loading
- Check if content is in iframe

## Debugging

```python
# Enable logging
import logging
logging.basicConfig(level=logging.DEBUG)

# Test scrape
result = firecrawl.scrape(url)
print(f"Status: {result['metadata']['statusCode']}")
print(f"Length: {len(result['markdown'])}")
```

## Related Documentation

- [Error Handling](./18-error-handling.md)
- [Best Practices](./32-best-practices.md)
