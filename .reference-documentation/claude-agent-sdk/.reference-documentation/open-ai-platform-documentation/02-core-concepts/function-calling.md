# OpenAI Platform - Function Calling

**Source:** https://platform.openai.com/docs/guides/function-calling
**Fetched:** 2025-10-11

## Overview

Function calling (also called tool use) allows models to intelligently call external functions and tools, enabling AI to interact with APIs, databases, and other systems.

---

## How It Works

1. **Define tools** with descriptions and parameters
2. **Model decides** when and which tool to call
3. **Extract arguments** from model response
4. **Execute function** in your code
5. **Return results** to model for final response

---

## Supported Models

- gpt-5 (all variants)
- gpt-4.1 (all variants)
- gpt-4o (all variants)
- gpt-4-turbo
- gpt-3.5-turbo
- o3, o3-mini, o4-mini (reasoning models)

---

## Quick Start

```python
from openai import OpenAI
import json

client = OpenAI()

# Define tools
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get the current weather for a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "City and state, e.g. San Francisco, CA"
                    },
                    "unit": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"],
                        "description": "Temperature unit"
                    }
                },
                "required": ["location"]
            }
        }
    }
]

# Call model
response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "What's the weather in Boston?"}],
    tools=tools,
    tool_choice="auto"
)

# Check if model wants to call a function
if response.choices[0].message.tool_calls:
    tool_call = response.choices[0].message.tool_calls[0]
    function_name = tool_call.function.name
    function_args = json.loads(tool_call.function.arguments)

    print(f"Function: {function_name}")
    print(f"Arguments: {function_args}")
    # Output: Function: get_weather
    # Output: Arguments: {'location': 'Boston, MA', 'unit': 'fahrenheit'}
```

---

## Defining Functions

### Basic Function Definition

```python
{
    "type": "function",
    "function": {
        "name": "function_name",
        "description": "Clear description of what the function does",
        "parameters": {
            "type": "object",
            "properties": {
                "param1": {
                    "type": "string",
                    "description": "Description of param1"
                },
                "param2": {
                    "type": "integer",
                    "description": "Description of param2"
                }
            },
            "required": ["param1"]
        }
    }
}
```

### With Strict Mode (Structured Outputs)

```python
{
    "type": "function",
    "function": {
        "name": "extract_data",
        "description": "Extract structured data",
        "strict": True,  # Enable structured outputs
        "parameters": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "age": {"type": "integer"}
            },
            "required": ["name", "age"],
            "additionalProperties": False
        }
    }
}
```

---

## Tool Choice Options

### auto (default)

Model decides whether to call a function:

```python
tool_choice="auto"
```

### none

Force model to NOT call any function:

```python
tool_choice="none"
```

### required

Force model to call at least one function:

```python
tool_choice="required"
```

### Specific Function

Force model to call a specific function:

```python
tool_choice={
    "type": "function",
    "function": {"name": "get_weather"}
}
```

---

## Complete Example

```python
import json
from openai import OpenAI

client = OpenAI()

# 1. Define functions
def get_weather(location, unit="fahrenheit"):
    """Actual function implementation."""
    # In production, call a real weather API
    return {
        "location": location,
        "temperature": 72,
        "unit": unit,
        "conditions": "sunny"
    }

# 2. Define tool schema
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
                        "description": "City and state, e.g. San Francisco, CA"
                    },
                    "unit": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"]
                    }
                },
                "required": ["location"]
            }
        }
    }
]

# 3. Initial conversation
messages = [
    {"role": "user", "content": "What's the weather like in Boston?"}
]

# 4. First API call
response = client.chat.completions.create(
    model="gpt-5",
    messages=messages,
    tools=tools,
    tool_choice="auto"
)

response_message = response.choices[0].message
messages.append(response_message)

# 5. Execute function if model requested it
if response_message.tool_calls:
    for tool_call in response_message.tool_calls:
        function_name = tool_call.function.name
        function_args = json.loads(tool_call.function.arguments)

        # Call actual function
        if function_name == "get_weather":
            function_response = get_weather(**function_args)

        # 6. Add function result to conversation
        messages.append({
            "role": "tool",
            "tool_call_id": tool_call.id,
            "content": json.dumps(function_response)
        })

    # 7. Get final response with function results
    final_response = client.chat.completions.create(
        model="gpt-5",
        messages=messages
    )

    print(final_response.choices[0].message.content)
    # Output: "The weather in Boston is currently sunny with a temperature of 72°F."
```

---

