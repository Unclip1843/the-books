# Firecrawl - Search

**Sources:**
- https://docs.firecrawl.dev/features/search
- https://api.firecrawl.dev/

**Fetched:** 2025-10-11

## Overview

Search performs web searches and returns full scraped content from results - not just links. Powered by multiple search engines for comprehensive coverage.

## How Search Works

```
Query → Search Engines → Get Results → Scrape Each Result → Return Content
```

**Features:**
- Web search with full content
- Multiple search types (web, news, images, GitHub, research)
- Location-based results
- Time-based filtering
- Returns scraped markdown, not just links

## Basic Search

### Python
```python
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

# Simple search
results = firecrawl.search(
    query="firecrawl API tutorial",
    limit=5
)

# Print results
for result in results['data']:
    print(f"Title: {result['metadata']['title']}")
    print(f"URL: {result['url']}")
    print(f"Content: {result['markdown'][:200]}...")
    print("---")
```

### Node.js
```javascript
import Firecrawl from '@mendable/firecrawl-js';

const firecrawl = new Firecrawl({ apiKey: 'fc-YOUR-API-KEY' });

const results = await firecrawl.search({
  query: 'firecrawl API tutorial',
  limit: 5
});

results.data.forEach(result => {
  console.log(`Title: ${result.metadata.title}`);
  console.log(`URL: ${result.url}`);
  console.log(`Content: ${result.markdown.substring(0, 200)}...`);
  console.log('---');
});
```

### cURL
```bash
curl -X POST https://api.firecrawl.dev/v1/search \
  -H "Authorization: Bearer fc-YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "firecrawl API tutorial",
    "limit": 5
  }'
```

## Search Types

### Web Search (Default)
```python
results = firecrawl.search(
    query="machine learning frameworks",
    searchType="web",
    limit=10
)
```

### News Search
```python
results = firecrawl.search(
    query="AI regulation",
    searchType="news",
    limit=10
)
```

### GitHub Search
```python
results = firecrawl.search(
    query="web scraping python",
    searchType="github",
    limit=10
)
```

### Research Papers
```python
results = firecrawl.search(
    query="transformer architecture",
    searchType="research",
    limit=10
)
```

### Image Search
```python
results = firecrawl.search(
    query="office interior design",
    searchType="images",
    limit=20
)
```

## Search Options

### Limit Results
```python
# Get top 5 results
results = firecrawl.search(
    query="python web scraping",
    limit=5
)

# Get top 20 results
results = firecrawl.search(
    query="machine learning",
    limit=20
)
```

### Location-Based
```python
# Search from specific country
results = firecrawl.search(
    query="best restaurants",
    location="US",
    limit=10
)

# Search from city
results = firecrawl.search(
    query="local events",
    location="San Francisco, CA",
    limit=10
)
```

### Time Range
```python
# Last 24 hours
results = firecrawl.search(
    query="tech news",
    timeRange="day",
    limit=10
)

# Last week
results = firecrawl.search(
    query="AI developments",
    timeRange="week",
    limit=10
)

# Last month
results = firecrawl.search(
    query="industry trends",
    timeRange="month",
    limit=10
)

# Last year
results = firecrawl.search(
    query="annual reports",
    timeRange="year",
    limit=10
)
```

### Scrape Options
```python
# Control how results are scraped
results = firecrawl.search(
    query="documentation",
    limit=5,
    scrapeOptions={
        "formats": ["markdown", "html"],
        "onlyMainContent": True,
        "excludeTags": ["nav", "footer"]
    }
)
```

## Response Format

```json
{
  "success": true,
  "data": [
    {
      "url": "https://example.com/article",
      "markdown": "# Article Title\n\nArticle content...",
      "html": "<html>...</html>",
      "metadata": {
        "title": "Article Title",
        "description": "Article description",
        "language": "en",
        "sourceURL": "https://example.com/article",
        "statusCode": 200
      },
      "links": ["https://...", "https://..."]
    }
  ]
}
```

## Pricing

- **Search:** 1 credit per result returned
- **Example:** Searching with limit=10 costs 10 credits

## Use Cases

### 1. Real-Time Research
```python
def research_topic(topic):
    # Search multiple sources
    web_results = firecrawl.search(query=topic, searchType="web", limit=5)
    news_results = firecrawl.search(query=topic, searchType="news", limit=5)
    research_results = firecrawl.search(query=topic, searchType="research", limit=5)
    
    all_results = {
        'web': web_results['data'],
        'news': news_results['data'],
        'research': research_results['data']
    }
    
    return all_results
```

