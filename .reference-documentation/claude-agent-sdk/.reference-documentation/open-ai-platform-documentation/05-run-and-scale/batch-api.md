# OpenAI Platform - Batch API

**Source:** https://platform.openai.com/docs/guides/batch
**Fetched:** 2025-10-11

## Overview

The Batch API enables asynchronous processing of large-scale workloads at 50% lower cost than standard API requests. Perfect for processing millions of requests that don't require immediate responses.

**Key Benefits:**
- **50% cost savings** on input and output tokens
- **Separate quota** from real-time requests
- **24-hour completion** window
- **No rate limit conflicts** with online workloads
- **Handles millions** of requests

**Best For:**
- Data analysis and processing
- Content generation at scale
- Evaluation and testing
- Offline classification tasks
- Bulk embeddings generation

---

## How It Works

### Batch Processing Flow

```
1. Prepare batch input (JSONL file)
   ↓
2. Upload input file
   ↓
3. Create batch job
   ↓
4. OpenAI processes asynchronously (up to 24 hours)
   ↓
5. Check batch status
   ↓
6. Download results when complete
```

### Input Format

Batch requests use JSONL format (newline-delimited JSON):

```jsonl
{"custom_id": "request-1", "method": "POST", "url": "/v1/chat/completions", "body": {"model": "gpt-5", "messages": [{"role": "user", "content": "Summarize this text..."}]}}
{"custom_id": "request-2", "method": "POST", "url": "/v1/chat/completions", "body": {"model": "gpt-5", "messages": [{"role": "user", "content": "Translate this..."}]}}
{"custom_id": "request-3", "method": "POST", "url": "/v1/chat/completions", "body": {"model": "gpt-5", "messages": [{"role": "user", "content": "Analyze sentiment..."}]}}
```

---

## Quick Start

### Creating a Batch Job

```python
from openai import OpenAI
import json

client = OpenAI()

# 1. Prepare batch input
batch_input = []
for i, text in enumerate(texts_to_process):
    batch_input.append({
        "custom_id": f"request-{i}",
        "method": "POST",
        "url": "/v1/chat/completions",
        "body": {
            "model": "gpt-5",
            "messages": [
                {
                    "role": "user",
                    "content": f"Summarize this text: {text}"
                }
            ],
            "max_tokens": 500
        }
    })

# 2. Save to JSONL file
with open("batch_input.jsonl", "w") as f:
    for item in batch_input:
        f.write(json.dumps(item) + "\n")

# 3. Upload file
batch_file = client.files.create(
    file=open("batch_input.jsonl", "rb"),
    purpose="batch"
)

# 4. Create batch job
batch_job = client.batches.create(
    input_file_id=batch_file.id,
    endpoint="/v1/chat/completions",
    completion_window="24h"
)

print(f"Batch job created: {batch_job.id}")
print(f"Status: {batch_job.status}")
```

### Checking Batch Status

```python
# Retrieve batch status
batch = client.batches.retrieve(batch_job.id)

print(f"Status: {batch.status}")
print(f"Total requests: {batch.request_counts.total}")
print(f"Completed: {batch.request_counts.completed}")
print(f"Failed: {batch.request_counts.failed}")
```

### Downloading Results

```python
# Wait for completion
import time

while True:
    batch = client.batches.retrieve(batch_job.id)

    if batch.status == "completed":
        break
    elif batch.status == "failed":
        print("Batch failed!")
        break

    print(f"Status: {batch.status} - {batch.request_counts.completed}/{batch.request_counts.total} completed")
    time.sleep(60)  # Check every minute

# Download results
if batch.status == "completed":
    result_file_id = batch.output_file_id

    result = client.files.content(result_file_id)
    result_data = result.content

    # Parse JSONL results
    results = []
    for line in result_data.decode('utf-8').strip().split('\n'):
        results.append(json.loads(line))

    # Process results
    for result in results:
        custom_id = result["custom_id"]
        response = result["response"]["body"]

        if result["response"]["status_code"] == 200:
            content = response["choices"][0]["message"]["content"]
            print(f"{custom_id}: {content}")
        else:
            print(f"{custom_id}: Error - {result['error']}")
```

---

## Supported Endpoints

### Chat Completions

