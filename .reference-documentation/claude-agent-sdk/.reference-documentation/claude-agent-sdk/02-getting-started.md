# Claude Agent SDK - Getting Started

**Source:** https://github.com/anthropics/claude-agent-sdk-python
**Fetched:** 2025-10-11

## Quick Start (Python)

### Installation
```bash
pip install claude-agent-sdk
```

### Basic Example
```python
import anyio
from claude_agent_sdk import query

async def main():
    async for message in query(prompt="What is 2 + 2?"):
        print(message)

anyio.run(main)
```

## Quick Start (TypeScript)

### Installation
```bash
npm install @anthropic-ai/claude-agent-sdk
```

### Basic Example
```typescript
import { query } from '@anthropic-ai/claude-agent-sdk';

async function main() {
  for await (const message of query({ prompt: "What is 2 + 2?" })) {
    console.log(message);
  }
}

main();
```

## Core Functions

### 1. `query()` - Main Interaction Function

The primary function for interacting with Claude Code. Creates an async generator that streams messages as they arrive.

**Python Example:**
```python
from claude_agent_sdk import query, ClaudeAgentOptions

async def ask_question():
    async for message in query(
        prompt="Explain async programming",
        options=ClaudeAgentOptions(
            model="claude-sonnet-4.5",
            allowed_tools=["Read", "Grep"]
        )
    ):
        print(message)
```

**TypeScript Example:**
```typescript
import { query } from '@anthropic-ai/claude-agent-sdk';

async function askQuestion() {
  for await (const message of query({
    prompt: "Explain async programming",
    options: {
      model: "claude-sonnet-4.5",
      allowedTools: ["Read", "Grep"]
    }
  })) {
    console.log(message);
  }
}
```

### 2. `tool()` - Create Custom Tools

Creates a type-safe MCP tool definition for use with SDK MCP servers.

**Python Example:**
```python
from claude_agent_sdk import tool, create_sdk_mcp_server
from pydantic import BaseModel

class WeatherInput(BaseModel):
    location: str
    units: str = "celsius"

@tool(
    name="get_weather",
    description="Get current weather for a location",
    input_schema=WeatherInput
)
async def get_weather(location: str, units: str = "celsius"):
    # Weather API logic here
    return f"Weather in {location}: 22°{units[0].upper()}"

server = create_sdk_mcp_server(
    name="weather-tools",
    version="1.0.0",
    tools=[get_weather]
)
```

**TypeScript Example:**
```typescript
import { tool, createSdkMcpServer } from '@anthropic-ai/claude-agent-sdk';
import { z } from 'zod';

const weatherTool = tool(
  "get_weather",
  "Get current weather for a location",
  {
    location: z.string().describe("City name"),
    units: z.enum(["celsius", "fahrenheit"]).default("celsius")
  },
  async (args) => {
    // Weather API logic here
    return {
      content: [{
        type: "text",
        text: `Weather in ${args.location}: 22°${args.units[0].toUpperCase()}`
      }]
    };
  }
);

const server = createSdkMcpServer({
  name: "weather-tools",
  version: "1.0.0",
  tools: [weatherTool]
});
```

### 3. `createSdkMcpServer()` - Create MCP Server

Creates an MCP server instance that runs in the same process as your application.

## Session Management (Python)

### Single-Use Sessions: `query()`
```python
# Each call creates a new session with no memory
async for message in query(prompt="Hello"):
    print(message)

async for message in query(prompt="What did I just say?"):
    print(message)  # Won't remember "Hello"
```

### Persistent Sessions: `ClaudeSDKClient()`
```python
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

async def conversation():
    options = ClaudeAgentOptions(
        model="claude-sonnet-4.5"
    )

    client = ClaudeSDKClient(options=options)

    # First question
    async for message in client.query("My name is Alice"):
        print(message)

    # Remembers previous context
    async for message in client.query("What's my name?"):
        print(message)  # Will respond with "Alice"
```

## Configuration Options

### Python: `ClaudeAgentOptions`
```python
from claude_agent_sdk import ClaudeAgentOptions

options = ClaudeAgentOptions(
    model="claude-sonnet-4.5",
    system_prompt="You are a helpful coding assistant",
    allowed_tools=["Read", "Write", "Bash", "Grep"],
    permission_mode="acceptEdits",
    hooks={
        "PreToolUse": my_pre_tool_hook,
        "PostToolUse": my_post_tool_hook
    }
)
```

### TypeScript: Query Options
```typescript
const options = {
  model: "claude-sonnet-4.5",
  systemPrompt: "You are a helpful coding assistant",
  allowedTools: ["Read", "Write", "Bash", "Grep"],
  permissionMode: "acceptEdits",
  hooks: {
    PreToolUse: myPreToolHook,
    PostToolUse: myPostToolHook
  }
};
```

## Custom Tool Benefits

- **No subprocess management:** Tools run in the same process
- **Better performance:** Reduced overhead
- **Simpler deployment:** No external dependencies
- **Easier debugging:** Direct access to application state
- **Type safety:** Full type checking in TypeScript/Python

## Error Handling

### Python
```python
from claude_agent_sdk import query, CLINotFoundError, ProcessError

async def safe_query():
    try:
        async for message in query(prompt="Run some command"):
            print(message)
    except CLINotFoundError as e:
        print(f"Claude CLI not found: {e}")
    except ProcessError as e:
        print(f"Process error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")
```

### TypeScript
```typescript
import { query } from '@anthropic-ai/claude-agent-sdk';

async function safeQuery() {
  try {
    for await (const message of query({ prompt: "Run some command" })) {
      console.log(message);
    }
  } catch (error) {
    console.error('Query failed:', error);
  }
}
```

## Next Steps

1. Explore [Python API Reference](./03-api-reference-python.md)
2. Explore [TypeScript API Reference](./04-api-reference-typescript.md)
3. Learn about [Custom Tools](./05-custom-tools.md)
4. Set up [Permissions](./06-permissions.md)
5. Implement [Subagents](./07-subagents.md)