### 2. Competitive Intelligence
```python
def monitor_competitor(company_name):
    results = firecrawl.search(
        query=f"{company_name} news",
        searchType="news",
        timeRange="week",
        limit=10
    )
    
    articles = []
    for result in results['data']:
        articles.append({
            'title': result['metadata']['title'],
            'url': result['url'],
            'date': result['metadata'].get('publishedDate'),
            'summary': result['markdown'][:300]
        })
    
    return articles
```

### 3. Content Aggregation
```python
def aggregate_content(keywords, num_sources=10):
    results = firecrawl.search(
        query=keywords,
        limit=num_sources
    )
    
    aggregated = []
    for result in results['data']:
        aggregated.append({
            'source': result['url'],
            'title': result['metadata']['title'],
            'content': result['markdown'],
            'links': result['links']
        })
    
    return aggregated
```

### 4. AI Assistant Context
```python
def get_current_context(user_query):
    # Search for recent information
    results = firecrawl.search(
        query=user_query,
        timeRange="week",
        limit=5
    )
    
    # Build context for LLM
    context = "Here's what I found:\n\n"
    for result in results['data']:
        context += f"**{result['metadata']['title']}**\n"
        context += f"Source: {result['url']}\n"
        context += f"{result['markdown'][:500]}...\n\n"
    
    return context

# Use with Claude
import anthropic
client = anthropic.Anthropic()

user_question = "What are the latest AI developments?"
context = get_current_context(user_question)

response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{
        "role": "user",
        "content": f"{context}\n\nBased on this information: {user_question}"
    }]
)
```

### 5. Market Research
```python
def market_analysis(industry, competitors):
    analysis = {}
    
    for company in competitors:
        # Search for company news
        news = firecrawl.search(
            query=f"{company} {industry}",
            searchType="news",
            timeRange="month",
            limit=5
        )
        
        analysis[company] = {
            'articles': len(news['data']),
            'headlines': [r['metadata']['title'] for r in news['data']],
            'mentions': sum(company.lower() in r['markdown'].lower() for r in news['data'])
        }
    
    return analysis
```

## Search vs Other Methods

| Method | Use Case | Cost | Speed |
|--------|----------|------|-------|
| Search | Find information across web | 1 credit/result | Fast |
| Scrape | Get specific URL | 1 credit | Very fast |
| Crawl | Get entire site | 1 credit/page | Slow |
| Map | Just URLs | 1 credit | Fast |

## Best Practices

### 1. Be Specific
```python
# Good - specific query
results = firecrawl.search("Python web scraping BeautifulSoup tutorial", limit=5)

# Less effective - vague query
results = firecrawl.search("programming", limit=5)
```

### 2. Limit Results
```python
# Start with fewer results
results = firecrawl.search(query="topic", limit=5)

# Increase if needed
if need_more:
    results = firecrawl.search(query="topic", limit=20)
```

### 3. Use Time Filters
```python
# For news and current events
results = firecrawl.search(
    query="tech news",
    timeRange="day",
    limit=10
)

# For historical data
results = firecrawl.search(
    query="historical analysis",
    timeRange="year",
    limit=10
)
```

### 4. Choose Right Search Type
```python
# For code examples
code_results = firecrawl.search(query="react hooks", searchType="github", limit=10)

# For current events
news_results = firecrawl.search(query="AI news", searchType="news", limit=10)

# For academic info
research_results = firecrawl.search(query="neural networks", searchType="research", limit=10)
```

### 5. Error Handling
```python
try:
    results = firecrawl.search(query="topic", limit=10)
except Exception as e:
    if '429' in str(e):
        print("Rate limited")
    elif '402' in str(e):
        print("Out of credits")
    else:
        print(f"Error: {e}")
```

## Limitations

- **Cost scales with results:** More results = more credits
- **Search quality:** Depends on search engine capabilities
- **Rate limits:** Apply per result scraped
- **Content availability:** Some sites may block scraping

## Related Documentation

- [Scraping](./04-scraping.md)
- [Extract](./08-extract.md)
- [API Reference](./14-map-search-endpoints.md)
- [AI Assistants](./28-ai-assistants.md)
- [Python SDK](./15-python-sdk.md)
