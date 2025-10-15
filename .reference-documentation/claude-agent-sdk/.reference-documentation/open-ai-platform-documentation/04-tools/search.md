# OpenAI Platform - Search Tools

**Source:** https://platform.openai.com/docs/guides/tools-web-search
**Fetched:** 2025-10-11

## Overview

Search tools enable agents to retrieve real-time information from the web and perform local searches across internal data. OpenAI provides built-in web search capabilities and patterns for implementing custom search solutions.

**Search Types:**
- **Web Search**: Real-time internet search with citations
- **Local Search**: Custom search over internal data
- **Hybrid Search**: Combined vector and keyword search
- **Enterprise Search**: Integrated business systems search

---

## Web Search

### Built-in Web Search Tool

OpenAI's web search tool provides real-time web access with grounding and citations.

```python
from openai import OpenAI

client = OpenAI()

# Enable web search
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "What are the latest developments in quantum computing?"
        }
    ],
    tools=[{"type": "web_search_preview"}]
)

print(response.choices[0].message.content)
```

**Features:**
- Real-time web access
- Automatic grounding with citations
- News and current events
- Fact verification
- Research assistance

**Model**: Uses `gpt-4o-search-preview` model

### Manual Search Control

```python
# Automatic: Model decides when to search
response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "What's the weather today?"}],
    tools=[{"type": "web_search_preview"}]
)

# Manual: Force search
response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Latest AI news"}],
    tools=[{"type": "web_search_preview"}],
    tool_choice={
        "type": "tool",
        "name": "web_search_preview"
    }
)
```

### Citations and Sources

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Who won the latest Nobel Prize in Physics?"
        }
    ],
    tools=[{"type": "web_search_preview"}]
)

# Access citations
message = response.choices[0].message

if message.annotations:
    print("Sources:")
    for annotation in message.annotations:
        if hasattr(annotation, 'url'):
            print(f"- {annotation.url}")
            print(f"  {annotation.title}")
```

---

## Custom Web Search

### Brave Search Integration

```python
import requests

def brave_search(query, count=10):
    """Search web using Brave Search API."""
    url = "https://api.search.brave.com/res/v1/web/search"

    headers = {
        "Accept": "application/json",
        "X-Subscription-Token": os.environ["BRAVE_API_KEY"]
    }

    params = {
        "q": query,
        "count": count
    }

    response = requests.get(url, headers=headers, params=params)
    results = response.json()

    return {
        "results": [
            {
                "title": r["title"],
                "url": r["url"],
                "description": r["description"]
            }
            for r in results.get("web", {}).get("results", [])
        ]
    }

# Define as tool
tools = [
    {
        "type": "function",
        "function": {
            "name": "web_search",
            "description": "Search the web for current information",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Search query"
                    },
                    "count": {
                        "type": "integer",
                        "description": "Number of results",
                        "default": 10
                    }
                },
                "required": ["query"]
            }
        }
    }
]

# Use in agent
response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Latest AI developments"}],
    tools=tools
)

# Execute search
if response.tool_calls:
    tool_call = response.tool_calls[0]
    args = json.loads(tool_call.function.arguments)
    search_results = brave_search(args["query"], args.get("count", 10))
```

### Google Custom Search

```python
from googleapiclient.discovery import build

def google_search(query, num=10):
    """Search web using Google Custom Search API."""
    service = build(
        "customsearch",
        "v1",
        developerKey=os.environ["GOOGLE_API_KEY"]
    )

    result = service.cse().list(
        q=query,
        cx=os.environ["GOOGLE_CSE_ID"],
        num=num
    ).execute()

    return {
        "results": [
            {
                "title": item["title"],
                "url": item["link"],
                "snippet": item["snippet"]
            }
            for item in result.get("items", [])
        ]
    }
```

---

## Local Search

### Vector Search

Search internal documents using embeddings.

```python
from openai import OpenAI
import numpy as np

client = OpenAI()

class LocalSearch:
    def __init__(self):
        self.documents = []
        self.embeddings = []

    def add_documents(self, docs):
        """Add documents to search index."""
        self.documents.extend(docs)

        # Get embeddings
        response = client.embeddings.create(
            model="text-embedding-3-large",
            input=docs
        )

        embeddings = [item.embedding for item in response.data]
        self.embeddings.extend(embeddings)

    def search(self, query, top_k=5):
        """Search documents."""
        # Get query embedding
        response = client.embeddings.create(
            model="text-embedding-3-large",
            input=[query]
        )
        query_embedding = response.data[0].embedding

        # Calculate similarities
        similarities = [
            np.dot(query_embedding, doc_emb)
            for doc_emb in self.embeddings
        ]

        # Get top results
        top_indices = np.argsort(similarities)[-top_k:][::-1]

        return [
            {
                "document": self.documents[i],
                "score": similarities[i]
            }
            for i in top_indices
        ]

