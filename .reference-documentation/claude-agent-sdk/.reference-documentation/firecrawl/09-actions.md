# Firecrawl - Actions

**Sources:**
- https://docs.firecrawl.dev/features/actions
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Actions enable interactive web scraping by performing operations like clicking, scrolling, typing, and waiting. Perfect for dynamic sites that require user interaction.

## Available Actions

### Click
Click on elements:
```python
actions = [
    {"type": "click", "selector": "#button-id"}
]
```

### Type
Enter text into inputs:
```python
actions = [
    {"type": "type", "selector": "#search-input", "text": "search query"}
]
```

### Scroll
Scroll page or elements:
```python
actions = [
    {"type": "scroll", "direction": "down", "amount": 500}
]
```

### Wait
Wait for elements or time:
```python
actions = [
    {"type": "wait", "selector": ".dynamic-content", "timeout": 5000}
]
```

### Navigate
Go to different URLs:
```python
actions = [
    {"type": "navigate", "url": "https://example.com/page2"}
]
```

## Basic Actions

### Python
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

# Click a button, then scrape
result = firecrawl.scrape(
    url="https://example.com",
    actions=[
        {"type": "click", "selector": "#load-more-button"},
        {"type": "wait", "milliseconds": 2000}
    ]
)

print(result['markdown'])
```

### Node.js
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });

const result = await firecrawl.scrapeUrl('https://example.com', {
  actions: [
    { type: 'click', selector: '#load-more-button' },
    { type: 'wait', milliseconds: 2000 }
  ]
});

console.log(result.markdown);
```

### cURL
```bash
curl -X POST https://api.firecrawl.dev/v1/scrape \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "actions": [
      {"type": "click", "selector": "#load-more-button"},
      {"type": "wait", "milliseconds": 2000}
    ]
  }'
```

## Action Sequences

### Load More Content
```python
actions = [
    {"type": "click", "selector": ".load-more"},
    {"type": "wait", "milliseconds": 1000},
    {"type": "click", "selector": ".load-more"},
    {"type": "wait", "milliseconds": 1000},
    {"type": "click", "selector": ".load-more"}
]

result = firecrawl.scrape(
    url="https://example.com/articles",
    actions=actions
)
```

### Fill Form
```python
actions = [
    {"type": "type", "selector": "#username", "text": "user@example.com"},
    {"type": "type", "selector": "#password", "text": "password123"},
    {"type": "click", "selector": "#login-button"},
    {"type": "wait", "selector": ".dashboard", "timeout": 5000}
]

result = firecrawl.scrape(
    url="https://example.com/login",
    actions=actions
)
```

### Navigate Pagination
```python
actions = [
    {"type": "click", "selector": ".next-page"},
    {"type": "wait", "milliseconds": 1000}
]

result = firecrawl.scrape(
    url="https://example.com/page1",
    actions=actions
)
```

### Expand Accordions
```python
actions = [
    {"type": "click", "selector": ".accordion-1"},
    {"type": "wait", "milliseconds": 500},
    {"type": "click", "selector": ".accordion-2"},
    {"type": "wait", "milliseconds": 500},
    {"type": "click", "selector": ".accordion-3"}
]

result = firecrawl.scrape(
    url="https://example.com/faq",
    actions=actions
)
```

### Infinite Scroll
```python
actions = [
    {"type": "scroll", "direction": "down", "amount": 1000},
    {"type": "wait", "milliseconds": 1000},
    {"type": "scroll", "direction": "down", "amount": 1000},
    {"type": "wait", "milliseconds": 1000},
    {"type": "scroll", "direction": "down", "amount": 1000}
]

result = firecrawl.scrape(
    url="https://example.com/feed",
    actions=actions
)
```

## Selectors

### CSS Selectors
```python
# ID
{"type": "click", "selector": "#button-id"}

# Class
{"type": "click", "selector": ".button-class"}

# Element
{"type": "click", "selector": "button"}

# Attribute
{"type": "click", "selector": "[data-action='submit']"}

# Nested
{"type": "click", "selector": "div.container > button.submit"}
```

### XPath Selectors
```python
{"type": "click", "selector": "//button[@id='submit']", "selectorType": "xpath"}
```

## Wait Strategies

### Wait for Time
```python
{"type": "wait", "milliseconds": 2000}  # Wait 2 seconds
```

### Wait for Element
```python
{"type": "wait", "selector": ".dynamic-content", "timeout": 5000}
```

### Wait for Navigation
```python
{"type": "wait", "event": "navigationComplete"}
```

