# Claude API - Streaming Guide

**Sources:** 
- https://docs.claude.com/en/docs/build-with-claude/streaming
- https://github.com/anthropics/anthropic-sdk-python
- https://github.com/anthropics/anthropic-sdk-typescript

**Fetched:** 2025-10-11

## Overview

Streaming allows you to receive Claude's response incrementally as it's being generated, rather than waiting for the complete response. This provides:

- **Better user experience** - Users see content appear in real-time
- **Lower perceived latency** - Response starts appearing immediately
- **Interruptible requests** - Can stop generation early if needed
- **Progress feedback** - Show users that processing is happening

## How Streaming Works

When you set `stream: true`, the API returns Server-Sent Events (SSE) instead of a single JSON response. Each event represents a piece of the response being generated.

### Event Flow

```
1. message_start → Initial message object (empty content)
2. content_block_start → Start of a content block
3. content_block_delta → Incremental content (multiple events)
4. content_block_stop → End of content block
5. message_delta → Message metadata updates
6. message_stop → Stream complete
```

### Event Types

| Event Type | Description | Data |
|------------|-------------|------|
| `message_start` | Stream begins | Initial Message object with empty content |
| `content_block_start` | New content block | Block index and type |
| `content_block_delta` | Incremental content | Text delta or tool input delta |
| `content_block_stop` | Block complete | Block index |
| `message_delta` | Message updates | stop_reason, usage updates |
| `message_stop` | Stream ends | Final event |
| `ping` | Keep-alive | Sent periodically |
| `error` | Error occurred | Error details |

## Python SDK

### Basic Streaming

```python
import anthropic

client = anthropic.Anthropic()

with client.messages.stream(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Write a haiku about coding"}],
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

### Event-Level Streaming

```python
with client.messages.stream(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}],
) as stream:
    for event in stream:
        if event.type == "message_start":
            print(f"\\nMessage ID: {event.message.id}")
        elif event.type == "content_block_start":
            print(f"\\nBlock {event.index} started (type: {event.content_block.type})")
        elif event.type == "content_block_delta":
            if hasattr(event.delta, 'text'):
                print(event.delta.text, end="", flush=True)
        elif event.type == "content_block_stop":
            print(f"\\nBlock {event.index} stopped")
        elif event.type == "message_delta":
            print(f"\\nStop reason: {event.delta.stop_reason}")
        elif event.type == "message_stop":
            print("\\nStream complete")
```

### Accessing Final Message

```python
with client.messages.stream(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}],
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)

    # Get the complete final message
    final_message = stream.get_final_message()
    print(f"\\n\\nTokens used: {final_message.usage.output_tokens}")
```

### Async Streaming

```python
import asyncio
from anthropic import AsyncAnthropic

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

### Manual Stream Control

```python
stream = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}],
    stream=True
)

for event in stream:
    if event.type == "content_block_delta":
        print(event.delta.text, end="", flush=True)
```

## TypeScript SDK

### Basic Streaming

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

const stream = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Write a haiku about coding' }],
  stream: true,
});

for await (const event of stream) {
  if (event.type === 'content_block_delta' && event.delta.type === 'text_delta') {
    process.stdout.write(event.delta.text);
  }
}
```

### Stream Helpers

```typescript
const stream = client.messages.stream({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Write a story' }],
});

stream.on('text', (text) => {
  process.stdout.write(text);
});

stream.on('message', (message) => {
  console.log('\\nFinal message:', message);
});

stream.on('error', (error) => {
  console.error('Stream error:', error);
});

const finalMessage = await stream.finalMessage();
console.log('Tokens:', finalMessage.usage.output_tokens);
```

### Event-Level Streaming

```typescript
const stream = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Hello' }],
  stream: true,
});

for await (const event of stream) {
  switch (event.type) {
    case 'message_start':
      console.log('Message started:', event.message.id);
      break;
    case 'content_block_start':
      console.log('Content block started:', event.index);
      break;
    case 'content_block_delta':
      if (event.delta.type === 'text_delta') {
        process.stdout.write(event.delta.text);
      }
      break;
    case 'content_block_stop':
      console.log('\\nContent block stopped:', event.index);
      break;
    case 'message_delta':
      console.log('Stop reason:', event.delta.stop_reason);
      break;
    case 'message_stop':
      console.log('Stream complete');
      break;
  }
}
```

## Streaming with Tool Use

### Python

```python
tools = [{
    "name": "get_weather",
    "description": "Get weather for a location",
    "input_schema": {
        "type": "object",
        "properties": {
            "location": {"type": "string"}
        },
        "required": ["location"]
    }
}]

with client.messages.stream(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "What's the weather in SF?"}],
) as stream:
    for event in stream:
        if event.type == "content_block_delta":
            if hasattr(event.delta, 'text'):
                print(event.delta.text, end="")
            elif hasattr(event.delta, 'partial_json'):
                print(f"Tool input delta: {event.delta.partial_json}")
```

### TypeScript

```typescript
const tools: Anthropic.Tool[] = [{
  name: 'get_weather',
  description: 'Get weather for a location',
  input_schema: {
    type: 'object',
    properties: {
      location: { type: 'string' }
    },
    required: ['location']
  }
}];

const stream = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  tools,
  messages: [{ role: 'user', content: "What's the weather in SF?" }],
  stream: true,
});

