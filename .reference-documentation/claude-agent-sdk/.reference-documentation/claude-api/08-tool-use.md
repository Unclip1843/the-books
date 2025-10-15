# Claude API - Tool Use Guide

**Sources:**
- https://docs.claude.com/en/docs/agents-and-tools/tool-use
- https://github.com/anthropics/anthropic-cookbook

**Fetched:** 2025-10-11

## Overview

Tool use (also known as function calling) allows Claude to interact with external tools and APIs. Claude can intelligently decide when to use tools, request them with proper parameters, and incorporate results into its responses.

## Supported Models

All Claude 3 and Claude 4 models support tool use:

| Model | Tool Use Support |
|-------|------------------|
| Claude Sonnet 4.5 | ✅ Yes |
| Claude Opus 4.1 | ✅ Yes |
| Claude Sonnet 4 | ✅ Yes |
| Claude Sonnet 3.7 | ✅ Yes |
| Claude Haiku 3.5 | ✅ Yes |
| Claude Haiku 3 | ✅ Yes |

## Types of Tools

### 1. Client Tools

Tools that execute on your systems:
- User-defined custom tools
- Anthropic-defined tools requiring client implementation
- You control execution and results

### 2. Server Tools

Tools that execute on Anthropic's servers:
- Web search
- Web fetch
- Automatically executed by Claude
- Results incorporated directly

## How Tool Use Works

### Workflow

```
1. Provide tools → Claude analyzes request
2. Claude decides to use tool → Sends tool_use request
3. Execute tool on your system → Get results
4. Send tool results back → Claude generates final response
```

### Event Flow

```
User: "What's the weather in San Francisco?"

1. API Request with tools defined
2. Claude Response: stop_reason="tool_use"
   - content[0]: tool_use block with name="get_weather", input={location: "San Francisco"}
3. Your Code: Execute get_weather("San Francisco") → {temp: 72, condition: "Sunny"}
4. API Request with tool_result
5. Claude Response: "It's currently 72°F and sunny in San Francisco"
```

## Defining Tools

### Tool Structure

```python
{
    "name": "tool_name",           # Required: Function identifier
    "description": "...",           # Required: What the tool does
    "input_schema": {              # Required: JSON Schema for parameters
        "type": "object",
        "properties": {...},
        "required": [...]
    }
}
```

### Example Tool Definitions

**Weather Tool:**
```python
{
    "name": "get_weather",
    "description": "Get the current weather in a given location",
    "input_schema": {
        "type": "object",
        "properties": {
            "location": {
                "type": "string",
                "description": "The city and state, e.g. San Francisco, CA"
            },
            "unit": {
                "type": "string",
                "enum": ["celsius", "fahrenheit"],
                "description": "The unit of temperature, either 'celsius' or 'fahrenheit'"
            }
        },
        "required": ["location"]
    }
}
```

**Database Query Tool:**
```python
{
    "name": "query_database",
    "description": "Execute a SQL query against the customer database",
    "input_schema": {
        "type": "object",
        "properties": {
            "query": {
                "type": "string",
                "description": "The SQL query to execute"
            },
            "limit": {
                "type": "integer",
                "description": "Maximum number of rows to return",
                "default": 100
            }
        },
        "required": ["query"]
    }
}
```

**File Operations Tool:**
```python
{
    "name": "read_file",
    "description": "Read the contents of a file from the filesystem",
    "input_schema": {
        "type": "object",
        "properties": {
            "file_path": {
                "type": "string",
                "description": "The absolute path to the file to read"
            },
            "encoding": {
                "type": "string",
                "enum": ["utf-8", "ascii", "latin-1"],
                "default": "utf-8",
                "description": "The character encoding of the file"
            }
        },
        "required": ["file_path"]
    }
}
```

## Python Implementation

### Basic Tool Use

