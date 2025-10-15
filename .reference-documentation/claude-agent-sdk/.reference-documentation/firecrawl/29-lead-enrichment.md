# Firecrawl - Lead Enrichment Use Case

**Sources:**
- https://docs.firecrawl.dev/
- https://www.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Extract company data from websites for lead enrichment and CRM integration.

## Basic Pattern

```
Company URL → Scrape/Extract → Structured Data → CRM
```

## Simple Example

```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

def enrich_lead(company_url):
    schema = {
        "type": "object",
        "properties": {
            "company_name": {"type": "string"},
            "industry": {"type": "string"},
            "size": {"type": "string"},
            "founded": {"type": "number"},
            "location": {"type": "string"},
            "email": {"type": "string"},
            "phone": {"type": "string"}
        }
    }
    
    result = firecrawl.extract(
        urls=[company_url],
        schema=schema
    )
    
    return result['data']

# Usage
company_data = enrich_lead("https://example.com/about")
print(company_data)
```

## Related Documentation

- [Extract](./08-extract.md)
- [Python SDK](./15-python-sdk.md)