```json
{
  "custom_id": "request-1",
  "method": "POST",
  "url": "/v1/chat/completions",
  "body": {
    "model": "gpt-5",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Hello!"}
    ],
    "max_tokens": 1000
  }
}
```

### Embeddings

```json
{
  "custom_id": "embed-1",
  "method": "POST",
  "url": "/v1/embeddings",
  "body": {
    "model": "text-embedding-3-large",
    "input": "Text to embed"
  }
}
```

### Moderation

```json
{
  "custom_id": "mod-1",
  "method": "POST",
  "url": "/v1/moderations",
  "body": {
    "input": "Text to moderate"
  }
}
```

---

## Batch Job Management

### List All Batches

```python
# List recent batches
batches = client.batches.list(limit=10)

for batch in batches:
    print(f"ID: {batch.id}")
    print(f"Status: {batch.status}")
    print(f"Created: {batch.created_at}")
    print(f"Requests: {batch.request_counts.total}")
    print("---")
```

### Cancel a Batch

```python
# Cancel ongoing batch
cancelled_batch = client.batches.cancel(batch_job.id)

print(f"Status: {cancelled_batch.status}")  # "cancelling" or "cancelled"
```

### Batch Metadata

```python
# Create batch with metadata
batch_job = client.batches.create(
    input_file_id=batch_file.id,
    endpoint="/v1/chat/completions",
    completion_window="24h",
    metadata={
        "project": "sentiment_analysis",
        "dataset": "customer_reviews_q4_2025",
        "version": "v1.2"
    }
)

# Filter batches by metadata
batches = client.batches.list()
project_batches = [
    b for b in batches
    if b.metadata and b.metadata.get("project") == "sentiment_analysis"
]
```

---

## Cost Optimization

### Pricing Comparison

**Standard API:**
- gpt-5: $1.25/1M input tokens, $10.00/1M output tokens

**Batch API (50% discount):**
- gpt-5: $0.625/1M input tokens, $5.00/1M output tokens

**Example Savings:**
```python
# Process 10,000 documents, avg 500 input + 200 output tokens each

# Standard API cost
standard_input = (10_000 * 500 / 1_000_000) * 1.25  # $6.25
standard_output = (10_000 * 200 / 1_000_000) * 10.00  # $20.00
standard_total = standard_input + standard_output  # $26.25

# Batch API cost
batch_input = (10_000 * 500 / 1_000_000) * 0.625  # $3.125
batch_output = (10_000 * 200 / 1_000_000) * 5.00  # $10.00
batch_total = batch_input + batch_output  # $13.125

# Savings
savings = standard_total - batch_total  # $13.125 (50%)
print(f"Savings: ${savings:.2f} ({(savings/standard_total)*100:.0f}%)")
```

### When to Use Batch API

**✅ Use Batch API for:**
- Data backfills and historical processing
- Evaluation runs (100s-1000s of test cases)
- Bulk content generation
- Classification of large datasets
- Embedding generation for vector databases
- Any workload where 24-hour latency is acceptable

**❌ Don't use Batch API for:**
- Real-time user interactions
- Interactive applications
- Time-sensitive operations
- Requests requiring immediate responses

---

## Advanced Usage

### Batch with Function Calling

```python
# Create batch with function calling
batch_input = []

for i, customer_query in enumerate(customer_queries):
    batch_input.append({
        "custom_id": f"query-{i}",
        "method": "POST",
        "url": "/v1/chat/completions",
        "body": {
            "model": "gpt-5",
            "messages": [
                {
                    "role": "user",
                    "content": customer_query
                }
            ],
            "tools": [
                {
                    "type": "function",
                    "function": {
                        "name": "classify_intent",
                        "description": "Classify customer query intent",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "intent": {
                                    "type": "string",
                                    "enum": ["billing", "technical", "general"]
                                },
                                "urgency": {
                                    "type": "string",
                                    "enum": ["low", "medium", "high"]
                                }
                            },
                            "required": ["intent", "urgency"]
                        }
                    }
                }
            ],
            "tool_choice": "required"
        }
    })
```

### Structured Output in Batches