```python
import anthropic

client = anthropic.Anthropic()

# Define tools
tools = [
    {
        "name": "get_weather",
        "description": "Get the current weather in a given location",
        "input_schema": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "The city and state, e.g. San Francisco, CA"
                },
                "unit": {
                    "type": "string",
                    "enum": ["celsius", "fahrenheit"],
                    "description": "The unit of temperature"
                }
            },
            "required": ["location"]
        }
    }
]

# Initial request
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "What's the weather like in San Francisco?"}]
)

print(response)
```

### Handling Tool Use Response

```python
# Check if Claude wants to use a tool
if response.stop_reason == "tool_use":
    tool_use = next(block for block in response.content if block.type == "tool_use")

    print(f"Tool: {tool_use.name}")
    print(f"Input: {tool_use.input}")

    # Execute the tool
    if tool_use.name == "get_weather":
        tool_result = get_weather(tool_use.input["location"],
                                   tool_use.input.get("unit", "fahrenheit"))
```

### Complete Tool Use Loop

```python
def process_tool_call(tool_name, tool_input):
    """Execute the actual tool"""
    if tool_name == "get_weather":
        # In reality, call a weather API
        return {
            "location": tool_input["location"],
            "temperature": 72,
            "condition": "Sunny",
            "humidity": 45
        }
    elif tool_name == "query_database":
        # Execute actual database query
        return [
            {"id": 1, "name": "Customer A"},
            {"id": 2, "name": "Customer B"}
        ]

# Initial request
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "What's the weather in SF?"}]
)

# Tool use loop
while response.stop_reason == "tool_use":
    # Extract tool use block
    tool_use = next(block for block in response.content if block.type == "tool_use")

    # Execute tool
    tool_result = process_tool_call(tool_use.name, tool_use.input)

    # Continue conversation with tool result
    response = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        tools=tools,
        messages=[
            {"role": "user", "content": "What's the weather in SF?"},
            {"role": "assistant", "content": response.content},
            {
                "role": "user",
                "content": [
                    {
                        "type": "tool_result",
                        "tool_use_id": tool_use.id,
                        "content": str(tool_result),
                    }
                ],
            },
        ],
    )

# Final response
print(response.content[0].text)
```

### Multiple Tools

```python
tools = [
    {
        "name": "get_weather",
        "description": "Get weather for a location",
        "input_schema": {
            "type": "object",
            "properties": {
                "location": {"type": "string"}
            },
            "required": ["location"]
        }
    },
    {
        "name": "get_stock_price",
        "description": "Get current stock price",
        "input_schema": {
            "type": "object",
            "properties": {
                "ticker": {"type": "string", "description": "Stock ticker symbol"}
            },
            "required": ["ticker"]
        }
    },
    {
        "name": "calculate",
        "description": "Perform mathematical calculations",
        "input_schema": {
            "type": "object",
            "properties": {
                "expression": {"type": "string", "description": "Math expression to evaluate"}
            },
            "required": ["expression"]
        }
    }
]

response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    tools=tools,
    messages=[{
        "role": "user",
        "content": "What's the weather in NYC and what's Apple's stock price?"
    }]
)
```

### Sequential Tool Calls

```python
def agentic_tool_loop(user_message, max_iterations=10):
    """Handle multiple sequential tool calls"""
    messages = [{"role": "user", "content": user_message}]

    for iteration in range(max_iterations):
        response = client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            tools=tools,
            messages=messages
        )

        if response.stop_reason == "end_turn":
            # No more tool calls needed
            final_text = next(
                (block.text for block in response.content if hasattr(block, "text")),
                None
            )
            return final_text

        if response.stop_reason == "tool_use":
            # Add assistant response
            messages.append({"role": "assistant", "content": response.content})

            # Process all tool calls in this turn
            tool_results = []
            for block in response.content:
                if block.type == "tool_use":
                    result = process_tool_call(block.name, block.input)
                    tool_results.append({
                        "type": "tool_result",
                        "tool_use_id": block.id,
                        "content": str(result)
                    })

            # Add tool results
            messages.append({"role": "user", "content": tool_results})

        if response.stop_reason == "max_tokens":
            return "Response truncated - increase max_tokens"

    return "Max iterations reached"

# Usage
result = agentic_tool_loop("What's the weather in SF and what's 15% of 250?")
print(result)
```

