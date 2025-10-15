# Firecrawl - Crawl Endpoint

**Sources:**
- https://docs.firecrawl.dev/api-reference/endpoint/crawl
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Endpoints

```
POST   /v1/crawl            # Start crawl
GET    /v1/crawl/status/:id # Get crawl status
DELETE /v1/crawl/cancel/:id # Cancel crawl
```

## Start Crawl

### Request

```
POST /v1/crawl
```

### Headers
```
Authorization: Bearer fc-YOUR-API-KEY
Content-Type: application/json
```

### Body Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| url | string | Yes | Starting URL |
| limit | number | No | Max pages to crawl (default: no limit) |
| maxDepth | number | No | Max depth to crawl (default: 10) |
| includePaths | array | No | Path patterns to include |
| excludePaths | array | No | Path patterns to exclude |
| allowSubdomains | boolean | No | Include subdomains (default: false) |
| ignoreSitemap | boolean | No | Skip sitemap.xml (default: false) |
| scrapeOptions | object | No | Options for scraping each page |
| webhook | string | No | Webhook URL for completion notification |

### Example Request

```bash
curl -X POST https://api.firecrawl.dev/v1/crawl \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "limit": 100,
    "includePaths": ["/blog/*", "/docs/*"],
    "scrapeOptions": {
      "formats": ["markdown"]
    }
  }'
```

### Response

```json
{
  "success": true,
  "id": "crawl_abc123",
  "url": "https://example.com"
}
```

## Check Crawl Status

### Request

```
GET /v1/crawl/status/:id
```

### Example Request

```bash
curl -X GET https://api.firecrawl.dev/v1/crawl/status/crawl_abc123 \
  -H "Authorization: Bearer fc-YOUR-API-KEY"
```

### Response (In Progress)

```json
{
  "success": true,
  "status": "scraping",
  "total": 100,
  "completed": 45,
  "creditsUsed": 45,
  "expiresAt": "2025-10-12T10:00:00Z",
  "next": "https://example.com/page46"
}
```

### Response (Completed)

```json
{
  "success": true,
  "status": "completed",
  "total": 87,
  "completed": 87,
  "creditsUsed": 87,
  "expiresAt": "2025-10-12T10:00:00Z",
  "data": [
    {
      "url": "https://example.com",
      "markdown": "# Home\n\nContent...",
      "metadata": {
        "title": "Home",
        "statusCode": 200
      }
    },
    {
      "url": "https://example.com/about",
      "markdown": "# About\n\nContent...",
      "metadata": {
        "title": "About Us",
        "statusCode": 200
      }
    }
  ]
}
```

### Status Values

| Status | Description |
|--------|-------------|
| `scraping` | Crawl in progress |
| `completed` | Crawl finished successfully |
| `failed` | Crawl failed with error |
| `cancelled` | Crawl was cancelled |

## Cancel Crawl

### Request

```
DELETE /v1/crawl/cancel/:id
```

### Example Request

```bash
curl -X DELETE https://api.firecrawl.dev/v1/crawl/cancel/crawl_abc123 \
  -H "Authorization: Bearer fc-YOUR-API-KEY"
```

### Response

```json
{
  "success": true,
  "status": "cancelled"
}
```

## Crawl Options

### Limit Pages
```json
{
  "url": "https://example.com",
  "limit": 50
}
```

### Max Depth
```json
{
  "url": "https://example.com",
  "maxDepth": 3
}
```

### Include Paths
```json
{
  "url": "https://example.com",
  "includePaths": ["/blog/*", "/docs/*", "/products/*"]
}
```

### Exclude Paths
```json
{
  "url": "https://example.com",
  "excludePaths": ["/admin/*", "/login/*", "/private/*"]
}
```

### Allow Subdomains
```json
{
  "url": "https://example.com",
  "allowSubdomains": true
}
```

### Scrape Options
```json
{
  "url": "https://example.com",
  "limit": 100,
  "scrapeOptions": {
    "formats": ["markdown", "html"],
    "onlyMainContent": true,
    "excludeTags": ["nav", "footer"],
    "waitFor": 2000
  }
}
```

