# OpenAI Platform - Agents SDK

**Source:** https://platform.openai.com/docs/guides/agents-sdk
**Fetched:** 2025-10-11

## Overview

The Agents SDK is a production-ready framework for building multi-agent workflows. Available in Python and TypeScript, it replaces the experimental Swarm framework with a robust, scalable solution.

**GitHub**:
- Python: https://github.com/openai/openai-agents-python
- TypeScript: https://github.com/openai/openai-agents-js

**Documentation**:
- Python: https://openai.github.io/openai-agents-python/
- TypeScript: https://openai.github.io/openai-agents-js/

---

## Installation

### Python

```bash
pip install openai-agents
```

### TypeScript

```bash
npm install openai-agents
# or
yarn add openai-agents
# or
pnpm add openai-agents
```

---

## Quick Start

### Python

```python
from openai_agents import Agent, Runner

# Create agent
agent = Agent(
    name="Assistant",
    instructions="You are a helpful assistant",
    model="gpt-5"
)

# Run agent
runner = Runner()
response = runner.run(agent, "Hello!")

print(response.messages[-1].content)
```

### TypeScript

```typescript
import { Agent, Runner } from 'openai-agents';

// Create agent
const agent = new Agent({
  name: 'Assistant',
  instructions: 'You are a helpful assistant',
  model: 'gpt-5',
});

// Run agent
const runner = new Runner();
const response = await runner.run(agent, 'Hello!');

console.log(response.messages[response.messages.length - 1].content);
```

---

## Core Concepts

### Agents

LLMs configured with instructions, tools, and guardrails.

```python
agent = Agent(
    name="Customer Support",
    instructions="Help customers with inquiries",
    model="gpt-5",
    tools=[search_tool, email_tool],
    guardrails=[input_validation, output_filter]
)
```

### Handoffs

Specialized tool calls for transferring control between agents.

```python
sales_agent = Agent(
    name="Sales",
    instructions="Handle sales inquiries",
    handoffs=[support_agent]  # Can hand off to support
)

support_agent = Agent(
    name="Support",
    instructions="Handle support tickets",
    handoffs=[sales_agent]  # Can hand off to sales
)
```

### Sessions

Automatic conversation history management across agent runs.

```python
# Session automatically tracks conversation
session = Session()
response1 = runner.run(agent, "What's Python?", session=session)
response2 = runner.run(agent, "Give me an example", session=session)
# Context from response1 is preserved
```

### Tools

Functions that agents can call.

```python
from openai_agents import tool

@tool
def search_database(query: str) -> str:
    """Search the company database."""
    return database.search(query)

agent = Agent(
    name="Agent",
    tools=[search_database]
)
```

### Guardrails

Safety checks for input and output validation.

```python
from openai_agents import Guardrail

input_guardrail = Guardrail(
    name="input_validation",
    check=lambda msg: len(msg) < 1000,
    error_message="Message too long"
)

agent = Agent(
    name="Agent",
    guardrails=[input_guardrail]
)
```

---

## Agent Configuration

### Basic Agent

```python
agent = Agent(
    name="Assistant",
    instructions="You are helpful",
    model="gpt-5"
)
```

### With Tools

```python
@tool
def get_weather(location: str) -> dict:
    """Get current weather."""
    return {"temp": 72, "conditions": "sunny"}

agent = Agent(
    name="Weather Bot",
    instructions="Help with weather queries",
    tools=[get_weather]
)
```

### With Handoffs

```python
specialist_agent = Agent(
    name="Specialist",
    instructions="Handle complex issues"
)

general_agent = Agent(
    name="General",
    instructions="Handle general queries",
    handoffs=[specialist_agent]
)
```

### With Guardrails

```python
agent = Agent(
    name="Safe Agent",
    instructions="Respond safely",
    guardrails=[
        input_validation,
        output_moderation,
        pii_filter
    ]
)
```

---

## Tools

### Function Tools

Automatic schema generation from Python/TypeScript functions.