## Use Cases

### 1. Load More Button
```python
def scrape_all_articles(url):
    # Click "Load More" 5 times
    actions = []
    for _ in range(5):
        actions.extend([
            {"type": "click", "selector": ".load-more-button"},
            {"type": "wait", "milliseconds": 1500}
        ])
    
    result = firecrawl.scrape(url=url, actions=actions)
    return result['markdown']
```

### 2. Login Required
```python
def scrape_protected_page(url, username, password):
    actions = [
        # Fill login form
        {"type": "type", "selector": "#email", "text": username},
        {"type": "type", "selector": "#password", "text": password},
        {"type": "click", "selector": "#login-submit"},
        
        # Wait for dashboard
        {"type": "wait", "selector": ".dashboard-content", "timeout": 5000}
    ]
    
    result = firecrawl.scrape(url=url, actions=actions)
    return result['markdown']
```

### 3. Pagination Crawler
```python
def scrape_all_pages(base_url, num_pages):
    all_content = []
    
    for page in range(num_pages):
        if page == 0:
            result = firecrawl.scrape(base_url)
        else:
            actions = [
                {"type": "click", "selector": ".pagination-next"},
                {"type": "wait", "milliseconds": 1000}
            ]
            result = firecrawl.scrape(base_url, actions=actions)
        
        all_content.append(result['markdown'])
    
    return all_content
```

### 4. Expand All Sections
```python
def scrape_with_all_sections_expanded(url):
    # Find all expandable sections
    actions = []
    
    # Expand 10 sections (adjust based on page)
    for i in range(1, 11):
        actions.extend([
            {"type": "click", "selector": f".section-{i} .expand-button"},
            {"type": "wait", "milliseconds": 300}
        ])
    
    result = firecrawl.scrape(url=url, actions=actions)
    return result['markdown']
```

### 5. Infinite Scroll Feed
```python
def scrape_infinite_scroll(url, scroll_times=10):
    actions = []
    
    for _ in range(scroll_times):
        actions.extend([
            {"type": "scroll", "direction": "down", "amount": 1000},
            {"type": "wait", "milliseconds": 1000}  # Wait for content to load
        ])
    
    result = firecrawl.scrape(url=url, actions=actions)
    return result['markdown']
```

### 6. Modal Handling
```python
def scrape_with_modal_close(url):
    actions = [
        # Wait for page load
        {"type": "wait", "milliseconds": 2000},
        
        # Close modal if present
        {"type": "click", "selector": ".modal-close"},
        {"type": "wait", "milliseconds": 500}
    ]
    
    result = firecrawl.scrape(url=url, actions=actions)
    return result['markdown']
```

## Best Practices

### 1. Add Waits Between Actions
```python
# Good - wait after interactions
actions = [
    {"type": "click", "selector": "#button"},
    {"type": "wait", "milliseconds": 1000},  # Wait for effect
    {"type": "click", "selector": "#next"}
]

# Bad - no waits
actions = [
    {"type": "click", "selector": "#button"},
    {"type": "click", "selector": "#next"}
]
```

### 2. Use Specific Selectors
```python
# Good - specific selector
{"type": "click", "selector": "#submit-form-button"}

# Less reliable - generic selector
{"type": "click", "selector": "button"}
```

### 3. Handle Errors Gracefully
```python
try:
    result = firecrawl.scrape(url=url, actions=actions)
except Exception as e:
    print(f"Actions failed: {e}")
    # Fallback to simple scrape
    result = firecrawl.scrape(url=url)
```

### 4. Test Selectors First
```python
# Test with simple scrape first
result = firecrawl.scrape(url, formats=["html"])

# Inspect HTML to find correct selectors
# Then add actions
```

### 5. Limit Action Sequences
```python
# Keep action sequences reasonable
# Too many actions = slower, more expensive, more likely to fail
actions = actions[:10]  # Limit to 10 actions
```

## Pricing

- **Actions:** No additional cost for actions
- **Total cost:** 1 credit per scrape (regardless of actions)
- **Note:** More actions = longer processing time

## Limitations

- **Timeout:** Total scrape time must be < 60 seconds (default)
- **Complexity:** Very complex interactions may fail
- **Reliability:** Actions depend on page structure staying consistent
- **JavaScript:** Requires JavaScript-rendered scraping (included)

## Related Documentation

- [Scraping](./04-scraping.md)
- [Advanced Options](./20-advanced-options.md)
- [API Reference](./11-scrape-endpoint.md)
- [Python SDK](./15-python-sdk.md)
