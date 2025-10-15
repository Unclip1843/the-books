# OpenAI Platform - Tools Overview

**Source:** https://platform.openai.com/docs/guides/tools
**Fetched:** 2025-10-11

## Overview

Tools extend agent capabilities by enabling them to perform specific actions beyond text generation. OpenAI provides built-in tools, supports the Model Context Protocol (MCP) for third-party tools, and allows custom tool development.

**Tool Categories:**
- **Built-in Tools**: Code Interpreter, File Search, Web Search, Computer Use, Image Generation
- **MCP Tools**: Connect to any MCP server
- **Custom Tools**: Define your own function tools
- **Knowledge Tools**: Knowledge graphs, vector search

---

## Built-in Tools

### Code Interpreter

Execute Python code in a secure sandbox environment.

```python
from openai import OpenAI

client = OpenAI()

# Enable code interpreter
response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Analyze this CSV data and create a chart"}
    ],
    tools=[{"type": "code_interpreter"}],
    files=["data.csv"]
)
```

**Capabilities:**
- Data analysis and visualization
- Complex mathematical calculations
- File processing (CSV, JSON, etc.)
- Image manipulation
- Code execution

**Pricing**: $0.03 per session

### File Search

Retrieve relevant information from uploaded documents.

```python
# Upload files
file1 = client.files.create(
    file=open("manual.pdf", "rb"),
    purpose="assistants"
)

file2 = client.files.create(
    file=open("specs.pdf", "rb"),
    purpose="assistants"
)

# Enable file search
response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "What are the safety specifications?"}
    ],
    tools=[{"type": "file_search"}],
    tool_resources={
        "file_search": {
            "vector_store_ids": [vector_store.id]
        }
    }
)
```

**Capabilities:**
- Semantic search across documents
- Multi-file search
- Metadata filtering
- Chunk retrieval with citations

**Pricing**:
- $0.10/GB per day (vector storage)
- $2.50/1k tool calls

### Web Search (Preview)

Search the internet for current information.

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "What are the latest AI developments?"}
    ],
    tools=[{"type": "web_search_preview"}]
)
```

**Capabilities:**
- Real-time web search
- News and current events
- Fact verification
- Research assistance

### Computer Use (Beta)

Control computer interfaces programmatically.

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Click the submit button"}
    ],
    tools=[{"type": "computer_use"}]
)
```

**Capabilities:**
- Screen reading
- Mouse and keyboard control
- Application interaction
- UI automation

### Image Generation

Generate images using DALL-E.

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Generate an image of a sunset over mountains"}
    ],
    tools=[{"type": "image_generation"}]
)
```

---

## Model Context Protocol (MCP)

### What is MCP?

MCP is an open protocol that standardizes how applications provide context to LLMs. It enables seamless integration with third-party tools and data sources.

### Using MCP Tools

```python
# Connect to MCP server
response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Get my GitHub repositories"}
    ],
    tools=[
        {
            "type": "mcp",
            "server_url": "https://mcp.example.com/github",
            "capabilities": ["read", "write"]
        }
    ]
)
```

### Built-in MCP Servers

OpenAI provides MCP servers for common services:

- **GitHub**: Repository management, issues, PRs
- **Google Drive**: File access and search
- **Slack**: Channel management, messaging
- **PostgreSQL**: Database queries
- **MongoDB**: Document database operations
- **Brave Search**: Web search alternative

```python
# Use GitHub MCP server
response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "List my open pull requests"}
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

**Pricing**: No additional cost (only output tokens)

---

## Custom Tools

### Defining Custom Tools

```python
# Define custom tool
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get current weather for a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "City name or zip code"
                    },
                    "units": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"],
                        "description": "Temperature units"
                    }
                },
                "required": ["location"]
            }
        }
    }
]

# Use custom tool
response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "What's the weather in Tokyo?"}
    ],
    tools=tools
)

# Handle tool calls
if response.tool_calls:
    for tool_call in response.tool_calls:
        if tool_call.function.name == "get_weather":
            args = json.loads(tool_call.function.arguments)
            result = get_weather(args["location"], args.get("units", "celsius"))

            # Submit result
            response = client.responses.create(
                model="gpt-5",
                messages=[
                    {"role": "user", "content": "What's the weather in Tokyo?"},
                    response.choices[0].message,
                    {
                        "role": "tool",
                        "tool_call_id": tool_call.id,
                        "content": json.dumps(result)
                    }
                ],
                tools=tools
            )
```

