# Firecrawl - Node.js SDK

**Sources:**
- https://github.com/mendableai/firecrawl-js
- https://www.npmjs.com/package/@mendable/firecrawl-js
- https://docs.firecrawl.dev/

**Fetched:** 2025-10-11

## Installation

```bash
npm install @mendable/firecrawl-js
```

## Initialization

### Basic
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });
```

### From Environment Variable (Recommended)
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({
  apiKey: process.env.FIRECRAWL_API_KEY
});
```

### With Custom Options
```javascript
const firecrawl = new Firecrawl({
  apiKey: 'fc-YOUR-API-KEY',
  baseUrl: 'https://api.firecrawl.dev',  // Custom API endpoint
  timeout: 120000  // Request timeout in ms
});
```

## TypeScript Support

Full TypeScript support with type definitions:

```typescript
import Firecrawl, {
  ScrapeOptions,
  CrawlOptions,
  SearchOptions,
  ExtractOptions
} from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });
```

## Methods

### scrapeUrl()

Scrape a single URL.

```typescript
await firecrawl.scrapeUrl(
  url: string,
  options?: ScrapeOptions
): Promise<ScrapeResult>
```

**Parameters:**
- `url` (string): URL to scrape
- `options` (object):
  - `formats` (string[]): Output formats - `["markdown", "html", "screenshot"]`
  - `onlyMainContent` (boolean): Extract only main content
  - `includeTags` (string[]): HTML tags to include
  - `excludeTags` (string[]): HTML tags to exclude
  - `headers` (object): Custom HTTP headers
  - `waitFor` (number): Milliseconds to wait for JS
  - `timeout` (number): Request timeout in ms
  - `stealth` (boolean): Use stealth mode (+1 credit)
  - `location` (string): Scrape from location (e.g. "US")

**Returns:**
```typescript
{
  markdown: string;
  html?: string;
  metadata: {
    title: string;
    description: string;
    statusCode: number;
    language?: string;
  };
  links?: string[];
  screenshot?: string;
}
```

**Example:**
```javascript
const result = await firecrawl.scrapeUrl('https://example.com', {
  formats: ['markdown', 'html'],
  onlyMainContent: true,
  waitFor: 2000
});

console.log(result.markdown);
```

### crawlUrl()

Crawl entire website (sync).

```typescript
await firecrawl.crawlUrl(
  url: string,
  options?: CrawlOptions
): Promise<CrawlResult>
```

**Parameters:**
- `url` (string): Starting URL
- `options` (object):
  - `limit` (number): Max pages to crawl
  - `maxDepth` (number): Max crawl depth
  - `includePaths` (string[]): Paths to include (e.g. `["/blog/*"]`)
  - `excludePaths` (string[]): Paths to exclude
  - `allowSubdomains` (boolean): Include subdomains
  - `ignoreSitemap` (boolean): Skip sitemap.xml
  - `scrapeOptions` (object): Options for scraping each page

**Returns:**
```typescript
{
  data: Array<{
    url: string;
    markdown: string;
    metadata: object;
  }>;
}
```

**Example:**
```javascript
const result = await firecrawl.crawlUrl('https://example.com', {
  limit: 50,
  includePaths: ['/blog/*', '/docs/*'],
  scrapeOptions: {
    formats: ['markdown'],
    onlyMainContent: true
  }
});

result.data.forEach(page => {
  console.log(`URL: ${page.url}`);
  console.log(`Title: ${page.metadata.title}`);
});
```

### asyncCrawlUrl()

Start async crawl.

```typescript
await firecrawl.asyncCrawlUrl(
  url: string,
  options?: CrawlOptions
): Promise<{ id: string; url: string }>
```

**Returns:**
```typescript
{
  id: string;  // Job ID
  url: string;  // Starting URL
}
```

**Example:**
```javascript
const job = await firecrawl.asyncCrawlUrl('https://example.com', {
  limit: 500
});

console.log(`Crawl started: ${job.id}`);
```

### checkCrawlStatus()

Check crawl status.

