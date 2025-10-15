# OpenAI Platform - Deep Research

**Source:** https://platform.openai.com/docs/guides/deep-research
**Fetched:** 2025-10-11

## Overview

Conduct comprehensive research using Deep Research API.

---

## Start Research

```python
research = client.research.create(
    topic="Impact of AI on healthcare",
    depth="comprehensive",  # or "standard"
    sources=["academic", "news", "reports"]
)

# Research runs asynchronously
research_id = research.id
```

---

## Check Status

```python
status = client.research.retrieve(research_id)
print(status.status)  # processing, completed, failed
```

---

## Get Results

```python
if status.status == "completed":
    results = status.results
    print(results.summary)
    print(results.sources)
```

---

**Source:** https://platform.openai.com/docs/guides/deep-research