### Tool Implementation Best Practices

```python
# ✅ Good tool definition
{
    "name": "create_calendar_event",
    "description": "Create a new calendar event with title, date, and time",
    "parameters": {
        "type": "object",
        "properties": {
            "title": {
                "type": "string",
                "description": "Event title"
            },
            "date": {
                "type": "string",
                "description": "Event date in YYYY-MM-DD format"
            },
            "time": {
                "type": "string",
                "description": "Event time in HH:MM format (24-hour)"
            },
            "duration_minutes": {
                "type": "integer",
                "description": "Event duration in minutes",
                "minimum": 15
            }
        },
        "required": ["title", "date", "time"]
    }
}

# ❌ Poor tool definition
{
    "name": "do_thing",
    "description": "Does a thing",
    "parameters": {
        "type": "object",
        "properties": {
            "data": {"type": "string"}
        }
    }
}
```

---

## Knowledge Tools

### Vector Search

```python
# Create vector store
vector_store = client.vector_stores.create(
    name="product_documentation",
    file_ids=[file1.id, file2.id, file3.id]
)

# Search with metadata filtering
response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Find information about API authentication"}
    ],
    tools=[{"type": "file_search"}],
    tool_resources={
        "file_search": {
            "vector_store_ids": [vector_store.id],
            "metadata_filter": {
                "section": "security",
                "version": "v2"
            }
        }
    }
)
```

### Knowledge Graphs

```python
# Query knowledge graph
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
                        "description": "Entity to query"
                    },
                    "relationship": {
                        "type": "string",
                        "description": "Relationship type to traverse"
                    },
                    "depth": {
                        "type": "integer",
                        "description": "Traversal depth",
                        "default": 1
                    }
                },
                "required": ["entity"]
            }
        }
    }
]

response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Who are the co-founders of companies that Peter Thiel invested in?"}
    ],
    tools=tools
)
```

**Capabilities:**
- Multi-hop reasoning
- Entity relationship traversal
- Complex graph queries
- Temporal queries

---

## Tool Orchestration

### Multiple Tools

Use multiple tools together for complex workflows.

```python
tools = [
    {"type": "web_search_preview"},
    {"type": "code_interpreter"},
    {
        "type": "function",
        "function": {
            "name": "send_email",
            "description": "Send an email",
            "parameters": {...}
        }
    }
]

response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Research the latest AI news, create a summary chart, and email it to me"
        }
    ],
    tools=tools
)

# Agent will:
# 1. Use web_search_preview to find news
# 2. Use code_interpreter to create chart
# 3. Call send_email function
```

### Tool Choice Control

```python
# Force specific tool
response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "What's the weather?"}],
    tools=tools,
    tool_choice={"type": "function", "function": {"name": "get_weather"}}
)

# Disable tools for this request
response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Just answer this"}],
    tools=tools,
    tool_choice="none"
)

# Auto (default)
response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Help me"}],
    tools=tools,
    tool_choice="auto"  # Model decides
)
```

### Parallel Tool Calls

```python
# Model can call multiple tools in parallel
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Get weather for New York, London, and Tokyo"
        }
    ],
    tools=tools,
    parallel_tool_calls=True
)

# Process all tool calls
results = []
for tool_call in response.tool_calls:
    result = execute_tool(tool_call.function.name, tool_call.function.arguments)
    results.append({
        "role": "tool",
        "tool_call_id": tool_call.id,
        "content": json.dumps(result)
    })

# Continue conversation with all results
final_response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Get weather for New York, London, and Tokyo"},
        response.choices[0].message,
        *results
    ],
    tools=tools
)
```

---

## Tool Security

### Input Validation

```python
def validate_tool_arguments(tool_name, arguments):
    """Validate tool arguments before execution."""
    if tool_name == "send_email":
        # Validate email address
        if not re.match(r"[^@]+@[^@]+\.[^@]+", arguments.get("to", "")):
            raise ValueError("Invalid email address")

        # Check email is in allowed domains
        domain = arguments["to"].split("@")[1]
        if domain not in ALLOWED_DOMAINS:
            raise ValueError("Email domain not allowed")

    return True

# Use in tool execution
if response.tool_calls:
    for tool_call in response.tool_calls:
        try:
            args = json.loads(tool_call.function.arguments)
            validate_tool_arguments(tool_call.function.name, args)
            result = execute_tool(tool_call.function.name, args)
        except ValueError as e:
            result = {"error": str(e)}
```

