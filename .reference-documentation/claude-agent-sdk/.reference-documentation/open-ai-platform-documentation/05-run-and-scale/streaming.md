# OpenAI Platform - Streaming Responses

**Source:** https://platform.openai.com/docs/guides/streaming-responses
**Fetched:** 2025-10-11

## Overview

Streaming allows you to receive model outputs token-by-token as they're generated, rather than waiting for the complete response. This significantly improves perceived latency and user experience, especially for long-form content.

**Benefits:**
- ⚡ Faster time-to-first-token
- 📝 Real-time text display (like ChatGPT)
- 🎯 Better user experience
- 🔄 Can cancel mid-generation
- 📊 Progressive rendering

---

## How Streaming Works

### Default (Non-Streaming)

```python
# Without streaming: wait for entire response
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Write a story"}]
)

# Waits 10+ seconds, then prints entire story at once
print(response.choices[0].message.content)
```

**Timeline:**
```
Request → [Waiting 10s...] → Complete response arrives
```

### With Streaming

```python
# With streaming: receive tokens as generated
stream = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Write a story"}],
    stream=True  # Enable streaming
)

# Prints tokens as they arrive
for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)
```

**Timeline:**
```
Request → First token (0.5s) → Token 2 (0.6s) → Token 3 (0.7s) → ...
```

---

## Basic Streaming

### Python Example

```python
from openai import OpenAI

client = OpenAI()

def stream_chat(message):
    """Stream chat response."""
    stream = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": message}],
        stream=True
    )

    print("Assistant: ", end="")
    for chunk in stream:
        if chunk.choices[0].delta.content:
            print(chunk.choices[0].delta.content, end="", flush=True)
    print()  # New line at end

# Usage
stream_chat("Explain quantum computing in simple terms")
```

### TypeScript Example

```typescript
import OpenAI from 'openai';

const client = new OpenAI();

async function streamChat(message: string) {
  const stream = await client.chat.completions.create({
    model: 'gpt-4o',
    messages: [{ role: 'user', content: message }],
    stream: true,
  });

  process.stdout.write('Assistant: ');
  for await (const chunk of stream) {
    if (chunk.choices[0]?.delta?.content) {
      process.stdout.write(chunk.choices[0].delta.content);
    }
  }
  process.stdout.write('\n');
}

// Usage
await streamChat('Explain quantum computing in simple terms');
```

---

## Stream Event Format

### Event Structure

```python
{
    "id": "chatcmpl-abc123",
    "object": "chat.completion.chunk",
    "created": 1728691200,
    "model": "gpt-4o-2024-08-06",
    "choices": [
        {
            "index": 0,
            "delta": {
                "role": "assistant",  # First chunk only
                "content": "Hello"    # Token content
            },
            "finish_reason": null
        }
    ]
}
```

### Event Types

**First Event (role):**
```python
{
    "delta": {
        "role": "assistant"
    },
    "finish_reason": null
}
```

**Content Events (tokens):**
```python
{
    "delta": {
        "content": " world"
    },
    "finish_reason": null
}
```

**Final Event (completion):**
```python
{
    "delta": {},
    "finish_reason": "stop"  # or "length", "tool_calls", etc.
}
```

---

## Advanced Streaming

### Complete Message Assembly

```python
from openai import OpenAI

client = OpenAI()

def stream_and_collect(message):
    """Stream response and collect full message."""
    stream = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": message}],
        stream=True
    )

    full_content = ""
    print("Assistant: ", end="")

    for chunk in stream:
        delta = chunk.choices[0].delta

        # Collect content
        if delta.content:
            content = delta.content
            full_content += content
            print(content, end="", flush=True)

        # Check if done
        if chunk.choices[0].finish_reason:
            print(f"\n[Finish reason: {chunk.choices[0].finish_reason}]")

    return full_content

# Usage
full_response = stream_and_collect("Write a haiku")
print(f"\nFull response: {full_response}")
```

### With Token Counting

```python
import tiktoken

def stream_with_metrics(message):
    """Stream with real-time metrics."""
    stream = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": message}],
        stream=True
    )

    encoding = tiktoken.encoding_for_model("gpt-4o")
    full_content = ""
    token_count = 0
    start_time = time.time()

    for chunk in stream:
        if chunk.choices[0].delta.content:
            content = chunk.choices[0].delta.content
            full_content += content
            token_count += len(encoding.encode(content))
            print(content, end="", flush=True)

    elapsed = time.time() - start_time
    tokens_per_second = token_count / elapsed if elapsed > 0 else 0

    print(f"\n\nMetrics:")
    print(f"  Tokens: {token_count}")
    print(f"  Time: {elapsed:.2f}s")
    print(f"  Speed: {tokens_per_second:.1f} tokens/sec")

    return full_content
```

