# OpenAI Platform - Node Reference

**Source:** https://platform.openai.com/docs/guides/agents/node-reference
**Fetched:** 2025-10-11

## Overview

Complete reference for all available nodes in Agent Builder. Each node has specific inputs, outputs, and configuration options.

---

## Core Nodes

### Start Node

**Purpose**: Entry point for agent workflow

**Inputs**: User message, context variables

**Outputs**: Passes all inputs to next node

**Configuration**:
```yaml
name: "start"
inputs:
  - user_message: string
  - user_id: string (optional)
  - session_id: string (optional)
```

---

### Agent Node

**Purpose**: LLM reasoning and response generation

**Inputs**: Messages, context

**Outputs**: Agent response, tool calls

**Configuration**:
```yaml
model: gpt-5 | gpt-5-mini | gpt-4o
instructions: string
temperature: 0.0-2.0 (default: 0.7)
max_tokens: 1-16384
tools: array (optional)
```

**Example**:
```yaml
agent_node:
  model: "gpt-5"
  instructions: "You are a helpful assistant"
  temperature: 0.7
  max_tokens: 1000
```

---

### Output Node

**Purpose**: Return final response to user

**Inputs**: Response content

**Outputs**: Final agent output

**Configuration**:
```yaml
format: text | markdown | json
include_sources: boolean
log_interaction: boolean
```

---

## Logic Nodes

### Conditional (If/Else)

**Purpose**: Branch workflow based on conditions

**Inputs**: Variable to test

**Outputs**: Follows true or false path

**Configuration**:
```yaml
condition:
  variable: "user_tier"
  operator: "==" | "!=" | ">" | "<" | "contains"
  value: "premium"
paths:
  true: node_id_1
  false: node_id_2
```

**Operators**:
- `==`: Equals
- `!=`: Not equals
- `>`, `<`, `>=`, `<=`: Comparison
- `contains`: String/array contains
- `starts_with`: String starts with
- `matches`: Regex match

---

### Loop (For Each)

**Purpose**: Iterate over collection

**Inputs**: Array to iterate

**Outputs**: Accumulated results

**Configuration**:
```yaml
loop:
  items: "{{documents}}"
  item_variable: "doc"
  max_iterations: 100
  body: [node_ids...]
```

**Example**:
```yaml
for_each:
  items: "{{search_results}}"
  item_variable: "result"
  body:
    - process_result
    - extract_data
```

---

### Switch (Multi-way Branch)

**Purpose**: Route to multiple paths based on value

**Inputs**: Variable to switch on

**Outputs**: Follows matching case path

**Configuration**:
```yaml
switch:
  variable: "{{intent}}"
  cases:
    - value: "sales"
      path: sales_agent
    - value: "support"
      path: support_agent
    - value: "billing"
      path: billing_agent
  default: general_agent
```

---

## Tool Nodes

### Web Search

**Purpose**: Search the web for information

**Inputs**: Query string

**Outputs**: Search results

**Configuration**:
```yaml
web_search:
  query: "{{user_question}}"
  max_results: 5
  search_type: general | news | images
```

**Output Format**:
```json
{
  "results": [
    {
      "title": "Result title",
      "url": "https://...",
      "snippet": "Description...",
      "timestamp": "2025-10-11"
    }
  ]
}
```

---

### Code Interpreter

**Purpose**: Execute Python code

**Inputs**: Code to execute

**Outputs**: Execution results

**Configuration**:
```yaml
code_interpreter:
  code: "{{python_code}}"
  timeout: 30
  packages: ["pandas", "numpy", "matplotlib"]
```

**Example**:
```python
# Input code
import pandas as pd
df = pd.read_csv('data.csv')
result = df.describe()
```

---

### File Search

**Purpose**: RAG over uploaded documents

**Inputs**: Query, file IDs

**Outputs**: Relevant excerpts

**Configuration**:
```yaml
file_search:
  query: "{{user_question}}"
  file_ids: ["file_abc123"]
  max_results: 5
  min_relevance: 0.7
```

---

### Database Query

**Purpose**: Query external database

**Inputs**: SQL query or parameters

**Outputs**: Query results

**Configuration**:
```yaml
database:
  connection: "{{db_connection_id}}"
  query: "SELECT * FROM users WHERE id = {{user_id}}"
  timeout: 10
```

---

### API Call

**Purpose**: Call external REST API

**Inputs**: Endpoint, method, body

**Outputs**: API response

**Configuration**:
```yaml
api_call:
  url: "https://api.example.com/data"
  method: GET | POST | PUT | DELETE
  headers:
    Authorization: "Bearer {{api_key}}"
  body: "{{request_data}}"
  timeout: 30
```

---

## Data Nodes

### Transform

**Purpose**: Transform and process data

**Inputs**: Data to transform

**Outputs**: Transformed data

**Configuration**:
```yaml
transform:
  operation: extract | filter | map | reduce
  input: "{{raw_data}}"
  expression: "{{data.field}}"
```

