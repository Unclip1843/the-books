# OpenAI Platform - Custom Tools

**Source:** https://platform.openai.com/docs/guides/tools-custom
**Fetched:** 2025-10-11

## Overview

Custom tools allow you to extend agent capabilities by defining your own functions. Agents can call these functions to perform specific tasks, access external APIs, query databases, or execute any custom logic.

**Key Concepts:**
- Tool definition with JSON schema
- Function parameters and types
- Tool execution and results
- Error handling
- Best practices for tool design

---

## Defining Custom Tools

### Basic Tool Definition

```python
from openai import OpenAI

client = OpenAI()

# Define tool
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

# Use tool
response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "What's the weather in Tokyo?"}
    ],
    tools=tools
)
```

### Tool Components

**Required Fields:**
- `type`: Always "function"
- `function.name`: Function identifier
- `function.description`: What the function does
- `function.parameters`: JSON schema for parameters

**Optional Fields:**
- `function.strict`: Enable strict schema validation
- Parameter descriptions
- Default values
- Enum constraints

---

## Parameter Types

### String Parameters

```python
{
    "name": "search_products",
    "description": "Search for products",
    "parameters": {
        "type": "object",
        "properties": {
            "query": {
                "type": "string",
                "description": "Search query"
            },
            "category": {
                "type": "string",
                "enum": ["electronics", "clothing", "books"],
                "description": "Product category"
            }
        },
        "required": ["query"]
    }
}
```

### Number Parameters

```python
{
    "name": "calculate_discount",
    "description": "Calculate discounted price",
    "parameters": {
        "type": "object",
        "properties": {
            "price": {
                "type": "number",
                "description": "Original price"
            },
            "discount_percent": {
                "type": "number",
                "minimum": 0,
                "maximum": 100,
                "description": "Discount percentage (0-100)"
            }
        },
        "required": ["price", "discount_percent"]
    }
}
```

### Boolean Parameters

```python
{
    "name": "create_account",
    "description": "Create a new user account",
    "parameters": {
        "type": "object",
        "properties": {
            "username": {
                "type": "string"
            },
            "send_welcome_email": {
                "type": "boolean",
                "description": "Whether to send welcome email",
                "default": true
            }
        },
        "required": ["username"]
    }
}
```

### Array Parameters

```python
{
    "name": "bulk_update",
    "description": "Update multiple items",
    "parameters": {
        "type": "object",
        "properties": {
            "item_ids": {
                "type": "array",
                "items": {"type": "string"},
                "description": "List of item IDs to update"
            },
            "tags": {
                "type": "array",
                "items": {"type": "string"},
                "description": "Tags to add"
            }
        },
        "required": ["item_ids"]
    }
}
```

### Object Parameters

```python
{
    "name": "create_event",
    "description": "Create calendar event",
    "parameters": {
        "type": "object",
        "properties": {
            "title": {"type": "string"},
            "details": {
                "type": "object",
                "properties": {
                    "location": {"type": "string"},
                    "attendees": {
                        "type": "array",
                        "items": {"type": "string"}
                    },
                    "reminder_minutes": {"type": "integer"}
                }
            }
        },
        "required": ["title"]
    }
}
```

---

## Executing Tools

### Basic Tool Execution

```python
def get_weather(location, units="celsius"):
    """Fetch weather data."""
    # Your implementation
    weather_api_url = f"https://api.weather.com/current?location={location}&units={units}"
    response = requests.get(weather_api_url)
    return response.json()

# Get response
response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "What's the weather in Tokyo?"}],
    tools=tools
)

# Handle tool calls
if response.tool_calls:
    for tool_call in response.tool_calls:
        # Parse arguments
        args = json.loads(tool_call.function.arguments)

        # Execute function
        if tool_call.function.name == "get_weather":
            result = get_weather(args["location"], args.get("units", "celsius"))

            # Submit result
            messages = [
                {"role": "user", "content": "What's the weather in Tokyo?"},
                response.choices[0].message,
                {
                    "role": "tool",
                    "tool_call_id": tool_call.id,
                    "content": json.dumps(result)
                }
            ]

            # Get final response
            final_response = client.responses.create(
                model="gpt-5",
                messages=messages,
                tools=tools
            )

            print(final_response.choices[0].message.content)
```

### Tool Execution Loop

```python
def execute_tool_loop(initial_message, tools, tool_implementations):
    """Execute agent with tool calling loop."""
    messages = [initial_message]

    while True:
        response = client.responses.create(
            model="gpt-5",
            messages=messages,
            tools=tools
        )

        # Add assistant message
        messages.append(response.choices[0].message)

        # Check for tool calls
        if not response.tool_calls:
            # No more tool calls, return final answer
            return response.choices[0].message.content

        # Execute all tool calls
        for tool_call in response.tool_calls:
            func_name = tool_call.function.name
            args = json.loads(tool_call.function.arguments)

            # Execute function
            func = tool_implementations[func_name]
            result = func(**args)

            # Add tool result
            messages.append({
                "role": "tool",
                "tool_call_id": tool_call.id,
                "content": json.dumps(result)
            })

# Usage
tool_implementations = {
    "get_weather": get_weather,
    "search_products": search_products,
    "create_order": create_order
}

answer = execute_tool_loop(
    initial_message={"role": "user", "content": "What's the weather and can I order an umbrella?"},
    tools=tools,
    tool_implementations=tool_implementations
)
```