## TypeScript Implementation

### Basic Tool Use

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

const tools: Anthropic.Tool[] = [
  {
    name: 'get_weather',
    description: 'Get the current weather in a given location',
    input_schema: {
      type: 'object',
      properties: {
        location: {
          type: 'string',
          description: 'The city and state, e.g. San Francisco, CA',
        },
        unit: {
          type: 'string',
          enum: ['celsius', 'fahrenheit'],
          description: 'The unit of temperature',
        },
      },
      required: ['location'],
    },
  },
];

const response = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  tools,
  messages: [{ role: 'user', content: "What's the weather in San Francisco?" }],
});

console.log(response);
```

### Complete Tool Loop

```typescript
function processToolCall(toolName: string, toolInput: any): any {
  if (toolName === 'get_weather') {
    return {
      location: toolInput.location,
      temperature: 72,
      condition: 'Sunny',
      humidity: 45,
    };
  } else if (toolName === 'calculate') {
    return { result: eval(toolInput.expression) };
  }
}

async function runToolLoop(userMessage: string) {
  const messages: Anthropic.MessageParam[] = [
    { role: 'user', content: userMessage },
  ];

  while (true) {
    const response = await client.messages.create({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 2048,
      tools,
      messages,
    });

    if (response.stop_reason === 'end_turn') {
      const textBlock = response.content.find(
        (block): block is Anthropic.TextBlock => block.type === 'text'
      );
      return textBlock?.text || '';
    }

    if (response.stop_reason === 'tool_use') {
      // Add assistant's response
      messages.push({ role: 'assistant', content: response.content });

      // Process tool calls
      const toolResults: Anthropic.ToolResultBlockParam[] = [];

      for (const block of response.content) {
        if (block.type === 'tool_use') {
          const result = processToolCall(block.name, block.input);
          toolResults.push({
            type: 'tool_result',
            tool_use_id: block.id,
            content: JSON.stringify(result),
          });
        }
      }

      // Add tool results
      messages.push({ role: 'user', content: toolResults });
    }
  }
}

// Usage
const result = await runToolLoop("What's the weather in SF?");
console.log(result);
```

### Streaming with Tools

```typescript
const stream = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  tools,
  messages: [{ role: 'user', content: "What's the weather in SF?" }],
  stream: true,
});

let currentToolUse: { id: string; name: string; input: string } | null = null;

for await (const event of stream) {
  if (event.type === 'content_block_start') {
    if (event.content_block.type === 'tool_use') {
      currentToolUse = {
        id: event.content_block.id,
        name: event.content_block.name,
        input: '',
      };
    }
  } else if (event.type === 'content_block_delta') {
    if (event.delta.type === 'input_json_delta' && currentToolUse) {
      currentToolUse.input += event.delta.partial_json;
    }
  } else if (event.type === 'content_block_stop' && currentToolUse) {
    const toolInput = JSON.parse(currentToolUse.input);
    const result = processToolCall(currentToolUse.name, toolInput);
    console.log('Tool result:', result);
    currentToolUse = null;
  }
}
```

## Forcing Tool Use

Force Claude to use a specific tool:

**Python:**
```python
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    tools=tools,
    tool_choice={"type": "tool", "name": "get_weather"},
    messages=[{"role": "user", "content": "Tell me about San Francisco"}]
)
```

**TypeScript:**
```typescript
const response = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  tools,
  tool_choice: { type: 'tool', name: 'get_weather' },
  messages: [{ role: 'user', content: 'Tell me about San Francisco' }],
});
```

**Tool Choice Options:**
- `{"type": "auto"}` - Claude decides (default)
- `{"type": "any"}` - Force use of any tool
- `{"type": "tool", "name": "tool_name"}` - Force specific tool

## Error Handling

### Tool Execution Errors

```python
def process_tool_call(tool_name, tool_input):
    try:
        if tool_name == "query_database":
            result = execute_sql(tool_input["query"])
            return {"success": True, "data": result}
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "error_type": type(e).__name__
        }

