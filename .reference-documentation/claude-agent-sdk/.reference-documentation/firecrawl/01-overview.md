# Firecrawl - Overview

**Sources:**
- https://www.firecrawl.dev/
- https://docs.firecrawl.dev/
- https://github.com/firecrawl/firecrawl

**Fetched:** 2025-10-11

## What is Firecrawl?

Firecrawl is a **Web Data API for AI** that transforms entire websites into LLM-ready markdown or structured data. It's designed to handle the complexity of modern web scraping, including JavaScript-heavy sites, anti-bot protection, and dynamic content.

**Mission:** Turn any website into clean, structured data that's ready for AI/LLM consumption.

## Key Capabilities

### 1. **Scraping**
Convert any URL into clean markdown, HTML, JSON, or screenshots
- Handles JavaScript rendering
- Bypasses common blockers
- Extracts text, images, and metadata
- Multiple output formats

### 2. **Crawling**
Recursively extract content from entire websites
- Automatic subpage discovery
- Configurable depth limits
- Domain/subdomain control
- No sitemap required

### 3. **Mapping**
Quickly get a complete list of URLs from any website
- Fast site structure analysis
- Perfect for site audits
- SEO analysis
- Link discovery

### 4. **Search**
Perform web searches with full content retrieval
- Search across web, news, images
- GitHub/research-specific searches
- Location and time-based filtering
- Returns scraped content, not just links

### 5. **Extract**
LLM-powered structured data extraction
- Define schemas or use natural language prompts
- Extract from single or multiple URLs
- Powered by FIRE-1 AI agent
- Perfect for data aggregation

### 6. **Actions**
Interactive web scraping
- Click elements
- Scroll pages
- Type text
- Wait for dynamic content
- Automate form filling

## Why Firecrawl?

### vs. Traditional Web Scrapers

| Feature | Firecrawl | Traditional Scrapers |
|---------|-----------|---------------------|
| JavaScript rendering | ✅ Built-in | ❌ Requires setup |
| Anti-bot bypass | ✅ Automatic | ❌ Manual config |
| LLM-ready output | ✅ Yes | ❌ Raw HTML |
| Proxy management | ✅ Handled | ❌ You configure |
| Maintenance | ✅ Zero | ❌ Constant updates |

### Key Differentiators

**🚀 Speed**
- Results in under 1 second for most pages
- Optimized for high-throughput

**🎯 Reliability**
- Covers 96% of websites
- Handles JavaScript-heavy sites
- Works with protected pages

**🧠 AI-Ready**
- Clean markdown output
- Structured JSON extraction
- Perfect for RAG systems

**💪 Comprehensive**
- No sitemap needed
- Media parsing (PDFs, DOCX)
- Screenshot capture

## Use Cases

### 1. AI Assistants
Build chatbots with real-time web context
```
User: "What's the latest news about AI?"
→ Firecrawl searches and scrapes results
→ Feed to Claude/GPT
→ Assistant responds with current info
```

### 2. Lead Enrichment
Extract company data at scale
- Company websites → structured data
- Contact information gathering
- Social media profile extraction
- CRM integration

### 3. SEO Tools
Analyze and optimize websites
- Competitor analysis
- Content extraction
- Backlink discovery
- Site auditing

### 4. Deep Research
Aggregate data from multiple sources
- Academic research
- Market analysis
- Price comparison
- Review aggregation

### 5. AI Platforms
Power AI apps with web data
- RAG (Retrieval Augmented Generation)
- Training data collection
- Real-time context injection
- Knowledge base building

## Architecture

```
┌─────────────┐
│  Your App   │
└──────┬──────┘
       │ API Call
       ▼
┌─────────────────────────────┐
│     Firecrawl API           │
│                             │
│  ┌─────────────────────┐   │
│  │  Smart Routing      │   │
│  └─────────────────────┘   │
│           │                 │
│  ┌────────▼────────┐       │
│  │ Browser Pool    │       │
│  │ (JS rendering)  │       │
│  └────────┬────────┘       │
│           │                 │
│  ┌────────▼────────┐       │
│  │ Content Extract │       │
│  │ (Clean markdown)│       │
│  └────────┬────────┘       │
│           │                 │
│  ┌────────▼────────┐       │
│  │ Format & Return │       │
│  └─────────────────┘       │
└─────────────────────────────┘
       │
       ▼ Clean Data
┌──────────────┐
│  Your App    │
│  (with data) │
└──────────────┘
```

