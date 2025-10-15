# Firecrawl - Other Framework Integrations

**Sources:**
- https://docs.firecrawl.dev/integrations
- https://www.firecrawl.dev/

**Fetched:** 2025-10-11

## CrewAI

### Installation
```bash
pip install crewai firecrawl-py
```

### Usage
```python
from crewai import Agent, Task, Crew
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

# Create research agent
researcher = Agent(
    role='Web Researcher',
    goal='Research topics using web scraping',
    backstory='Expert at finding and analyzing web content'
)

# Create task
research_task = Task(
    description='Research latest AI developments',
    agent=researcher,
    tools=[firecrawl]
)

# Run crew
crew = Crew(agents=[researcher], tasks=[research_task])
result = crew.kickoff()
```

## Dify

### Setup
1. Go to Dify workspace
2. Navigate to Tools → Add Tool
3. Select "Firecrawl"
4. Enter API key

### Usage in Workflow
- Use Firecrawl node to scrape/crawl
- Connect to LLM nodes for processing
- Build complete AI workflows

## Flowise

### Setup
1. Open Flowise
2. Add Firecrawl node
3. Configure with API key

### Example Flow
```
Firecrawl (Scrape) → Document Loader → Text Splitter → Vector Store → LLM
```

## Langflow

### Setup
1. Open Langflow
2. Drag Firecrawl component
3. Configure API key

### Example
Use Firecrawl as data source for RAG pipelines.

## Make (Integromat)

### Setup
1. Create new scenario
2. Add Firecrawl module
3. Connect API key

### Automation Examples
- Scrape → Process → Save to DB
- Monitor site → Send alerts
- Daily crawl → Generate reports

## Zapier

### Setup
1. Create Zap
2. Search for Firecrawl
3. Connect account

### Example Zaps
- New blog post → Scrape → Save to Notion
- Schedule → Crawl site → Email summary
- Webhook → Scrape → Update Airtable

## n8n

### Installation
```bash
npm install n8n-nodes-firecrawl
```

### Workflow Example
```
Trigger → Firecrawl → Process → Save
```

### Example Workflow
```json
{
  "nodes": [
    {
      "name": "Firecrawl",
      "type": "n8n-nodes-firecrawl.firecrawl",
      "parameters": {
        "operation": "scrape",
        "url": "https://example.com"
      }
    }
  ]
}
```

## Camel AI

### Usage
```python
from camel.agents import ChatAgent
from firecrawl import Firecrawl

firecrawl = Firecrawl(api_key="fc-YOUR-API-KEY")

agent = ChatAgent(
    tools=[firecrawl],
    system_message="You are a web research assistant"
)

response = agent.step("Research latest tech news")
```

## Related Documentation

- [LangChain](./24-langchain.md)
- [LlamaIndex](./25-llamaindex.md)
- [AI Assistants](./28-ai-assistants.md)