### Webhook
```json
{
  "url": "https://example.com",
  "limit": 100,
  "webhook": "https://your-api.com/webhook"
}
```

Webhook receives POST request when crawl completes:
```json
{
  "status": "completed",
  "id": "crawl_abc123",
  "total": 87,
  "data": [...]
}
```

## Examples

### Python - Async Crawl
```python
import requests
import time

# Start crawl
response = requests.post(
    "https://api.firecrawl.dev/v1/crawl",
    headers={"Authorization": "Bearer fc-YOUR-API-KEY"},
    json={
        "url": "https://example.com",
        "limit": 100
    }
)

crawl_id = response.json()['id']
print(f"Crawl started: {crawl_id}")

# Poll for status
while True:
    status_response = requests.get(
        f"https://api.firecrawl.dev/v1/crawl/status/{crawl_id}",
        headers={"Authorization": "Bearer fc-YOUR-API-KEY"}
    )
    
    status = status_response.json()
    
    if status['status'] == 'completed':
        print(f"Crawl completed! Found {len(status['data'])} pages")
        break
    elif status['status'] == 'failed':
        print(f"Crawl failed: {status.get('error')}")
        break
    
    print(f"Progress: {status['completed']}/{status['total']}")
    time.sleep(10)
```

### Node.js - Async Crawl
```javascript
// Start crawl
const startResponse = await fetch('https://api.firecrawl.dev/v1/crawl', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer fc-YOUR-API-KEY',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    url: 'https://example.com',
    limit: 100
  })
});

const { id: crawlId } = await startResponse.json();
console.log(`Crawl started: ${crawlId}`);

// Poll for status
while (true) {
  const statusResponse = await fetch(
    `https://api.firecrawl.dev/v1/crawl/status/${crawlId}`,
    {
      headers: {
        'Authorization': 'Bearer fc-YOUR-API-KEY'
      }
    }
  );
  
  const status = await statusResponse.json();
  
  if (status.status === 'completed') {
    console.log(`Crawl completed! Found ${status.data.length} pages`);
    break;
  } else if (status.status === 'failed') {
    console.error(`Crawl failed: ${status.error}`);
    break;
  }
  
  console.log(`Progress: ${status.completed}/${status.total}`);
  await new Promise(resolve => setTimeout(resolve, 10000));
}
```

### With Webhook
```bash
curl -X POST https://api.firecrawl.dev/v1/crawl \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "limit": 100,
    "webhook": "https://your-api.com/firecrawl-webhook"
  }'
```

Your webhook endpoint receives:
```python
@app.post("/firecrawl-webhook")
def handle_crawl_completion(data: dict):
    crawl_id = data['id']
    status = data['status']
    pages = data['data']
    
    if status == 'completed':
        print(f"Crawl {crawl_id} completed with {len(pages)} pages")
        # Process pages...
```

## Pricing

- **1 credit per page** crawled
- Additional costs apply for stealth mode, PDFs, etc.

## Best Practices

### 1. Always Set Limits
```json
{
  "url": "https://example.com",
  "limit": 100  // Prevent runaway costs
}
```

### 2. Use Webhooks for Large Crawls
```json
{
  "url": "https://example.com",
  "limit": 500,
  "webhook": "https://your-api.com/webhook"
}
```

### 3. Filter Paths
```json
{
  "url": "https://example.com",
  "includePaths": ["/blog/*"],
  "excludePaths": ["/admin/*"]
}
```

### 4. Poll Reasonably
```python
# Check every 10 seconds, not every second
time.sleep(10)
```

### 5. Handle Errors
```python
if status['status'] == 'failed':
    print(f"Error: {status.get('error')}")
    # Implement retry logic
```

## Limitations

- **Max depth:** 10 levels (default)
- **Timeout:** 24 hours
- **Max pages:** Tier-dependent
- **Expiration:** Results expire after 24 hours

## Related Documentation

- [Crawling Guide](./05-crawling.md)
- [API Overview](./10-api-overview.md)
- [Async Operations](./17-async-operations.md)
- [Python SDK](./15-python-sdk.md)