**Python (Pydantic)**:
```python
from pydantic import BaseModel
from openai_agents import tool

class WeatherQuery(BaseModel):
    location: str
    unit: str = "fahrenheit"

@tool
def get_weather(query: WeatherQuery) -> dict:
    """Get weather for a location."""
    return {
        "location": query.location,
        "temperature": 72,
        "unit": query.unit
    }
```

**TypeScript (Zod)**:
```typescript
import { z } from 'zod';
import { tool } from 'openai-agents';

const WeatherQuery = z.object({
  location: z.string(),
  unit: z.enum(['celsius', 'fahrenheit']).default('fahrenheit'),
});

const getWeather = tool({
  name: 'get_weather',
  description: 'Get weather for a location',
  parameters: WeatherQuery,
  execute: async (query) => {
    return {
      location: query.location,
      temperature: 72,
      unit: query.unit,
    };
  },
});
```

### Async Tools

```python
import asyncio

@tool
async def async_search(query: str) -> str:
    """Async web search."""
    await asyncio.sleep(1)  # Simulate API call
    return f"Results for: {query}"

agent = Agent(
    name="Async Agent",
    tools=[async_search]
)
```

### Tool Results

Handle tool execution results:

```python
@tool
def risky_operation(data: str) -> str:
    """Operation that might fail."""
    try:
        result = perform_operation(data)
        return result
    except Exception as e:
        return f"Error: {str(e)}"
```

---

## Sessions

### Session Management

```python
from openai_agents import Session

# Create session
session = Session()

# Use across multiple runs
response1 = runner.run(agent, "Hello", session=session)
response2 = runner.run(agent, "How are you?", session=session)

# Session automatically maintains context
```

### Session Storage

```python
# Custom session storage
class DatabaseSession(Session):
    def __init__(self, user_id):
        super().__init__()
        self.user_id = user_id

    def save(self):
        """Save session to database."""
        db.sessions.update(
            {"user_id": self.user_id},
            {"messages": self.messages}
        )

    def load(self):
        """Load session from database."""
        data = db.sessions.find_one({"user_id": self.user_id})
        if data:
            self.messages = data["messages"]
```

---

## Handoffs

### Agent-to-Agent Handoffs

```python
# Define agents
triage_agent = Agent(
    name="Triage",
    instructions="Route to appropriate agent"
)

sales_agent = Agent(
    name="Sales",
    instructions="Handle sales",
    handoffs=[triage_agent]
)

support_agent = Agent(
    name="Support",
    instructions="Handle support",
    handoffs=[triage_agent]
)

# Configure triage handoffs
triage_agent.handoffs = [sales_agent, support_agent]

# Agent automatically decides when to hand off
response = runner.run(triage_agent, "I want to buy a product")
# Triage hands off to sales_agent
```

### Conditional Handoffs

```python
def should_escalate(context):
    """Determine if escalation needed."""
    return context.get("issue_severity") == "high"

agent = Agent(
    name="Agent",
    instructions="Help users",
    handoffs=[
        Handoff(
            target=specialist_agent,
            condition=should_escalate
        )
    ]
)
```

---

## Tracing

### Built-in Tracing

Trace agent runs for debugging:

```python
from openai_agents import Runner, trace

# Enable tracing
runner = Runner(trace=True)

# Run with tracing
@trace
def run_agent(query):
    response = runner.run(agent, query)
    return response

# View traces
traces = runner.get_traces()
for trace in traces:
    print(f"Agent: {trace.agent_name}")
    print(f"Duration: {trace.duration}ms")
    print(f"Tools used: {trace.tools_used}")
```

### Custom Tracing

```python
class CustomTracer:
    def on_agent_start(self, agent, input):
        print(f"Starting {agent.name}")

    def on_agent_end(self, agent, output):
        print(f"Finished {agent.name}")

    def on_tool_call(self, tool, args):
        print(f"Calling {tool.name} with {args}")

runner = Runner(tracer=CustomTracer())
```

---

## Error Handling

### Graceful Failures

```python
try:
    response = runner.run(agent, user_input)
except AgentError as e:
    print(f"Agent error: {e}")
except ToolError as e:
    print(f"Tool error: {e}")
except Exception as e:
    print(f"Unexpected error: {e}")
```

