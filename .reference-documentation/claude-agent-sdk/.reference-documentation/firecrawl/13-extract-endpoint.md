# Firecrawl - Extract Endpoint

**Sources:**
- https://docs.firecrawl.dev/api-reference/endpoint/extract
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Endpoint

```
POST /v1/extract
```

## Description

Uses LLM to extract structured data from URLs based on schema or prompt. Powered by FIRE-1 AI agent.

## Request

### Headers
```
Authorization: Bearer fc-YOUR-API-KEY
Content-Type: application/json
```

### Body Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| urls | array | Yes* | URLs to extract from |
| schema | object | No** | JSON schema defining output structure |
| prompt | string | No** | Natural language extraction prompt |
| searchQuery | string | No | Search query (alternative to urls) |
| searchType | string | No | Search type: web, news, github, research |
| limit | number | No | Max results when using search |

\* Required unless using `searchQuery`  
\** Either `schema` or `prompt` required

### Example Request

```bash
curl -X POST https://api.firecrawl.dev/v1/extract \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "urls": ["https://example.com/about"],
    "schema": {
      "type": "object",
      "properties": {
        "company_name": {"type": "string"},
        "founded": {"type": "number"},
        "ceo": {"type": "string"}
      }
    }
  }'
```

## Response

### Success Response (200)

```json
{
  "success": true,
  "data": {
    "company_name": "Example Corp",
    "founded": 2010,
    "ceo": "John Smith"
  },
  "metadata": {
    "sourceURL": "https://example.com/about",
    "processingTime": 2.5
  }
}
```

### Multiple URLs Response

```json
{
  "success": true,
  "data": [
    {
      "company_name": "Company A",
      "founded": 2010,
      "ceo": "John Smith"
    },
    {
      "company_name": "Company B",
      "founded": 2015,
      "ceo": "Jane Doe"
    }
  ]
}
```

## Schema-Based Extraction

### Simple Schema
```json
{
  "urls": ["https://example.com"],
  "schema": {
    "type": "object",
    "properties": {
      "title": {"type": "string"},
      "author": {"type": "string"},
      "date": {"type": "string"}
    },
    "required": ["title"]
  }
}
```

### Complex Schema with Arrays
```json
{
  "urls": ["https://example.com/products"],
  "schema": {
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
}
```

### Nested Objects
```json
{
  "urls": ["https://example.com"],
  "schema": {
    "type": "object",
    "properties": {
      "company": {
        "type": "object",
        "properties": {
          "name": {"type": "string"},
          "location": {"type": "string"}
        }
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
}
```

## Prompt-Based Extraction

### Simple Prompt
```json
{
  "urls": ["https://example.com"],
  "prompt": "Extract the company name, CEO, and founding year"
}
```

### Detailed Prompt
```json
{
  "urls": ["https://example.com/article"],
  "prompt": "Extract: article title, author name, publication date, main topics (as array), key takeaways (as array), sentiment (positive/negative/neutral)"
}
```

## Search + Extract

### Web Search
```json
{
  "searchQuery": "Y Combinator companies 2024",
  "limit": 10,
  "schema": {
    "type": "object",
    "properties": {
      "name": {"type": "string"},
      "description": {"type": "string"},
      "founders": {"type": "string"},
      "year": {"type": "number"}
    }
  }
}
```

### News Search
```json
{
  "searchQuery": "AI developments",
  "searchType": "news",
  "limit": 5,
  "prompt": "Extract headline, publication date, summary, and key points"
}
```

## Examples

### Python - Schema Extraction
```python
import requests

url = "https://api.firecrawl.dev/v1/extract"
headers = {
    "Authorization": "Bearer fc-YOUR-API-KEY",
    "Content-Type": "application/json"
}

data = {
    "urls": ["https://example.com/about"],
    "schema": {
        "type": "object",
        "properties": {
            "company_name": {"type": "string"},
            "founded": {"type": "number"},
            "employees": {"type": "number"}
        }
    }
}

response = requests.post(url, headers=headers, json=data)
result = response.json()

print(result['data'])
```

### Python - Prompt Extraction
```python
data = {
    "urls": ["https://example.com"],
    "prompt": "Extract all team member names, roles, and email addresses"
}

response = requests.post(url, headers=headers, json=data)
result = response.json()
```

### Python - Multi-URL Extraction
```python
data = {
    "urls": [
        "https://example.com/team/person1",
        "https://example.com/team/person2",
        "https://example.com/team/person3"
    ],
    "schema": {
        "type": "object",
        "properties": {
            "name": {"type": "string"},
            "role": {"type": "string"},
            "email": {"type": "string"}
        }
    }
}

response = requests.post(url, headers=headers, json=data)
results = response.json()['data']

for person in results:
    print(f"{person['name']} - {person['role']}")
```

### Node.js - Extraction
```javascript
const response = await fetch('https://api.firecrawl.dev/v1/extract', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer fc-YOUR-API-KEY',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    urls: ['https://example.com'],
    schema: {
      type: 'object',
      properties: {
        title: { type: 'string' },
        author: { type: 'string' }
      }
    }
  })
});

const result = await response.json();
console.log(result.data);
```

## Schema Types

### Supported Types

- `string` - Text data
- `number` - Numeric data (int or float)
- `boolean` - true/false
- `array` - Lists of items
- `object` - Nested objects
- `null` - Null values

### Example with All Types
```json
{
  "schema": {
    "type": "object",
    "properties": {
      "name": {"type": "string"},
      "age": {"type": "number"},
      "active": {"type": "boolean"},
      "tags": {
        "type": "array",
        "items": {"type": "string"}
      },
      "address": {
        "type": "object",
        "properties": {
          "street": {"type": "string"},
          "city": {"type": "string"}
        }
      }
    }
  }
}
```

## Error Codes

| Code | Error | Solution |
|------|-------|----------|
| 400 | Invalid schema | Check schema format |
| 401 | Unauthorized | Check API key |
| 402 | Payment Required | Add credits |
| 429 | Rate Limited | Slow down requests |
| 500 | Extraction Failed | Retry or simplify schema |

## Pricing

- **Extract (Beta):** 2-5 credits per URL
- **Varies by:** Complexity, content size, schema depth
- **Search + Extract:** Search credits + extraction credits

## Best Practices

### 1. Use Specific Schemas
```json
// Good - specific structure
{
  "properties": {
    "price": {"type": "number"},
    "currency": {"type": "string"}
  }
}

// Less effective - too vague
{
  "properties": {
    "data": {"type": "string"}
  }
}
```

### 2. Mark Required Fields
```json
{
  "schema": {
    "properties": {...},
    "required": ["name", "price"]
  }
}
```

### 3. Use Prompts for Flexibility
When structure varies across pages, use prompts instead of rigid schemas.

### 4. Batch URLs
```json
{
  "urls": [
    "https://example.com/page1",
    "https://example.com/page2",
    "https://example.com/page3"
  ]
}
```

### 5. Validate Results
```python
result = response.json()['data']

if 'name' not in result:
    print("Missing required field")
```

## Limitations (Beta)

- **Beta status:** Feature still being refined
- **Processing time:** 2-10 seconds per URL
- **Complexity limits:** Very complex schemas may fail
- **Accuracy:** Depends on content clarity

## Related Documentation

- [Extract Guide](./08-extract.md)
- [API Overview](./10-api-overview.md)
- [Python SDK](./15-python-sdk.md)
- [Lead Enrichment](./29-lead-enrichment.md)
