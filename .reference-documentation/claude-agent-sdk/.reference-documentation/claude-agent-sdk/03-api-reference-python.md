# Claude Agent SDK - Python API Reference

**Source:** https://docs.claude.com/en/api/agent-sdk/python
**Fetched:** 2025-10-11

## Installation

```bash
pip install claude-agent-sdk
```

**Requirements:**
- Python 3.10+
- Node.js
- Claude Code 2.0.0+

## Core Functions

### `query()`

Single-use session function with no conversation memory. Creates a new session for each interaction.

```python
from claude_agent_sdk import query

async def single_query():
    async for message in query(prompt="What is 2 + 2?"):
        print(message)
```

**Parameters:**
- `prompt` (str | AsyncIterable[str]): The query or prompt to send to Claude
- `options` (ClaudeAgentOptions, optional): Configuration options

**Returns:**
- AsyncGenerator[str, None, None]: Streaming messages from Claude

### `ClaudeSDKClient()`

Client for continuous conversations with context retention.

```python
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

async def persistent_conversation():
    options = ClaudeAgentOptions(
        model="claude-sonnet-4.5",
        system_prompt="You are a helpful assistant"
    )

    client = ClaudeSDKClient(options=options)

    # First interaction
    async for message in client.query("My name is Alice"):
        print(message)

    # Second interaction - remembers context
    async for message in client.query("What's my name?"):
        print(message)
```

**Parameters:**
- `options` (ClaudeAgentOptions, optional): Configuration options

**Methods:**
- `query(prompt: str | AsyncIterable[str])`: Send a query with context retention

### `tool()`

Decorator for defining MCP (Model Context Protocol) tools.

```python
from claude_agent_sdk import tool
from pydantic import BaseModel

class CalculatorInput(BaseModel):
    a: float
    b: float
    operation: str

@tool(
    name="calculator",
    description="Perform basic arithmetic operations",
    input_schema=CalculatorInput
)
async def calculator(a: float, b: float, operation: str):
    if operation == "add":
        return str(a + b)
    elif operation == "multiply":
        return str(a * b)
    # ... more operations
    return "Invalid operation"
```

**Parameters:**
- `name` (str): Tool name (becomes `mcp__{server_name}__{tool_name}`)
- `description` (str): Human-readable description
- `input_schema` (BaseModel): Pydantic model for input validation
- Handler function: async function that implements the tool

**Returns:**
- Tool definition object for use with `create_sdk_mcp_server()`

### `create_sdk_mcp_server()`

Creates an in-process MCP server instance.

```python
from claude_agent_sdk import create_sdk_mcp_server, tool

server = create_sdk_mcp_server(
    name="my-custom-tools",
    version="1.0.0",
    tools=[calculator, get_weather, ...]
)
```

**Parameters:**
- `name` (str): Server name
- `version` (str): Server version
- `tools` (list): List of tool definitions

**Returns:**
- MCP server instance

## Configuration Classes

### `ClaudeAgentOptions`

Configuration options for Claude agent behavior.

```python
from claude_agent_sdk import ClaudeAgentOptions

options = ClaudeAgentOptions(
    model="claude-sonnet-4.5",
    system_prompt="You are an expert Python developer",
    allowed_tools=["Read", "Write", "Bash", "Grep", "Glob"],
    permission_mode="acceptEdits",
    mcp_servers=[custom_server],
    hooks={
        "PreToolUse": pre_tool_hook,
        "PostToolUse": post_tool_hook,
        "UserPromptSubmit": prompt_submit_hook,
        "SessionStart": session_start_hook,
        "SessionEnd": session_end_hook
    }
)
```

**Fields:**
- `model` (str, optional): Claude model to use
  - Options: `"claude-sonnet-4.5"`, `"claude-opus-4"`, etc.
- `system_prompt` (str, optional): Custom system prompt
- `allowed_tools` (list[str], optional): List of allowed tool names
- `permission_mode` (str, optional): Permission mode
  - `"default"`: Standard permission checks
  - `"acceptEdits"`: Auto-approve file edits
  - `"bypassPermissions"`: Bypass all checks (use with caution)
- `mcp_servers` (list, optional): Custom MCP servers to enable
- `hooks` (dict, optional): Event hooks for custom behavior

### Permission Modes