# Use local search
local_search = LocalSearch()
local_search.add_documents([
    "Product manual for Widget Pro v2.0",
    "Troubleshooting guide for common issues",
    "Safety specifications and guidelines"
])

# Define as tool
def search_local(query):
    return local_search.search(query, top_k=3)

tools = [
    {
        "type": "function",
        "function": {
            "name": "search_local",
            "description": "Search internal documentation",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Search query"
                    }
                },
                "required": ["query"]
            }
        }
    }
]
```

### Database Search

```python
import sqlite3

def search_database(query, table, limit=10):
    """Full-text search in database."""
    conn = sqlite3.connect("app.db")
    cursor = conn.cursor()

    # Full-text search
    cursor.execute(f"""
        SELECT * FROM {table}
        WHERE {table} MATCH ?
        ORDER BY rank
        LIMIT ?
    """, (query, limit))

    results = cursor.fetchall()
    conn.close()

    return results

# Define as tool
tools = [
    {
        "type": "function",
        "function": {
            "name": "search_database",
            "description": "Search database records",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Search query"
                    },
                    "table": {
                        "type": "string",
                        "description": "Table to search",
                        "enum": ["products", "customers", "orders"]
                    }
                },
                "required": ["query", "table"]
            }
        }
    }
]
```

---

## Hybrid Search

Combine multiple search methods for better results.

```python
def hybrid_search(query):
    """Combine vector search, keyword search, and web search."""

    # 1. Vector search (semantic)
    vector_results = local_search.search(query, top_k=3)

    # 2. Keyword search (exact matches)
    keyword_results = search_database(query, "documents", limit=3)

    # 3. Web search (current info)
    web_results = brave_search(query, count=3)

    # Combine results
    all_results = {
        "local_documents": vector_results,
        "database_records": keyword_results,
        "web_sources": web_results["results"]
    }

    return all_results

# Use in agent
tools = [
    {
        "type": "function",
        "function": {
            "name": "hybrid_search",
            "description": "Search across multiple sources",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {"type": "string"}
                },
                "required": ["query"]
            }
        }
    }
]

response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "What are our product specifications for Widget Pro?"
        }
    ],
    tools=tools
)
```

---

## Enterprise Search

### Elasticsearch Integration

```python
from elasticsearch import Elasticsearch

es = Elasticsearch(["http://localhost:9200"])

def enterprise_search(query, index="documents", size=10):
    """Search Elasticsearch index."""
    body = {
        "query": {
            "multi_match": {
                "query": query,
                "fields": ["title^2", "content", "tags"],
                "type": "best_fields"
            }
        },
        "highlight": {
            "fields": {
                "content": {}
            }
        },
        "size": size
    }

    results = es.search(index=index, body=body)

    return [
        {
            "id": hit["_id"],
            "title": hit["_source"]["title"],
            "content": hit["_source"]["content"],
            "score": hit["_score"],
            "highlights": hit.get("highlight", {}).get("content", [])
        }
        for hit in results["hits"]["hits"]
    ]
```

### Microsoft Graph Search

```python
from msgraph import GraphServiceClient
from azure.identity import ClientSecretCredential

def microsoft_search(query):
    """Search Microsoft 365 content."""
    credential = ClientSecretCredential(
        tenant_id=os.environ["TENANT_ID"],
        client_id=os.environ["CLIENT_ID"],
        client_secret=os.environ["CLIENT_SECRET"]
    )

    client = GraphServiceClient(credential)

    request_body = {
        "requests": [
            {
                "entityTypes": ["driveItem", "list", "listItem", "site"],
                "query": {
                    "queryString": query
                },
                "from": 0,
                "size": 10
            }
        ]
    }

    results = client.search.query.post(request_body)

    return results

# Use in agent
tools = [
    {
        "type": "function",
        "function": {
            "name": "search_microsoft_365",
            "description": "Search Microsoft 365 documents and emails",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {"type": "string"}
                },
                "required": ["query"]
            }
        }
    }
]
```

---

## Search Optimization

### Query Rewriting

Improve search queries before execution.

```python
def rewrite_query(original_query):
    """Optimize query for better search results."""
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": """
Rewrite the user's query to be more effective for search:
- Add relevant keywords
- Expand abbreviations
- Add synonyms
- Make more specific

