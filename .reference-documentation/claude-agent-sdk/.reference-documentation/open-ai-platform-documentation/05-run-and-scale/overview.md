# OpenAI Platform - Run and Scale Overview

**Source:** https://platform.openai.com/docs/guides/production
**Fetched:** 2025-10-11

## Overview

This section covers best practices, patterns, and tools for running OpenAI applications at scale in production environments. From batch processing to rate limits, monitoring to cost optimization—everything you need to deploy reliably.

**Key Topics:**
- Batch API for large-scale processing
- Rate limits and quotas
- Error handling and retry strategies
- Streaming responses
- Prompt caching
- Production best practices
- Monitoring and observability
- Scaling patterns
- Cost optimization
- Performance tuning

---

## Production Readiness Checklist

### Before Going to Production

**✅ Security:**
- [ ] API keys stored in environment variables
- [ ] Key rotation strategy in place
- [ ] Rate limiting on your endpoints
- [ ] Input validation and sanitization
- [ ] Output content filtering

**✅ Reliability:**
- [ ] Error handling with retries
- [ ] Fallback strategies for failures
- [ ] Health checks and monitoring
- [ ] Timeout configurations
- [ ] Circuit breakers for external dependencies

**✅ Performance:**
- [ ] Streaming enabled where appropriate
- [ ] Prompt caching configured
- [ ] Appropriate model selection
- [ ] Response size optimization
- [ ] Concurrent request handling

**✅ Cost Management:**
- [ ] Token usage tracking
- [ ] Budget alerts configured
- [ ] Batch API for offline workloads
- [ ] Model selection based on task complexity
- [ ] Prompt optimization for token efficiency

**✅ Observability:**
- [ ] Logging for all API calls
- [ ] Metrics collection (latency, errors, costs)
- [ ] Distributed tracing
- [ ] Alerting for anomalies
- [ ] Dashboard for key metrics

---

## Deployment Patterns

### Pattern 1: Synchronous Real-Time

Best for: Interactive applications, chatbots, live assistants

```python
from openai import OpenAI

client = OpenAI()

def handle_user_request(user_message):
    """Handle real-time user request."""
    try:
        response = client.chat.completions.create(
            model="gpt-5",
            messages=[{"role": "user", "content": user_message}],
            timeout=30.0,
            max_retries=2
        )
        return response.choices[0].message.content

    except openai.APITimeoutError:
        return "Request timed out. Please try again."

    except openai.RateLimitError:
        return "System is busy. Please try again in a moment."

    except Exception as e:
        log_error(e)
        return "An error occurred. Please try again later."
```

**Characteristics:**
- Low latency required (< 3 seconds)
- User waiting for response
- Handles moderate request volume
- Requires robust error handling

### Pattern 2: Asynchronous with Queue

Best for: Background processing, non-urgent tasks

```python
import asyncio
from celery import Celery

app = Celery('tasks', broker='redis://localhost:6379')

@app.task(bind=True, max_retries=3)
def process_document(self, document_id):
    """Process document asynchronously."""
    try:
        document = get_document(document_id)

        response = client.chat.completions.create(
            model="gpt-5",
            messages=[
                {
                    "role": "user",
                    "content": f"Summarize this document: {document.content}"
                }
            ]
        )

        save_summary(document_id, response.choices[0].message.content)

    except Exception as e:
        # Retry with exponential backoff
        raise self.retry(exc=e, countdown=60 * (2 ** self.request.retries))
```

**Characteristics:**
- Higher latency acceptable (minutes to hours)
- Queue-based processing
- Automatic retries
- Better resource utilization

### Pattern 3: Batch Processing

Best for: Large-scale offline processing, data analysis

```python
# Create batch job
batch_input = [
    {
        "custom_id": f"request-{i}",
        "method": "POST",
        "url": "/v1/chat/completions",
        "body": {
            "model": "gpt-5",
            "messages": [{"role": "user", "content": item}]
        }
    }
    for i, item in enumerate(items)
]

# Upload batch file
batch_file = client.files.create(
    file=json.dumps(batch_input),
    purpose="batch"
)

# Create batch job
batch_job = client.batches.create(
    input_file_id=batch_file.id,
    endpoint="/v1/chat/completions",
    completion_window="24h"
)

# Check status later
batch_status = client.batches.retrieve(batch_job.id)
```

**Characteristics:**
- 50% cost savings
- 24-hour completion window
- Handles millions of requests
- Separate quota from real-time

---

## Scaling Strategies

### Horizontal Scaling

Scale by adding more application instances.

```python
# Load balancer configuration (nginx)
upstream openai_backend {
    least_conn;  # Route to least busy server

    server backend1.example.com:5000 weight=1;
    server backend2.example.com:5000 weight=1;
    server backend3.example.com:5000 weight=1;
}

server {
    listen 80;

    location /api/chat {
        proxy_pass http://openai_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;

        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

### Vertical Scaling

Optimize single instance performance.

```python
import asyncio
from concurrent.futures import ThreadPoolExecutor

