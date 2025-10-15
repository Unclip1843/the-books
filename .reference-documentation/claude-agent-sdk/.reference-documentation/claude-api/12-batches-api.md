# Claude API - Message Batches

**Sources:**
- https://docs.claude.com/en/docs/build-with-claude/message-batches
- https://docs.claude.com/en/api/message-batches

**Fetched:** 2025-10-11

## Overview

The Message Batches API allows you to process large volumes of Claude requests asynchronously with **50% cost savings** compared to standard API pricing. Batches are ideal for processing operations that don't require immediate responses.

## Key Benefits

- **50% Cost Reduction** - Flat discount on all standard API prices
- **Asynchronous Processing** - Submit requests and retrieve results later
- **Large Scale** - Process up to 100,000 requests per batch
- **Full Feature Support** - Vision, tool use, prompt caching all work
- **Simple Integration** - Same request format as Messages API

## When to Use Batches

### Good Use Cases
✅ Large-scale evaluations and benchmarking
✅ Content moderation at scale
✅ Bulk data analysis and processing
✅ Batch content generation
✅ Offline processing workflows
✅ ETL pipelines
✅ Research and experimentation

### Not Ideal For
❌ Real-time user interactions
❌ Latency-sensitive applications
❌ Requests needing immediate responses
❌ Interactive conversations

## Supported Models

All Claude models support batches:
- Claude Sonnet 4.5
- Claude Opus 4.1
- Claude Sonnet 4
- Claude Sonnet 3.7
- Claude Haiku 3.5
- Claude Haiku 3

## Batch Limits

| Limit | Value |
|-------|-------|
| Maximum requests per batch | 100,000 |
| Maximum batch size | 256 MB |
| Maximum processing time | 24 hours |
| Results retention | 29 days |
| Scope | Per workspace |

## Pricing

**Flat 50% discount on standard API pricing:**

| Model | Standard Input | Batch Input | Standard Output | Batch Output |
|-------|----------------|-------------|-----------------|--------------|
| Sonnet 4.5 | $3.00/MTok | $1.50/MTok | $15.00/MTok | $7.50/MTok |
| Opus 4.1 | $15.00/MTok | $7.50/MTok | $75.00/MTok | $37.50/MTok |
| Haiku 3.5 | $0.80/MTok | $0.40/MTok | $4.00/MTok | $2.00/MTok |

## Python Implementation

### Creating a Batch

```python
import anthropic

client = anthropic.Anthropic()

# Prepare requests
requests = [
    {
        "custom_id": "request-1",
        "params": {
            "model": "claude-sonnet-4-5-20250929",
            "max_tokens": 1024,
            "messages": [
                {"role": "user", "content": "Summarize this article: [...]"}
            ]
        }
    },
    {
        "custom_id": "request-2",
        "params": {
            "model": "claude-sonnet-4-5-20250929",
            "max_tokens": 1024,
            "messages": [
                {"role": "user", "content": "Classify sentiment: [...]"}
            ]
        }
    }
]

# Create batch
batch = client.messages.batches.create(requests=requests)

print(f"Batch ID: {batch.id}")
print(f"Status: {batch.processing_status}")
```

### Checking Batch Status

```python
# Get batch status
batch_status = client.messages.batches.retrieve(batch.id)

print(f"Processing status: {batch_status.processing_status}")
print(f"Request counts: {batch_status.request_counts}")
```

### Retrieving Results

```python
# Wait for completion (poll periodically)
import time

while True:
    batch_status = client.messages.batches.retrieve(batch.id)

    if batch_status.processing_status == "ended":
        break

    print(f"Status: {batch_status.processing_status}, "
          f"Processed: {batch_status.request_counts.succeeded}")
    time.sleep(60)  # Check every minute

# Get results
results = client.messages.batches.results(batch.id)

for result in results:
    if result.result.type == "succeeded":
        print(f"Request {result.custom_id}: Success")
        print(f"Response: {result.result.message.content[0].text}")
    elif result.result.type == "errored":
        print(f"Request {result.custom_id}: Error")
        print(f"Error: {result.result.error}")
```

### Complete Example

```python
import anthropic
import time
import json

def process_batch(requests, poll_interval=60):
    """Process a batch of requests and return results"""
    client = anthropic.Anthropic()

    # Create batch
    batch = client.messages.batches.create(requests=requests)
    print(f"Created batch: {batch.id}")

    # Poll for completion
    while True:
        batch_status = client.messages.batches.retrieve(batch.id)

        if batch_status.processing_status == "ended":
            break

        counts = batch_status.request_counts
        print(f"Processing... Succeeded: {counts.succeeded}, "
              f"Errored: {counts.errored}, "
              f"Processing: {counts.processing}")

        time.sleep(poll_interval)

    # Get results
    results = list(client.messages.batches.results(batch.id))

    # Organize results
    succeeded = []
    errored = []

    for result in results:
        if result.result.type == "succeeded":
            succeeded.append({
                "custom_id": result.custom_id,
                "response": result.result.message.content[0].text
            })
        else:
            errored.append({
                "custom_id": result.custom_id,
                "error": result.result.error
            })

    return {
        "batch_id": batch.id,
        "succeeded": succeeded,
        "errored": errored
    }

# Usage
requests = [
    {
        "custom_id": f"request-{i}",
        "params": {
            "model": "claude-sonnet-4-5-20250929",
            "max_tokens": 1024,
            "messages": [{"role": "user", "content": f"Task {i}"}]
        }
    }
    for i in range(100)
]

results = process_batch(requests)
print(f"Completed: {len(results['succeeded'])}")
print(f"Failed: {len(results['errored'])}")
```

