# OpenAI Platform - Agent Builder

**Source:** https://platform.openai.com/docs/guides/agent-builder
**Fetched:** 2025-10-11

## Overview

Agent Builder is a visual canvas for composing agent logic without code. Described as "like Canva for building agents," it provides a drag-and-drop interface for creating complex agentic workflows.

**Access**: https://platform.openai.com/agent-builder

---

## Key Features

### Visual Canvas

- **Drag-and-drop nodes**: Build workflows visually
- **Real-time preview**: Test as you build
- **Version control**: Track changes and rollback
- **Templates**: Start with pre-built patterns

### Built-in Tools

- **Preview runs**: Test agent behavior inline
- **Inline evals**: Evaluate performance
- **Debugging**: Step through agent decisions
- **Export to code**: Generate SDK code

### Collaboration

- **Team workspaces**: Build together
- **Comments**: Discuss within canvas
- **Sharing**: Share agents with team
- **Permissions**: Control access

---

## Getting Started

### 1. Create New Agent

**From Template**:
- Customer Support Agent
- Sales Assistant
- Research Agent
- Code Helper
- Data Analyst

**From Blank Canvas**:
- Start with empty workflow
- Add nodes as needed
- Full customization

### 2. Configure Agent

```
Agent Settings:
├── Name: "Customer Support Bot"
├── Model: gpt-5
├── Instructions: "You help customers..."
└── Tools: [web_search, file_search, ...]
```

### 3. Build Workflow

Add and connect nodes to create logic flow.

---

## Node Types

### Start Node

Entry point for all agents.

**Configuration**:
- Input schema
- Initial context
- User data

**Example**:
```
Start
├── Input: user_query
├── Context: customer_id, session_id
└── Metadata: timestamp, channel
```

### Agent Node

Core reasoning and response generation.

**Configuration**:
- Model selection
- Instructions
- Temperature
- Max tokens

**Example**:
```
Agent Node
├── Model: gpt-5
├── Instructions: "Analyze the query and provide helpful response"
├── Temperature: 0.7
└── Max tokens: 1000
```

### Tool Node

Execute external tools or functions.

**Built-in Tools**:
- Web Search
- Code Interpreter
- File Search
- Database Query

**Custom Tools**:
- API calls
- Custom functions
- External services

**Example**:
```
Tool: Web Search
├── Query: {user_question}
├── Max results: 5
└── Output: search_results
```

### Conditional Node (If/Else)

Branch logic based on conditions.

**Configuration**:
- Condition expression
- True path
- False path

**Example**:
```
If customer_tier == "premium"
├── True → Premium Support Agent
└── False → Standard Support Agent
```

### Loop Node

Repeat actions multiple times.

**Configuration**:
- Iteration variable
- Max iterations
- Loop body

**Example**:
```
For each document in documents
├── Process document
├── Extract key points
└── Accumulate results
```

### Guardrail Node

Validate inputs/outputs for safety.

**Types**:
- Input validation
- Output filtering
- Action approval
- Content moderation

**Example**:
```
Guardrail: Output Safety
├── Check for: PII, offensive content
├── Action: filter | block | flag
└── Fallback: safe_response
```

### Handoff Node

Transfer to another agent or human.

**Configuration**:
- Target agent/human
- Context to pass
- Handoff conditions

**Example**:
```
Handoff to Human
├── Condition: cannot_resolve || urgent
├── Context: conversation_history, issue_summary
└── Target: support_team
```

### Data Transform Node

Process and format data.

**Operations**:
- JSON parsing
- Data extraction
- Formatting
- Aggregation

**Example**:
```
Transform
├── Input: raw_data
├── Operation: extract_emails
└── Output: email_list
```

### Output Node

Final response to user.

**Configuration**:
- Response format
- Post-processing
- Logging

**Example**:
```
Output
├── Format: markdown
├── Include: sources, confidence
└── Log: true
```

---

## Connecting Nodes

### Direct Connection

Simple flow from one node to next.

```
Start → Agent → Tool → Output
```

### Conditional Routing

Branch based on conditions.

```
Start → Agent → Conditional
                    ├── True → Tool A → Output
                    └── False → Tool B → Output
```

### Parallel Execution

Run multiple paths simultaneously.

```
Start → Agent → [Tool A, Tool B, Tool C] → Merge → Output
```

### Loops

Iterative processing.

```
Start → Agent → Loop
                  ├── Process Item
                  └── Next Iteration
                → Output
```

---

## Building Patterns

### 1. Simple Q&A Agent

```
Start
  → Agent (answer questions)
  → Output
```

### 2. Research Agent

```
Start
  → Agent (understand query)
  → Web Search
  → Agent (synthesize findings)
  → Output
```

### 3. Multi-Tool Agent

```
Start
  → Agent (decide tool)
  → Conditional
      ├── Need Search → Web Search
      ├── Need Data → Database Query
      └── Need Code → Code Interpreter
  → Agent (process results)
  → Output
```

### 4. Routing Agent

```
Start
  → Classifier Agent
  → Conditional
      ├── Sales → Sales Agent → Output
      ├── Support → Support Agent → Output
      └── Other → General Agent → Output
```