for await (const event of stream) {
  if (event.type === 'content_block_delta') {
    if (event.delta.type === 'text_delta') {
      process.stdout.write(event.delta.text);
    } else if (event.delta.type === 'input_json_delta') {
      console.log('Tool input delta:', event.delta.partial_json);
    }
  }
}
```

## Error Handling

### Python

```python
from anthropic import APIError, APIConnectionError

try:
    with client.messages.stream(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{"role": "user", "content": "Hello"}],
    ) as stream:
        for text in stream.text_stream:
            print(text, end="", flush=True)
except APIConnectionError as e:
    print(f"Connection lost: {e}")
    # Handle reconnection logic
except APIError as e:
    print(f"API error: {e}")
```

### TypeScript

```typescript
try {
  const stream = client.messages.stream({
    model: 'claude-sonnet-4-5-20250929',
    max_tokens: 1024,
    messages: [{ role: 'user', content: 'Hello' }],
  });

  stream.on('error', (error) => {
    console.error('Stream error:', error);
  });

  for await (const text of stream.textStream) {
    process.stdout.write(text);
  }
} catch (error) {
  console.error('Failed to create stream:', error);
}
```

## Advanced Patterns

### Resumable Streaming (Python)

```python
def resumable_stream(prompt, max_retries=3):
    accumulated_text = ""
    retry_count = 0

    while retry_count < max_retries:
        try:
            with client.messages.stream(
                model="claude-sonnet-4-5-20250929",
                max_tokens=1024,
                messages=[
                    {"role": "user", "content": prompt},
                    {"role": "assistant", "content": accumulated_text}
                ] if accumulated_text else [{"role": "user", "content": prompt}],
            ) as stream:
                for text in stream.text_stream:
                    accumulated_text += text
                    print(text, end="", flush=True)
                break  # Success
        except APIConnectionError:
            retry_count += 1
            print(f"\\nConnection lost, retrying ({retry_count}/{max_retries})...")
            time.sleep(2 ** retry_count)

    return accumulated_text
```

### Progress Tracking

```python
class StreamProgress:
    def __init__(self):
        self.tokens_generated = 0
        self.blocks_completed = 0

    def track(self, event):
        if event.type == "content_block_delta":
            if hasattr(event.delta, 'text'):
                self.tokens_generated += len(event.delta.text.split())
        elif event.type == "content_block_stop":
            self.blocks_completed += 1

progress = StreamProgress()

with client.messages.stream(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Write a long story"}],
) as stream:
    for event in stream:
        progress.track(event)
        if event.type == "content_block_delta" and hasattr(event.delta, 'text'):
            print(event.delta.text, end="", flush=True)

print(f"\\nGenerated ~{progress.tokens_generated} tokens in {progress.blocks_completed} blocks")
```

## Best Practices

### 1. Always Use Context Managers (Python)

```python
# Good
with client.messages.stream(...) as stream:
    for text in stream.text_stream:
        process(text)

# Bad - can leak connections
stream = client.messages.stream(...)
for text in stream.text_stream:
    process(text)
```

### 2. Handle Backpressure

```python
import queue
import threading

response_queue = queue.Queue(maxsize=100)

def stream_to_queue():
    with client.messages.stream(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{"role": "user", "content": "Write a long essay"}],
    ) as stream:
        for text in stream.text_stream:
            response_queue.put(text)
        response_queue.put(None)  # Signal completion

threading.Thread(target=stream_to_queue).start()

while True:
    chunk = response_queue.get()
    if chunk is None:
        break
    process_chunk(chunk)
```

### 3. Implement Timeouts

```python
import signal

class StreamTimeout(Exception):
    pass

def timeout_handler(signum, frame):
    raise StreamTimeout()

signal.signal(signal.SIGALRM, timeout_handler)
signal.alarm(30)  # 30 second timeout

try:
    with client.messages.stream(...) as stream:
        for text in stream.text_stream:
            print(text, end="")
except StreamTimeout:
    print("\\nStream timed out")
finally:
    signal.alarm(0)
```

### 4. Buffer for Display

```python
import time

buffer = []
last_flush = time.time()
FLUSH_INTERVAL = 0.1  # Flush every 100ms

with client.messages.stream(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}],
) as stream:
    for text in stream.text_stream:
        buffer.append(text)

        if time.time() - last_flush > FLUSH_INTERVAL:
            print(''.join(buffer), end="", flush=True)
            buffer = []
            last_flush = time.time()

    # Flush remaining
    if buffer:
        print(''.join(buffer), end="", flush=True)
```

## Troubleshooting

### Issue: Stream Stops Unexpectedly

**Cause:** Network interruption or timeout  
**Solution:**
```python
import time

max_retries = 3
for attempt in range(max_retries):
    try:
        with client.messages.stream(...) as stream:
            for text in stream.text_stream:
                print(text, end="")
        break
    except APIConnectionError:
        if attempt < max_retries - 1:
            time.sleep(2 ** attempt)
```

### Issue: Events Out of Order

**Cause:** Not processing events sequentially  
**Solution:** Always process events in the order received

### Issue: Memory Buildup

**Cause:** Accumulating all text without processing  
**Solution:**
```python
with client.messages.stream(...) as stream:
    for text in stream.text_stream:
        process_immediately(text)  # Don't accumulate
```

## Related Documentation

- [Messages API](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)
- [TypeScript SDK](./05-typescript-sdk.md)
- [Tool Use](./08-tool-use.md)