# Concurrent request handling
async def process_requests_concurrently(requests, max_concurrent=10):
    """Process multiple requests concurrently."""
    semaphore = asyncio.Semaphore(max_concurrent)

    async def process_with_limit(request):
        async with semaphore:
            return await process_request(request)

    tasks = [process_with_limit(req) for req in requests]
    return await asyncio.gather(*tasks)

# Usage
requests = [{"content": f"Request {i}"} for i in range(100)]
results = asyncio.run(process_requests_concurrently(requests, max_concurrent=10))
```

### Smart Routing

Route requests based on characteristics.

```python
def route_request(request):
    """Route request to appropriate model/endpoint."""

    # Simple queries -> faster model
    if len(request["content"]) < 100:
        model = "gpt-5-mini"
        priority = "high"

    # Complex queries -> powerful model
    elif requires_reasoning(request["content"]):
        model = "gpt-5"
        priority = "normal"

    # Batch-able queries -> batch API
    elif request.get("urgent") == False:
        return queue_for_batch(request)

    else:
        model = "gpt-5"
        priority = "normal"

    return process_realtime(request, model, priority)
```

---

## Rate Limit Management

### Understanding Rate Limits

**Types of Limits:**
- **RPM (Requests Per Minute)**: Number of API calls
- **TPM (Tokens Per Minute)**: Total tokens processed
- **RPD (Requests Per Day)**: Daily request quota

**Tier System:**
```
Free tier:    3 RPM,     40,000 TPM
Tier 1:      60 RPM,  1,000,000 TPM
Tier 2:    5,000 RPM, 10,000,000 TPM
Tier 3:   10,000 RPM, 20,000,000 TPM
Tier 4:   30,000 RPM, 50,000,000 TPM
Tier 5:   60,000 RPM,100,000,000 TPM
```

### Rate Limit Handling

```python
import time
from tenacity import retry, wait_exponential, stop_after_attempt

@retry(
    wait=wait_exponential(multiplier=1, min=2, max=60),
    stop=stop_after_attempt(5)
)
def call_with_retry(messages):
    """Call API with automatic retry on rate limits."""
    try:
        return client.chat.completions.create(
            model="gpt-5",
            messages=messages
        )
    except openai.RateLimitError as e:
        # Check headers for retry time
        retry_after = e.response.headers.get('retry-after')
        if retry_after:
            time.sleep(int(retry_after))
        raise  # Retry with exponential backoff

# Token-based rate limiting
class TokenBucketLimiter:
    def __init__(self, rate, capacity):
        self.rate = rate  # tokens per second
        self.capacity = capacity
        self.tokens = capacity
        self.last_update = time.time()

    def consume(self, tokens):
        """Try to consume tokens."""
        now = time.time()

        # Refill bucket
        elapsed = now - self.last_update
        self.tokens = min(self.capacity, self.tokens + elapsed * self.rate)
        self.last_update = now

        # Check if enough tokens
        if tokens <= self.tokens:
            self.tokens -= tokens
            return True

        return False

limiter = TokenBucketLimiter(rate=1000, capacity=10000)  # 1000 TPM

def rate_limited_call(messages):
    """Call API with token-based rate limiting."""
    # Estimate tokens
    estimated_tokens = estimate_tokens(messages) * 2  # Input + output

    # Wait if needed
    while not limiter.consume(estimated_tokens):
        time.sleep(0.1)

    return client.chat.completions.create(model="gpt-5", messages=messages)
```

---

## Error Handling Strategy

### Retry Logic

```python
from enum import Enum
import random

class ErrorType(Enum):
    RETRYABLE = "retryable"  # Network, timeout, rate limit
    NON_RETRYABLE = "non_retryable"  # Invalid request, auth
    UNKNOWN = "unknown"

def classify_error(error):
    """Classify error type."""
    if isinstance(error, (openai.APITimeoutError, openai.APIConnectionError)):
        return ErrorType.RETRYABLE

    if isinstance(error, openai.RateLimitError):
        return ErrorType.RETRYABLE

    if isinstance(error, (openai.AuthenticationError, openai.InvalidRequestError)):
        return ErrorType.NON_RETRYABLE

    return ErrorType.UNKNOWN

def call_with_smart_retry(messages, max_retries=3):
    """Call API with intelligent retry logic."""
    for attempt in range(max_retries):
        try:
            return client.chat.completions.create(
                model="gpt-5",
                messages=messages
            )

        except Exception as e:
            error_type = classify_error(e)

            if error_type == ErrorType.NON_RETRYABLE:
                raise  # Don't retry

            if attempt == max_retries - 1:
                raise  # Max retries exceeded

            # Exponential backoff with jitter
            delay = (2 ** attempt) + random.uniform(0, 1)
            time.sleep(delay)