### Rate Limiting

```python
from collections import defaultdict
import time

tool_calls = defaultdict(list)

def rate_limit_tool(tool_name, max_calls=10, window_seconds=60):
    """Rate limit tool calls."""
    now = time.time()

    # Remove old calls
    tool_calls[tool_name] = [
        t for t in tool_calls[tool_name]
        if now - t < window_seconds
    ]

    # Check limit
    if len(tool_calls[tool_name]) >= max_calls:
        raise ValueError(f"Rate limit exceeded for {tool_name}")

    # Record call
    tool_calls[tool_name].append(now)
```

### Approval Workflows

```python
REQUIRES_APPROVAL = ["delete_file", "send_email", "make_purchase"]

async def handle_tool_call(tool_call):
    """Handle tool call with approval if needed."""
    tool_name = tool_call.function.name

    if tool_name in REQUIRES_APPROVAL:
        # Request approval
        approved = await request_approval(
            tool_name=tool_name,
            arguments=tool_call.function.arguments
        )

        if not approved:
            return {"error": "Action not approved by user"}

    # Execute tool
    return execute_tool(tool_name, json.loads(tool_call.function.arguments))
```

---

## Tool Performance

### Monitoring

```python
import time

def track_tool_performance(tool_name):
    """Decorator to track tool performance."""
    def decorator(func):
        def wrapper(*args, **kwargs):
            start = time.time()
            try:
                result = func(*args, **kwargs)
                duration = time.time() - start

                # Log metrics
                log_metric(
                    tool=tool_name,
                    duration_ms=duration * 1000,
                    status="success"
                )

                return result
            except Exception as e:
                duration = time.time() - start
                log_metric(
                    tool=tool_name,
                    duration_ms=duration * 1000,
                    status="error",
                    error=str(e)
                )
                raise
        return wrapper
    return decorator

@track_tool_performance("get_weather")
def get_weather(location, units="celsius"):
    # Implementation
    pass
```

### Caching

```python
from functools import lru_cache

@lru_cache(maxsize=100)
def get_weather_cached(location, units):
    """Cache weather results for 5 minutes."""
    return get_weather_api(location, units)
```

---

## Tool Examples by Use Case

### Customer Support

```python
customer_support_tools = [
    {"type": "file_search"},  # Search knowledge base
    {
        "type": "function",
        "function": {
            "name": "lookup_order",
            "description": "Look up order details",
            "parameters": {...}
        }
    },
    {
        "type": "function",
        "function": {
            "name": "create_ticket",
            "description": "Create support ticket",
            "parameters": {...}
        }
    },
    {
        "type": "function",
        "function": {
            "name": "process_refund",
            "description": "Process a refund",
            "parameters": {...}
        }
    }
]
```

### Data Analysis

```python
data_analysis_tools = [
    {"type": "code_interpreter"},
    {
        "type": "function",
        "function": {
            "name": "query_database",
            "description": "Query SQL database",
            "parameters": {...}
        }
    },
    {
        "type": "function",
        "function": {
            "name": "fetch_api_data",
            "description": "Fetch data from API",
            "parameters": {...}
        }
    }
]
```

### Research Assistant

```python
research_tools = [
    {"type": "web_search_preview"},
    {"type": "file_search"},
    {
        "type": "function",
        "function": {
            "name": "query_knowledge_graph",
            "description": "Query knowledge graph",
            "parameters": {...}
        }
    },
    {
        "type": "function",
        "function": {
            "name": "fetch_academic_papers",
            "description": "Search academic papers",
            "parameters": {...}
        }
    }
]
```

---

## Additional Resources

- **Tools Documentation**: https://platform.openai.com/docs/guides/tools
- **MCP Guide**: https://platform.openai.com/docs/mcp
- **Code Interpreter**: https://platform.openai.com/docs/guides/tools-code-interpreter
- **File Search**: https://platform.openai.com/docs/guides/tools-file-search
- **Tool Examples**: https://cookbook.openai.com/examples/tools

---

**Next**: [Code Interpreter →](./code-interpreter.md)
