# Firecrawl - Map & Search Endpoints

**Sources:**
- https://docs.firecrawl.dev/api-reference/endpoint/map
- https://docs.firecrawl.dev/api-reference/endpoint/search
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Map Endpoint

### Endpoint
```
POST /v1/map
```

### Description
Get a complete list of URLs from a website without scraping content.

### Request

#### Headers
```
Authorization: Bearer fc-YOUR-API-KEY
Content-Type: application/json
```

#### Body Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| url | string | Yes | Website to map |
| search | string | No | Filter URLs containing this string |
| ignoreSitemap | boolean | No | Skip sitemap.xml (default: false) |
| includeSubdomains | boolean | No | Include subdomains (default: false) |
| limit | number | No | Max URLs to return |

### Example Request

```bash
curl -X POST https://api.firecrawl.dev/v1/map \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "search": "blog"
  }'
```

### Response

```json
{
  "success": true,
  "links": [
    "https://example.com",
    "https://example.com/about",
    "https://example.com/blog",
    "https://example.com/blog/post-1",
    "https://example.com/blog/post-2",
    "https://example.com/contact"
  ]
}
```

### Examples

#### Python
```python
import requests

url = "https://api.firecrawl.dev/v1/map"
headers = {
    "Authorization": "Bearer fc-YOUR-API-KEY",
    "Content-Type": "application/json"
}
data = {
    "url": "https://example.com",
    "search": "product"
}

response = requests.post(url, headers=headers, json=data)
result = response.json()

print(f"Found {len(result['links'])} URLs")
for link in result['links']:
    print(link)
```

#### Node.js
```javascript
const response = await fetch('https://api.firecrawl.dev/v1/map', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer fc-YOUR-API-KEY',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    url: 'https://example.com',
    search: 'product'
  })
});

const result = await response.json();
console.log(`Found ${result.links.length} URLs`);
```

### Pricing
- **1 credit per request** (regardless of URLs found)

---

## Search Endpoint

### Endpoint
```
POST /v1/search
```

### Description
Perform web search and return full scraped content from results.

### Request

#### Headers
```
Authorization: Bearer fc-YOUR-API-KEY
Content-Type: application/json
```

#### Body Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | Search query |
| limit | number | No | Max results (default: 10) |
| searchType | string | No | Type: web, news, images, github, research |
| location | string | No | Geographic location (e.g. "US") |
| timeRange | string | No | Time filter: day, week, month, year |
| scrapeOptions | object | No | Options for scraping results |

### Example Request

```bash
curl -X POST https://api.firecrawl.dev/v1/search \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "firecrawl API tutorial",
    "limit": 5,
    "searchType": "web"
  }'
```

### Response

```json
{
  "success": true,
  "data": [
    {
      "url": "https://example.com/article",
      "markdown": "# Article Title\n\nContent...",
      "html": "<html>...</html>",
      "metadata": {
        "title": "Article Title",
        "description": "Article description",
        "language": "en",
        "sourceURL": "https://example.com/article",
        "statusCode": 200
      },
      "links": ["https://...", "https://..."]
    }
  ]
}
```

### Search Types

#### Web Search (Default)
```json
{
  "query": "machine learning frameworks",
  "searchType": "web",
  "limit": 10
}
```

#### News Search
```json
{
  "query": "AI regulation",
  "searchType": "news",
  "timeRange": "week",
  "limit": 10
}
```

#### GitHub Search
```json
{
  "query": "web scraping python",
  "searchType": "github",
  "limit": 10
}
```

#### Research Papers
```json
{
  "query": "transformer architecture",
  "searchType": "research",
  "limit": 10
}
```

#### Image Search
```json
{
  "query": "office interior design",
  "searchType": "images",
  "limit": 20
}
```

### Options

#### Location-Based
```json
{
  "query": "best restaurants",
  "location": "San Francisco, CA",
  "limit": 10
}
```

#### Time Range
```json
{
  "query": "tech news",
  "timeRange": "day",
  "limit": 10
}
```

#### With Scrape Options
```json
{
  "query": "documentation",
  "limit": 5,
  "scrapeOptions": {
    "formats": ["markdown"],
    "onlyMainContent": true
  }
}
```

### Examples

#### Python
```python
import requests

url = "https://api.firecrawl.dev/v1/search"
headers = {
    "Authorization": "Bearer fc-YOUR-API-KEY",
    "Content-Type": "application/json"
}
data = {
    "query": "firecrawl tutorials",
    "limit": 5,
    "searchType": "web"
}

response = requests.post(url, headers=headers, json=data)
result = response.json()

for item in result['data']:
    print(f"Title: {item['metadata']['title']}")
    print(f"URL: {item['url']}")
    print(f"Content: {item['markdown'][:200]}...")
    print("---")
```

#### Node.js
```javascript
const response = await fetch('https://api.firecrawl.dev/v1/search', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer fc-YOUR-API-KEY',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    query: 'firecrawl tutorials',
    limit: 5,
    searchType: 'web'
  })
});

const result = await response.json();

result.data.forEach(item => {
  console.log(`Title: ${item.metadata.title}`);
  console.log(`URL: ${item.url}`);
  console.log(`Content: ${item.markdown.substring(0, 200)}...`);
  console.log('---');
});
```

### Pricing
- **1 credit per result** returned
- Example: `limit: 10` costs 10 credits

---

## Error Codes

| Code | Error | Solution |
|------|-------|----------|
| 400 | Invalid Parameters | Check request format |
| 401 | Unauthorized | Check API key |
| 402 | Payment Required | Add credits |
| 429 | Rate Limited | Slow down requests |
| 500 | Server Error | Retry request |

## Best Practices

### Map
1. Use for site structure analysis
2. Filter with `search` parameter
3. Combine with crawl for targeted scraping
4. 1 credit regardless of URLs found

### Search
1. Be specific with queries
2. Limit results to control costs
3. Use appropriate search type
4. Apply time filters for current events

## Related Documentation

- [Mapping Guide](./06-mapping.md)
- [Search Guide](./07-search.md)
- [API Overview](./10-api-overview.md)
- [Python SDK](./15-python-sdk.md)