```typescript
await firecrawl.checkCrawlStatus(jobId: string): Promise<CrawlStatus>
```

**Returns:**
```typescript
{
  status: 'scraping' | 'completed' | 'failed';
  total: number;
  completed: number;
  creditsUsed: number;
  data?: Array<{
    url: string;
    markdown: string;
    metadata: object;
  }>;
}
```

**Example:**
```javascript
const job = await firecrawl.asyncCrawlUrl('https://example.com', {
  limit: 100
});

// Poll for status
while (true) {
  const status = await firecrawl.checkCrawlStatus(job.id);
  
  console.log(`Status: ${status.status}`);
  console.log(`Progress: ${status.completed}/${status.total}`);
  
  if (status.status === 'completed') {
    status.data.forEach(page => {
      console.log(`Scraped: ${page.url}`);
    });
    break;
  } else if (status.status === 'failed') {
    console.error(`Error: ${status.error}`);
    break;
  }
  
  await new Promise(resolve => setTimeout(resolve, 10000));
}
```

### cancelCrawl()

Cancel running crawl.

```typescript
await firecrawl.cancelCrawl(jobId: string): Promise<{ status: string }>
```

**Example:**
```javascript
const job = await firecrawl.asyncCrawlUrl('https://example.com', {
  limit: 1000
});

await new Promise(resolve => setTimeout(resolve, 30000));
await firecrawl.cancelCrawl(job.id);
console.log('Crawl canceled');
```

### mapUrl()

Get all URLs from website.

```typescript
await firecrawl.mapUrl(
  url: string,
  options?: MapOptions
): Promise<{ links: string[] }>
```

**Parameters:**
- `url` (string): Website to map
- `options` (object):
  - `search` (string): Filter URLs containing this string
  - `ignoreSitemap` (boolean): Skip sitemap.xml
  - `includeSubdomains` (boolean): Include subdomains
  - `limit` (number): Max URLs to return

**Returns:**
```typescript
{
  links: string[];
}
```

**Example:**
```javascript
const result = await firecrawl.mapUrl('https://example.com', {
  search: 'blog'
});

console.log(`Found ${result.links.length} URLs`);
result.links.forEach(link => console.log(link));
```

### search()

Web search with scraping.

```typescript
await firecrawl.search(
  options: SearchOptions
): Promise<SearchResult>
```

**Parameters:**
- `options` (object):
  - `query` (string): Search query
  - `limit` (number): Max results
  - `searchType` (string): "web", "news", "images", "github", "research"
  - `location` (string): Geographic location
  - `timeRange` (string): "day", "week", "month", "year"
  - `scrapeOptions` (object): Options for scraping results

**Returns:**
```typescript
{
  data: Array<{
    url: string;
    markdown: string;
    metadata: object;
  }>;
}
```

**Example:**
```javascript
const result = await firecrawl.search({
  query: 'firecrawl tutorials',
  limit: 5,
  searchType: 'web'
});

result.data.forEach(item => {
  console.log(`Title: ${item.metadata.title}`);
  console.log(`URL: ${item.url}`);
  console.log(`Content: ${item.markdown.substring(0, 200)}...`);
});
```

### extract()

LLM-powered extraction.

```typescript
await firecrawl.extract(
  options: ExtractOptions
): Promise<ExtractResult>
```

**Parameters:**
- `options` (object):
  - `urls` (string[]): URLs to extract from
  - `schema` (object): JSON schema for output structure
  - `prompt` (string): Natural language extraction prompt
  - `searchQuery` (string): Search query (alternative to urls)
  - `searchType` (string): Search type
  - `limit` (number): Max results when using search

**Returns:**
```typescript
{
  data: any;  // Structured data matching schema
}
```

**Example - Schema:**
```javascript
const schema = {
  type: 'object',
  properties: {
    company_name: { type: 'string' },
    founded: { type: 'number' },
    ceo: { type: 'string' }
  }
};

const result = await firecrawl.extract({
  urls: ['https://example.com/about'],
  schema: schema
});

console.log(result.data);
```