## Multiple Functions

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get current weather",
            "parameters": {...}
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_news",
            "description": "Get latest news",
            "parameters": {...}
        }
    },
    {
        "type": "function",
        "function": {
            "name": "search_restaurants",
            "description": "Search for restaurants",
            "parameters": {...}
        }
    }
]

response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "What's the weather and news in NYC?"}],
    tools=tools
)

# Model may call multiple functions
if response.choices[0].message.tool_calls:
    for tool_call in response.choices[0].message.tool_calls:
        print(f"Calling: {tool_call.function.name}")
```

---

## Common Use Cases

### 1. Database Queries

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "query_database",
            "description": "Query user database",
            "parameters": {
                "type": "object",
                "properties": {
                    "user_id": {
                        "type": "string",
                        "description": "User ID to query"
                    },
                    "fields": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Fields to retrieve"
                    }
                },
                "required": ["user_id"]
            }
        }
    }
]

def query_database(user_id, fields=None):
    # Query your database
    return db.users.find_one({"id": user_id}, projection=fields)
```

### 2. API Integration

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "send_email",
            "description": "Send an email",
            "parameters": {
                "type": "object",
                "properties": {
                    "to": {"type": "string", "description": "Recipient email"},
                    "subject": {"type": "string", "description": "Email subject"},
                    "body": {"type": "string", "description": "Email body"}
                },
                "required": ["to", "subject", "body"]
            }
        }
    }
]

def send_email(to, subject, body):
    # Call email API
    return email_service.send(to=to, subject=subject, body=body)
```

### 3. Calculations

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "calculate",
            "description": "Perform mathematical calculations",
            "parameters": {
                "type": "object",
                "properties": {
                    "expression": {
                        "type": "string",
                        "description": "Mathematical expression to evaluate"
                    }
                },
                "required": ["expression"]
            }
        }
    }
]

def calculate(expression):
    # Safely evaluate mathematical expression
    import ast
    import operator

    ops = {
        ast.Add: operator.add,
        ast.Sub: operator.sub,
        ast.Mult: operator.mul,
        ast.Div: operator.truediv
    }

    return eval_expr(ast.parse(expression, mode='eval').body, ops)
```

### 4. Web Search

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "web_search",
            "description": "Search the web for information",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Search query"
                    },
                    "num_results": {
                        "type": "integer",
                        "description": "Number of results to return"
                    }
                },
                "required": ["query"]
            }
        }
    }
]

def web_search(query, num_results=5):
    # Call search API
    return search_api.search(query, limit=num_results)
```

---

## Parallel Function Calls

Model can call multiple functions in parallel:

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Get weather in NYC and LA, and latest tech news"}
    ],
    tools=tools
)

# Process all tool calls
tool_calls = response.choices[0].message.tool_calls

for tool_call in tool_calls:
    function_name = tool_call.function.name
    function_args = json.loads(tool_call.function.arguments)

    # Execute functions in parallel (async)
    if function_name == "get_weather":
        result = get_weather(**function_args)
    elif function_name == "get_news":
        result = get_news(**function_args)

    messages.append({
        "role": "tool",
        "tool_call_id": tool_call.id,
        "content": json.dumps(result)
    })
```

---

## Best Practices

### 1. Clear Function Descriptions

**Bad**:
```python
"description": "Get data"
```

**Good**:
```python
"description": "Get current weather conditions including temperature, humidity, and conditions for a specific location"
```

### 2. Descriptive Parameter Names

**Bad**:
```python
"properties": {
    "loc": {"type": "string"},
    "u": {"type": "string"}
}
```

**Good**:
```python
"properties": {
    "location": {
        "type": "string",
        "description": "City and state (e.g., 'Boston, MA')"
    },
    "unit": {
        "type": "string",
        "enum": ["celsius", "fahrenheit"],
        "description": "Temperature unit"
    }
}
```

### 3. Use Enums for Constrained Values

```python
"unit": {
    "type": "string",
    "enum": ["celsius", "fahrenheit", "kelvin"]
}
```

### 4. Validate Function Arguments

```python
def get_weather(location, unit="fahrenheit"):
    # Validate arguments
    if not location:
        raise ValueError("location is required")

    if unit not in ["celsius", "fahrenheit"]:
        raise ValueError("unit must be celsius or fahrenheit")

    # Execute function
    return weather_api.get(location, unit)
```

### 5. Handle Errors Gracefully

```python
try:
    result = get_weather(**function_args)
except Exception as e:
    result = {
        "error": str(e),
        "message": "Failed to get weather data"
    }

messages.append({
    "role": "tool",
    "tool_call_id": tool_call.id,
    "content": json.dumps(result)
})
```

### 6. Keep Functions Focused

