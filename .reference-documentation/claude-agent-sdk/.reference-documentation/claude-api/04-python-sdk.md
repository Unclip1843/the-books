# Claude API - Python SDK Reference

**Source:** https://github.com/anthropics/anthropic-sdk-python
**Fetched:** 2025-10-11

## Installation

```bash
pip install anthropic
```

**Requirements:**
- Python 3.8 or higher

**Optional dependencies:**
```bash
# For AWS Bedrock support
pip install anthropic[bedrock]

# For Google Vertex AI support
pip install anthropic[vertex]
```

## Quick Start

```python
import anthropic
import os

client = anthropic.Anthropic(
    api_key=os.environ.get("ANTHROPIC_API_KEY")
)

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Hello, Claude"}
    ]
)

print(message.content[0].text)
```

## Client Initialization

### Basic Client

```python
from anthropic import Anthropic

# From environment variable
client = Anthropic()  # Uses ANTHROPIC_API_KEY env var

# Explicit API key
client = Anthropic(api_key="your-api-key")

# Custom configuration
client = Anthropic(
    api_key="your-api-key",
    base_url="https://api.anthropic.com",  # Custom base URL
    timeout=60.0,  # Request timeout in seconds
    max_retries=2,  # Number of retries
)
```

### Async Client

```python
from anthropic import AsyncAnthropic
import asyncio

async def main():
    client = AsyncAnthropic()

    message = await client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{"role": "user", "content": "Hello"}]
    )

    print(message.content[0].text)

asyncio.run(main())
```

## Messages API

### Creating Messages

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "What is the capital of France?"}
    ]
)

print(message.content[0].text)  # "The capital of France is Paris."
print(message.usage)  # Token usage stats
```

### With System Prompt

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    system="You are a helpful assistant that speaks like Shakespeare",
    messages=[
        {"role": "user", "content": "Hello, how are you?"}
    ]
)
```

### Multi-Turn Conversation

```python
messages = []

# First turn
messages.append({"role": "user", "content": "What's 2+2?"})
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=messages
)
messages.append({"role": "assistant", "content": response.content[0].text})

# Second turn
messages.append({"role": "user", "content": "And 3+3?"})
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=messages
)
```

### With Temperature

```python
# More deterministic
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    temperature=0.0,  # Range: 0.0 to 1.0
    messages=[{"role": "user", "content": "Count to 10"}]
)

# More creative
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    temperature=1.0,
    messages=[{"role": "user", "content": "Write a creative story"}]
)
```

## Streaming

### Basic Streaming

```python
with client.messages.stream(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Write a story"}],
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

### Streaming with Event Handling

```python
with client.messages.stream(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}],
) as stream:
    for event in stream:
        if event.type == "content_block_delta":
            print(event.delta.text, end="", flush=True)
```

### Async Streaming

```python
async def stream_example():
    client = AsyncAnthropic()

    async with client.messages.stream(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{"role": "user", "content": "Write a story"}],
    ) as stream:
        async for text in stream.text_stream:
            print(text, end="", flush=True)

asyncio.run(stream_example())
```

### Stream Helpers

```python
with client.messages.stream(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}],
) as stream:
    # Get final message
    message = stream.get_final_message()
    print(message.content[0].text)

    # Get accumulated text
    for text in stream.text_stream:
        accumulated_text = stream.current_message_snapshot.content[0].text
```

### Manual Streaming

```python
stream = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}],
    stream=True
)

for event in stream:
    if event.type == "message_start":
        print("Message started")
    elif event.type == "content_block_start":
        print("Content block started")
    elif event.type == "content_block_delta":
        print(event.delta.text, end="", flush=True)
    elif event.type == "content_block_stop":
        print("\nContent block stopped")
    elif event.type == "message_stop":
        print("Message stopped")
```

## Vision (Images)

### Base64 Image

```python
import base64

