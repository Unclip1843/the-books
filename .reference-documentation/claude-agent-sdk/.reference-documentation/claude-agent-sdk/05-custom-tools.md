# Claude Agent SDK - Custom Tools Guide

**Source:** https://docs.claude.com/en/api/agent-sdk/custom-tools
**Fetched:** 2025-10-11

## Overview

Custom tools allow you to extend Claude Code's capabilities by creating specialized functions that Claude can use during interactions. These tools are implemented through in-process MCP (Model Context Protocol) servers.

## Benefits of Custom Tools

- **No subprocess management:** Tools run in the same process as your application
- **Better performance:** Reduced overhead compared to external tools
- **Simpler deployment:** No external dependencies to manage
- **Easier debugging:** Direct access to application state and variables
- **Type safety:** Full type checking with Zod (TypeScript) or Pydantic (Python)

## Tool Name Format

Custom tools follow a specific naming pattern:
```
mcp__{server_name}__{tool_name}
```

**Example:**
- Server name: `my-custom-tools`
- Tool name: `get_weather`
- Full tool name: `mcp__my-custom-tools__get_weather`

## Creating Custom Tools

### TypeScript Example

```typescript
import { createSdkMcpServer, tool } from '@anthropic-ai/claude-agent-sdk';
import { z } from 'zod';

// Define the tool
const weatherTool = tool(
  "get_weather",
  "Get current weather for a specified location",
  {
    location: z.string().describe("City name or coordinates"),
    units: z.enum(["celsius", "fahrenheit"]).default("celsius").describe("Temperature units")
  },
  async (args) => {
    // Implementation
    const weatherData = await fetchWeatherAPI(args.location, args.units);

    return {
      content: [{
        type: "text",
        text: `Weather in ${args.location}: ${weatherData.temp}°${args.units[0].toUpperCase()}, ${weatherData.condition}`
      }]
    };
  }
);

// Create MCP server with the tool
const customServer = createSdkMcpServer({
  name: "weather-service",
  version: "1.0.0",
  tools: [weatherTool]
});
```

### Python Example

```python
from claude_agent_sdk import create_sdk_mcp_server, tool
from pydantic import BaseModel, Field

class WeatherInput(BaseModel):
    location: str = Field(description="City name or coordinates")
    units: str = Field(default="celsius", description="Temperature units")

@tool(
    name="get_weather",
    description="Get current weather for a specified location",
    input_schema=WeatherInput
)
async def get_weather(location: str, units: str = "celsius"):
    """Fetch weather data from API"""
    weather_data = await fetch_weather_api(location, units)

    return f"Weather in {location}: {weather_data['temp']}°{units[0].upper()}, {weather_data['condition']}"

# Create MCP server with the tool
custom_server = create_sdk_mcp_server(
    name="weather-service",
    version="1.0.0",
    tools=[get_weather]
)
```

## Using Custom Tools

### Streaming Input Mode (Required)

Custom tools must be used with streaming input mode:

**TypeScript:**
```typescript
import { query } from '@anthropic-ai/claude-agent-sdk';

async function* streamPrompts() {
  yield "What's the weather in San Francisco?";
}

async function useWeatherTool() {
  for await (const message of query({
    prompt: streamPrompts(),
    options: {
      mcpServers: [customServer],
      allowedTools: ["mcp__weather-service__get_weather"]
    }
  })) {
    console.log(message);
  }
}
```

**Python:**
```python
async def stream_prompts():
    yield "What's the weather in San Francisco?"

async def use_weather_tool():
    async for message in query(
        prompt=stream_prompts(),
        options={
            "mcp_servers": [custom_server],
            "allowed_tools": ["mcp__weather-service__get_weather"]
        }
    ):
        print(message)
```

## Advanced Examples

### 1. Database Query Tool

**TypeScript:**
```typescript
import { tool } from '@anthropic-ai/claude-agent-sdk';
import { z } from 'zod';
import { Pool } from 'pg';

const dbPool = new Pool({ /* config */ });

const queryDatabaseTool = tool(
  "query_database",
  "Execute SQL queries against the database",
  {
    query: z.string().describe("SQL query to execute"),
    params: z.array(z.any()).optional().describe("Query parameters")
  },
  async (args) => {
    try {
      const result = await dbPool.query(args.query, args.params || []);

      return {
        content: [{
          type: "text",
          text: JSON.stringify(result.rows, null, 2)
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: "text",
          text: `Database error: ${error.message}`
        }],
        isError: true
      };
    }
  }
);
```

