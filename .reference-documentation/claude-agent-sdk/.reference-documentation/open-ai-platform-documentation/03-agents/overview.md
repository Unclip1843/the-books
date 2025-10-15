# OpenAI Platform - Agents Overview

**Source:** https://platform.openai.com/docs/guides/agents
**Fetched:** 2025-10-11

## What Are Agents?

Agents are AI systems that can autonomously complete multi-step tasks by:
- Breaking down complex problems
- Using tools and external APIs
- Making decisions based on context
- Coordinating with other agents
- Learning from feedback

OpenAI's Agent Platform provides a complete set of tools for developers and enterprises to build, deploy, and optimize agents.

---

## Agent Platform Components

### 1. Agent Builder

Visual canvas for composing agent logic.

**Features**:
- Drag-and-drop node interface
- Preview runs and inline evaluation
- Full versioning and templates
- Modular building blocks

**Like**: "Canva for building agents"

**Access**: https://platform.openai.com/agent-builder

### 2. Agents SDK

Production-ready framework for code-based agents.

**Languages**:
- Python: https://github.com/openai/openai-agents-python
- TypeScript: https://github.com/openai/openai-agents-js

**Key Features**:
- Multi-agent workflows
- Automatic handoffs
- Built-in guardrails
- Session management
- Tracing and debugging

### 3. ChatKit

Toolkit for embedding chat-based agent experiences.

**Use for**:
- Chat interfaces
- Custom UIs
- Agent deployment
- Customer-facing interactions

### 4. Connector Registry

Manage data and tool connections.

**Supports**:
- APIs and webhooks
- Databases
- MCP (Model Context Protocol) connectors
- File systems

---

## Agent Capabilities

### Tools

Agents can use various tools:

- **Web Search**: Real-time web access
- **Code Interpreter**: Run Python code
- **File Search**: RAG over documents
- **Computer Use**: Control desktop applications
- **Custom Functions**: Your own APIs

### Reasoning

Agents leverage GPT-5's built-in reasoning to:
- Plan multi-step workflows
- Evaluate options
- Self-correct errors
- Learn from outcomes

### Memory

- **Short-term**: Conversation context
- **Long-term**: Persistent storage across sessions
- **Shared**: Knowledge across agent teams

### Handoffs

Transfer control between specialized agents:

```python
from openai_agents import Agent

sales_agent = Agent(
    name="Sales",
    instructions="Handle sales inquiries"
)

support_agent = Agent(
    name="Support",
    instructions="Handle support tickets"
)

# Automatic handoff based on context
```

---

## Building Approaches

### 1. Visual (Agent Builder)

**Best for**:
- Non-coders
- Rapid prototyping
- Business users
- Simple workflows

**Pros**:
- No coding required
- Visual debugging
- Quick iteration

**Cons**:
- Less flexibility
- Limited to provided nodes

### 2. Code (Agents SDK)

**Best for**:
- Developers
- Complex logic
- Custom integrations
- Production systems

**Pros**:
- Full control
- Version control
- Testing frameworks
- Custom tools

**Cons**:
- Requires coding
- More setup

### 3. Hybrid

Combine both approaches:
- Build core logic in Agent Builder
- Export to code
- Extend with custom logic
- Deploy at scale

---

## Common Agent Patterns

### 1. Single Agent

One agent handles all tasks.

```
User → Agent → Tools → Response
```

**Use for**: Simple, focused tasks

### 2. Sequential Agents

Agents work in sequence.

```
User → Agent A → Agent B → Agent C → Response
```

**Use for**: Multi-stage processes

### 3. Hierarchical Agents

Manager agent coordinates workers.

```
          Manager Agent
         /      |       \
    Worker1  Worker2  Worker3
```

**Use for**: Complex, parallel tasks

### 4. Collaborative Agents

Agents discuss and decide together.

```
    Agent A ←→ Agent B
       ↕          ↕
    Agent C ←→ Agent D
```

**Use for**: Decision-making, consensus

---

## Agent Lifecycle

### 1. Build

**Agent Builder**:
- Design flow visually
- Configure nodes
- Add tools and guardrails

**Agents SDK**:
```python
from openai_agents import Agent

agent = Agent(
    name="Assistant",
    instructions="You are a helpful assistant",
    model="gpt-5",
    tools=[...]
)
```

### 2. Test

**Preview runs**: Test in Agent Builder
**Unit tests**: Test with SDK
**Evaluation**: Use built-in evals