## TypeScript Implementation

### Creating a Batch

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

const requests: Anthropic.MessageBatchParam[] = [
  {
    custom_id: 'request-1',
    params: {
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 1024,
      messages: [
        { role: 'user', content: 'Summarize this article: [...]' }
      ],
    },
  },
  {
    custom_id: 'request-2',
    params: {
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 1024,
      messages: [
        { role: 'user', content: 'Classify sentiment: [...]' }
      ],
    },
  },
];

const batch = await client.messages.batches.create({ requests });

console.log(`Batch ID: ${batch.id}`);
console.log(`Status: ${batch.processing_status}`);
```

### Checking Status and Retrieving Results

```typescript
async function waitForBatchCompletion(
  batchId: string,
  pollInterval: number = 60000
): Promise<void> {
  while (true) {
    const batch = await client.messages.batches.retrieve(batchId);

    if (batch.processing_status === 'ended') {
      break;
    }

    console.log(`Status: ${batch.processing_status}`);
    console.log(`Succeeded: ${batch.request_counts.succeeded}`);

    await new Promise(resolve => setTimeout(resolve, pollInterval));
  }
}

// Get results
const results = await client.messages.batches.results(batchId);

for await (const result of results) {
  if (result.result.type === 'succeeded') {
    console.log(`Request ${result.custom_id}: Success`);
    console.log(result.result.message.content[0].text);
  } else if (result.result.type === 'errored') {
    console.log(`Request ${result.custom_id}: Error`);
    console.log(result.result.error);
  }
}
```

## Batch Request Format

### Basic Request

```json
{
  "custom_id": "unique-identifier",
  "params": {
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "Your prompt here"}
    ]
  }
}
```

### With System Prompt

```json
{
  "custom_id": "request-with-system",
  "params": {
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "system": "You are a helpful assistant",
    "messages": [
      {"role": "user", "content": "Hello"}
    ]
  }
}
```

### With Vision

```json
{
  "custom_id": "image-analysis",
  "params": {
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "messages": [{
      "role": "user",
      "content": [
        {"type": "text", "text": "Describe this image"},
        {
          "type": "image",
          "source": {
            "type": "url",
            "url": "https://example.com/image.jpg"
          }
        }
      ]
    }]
  }
}
```

### With Tools

```json
{
  "custom_id": "tool-use-request",
  "params": {
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "tools": [{
      "name": "get_weather",
      "description": "Get weather data",
      "input_schema": {
        "type": "object",
        "properties": {
          "location": {"type": "string"}
        },
        "required": ["location"]
      }
    }],
    "messages": [
      {"role": "user", "content": "What's the weather in SF?"}
    ]
  }
}
```

### With Prompt Caching

```json
{
  "custom_id": "cached-request",
  "params": {
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 1024,
    "system": [{
      "type": "text",
      "text": "Large system prompt...",
      "cache_control": {"type": "ephemeral"}
    }],
    "messages": [
      {"role": "user", "content": "Question"}
    ]
  }
}
```

## Batch Status Values

| Status | Description |
|--------|-------------|
| `in_progress` | Batch is being processed |
| `canceling` | Cancellation requested |
| `ended` | Processing complete (check individual results) |

## Result Types

| Type | Description |
|------|-------------|
| `succeeded` | Request completed successfully |
| `errored` | Request failed with error |
| `canceled` | Request was canceled |
| `expired` | Result expired (after 29 days) |

## Best Practices

### 1. Use Meaningful Custom IDs

```python
# Good - descriptive IDs
{
    "custom_id": "customer-123-sentiment-analysis",
    "params": {...}
}

# Bad - generic IDs
{
    "custom_id": "1",
    "params": {...}
}
```

### 2. Validate Requests First

```python
# Test single request first
test_response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Test"}]
)

# If successful, use same format in batch
batch_request = {
    "custom_id": "test",
    "params": {
        "model": "claude-sonnet-4-5-20250929",
        "max_tokens": 1024,
        "messages": [{"role": "user", "content": "Test"}]
    }
}
```

### 3. Break Large Batches

```python
def create_batches(requests, batch_size=10000):
    """Split requests into multiple batches"""
    batches = []

    for i in range(0, len(requests), batch_size):
        chunk = requests[i:i + batch_size]
        batch = client.messages.batches.create(requests=chunk)
        batches.append(batch.id)

    return batches
