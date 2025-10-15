# Firecrawl - Extract

**Sources:**
- https://docs.firecrawl.dev/features/extract
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Extract uses LLM-powered extraction to transform unstructured web content into structured data. Define schemas or use natural language prompts to extract exactly what you need.

**Powered by:** FIRE-1 AI agent

## How Extract Works

```
URLs → Scrape Content → LLM Processing → Structured Output
```

**Features:**
- Schema-based extraction (define structure)
- Prompt-based extraction (natural language)
- Multi-URL extraction
- Web search expansion
- Consistent JSON output

## Basic Extract

### Python
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

# Extract with prompt
result = firecrawl.extract(
    urls=["https://example.com/about"],
    prompt="Extract the company name, founding year, and CEO"
)

print(result['data'])
```

### Node.js
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });

const result = await firecrawl.extract({
  urls: ['https://example.com/about'],
  prompt: 'Extract the company name, founding year, and CEO'
});

console.log(result.data);
```

### cURL
```bash
curl -X POST https://api.firecrawl.dev/v1/extract \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "urls": ["https://example.com/about"],
    "prompt": "Extract the company name, founding year, and CEO"
  }'
```

## Schema-Based Extraction

Define exact structure you want:

### Python
```python
schema = {
    "type": "object",
    "properties": {
        "company_name": {"type": "string"},
        "founded": {"type": "number"},
        "ceo": {"type": "string"},
        "employees": {"type": "number"},
        "headquarters": {"type": "string"}
    },
    "required": ["company_name", "founded"]
}

result = firecrawl.extract(
    urls=["https://example.com/about"],
    schema=schema
)

print(result['data'])
# Output:
# {
#   "company_name": "Example Corp",
#   "founded": 2010,
#   "ceo": "John Smith",
#   "employees": 500,
#   "headquarters": "San Francisco, CA"
# }
```

### Node.js
```javascript
const schema = {
  type: 'object',
  properties: {
    company_name: { type: 'string' },
    founded: { type: 'number' },
    ceo: { type: 'string' },
    employees: { type: 'number' },
    headquarters: { type: 'string' }
  },
  required: ['company_name', 'founded']
};

const result = await firecrawl.extract({
  urls: ['https://example.com/about'],
  schema: schema
});
```

## Complex Schemas

### Nested Objects
```python
schema = {
    "type": "object",
    "properties": {
        "company": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "founded": {"type": "number"}
            }
        },
        "leadership": {
            "type": "object",
            "properties": {
                "ceo": {"type": "string"},
                "cto": {"type": "string"}
            }
        }
    }
}
```

### Arrays
```python
schema = {
    "type": "object",
    "properties": {
        "products": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "price": {"type": "number"},
                    "description": {"type": "string"}
                }
            }
        }
    }
}

result = firecrawl.extract(
    urls=["https://example.com/products"],
    schema=schema
)

print(result['data']['products'])
# Output:
# [
#   {"name": "Product A", "price": 29.99, "description": "..."},
#   {"name": "Product B", "price": 49.99, "description": "..."}
# ]
```

## Multi-URL Extraction

Extract from multiple pages:

```python
urls = [
    "https://example.com/team/john",
    "https://example.com/team/jane",
    "https://example.com/team/bob"
]

schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "role": {"type": "string"},
        "email": {"type": "string"},
        "bio": {"type": "string"}
    }
}

result = firecrawl.extract(urls=urls, schema=schema)

for person in result['data']:
    print(f"{person['name']} - {person['role']}")
```

## Search + Extract

Combine search with extraction:

```python
# Search for companies, then extract data
result = firecrawl.extract(
    prompt="Find and extract information about Y Combinator companies: name, description, founders, year",
    searchQuery="Y Combinator companies 2024",
    limit=10
)

for company in result['data']:
    print(f"{company['name']} ({company['year']})")
    print(f"Founders: {company['founders']}")
    print(f"Description: {company['description']}")
    print("---")
```

## Prompt-Based Extraction

Use natural language instead of schemas:

```python
# Simple extraction
result = firecrawl.extract(
    urls=["https://news.ycombinator.com"],
    prompt="Extract all post titles and their scores"
)

# Complex extraction
result = firecrawl.extract(
    urls=["https://example.com/article"],
    prompt="""
    Extract the following information:
    - Article title
    - Author name
    - Publication date
    - Main topics covered
    - Key takeaways (as a list)
    - Sentiment (positive/negative/neutral)
    """
)
```

## Response Format

```json
{
  "success": true,
  "data": {
    "company_name": "Example Corp",
    "founded": 2010,
    "ceo": "John Smith",
    "employees": 500,
    "headquarters": "San Francisco, CA"
  },
  "metadata": {
    "sourceURL": "https://example.com/about",
    "processingTime": 2.5
  }
}
```

## Pricing

- **Extract (Beta):** Pricing varies by complexity
- **Single URL:** ~2-5 credits
- **Multiple URLs:** ~2-5 credits per URL
- **Search + Extract:** Search credits + extraction credits

