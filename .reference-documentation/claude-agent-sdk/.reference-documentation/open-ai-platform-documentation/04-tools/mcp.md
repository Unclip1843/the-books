# OpenAI Platform - Model Context Protocol (MCP)

**Source:** https://platform.openai.com/docs/mcp
**Fetched:** 2025-10-11

## Overview

The Model Context Protocol (MCP) is an open standard for connecting AI agents to external tools and data sources. OpenAI supports MCP through hosted servers, allowing you to connect to any MCP-compatible service with minimal code.

**Key Features:**
- Connect to any MCP server
- Pre-built connectors for popular services
- No additional cost (only output tokens)
- Hosted and local server support
- Standardized tool interface

**Benefits:**
- Reuse existing MCP servers
- Community-built integrations
- Consistent tool interface
- Reduced integration effort

---

## Quick Start

### Using Hosted MCP Server

```python
from openai import OpenAI

client = OpenAI()

# Connect to GitHub MCP server
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "List my GitHub repositories"
        }
    ],
    tools=[
        {
            "type": "hosted_mcp",
            "server": "github",
            "credentials": {
                "token": os.environ["GITHUB_TOKEN"]
            }
        }
    ]
)

print(response.choices[0].message.content)
```

**No additional cost**: Only output tokens are billed

---

## MCP Architecture

### How MCP Works

```
┌─────────────┐
│ OpenAI API  │
│  (Client)   │
└──────┬──────┘
       │
       ↓ MCP Protocol
┌──────────────┐
│  MCP Server  │
│ (GitHub, DB, │
│   Slack...)  │
└──────┬───────┘
       │
       ↓
┌──────────────┐
│   External   │
│   Service    │
└──────────────┘
```

### Components

1. **Client**: OpenAI API/Agent
2. **MCP Server**: Tool provider
3. **Transport**: Communication protocol (SSE, stdio)
4. **Tools**: Exposed functions
5. **Resources**: Data sources

---

## Built-in MCP Servers

### GitHub

Access repositories, issues, and pull requests.

```python
# GitHub MCP server
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "List open pull requests in my-org/my-repo"
        }
    ],
    tools=[
        {
            "type": "hosted_mcp",
            "server": "github",
            "credentials": {
                "token": os.environ["GITHUB_TOKEN"]
            }
        }
    ]
)
```

**Available Tools:**
- List repositories
- Get file contents
- Create/update files
- List/create issues
- List/create pull requests
- Search code

### PostgreSQL

Query and inspect databases.

```python
# PostgreSQL MCP server
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Show me the top 10 customers by revenue"
        }
    ],
    tools=[
        {
            "type": "hosted_mcp",
            "server": "postgresql",
            "credentials": {
                "connection_string": os.environ["DATABASE_URL"]
            }
        }
    ]
)
```

**Available Tools:**
- Query database (SELECT only)
- Get schema information
- List tables
- Describe table structure

**Safety**: Read-only access by default

### Slack

Send messages and retrieve channel information.

```python
# Slack MCP server
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Send a message to #general: 'Meeting at 3pm'"
        }
    ],
    tools=[
        {
            "type": "hosted_mcp",
            "server": "slack",
            "credentials": {
                "token": os.environ["SLACK_BOT_TOKEN"]
            }
        }
    ]
)
```

**Available Tools:**
- List channels
- Send messages
- Get channel history
- Search messages
- Get user info

### Google Drive

Access and search files.

```python
# Google Drive MCP server
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Find files modified in the last week"
        }
    ],
    tools=[
        {
            "type": "hosted_mcp",
            "server": "google_drive",
            "credentials": {
                "oauth_token": os.environ["GOOGLE_OAUTH_TOKEN"]
            }
        }
    ]
)
```

**Available Tools:**
- List files
- Search files
- Get file content
- Get file metadata

### MongoDB

Query MongoDB databases.

```python
# MongoDB MCP server
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Find all users who signed up this month"
        }
    ],
    tools=[
        {
            "type": "hosted_mcp",
            "server": "mongodb",
            "credentials": {
                "connection_string": os.environ["MONGODB_URI"]
            }
        }
    ]
)
```

### Brave Search

Web search via Brave API.

```python
# Brave Search MCP server
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Search for latest AI research papers"
        }
    ],
    tools=[
        {
            "type": "hosted_mcp",
            "server": "brave_search",
            "credentials": {
                "api_key": os.environ["BRAVE_API_KEY"]
            }
        }
    ]
)
```