# Send error back to Claude
tool_result_content = {
    "type": "tool_result",
    "tool_use_id": tool_use.id,
    "content": str(tool_result),
    "is_error": not tool_result.get("success", False)
}
```

### Input Validation

```python
def validate_tool_input(tool_name, tool_input):
    """Validate tool inputs before execution"""
    if tool_name == "query_database":
        if "DROP" in tool_input.get("query", "").upper():
            return False, "Dangerous SQL operation not allowed"
        if len(tool_input.get("query", "")) > 1000:
            return False, "Query too long"

    return True, None

# Use in tool loop
if response.stop_reason == "tool_use":
    tool_use = next(block for block in response.content if block.type == "tool_use")

    is_valid, error_msg = validate_tool_input(tool_use.name, tool_use.input)

    if not is_valid:
        tool_result = {"error": error_msg}
        is_error = True
    else:
        tool_result = process_tool_call(tool_use.name, tool_use.input)
        is_error = False
```

## Best Practices

### 1. Clear Tool Descriptions

```python
# Good
{
    "name": "send_email",
    "description": "Send an email to a recipient. Use this when the user asks to email someone or send a message via email.",
    "input_schema": {...}
}

# Too vague
{
    "name": "send_email",
    "description": "Sends email",
    "input_schema": {...}
}
```

### 2. Detailed Input Schemas

```python
# Good
{
    "type": "object",
    "properties": {
        "recipient": {
            "type": "string",
            "description": "Email address of the recipient in format: user@domain.com"
        },
        "subject": {
            "type": "string",
            "description": "Subject line of the email (max 100 characters)"
        },
        "body": {
            "type": "string",
            "description": "The main content/body of the email"
        },
        "priority": {
            "type": "string",
            "enum": ["low", "normal", "high"],
            "description": "Priority level for the email",
            "default": "normal"
        }
    },
    "required": ["recipient", "subject", "body"]
}
```

### 3. Handle Missing Parameters

```python
def process_tool_call(tool_name, tool_input):
    if tool_name == "get_weather":
        location = tool_input.get("location")
        if not location:
            return {"error": "Location parameter is required"}

        unit = tool_input.get("unit", "fahrenheit")  # Default value

        return get_weather_data(location, unit)
```

### 4. Return Structured Data

```python
# Good - Structured JSON
{
    "success": True,
    "data": {
        "temperature": 72,
        "condition": "Sunny",
        "humidity": 45
    },
    "timestamp": "2025-01-15T10:30:00Z"
}

# Less ideal - Plain text
"It's 72 degrees and sunny with 45% humidity"
```

### 5. Implement Timeouts

```python
import asyncio

async def process_tool_call_with_timeout(tool_name, tool_input, timeout=30):
    try:
        result = await asyncio.wait_for(
            execute_tool(tool_name, tool_input),
            timeout=timeout
        )
        return result
    except asyncio.TimeoutError:
        return {
            "error": f"Tool execution timed out after {timeout} seconds",
            "success": False
        }