## Use Cases

### 1. Lead Enrichment
```python
def enrich_company_data(company_url):
    schema = {
        "type": "object",
        "properties": {
            "name": {"type": "string"},
            "industry": {"type": "string"},
            "size": {"type": "string"},
            "revenue": {"type": "string"},
            "technologies": {
                "type": "array",
                "items": {"type": "string"}
            },
            "contact": {
                "type": "object",
                "properties": {
                    "email": {"type": "string"},
                    "phone": {"type": "string"}
                }
            }
        }
    }
    
    result = firecrawl.extract(
        urls=[company_url],
        schema=schema
    )
    
    return result['data']
```

### 2. Product Catalog
```python
def extract_products(store_url):
    schema = {
        "type": "object",
        "properties": {
            "products": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "name": {"type": "string"},
                        "price": {"type": "number"},
                        "description": {"type": "string"},
                        "image_url": {"type": "string"},
                        "in_stock": {"type": "boolean"}
                    }
                }
            }
        }
    }
    
    result = firecrawl.extract(
        urls=[store_url],
        schema=schema
    )
    
    return result['data']['products']
```

### 3. Job Listings
```python
def extract_jobs(career_page_url):
    schema = {
        "type": "object",
        "properties": {
            "jobs": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "title": {"type": "string"},
                        "department": {"type": "string"},
                        "location": {"type": "string"},
                        "type": {"type": "string"},
                        "salary_range": {"type": "string"},
                        "posted_date": {"type": "string"}
                    }
                }
            }
        }
    }
    
    result = firecrawl.extract(
        urls=[career_page_url],
        schema=schema
    )
    
    return result['data']['jobs']
```

### 4. News Monitoring
```python
def monitor_news(topic):
    result = firecrawl.extract(
        searchQuery=f"{topic} news",
        limit=10,
        prompt="""
        Extract from each article:
        - Headline
        - Publication date
        - Author
        - Summary (2-3 sentences)
        - Sentiment (positive/negative/neutral)
        - Key entities mentioned
        """
    )
    
    return result['data']
```

### 5. Research Data Collection
```python
def collect_research_data(topic, num_papers=20):
    result = firecrawl.extract(
        searchQuery=topic,
        searchType="research",
        limit=num_papers,
        schema={
            "type": "object",
            "properties": {
                "papers": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "title": {"type": "string"},
                            "authors": {
                                "type": "array",
                                "items": {"type": "string"}
                            },
                            "abstract": {"type": "string"},
                            "publication_date": {"type": "string"},
                            "citations": {"type": "number"}
                        }
                    }
                }
            }
        }
    )
    
    return result['data']['papers']
```

## Best Practices

### 1. Define Clear Schemas
```python
# Good - specific types and structure
schema = {
    "type": "object",
    "properties": {
        "price": {"type": "number"},
        "in_stock": {"type": "boolean"},
        "name": {"type": "string"}
    },
    "required": ["name", "price"]
}

# Less effective - too vague
schema = {
    "type": "object",
    "properties": {
        "data": {"type": "string"}
    }
}
```

### 2. Use Prompts for Flexibility
```python
# When structure varies
result = firecrawl.extract(
    urls=["https://example.com"],
    prompt="Extract all relevant company information you can find"
)
```

### 3. Validate Results
```python
result = firecrawl.extract(urls=[url], schema=schema)

# Check required fields
if 'name' not in result['data'] or not result['data']['name']:
    print("Missing required field: name")
```

### 4. Handle Errors
```python
try:
    result = firecrawl.extract(urls=[url], schema=schema)
except Exception as e:
    print(f"Extraction failed: {e}")
    # Fallback to scraping
    result = firecrawl.scrape(url)
```

### 5. Batch Processing
```python
# Process multiple URLs efficiently
urls = [f"https://example.com/item/{i}" for i in range(1, 101)]

# Batch in groups
batch_size = 10
for i in range(0, len(urls), batch_size):
    batch = urls[i:i+batch_size]
    result = firecrawl.extract(urls=batch, schema=schema)
    # Process results
```

## Extract vs Other Methods

| Method | Use Case | Output | Cost |
|--------|----------|--------|------|
| Extract | Structured data | JSON | 2-5 credits |
| Scrape | Raw content | Markdown/HTML | 1 credit |
| Crawl | Many pages | Markdown/HTML | 1 per page |
| Search | Web search | Markdown/HTML | 1 per result |

## Limitations (Beta)

- **Beta feature:** May have occasional issues
- **Processing time:** Slower than scraping (LLM processing)
- **Cost:** Higher than simple scraping
- **Accuracy:** Depends on content clarity and schema definition

## Related Documentation

- [Scraping](./04-scraping.md)
- [Search](./07-search.md)
- [API Reference](./13-extract-endpoint.md)
- [Python SDK](./15-python-sdk.md)
- [Lead Enrichment](./29-lead-enrichment.md)
