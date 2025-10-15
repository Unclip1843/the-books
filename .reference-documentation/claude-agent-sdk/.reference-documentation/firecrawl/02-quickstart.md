# Firecrawl - Quickstart Guide

**Sources:**
- https://docs.firecrawl.dev/
- https://www.firecrawl.dev/

**Fetched:** 2025-10-11

## Get Started in 5 Minutes

This guide will have you scraping websites in minutes.

## 1. Get Your API Key

### Sign Up
1. Go to [firecrawl.dev](https://www.firecrawl.dev/)
2. Click "Sign Up" or "Get Started"
3. Create your account

### Get API Key
1. Navigate to your dashboard
2. Click "API Keys" in the sidebar
3. Click "Create New Key"
4. Copy your key (starts with `fc-`)

**Keep your API key secure!** Never commit it to version control.

## 2. Install SDK

### Python
```bash
pip install firecrawl-py
```

###Node.js
```bash
npm install @mendable/firecrawl-js
```

## 3. Your First Scrape

### Python

```python
from firecrawl import Firecrawl

# Initialize
firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

# Scrape a URL
result = firecrawl.scrape("https://firecrawl.dev")

# Print markdown content
print(result['markdown'])
```

### Node.js

```javascript
import Firecrawl from '@mendable/firecrawl-js';

// Initialize
const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });

// Scrape a URL
const result = await firecrawl.scrapeUrl('https://firecrawl.dev');

// Print markdown content
console.log(result.markdown);
```

### cURL

```bash
curl -X POST https://api.firecrawl.dev/v1/scrape \
  -H 'Authorization: Bearer fc-YOUR-API-KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://firecrawl.dev",
    "formats": ["markdown"]
  }'
```

## 4. Your First Crawl

Crawl an entire website:

### Python

```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

# Crawl entire website (limited to 10 pages)
result = firecrawl.crawl(
    url="https://firecrawl.dev",
    limit=10
)

# Print results
for page in result['data']:
    print(f"URL: {page['url']}")
    print(f"Content: {page['markdown'][:100]}...")
    print("---")
```

### Node.js

```javascript
const result = await firecrawl.crawlUrl('https://firecrawl.dev', {
  limit: 10
});

// Print results
result.data.forEach(page => {
  console.log(`URL: ${page.url}`);
  console.log(`Content: ${page.markdown.substring(0, 100)}...`);
  console.log('---');
});
```

## 5. Extract Structured Data

Use LLM to extract specific information:

### Python

```python
result = firecrawl.extract(
    urls=["https://www.ycombinator.com/companies"],
    prompt="Extract company names and descriptions"
)

print(result)
```

### Node.js

```javascript
const result = await firecrawl.extract({
  urls: ['https://www.ycombinator.com/companies'],
  prompt: 'Extract company names and descriptions'
});

console.log(result);
```

## Understanding Output

### Scrape Response

```json
{
  "success": true,
  "data": {
    "markdown": "# Page Title\n\nPage content...",
    "html": "<html>...",
    "metadata": {
      "title": "Page Title",
      "description": "Page description",
      "language": "en",
      "sourceURL": "https://example.com"
    },
    "links": ["https://...", "https://..."]
  }
}
```

### Crawl Response

```json
{
  "success": true,
  "data": [
    {
      "url": "https://example.com/page1",
      "markdown": "Content...",
      "metadata": {...}
    },
    {
      "url": "https://example.com/page2",
      "markdown": "Content...",
      "metadata": {...}
    }
  ]
}
```

## Common Patterns

### Environment Variables

Never hardcode API keys!

**Python:**
```python
import os
from firecrawl import Firecrawl

api_key = os.environ.get("FIRECRAWL_API_KEY")
firecrawl = Firecrawl(api_key=api_key)
```

**Node.js:**
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({
  apiKey: process.env.FIRECRAWL_API_KEY
});
```

**.env file:**
```
FIRECRAWL_API_KEY=fc-your-api-key-here
```

### Error Handling

**Python:**
```python
try:
    result = firecrawl.scrape("https://example.com")
    print(result['markdown'])
except Exception as e:
    print(f"Error: {e}")
```

**Node.js:**
```javascript
try {
  const result = await firecrawl.scrapeUrl('https://example.com');
  console.log(result.markdown);
} catch (error) {
  console.error('Error:', error.message);
}
```

## Quick Tips

### 1. Choose the Right Method

- **Scrape:** Single page → Use `scrape()`
- **Crawl:** Entire website → Use `crawl()`
- **Map:** Just need URLs → Use `map()`
- **Search:** Web search → Use `search()`
- **Extract:** Structured data → Use `extract()`

### 2. Specify Formats

```python
# Get multiple formats at once
result = firecrawl.scrape(
    url="https://example.com",
    formats=["markdown", "html", "screenshot"]
)
```

### 3. Limit Crawls

Always set a limit to control costs:

```python
result = firecrawl.crawl(
    url="https://example.com",
    limit=50  # Max 50 pages
)
```

### 4. Use Async for Crawls

For large crawls, use async mode:

```python
# Start crawl (non-blocking)
job = firecrawl.start_crawl(url="https://example.com")

# Check status later
status = firecrawl.get_crawl_status(job['id'])
```

## Next Steps

**Learn Core Features:**
- [Scraping Guide](./04-scraping.md) - Master single-page scraping
- [Crawling Guide](./05-crawling.md) - Extract entire websites
- [Extract Guide](./08-extract.md) - LLM-powered extraction

**SDK Documentation:**
- [Python SDK](./15-python-sdk.md) - Complete Python reference
- [Node.js SDK](./16-nodejs-sdk.md) - Complete TypeScript reference

**Best Practices:**
- [Authentication](./03-authentication.md) - Secure API key management
- [Cost Optimization](./33-cost-optimization.md) - Reduce credit usage
- [Best Practices](./32-best-practices.md) - Tips and patterns

## Troubleshooting

**Can't install SDK?**
- Python: Make sure `pip` is up to date: `pip install --upgrade pip`
- Node: Make sure you're using Node 16+: `node --version`

**API key not working?**
- Check it starts with `fc-`
- Verify it's active in your dashboard
- Make sure no extra spaces when copying

**Getting rate limited?**
- Check your subscription tier limits
- Add delays between requests
- Consider upgrading your plan

**Need help?**
- Docs: https://docs.firecrawl.dev/
- GitHub: https://github.com/firecrawl/firecrawl
- Discord: Check website for invite link

## Related Documentation

- [Overview](./01-overview.md)
- [Authentication](./03-authentication.md)
- [API Reference](./10-api-overview.md)
- [Examples](./28-ai-assistants.md)