### 5. Iterative Agent

```
Start
  → Agent (plan tasks)
  → Loop (for each task)
      → Tool (execute)
      → Agent (verify)
  → Agent (summarize)
  → Output
```

---

## Testing & Preview

### Preview Run

Test agent with sample inputs.

**Steps**:
1. Click "Preview"
2. Enter test input
3. Watch execution flow
4. Review output

**Features**:
- Step-by-step execution
- Node-level inspection
- Variable values
- Timing information

### Test Cases

Save and reuse test inputs.

```
Test Case: Basic Query
├── Input: "What's the weather?"
├── Expected: Weather information
└── Status: Pass/Fail

Test Case: Complex Query
├── Input: "Research AI trends and create report"
├── Expected: Detailed report with sources
└── Status: Pass/Fail
```

### Debugging

Inspect agent behavior.

**Tools**:
- Breakpoints
- Variable inspection
- Execution logs
- Error messages

---

## Evaluation

### Built-in Evals

Configure inline evaluation.

**Metrics**:
- Response quality
- Tool usage accuracy
- Latency
- Cost

**Configuration**:
```
Eval Config
├── Metric: response_quality
├── Evaluator: gpt-5
├── Criteria: helpful, accurate, concise
└── Threshold: 0.8
```

### Custom Evals

Define your own evaluation criteria.

```python
def custom_eval(input, output):
    # Check if output contains required elements
    has_sources = "Sources:" in output
    has_summary = len(output) > 100

    return {
        "passed": has_sources and has_summary,
        "score": calculate_score(output)
    }
```

---

## Version Control

### Versions

Track changes over time.

**Features**:
- Auto-save versions
- Manual version tagging
- Compare versions
- Rollback

**Example**:
```
Versions
├── v1.0.0: Initial release
├── v1.1.0: Added web search
├── v1.2.0: Improved prompts
└── v2.0.0: Multi-agent support
```

### Branches

Work on features separately.

```
main
├── develop
│   ├── feature/new-tool
│   └── feature/better-prompts
└── hotfix/critical-bug
```

---

## Deployment

### Export Options

**1. ChatKit Embed**:
```html
<script src="https://chatkit.openai.com/embed.js"></script>
<div id="chatkit-container"
     data-agent-id="agent_abc123"></div>
```

**2. SDK Code**:
```python
# Generated code
from openai_agents import Agent

agent = Agent.from_config("agent_abc123")
```

**3. API Endpoint**:
```bash
curl https://api.openai.com/v1/agents/agent_abc123/run \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{"input": "Hello"}'
```

### Publishing

**Steps**:
1. Test thoroughly
2. Create version tag
3. Click "Publish"
4. Choose deployment target
5. Configure access

**Options**:
- Private (team only)
- Public (with API key)
- Embedded (via ChatKit)

---

## Best Practices

### 1. Start Simple

Begin with basic flow, add complexity gradually.

```
✅ Start → Agent → Output
❌ Start → 10 nodes → Complex logic → Output
```

### 2. Use Templates

Leverage pre-built patterns.

```
Templates
├── Customer Support
├── Sales Assistant
├── Research Agent
└── Code Helper
```

### 3. Add Guardrails

Protect against unexpected inputs/outputs.

```
Input → Guardrail → Agent → Guardrail → Output
```

### 4. Test Edge Cases

Test with unusual inputs.

```
Test Cases
├── Normal: "Help me with X"
├── Ambiguous: "That thing"
├── Complex: Multi-step task
└── Adversarial: "Ignore instructions"
```

### 5. Monitor Performance

Track metrics in production.

```
Metrics
├── Response time
├── Success rate
├── User satisfaction
└── Cost per interaction
```

---

## Limitations

### Node Limits

- Maximum 100 nodes per agent
- Maximum 10 handoffs per conversation
- Tool execution timeout: 60 seconds

### Performance

- Preview runs: Limited to 10 concurrent
- API rate limits apply
- Large workflows may be slower

### Features

- Limited custom code within nodes
- No direct database connections (use API tools)
- File size limit: 512MB

---

## Troubleshooting

### Common Issues

**Agent not responding**:
- Check node connections
- Verify API keys
- Review error logs

**Incorrect outputs**:
- Improve agent instructions
- Add guardrails
- Test with more examples

**Slow performance**:
- Reduce tool calls
- Use smaller models for simple tasks
- Optimize prompts

---

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Add node | `N` |
| Delete node | `Delete` |
| Duplicate | `Cmd+D` |
| Preview | `Cmd+P` |
| Save | `Cmd+S` |
| Undo | `Cmd+Z` |
| Redo | `Cmd+Shift+Z` |

---

## Additional Resources

- **Agent Builder**: https://platform.openai.com/agent-builder
- **Video Tutorial**: https://openai.com/agent-builder-tutorial
- **Community**: https://community.openai.com/c/agent-builder
- **Templates**: https://platform.openai.com/agent-templates

---

**Next**: [Node Reference →](./node-reference.md)