### 3. Deploy

**ChatKit**: Embed in your app
**API**: Host as API endpoint
**Integration**: Connect to existing systems

### 4. Monitor

**Tracing**: View agent decisions
**Logging**: Track performance
**Analytics**: Measure success

### 5. Optimize

**Prompt engineering**: Refine instructions
**Tool selection**: Add/remove tools
**Eval-driven**: Use metrics to improve

---

## Getting Started

### Quick Start with Agent Builder

1. Go to https://platform.openai.com/agent-builder
2. Choose a template or blank canvas
3. Add nodes for logic flow
4. Connect tools
5. Configure guardrails
6. Preview and test
7. Deploy

### Quick Start with SDK

**Python**:
```bash
pip install openai-agents
```

```python
from openai_agents import Agent, Runner

agent = Agent(
    name="Assistant",
    instructions="You are helpful",
    model="gpt-5"
)

runner = Runner()
response = runner.run(agent, "Hello!")
print(response.messages[-1].content)
```

**TypeScript**:
```bash
npm install openai-agents
```

```typescript
import { Agent, Runner } from 'openai-agents';

const agent = new Agent({
  name: 'Assistant',
  instructions: 'You are helpful',
  model: 'gpt-5',
});

const runner = new Runner();
const response = await runner.run(agent, 'Hello!');
console.log(response.messages[response.messages.length - 1].content);
```

---

## Use Cases

### Customer Support

- Route inquiries to specialized agents
- Access knowledge base
- Escalate to humans when needed
- Track ticket status

### Sales Assistant

- Qualify leads
- Schedule meetings
- Answer product questions
- Generate proposals

### Coding Agent

- Generate code
- Debug issues
- Review pull requests
- Write documentation

### Research Agent

- Gather information
- Synthesize findings
- Cite sources
- Generate reports

### Data Analysis

- Query databases
- Create visualizations
- Generate insights
- Export reports

---

## Best Practices

### 1. Clear Instructions

```python
# Bad
instructions="Help users"

# Good
instructions="""You are a customer support agent. Your responsibilities:
1. Answer product questions accurately
2. Troubleshoot technical issues step-by-step
3. Escalate to human if issue is unresolved after 3 attempts
4. Always be polite and professional"""
```

### 2. Appropriate Tools

Only give agents tools they need:

```python
# For a sales agent
tools=["web_search", "calendar", "crm_api"]

# NOT
tools=[...all_available_tools]  # Too many choices
```

### 3. Guardrails

Protect against harmful or incorrect actions:

```python
guardrails=[
    {"type": "input_validation", "rules": [...]},
    {"type": "output_filtering", "rules": [...]},
    {"type": "action_approval", "actions": ["delete", "purchase"]}
]
```

### 4. Testing

Test edge cases thoroughly:

```python
test_cases = [
    "Normal case",
    "Ambiguous request",
    "Out of scope",
    "Adversarial input",
    "Multi-step task",
]

for case in test_cases:
    result = runner.run(agent, case)
    assert_valid(result)
```

### 5. Monitoring

Track agent performance:

```python
from openai_agents import trace

@trace
def run_agent(query):
    response = runner.run(agent, query)
    # Automatically traced
    return response
```

---

## Pricing

**Agent Builder**: Included with API access
**Agents SDK**: Free and open-source
**ChatKit**: Included with API access
**Model Usage**: Standard API pricing

Example costs:
- GPT-5: $1.25/1M input, $10/1M output
- GPT-5-mini: $0.30/1M input, $1.20/1M output

Agent overhead: +5-10% tokens for orchestration

---

## Limitations

### Current Limitations

- Maximum 10 agent handoffs per conversation
- Tools must complete within 60 seconds
- Maximum 20 tools per agent (recommended)
- File size limit: 512MB per file

### Coming Soon

- Multi-modal agent inputs (video, audio)
- Advanced memory systems
- Agent-to-agent learning
- Automated optimization

---

## Additional Resources

- **Agent Builder**: https://platform.openai.com/agent-builder
- **Agents SDK (Python)**: https://openai.github.io/openai-agents-python/
- **Agents SDK (TypeScript)**: https://openai.github.io/openai-agents-js/
- **Developer Guide**: https://developers.openai.com/tracks/building-agents/
- **Community**: https://community.openai.com/c/agents

---

**Next**: [Agent Builder →](./build-agents/agent-builder.md)
