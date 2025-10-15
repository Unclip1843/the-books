# Firecrawl - Scrape Endpoint

**Sources:**
- https://docs.firecrawl.dev/api-reference/endpoint/scrape
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Endpoint

```
POST /v1/scrape
```

## Description

Scrapes a single URL and returns content in specified formats (markdown, HTML, JSON, screenshot).

## Request

### Headers
```
Authorization: Bearer fc-YOUR-API-KEY
Content-Type: application/json
```

### Body Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| url | string | Yes | URL to scrape |
| formats | array | No | Output formats: `["markdown", "html", "screenshot"]` |
| onlyMainContent | boolean | No | Extract only main content (default: false) |
| includeTags | array | No | HTML tags to include |
| excludeTags | array | No | HTML tags to exclude |
| headers | object | No | Custom HTTP headers |
| waitFor | number | No | Milliseconds to wait for JS |
| timeout | number | No | Request timeout in ms (max 60000) |
| stealth | boolean | No | Use stealth mode (+1 credit) |
| location | string | No | Scrape from location (e.g. "US") |

### Example Request

```bash
curl -X POST https://api.firecrawl.dev/v1/scrape \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "formats": ["markdown", "html"],
    "onlyMainContent": true,
    "waitFor": 2000
  }'
```

## Response

### Success Response (200)

```json
{
  "success": true,
  "data": {
    "markdown": "# Page Title\n\nContent...",
    "html": "<html>...</html>",
    "metadata": {
      "title": "Page Title",
      "description": "Page description",
      "language": "en",
      "sourceURL": "https://example.com",
      "statusCode": 200,
      "author": "Author Name",
      "publishDate": "2025-01-01"
    },
    "links": [
      "https://example.com/page1",
      "https://example.com/page2"
    ]
  }
}
```

### Error Response (4xx/5xx)

```json
{
  "success": false,
  "error": "Error message",
  "statusCode": 400
}
```

## Format Options

### Markdown
```json
{
  "url": "https://example.com",
  "formats": ["markdown"]
}
```

Response includes:
- Clean markdown text
- Preserved structure
- Links maintained
- Images as markdown references

### HTML
```json
{
  "url": "https://example.com",
  "formats": ["html"]
}
```

Response includes:
- Full HTML structure
- All tags and attributes
- Inline styles preserved

### Screenshot
```json
{
  "url": "https://example.com",
  "formats": ["screenshot"]
}
```

Response includes:
- Base64 encoded PNG image
- Full page screenshot

### Multiple Formats
```json
{
  "url": "https://example.com",
  "formats": ["markdown", "html", "screenshot"]
}
```

## Advanced Options

### Only Main Content
```json
{
  "url": "https://example.com",
  "onlyMainContent": true
}
```

Removes navigation, sidebars, footers automatically.

### Include/Exclude Tags
```json
{
  "url": "https://example.com",
  "excludeTags": ["nav", "footer", "aside"],
  "includeTags": ["article", "main"]
}
```

### Custom Headers
```json
{
  "url": "https://example.com",
  "headers": {
    "User-Agent": "CustomBot/1.0",
    "Accept-Language": "en-US",
    "Cookie": "session=abc123"
  }
}
```

### Wait for JavaScript
```json
{
  "url": "https://example.com",
  "waitFor": 5000
}
```

Waits 5 seconds for JavaScript to load content.

### Stealth Mode
```json
{
  "url": "https://example.com",
  "stealth": true
}
```

Bypasses anti-bot detection (+1 credit cost).

### Location-Based
```json
{
  "url": "https://example.com",
  "location": "US"
}
```

Scrapes from specific geographic location.

## Examples

### Basic Scrape
```bash
curl -X POST https://api.firecrawl.dev/v1/scrape \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

### With Options
```bash
curl -X POST https://api.firecrawl.dev/v1/scrape \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/article",
    "formats": ["markdown"],
    "onlyMainContent": true,
    "excludeTags": ["nav", "footer"],
    "waitFor": 2000
  }'
```

### Python
```python
import requests

url = "https://api.firecrawl.dev/v1/scrape"
headers = {
    "Authorization": "Bearer fc-YOUR-API-KEY",
    "Content-Type": "application/json"
}
data = {
    "url": "https://example.com",
    "formats": ["markdown", "html"]
}

response = requests.post(url, headers=headers, json=data)
result = response.json()

print(result['data']['markdown'])
```

### Node.js
```javascript
const response = await fetch('https://api.firecrawl.dev/v1/scrape', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer fc-YOUR-API-KEY',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    url: 'https://example.com',
    formats: ['markdown']
  })
});

const result = await response.json();
console.log(result.data.markdown);
```

## Error Codes

| Code | Error | Solution |
|------|-------|----------|
| 400 | Invalid URL | Check URL format |
| 401 | Unauthorized | Check API key |
| 402 | Payment Required | Add credits |
| 429 | Rate Limited | Slow down requests |
| 500 | Server Error | Retry request |

## Pricing

- **Base scrape:** 1 credit
- **Screenshot:** +0 credits (included)
- **Stealth mode:** +1 credit
- **PDF parsing:** +1 credit

## Related Documentation

- [Scraping Guide](./04-scraping.md)
- [API Overview](./10-api-overview.md)
- [Python SDK](./15-python-sdk.md)
