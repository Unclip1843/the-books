# Firecrawl - Error Handling

**Sources:**
- https://docs.firecrawl.dev/
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## HTTP Status Codes

| Code | Error | Meaning |
|------|-------|---------|
| 200 | Success | Request completed successfully |
| 400 | Bad Request | Invalid parameters or malformed request |
| 401 | Unauthorized | Invalid or missing API key |
| 402 | Payment Required | Insufficient credits |
| 403 | Forbidden | Access denied |
| 404 | Not Found | Resource not found |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error, retry with backoff |
| 503 | Service Unavailable | Service temporarily unavailable |

## Common Errors

### 401 Unauthorized

**Cause:** Invalid API key

```json
{
  "success": false,
  "error": "Invalid API key",
  "statusCode": 401
}
```

**Solutions:**
- Check API key format (starts with `fc-`)
- Verify key is active in dashboard
- Check for extra spaces when copying

### 402 Payment Required

**Cause:** Out of credits

```json
{
  "success": false,
  "error": "Insufficient credits",
  "statusCode": 402
}
```

**Solutions:**
- Add credits to account
- Check current usage in dashboard
- Upgrade subscription tier

### 429 Rate Limited

**Cause:** Too many requests

```json
{
  "success": false,
  "error": "Rate limit exceeded",
  "statusCode": 429,
  "retryAfter": 60
}
```

**Solutions:**
- Slow down request rate
- Implement exponential backoff
- Upgrade to higher tier
- Check `Retry-After` header

### 500 Internal Server Error

**Cause:** Server-side error

```json
{
  "success": false,
  "error": "Internal server error",
  "statusCode": 500
}
```

**Solutions:**
- Retry request with exponential backoff
- Check Firecrawl status page
- Contact support if persistent

## Error Handling Patterns

### Python - Try/Except
```python
from firecrawl import Firecrawl
from firecrawl.exceptions import (
    FirecrawlError,
    AuthenticationError,
    RateLimitError,
    PaymentRequiredError
)

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

try:
    result = firecrawl.scrape("https://example.com")
except AuthenticationError:
    print("Invalid API key - check credentials")
except PaymentRequiredError:
    print("Out of credits - add more credits")
except RateLimitError as e:
    print(f"Rate limited - wait {e.retry_after}s")
except FirecrawlError as e:
    print(f"Error: {e}")
```

### Node.js - Try/Catch
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });

try {
  const result = await firecrawl.scrapeUrl('https://example.com');
  console.log(result.markdown);
} catch (error) {
  if (error.response) {
    switch (error.response.status) {
      case 401:
        console.error('Invalid API key');
        break;
      case 402:
        console.error('Out of credits');
        break;
      case 429:
        console.error('Rate limited');
        break;
      default:
        console.error(`Error: ${error.message}`);
    }
  } else {
    console.error(`Network error: ${error.message}`);
  }
}
```

## Retry Strategies

### Simple Retry
```python
import time

def scrape_with_retry(url, max_retries=3):
    for attempt in range(max_retries):
        try:
            return firecrawl.scrape(url)
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            print(f"Attempt {attempt + 1} failed: {e}")
            time.sleep(2)
```

### Exponential Backoff
```python
import time

def scrape_with_backoff(url, max_retries=5):
    for attempt in range(max_retries):
        try:
            return firecrawl.scrape(url)
        except RateLimitError as e:
            if attempt == max_retries - 1:
                raise
            
            wait_time = (2 ** attempt) + (e.retry_after or 0)
            print(f"Rate limited. Waiting {wait_time}s...")
            time.sleep(wait_time)
        except FirecrawlError as e:
            if attempt == max_retries - 1:
                raise
            
            wait_time = 2 ** attempt
            print(f"Error: {e}. Retrying in {wait_time}s...")
            time.sleep(wait_time)
```

### Smart Retry (Selective)
```python
def should_retry(error):
    """Determine if error is retryable"""
    if isinstance(error, AuthenticationError):
        return False  # Don't retry auth errors
    if isinstance(error, PaymentRequiredError):
        return False  # Don't retry payment errors
    return True  # Retry other errors

def smart_scrape(url, max_retries=3):
    for attempt in range(max_retries):
        try:
            return firecrawl.scrape(url)
        except FirecrawlError as e:
            if not should_retry(e) or attempt == max_retries - 1:
                raise
            
            wait_time = 2 ** attempt
            print(f"Retrying in {wait_time}s...")
            time.sleep(wait_time)