Return only the rewritten query.
"""
            },
            {"role": "user", "content": original_query}
        ]
    )

    return response.choices[0].message.content

# Use in search workflow
def smart_search(user_query):
    # Rewrite query
    optimized_query = rewrite_query(user_query)

    # Search with optimized query
    results = brave_search(optimized_query)

    return results
```

### Result Reranking

```python
def rerank_results(query, results):
    """Rerank search results by relevance."""
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": f"""
Rank these search results by relevance to the query: "{query}"

Return a JSON array of indices in order of relevance (most relevant first).
"""
            },
            {
                "role": "user",
                "content": json.dumps([
                    {"index": i, "title": r["title"], "snippet": r.get("description", "")}
                    for i, r in enumerate(results)
                ])
            }
        ],
        response_format={"type": "json_object"}
    )

    ranking = json.loads(response.choices[0].message.content)
    reranked = [results[i] for i in ranking["indices"]]

    return reranked
```

---

## Use Cases

### Research Assistant

```python
async def research_question(question):
    """Research a question using multiple sources."""

    # Step 1: Web search
    web_results = brave_search(question, count=5)

    # Step 2: Local knowledge search
    local_results = local_search.search(question, top_k=3)

    # Step 3: Synthesize answer
    context = {
        "web_sources": web_results["results"],
        "internal_docs": local_results
    }

    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": f"""
Answer the question using these sources:

Web sources:
{json.dumps(context['web_sources'], indent=2)}

Internal documentation:
{json.dumps(context['internal_docs'], indent=2)}

Cite your sources inline using [1], [2], etc.
"""
            },
            {"role": "user", "content": question}
        ]
    )

    return response.choices[0].message.content
```

### Customer Support

```python
def support_search(user_question):
    """Search multiple sources for support information."""

    # Search in priority order
    results = {}

    # 1. Internal KB (highest priority)
    kb_results = search_local(user_question)
    if kb_results:
        results["knowledge_base"] = kb_results

    # 2. Previous tickets
    ticket_results = search_database(user_question, "tickets")
    if ticket_results:
        results["previous_tickets"] = ticket_results

    # 3. Web (if no internal results)
    if not results:
        web_results = brave_search(f"{user_question} support")
        results["web_results"] = web_results

    return results
```

---

## Best Practices

### 1. Prioritize Search Sources

```python
# ✅ Good: Search in order of reliability
def smart_search(query):
    # First: Internal verified docs
    results = search_local(query)
    if results:
        return results

    # Second: Enterprise search
    results = enterprise_search(query)
    if results:
        return results

    # Last: Web search
    return brave_search(query)
```

### 2. Cache Search Results

```python
from functools import lru_cache
import time

@lru_cache(maxsize=100)
def cached_web_search(query, ttl=3600):
    """Cache web search results."""
    cache_key = f"search:{query}:{int(time.time() / ttl)}"

    # Check cache
    cached = redis.get(cache_key)
    if cached:
        return json.loads(cached)

    # Perform search
    results = brave_search(query)

    # Cache results
    redis.setex(cache_key, ttl, json.dumps(results))

    return results
```

### 3. Add Safety Filters

```python
def safe_search(query):
    """Search with content filtering."""
    results = brave_search(query)

    # Filter inappropriate content
    filtered_results = []
    for result in results["results"]:
        # Check safe_search indicators
        if result.get("is_safe", True):
            filtered_results.append(result)

    return {"results": filtered_results}
```

### 4. Handle Rate Limits

```python
import time
from functools import wraps

def rate_limit(max_calls, period):
    """Rate limit decorator."""
    calls = []

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            now = time.time()

            # Remove old calls
            while calls and calls[0] < now - period:
                calls.pop(0)

            # Check limit
            if len(calls) >= max_calls:
                sleep_time = period - (now - calls[0])
                time.sleep(sleep_time)

            # Make call
            calls.append(now)
            return func(*args, **kwargs)

        return wrapper
    return decorator

@rate_limit(max_calls=10, period=60)  # 10 calls per minute
def rate_limited_search(query):
    return brave_search(query)
```

---

## Additional Resources

- **Web Search Docs**: https://platform.openai.com/docs/guides/tools-web-search
- **Brave Search API**: https://brave.com/search/api/
- **Google Custom Search**: https://developers.google.com/custom-search
- **Elasticsearch**: https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html

---

**Next**: [MCP →](./mcp.md)
