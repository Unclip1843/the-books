# Firecrawl - Mapping

**Sources:**
- https://docs.firecrawl.dev/features/map
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Mapping quickly retrieves a complete list of URLs from a website without scraping content. Perfect for site audits, SEO analysis, and understanding site structure.

## How Mapping Works

```
Start URL → Analyze Sitemap → Discover Links → Return URL List
```

**Benefits:**
- **Fast:** Returns URLs in seconds
- **Cheap:** Lower cost than crawling
- **Comprehensive:** Finds all discoverable URLs
- **No content:** Just URLs and metadata

## Basic Mapping

### Python
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

# Map entire site
result = firecrawl.map("https://example.com")

# Print all URLs
for url in result['links']:
    print(url)

print(f"Total URLs found: {len(result['links'])}")
```

### Node.js
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });

const result = await firecrawl.mapUrl('https://example.com');

result.links.forEach(url => console.log(url));

console.log(`Total URLs found: ${result.links.length}`);
```

### cURL
```bash
curl -X POST https://api.firecrawl.dev/v1/map \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com"
  }'
```

## Map Options

### Include/Exclude Patterns
```python
result = firecrawl.map(
    url="https://example.com",
    search="blog",  # Only URLs containing "blog"
    ignoreSitemap=False,  # Use sitemap.xml if available
    includeSubdomains=False,  # Main domain only
    limit=1000  # Max URLs to return
)
```

### Search Pattern
```python
# Find all blog posts
blog_urls = firecrawl.map(
    url="https://example.com",
    search="blog"
)

# Find all product pages
product_urls = firecrawl.map(
    url="https://example.com",
    search="product"
)
```

### Limit Results
```python
# Get first 100 URLs
result = firecrawl.map(
    url="https://example.com",
    limit=100
)
```

## Response Format

```json
{
  "success": true,
  "links": [
    "https://example.com",
    "https://example.com/about",
    "https://example.com/contact",
    "https://example.com/blog",
    "https://example.com/blog/post-1",
    "https://example.com/blog/post-2",
    "https://example.com/products",
    "https://example.com/products/item-1"
  ]
}
```

## Pricing

- **Map operation:** 1 credit per request (regardless of URLs found)
- Much cheaper than crawling individual pages

## Use Cases

### 1. Site Audit
```python
def audit_site_structure(url):
    result = firecrawl.map(url)
    
    # Categorize URLs
    pages = {
        'total': len(result['links']),
        'blog': len([u for u in result['links'] if '/blog/' in u]),
        'products': len([u for u in result['links'] if '/product' in u]),
        'static': len([u for u in result['links'] if u.endswith('.pdf') or u.endswith('.jpg')])
    }
    
    return pages

# Example output:
# {
#   'total': 487,
#   'blog': 123,
#   'products': 56,
#   'static': 34
# }
```

### 2. SEO Analysis
```python
def analyze_url_structure(url):
    result = firecrawl.map(url)
    
    analysis = {
        'total_pages': len(result['links']),
        'avg_depth': sum(u.count('/') for u in result['links']) / len(result['links']),
        'long_urls': len([u for u in result['links'] if len(u) > 100]),
        'external_links': len([u for u in result['links'] if url not in u])
    }
    
    return analysis
```

### 3. Sitemap Generation
```python
def generate_sitemap(url):
    result = firecrawl.map(url)
    
    sitemap = '<?xml version="1.0" encoding="UTF-8"?>\n'
    sitemap += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
    
    for link in result['links']:
        sitemap += f'  <url><loc>{link}</loc></url>\n'
    
    sitemap += '</urlset>'
    
    return sitemap
```

### 4. Link Discovery
```python
def find_links_by_type(url, link_type):
    result = firecrawl.map(url)
    
    # Find specific types of links
    if link_type == 'pdf':
        return [u for u in result['links'] if u.endswith('.pdf')]
    elif link_type == 'blog':
        return [u for u in result['links'] if '/blog/' in u]
    elif link_type == 'product':
        return [u for u in result['links'] if '/product' in u]
    
    return result['links']
```

### 5. Before Crawling
```python
def smart_crawl(url, max_pages=100):
    # First, map the site
    map_result = firecrawl.map(url)
    
    print(f"Found {len(map_result['links'])} URLs")
    
    # Filter to relevant URLs
    relevant_urls = [u for u in map_result['links'] if '/blog/' in u or '/docs/' in u]
    
    print(f"Crawling {len(relevant_urls)} relevant pages")
    
    # Now crawl only what we need
    if len(relevant_urls) <= max_pages:
        return firecrawl.crawl(url, limit=len(relevant_urls), includePaths=['/blog/*', '/docs/*'])
    else:
        print(f"Too many pages. Limiting to {max_pages}")
        return firecrawl.crawl(url, limit=max_pages, includePaths=['/blog/*', '/docs/*'])
```

## Map vs Crawl

| Feature | Map | Crawl |
|---------|-----|-------|
| Speed | Very fast (seconds) | Slower (minutes) |
| Cost | 1 credit total | 1 credit per page |
| Output | Just URLs | Full content |
| Use case | URL discovery | Content extraction |

**When to use Map:**
- Site structure analysis
- URL discovery
- Before crawling (to estimate scope)
- SEO audits
- Sitemap generation

**When to use Crawl:**
- Need actual content
- Data extraction
- Content analysis
- Building knowledge base

## Best Practices

### 1. Use Map Before Crawl
```python
# Estimate scope first
map_result = firecrawl.map(url)
estimated_pages = len(map_result['links'])

print(f"Site has ~{estimated_pages} pages")
print(f"Crawling will cost ~{estimated_pages} credits")

# Then decide whether to crawl
if estimated_pages < 1000:
    crawl_result = firecrawl.crawl(url, limit=estimated_pages)
```

### 2. Filter Results
```python
# Get all URLs, then filter
all_urls = firecrawl.map(url)

# Filter to what you need
blog_urls = [u for u in all_urls['links'] if '/blog/' in u]
product_urls = [u for u in all_urls['links'] if '/product' in u]
```

### 3. Combine with Scraping
```python
# Map to find URLs
urls = firecrawl.map("https://example.com")

# Scrape specific pages
important_urls = [u for u in urls['links'] if '/important/' in u]

for url in important_urls:
    result = firecrawl.scrape(url)
    print(result['markdown'])
```

## Limitations

- **No content:** Only returns URLs, not page content
- **No metadata:** No titles, descriptions, etc.
- **Discovery-based:** Only finds linked pages
- **Sitemap dependent:** Results may vary if site has incomplete sitemap

## Related Documentation

- [Crawling](./05-crawling.md)
- [Scraping](./04-scraping.md)
- [API Reference](./14-map-search-endpoints.md)
- [Python SDK](./15-python-sdk.md)
