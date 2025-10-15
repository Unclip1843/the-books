# OpenAI Platform - Knowledge Graphs

**Source:** https://platform.openai.com/docs/guides/tools-knowledge-graphs
**Fetched:** 2025-10-11

## Overview

Knowledge graphs enable agents to perform multi-hop reasoning over structured entity relationships. By combining OpenAI models with graph queries via tool calls, agents can traverse complex relationship networks to answer sophisticated questions that require reasoning across multiple connected facts.

**Key Capabilities:**
- Multi-hop graph traversal
- Temporal relationship tracking
- Entity resolution
- Complex query answering
- Graph construction from text
- Relationship inference

---

## Why Knowledge Graphs?

### Limitations of Vector Search

Traditional vector/semantic search:
- Single-hop retrieval
- No relationship awareness
- Limited complex reasoning
- Static snapshots

### Advantages of Knowledge Graphs

Knowledge graphs provide:
- Multi-step traversal
- Explicit relationships
- Temporal awareness
- Complex query support
- Structured reasoning

**Example:**
```
Vector Search:
Q: "Who are the co-founders of companies that Peter Thiel invested in?"
→ Retrieves documents mentioning Peter Thiel
→ Limited to single-hop information

Knowledge Graph:
Q: "Who are the co-founders of companies that Peter Thiel invested in?"
→ Find Peter Thiel (entity)
→ Traverse INVESTED_IN relationships
→ Get related companies
→ Traverse CO_FOUNDER relationships
→ Return co-founders
```

---

## Quick Start

### Basic Knowledge Graph Query

```python
from openai import OpenAI

client = OpenAI()

# Define graph query tool
tools = [
    {
        "type": "function",
        "function": {
            "name": "query_knowledge_graph",
            "description": "Query the knowledge graph for entity relationships",
            "parameters": {
                "type": "object",
                "properties": {
                    "entity": {
                        "type": "string",
                        "description": "The entity to start from"
                    },
                    "relationship": {
                        "type": "string",
                        "description": "The relationship type to traverse"
                    },
                    "depth": {
                        "type": "integer",
                        "description": "How many hops to traverse",
                        "default": 1
                    }
                },
                "required": ["entity"]
            }
        }
    }
]

# Query graph
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "What companies did Peter Thiel invest in?"
        }
    ],
    tools=tools
)

# Execute tool call
if response.tool_calls:
    tool_call = response.tool_calls[0]
    args = json.loads(tool_call.function.arguments)

    # Query your graph database
    results = query_graph(
        entity=args["entity"],
        relationship=args.get("relationship"),
        depth=args.get("depth", 1)
    )
```

---

## Graph Databases

### Neo4j Integration

```python
from neo4j import GraphDatabase

# Connect to Neo4j
driver = GraphDatabase.driver(
    "bolt://localhost:7687",
    auth=("neo4j", "password")
)

def query_graph(entity, relationship=None, depth=1):
    """Query Neo4j knowledge graph."""
    with driver.session() as session:
        if relationship:
            # Traverse specific relationship
            query = """
            MATCH (start {name: $entity})-[r:$relationship*1..$depth]->(end)
            RETURN end.name as result
            """
        else:
            # Get all related entities
            query = """
            MATCH (start {name: $entity})-[r*1..$depth]->(end)
            RETURN end.name as result, type(r) as relationship
            """

        result = session.run(
            query,
            entity=entity,
            relationship=relationship,
            depth=depth
        )

        return [{"entity": record["result"]} for record in result]

# Use with OpenAI
tools = [
    {
        "type": "function",
        "function": {
            "name": "query_knowledge_graph",
            "description": "Query Neo4j knowledge graph",
            "parameters": {...},
            "execute": query_graph
        }
    }
]
```

### Temporal Knowledge Graphs

Track relationships that change over time.