```

### Circuit Breaker

```python
from datetime import datetime, timedelta

class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failures = 0
        self.last_failure_time = None
        self.state = "CLOSED"  # CLOSED, OPEN, HALF_OPEN

    def call(self, func, *args, **kwargs):
        """Call function with circuit breaker."""
        if self.state == "OPEN":
            if datetime.now() - self.last_failure_time > timedelta(seconds=self.timeout):
                self.state = "HALF_OPEN"
            else:
                raise Exception("Circuit breaker is OPEN")

        try:
            result = func(*args, **kwargs)

            # Success - reset failures
            if self.state == "HALF_OPEN":
                self.state = "CLOSED"
            self.failures = 0

            return result

        except Exception as e:
            self.failures += 1
            self.last_failure_time = datetime.now()

            if self.failures >= self.failure_threshold:
                self.state = "OPEN"

            raise

# Usage
breaker = CircuitBreaker(failure_threshold=5, timeout=60)

def safe_api_call(messages):
    return breaker.call(
        client.chat.completions.create,
        model="gpt-5",
        messages=messages
    )
```

---

## Cost Optimization

### Model Selection

```python
def select_optimal_model(task_complexity, token_count):
    """Select most cost-effective model."""

    # Simple tasks -> gpt-5-mini (cheaper)
    if task_complexity == "simple":
        return "gpt-5-mini"

    # Medium tasks, short context -> gpt-5-mini
    elif task_complexity == "medium" and token_count < 1000:
        return "gpt-5-mini"

    # Complex tasks or long context -> gpt-5
    else:
        return "gpt-5"

# Usage
task = analyze_task_complexity(user_message)
tokens = estimate_tokens(user_message)
model = select_optimal_model(task, tokens)
```

### Prompt Caching

```python
# Use system message caching
system_prompt = "You are a helpful assistant..." * 1000  # Long system prompt

response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "system", "content": system_prompt},  # Cached
        {"role": "user", "content": user_message}  # Not cached
    ]
)

# System prompt cached after first use
# Subsequent requests: pay only for user message tokens
```

### Cost Tracking

```python
class CostTracker:
    def __init__(self):
        self.costs = {
            "gpt-5": {"input": 1.25, "output": 10.00},  # per 1M tokens
            "gpt-5-mini": {"input": 0.15, "output": 1.20}
        }

    def calculate_cost(self, model, input_tokens, output_tokens):
        """Calculate cost for API call."""
        input_cost = (input_tokens / 1_000_000) * self.costs[model]["input"]
        output_cost = (output_tokens / 1_000_000) * self.costs[model]["output"]
        return input_cost + output_cost

    def track_call(self, response):
        """Track cost of API call."""
        usage = response.usage
        cost = self.calculate_cost(
            model=response.model,
            input_tokens=usage.prompt_tokens,
            output_tokens=usage.completion_tokens
        )

        # Log cost
        log_metric("openai_cost", cost, {
            "model": response.model,
            "user_id": current_user_id
        })

        return cost

tracker = CostTracker()
cost = tracker.track_call(response)
```

---

## Key Metrics to Monitor

### Latency Metrics

- **p50 latency**: Median response time
- **p95 latency**: 95th percentile
- **p99 latency**: 99th percentile

### Reliability Metrics

- **Success rate**: % successful requests
- **Error rate**: % failed requests
- **Retry rate**: % requests that required retries

### Cost Metrics

- **Cost per request**: Average API cost
- **Daily spend**: Total daily cost
- **Cost by user/feature**: Granular tracking

### Usage Metrics

- **Requests per minute**: API call rate
- **Tokens per minute**: Token usage rate
- **Cache hit rate**: % requests using cached responses

---

## Next Steps

Dive deeper into specific topics:

1. **[Batch API →](./batch-api.md)** - Large-scale offline processing
2. **[Rate Limits →](./rate-limits.md)** - Managing and optimizing limits
3. **[Error Handling →](./error-handling.md)** - Robust error strategies
4. **[Streaming →](./streaming.md)** - Real-time response streaming
5. **[Caching →](./caching.md)** - Optimize with prompt caching
6. **[Monitoring →](./monitoring.md)** - Observability and alerting
7. **[Cost Optimization →](./cost-optimization.md)** - Reduce spending
8. **[Performance Tuning →](./performance-tuning.md)** - Optimize speed

---

## Additional Resources

- **Production Best Practices**: https://platform.openai.com/docs/guides/production-best-practices
- **Rate Limits**: https://platform.openai.com/docs/guides/rate-limits
- **Error Codes**: https://platform.openai.com/docs/guides/error-codes
- **Batch API**: https://platform.openai.com/docs/guides/batch

---

**Next**: [Batch API →](./batch-api.md)
