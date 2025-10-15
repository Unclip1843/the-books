# Firecrawl - Authentication

**Sources:**
- https://docs.firecrawl.dev/
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## API Key Authentication

Firecrawl uses API key authentication with Bearer tokens.

## Getting Your API Key

1. Sign up at [firecrawl.dev](https://www.firecrawl.dev/)
2. Navigate to your Dashboard
3. Click "API Keys" in sidebar
4. Click "Create New Key"
5. Copy your key (format: `fc-xxxxxxxxxxxx`)

## Using Your API Key

### Python
```python
from firecrawl import Firecrawl

# Direct initialization
firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

# From environment variable (recommended)
import os
firecrawl = Firecrawl(api_key=os.environ.get("FIRECRAWL_API_KEY"))
```

### Node.js
```javascript
import Firecrawl from '@mendable/firecrawl-js';

// Direct initialization
const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });

// From environment variable (recommended)
const firecrawl = new Firecrawl({ apiKey: process.env.FIRECRAWL_API_KEY });
```

### cURL
```bash
curl -X POST https://api.firecrawl.dev/v1/scrape \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

## Rate Limits

Rate limits vary by subscription tier:

| Tier | Requests/Min | Credits/Month |
|------|--------------|---------------|
| Free | 10 | 500 |
| Starter | 60 | 10,000 |
| Growth | 300 | 100,000 |
| Scale | 600 | 500,000 |
| Enterprise | Custom | Custom |

### Checking Rate Limits

Response headers include rate limit information:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1609459200
```

### Handling Rate Limits

**Python:**
```python
import time
from firecrawl import Firecrawl

def scrape_with_retry(url, max_retries=3):
    firecrawl = Firecrawl(api_key=os.environ.get("FIRECRAWL_API_KEY"))
    
    for attempt in range(max_retries):
        try:
            return firecrawl.scrape(url)
        except Exception as e:
            if "429" in str(e):  # Rate limited
                wait_time = 2 ** attempt
                print(f"Rate limited. Waiting {wait_time}s...")
                time.sleep(wait_time)
            else:
                raise
    raise Exception("Max retries exceeded")
```

## Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| 401 | Invalid/missing API key | Check key format |
| 402 | Payment required | Upgrade plan or add credits |
| 429 | Rate limit exceeded | Slow down requests |
| 500 | Server error | Retry with backoff |

## Security Best Practices

### 1. Never Commit Keys
```bash
# .gitignore
.env
*.env
config/secrets.json
```

### 2. Use Environment Variables
```bash
# .env file
FIRECRAWL_API_KEY=fc-your-key-here

# Load in app
export FIRECRAWL_API_KEY=fc-your-key-here
```

### 3. Rotate Keys Regularly
- Create new key
- Update applications
- Delete old key

### 4. Restrict Key Permissions
- Use separate keys for dev/prod
- Set IP restrictions if available
- Monitor key usage

### 5. Secure Storage
```python
# Use secret management
from azure.keyvault.secrets import SecretClient

secret_client = SecretClient(vault_url=vault_url, credential=credential)
api_key = secret_client.get_secret("firecrawl-api-key").value
```

## Related Documentation

- [Quickstart](./02-quickstart.md)
- [API Reference](./10-api-overview.md)
- [Best Practices](./32-best-practices.md)