```

## Timeout Handling

### Python
```python
import requests
from requests.exceptions import Timeout

try:
    result = firecrawl.scrape(url, timeout=30000)  # 30 seconds
except Timeout:
    print("Request timed out - try increasing timeout")
```

### Node.js
```javascript
const firecrawl = new Firecrawl({
  apiKey: 'fc-YOUR-API-KEY',
  timeout: 30000  // 30 seconds
});

try {
  const result = await firecrawl.scrapeUrl(url);
} catch (error) {
  if (error.code === 'ECONNABORTED') {
    console.error('Request timed out');
  }
}
```

## Graceful Degradation

```python
def scrape_with_fallback(url):
    """Try scraping with fallback options"""
    
    # Try with best options first
    try:
        return firecrawl.scrape(
            url,
            formats=["markdown", "html", "screenshot"],
            stealth=True
        )
    except Exception as e:
        print(f"Full scrape failed: {e}")
    
    # Fallback: Try without stealth
    try:
        return firecrawl.scrape(
            url,
            formats=["markdown"]
        )
    except Exception as e:
        print(f"Simple scrape failed: {e}")
    
    # Last resort: Return error info
    return {
        "error": "All scrape attempts failed",
        "url": url
    }
```

## Logging Errors

```python
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def scrape_with_logging(url):
    try:
        logger.info(f"Scraping {url}")
        result = firecrawl.scrape(url)
        logger.info(f"Successfully scraped {url}")
        return result
    
    except AuthenticationError as e:
        logger.error(f"Auth error for {url}: {e}")
        raise
    
    except RateLimitError as e:
        logger.warning(f"Rate limited on {url}: {e}")
        raise
    
    except FirecrawlError as e:
        logger.error(f"Error scraping {url}: {e}")
        raise
```

## Batch Error Handling

```python
def batch_scrape_safe(urls):
    """Scrape multiple URLs with error handling"""
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

## Circuit Breaker Pattern

```python
from datetime import datetime, timedelta

class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failures = 0
        self.last_failure = None
        self.state = 'closed'  # closed, open, half-open
    
    def call(self, func, *args, **kwargs):
        if self.state == 'open':
            if datetime.now() - self.last_failure > timedelta(seconds=self.timeout):
                self.state = 'half-open'
            else:
                raise Exception("Circuit breaker is open")
        
        try:
            result = func(*args, **kwargs)
            self.on_success()
            return result
        except Exception as e:
            self.on_failure()
            raise
    
    def on_success(self):
        self.failures = 0
        self.state = 'closed'
    
    def on_failure(self):
        self.failures += 1
        self.last_failure = datetime.now()
        
        if self.failures >= self.failure_threshold:
            self.state = 'open'

# Usage
breaker = CircuitBreaker(failure_threshold=3, timeout=60)

try:
    result = breaker.call(firecrawl.scrape, url)
except Exception as e:
    print(f"Error: {e}")
```

## Best Practices

### 1. Always Handle Errors
```python
# Good
try:
    result = firecrawl.scrape(url)
except Exception as e:
    logger.error(f"Error: {e}")
    return None

# Bad
result = firecrawl.scrape(url)  # No error handling
```

### 2. Use Specific Exceptions
```python
# Good
except AuthenticationError:
    # Handle auth specifically
except RateLimitError:
    # Handle rate limit specifically

# Less specific
except Exception:
    # Handle all errors the same
```

### 3. Implement Retries
```python
# Good - with retries
result = scrape_with_retry(url, max_retries=3)

# Bad - no retries
result = firecrawl.scrape(url)
```

### 4. Log Errors
```python
# Good
logger.error(f"Failed to scrape {url}: {e}")

# Bad - silent failures
except Exception:
    pass
```

### 5. Validate Input
```python
# Good
if not url or not url.startswith('http'):
    raise ValueError("Invalid URL")

# Bad - no validation
result = firecrawl.scrape(url)
```

## Related Documentation

- [API Overview](./10-api-overview.md)
- [Python SDK](./15-python-sdk.md)
- [Node.js SDK](./16-nodejs-sdk.md)
- [Best Practices](./32-best-practices.md)