```python
from pydantic import BaseModel

class Analysis(BaseModel):
    sentiment: str
    confidence: float
    key_points: list[str]

# Create batch with structured output
for i, text in enumerate(texts):
    batch_input.append({
        "custom_id": f"analysis-{i}",
        "method": "POST",
        "url": "/v1/chat/completions",
        "body": {
            "model": "gpt-5",
            "messages": [
                {
                    "role": "user",
                    "content": f"Analyze: {text}"
                }
            ],
            "response_format": {
                "type": "json_schema",
                "json_schema": {
                    "name": "analysis",
                    "strict": True,
                    "schema": Analysis.model_json_schema()
                }
            }
        }
    })
```

### Error Handling in Batches

```python
def process_batch_results(result_file_id):
    """Process batch results with error handling."""
    result = client.files.content(result_file_id)

    successes = []
    failures = []

    for line in result.content.decode('utf-8').strip().split('\n'):
        result_item = json.loads(line)

        if result_item["response"]["status_code"] == 200:
            successes.append(result_item)
        else:
            failures.append({
                "custom_id": result_item["custom_id"],
                "error": result_item.get("error", {})
            })

    print(f"Successful: {len(successes)}")
    print(f"Failed: {len(failures)}")

    # Retry failures
    if failures:
        retry_batch = []
        for failure in failures:
            # Get original request and retry
            original_request = get_original_request(failure["custom_id"])
            retry_batch.append(original_request)

        # Create new batch for retries
        if retry_batch:
            create_batch_from_list(retry_batch)

    return successes, failures
```

---

## Best Practices

### 1. Optimize Batch Size

```python
# ✅ Good: Reasonable batch size
batch_sizes = {
    "small_tasks": 10_000,  # Simple classifications
    "medium_tasks": 5_000,   # Summaries, translations
    "large_tasks": 1_000     # Complex analysis
}

# Split large datasets
def create_batches(items, batch_size=5_000):
    """Split items into batches."""
    for i in range(0, len(items), batch_size):
        yield items[i:i + batch_size]

for batch_items in create_batches(all_items, 5_000):
    create_batch_job(batch_items)
```

### 2. Use Custom IDs Effectively

```python
# ✅ Good: Descriptive custom IDs
custom_id = f"user-{user_id}-doc-{doc_id}-{timestamp}"

# ❌ Bad: Sequential numbers only
custom_id = f"request-{i}"
```

### 3. Monitor Progress

```python
def monitor_batch(batch_id, check_interval=300):
    """Monitor batch progress with notifications."""
    last_completed = 0

    while True:
        batch = client.batches.retrieve(batch_id)

        if batch.status in ["completed", "failed", "cancelled"]:
            send_notification(f"Batch {batch_id}: {batch.status}")
            break

        completed = batch.request_counts.completed
        if completed > last_completed:
            progress = (completed / batch.request_counts.total) * 100
            print(f"Progress: {progress:.1f}% ({completed}/{batch.request_counts.total})")
            last_completed = completed

        time.sleep(check_interval)
```

### 4. Handle Partial Failures

```python
def create_resilient_batch(requests):
    """Create batch with fallback for failures."""
    # Initial batch
    batch = create_batch_job(requests)

    # Wait for completion
    wait_for_batch(batch.id)

    # Check for failures
    results = download_results(batch.output_file_id)

    failed_requests = [
        r for r in results
        if r["response"]["status_code"] != 200
    ]

    if failed_requests:
        print(f"Retrying {len(failed_requests)} failed requests")

        # Retry with adjusted parameters
        retry_requests = [
            adjust_request(r)  # Maybe reduce tokens, simplify prompt
            for r in failed_requests
        ]

        retry_batch = create_batch_job(retry_requests)
        return retry_batch

    return batch
```

### 5. Cost Tracking