```

### 4. Handle Errors Gracefully

```python
def process_with_retry(failed_requests, max_retries=3):
    """Retry failed requests"""
    for attempt in range(max_retries):
        if not failed_requests:
            break

        batch = client.messages.batches.create(requests=failed_requests)
        # Wait for completion...
        results = list(client.messages.batches.results(batch.id))

        # Extract still-failed requests
        failed_requests = [
            r for r in results if r.result.type == "errored"
        ]
```

### 5. Monitor Progress

```python
def monitor_batch(batch_id, update_callback=None):
    """Monitor batch with custom callback"""
    while True:
        batch = client.messages.batches.retrieve(batch_id)

        if update_callback:
            update_callback(batch)

        if batch.processing_status == "ended":
            break

        time.sleep(60)

    return batch

# Usage
def print_progress(batch):
    counts = batch.request_counts
    total = counts.succeeded + counts.errored + counts.processing
    progress = (counts.succeeded + counts.errored) / total * 100
    print(f"Progress: {progress:.1f}%")

monitor_batch(batch_id, print_progress)
```

## Common Use Cases

### 1. Content Moderation

```python
def moderate_content_batch(texts):
    """Moderate large volumes of user-generated content"""
    requests = []

    for i, text in enumerate(texts):
        requests.append({
            "custom_id": f"moderation-{i}",
            "params": {
                "model": "claude-sonnet-4-5-20250929",
                "max_tokens": 200,
                "messages": [{
                    "role": "user",
                    "content": f"Analyze for inappropriate content. Return JSON.\n\nText: {text}"
                }]
            }
        })

    batch = client.messages.batches.create(requests=requests)
    return batch.id
```

### 2. Data Analysis

```python
def analyze_dataset_batch(data_records):
    """Analyze structured data in bulk"""
    requests = []

    for record in data_records:
        requests.append({
            "custom_id": record["id"],
            "params": {
                "model": "claude-sonnet-4-5-20250929",
                "max_tokens": 1024,
                "messages": [{
                    "role": "user",
                    "content": f"Analyze this data: {json.dumps(record)}"
                }]
            }
        })

    return process_batch(requests)
```

### 3. Translation Pipeline

```python
def translate_batch(texts, target_language):
    """Translate multiple texts"""
    requests = [
        {
            "custom_id": f"translate-{i}",
            "params": {
                "model": "claude-haiku-3-5-20241022",  # Fast, cheap
                "max_tokens": 2048,
                "messages": [{
                    "role": "user",
                    "content": f"Translate to {target_language}: {text}"
                }]
            }
        }
        for i, text in enumerate(texts)
    ]

    return process_batch(requests)
```

## Canceling Batches

```python
# Cancel a batch
canceled_batch = client.messages.batches.cancel(batch_id)

print(f"Status: {canceled_batch.processing_status}")  # "canceling"
```

## Listing Batches

```python
# List all batches
batches = client.messages.batches.list(limit=20)

for batch in batches:
    print(f"Batch {batch.id}: {batch.processing_status}")
```

## Error Handling

```python
from anthropic import APIError

try:
    batch = client.messages.batches.create(requests=requests)
except APIError as e:
    if e.status_code == 400:
        print(f"Invalid request: {e.message}")
    elif e.status_code == 413:
        print("Batch too large - split into smaller batches")
    elif e.status_code == 429:
        print("Rate limited - wait before retrying")
    else:
        print(f"Error: {e}")
```

## Cost Comparison

### Example: 10,000 Requests

**Standard API (Sonnet 4.5):**
```
Input: 10,000 requests × 1,000 tokens × $3.00/MTok = $30.00
Output: 10,000 requests × 500 tokens × $15.00/MTok = $75.00
Total: $105.00
```

**Batch API (Sonnet 4.5):**
```
Input: 10,000 requests × 1,000 tokens × $1.50/MTok = $15.00
Output: 10,000 requests × 500 tokens × $7.50/MTok = $37.50
Total: $52.50

Savings: $52.50 (50%)
```

## Limitations

- ❌ Cannot update batch after creation
- ❌ Cannot add requests to existing batch
- ❌ Results expire after 29 days
- ❌ Maximum 24-hour processing time
- ❌ No real-time streaming
- ❌ Cancellation not instant

## Troubleshooting

### Issue: Batch Taking Too Long

**Cause:** Large batch size
**Solution:** Split into smaller batches

### Issue: Many Failed Requests

**Cause:** Invalid request format
**Solution:** Test format with Messages API first

### Issue: Results Not Available

**Cause:** Results expired (29 days)
**Solution:** Process results promptly after completion

## Related Documentation

- [Messages API](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)
- [TypeScript SDK](./05-typescript-sdk.md)
- [Tool Use](./08-tool-use.md)
- [Prompt Caching](./09-prompt-caching.md)
- [Vision](./07-vision.md)