### Function Calling with Streaming

```python
import json

def stream_with_tools(message):
    """Stream response with function calls."""
    tools = [{
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get weather for a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {"type": "string"}
                },
                "required": ["location"]
            }
        }
    }]

    stream = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": message}],
        tools=tools,
        stream=True
    )

    function_name = ""
    function_args = ""

    for chunk in stream:
        delta = chunk.choices[0].delta

        # Regular content
        if delta.content:
            print(delta.content, end="", flush=True)

        # Function call
        if delta.tool_calls:
            for tool_call in delta.tool_calls:
                if tool_call.function.name:
                    function_name = tool_call.function.name
                    print(f"\n[Calling function: {function_name}]")

                if tool_call.function.arguments:
                    function_args += tool_call.function.arguments

        # Completion
        if chunk.choices[0].finish_reason == "tool_calls":
            print(f"[Arguments: {function_args}]")

            # Execute function
            args = json.loads(function_args)
            result = get_weather(args["location"])
            print(f"[Result: {result}]")

# Usage
stream_with_tools("What's the weather in London?")
```

---

## Web Application Integration

### FastAPI Streaming

```python
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from openai import OpenAI
import asyncio

app = FastAPI()
client = OpenAI()

async def generate_stream(message: str):
    """Async generator for streaming."""
    stream = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": message}],
        stream=True
    )

    for chunk in stream:
        if chunk.choices[0].delta.content:
            content = chunk.choices[0].delta.content
            yield f"data: {content}\n\n"
            await asyncio.sleep(0)  # Allow other tasks to run

    yield "data: [DONE]\n\n"

@app.get("/stream")
async def stream_response(message: str):
    """Stream OpenAI response to client."""
    return StreamingResponse(
        generate_stream(message),
        media_type="text/event-stream"
    )

# Usage:
# curl "http://localhost:8000/stream?message=Tell me a joke"
```

### Flask Streaming

```python
from flask import Flask, Response, request
from openai import OpenAI

app = Flask(__name__)
client = OpenAI()

def generate_stream(message):
    """Generator for streaming."""
    stream = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": message}],
        stream=True
    )

    for chunk in stream:
        if chunk.choices[0].delta.content:
            content = chunk.choices[0].delta.content
            yield f"data: {content}\n\n"

    yield "data: [DONE]\n\n"

@app.route('/stream')
def stream_response():
    """Stream OpenAI response."""
    message = request.args.get('message', '')
    return Response(
        generate_stream(message),
        mimetype='text/event-stream'
    )

if __name__ == '__main__':
    app.run()
```

### Frontend (JavaScript)

```javascript
// Fetch API with streaming
async function streamChat(message) {
  const response = await fetch(`/stream?message=${encodeURIComponent(message)}`);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();

  let content = '';

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;

    const chunk = decoder.decode(value);
    const lines = chunk.split('\n');

    for (const line of lines) {
      if (line.startsWith('data: ')) {
        const data = line.slice(6);
        if (data === '[DONE]') {
          console.log('Stream complete');
        } else {
          content += data;
          updateUI(content);  // Update UI with new content
        }
      }
    }
  }
}

// EventSource for Server-Sent Events
const eventSource = new EventSource('/stream?message=Tell me a story');

eventSource.onmessage = (event) => {
  if (event.data === '[DONE]') {
    eventSource.close();
  } else {
    updateUI(event.data);
  }
};
```

### React Component

```jsx
import React, { useState } from 'react';

function StreamingChat() {
  const [message, setMessage] = useState('');
  const [response, setResponse] = useState('');
  const [isStreaming, setIsStreaming] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsStreaming(true);
    setResponse('');

    const res = await fetch(`/stream?message=${encodeURIComponent(message)}`);
    const reader = res.body.getReader();
    const decoder = new TextDecoder();

    let fullResponse = '';

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value);
      const lines = chunk.split('\n');

      for (const line of lines) {
        if (line.startsWith('data: ')) {
          const data = line.slice(6);
          if (data !== '[DONE]') {
            fullResponse += data;
            setResponse(fullResponse);
          }
        }
      }
    }

    setIsStreaming(false);
  };

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <input
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          placeholder="Ask something..."
          disabled={isStreaming}
        />
        <button type="submit" disabled={isStreaming}>
          {isStreaming ? 'Streaming...' : 'Send'}
        </button>
      </form>

      <div className="response">
        {response}
        {isStreaming && <span className="cursor">▋</span>}
      </div>
    </div>
  );
}
```

---

## Error Handling

### Robust Streaming