**Operations**:
- `extract`: Extract fields
- `filter`: Filter items
- `map`: Transform each item
- `reduce`: Aggregate
- `parse_json`: Parse JSON string
- `format_text`: String formatting

---

### Merge

**Purpose**: Combine multiple data sources

**Inputs**: Multiple data streams

**Outputs**: Merged data

**Configuration**:
```yaml
merge:
  inputs: ["stream_1", "stream_2"]
  strategy: concat | union | intersection
```

---

### Variable Set

**Purpose**: Set or update variables

**Inputs**: Variable name and value

**Outputs**: Updated context

**Configuration**:
```yaml
set_variable:
  name: "user_context"
  value: "{{agent_response}}"
  scope: local | session | global
```

---

## Control Flow Nodes

### Handoff

**Purpose**: Transfer to another agent

**Inputs**: Target agent, context

**Outputs**: Handoff confirmation

**Configuration**:
```yaml
handoff:
  target: "specialist_agent"
  context:
    conversation_history: "{{messages}}"
    issue_summary: "{{summary}}"
  condition: "{{requires_specialist}}"
```

---

### Human Escalation

**Purpose**: Transfer to human operator

**Inputs**: Escalation reason, context

**Outputs**: Pending human response

**Configuration**:
```yaml
escalate:
  queue: "support_team"
  priority: low | medium | high | urgent
  context: "{{full_context}}"
  notify: ["manager@example.com"]
```

---

### Approval Gate

**Purpose**: Require human approval before proceeding

**Inputs**: Action to approve

**Outputs**: Approved/rejected

**Configuration**:
```yaml
approval:
  action: "{{proposed_action}}"
  approvers: ["admin@example.com"]
  timeout: 3600  # seconds
  auto_approve: false
```

---

## Guardrail Nodes

### Input Validation

**Purpose**: Validate user inputs

**Inputs**: Input to validate

**Outputs**: Valid/invalid flag

**Configuration**:
```yaml
validate_input:
  checks:
    - type: length
      min: 1
      max: 1000
    - type: content
      disallow: ["harmful", "inappropriate"]
    - type: format
      pattern: "email" | "url" | regex
```

---

### Output Filter

**Purpose**: Filter agent outputs

**Inputs**: Agent response

**Outputs**: Filtered response

**Configuration**:
```yaml
filter_output:
  remove:
    - pii  # Personal identifiable information
    - credentials
    - sensitive_data
  replace_with: "[REDACTED]"
```

---

### Content Moderation

**Purpose**: Check content safety

**Inputs**: Text to moderate

**Outputs**: Moderation results

**Configuration**:
```yaml
moderate:
  categories:
    - hate
    - violence
    - sexual
    - self_harm
  action: block | flag | log
  threshold: 0.7
```

---

## Utility Nodes

### Delay

**Purpose**: Add pause in workflow

**Inputs**: None

**Outputs**: None (just waits)

**Configuration**:
```yaml
delay:
  duration: 5  # seconds
  reason: "Rate limit cooling"
```

---

### Log

**Purpose**: Log data for debugging

**Inputs**: Data to log

**Outputs**: Passes input through

**Configuration**:
```yaml
log:
  level: debug | info | warn | error
  message: "{{log_message}}"
  data: "{{context}}"
```

---

### Error Handler

**Purpose**: Catch and handle errors

**Inputs**: Error from previous node

**Outputs**: Error handling result

**Configuration**:
```yaml
error_handler:
  retry: 3
  fallback: "default_response"
  notify: true
```

---

## Variable Interpolation

All nodes support variable interpolation using `{{variable_name}}` syntax:

```yaml
agent:
  instructions: "Help {{user_name}} with {{their_issue}}"

api_call:
  url: "https://api.example.com/users/{{user_id}}"

conditional:
  condition: "{{user_tier}} == 'premium'"
```

---

## Node Connections

### Output Ports

Most nodes have these output types:

- **Success**: Normal completion
- **Error**: Error occurred
- **Timeout**: Operation timed out
- **Custom**: Node-specific outputs

### Connection Types

- **Sequential**: One node after another
- **Conditional**: Branch based on condition
- **Parallel**: Multiple nodes simultaneously
- **Loop**: Iterative connections

---

## Best Practices

### Naming

Use clear, descriptive names:

```yaml
✅ "validate_email_format"
❌ "node_7"

✅ "search_knowledge_base"
❌ "search"
```

### Error Handling

Always handle errors:

```yaml
node:
  on_error: error_handler_node
  timeout: 30
  retries: 3
```

### Variable Scope

Understand variable scoping:

- **Local**: Current workflow only
- **Session**: Persists across turns
- **Global**: Shared across agents

---

## Additional Resources

- **Agent Builder**: https://platform.openai.com/agent-builder
- **Node Examples**: https://platform.openai.com/docs/examples/nodes
- **Community Nodes**: https://community.openai.com/c/agent-nodes

---

**Next**: [Safety in Building Agents →](./safety.md)