**Bad** - one function does too much:
```python
def handle_user_request(action, user_id, data):
    # Too generic
    pass
```

**Good** - separate, focused functions:
```python
def get_user(user_id):
    pass

def update_user(user_id, data):
    pass

def delete_user(user_id):
    pass
```

---

## Advanced Patterns

### 1. Function Chaining

```python
def chat_with_functions(messages, tools, max_iterations=5):
    """Allow model to chain multiple function calls."""
    for i in range(max_iterations):
        response = client.chat.completions.create(
            model="gpt-5",
            messages=messages,
            tools=tools
        )

        response_message = response.choices[0].message
        messages.append(response_message)

        # If no tool calls, we're done
        if not response_message.tool_calls:
            return response_message.content

        # Execute all tool calls
        for tool_call in response_message.tool_calls:
            function_name = tool_call.function.name
            function_args = json.loads(tool_call.function.arguments)

            # Route to appropriate function
            result = execute_function(function_name, function_args)

            messages.append({
                "role": "tool",
                "tool_call_id": tool_call.id,
                "content": json.dumps(result)
            })

    return "Max iterations reached"
```

### 2. Conditional Tool Availability

```python
def get_available_tools(user_permissions):
    """Only show tools user has permission to use."""
    all_tools = [weather_tool, email_tool, database_tool, admin_tool]

    available_tools = []
    for tool in all_tools:
        if has_permission(user_permissions, tool):
            available_tools.append(tool)

    return available_tools

# Use in API call
tools = get_available_tools(current_user.permissions)
response = client.chat.completions.create(
    model="gpt-5",
    messages=messages,
    tools=tools
)
```

### 3. Async Function Execution

```python
import asyncio

async def execute_functions_async(tool_calls):
    """Execute multiple functions in parallel."""
    tasks = []

    for tool_call in tool_calls:
        function_name = tool_call.function.name
        function_args = json.loads(tool_call.function.arguments)

        # Create async task for each function
        task = asyncio.create_task(
            call_function_async(function_name, function_args)
        )
        tasks.append((tool_call.id, task))

    # Wait for all to complete
    results = []
    for tool_call_id, task in tasks:
        result = await task
        results.append({
            "tool_call_id": tool_call_id,
            "result": result
        })

    return results
```

### 4. Function Result Caching

```python
from functools import lru_cache
import hashlib

@lru_cache(maxsize=100)
def cached_function_call(function_name, args_hash):
    """Cache function results to avoid redundant calls."""
    args = json.loads(args_hash)
    return execute_function(function_name, args)

def call_with_cache(function_name, function_args):
    args_hash = hashlib.md5(
        json.dumps(function_args, sort_keys=True).encode()
    ).hexdigest()

    return cached_function_call(function_name, args_hash)
```

---

## Debugging

### Log Function Calls

```python
def log_function_call(tool_call):
    """Log all function calls for debugging."""
    print(f"""
    Function Call:
    - Name: {tool_call.function.name}
    - Arguments: {tool_call.function.arguments}
    - Call ID: {tool_call.id}
    """)

if response.choices[0].message.tool_calls:
    for tool_call in response.choices[0].message.tool_calls:
        log_function_call(tool_call)
```

### Validate Arguments

```python
import jsonschema

def validate_function_args(function_schema, args):
    """Validate args against function schema."""
    try:
        jsonschema.validate(instance=args, schema=function_schema)
        return True
    except jsonschema.exceptions.ValidationError as e:
        print(f"Validation error: {e}")
        return False
```

---

## Limitations

### Per-Request Limits

- **Tools**: Up to 128 functions per request
- **Tool calls**: Model typically makes 1-5 calls per response
- **Arguments**: Up to 100,000 characters per function call

### Best Configurations

✅ **< 100 tools**: In-distribution, reliable
✅ **< 20 arguments per tool**: Best performance
⚠️ **> 100 tools**: May decrease reliability
⚠️ **> 20 arguments**: May miss parameters

---

## Migration from Legacy Format

**Old (deprecated)**:
```python
functions = [...]
function_call = "auto"
```

**New**:
```python
tools = [
    {"type": "function", "function": {...}}
]
tool_choice = "auto"
```

---

## Additional Resources

- **Function Calling Guide**: https://platform.openai.com/docs/guides/function-calling
- **API Reference**: https://platform.openai.com/docs/api-reference/chat/create
- **Cookbook Examples**: https://cookbook.openai.com/examples/function_calling
- **O-series Guide**: https://cookbook.openai.com/examples/o-series/o3o4-mini_prompting_guide

---

**Next**: [Using GPT-5 →](./using-gpt-5.md)