---

## Custom MCP Servers

### Building an MCP Server

```python
from mcp.server import Server, Tool
from mcp.types import ToolInput, ToolResult
import uvicorn

app = Server("my-custom-server")

# Define tool
@app.tool(
    name="get_weather",
    description="Get current weather for a location",
    input_schema={
        "type": "object",
        "properties": {
            "location": {
                "type": "string",
                "description": "City name"
            }
        },
        "required": ["location"]
    }
)
async def get_weather(arguments: ToolInput) -> ToolResult:
    location = arguments["location"]

    # Fetch weather
    weather_data = await fetch_weather(location)

    return {
        "content": [
            {
                "type": "text",
                "text": f"Temperature: {weather_data['temp']}°F, Conditions: {weather_data['condition']}"
            }
        ]
    }

# Run server
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Using Custom MCP Server

```python
# Connect to custom MCP server
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "What's the weather in Tokyo?"
        }
    ],
    tools=[
        {
            "type": "mcp",
            "server_url": "https://my-server.com/mcp",
            "capabilities": ["tools"]
        }
    ]
)
```

---

## OpenAI Connectors

Pre-configured MCP servers with managed authentication.

```python
# Use OpenAI connector
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Get my Salesforce opportunities"
        }
    ],
    tools=[
        {
            "type": "hosted_mcp",
            "connector_id": "salesforce_connector",
            "access_token": user_access_token
        }
    ]
)
```

**Available Connectors:**
- Salesforce
- HubSpot
- Zendesk
- Jira
- Confluence
- And more...

---

## Agents SDK with MCP

### Local MCP Server

```python
from openai_agents import Agent
from mcp import LocalMCPServer

# Start local MCP server
mcp_server = LocalMCPServer(
    command=["node", "my-mcp-server.js"],
    env={"API_KEY": "..."}
)

# Create agent with MCP tools
agent = Agent(
    name="MCPAgent",
    instructions="Use MCP tools to help the user",
    model="gpt-5",
    tools=[mcp_server]
)

# Run agent
runner = Runner()
response = runner.run(
    agent=agent,
    messages=[{"role": "user", "content": "List my repositories"}]
)
```

### Hosted MCP with Agents

```python
from openai_agents import Agent, HostedMCPTool

# Use hosted MCP
github_tool = HostedMCPTool(
    server="github",
    credentials={"token": os.environ["GITHUB_TOKEN"]}
)

agent = Agent(
    name="GitHubAgent",
    model="gpt-5",
    tools=[github_tool]
)
```

---

## Advanced Usage

### Multiple MCP Servers

Connect to multiple MCP servers simultaneously.

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Get open GitHub issues and post a summary to Slack"
        }
    ],
    tools=[
        {
            "type": "hosted_mcp",
            "server": "github",
            "credentials": {"token": os.environ["GITHUB_TOKEN"]}
        },
        {
            "type": "hosted_mcp",
            "server": "slack",
            "credentials": {"token": os.environ["SLACK_BOT_TOKEN"]}
        }
    ]
)
```

### MCP + Custom Tools

Combine MCP servers with custom function tools.

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Get data from GitHub and process it"
        }
    ],
    tools=[
        # MCP server
        {
            "type": "hosted_mcp",
            "server": "github",
            "credentials": {"token": os.environ["GITHUB_TOKEN"]}
        },
        # Custom function
        {
            "type": "function",
            "function": {
                "name": "process_data",
                "description": "Process GitHub data",
                "parameters": {...}
            }
        }
    ]
)
```

### MCP with Other Built-in Tools

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Analyze this data and create visualizations"
        }
    ],
    tools=[
        {"type": "code_interpreter"},  # Built-in tool
        {"type": "file_search"},       # Built-in tool
        {
            "type": "hosted_mcp",       # MCP server
            "server": "postgresql",
            "credentials": {"connection_string": os.environ["DATABASE_URL"]}
        }
    ]
)
```

---

## Building MCP Servers

### Server Types

**Transport Protocols:**
- **stdio**: Local process communication
- **SSE**: Server-Sent Events over HTTP

**Hosting:**
- **Local**: Run on same machine as client
- **Remote**: Hosted service accessible via URL

### MCP Server Structure