**Example - Prompt:**
```javascript
const result = await firecrawl.extract({
  urls: ['https://example.com'],
  prompt: 'Extract the company name, CEO, and founding year'
});

console.log(result.data);
```

**Example - Multi-URL:**
```javascript
const urls = [
  'https://example.com/team/person1',
  'https://example.com/team/person2'
];

const schema = {
  type: 'object',
  properties: {
    name: { type: 'string' },
    role: { type: 'string' },
    email: { type: 'string' }
  }
};

const result = await firecrawl.extract({ urls, schema });

result.data.forEach(person => {
  console.log(`${person.name} - ${person.role}`);
});
```

## Error Handling

```typescript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });

try {
  const result = await firecrawl.scrapeUrl('https://example.com');
  console.log(result.markdown);
} catch (error) {
  if (error.response) {
    switch (error.response.status) {
      case 401:
        console.error('Invalid API key');
        break;
      case 402:
        console.error('Out of credits');
        break;
      case 429:
        console.error('Rate limited - slow down');
        break;
      default:
        console.error(`Error: ${error.message}`);
    }
  } else {
    console.error(`Error: ${error.message}`);
  }
}
```

## Complete Examples

### 1. Scrape with All Options
```javascript
const result = await firecrawl.scrapeUrl('https://example.com/article', {
  formats: ['markdown', 'html', 'screenshot'],
  onlyMainContent: true,
  excludeTags: ['nav', 'footer', 'aside'],
  waitFor: 3000,
  stealth: true,
  headers: {
    'User-Agent': 'CustomBot/1.0'
  }
});

// Access different formats
const markdown = result.markdown;
const html = result.html;
const screenshot = result.screenshot;  // Base64 encoded
const metadata = result.metadata;
```

### 2. Monitored Async Crawl
```javascript
async function monitoredCrawl(url, limit) {
  const job = await firecrawl.asyncCrawlUrl(url, { limit });
  console.log(`Started crawl: ${job.id}`);
  
  while (true) {
    const status = await firecrawl.checkCrawlStatus(job.id);
    
    if (status.status === 'completed') {
      console.log(`✓ Completed! Scraped ${status.data.length} pages`);
      return status.data;
    } else if (status.status === 'failed') {
      console.error(`✗ Failed: ${status.error}`);
      return null;
    }
    
    const progress = (status.completed / status.total) * 100;
    console.log(`Progress: ${progress.toFixed(1)}% (${status.completed}/${status.total})`);
    
    await new Promise(resolve => setTimeout(resolve, 10000));
  }
}

const pages = await monitoredCrawl('https://example.com', 100);
```

### 3. Search and Extract
```javascript
// Search for companies
const searchResults = await firecrawl.search({
  query: 'Y Combinator companies 2024',
  limit: 10
});

// Extract structured data
const schema = {
  type: 'object',
  properties: {
    name: { type: 'string' },
    description: { type: 'string' },
    year: { type: 'number' }
  }
};

const urls = searchResults.data.map(item => item.url);
const companies = await firecrawl.extract({ urls, schema });

companies.data.forEach(company => {
  console.log(`${company.name} (${company.year})`);
});
```

### 4. Complete Site Backup
```javascript
import fs from 'fs/promises';
import path from 'path';

async function backupWebsite(url, outputDir = 'backup') {
  await fs.mkdir(outputDir, { recursive: true });
  
  // Crawl entire site
  console.log(`Crawling ${url}...`);
  const result = await firecrawl.crawlUrl(url, {
    limit: 1000,
    scrapeOptions: {
      formats: ['markdown', 'html']
    }
  });
  
  // Save each page
  for (const [i, page] of result.data.entries()) {
    const filename = page.url.replace('https://', '').replace(/\//g, '_');
    
    // Save markdown
    await fs.writeFile(
      path.join(outputDir, `${filename}.md`),
      page.markdown
    );
    
    // Save metadata
    await fs.writeFile(
      path.join(outputDir, `${filename}.json`),
      JSON.stringify(page.metadata, null, 2)
    );
  }
  
  console.log(`Backed up ${result.data.length} pages to ${outputDir}/`);
}

await backupWebsite('https://example.com');
```

