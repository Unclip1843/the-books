# Firecrawl Documentation

Complete reference documentation for Firecrawl API and SDKs.

**Version:** v1  
**Last Updated:** 2025-10-11

## Official Resources

- **Website:** https://www.firecrawl.dev/
- **Official Docs:** https://docs.firecrawl.dev/
- **API Reference:** https://api.firecrawl.dev/
- **GitHub:** https://github.com/firecrawl/firecrawl
- **Python SDK:** https://pypi.org/project/firecrawl-py/
- **Node.js SDK:** https://www.npmjs.com/package/@mendable/firecrawl-js

## Quick Links

- [Quickstart](./02-quickstart.md) - Get started in 5 minutes
- [Python SDK](./15-python-sdk.md) - Complete Python reference
- [Node.js SDK](./16-nodejs-sdk.md) - Complete TypeScript reference
- [API Overview](./10-api-overview.md) - REST API reference

## Table of Contents

### Getting Started (3 files)

- [01 - Overview](./01-overview.md) - What is Firecrawl
- [02 - Quickstart](./02-quickstart.md) - Get started in 5 minutes
- [03 - Authentication](./03-authentication.md) - API keys and security

### Core Features (6 files)

- [04 - Scraping](./04-scraping.md) - Single URL scraping
- [05 - Crawling](./05-crawling.md) - Recursive website crawling
- [06 - Mapping](./06-mapping.md) - URL discovery
- [07 - Search](./07-search.md) - Web search with scraping
- [08 - Extract](./08-extract.md) - LLM-powered data extraction
- [09 - Actions](./09-actions.md) - Interactive scraping

### API Reference (5 files)

- [10 - API Overview](./10-api-overview.md) - REST API basics
- [11 - Scrape Endpoint](./11-scrape-endpoint.md) - POST /v1/scrape
- [12 - Crawl Endpoint](./12-crawl-endpoint.md) - POST /v1/crawl
- [13 - Extract Endpoint](./13-extract-endpoint.md) - POST /v1/extract
- [14 - Map & Search Endpoints](./14-map-search-endpoints.md) - Map and search

### SDK Documentation (4 files)

- [15 - Python SDK](./15-python-sdk.md) - Complete Python reference
- [16 - Node.js SDK](./16-nodejs-sdk.md) - Complete TypeScript reference
- [17 - Async Operations](./17-async-operations.md) - Async crawls, WebSocket
- [18 - Error Handling](./18-error-handling.md) - Errors, retries, logging

### Advanced Features (5 files)

- [19 - Output Formats](./19-output-formats.md) - Markdown, HTML, screenshots
- [20 - Advanced Options](./20-advanced-options.md) - Stealth, headers, filtering
- [21 - Batch Operations](./21-batch-operations.md) - Concurrent scraping
- [22 - Caching](./22-caching.md) - Cache control and strategies
- [23 - Monitoring](./23-monitoring.md) - Progress tracking, WebSocket

### Integrations (4 files)

- [24 - LangChain](./24-langchain.md) - LangChain integration
- [25 - LlamaIndex](./25-llamaindex.md) - LlamaIndex integration
- [26 - Other Frameworks](./26-other-frameworks.md) - CrewAI, Dify, Flowise
- [27 - Zapier & n8n](./27-zapier-n8n.md) - Automation platforms

### Use Cases (4 files)

- [28 - AI Assistants](./28-ai-assistants.md) - Building AI assistants
- [29 - Lead Enrichment](./29-lead-enrichment.md) - Company data extraction
- [30 - SEO Tools](./30-seo-tools.md) - SEO analysis and audits
- [31 - Research](./31-research.md) - Data aggregation and analysis

### Best Practices & Reference (6 files)

- [32 - Best Practices](./32-best-practices.md) - Tips and patterns
- [33 - Cost Optimization](./33-cost-optimization.md) - Reduce credit usage
- [34 - Performance](./34-performance.md) - Speed optimization
- [35 - Troubleshooting](./35-troubleshooting.md) - Common issues
- [36 - Pricing](./36-pricing.md) - Credit costs and tiers
- [37 - Limits & Quotas](./37-limits-quotas.md) - Rate limits and quotas

## Quick Examples

### Python - Scrape
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")
result = firecrawl.scrape("https://firecrawl.dev")
print(result['markdown'])
```

### Python - Crawl
```python
result = firecrawl.crawl(
    url="https://docs.firecrawl.dev",
    limit=100
)

for page in result['data']:
    print(page['url'])
```

### Node.js - Scrape
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });
const result = await firecrawl.scrapeUrl('https://firecrawl.dev');
console.log(result.markdown);
```

### Node.js - Crawl
```javascript
const result = await firecrawl.crawlUrl('https://docs.firecrawl.dev', {
  limit: 100
});

result.data.forEach(page => console.log(page.url));
```

## Common Tasks

| Task | Documentation |
|------|--------------|
| Get started | [Quickstart](./02-quickstart.md) |
| Scrape a page | [Scraping Guide](./04-scraping.md) |
| Crawl a website | [Crawling Guide](./05-crawling.md) |
| Extract structured data | [Extract Guide](./08-extract.md) |
| Build AI assistant | [AI Assistants](./28-ai-assistants.md) |
| Integrate with LangChain | [LangChain](./24-langchain.md) |
| Handle errors | [Error Handling](./18-error-handling.md) |
| Optimize costs | [Cost Optimization](./33-cost-optimization.md) |

## Installation

### Python
```bash
pip install firecrawl-py
```

### Node.js
```bash
npm install @mendable/firecrawl-js
```

## Authentication

Get your API key from [firecrawl.dev](https://www.firecrawl.dev/):

```python
# Python
from firecrawl import Firecrawl
firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")
```

```javascript
// Node.js
import Firecrawl from '@mendable/firecrawl-js';
const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });
```

## Support

- **Documentation:** https://docs.firecrawl.dev/
- **GitHub Issues:** https://github.com/firecrawl/firecrawl/issues
- **Discord:** Check website for invite link

## License

This documentation mirrors the official Firecrawl documentation and API reference.

## Status

**Total Files:** 39 (37 documentation files + README + SOURCES)  
**Last Updated:** 2025-10-11  
**Status:** Complete ✓
