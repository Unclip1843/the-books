# Firecrawl - Zapier & n8n Integration

**Sources:**
- https://docs.firecrawl.dev/integrations/zapier
- https://docs.firecrawl.dev/integrations/n8n

**Fetched:** 2025-10-11

## Zapier Integration

### Setup
1. Log in to Zapier
2. Create new Zap
3. Search for "Firecrawl"
4. Click "Connect Account"
5. Enter Firecrawl API key

### Available Actions
- Scrape URL
- Crawl Website
- Search Web

### Example Zaps

**1. Save Blog Posts to Notion**
```
Trigger: Schedule (Daily)
↓
Action: Firecrawl (Crawl)
URL: https://example.com/blog
Limit: 10
↓
Action: Notion (Create Page)
```

**2. Monitor Competitor Pricing**
```
Trigger: Schedule (Hourly)
↓
Action: Firecrawl (Scrape)
URL: https://competitor.com/pricing
↓
Filter: Price changed
↓
Action: Send Email Alert
```

**3. Content Aggregation**
```
Trigger: RSS Feed
↓
Action: Firecrawl (Scrape)
Extract article content
↓
Action: Save to Airtable
```

## n8n Integration

### Installation

**Self-Hosted:**
```bash
npm install n8n-nodes-firecrawl
```

**Cloud:** Available by default

### Setup
1. Add Firecrawl node
2. Create credentials
3. Enter API key

### Example Workflows

**1. Daily News Aggregation**
```json
{
  "nodes": [
    {
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.scheduleTrigger",
      "parameters": {
        "rule": {
          "interval": "day"
        }
      }
    },
    {
      "name": "Firecrawl",
      "type": "n8n-nodes-firecrawl.firecrawl",
      "parameters": {
        "operation": "search",
        "query": "tech news",
        "limit": 10
      }
    },
    {
      "name": "Process Results",
      "type": "n8n-nodes-base.code",
      "parameters": {
        "code": "return items.map(item => ({
          json: {
            title: item.json.metadata.title,
            url: item.json.url,
            content: item.json.markdown
          }
        }));"
      }
    },
    {
      "name": "Send to Slack",
      "type": "n8n-nodes-base.slack",
      "parameters": {
        "operation": "sendMessage"
      }
    }
  ]
}
```

**2. Website Monitoring**
```json
{
  "nodes": [
    {
      "name": "Schedule",
      "type": "n8n-nodes-base.scheduleTrigger",
      "parameters": {
        "rule": {
          "interval": "hour"
        }
      }
    },
    {
      "name": "Scrape Page",
      "type": "n8n-nodes-firecrawl.firecrawl",
      "parameters": {
        "operation": "scrape",
        "url": "https://example.com/status"
      }
    },
    {
      "name": "Check Changes",
      "type": "n8n-nodes-base.compare",
      "parameters": {
        "conditions": {
          "string": [
            {
              "value1": "={{$json.markdown}}",
              "operation": "notEqual",
              "value2": "={{$node[\"Previous\"].json.markdown}}"
            }
          ]
        }
      }
    },
    {
      "name": "Send Alert",
      "type": "n8n-nodes-base.emailSend"
    }
  ]
}
```

**3. Documentation Sync**
```json
{
  "nodes": [
    {
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "webhookId": "docs-sync"
    },
    {
      "name": "Crawl Docs",
      "type": "n8n-nodes-firecrawl.firecrawl",
      "parameters": {
        "operation": "crawl",
        "url": "{{$json.docs_url}}",
        "limit": 100,
        "includePaths": ["/docs/*"]
      }
    },
    {
      "name": "Transform",
      "type": "n8n-nodes-base.code",
      "parameters": {
        "code": "const docs = [];\nfor (const page of items[0].json.data) {\n  docs.push({\n    title: page.metadata.title,\n    content: page.markdown,\n    url: page.url\n  });\n}\nreturn [{json: {docs}}];"
      }
    },
    {
      "name": "Upload to Vector DB",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "POST",
        "url": "https://vector-db.example.com/upload"
      }
    }
  ]
}
```

## Best Practices

### 1. Use Filters
```
Firecrawl → Filter (only if changed) → Action
```

### 2. Handle Errors
```
Firecrawl → Error Trigger → Send Alert
```

### 3. Set Limits
```
Always set `limit` parameter to control costs
```

### 4. Cache Results
```
Use storage nodes to avoid redundant scrapes
```

## Related Documentation

- [Other Frameworks](./26-other-frameworks.md)
- [Scraping](./04-scraping.md)
- [Crawling](./05-crawling.md)