**Python:**
```python
from claude_agent_sdk import tool
from pydantic import BaseModel
import asyncpg

class DatabaseQueryInput(BaseModel):
    query: str
    params: list = []

@tool(
    name="query_database",
    description="Execute SQL queries against the database",
    input_schema=DatabaseQueryInput
)
async def query_database(query: str, params: list = []):
    conn = await asyncpg.connect(database='mydb')
    try:
        result = await conn.fetch(query, *params)
        return str([dict(r) for r in result])
    except Exception as e:
        return f"Database error: {str(e)}"
    finally:
        await conn.close()
```

### 2. API Gateway Tool

**TypeScript:**
```typescript
const apiGatewayTool = tool(
  "call_api",
  "Make HTTP requests to external APIs",
  {
    url: z.string().url().describe("API endpoint URL"),
    method: z.enum(["GET", "POST", "PUT", "DELETE"]).describe("HTTP method"),
    headers: z.record(z.string()).optional().describe("Request headers"),
    body: z.any().optional().describe("Request body")
  },
  async (args) => {
    const response = await fetch(args.url, {
      method: args.method,
      headers: args.headers,
      body: args.body ? JSON.stringify(args.body) : undefined
    });

    const data = await response.json();

    return {
      content: [{
        type: "text",
        text: JSON.stringify({ status: response.status, data }, null, 2)
      }]
    };
  }
);
```

### 3. Calculator Tool

**TypeScript:**
```typescript
const calculatorTool = tool(
  "calculate",
  "Perform mathematical calculations",
  {
    expression: z.string().describe("Mathematical expression to evaluate"),
    precision: z.number().default(2).describe("Decimal precision")
  },
  async (args) => {
    try {
      // Use a safe expression evaluator
      const result = evaluateExpression(args.expression);
      const rounded = Number(result.toFixed(args.precision));

      return {
        content: [{
          type: "text",
          text: `${args.expression} = ${rounded}`
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: "text",
          text: `Calculation error: ${error.message}`
        }],
        isError: true
      };
    }
  }
);
```

### 4. File System Tool

**Python:**
```python
from claude_agent_sdk import tool
from pydantic import BaseModel
import aiofiles
from pathlib import Path

class FileSearchInput(BaseModel):
    directory: str
    pattern: str

@tool(
    name="search_files",
    description="Search for files matching a pattern",
    input_schema=FileSearchInput
)
async def search_files(directory: str, pattern: str):
    """Search for files in directory matching pattern"""
    path = Path(directory)
    matches = list(path.glob(pattern))

    results = [
        {
            "path": str(m),
            "size": m.stat().st_size,
            "modified": m.stat().st_mtime
        }
        for m in matches
    ]

    return f"Found {len(results)} files:\n" + "\n".join([r["path"] for r in results])
```

### 5. Image Analysis Tool

**TypeScript:**
```typescript
import * as fs from 'fs/promises';

const imageAnalysisTool = tool(
  "analyze_image",
  "Analyze an image and extract information",
  {
    imagePath: z.string().describe("Path to image file"),
    analysisType: z.enum(["objects", "text", "colors"]).describe("Type of analysis")
  },
  async (args) => {
    const imageBuffer = await fs.readFile(args.imagePath);
    const base64Image = imageBuffer.toString('base64');

    // Return image for Claude to analyze
    return {
      content: [
        {
          type: "text",
          text: `Analyzing image for: ${args.analysisType}`
        },
        {
          type: "image",
          source: {
            type: "base64",
            media_type: "image/jpeg",
            data: base64Image
          }
        }
      ]
    };
  }
);
```

## Best Practices

### 1. Input Validation

Always validate inputs using Zod (TypeScript) or Pydantic (Python):

```typescript
// Good: Strict validation
const tool1 = tool(
  "process_data",
  "Process user data",
  {
    userId: z.string().uuid(),
    action: z.enum(["read", "write", "delete"]),
    data: z.object({
      name: z.string().min(1).max(100),
      age: z.number().min(0).max(150)
    })
  },
  async (args) => { /* ... */ }
);
```

### 2. Error Handling

Handle errors gracefully and return meaningful messages:

