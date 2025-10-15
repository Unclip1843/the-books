# Firecrawl - API Overview

**Sources:**
- https://api.firecrawl.dev/
- https://docs.firecrawl.dev/api-reference/introduction

**Fetched:** 2025-10-11

## Base URL

```
https://api.firecrawl.dev
```

## API Versions

- **Current:** v1
- **Endpoints:** `/v1/{endpoint}`

## Authentication

All requests require Bearer token authentication:

```bash
Authorization: Bearer fc-YOUR-API-KEY
```

## Endpoints

### Scraping
```
POST   /v1/scrape           # Scrape single URL
```

### Crawling
```
POST   /v1/crawl            # Start crawl
GET    /v1/crawl/status/:id # Check crawl status
DELETE /v1/crawl/cancel/:id # Cancel crawl
```

### Mapping
```
POST   /v1/map              # Get all URLs from site
```

### Search
```
POST   /v1/search           # Web search with scraping
```

### Extract
```
POST   /v1/extract          # LLM-powered extraction
```

## Request Format

### Headers
```
Authorization: Bearer fc-YOUR-API-KEY
Content-Type: application/json
```

### Body
```json
{
  "url": "https://example.com",
  "formats": ["markdown"],
  "options": {...}
}
```

## Response Format

### Success Response
```json
{
  "success": true,
  "data": {
    "markdown": "# Content...",
    "metadata": {...}
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message",
  "statusCode": 400
}
```

## HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid API key |
| 402 | Payment Required - Out of credits |
| 429 | Too Many Requests - Rate limited |
| 500 | Internal Server Error |
| 503 | Service Unavailable |

## Rate Limits

### By Tier

| Tier | Requests/Min | Concurrent |
|------|--------------|------------|
| Free | 10 | 2 |
| Starter | 60 | 10 |
| Growth | 300 | 50 |
| Scale | 600 | 100 |
| Enterprise | Custom | Custom |

### Rate Limit Headers

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1609459200
```

### Handling Rate Limits

```python
import time
import requests

def request_with_retry(url, data, max_retries=3):
    for attempt in range(max_retries):
        response = requests.post(url, json=data, headers=headers)
        
        if response.status_code == 429:
            retry_after = int(response.headers.get('Retry-After', 60))
            print(f"Rate limited. Waiting {retry_after}s...")
            time.sleep(retry_after)
            continue
        
        return response.json()
    
    raise Exception("Max retries exceeded")
```

## Error Handling

### Common Errors

**401 Unauthorized**
```json
{
  "success": false,
  "error": "Invalid API key",
  "statusCode": 401
}
```

Solution: Check your API key format (should start with `fc-`)

**402 Payment Required**
```json
{
  "success": false,
  "error": "Insufficient credits",
  "statusCode": 402
}
```

Solution: Add credits to your account

**429 Rate Limit**
```json
{
  "success": false,
  "error": "Rate limit exceeded",
  "statusCode": 429
}
```

Solution: Slow down requests or upgrade plan

**500 Server Error**
```json
{
  "success": false,
  "error": "Internal server error",
  "statusCode": 500
}
```

Solution: Retry with exponential backoff

### Error Handling Example

```python
try:
    response = requests.post(
        "https://api.firecrawl.dev/v1/scrape",
        headers={"Authorization": f"Bearer {api_key}"},
        json={"url": "https://example.com"}
    )
    response.raise_for_status()
    data = response.json()
    
except requests.exceptions.HTTPError as e:
    if e.response.status_code == 401:
        print("Invalid API key")
    elif e.response.status_code == 402:
        print("Out of credits")
    elif e.response.status_code == 429:
        print("Rate limited")
    else:
        print(f"HTTP error: {e}")
        
except Exception as e:
    print(f"Error: {e}")
```

## Pagination

For endpoints that return multiple results:

```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 87,
    "hasMore": true
  }
}
```

## Timeouts

- **Default:** 60 seconds per request
- **Crawls:** Up to 24 hours (async mode)
- **Extract:** Variable based on complexity

### Setting Timeouts

```python
import requests

response = requests.post(
    url,
    json=data,
    headers=headers,
    timeout=120  # 2 minutes
)
```

## Webhooks

Configure webhooks for async operations:

```json
{
  "url": "https://example.com",
  "webhook": "https://your-api.com/webhook"
}
```

Webhook payload:
```json
{
  "status": "completed",
  "id": "job_abc123",
  "data": [...]
}
```

## Best Practices

### 1. Use HTTPS
Always use HTTPS for API requests (enforced).

### 2. Store API Keys Securely
```python
# Good - from environment
import os
api_key = os.environ.get("FIRECRAWL_API_KEY")

# Bad - hardcoded
api_key = "fc-abc123..."
```

### 3. Handle Errors
Always implement error handling and retries.

### 4. Monitor Rate Limits
Check `X-RateLimit-Remaining` header.

### 5. Use Async for Large Operations
For crawls > 50 pages, use async mode.

### 6. Set Reasonable Timeouts
Don't let requests hang indefinitely.

### 7. Validate Input
Check URLs before sending requests.

```python
from urllib.parse import urlparse

def is_valid_url(url):
    try:
        result = urlparse(url)
        return all([result.scheme, result.netloc])
    except:
        return False
```

## SDK vs Direct API

### Using SDK (Recommended)
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")
result = firecrawl.scrape("https://example.com")
```

**Benefits:**
- Automatic error handling
- Built-in retries
- Type hints
- Cleaner code

### Direct API Calls
```python
import requests

response = requests.post(
    "https://api.firecrawl.dev/v1/scrape",
    headers={"Authorization": "Bearer fc-YOUR-API-KEY"},
    json={"url": "https://example.com"}
)
```

**Use when:**
- SDK not available for your language
- Need fine-grained control
- Custom request handling

## Related Documentation

- [Authentication](./03-authentication.md)
- [Scrape Endpoint](./11-scrape-endpoint.md)
- [Crawl Endpoint](./12-crawl-endpoint.md)
- [Python SDK](./15-python-sdk.md)
- [Error Handling](./18-error-handling.md)