### Retry Logic

```python
from openai_agents import retry

@tool
@retry(max_attempts=3, backoff=2.0)
def flaky_api_call(query: str) -> str:
    """API call that might fail."""
    return make_api_request(query)
```

---

## Multi-Agent Patterns

### Sequential Agents

```python
# Research → Analyze → Summarize
research_agent = Agent(name="Researcher", instructions="Research topic")
analysis_agent = Agent(name="Analyst", instructions="Analyze findings")
summary_agent = Agent(name="Summarizer", instructions="Create summary")

# Orchestrate
research = runner.run(research_agent, "Topic: AI safety")
analysis = runner.run(analysis_agent, research.messages[-1].content)
summary = runner.run(summary_agent, analysis.messages[-1].content)
```

### Hierarchical Agents

```python
# Manager coordinates workers
manager = Agent(
    name="Manager",
    instructions="Coordinate tasks among workers",
    handoffs=[worker1, worker2, worker3]
)

response = runner.run(manager, "Complete project X")
# Manager delegates to workers as needed
```

### Collaborative Agents

```python
# Agents discuss and reach consensus
agent_a = Agent(name="Agent A", handoffs=[agent_b, agent_c])
agent_b = Agent(name="Agent B", handoffs=[agent_a, agent_c])
agent_c = Agent(name="Agent C", handoffs=[agent_a, agent_b])

# Start discussion
response = runner.run(agent_a, "Discuss: Should we implement feature X?")
# Agents collaborate to reach decision
```

---

## Production Best Practices

### Configuration Management

```python
from pydantic import BaseSettings

class AgentConfig(BaseSettings):
    model: str = "gpt-5"
    temperature: float = 0.7
    max_tokens: int = 1000

    class Config:
        env_file = ".env"

config = AgentConfig()
agent = Agent(
    name="Production Agent",
    model=config.model,
    temperature=config.temperature
)
```

### Monitoring

```python
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class MonitoredRunner(Runner):
    def run(self, agent, input, **kwargs):
        start_time = time.time()

        try:
            response = super().run(agent, input, **kwargs)
            duration = time.time() - start_time

            logger.info(f"Agent: {agent.name}, Duration: {duration:.2f}s")

            return response
        except Exception as e:
            logger.error(f"Agent {agent.name} failed: {e}")
            raise
```

### Rate Limiting

```python
from ratelimit import limits, sleep_and_retry

@sleep_and_retry
@limits(calls=10, period=60)  # 10 calls per minute
def rate_limited_run(agent, input):
    return runner.run(agent, input)
```

---

## Testing

### Unit Tests

```python
import pytest
from openai_agents import Agent, Runner

def test_agent_response():
    agent = Agent(
        name="Test Agent",
        instructions="Always say 'Hello'"
    )

    runner = Runner()
    response = runner.run(agent, "Hi")

    assert "hello" in response.messages[-1].content.lower()

def test_tool_execution():
    @tool
    def add(a: int, b: int) -> int:
        return a + b

    agent = Agent(name="Math", tools=[add])

    response = runner.run(agent, "What is 2 + 2?")

    # Verify tool was called
    assert any(msg.tool_calls for msg in response.messages)
```

### Integration Tests

```python
def test_multi_agent_workflow():
    agent1 = Agent(name="A1", instructions="Pass to A2", handoffs=[agent2])
    agent2 = Agent(name="A2", instructions="Respond with 'Done'")

    response = runner.run(agent1, "Start workflow")

    assert "Done" in response.messages[-1].content
```

---

## Additional Resources

- **Python SDK**: https://openai.github.io/openai-agents-python/
- **TypeScript SDK**: https://openai.github.io/openai-agents-js/
- **GitHub (Python)**: https://github.com/openai/openai-agents-python
- **GitHub (TypeScript)**: https://github.com/openai/openai-agents-js
- **Examples**: https://developers.openai.com/tracks/building-agents/

---

**Next**: [ChatKit →](../deploy/chatkit.md)