```python
# Temporal graph schema
"""
(:Person {name})-[:WORKED_AT {from_date, to_date}]->(:Company {name})
(:Person {name})-[:FOUNDED {date}]->(:Company {name})
(:Company {name})-[:ACQUIRED {date, price}]->(:Company {name})
"""

def query_temporal_graph(entity, relationship, as_of_date):
    """Query graph at specific point in time."""
    query = """
    MATCH (start {name: $entity})-[r:$relationship]->(end)
    WHERE r.from_date <= date($as_of_date)
      AND (r.to_date IS NULL OR r.to_date >= date($as_of_date))
    RETURN end.name as entity, r.from_date as from_date, r.to_date as to_date
    """

    with driver.session() as session:
        result = session.run(
            query,
            entity=entity,
            relationship=relationship,
            as_of_date=as_of_date
        )
        return [dict(record) for record in result]

# Example: Who was CEO of Apple in 2000?
results = query_temporal_graph(
    entity="Apple",
    relationship="CEO",
    as_of_date="2000-01-01"
)
```

---

## Building Knowledge Graphs

### Extract Entities from Text

```python
def extract_entities_and_relations(text):
    """Extract structured information using OpenAI."""
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": """
Extract entities and relationships from the text.
Return as JSON:
{
  "entities": [
    {"name": "entity name", "type": "Person|Company|Product|..."}
  ],
  "relationships": [
    {
      "from": "entity name",
      "to": "entity name",
      "type": "FOUNDED|INVESTED_IN|WORKED_AT|...",
      "date": "YYYY-MM-DD" (if mentioned)
    }
  ]
}
"""
            },
            {"role": "user", "content": text}
        ],
        response_format={"type": "json_object"}
    )

    return json.loads(response.choices[0].message.content)

# Example
text = """
Peter Thiel co-founded PayPal in 1998 with Max Levchin and Elon Musk.
In 2004, he made a $500,000 angel investment in Facebook.
He founded Palantir Technologies in 2003.
"""

graph_data = extract_entities_and_relations(text)

# Create graph
for entity in graph_data["entities"]:
    create_node(entity["name"], entity["type"])

for rel in graph_data["relationships"]:
    create_relationship(
        from_entity=rel["from"],
        to_entity=rel["to"],
        rel_type=rel["type"],
        properties={"date": rel.get("date")}
    )
```

### Structured Output for Graph Construction

```python
from pydantic import BaseModel
from typing import List, Optional

class Entity(BaseModel):
    name: str
    type: str
    properties: dict = {}

class Relationship(BaseModel):
    from_entity: str
    to_entity: str
    type: str
    from_date: Optional[str] = None
    to_date: Optional[str] = None
    properties: dict = {}

class KnowledgeGraph(BaseModel):
    entities: List[Entity]
    relationships: List[Relationship]

# Extract with schema
response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {
            "role": "system",
            "content": "Extract entities and relationships from text"
        },
        {"role": "user", "content": text}
    ],
    response_format={
        "type": "json_schema",
        "json_schema": {
            "name": "knowledge_graph",
            "strict": True,
            "schema": KnowledgeGraph.model_json_schema()
        }
    }
)

graph = KnowledgeGraph.model_validate_json(
    response.choices[0].message.content
)
```

---

## Multi-Hop Reasoning

### Two-Hop Query

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "query_graph",
            "description": "Query knowledge graph",
            "parameters": {
                "type": "object",
                "properties": {
                    "cypher_query": {
                        "type": "string",
                        "description": "Cypher query to execute"
                    }
                },
                "required": ["cypher_query"]
            }
        }
    }
]

# Ask complex question
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Who are the co-founders of companies that Peter Thiel invested in?"
        }
    ],
    tools=tools
)

# Model generates multi-hop query:
"""
MATCH (thiel:Person {name: 'Peter Thiel'})-[:INVESTED_IN]->(company:Company)
MATCH (cofounder:Person)-[:FOUNDED]->(company)
WHERE cofounder.name <> 'Peter Thiel'
RETURN DISTINCT cofounder.name
"""
```

### Complex Traversal

```python
# Question: "What products were developed by people who worked at companies
# that were funded by Y Combinator before 2010?"