```python
from openai import OpenAI, APIError, APIConnectionError

client = OpenAI()

def robust_stream(message, max_retries=3):
    """Stream with error handling."""
    for attempt in range(max_retries):
        try:
            stream = client.chat.completions.create(
                model="gpt-4o",
                messages=[{"role": "user", "content": message}],
                stream=True,
                timeout=30.0
            )

            full_content = ""

            for chunk in stream:
                try:
                    if chunk.choices[0].delta.content:
                        content = chunk.choices[0].delta.content
                        full_content += content
                        print(content, end="", flush=True)

                except (KeyError, IndexError):
                    # Skip malformed chunks
                    continue

            return full_content

        except APIConnectionError as e:
            if attempt < max_retries - 1:
                print(f"\n[Connection error, retrying... ({attempt + 1}/{max_retries})]")
                time.sleep(2 ** attempt)  # Exponential backoff
            else:
                raise

        except APIError as e:
            print(f"\n[API error: {e}]")
            raise

# Usage
response = robust_stream("Tell me a story")
```

### Timeout Handling

```python
import signal

class TimeoutError(Exception):
    pass

def timeout_handler(signum, frame):
    raise TimeoutError("Stream timeout")

def stream_with_timeout(message, timeout_seconds=30):
    """Stream with timeout."""
    # Set timeout
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(timeout_seconds)

    try:
        stream = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": message}],
            stream=True
        )

        for chunk in stream:
            if chunk.choices[0].delta.content:
                print(chunk.choices[0].delta.content, end="", flush=True)

        # Cancel timeout
        signal.alarm(0)

    except TimeoutError:
        print("\n[Stream timeout - response incomplete]")
        signal.alarm(0)
```

---

## Best Practices

### 1. Always Flush Output

```python
# ❌ Bad: output buffered
for chunk in stream:
    print(chunk.choices[0].delta.content, end="")

# ✅ Good: flush immediately
for chunk in stream:
    print(chunk.choices[0].delta.content, end="", flush=True)
```

### 2. Handle Empty Deltas

```python
# ✅ Always check for content
for chunk in stream:
    delta = chunk.choices[0].delta
    if hasattr(delta, 'content') and delta.content:
        print(delta.content, end="", flush=True)
```

### 3. Track Finish Reason

```python
for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)

    finish_reason = chunk.choices[0].finish_reason
    if finish_reason:
        if finish_reason == "length":
            print("\n[Response truncated due to length]")
        elif finish_reason == "content_filter":
            print("\n[Response filtered]")
```

### 4. Use Server-Sent Events for Web

```python
# Server-Sent Events format
def generate():
    stream = client.chat.completions.create(...)
    for chunk in stream:
        if chunk.choices[0].delta.content:
            yield f"data: {chunk.choices[0].delta.content}\n\n"
    yield "data: [DONE]\n\n"
```

---

## Performance Tips

### 1. Use Appropriate Models

```python
# gpt-4o-mini streams faster and costs less
stream = client.chat.completions.create(
    model="gpt-4o-mini",  # Faster, cheaper
    messages=messages,
    stream=True
)
```

### 2. Set Max Tokens

```python
# Limit response length for faster streaming
stream = client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    stream=True,
    max_tokens=500  # Shorter responses
)
```

### 3. Monitor Network

```python
import time

def stream_with_monitoring(message):
    """Monitor stream performance."""
    stream = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": message}],
        stream=True
    )

    first_token_time = None
    start_time = time.time()
    token_count = 0

    for chunk in stream:
        if chunk.choices[0].delta.content:
            if first_token_time is None:
                first_token_time = time.time() - start_time

            token_count += 1
            print(chunk.choices[0].delta.content, end="", flush=True)

    total_time = time.time() - start_time

    print(f"\n\nPerformance:")
    print(f"  Time to first token: {first_token_time:.2f}s")
    print(f"  Total time: {total_time:.2f}s")
    print(f"  Tokens: {token_count}")
    print(f"  Speed: {token_count / total_time:.1f} tokens/sec")
```

---

## Next Steps

1. **[Webhooks →](./webhooks.md)** - Event-driven notifications
2. **[Background Mode →](./background-mode.md)** - Async processing
3. **[Conversation State →](./conversation-state.md)** - Manage context
4. **[Batch API →](./batch-api.md)** - Large-scale processing

---

## Additional Resources

- **Streaming Guide**: https://platform.openai.com/docs/guides/streaming-responses
- **SSE Specification**: https://html.spec.whatwg.org/multipage/server-sent-events.html
- **API Reference**: https://platform.openai.com/docs/api-reference/chat/create
- **Examples**: https://github.com/openai/openai-cookbook

---

**Next**: [Webhooks →](./webhooks.md)
