# Firecrawl - Advanced Options

**Sources:**
- https://docs.firecrawl.dev/features/scrape
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Advanced options for fine-tuning scraping behavior.

## Wait Options

### waitFor (milliseconds)
Wait for JavaScript to execute:

```python
result = firecrawl.scrape(
    url="https://example.com",
    waitFor=5000  # Wait 5 seconds
)
```

**Use cases:**
- Dynamic content loading
- JavaScript-heavy sites
- AJAX requests
- Lazy-loaded images

### Wait for Selector
Wait for specific element:

```python
result = firecrawl.scrape(
    url="https://example.com",
    actions=[
        {"type": "wait", "selector": ".dynamic-content", "timeout": 5000}
    ]
)
```

## Custom Headers

Override HTTP headers:

```python
result = firecrawl.scrape(
    url="https://example.com",
    headers={
        "User-Agent": "CustomBot/1.0",
        "Accept-Language": "en-US,en;q=0.9",
        "Referer": "https://google.com",
        "Cookie": "session=abc123"
    }
)
```

**Common use cases:**
- Custom user agent
- Language preferences
- Authentication cookies
- Referrer spoofing

## Stealth Mode

Bypass anti-bot detection (+1 credit):

```python
result = firecrawl.scrape(
    url="https://example.com",
    stealth=True
)
```

**Features:**
- Realistic browser fingerprinting
- Human-like behavior simulation
- Bypasses common anti-bot systems
- Rotating user agents

**Cost:** +1 credit per scrape

## Location-Based Scraping

Scrape from specific geographic location:

```python
# From US
result = firecrawl.scrape(
    url="https://example.com",
    location="US"
)

# From UK
result = firecrawl.scrape(
    url="https://example.com",
    location="GB"
)
```

**Supported locations:**
- US - United States
- GB - United Kingdom
- DE - Germany
- FR - France
- JP - Japan
- AU - Australia
- Many more...

**Use cases:**
- Geo-restricted content
- Regional pricing
- Localized search results
- A/B testing

## Content Filtering

### onlyMainContent
Extract only main content, removing navigation, footers, etc:

```python
result = firecrawl.scrape(
    url="https://example.com/article",
    onlyMainContent=True
)
```

### includeTags
Only include specific HTML tags:

```python
result = firecrawl.scrape(
    url="https://example.com",
    includeTags=["article", "main", "p", "h1", "h2"]
)
```

### excludeTags
Exclude specific HTML tags:

```python
result = firecrawl.scrape(
    url="https://example.com",
    excludeTags=["nav", "footer", "aside", "script", "style"]
)
```

### Combined Filtering
```python
result = firecrawl.scrape(
    url="https://example.com",
    onlyMainContent=True,
    excludeTags=["nav", "footer", "aside", "iframe"]
)
```

## Timeout Options

Set maximum wait time:

```python
result = firecrawl.scrape(
    url="https://example.com",
    timeout=60000  # 60 seconds
)
```

**Default:** 60 seconds  
**Maximum:** 120 seconds

## Mobile Rendering

Render as mobile device:

```python
result = firecrawl.scrape(
    url="https://example.com",
    mobile=True
)
```

**Features:**
- Mobile viewport size
- Touch events
- Mobile user agent
- Responsive design

## PDF Options

For PDF URLs:

```python
result = firecrawl.scrape(
    url="https://example.com/document.pdf",
    formats=["markdown"]
)
```

**Features:**
- Text extraction
- Maintains structure
- Image extraction
- +1 credit cost

**Limits:**
- Max 32MB file size
- Max 100 pages

## Proxy Configuration

(Enterprise feature)

```python
result = firecrawl.scrape(
    url="https://example.com",
    proxy={
        "server": "http://proxy.example.com:8080",
        "username": "user",
        "password": "pass"
    }
)
```

## Complete Examples

