# Firecrawl - Output Formats

**Sources:**
- https://docs.firecrawl.dev/features/scrape
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Available Formats

Firecrawl supports multiple output formats:

| Format | Use Case | Cost |
|--------|----------|------|
| Markdown | LLM input, clean text | Included |
| HTML | Preserve structure | Included |
| Screenshot | Visual capture | Included |
| JSON | Structured data | +2 credits |

## Markdown Format

Clean, readable text perfect for LLMs.

### Features
- Preserves document structure
- Links maintained
- Images as markdown references
- Tables converted
- Lists preserved

### Example
```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["markdown"]
)

print(result['markdown'])
```

### Output
```markdown
# Page Title

This is the main content.

## Section 1

Content here with [link](https://example.com).

- List item 1
- List item 2

| Column 1 | Column 2 |
|----------|----------|
| Data 1   | Data 2   |
```

## HTML Format

Full HTML structure preserved.

### Features
- Complete HTML structure
- All tags and attributes
- Inline styles
- JavaScript (if present)

### Example
```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["html"]
)

print(result['html'])
```

### Output
```html
<!DOCTYPE html>
<html>
<head>
    <title>Page Title</title>
    <meta name="description" content="Description">
</head>
<body>
    <h1>Page Title</h1>
    <p>Content here.</p>
</body>
</html>
```

## Screenshot Format

Base64-encoded PNG image.

### Features
- Full page screenshot
- Rendered view
- Base64 encoded
- Ready for display

### Example
```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["screenshot"]
)

# Get base64 image
screenshot_base64 = result['screenshot']

# Save to file
import base64
image_data = base64.b64decode(screenshot_base64)
with open('screenshot.png', 'wb') as f:
    f.write(image_data)
```

### Display in HTML
```html
<img src="data:image/png;base64,{base64_string}" />
```

## JSON Format (Beta)

Structured data extraction.

### Features
- Structured output
- Custom schemas
- LLM-powered
- Additional cost (+2 credits)

### Example
```python
result = firecrawl.extract(
    urls=["https://example.com"],
    schema={
        "type": "object",
        "properties": {
            "title": {"type": "string"},
            "author": {"type": "string"}
        }
    }
)

print(result['data'])
```

### Output
```json
{
  "title": "Page Title",
  "author": "John Doe"
}
```

## Multiple Formats

Request multiple formats at once:

```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["markdown", "html", "screenshot"]
)

# Access each format
markdown = result['markdown']
html = result['html']
screenshot = result['screenshot']
metadata = result['metadata']
```

## Format-Specific Options

### Markdown Options
```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["markdown"],
    onlyMainContent=True,  # Remove nav, footer
    excludeTags=["aside", "nav"]  # Exclude specific tags
)
```

### HTML Options
```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["html"],
    includeTags=["article", "main"]  # Only these tags
)
```

### Screenshot Options
```python
result = firecrawl.scrape(
    url="https://example.com",
    formats=["screenshot"],
    waitFor=3000  # Wait for page to load
)
```

## Format Comparisons

### Markdown vs HTML

**Markdown:**
- ✅ Clean and readable
- ✅ Perfect for LLMs
- ✅ Small file size
- ❌ Loses some structure

**HTML:**
- ✅ Complete structure
- ✅ All elements preserved
- ❌ Larger file size
- ❌ Harder to parse

### When to Use Each

**Use Markdown when:**
- Feeding to LLMs
- Need readable text
- Content extraction
- File size matters

**Use HTML when:**
- Need exact structure
- Parsing with BeautifulSoup
- Preserving all elements
- Web scraping tasks

**Use Screenshot when:**
- Visual verification
- Layout matters
- Archiving pages
- Bug reports

**Use JSON when:**
- Need structured data
- Specific fields
- Database insertion
- API integration

## Complete Examples

### 1. All Formats
```python
result = firecrawl.scrape(
    url="https://example.com/article",
    formats=["markdown", "html", "screenshot"]
)

# Save markdown
with open('article.md', 'w') as f:
    f.write(result['markdown'])

# Save HTML
with open('article.html', 'w') as f:
    f.write(result['html'])

# Save screenshot
import base64
image_data = base64.b64decode(result['screenshot'])
with open('article.png', 'wb') as f:
    f.write(image_data)

# Save metadata
import json
with open('article.json', 'w') as f:
    json.dump(result['metadata'], f, indent=2)
```

### 2. Markdown for LLM
```python
import anthropic

# Scrape article
result = firecrawl.scrape(
    url="https://example.com/article",
    formats=["markdown"],
    onlyMainContent=True
)

# Feed to Claude
client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{
        "role": "user",
        "content": f"Summarize this article:\n\n{result['markdown']}"
    }]
)

print(response.content[0].text)
```

### 3. HTML Parsing
```python
from bs4 import BeautifulSoup

result = firecrawl.scrape(
    url="https://example.com",
    formats=["html"]
)

soup = BeautifulSoup(result['html'], 'html.parser')

# Extract all links
links = [a['href'] for a in soup.find_all('a', href=True)]

# Extract all headings
headings = [h.text for h in soup.find_all(['h1', 'h2', 'h3'])]
```

### 4. Screenshot Archive
```python
import base64
from datetime import datetime

def archive_page(url):
    result = firecrawl.scrape(
        url=url,
        formats=["screenshot", "markdown"]
    )
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = url.replace('https://', '').replace('/', '_')
    
    # Save screenshot
    image_data = base64.b64decode(result['screenshot'])
    with open(f'archive/{filename}_{timestamp}.png', 'wb') as f:
        f.write(image_data)
    
    # Save markdown
    with open(f'archive/{filename}_{timestamp}.md', 'w') as f:
        f.write(result['markdown'])

archive_page("https://example.com")
```

## Pricing

| Format | Additional Cost |
|--------|----------------|
| Markdown | Included |
| HTML | Included |
| Screenshot | Included |
| JSON (Extract) | +2 credits |

Base scrape cost: 1 credit

## Best Practices

### 1. Request Only What You Need
```python
# Good - specific format
formats=["markdown"]

# Bad - unnecessary formats
formats=["markdown", "html", "screenshot"]
```

### 2. Use onlyMainContent
```python
# Good - clean content
result = firecrawl.scrape(
    url=url,
    formats=["markdown"],
    onlyMainContent=True
)

# Less ideal - includes nav, footer
result = firecrawl.scrape(url=url, formats=["markdown"])
```

### 3. Choose Right Format for Task
```python
# For LLM input
formats=["markdown"]

# For parsing
formats=["html"]

# For visual verification
formats=["screenshot"]

# For structured data
# Use extract() instead
```

## Related Documentation

- [Scraping](./04-scraping.md)
- [Extract](./08-extract.md)
- [Python SDK](./15-python-sdk.md)
- [Best Practices](./32-best-practices.md)