```python
def track_batch_cost(batch_id):
    """Calculate and track batch cost."""
    batch = client.batches.retrieve(batch_id)

    if batch.status != "completed":
        return None

    # Download results to calculate usage
    results = download_results(batch.output_file_id)

    total_input_tokens = 0
    total_output_tokens = 0

    for result in results:
        if result["response"]["status_code"] == 200:
            usage = result["response"]["body"]["usage"]
            total_input_tokens += usage["prompt_tokens"]
            total_output_tokens += usage["completion_tokens"]

    # Calculate cost (Batch API pricing)
    input_cost = (total_input_tokens / 1_000_000) * 0.625  # $0.625/1M for gpt-5 batch
    output_cost = (total_output_tokens / 1_000_000) * 5.00  # $5.00/1M for gpt-5 batch
    total_cost = input_cost + output_cost

    print(f"Batch {batch_id} cost: ${total_cost:.2f}")

    # Log cost
    log_metric("batch_cost", total_cost, {
        "batch_id": batch_id,
        "input_tokens": total_input_tokens,
        "output_tokens": total_output_tokens
    })

    return total_cost
```

---

## Common Use Cases

### 1. Bulk Classification

```python
def classify_documents_batch(documents):
    """Classify many documents using batch API."""
    batch_input = []

    for i, doc in enumerate(documents):
        batch_input.append({
            "custom_id": f"doc-{doc['id']}",
            "method": "POST",
            "url": "/v1/chat/completions",
            "body": {
                "model": "gpt-5-mini",  # Use mini for simple classification
                "messages": [
                    {
                        "role": "user",
                        "content": f"Classify this document category: {doc['text']}"
                    }
                ],
                "max_tokens": 50
            }
        })

    return create_and_process_batch(batch_input)
```

### 2. Evaluation Pipeline

```python
def run_evaluation_batch(test_cases):
    """Evaluate model on test cases."""
    batch_input = []

    for i, test_case in enumerate(test_cases):
        batch_input.append({
            "custom_id": f"eval-{i}",
            "method": "POST",
            "url": "/v1/chat/completions",
            "body": {
                "model": "gpt-5",
                "messages": test_case["messages"],
                "temperature": 0.7
            }
        })

    # Process batch
    results = create_and_process_batch(batch_input)

    # Compare results to expected
    scores = []
    for result, test_case in zip(results, test_cases):
        if result["response"]["status_code"] == 200:
            actual = result["response"]["body"]["choices"][0]["message"]["content"]
            expected = test_case["expected"]

            score = calculate_similarity(actual, expected)
            scores.append(score)

    print(f"Average score: {sum(scores) / len(scores):.2f}")
    return scores
```

### 3. Content Generation at Scale

```python
def generate_product_descriptions_batch(products):
    """Generate descriptions for many products."""
    batch_input = []

    for product in products:
        batch_input.append({
            "custom_id": f"product-{product['id']}",
            "method": "POST",
            "url": "/v1/chat/completions",
            "body": {
                "model": "gpt-5",
                "messages": [
                    {
                        "role": "system",
                        "content": "Generate compelling product descriptions."
                    },
                    {
                        "role": "user",
                        "content": f"Product: {product['name']}\nFeatures: {product['features']}"
                    }
                ],
                "max_tokens": 200
            }
        })

    return create_and_process_batch(batch_input)
```

---

## Troubleshooting

### Batch Stuck in "validating"

```python
# Check input file format
with open("batch_input.jsonl", "r") as f:
    lines = f.readlines()
    for i, line in enumerate(lines):
        try:
            json.loads(line)
        except json.JSONDecodeError as e:
            print(f"Invalid JSON on line {i+1}: {e}")
```

### High Failure Rate

```python
# Analyze failures
def analyze_batch_failures(result_file_id):
    """Analyze why requests failed."""
    result = client.files.content(result_file_id)

    failures_by_error = {}

    for line in result.content.decode('utf-8').strip().split('\n'):
        result_item = json.loads(line)

        if result_item["response"]["status_code"] != 200:
            error_type = result_item.get("error", {}).get("type", "unknown")
            failures_by_error[error_type] = failures_by_error.get(error_type, 0) + 1

    print("Failures by error type:")
    for error_type, count in failures_by_error.items():
        print(f"  {error_type}: {count}")
```

---

## Additional Resources

- **Batch API Documentation**: https://platform.openai.com/docs/guides/batch
- **Batch API Reference**: https://platform.openai.com/docs/api-reference/batch
- **Batch API FAQ**: https://help.openai.com/en/articles/9197833-batch-api-faq
- **Pricing**: https://openai.com/api/pricing/

---

**Next**: [Rate Limits →](./rate-limits.md)