```typescript
const safeTool = tool(
  "safe_operation",
  "Perform operation with error handling",
  { /* schema */ },
  async (args) => {
    try {
      const result = await riskyOperation(args);
      return {
        content: [{ type: "text", text: result }]
      };
    } catch (error) {
      return {
        content: [{
          type: "text",
          text: `Operation failed: ${error.message}`
        }],
        isError: true
      };
    }
  }
);
```

### 3. Clear Descriptions

Provide detailed descriptions for tools and parameters:

```typescript
const wellDocumentedTool = tool(
  "fetch_user_data",
  "Fetch user information from the database. Returns user profile including name, email, and preferences.",
  {
    userId: z.string().uuid().describe("Unique identifier for the user (UUID format)"),
    includePrivate: z.boolean().default(false).describe("Whether to include private/sensitive fields")
  },
  async (args) => { /* ... */ }
);
```

### 4. Type Safety

Leverage type inference for safer code:

```typescript
// Types are automatically inferred
const typeSafeTool = tool(
  "typed_tool",
  "Example of type-safe tool",
  {
    count: z.number(),
    items: z.array(z.string())
  },
  async (args) => {
    // args.count is number
    // args.items is string[]
    const total = args.count * args.items.length;
    return {
      content: [{ type: "text", text: `Total: ${total}` }]
    };
  }
);
```

### 5. Async Operations

All tool handlers must be async:

```typescript
// Good: Async handler
const asyncTool = tool(
  "async_operation",
  "Performs async operation",
  { /* schema */ },
  async (args) => {
    const data = await fetchData(args);
    return { content: [{ type: "text", text: data }] };
  }
);

// Bad: Sync handler (will not work)
const syncTool = tool(
  "sync_operation",
  "This won't work",
  { /* schema */ },
  (args) => { // Missing async!
    return { content: [{ type: "text", text: "data" }] };
  }
);
```

## Tool Response Format

Tools must return a `ToolResponse` object:

```typescript
interface ToolResponse {
  content: Array<{
    type: 'text' | 'image';
    text?: string;
    source?: {
      type: 'base64';
      media_type: string;
      data: string;
    };
  }>;
  isError?: boolean;
}
```

**Examples:**

```typescript
// Text response
return {
  content: [{
    type: "text",
    text: "Operation completed successfully"
  }]
};

// Image response
return {
  content: [{
    type: "image",
    source: {
      type: "base64",
      media_type: "image/png",
      data: base64ImageData
    }
  }]
};

// Multiple content items
return {
  content: [
    { type: "text", text: "Here's the image analysis:" },
    { type: "image", source: { /* ... */ } },
    { type: "text", text: "Summary: ..." }
  ]
};

// Error response
return {
  content: [{
    type: "text",
    text: "Failed to process request"
  }],
  isError: true
};
```

## Complete Working Example

```typescript
import { query, createSdkMcpServer, tool } from '@anthropic-ai/claude-agent-sdk';
import { z } from 'zod';

// Define multiple tools
const tools = [
  tool(
    "add_numbers",
    "Add two numbers together",
    {
      a: z.number().describe("First number"),
      b: z.number().describe("Second number")
    },
    async (args) => ({
      content: [{
        type: "text",
        text: `${args.a} + ${args.b} = ${args.a + args.b}`
      }]
    })
  ),

  tool(
    "reverse_string",
    "Reverse a string",
    {
      text: z.string().describe("String to reverse")
    },
    async (args) => ({
      content: [{
        type: "text",
        text: args.text.split('').reverse().join('')
      }]
    })
  )
];

// Create server
const mathServer = createSdkMcpServer({
  name: "math-tools",
  version: "1.0.0",
  tools
});

// Use in agent
async function* streamPrompts() {
  yield "What is 15 + 27?";
  yield "Now reverse the word 'hello'";
}

async function runAgent() {
  for await (const message of query({
    prompt: streamPrompts(),
    options: {
      mcpServers: [mathServer],
      allowedTools: [
        "mcp__math-tools__add_numbers",
        "mcp__math-tools__reverse_string"
      ]
    }
  })) {
    console.log(message);
  }
}

runAgent().catch(console.error);
```

## Related Documentation

- [TypeScript API Reference](./04-api-reference-typescript.md)
- [Python API Reference](./03-api-reference-python.md)
- [Permissions Guide](./06-permissions.md)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)