### 5. Batch Scraping with Rate Limiting
```javascript
async function batchScrape(urls, delay = 1000) {
  const results = [];
  
  for (const [i, url] of urls.entries()) {
    try {
      console.log(`Scraping ${i+1}/${urls.length}: ${url}`);
      const result = await firecrawl.scrapeUrl(url);
      results.push(result);
      
      // Rate limiting
      if (i < urls.length - 1) {
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    } catch (error) {
      console.error(`Error scraping ${url}: ${error.message}`);
      continue;
    }
  }
  
  return results;
}

const urls = [
  'https://example.com/page1',
  'https://example.com/page2',
  'https://example.com/page3'
];

const results = await batchScrape(urls, 2000);
```

### 6. TypeScript Example
```typescript
import Firecrawl, { ScrapeResult, CrawlResult } from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: process.env.FIRECRAWL_API_KEY! });

async function scrapeAndProcess(url: string): Promise<void> {
  try {
    const result: ScrapeResult = await firecrawl.scrapeUrl(url, {
      formats: ['markdown'],
      onlyMainContent: true
    });
    
    console.log(`Title: ${result.metadata.title}`);
    console.log(`Content length: ${result.markdown.length} chars`);
    
  } catch (error) {
    console.error(`Error: ${error instanceof Error ? error.message : error}`);
  }
}

await scrapeAndProcess('https://example.com');
```

### 7. Express.js API Integration
```javascript
import express from 'express';
import Firecrawl from '@mendable/firecrawl-js';

const app = express();
const firecrawl = new Firecrawl({ apiKey: process.env.FIRECRAWL_API_KEY });

app.use(express.json());

// Scrape endpoint
app.post('/api/scrape', async (req, res) => {
  try {
    const { url } = req.body;
    const result = await firecrawl.scrapeUrl(url);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start async crawl
app.post('/api/crawl', async (req, res) => {
  try {
    const { url, limit } = req.body;
    const job = await firecrawl.asyncCrawlUrl(url, { limit });
    res.json(job);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Check crawl status
app.get('/api/crawl/:id', async (req, res) => {
  try {
    const status = await firecrawl.checkCrawlStatus(req.params.id);
    res.json(status);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => console.log('Server running on port 3000'));
```

## Best Practices

### 1. Use Environment Variables
```javascript
// Good
const firecrawl = new Firecrawl({
  apiKey: process.env.FIRECRAWL_API_KEY
});

// Bad - hardcoded
const firecrawl = new Firecrawl({
  apiKey: 'fc-abc123...'
});
```

### 2. Handle Errors
```javascript
try {
  const result = await firecrawl.scrapeUrl(url);
} catch (error) {
  console.error(`Error: ${error.message}`);
  // Implement retry logic
}
```

### 3. Set Limits
```javascript
// Always limit crawls
const result = await firecrawl.crawlUrl(url, { limit: 100 });

// Not: await firecrawl.crawlUrl(url);  // Could scrape thousands
```

### 4. Use Async for Large Operations
```javascript
// For > 50 pages
if (expectedPages > 50) {
  const job = await firecrawl.asyncCrawlUrl(url, { limit: expectedPages });
  // Poll for status
} else {
  const result = await firecrawl.crawlUrl(url, { limit: expectedPages });
}
```

### 5. Monitor Progress
```javascript
const job = await firecrawl.asyncCrawlUrl(url, { limit: 500 });

while (true) {
  const status = await firecrawl.checkCrawlStatus(job.id);
  console.log(`Progress: ${status.completed}/${status.total}`);
  
  if (['completed', 'failed'].includes(status.status)) {
    break;
  }
  
  await new Promise(resolve => setTimeout(resolve, 10000));
}
```

## Related Documentation

- [Quickstart](./02-quickstart.md)
- [Scraping](./04-scraping.md)
- [Crawling](./05-crawling.md)
- [API Reference](./10-api-overview.md)
- [Error Handling](./18-error-handling.md)