---

## Error Handling

### Tool Execution Errors

```python
def execute_tool_safely(tool_call):
    """Execute tool with error handling."""
    try:
        func_name = tool_call.function.name
        args = json.loads(tool_call.function.arguments)

        # Validate arguments
        validate_args(func_name, args)

        # Execute
        result = tool_implementations[func_name](**args)

        return {
            "role": "tool",
            "tool_call_id": tool_call.id,
            "content": json.dumps({"success": True, "data": result})
        }

    except ValidationError as e:
        return {
            "role": "tool",
            "tool_call_id": tool_call.id,
            "content": json.dumps({
                "success": False,
                "error": "validation_error",
                "message": str(e)
            })
        }

    except Exception as e:
        return {
            "role": "tool",
            "tool_call_id": tool_call.id,
            "content": json.dumps({
                "success": False,
                "error": "execution_error",
                "message": str(e)
            })
        }
```

### Timeouts

```python
import signal
from contextlib import contextmanager

@contextmanager
def timeout(seconds):
    """Context manager for function timeouts."""
    def timeout_handler(signum, frame):
        raise TimeoutError(f"Function exceeded {seconds} second timeout")

    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(seconds)
    try:
        yield
    finally:
        signal.alarm(0)

def execute_with_timeout(func, args, timeout_seconds=30):
    """Execute function with timeout."""
    try:
        with timeout(timeout_seconds):
            return func(**args)
    except TimeoutError as e:
        return {"error": str(e)}
```

### Retries

```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10)
)
def execute_tool_with_retry(tool_call):
    """Execute tool with automatic retries."""
    func_name = tool_call.function.name
    args = json.loads(tool_call.function.arguments)

    return tool_implementations[func_name](**args)
```

---

## Advanced Patterns

### Conditional Tool Availability

```python
def get_available_tools(user):
    """Return tools based on user permissions."""
    tools = []

    # Basic tools for everyone
    tools.append(search_tool)
    tools.append(get_info_tool)

    # Premium tools
    if user.is_premium:
        tools.append(advanced_search_tool)
        tools.append(export_tool)

    # Admin tools
    if user.is_admin:
        tools.append(delete_tool)
        tools.append(modify_tool)

    return tools

# Use in request
available_tools = get_available_tools(current_user)

response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Help me"}],
    tools=available_tools
)
```

### Tool Chaining

```python
# Tools that call other tools
def complex_workflow(step1_result):
    """Multi-step workflow using multiple tools."""

    # Step 1: Search
    search_results = search_tool(**step1_result)

    # Step 2: Filter
    filtered = filter_tool(search_results)

    # Step 3: Process
    processed = process_tool(filtered)

    return processed

# Define as tool
tools = [
    {
        "type": "function",
        "function": {
            "name": "complex_workflow",
            "description": "Execute multi-step workflow",
            "parameters": {...}
        }
    }
]
```

### Dynamic Tool Generation

```python
def generate_tool_for_api(api_spec):
    """Generate tool definition from API spec."""
    return {
        "type": "function",
        "function": {
            "name": api_spec["operationId"],
            "description": api_spec["summary"],
            "parameters": {
                "type": "object",
                "properties": {
                    param["name"]: {
                        "type": param["schema"]["type"],
                        "description": param.get("description", "")
                    }
                    for param in api_spec["parameters"]
                },
                "required": [
                    param["name"]
                    for param in api_spec["parameters"]
                    if param.get("required", False)
                ]
            }
        }
    }

# Generate tools from OpenAPI spec
openapi_spec = load_openapi_spec("api-spec.yaml")
tools = [
    generate_tool_for_api(endpoint)
    for endpoint in openapi_spec["paths"].values()
]
```

---

## Tool Design Best Practices

### 1. Clear Descriptions

```python
# ✅ Good: Detailed description
{
    "name": "create_calendar_event",
    "description": """
Create a new calendar event with specified title, date, time, and optional details.
The event will be created in the user's primary calendar.
Time should be in ISO 8601 format (YYYY-MM-DDTHH:MM:SS).
Returns the created event ID.
""",
    "parameters": {...}
}

# ❌ Bad: Vague description
{
    "name": "create_event",
    "description": "Creates an event",
    "parameters": {...}
}
```

### 2. Descriptive Parameter Names

```python
# ✅ Good: Clear parameter names
{
    "parameters": {
        "type": "object",
        "properties": {
            "customer_email": {
                "type": "string",
                "description": "Customer's email address for sending confirmation"
            },
            "order_id": {
                "type": "string",
                "description": "Unique order identifier"
            }
        }
    }
}

# ❌ Bad: Ambiguous names
{
    "parameters": {
        "type": "object",
        "properties": {
            "email": {"type": "string"},
            "id": {"type": "string"}
        }
    }
}
```