```python
# Default mode - standard permission checks
options = ClaudeAgentOptions(permission_mode="default")

# Accept edits - automatically approve file edits
options = ClaudeAgentOptions(permission_mode="acceptEdits")

# Bypass permissions - skip all checks (dangerous!)
options = ClaudeAgentOptions(permission_mode="bypassPermissions")
```

## Hooks System

### Available Hook Events

```python
from claude_agent_sdk import ClaudeAgentOptions

async def pre_tool_use_hook(event):
    """Called before a tool is used"""
    print(f"About to use tool: {event.tool_name}")
    # Return True to allow, False to deny
    return True

async def post_tool_use_hook(event):
    """Called after a tool is used"""
    print(f"Tool result: {event.result}")

async def prompt_submit_hook(event):
    """Called when user submits a prompt"""
    print(f"User prompt: {event.prompt}")

async def session_start_hook(event):
    """Called when session starts"""
    print("Session started")

async def session_end_hook(event):
    """Called when session ends"""
    print("Session ended")

options = ClaudeAgentOptions(
    hooks={
        "PreToolUse": pre_tool_use_hook,
        "PostToolUse": post_tool_use_hook,
        "UserPromptSubmit": prompt_submit_hook,
        "SessionStart": session_start_hook,
        "SessionEnd": session_end_hook
    }
)
```

### Hook Event Types

**PreToolUse Event:**
```python
{
    "tool_name": str,
    "arguments": dict,
    "timestamp": datetime
}
```

**PostToolUse Event:**
```python
{
    "tool_name": str,
    "arguments": dict,
    "result": any,
    "duration": float,
    "timestamp": datetime
}
```

## Error Handling

### Exception Types

```python
from claude_agent_sdk import CLINotFoundError, ProcessError

try:
    async for message in query(prompt="Run analysis"):
        print(message)
except CLINotFoundError as e:
    # Claude CLI not found in PATH
    print(f"CLI not found: {e}")
except ProcessError as e:
    # Process execution error
    print(f"Process error: {e}")
except Exception as e:
    # Other errors
    print(f"Error: {e}")
```

## Complete Example

### Weather Agent with Custom Tools

```python
import anyio
from claude_agent_sdk import (
    query,
    ClaudeSDKClient,
    ClaudeAgentOptions,
    tool,
    create_sdk_mcp_server
)
from pydantic import BaseModel
import httpx

class WeatherInput(BaseModel):
    location: str
    units: str = "celsius"

@tool(
    name="get_weather",
    description="Get current weather for a location",
    input_schema=WeatherInput
)
async def get_weather(location: str, units: str = "celsius"):
    """Fetch weather data from API"""
    # Simulated API call
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"https://api.weather.com/data?location={location}&units={units}"
        )
        data = response.json()
        return f"Temperature in {location}: {data['temp']}°{units[0].upper()}"

# Create MCP server with custom tools
weather_server = create_sdk_mcp_server(
    name="weather-tools",
    version="1.0.0",
    tools=[get_weather]
)

async def weather_agent():
    """Interactive weather agent"""

    async def pre_tool_hook(event):
        print(f"→ Using tool: {event.tool_name}")
        return True

    options = ClaudeAgentOptions(
        model="claude-sonnet-4.5",
        system_prompt="You are a helpful weather assistant",
        allowed_tools=["mcp__weather-tools__get_weather"],
        mcp_servers=[weather_server],
        hooks={"PreToolUse": pre_tool_hook}
    )

    client = ClaudeSDKClient(options=options)

    # Example conversation
    async for message in client.query("What's the weather in San Francisco?"):
        print(message)

    async for message in client.query("How about Tokyo?"):
        print(message)

if __name__ == "__main__":
    anyio.run(weather_agent)
```

## Best Practices

1. **Use `ClaudeSDKClient()` for conversations:** Maintains context across queries
2. **Use `query()` for one-off tasks:** Simpler for single interactions
3. **Validate tool inputs:** Use Pydantic models for type safety
4. **Handle errors gracefully:** Catch specific exceptions
5. **Use hooks for monitoring:** Track tool usage and performance
6. **Limit tool permissions:** Only allow necessary tools
7. **Set appropriate permission modes:** Balance security and automation

## See Also

- [TypeScript API Reference](./04-api-reference-typescript.md)
- [Custom Tools Guide](./05-custom-tools.md)
- [Permissions Guide](./06-permissions.md)
- [Subagents Guide](./07-subagents.md)