```

## Common Use Cases

### 1. Customer Service Agent

```python
tools = [
    {
        "name": "lookup_customer",
        "description": "Look up customer information by email or customer ID",
        "input_schema": {
            "type": "object",
            "properties": {
                "identifier": {
                    "type": "string",
                    "description": "Customer email or ID"
                }
            },
            "required": ["identifier"]
        }
    },
    {
        "name": "get_order_status",
        "description": "Get the current status of an order",
        "input_schema": {
            "type": "object",
            "properties": {
                "order_id": {"type": "string"}
            },
            "required": ["order_id"]
        }
    },
    {
        "name": "create_support_ticket",
        "description": "Create a new support ticket",
        "input_schema": {
            "type": "object",
            "properties": {
                "customer_id": {"type": "string"},
                "issue": {"type": "string"},
                "priority": {"type": "string", "enum": ["low", "medium", "high"]}
            },
            "required": ["customer_id", "issue"]
        }
    }
]
```

### 2. Data Analysis Agent

```python
tools = [
    {
        "name": "query_database",
        "description": "Execute SQL queries against the analytics database",
        "input_schema": {
            "type": "object",
            "properties": {
                "query": {"type": "string"},
                "limit": {"type": "integer", "default": 100}
            },
            "required": ["query"]
        }
    },
    {
        "name": "create_visualization",
        "description": "Generate a chart or graph from data",
        "input_schema": {
            "type": "object",
            "properties": {
                "data": {"type": "array"},
                "chart_type": {"type": "string", "enum": ["bar", "line", "pie"]},
                "title": {"type": "string"}
            },
            "required": ["data", "chart_type"]
        }
    },
    {
        "name": "calculate_statistics",
        "description": "Calculate statistical measures (mean, median, std dev, etc.)",
        "input_schema": {
            "type": "object",
            "properties": {
                "numbers": {"type": "array", "items": {"type": "number"}},
                "measures": {"type": "array", "items": {"type": "string"}}
            },
            "required": ["numbers"]
        }
    }
]
```

### 3. Code Execution Agent

```python
tools = [
    {
        "name": "execute_python",
        "description": "Execute Python code and return the output",
        "input_schema": {
            "type": "object",
            "properties": {
                "code": {"type": "string", "description": "Python code to execute"},
                "timeout": {"type": "integer", "default": 30}
            },
            "required": ["code"]
        }
    },
    {
        "name": "install_package",
        "description": "Install a Python package using pip",
        "input_schema": {
            "type": "object",
            "properties": {
                "package_name": {"type": "string"}
            },
            "required": ["package_name"]
        }
    },
    {
        "name": "read_file",
        "description": "Read contents of a file",
        "input_schema": {
            "type": "object",
            "properties": {
                "file_path": {"type": "string"}
            },
            "required": ["file_path"]
        }
    }
]
```

## Pricing

Tool use adds tokens to your request:

- **Tool definitions**: ~40 tokens per tool (varies by complexity)
- **Tool results**: Counted as input tokens
- **Tool use blocks**: ~10 tokens per tool use

**Example:**
```
3 tools × 40 tokens = 120 tokens
User message: 20 tokens
Tool result: 100 tokens
Total input: 240 tokens

At Claude Sonnet 4.5 ($3/MTok):
Cost = (240 / 1,000,000) × $3 = $0.00072
```

## Limitations

- Maximum 1024 tools per request
- Tool names must match `^[a-zA-Z0-9_-]{1,64}$`
- Input schemas must be valid JSON Schema
- Tool results must be strings or JSON-serializable
- No nested tool calls (tool can't call another tool directly)

## Troubleshooting

### Issue: Claude doesn't use the tool

**Cause:** Unclear tool description
**Solution:** Make description more specific about when to use the tool

### Issue: Wrong parameters passed to tool

**Cause:** Vague parameter descriptions
**Solution:** Add detailed descriptions and examples in input_schema

### Issue: Tool loop never ends

**Cause:** Tool results don't satisfy Claude's needs
**Solution:** Return more complete data or add max_iterations limit

## Related Documentation

- [Messages API](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)
- [TypeScript SDK](./05-typescript-sdk.md)
- [Streaming](./06-streaming.md)
- [Examples](./11-examples.md)