# Model might generate:
query = """
MATCH (yc:Investor {name: 'Y Combinator'})-[funding:FUNDED]->(company:Company)
WHERE funding.date < date('2010-01-01')
MATCH (person:Person)-[worked:WORKED_AT]->(company)
MATCH (person)-[:DEVELOPED]->(product:Product)
RETURN DISTINCT product.name, person.name, company.name
"""

def execute_graph_query(cypher_query):
    """Execute Cypher query and return results."""
    with driver.session() as session:
        result = session.run(cypher_query)
        return [dict(record) for record in result]
```

---

## Agent + Graph Patterns

### Iterative Graph Exploration

```python
from openai_agents import Agent

# Create agent with graph tool
graph_agent = Agent(
    name="GraphExplorer",
    instructions="""
You are a knowledge graph expert. Use the graph query tool to explore
relationships and answer complex questions. You can make multiple queries
to traverse the graph as needed.
""",
    model="gpt-5",
    tools=[
        {
            "name": "query_graph",
            "description": "Execute Cypher query on Neo4j",
            "parameters": {...},
            "execute": execute_graph_query
        }
    ]
)

# Agent explores graph iteratively
runner = Runner()
response = runner.run(
    agent=graph_agent,
    messages=[
        {
            "role": "user",
            "content": """
Find the shortest path between Elon Musk and Steve Jobs.
What companies or people connect them?
"""
        }
    ]
)

# Agent might:
# 1. Query entities related to Elon Musk
# 2. Query entities related to Steve Jobs
# 3. Find intersection/paths
# 4. Query for connection details
```

### GraphRAG Pattern

Combine graph queries with retrieval-augmented generation.

```python
def graph_rag(question):
    """Retrieve graph context + generate answer."""

    # Step 1: Extract entities from question
    entities_response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": "Extract entity names from the question"
            },
            {"role": "user", "content": question}
        ],
        response_format={"type": "json_object"}
    )

    entities = json.loads(entities_response.choices[0].message.content)

    # Step 2: Query graph for relevant subgraph
    subgraph = []
    for entity in entities["entities"]:
        results = query_graph(
            entity=entity,
            depth=2  # Two-hop neighborhood
        )
        subgraph.extend(results)

    # Step 3: Generate answer with graph context
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": f"""
Answer the question using this knowledge graph context:

{json.dumps(subgraph, indent=2)}

Cite specific relationships in your answer.
"""
            },
            {"role": "user", "content": question}
        ]
    )

    return response.choices[0].message.content
```

---

## Use Cases

### Company Intelligence

```python
# Graph schema
"""
(:Person)-[:FOUNDED]->(:Company)
(:Person)-[:WORKS_AT {title, from_date, to_date}]->(:Company)
(:Company)-[:INVESTED_IN {amount, date}]->(:Company)
(:Company)-[:ACQUIRED {price, date}]->(:Company)
(:Company)-[:COMPETES_WITH]->(:Company)
"""

# Query: Competitive landscape
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": """
Analyze the competitive landscape around Stripe:
- Direct competitors
- Companies they've acquired
- Key executives who joined from competitors
- Investors who also invested in competitors
"""
        }
    ],
    tools=[graph_query_tool]
)
```

### Academic Research

```python
# Graph schema
"""
(:Researcher)-[:AUTHORED]->(:Paper)
(:Paper)-[:CITES]->(:Paper)
(:Researcher)-[:AFFILIATED_WITH]->(:Institution)
(:Paper)-[:ABOUT]->(:Topic)
"""

# Query: Research influence
query = """
Find the most influential papers on neural architecture search:
1. Papers with most citations
2. Authors of those papers
3. Other significant papers by those authors
4. Collabor networks
"""

response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": query}],
    tools=[graph_query_tool]
)
```

### Supply Chain

```python
# Graph schema
"""
(:Supplier)-[:SUPPLIES {lead_time}]->(:Component)
(:Component)-[:USED_IN]->(:Product)
(:Facility)-[:MANUFACTURES]->(:Product)
(:Facility)-[:LOCATED_IN]->(:Region)
"""

# Query: Risk analysis
query = """
If Supplier X has a disruption, what products are affected?
- Find all components they supply
- Find products using those components
- Identify alternate suppliers
- Calculate impact timeline
"""
```

---

## Best Practices

### 1. Design Clear Schema

```python
# ✅ Good schema
"""
Clear entity types:
(:Person {name, birth_date, nationality})
(:Company {name, founded_date, industry})
(:Product {name, launch_date, category})