### 1. Maximum Stealth
```python
result = firecrawl.scrape(
    url="https://protected-site.com",
    stealth=True,
    waitFor=3000,
    headers={
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Accept-Language": "en-US,en;q=0.9",
        "Referer": "https://google.com"
    },
    location="US"
)
```

### 2. Clean Content Extraction
```python
result = firecrawl.scrape(
    url="https://example.com/article",
    formats=["markdown"],
    onlyMainContent=True,
    excludeTags=["nav", "footer", "aside", "script", "style", "iframe"],
    waitFor=2000
)

# Clean article content
clean_content = result['markdown']
```

### 3. Geo-Specific Pricing
```python
def get_regional_prices(product_url):
    regions = ["US", "GB", "DE", "JP"]
    prices = {}
    
    for region in regions:
        result = firecrawl.scrape(
            url=product_url,
            location=region,
            formats=["markdown"]
        )
        
        # Extract price from content
        prices[region] = extract_price(result['markdown'])
    
    return prices
```

### 4. Dynamic Content
```python
result = firecrawl.scrape(
    url="https://dynamic-site.com",
    waitFor=5000,  # Wait for initial load
    actions=[
        # Scroll to trigger lazy loading
        {"type": "scroll", "direction": "down", "amount": 1000},
        {"type": "wait", "milliseconds": 1000},
        
        # Wait for specific content
        {"type": "wait", "selector": ".loaded-content"}
    ]
)
```

### 5. PDF Extraction
```python
result = firecrawl.scrape(
    url="https://example.com/research-paper.pdf",
    formats=["markdown"]
)

# Clean markdown from PDF
paper_text = result['markdown']

# Extract metadata
title = result['metadata']['title']
pages = result['metadata'].get('pages', 'Unknown')

print(f"Extracted {pages} pages from {title}")
```

## Option Combinations

### Article Extraction
```python
result = firecrawl.scrape(
    url=article_url,
    formats=["markdown"],
    onlyMainContent=True,
    excludeTags=["nav", "footer", "aside"],
    waitFor=2000
)
```

### E-commerce Scraping
```python
result = firecrawl.scrape(
    url=product_url,
    stealth=True,
    location="US",
    waitFor=3000,
    formats=["html"]
)
```

### Documentation Crawling
```python
result = firecrawl.crawl(
    url=docs_url,
    limit=100,
    includePaths=["/docs/*"],
    scrapeOptions={
        "formats": ["markdown"],
        "onlyMainContent": True,
        "excludeTags": ["nav", "aside"]
    }
)
```

## Performance Tips

### 1. Minimize waitFor
```python
# Good - only when needed
waitFor=2000

# Bad - unnecessary wait
waitFor=10000
```

### 2. Use Specific Selectors
```python
# Good - wait for specific element
actions=[{"type": "wait", "selector": "#content"}]

# Bad - generic wait
waitFor=5000
```

### 3. Filter Early
```python
# Good - filter during scrape
onlyMainContent=True,
excludeTags=["nav", "footer"]

# Bad - filter after scraping
# (wastes bandwidth)
```

## Pricing Impact

| Option | Additional Cost |
|--------|----------------|
| waitFor | No cost |
| Custom headers | No cost |
| Content filtering | No cost |
| Stealth mode | +1 credit |
| PDF parsing | +1 credit |
| Location-based | No cost |

## Best Practices

### 1. Use Stealth Sparingly
```python
# Only when needed
if site_has_antibot:
    stealth=True
```

### 2. Set Reasonable Timeouts
```python
# Good
timeout=30000

# Bad - too long
timeout=120000
```

### 3. Filter Content
```python
# Always use when possible
onlyMainContent=True,
excludeTags=["nav", "footer"]
```

### 4. Test Headers
```python
# Start simple
headers={}

# Add if needed
headers={"User-Agent": "..."}
```

## Related Documentation

- [Scraping](./04-scraping.md)
- [Actions](./09-actions.md)
- [Best Practices](./32-best-practices.md)
- [Cost Optimization](./33-cost-optimization.md)