with open("image.jpg", "rb") as image_file:
    image_data = base64.standard_b64encode(image_file.read()).decode("utf-8")

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "What's in this image?"
                },
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/jpeg",
                        "data": image_data,
                    },
                },
            ],
        }
    ],
)

print(message.content[0].text)
```

### Image URL

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Describe this image"},
                {
                    "type": "image",
                    "source": {
                        "type": "url",
                        "url": "https://example.com/image.jpg",
                    },
                },
            ],
        }
    ],
)
```

### Multiple Images

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Compare these images"},
                {
                    "type": "image",
                    "source": {"type": "url", "url": "https://example.com/image1.jpg"},
                },
                {
                    "type": "image",
                    "source": {"type": "url", "url": "https://example.com/image2.jpg"},
                },
            ],
        }
    ],
)
```

## Tool Use (Function Calling)

### Defining Tools

```python
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

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "What's the weather in San Francisco?"}]
)
```

### Handling Tool Use

```python
def process_tool_call(tool_name, tool_input):
    if tool_name == "get_weather":
        # Call your actual weather API
        return {
            "location": tool_input["location"],
            "temperature": "72°F",
            "condition": "Sunny"
        }

# Initial request
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "What's the weather in SF?"}]
)

# Check if Claude wants to use a tool
if response.stop_reason == "tool_use":
    # Extract tool use
    tool_use = next(block for block in response.content if block.type == "tool_use")
    tool_name = tool_use.name
    tool_input = tool_use.input

    # Execute tool
    tool_result = process_tool_call(tool_name, tool_input)

    # Send result back to Claude
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

    print(response.content[0].text)
```

## Prompt Caching

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": "You are an AI assistant with expertise in...",
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=[{"role": "user", "content": "Hello"}]
)

# Check cache usage
print(f"Cache creation tokens: {message.usage.cache_creation_input_tokens}")
print(f"Cache read tokens: {message.usage.cache_read_input_tokens}")
print(f"Input tokens: {message.usage.input_tokens}")
```

## Error Handling

```python
from anthropic import (
    APIError,
    APIConnectionError,
    APIStatusError,
    RateLimitError,
    AuthenticationError,
)

try:
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{"role": "user", "content": "Hello"}]
    )
except AuthenticationError as e:
    print(f"Authentication failed: {e}")
except RateLimitError as e:
    print(f"Rate limit exceeded: {e}")
    # Implement retry logic
except APIConnectionError as e:
    print(f"Connection error: {e}")
except APIStatusError as e:
    print(f"API error {e.status_code}: {e.response}")
except APIError as e:
    print(f"General API error: {e}")
```

## Retries and Timeouts

### Custom Timeouts

```python
client = Anthropic(
    timeout=30.0,  # 30 seconds
)

# Or per-request
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}],
    timeout=60.0
)
```

### Custom Retries

```python
from anthropic import Anthropic
import httpx

client = Anthropic(
    max_retries=3,
    http_client=httpx.Client(
        timeout=httpx.Timeout(60.0, connect=5.0),
    ),
)
```

### Manual Retry Logic

```python
import time

max_retries = 3
for attempt in range(max_retries):
    try:
        message = client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=1024,
            messages=[{"role": "user", "content": "Hello"}]
        )
        break
    except RateLimitError:
        if attempt < max_retries - 1:
            sleep_time = 2 ** attempt  # Exponential backoff
            print(f"Rate limited. Retrying in {sleep_time}s...")
            time.sleep(sleep_time)
        else:
            raise
```

## AWS Bedrock

```python
from anthropic import AnthropicBedrock

client = AnthropicBedrock(
    aws_access_key="your-access-key",
    aws_secret_key="your-secret-key",
    aws_region="us-east-1",
)

message = client.messages.create(
    model="anthropic.claude-sonnet-4-5-v2:0",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}]
)
```

## Google Vertex AI

```python
from anthropic import AnthropicVertex

client = AnthropicVertex(
    project_id="your-project-id",
    region="us-central1",
)

message = client.messages.create(
    model="claude-sonnet-4-5@20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}]
)
```