Clear relationship types:
(:Person)-[:FOUNDED {role, date}]->(:Company)
(:Person)-[:INVESTED_IN {amount, date}]->(:Company)
(:Company)-[:ACQUIRED {price, date}]->(:Company)
"""

# ❌ Poor schema
"""
Vague types:
(:Entity {data})
(:Thing)-[:RELATED]->(:Thing)
"""
```

### 2. Use Indexes

```cypher
-- Create indexes for fast lookups
CREATE INDEX person_name FOR (p:Person) ON (p.name);
CREATE INDEX company_name FOR (c:Company) ON (c.name);
CREATE INDEX date_index FOR ()-[r:WORKED_AT]-() ON (r.from_date);
```

### 3. Limit Traversal Depth

```python
# ✅ Good: Limit depth
query = """
MATCH path = (start)-[*1..3]->(end)
WHERE start.name = 'Peter Thiel'
RETURN path
LIMIT 100
"""

# ❌ Poor: Unbounded traversal
query = """
MATCH path = (start)-[*]->(end)
WHERE start.name = 'Peter Thiel'
RETURN path
"""
```

### 4. Combine with Vector Search

```python
# Hybrid: Vector + Graph
def hybrid_search(question):
    # Vector search for relevant documents
    vector_results = vector_search(question)

    # Extract entities from results
    entities = extract_entities(vector_results)

    # Graph traversal for relationships
    graph_context = []
    for entity in entities:
        subgraph = query_graph(entity, depth=2)
        graph_context.append(subgraph)

    # Generate answer with both contexts
    answer = generate_with_context(
        question=question,
        vector_context=vector_results,
        graph_context=graph_context
    )

    return answer
```

---

## Tools and Libraries

### Python Libraries

```python
# Neo4j driver
from neo4j import GraphDatabase

# Knowledge graph construction
import spacy
from graphiti import Graphiti

# Temporal graphs
from temporal_graph import TemporalGraph

# OpenAI integration
from openai import OpenAI
```

### Example: Graphiti Integration

```python
from graphiti import Graphiti

# Initialize Graphiti
graphiti = Graphiti(
    neo4j_uri="bolt://localhost:7687",
    neo4j_user="neo4j",
    neo4j_password="password"
)

# Add documents (automatic entity extraction)
graphiti.add_documents([
    "Peter Thiel co-founded PayPal with Max Levchin.",
    "In 2004, Peter Thiel invested $500,000 in Facebook.",
    "Mark Zuckerberg founded Facebook in 2004."
])

# Query
results = graphiti.search(
    "What companies did Peter Thiel found or invest in?"
)

# Temporal queries
results = graphiti.temporal_search(
    "Who was CEO of Apple in 2000?",
    as_of_date="2000-01-01"
)
```

---

## Additional Resources

- **OpenAI Cookbook - Knowledge Graphs**: https://cookbook.openai.com/examples/partners/temporal_agents_with_knowledge_graphs
- **Neo4j GraphRAG**: https://neo4j.com/labs/genai-ecosystem/
- **Graphiti**: https://github.com/getzep/graphiti
- **RAG with Graph DB**: https://cookbook.openai.com/examples/rag_with_graph_db

---

**Next**: [Search →](./search.md)