## Output Formats

### Markdown
```markdown
# Page Title

Clean, readable content perfect for LLMs.

- Bullet points preserved
- Links maintained
- Images referenced
```

### HTML
```html
<div>Original HTML structure</div>
```

### JSON (Structured)
```json
{
  "title": "Page Title",
  "content": "Main content",
  "metadata": {...},
  "links": [...],
  "images": [...]
}
```

### Screenshots
```
PNG/JPEG image of the rendered page
```

## Pricing Model

Firecrawl uses a **credit-based system**:

- **Scrape:** 1 credit per page
- **Crawl:** 1 credit per page crawled
- **Search:** 1 credit per result
- **Extract:** Variable based on complexity

**Additional Costs:**
- PDF parsing: +1 credit
- Stealth mode: +1 credit
- JSON extraction: +2 credits

**Tiers:** Free, Starter, Growth, Scale, Enterprise

## Supported Languages

### Official SDKs
- **Python:** `pip install firecrawl-py`
- **Node.js/TypeScript:** `npm install @mendable/firecrawl-js`

### Community SDKs
- **Go:** github.com/firecrawl/firecrawl-go
- **Rust:** crates.io/crates/firecrawl

### Direct API
- **cURL:** Standard HTTP requests
- **Any language:** REST API compatible

## Platform Integrations

### LLM Frameworks
- **LangChain:** Document loaders
- **LlamaIndex:** Data connectors
- **CrewAI:** Agent tools
- **Camel AI:** Web scraping components

### Low-Code Platforms
- **Dify:** AI app builder
- **Flowise:** Visual LLM chains
- **Langflow:** Drag-and-drop AI

### Automation
- **Zapier:** No-code workflows
- **n8n:** Workflow automation
- **Make:** Integration platform

## Getting Started

### 1. Sign Up
Visit [firecrawl.dev](https://www.firecrawl.dev/) and create an account

### 2. Get API Key
Navigate to dashboard → API Keys → Create new key

### 3. Install SDK
```bash
# Python
pip install firecrawl-py

# Node.js
npm install @mendable/firecrawl-js
```

### 4. First Scrape
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")
result = firecrawl.scrape("https://firecrawl.dev")
print(result['markdown'])
```

## Open Source vs Cloud

| Feature | Open Source | Cloud |
|---------|-------------|-------|
| Self-hosted | ✅ Yes | ❌ No |
| Cost | Free (infra) | Pay-per-use |
| Maintenance | You manage | Fully managed |
| Scale | Manual | Auto-scale |
| Features | Core | Core + Advanced |
| Support | Community | Priority |

**Open Source:**
- AGPL-3.0 license
- Self-host for free
- Full control
- GitHub: github.com/firecrawl/firecrawl

**Cloud:**
- Fully managed
- No infrastructure
- Automatic updates
- Higher rate limits

## Performance

**Speed:**
- Most pages: <1 second
- Complex sites: 2-5 seconds
- Full crawls: Minutes (depending on size)

**Coverage:**
- 96% of websites supported
- JavaScript-rendered sites ✅
- Single-page apps ✅
- Protected sites ✅ (with stealth mode)

**Reliability:**
- Built-in retries
- Automatic error handling
- Fallback strategies
- 99.9% uptime (cloud)

## Limitations

- **Rate limits:** Based on subscription tier
- **Timeout:** 60 seconds per request (default)
- **Page size:** 10MB max per page
- **Concurrent requests:** Tier-dependent
- **Crawl depth:** Configurable, max varies by tier

## Security & Privacy

- **API Keys:** Secure bearer token authentication
- **Data:** Not stored on Firecrawl servers
- **Requests:** HTTPS only
- **Compliance:** GDPR-friendly
- **Robots.txt:** Respects (configurable)

## Next Steps

- **[Quickstart Guide](./02-quickstart.md)** - Your first scrape in 5 minutes
- **[Scraping Guide](./04-scraping.md)** - Master single-page scraping
- **[Crawling Guide](./05-crawling.md)** - Extract entire websites
- **[Python SDK](./15-python-sdk.md)** - Complete Python reference
- **[Node.js SDK](./16-nodejs-sdk.md)** - Complete TypeScript reference

## Related Documentation

- [Authentication](./03-authentication.md)
- [API Reference](./10-api-overview.md)
- [Best Practices](./32-best-practices.md)
- [Pricing](./36-pricing.md)