## Response Types

### Message Object

```python
message = client.messages.create(...)

print(message.id)  # "msg_01..."
print(message.type)  # "message"
print(message.role)  # "assistant"
print(message.content)  # List of content blocks
print(message.model)  # "claude-sonnet-4-5-20250929"
print(message.stop_reason)  # "end_turn", "max_tokens", etc.
print(message.usage.input_tokens)  # Token count
print(message.usage.output_tokens)  # Token count
```

### Content Blocks

```python
for block in message.content:
    if block.type == "text":
        print(block.text)
    elif block.type == "tool_use":
        print(f"Tool: {block.name}")
        print(f"Input: {block.input}")
```

## Best Practices

### 1. Use Context Managers for Streaming

```python
# Good
with client.messages.stream(...) as stream:
    for text in stream.text_stream:
        print(text, end="")

# Also good for async
async with client.messages.stream(...) as stream:
    async for text in stream.text_stream:
        print(text, end="")
```

### 2. Handle Errors Gracefully

```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10)
)
def create_message(prompt):
    return client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}]
    )
```

### 3. Use Async for Concurrent Requests

```python
import asyncio

async def process_prompts(prompts):
    client = AsyncAnthropic()

    tasks = [
        client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=1024,
            messages=[{"role": "user", "content": prompt}]
        )
        for prompt in prompts
    ]

    results = await asyncio.gather(*tasks)
    return results

prompts = ["Hello", "Tell me a joke", "What's 2+2?"]
results = asyncio.run(process_prompts(prompts))
```

### 4. Monitor Token Usage

```python
def create_with_monitoring(prompt):
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}]
    )

    print(f"Input tokens: {message.usage.input_tokens}")
    print(f"Output tokens: {message.usage.output_tokens}")
    print(f"Total tokens: {message.usage.input_tokens + message.usage.output_tokens}")

    return message
```

## Complete Example

```python
import anthropic
import os
import base64

class ClaudeAssistant:
    def __init__(self):
        self.client = anthropic.Anthropic(
            api_key=os.environ.get("ANTHROPIC_API_KEY")
        )
        self.conversation = []

    def send_message(self, content):
        """Send a text message"""
        self.conversation.append({"role": "user", "content": content})

        response = self.client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            messages=self.conversation
        )

        assistant_message = response.content[0].text
        self.conversation.append({
            "role": "assistant",
            "content": assistant_message
        })

        return assistant_message

    def send_image(self, image_path, question):
        """Send an image with a question"""
        with open(image_path, "rb") as img:
            image_data = base64.standard_b64encode(img.read()).decode()

        message_content = [
            {"type": "text", "text": question},
            {
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": image_data
                }
            }
        ]

        self.conversation.append({"role": "user", "content": message_content})

        response = self.client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            messages=self.conversation
        )

        assistant_message = response.content[0].text
        self.conversation.append({
            "role": "assistant",
            "content": assistant_message
        })

        return assistant_message

    def stream_response(self, content):
        """Stream a response"""
        self.conversation.append({"role": "user", "content": content})

        full_response = ""
        with self.client.messages.stream(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            messages=self.conversation
        ) as stream:
            for text in stream.text_stream:
                print(text, end="", flush=True)
                full_response += text

        print()  # New line

        self.conversation.append({
            "role": "assistant",
            "content": full_response
        })

        return full_response

# Usage
assistant = ClaudeAssistant()
response = assistant.send_message("Hello, Claude!")
print(response)

response = assistant.stream_response("Tell me a short story")
```

## Related Documentation

- [Getting Started](./02-getting-started.md)
- [Messages API Reference](./03-messages-api.md)
- [TypeScript SDK](./05-typescript-sdk.md)
- [Streaming Guide](./06-streaming.md)
- [Vision Guide](./07-vision.md)
- [Tool Use Guide](./08-tool-use.md)
- [Prompt Caching Guide](./09-prompt-caching.md)