```typescript
// TypeScript MCP server example
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

// Create server
const server = new Server(
  {
    name: "my-mcp-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Register tool
server.setRequestHandler("tools/list", async () => {
  return {
    tools: [
      {
        name: "get_user_data",
        description: "Get user data from database",
        inputSchema: {
          type: "object",
          properties: {
            user_id: {
              type: "string",
              description: "User ID"
            }
          },
          required: ["user_id"]
        }
      }
    ]
  };
});

// Handle tool calls
server.setRequestHandler("tools/call", async (request) => {
  if (request.params.name === "get_user_data") {
    const userData = await fetchUser(request.params.arguments.user_id);
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(userData)
        }
      ]
    };
  }
});

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

---

## Use Cases

### Database Query Agent

```python
# Agent that queries database using MCP
db_agent = Agent(
    name="DatabaseAgent",
    instructions="""
You are a database assistant. Help users query the database.
Always use the PostgreSQL MCP server to execute queries.
""",
    model="gpt-5",
    tools=[
        {
            "type": "hosted_mcp",
            "server": "postgresql",
            "credentials": {"connection_string": os.environ["DATABASE_URL"]}
        }
    ]
)

runner = Runner()
response = runner.run(
    agent=db_agent,
    messages=[
        {
            "role": "user",
            "content": "Show me the top 5 products by sales"
        }
    ]
)
```

### DevOps Assistant

```python
# Agent with multiple MCP servers
devops_agent = Agent(
    name="DevOpsAgent",
    instructions="Help with DevOps tasks using GitHub and Slack",
    model="gpt-5",
    tools=[
        {
            "type": "hosted_mcp",
            "server": "github",
            "credentials": {"token": os.environ["GITHUB_TOKEN"]}
        },
        {
            "type": "hosted_mcp",
            "server": "slack",
            "credentials": {"token": os.environ["SLACK_BOT_TOKEN"]}
        }
    ]
)

# Deploy notification workflow
response = runner.run(
    agent=devops_agent,
    messages=[
        {
            "role": "user",
            "content": """
Check if there are any new commits to main branch.
If yes, notify the #deployments channel.
"""
        }
    ]
)
```

---

## Best Practices

### 1. Credential Management

```python
# ✅ Good: Environment variables
credentials = {
    "token": os.environ["GITHUB_TOKEN"]
}

# ❌ Bad: Hardcoded credentials
credentials = {
    "token": "ghp_hardcoded_token_123"
}
```

### 2. Error Handling

```python
try:
    response = client.responses.create(
        model="gpt-5",
        messages=[{"role": "user", "content": "List repos"}],
        tools=[
            {
                "type": "hosted_mcp",
                "server": "github",
                "credentials": {"token": os.environ["GITHUB_TOKEN"]}
            }
        ]
    )
except Exception as e:
    if "authentication" in str(e).lower():
        print("Invalid GitHub token")
    elif "rate limit" in str(e).lower():
        print("GitHub rate limit exceeded")
    else:
        print(f"Error: {e}")
```

### 3. Scope Limitations

```python
# ✅ Good: Minimal permissions
github_token = generate_token(scopes=["repo:read"])

# ❌ Bad: Overly broad permissions
github_token = generate_token(scopes=["repo", "admin", "delete_repo"])
```

### 4. Monitor Usage

```python
# Track MCP tool calls
def log_mcp_usage(response):
    if response.tool_calls:
        for tool_call in response.tool_calls:
            if tool_call.type == "mcp":
                log_metric(
                    server=tool_call.server,
                    tool=tool_call.name,
                    timestamp=datetime.now()
                )
```

---

## Community MCP Servers

Popular community-built MCP servers:

- **AWS**: S3, Lambda, EC2 operations
- **Docker**: Container management
- **Kubernetes**: Cluster operations
- **Redis**: Cache operations
- **Stripe**: Payment processing
- **Twilio**: SMS/voice communication
- **SendGrid**: Email sending
- **Notion**: Workspace management

Find more at: https://github.com/modelcontextprotocol/servers

---

## Additional Resources

- **MCP Documentation**: https://modelcontextprotocol.io/
- **MCP Servers Repository**: https://github.com/modelcontextprotocol/servers
- **OpenAI MCP Guide**: https://platform.openai.com/docs/mcp
- **Agents SDK MCP**: https://openai.github.io/openai-agents-python/mcp/

---

**Next**: [Custom Tools →](./custom-tools.md)