### 3. Use Enums for Fixed Choices

```python
# ✅ Good: Enum constraints
{
    "status": {
        "type": "string",
        "enum": ["pending", "approved", "rejected"],
        "description": "Order status"
    }
}

# ❌ Bad: Free-form string
{
    "status": {
        "type": "string",
        "description": "Order status (pending/approved/rejected)"
    }
}
```

### 4. Provide Defaults

```python
{
    "page_size": {
        "type": "integer",
        "description": "Number of results per page",
        "default": 10,
        "minimum": 1,
        "maximum": 100
    }
}
```

### 5. Validate Inputs

```python
def validate_email(email):
    """Validate email format."""
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(pattern, email):
        raise ValueError(f"Invalid email: {email}")

def create_account(email, username):
    """Create account with validation."""
    validate_email(email)

    if len(username) < 3:
        raise ValueError("Username must be at least 3 characters")

    # Create account
    ...
```

### 6. Return Structured Data

```python
# ✅ Good: Structured response
def get_order_status(order_id):
    return {
        "order_id": order_id,
        "status": "shipped",
        "tracking_number": "1Z999AA1234567890",
        "estimated_delivery": "2025-10-15",
        "items_count": 3
    }

# ❌ Bad: Unstructured response
def get_order_status(order_id):
    return "Order 12345 is shipped, tracking: 1Z999AA1234567890"
```

---

## Security Considerations

### Input Sanitization

```python
import html

def sanitize_input(data):
    """Sanitize user input."""
    if isinstance(data, str):
        # Remove HTML tags
        data = html.escape(data)

        # Limit length
        if len(data) > 10000:
            data = data[:10000]

    return data

def safe_tool_execution(tool_call):
    """Execute tool with sanitized inputs."""
    args = json.loads(tool_call.function.arguments)

    # Sanitize all string arguments
    sanitized_args = {
        key: sanitize_input(value)
        for key, value in args.items()
    }

    return tool_implementations[tool_call.function.name](**sanitized_args)
```

### Permission Checks

```python
def check_permissions(user, tool_name, args):
    """Check if user has permission to use tool."""
    # Check tool access
    if tool_name in ADMIN_ONLY_TOOLS and not user.is_admin:
        raise PermissionError(f"User {user.id} cannot access {tool_name}")

    # Check resource access
    if "user_id" in args and args["user_id"] != user.id:
        if not user.has_permission("access_other_users"):
            raise PermissionError("Cannot access other users' data")

    return True

def execute_tool_with_permissions(tool_call, user):
    """Execute tool with permission checks."""
    func_name = tool_call.function.name
    args = json.loads(tool_call.function.arguments)

    # Check permissions
    check_permissions(user, func_name, args)

    # Execute
    return tool_implementations[func_name](**args)
```

### Rate Limiting

```python
from collections import defaultdict
import time

tool_calls_per_user = defaultdict(list)

def rate_limit_tool(user_id, tool_name, max_calls=10, window=60):
    """Rate limit tool calls per user."""
    now = time.time()
    key = f"{user_id}:{tool_name}"

    # Remove old calls
    tool_calls_per_user[key] = [
        call_time for call_time in tool_calls_per_user[key]
        if now - call_time < window
    ]

    # Check limit
    if len(tool_calls_per_user[key]) >= max_calls:
        raise RateLimitError(f"Rate limit exceeded for {tool_name}")

    # Record call
    tool_calls_per_user[key].append(now)
```

---

## Testing Tools

### Unit Tests

```python
import pytest

def test_get_weather():
    """Test weather tool."""
    result = get_weather("Tokyo", "celsius")

    assert "temperature" in result
    assert "condition" in result
    assert isinstance(result["temperature"], (int, float))

def test_get_weather_invalid_location():
    """Test error handling."""
    with pytest.raises(ValueError):
        get_weather("Invalid City XYZ", "celsius")

def test_create_order():
    """Test order creation."""
    result = create_order(
        product_id="prod_123",
        quantity=2,
        customer_email="test@example.com"
    )

    assert result["success"] == True
    assert "order_id" in result
```

### Integration Tests

```python
def test_tool_integration():
    """Test tool with OpenAI API."""
    response = client.responses.create(
        model="gpt-5",
        messages=[
            {"role": "user", "content": "What's the weather in Tokyo?"}
        ],
        tools=[weather_tool]
    )

    # Should call weather tool
    assert response.tool_calls
    assert response.tool_calls[0].function.name == "get_weather"

    # Execute tool
    tool_call = response.tool_calls[0]
    args = json.loads(tool_call.function.arguments)
    result = get_weather(**args)

    # Should return valid weather data
    assert "temperature" in result
```

---

## Additional Resources

- **Function Calling Guide**: https://platform.openai.com/docs/guides/function-calling
- **Tool Examples**: https://cookbook.openai.com/examples/tools
- **JSON Schema Reference**: https://json-schema.org/

---

**Next**: [Tool Examples →](./tool-examples.md)
