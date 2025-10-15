# OpenAI Platform - Rate Limits

**Source:** https://platform.openai.com/docs/guides/rate-limits
**Fetched:** 2025-10-11

## Overview

Rate limits control how many requests you can make to the OpenAI API. Understanding and managing rate limits is crucial for building reliable production applications.

**Types of Limits:**
- **RPM**: Requests Per Minute
- **TPM**: Tokens Per Minute
- **RPD**: Requests Per Day
- **Batch Queue Limit**: Enqueued tokens for batch processing

---

## Usage Tiers

OpenAI uses a tier system based on your usage and payment history:

| Tier | Qualification | RPM | TPM | Batch Queue |
|------|---------------|-----|-----|-------------|
| Free | New account | 3 | 40,000 | 200,000 |
| Tier 1 | $5 paid | 60 | 1,000,000 | 2,000,000 |
| Tier 2 | $50 paid + 7 days | 5,000 | 10,000,000 | 20,000,000 |
| Tier 3 | $100 paid + 7 days | 10,000 | 20,000,000 | 40,000,000 |
| Tier 4 | $1,000 paid + 14 days | 30,000 | 50,000,000 | 100,000,000 |
| Tier 5 | $5,000 paid + 30 days | 60,000 | 100,000,000 | 200,000,000 |

**Note**: Limits shown are for gpt-5. Other models may have different limits.

### Checking Your Tier

```python
from openai import OpenAI

client = OpenAI()

# Check usage and limits via headers
response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Hi"}]
)

# Response headers contain rate limit info:
# x-ratelimit-limit-requests: 60
# x-ratelimit-limit-tokens: 1000000
# x-ratelimit-remaining-requests: 59
# x-ratelimit-remaining-tokens: 999500
# x-ratelimit-reset-requests: 1s
# x-ratelimit-reset-tokens: 30ms
```

---

## Understanding Rate Limits

### Request-Based Limits (RPM)

Limits the number of API calls per minute.

```python
# Example: Tier 1 has 60 RPM limit
# This means:
# - Can make 60 requests in any 60-second window
# - After 60 requests, must wait until requests "expire" from the window
```

### Token-Based Limits (TPM)

Limits total tokens (input + output) per minute.

```python
# Example: Tier 1 has 1,000,000 TPM limit
# Request with 500 input + 500 output tokens = 1,000 tokens total
# Can make ~1,000 such requests per minute before hitting TPM limit

# TPM usually limits first for large batches
```

### How Limits Reset

**Rolling Window**: Limits reset continuously, not at fixed intervals.

```python
# Example RPM limit: 60
# 12:00:00 - Make 60 requests
# 12:00:30 - Still at limit
# 12:01:00 - First request from 12:00:00 expires, can make 1 new request
# 12:01:01 - Second request expires, can make 1 more, etc.
```

---

## Rate Limit Errors

### Error Response

```json
{
  "error": {
    "message": "Rate limit reached for requests",
    "type": "rate_limit_error",
    "param": null,
    "code": "rate_limit_exceeded"
  }
}
```

### Error Handling

```python
import time
from openai import OpenAI, RateLimitError

client = OpenAI()

def call_with_backoff(messages, max_retries=5):
    """Call API with exponential backoff on rate limits."""
    for attempt in range(max_retries):
        try:
            return client.chat.completions.create(
                model="gpt-5",
                messages=messages
            )

        except RateLimitError as e:
            if attempt == max_retries - 1:
                raise

            # Check retry-after header
            retry_after = e.response.headers.get('retry-after')
            if retry_after:
                wait_time = int(retry_after)
            else:
                # Exponential backoff
                wait_time = (2 ** attempt) + random.uniform(0, 1)

            print(f"Rate limited. Waiting {wait_time}s...")
            time.sleep(wait_time)
```

---

## Avoiding Rate Limits

### 1. Batch Requests

Reduce RPM by batching multiple operations.

```python
# ❌ Bad: Sequential requests (uses 100 RPM)
for item in items:  # 100 items
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[{"role": "user", "content": f"Process {item}"}]
    )

# ✅ Good: Batch processing (uses 1 RPM or batch API)
# Option 1: Use Batch API
batch_input = [
    {
        "custom_id": f"item-{i}",
        "method": "POST",
        "url": "/v1/chat/completions",
        "body": {
            "model": "gpt-5",
            "messages": [{"role": "user", "content": f"Process {item}"}]
        }
    }
    for i, item in enumerate(items)
]

# Option 2: Process multiple items per request
chunks = [items[i:i+10] for i in range(0, len(items), 10)]
for chunk in chunks:
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "user",
                "content": f"Process these items: {json.dumps(chunk)}"
            }
        ]
    )
```

### 2. Use Smaller Models

Reduce TPM usage with efficient model selection.

```python
def select_model(task_complexity, estimated_tokens):
    """Choose model based on task and token budget."""

    # Simple tasks -> gpt-5-mini (cheaper, lower TPM usage)
    if task_complexity == "simple":
        return "gpt-5-mini"

    # Complex but short -> gpt-5-mini
    elif task_complexity == "medium" and estimated_tokens < 1000:
        return "gpt-5-mini"

    # Complex or long -> gpt-5
    else:
        return "gpt-5"

model = select_model("simple", 500)
response = client.chat.completions.create(
    model=model,
    messages=messages
)
```

### 3. Optimize Token Usage

Reduce TPM consumption by minimizing tokens.

```python
# ❌ Bad: Wasteful token usage
messages = [
    {
        "role": "system",
        "content": "You are a helpful assistant. " * 100  # Wasteful
    },
    {"role": "user", "content": user_message}
]

# ✅ Good: Optimized tokens
messages = [
    {
        "role": "system",
        "content": "You are a helpful assistant."  # Concise
    },
    {"role": "user", "content": user_message}
]

# Use max_tokens to limit output
response = client.chat.completions.create(
    model="gpt-5",
    messages=messages,
    max_tokens=500  # Limit response length
)
```

### 4. Implement Request Queuing

Smooth out request spikes with a queue.

```python
import asyncio
from asyncio import Queue

class RateLimitedClient:
    def __init__(self, rpm_limit=60):
        self.rpm_limit = rpm_limit
        self.queue = Queue()
        self.request_times = []

    async def call(self, **kwargs):
        """Make rate-limited API call."""
        # Add to queue
        await self.queue.put(kwargs)

        # Wait for our turn
        return await self._process_queue()

    async def _process_queue(self):
        """Process requests respecting rate limits."""
        now = time.time()

        # Remove requests older than 60 seconds
        self.request_times = [
            t for t in self.request_times
            if now - t < 60
        ]

        # Check if at limit
        if len(self.request_times) >= self.rpm_limit:
            # Wait until oldest request expires
            wait_time = 60 - (now - self.request_times[0])
            await asyncio.sleep(wait_time)

        # Make request
        kwargs = await self.queue.get()
        self.request_times.append(time.time())

        return client.chat.completions.create(**kwargs)

# Usage
limited_client = RateLimitedClient(rpm_limit=60)
response = await limited_client.call(
    model="gpt-5",
    messages=[{"role": "user", "content": "Hello"}]
)
```

### 5. Use Prompt Caching

Reduce TPM by caching repeated content.

```python
# System prompt is cached after first use
large_system_prompt = "Long system prompt..." * 1000

# First request: pays for full system prompt
response1 = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "system", "content": large_system_prompt},  # Cached
        {"role": "user", "content": "Question 1"}
    ]
)

# Subsequent requests: discounted tokens for cached content
response2 = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "system", "content": large_system_prompt},  # From cache
        {"role": "user", "content": "Question 2"}
    ]
)
# Pay only for uncached portion (user message + output)
```

---

## Monitoring Rate Limits

### Track Usage in Real-Time

```python
import logging

class RateLimitMonitor:
    def __init__(self):
        self.requests_made = 0
        self.tokens_used = 0

    def log_request(self, response):
        """Log request and track usage."""
        self.requests_made += 1

        if hasattr(response, 'usage'):
            tokens = response.usage.total_tokens
            self.tokens_used += tokens

            # Log metrics
            logging.info(
                f"Request {self.requests_made}: {tokens} tokens used. "
                f"Total: {self.tokens_used} tokens"
            )

        # Check headers for limits
        headers = response.headers if hasattr(response, 'headers') else {}

        remaining_requests = headers.get('x-ratelimit-remaining-requests')
        remaining_tokens = headers.get('x-ratelimit-remaining-tokens')

        if remaining_requests:
            logging.info(f"Remaining requests: {remaining_requests}")

        if remaining_tokens:
            logging.info(f"Remaining tokens: {remaining_tokens}")

            # Warn if close to limit
            if int(remaining_tokens) < 100000:
                logging.warning("Approaching token limit!")

monitor = RateLimitMonitor()
response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Hello"}]
)
monitor.log_request(response)
```

### Set Up Alerts

```python
def check_rate_limit_usage():
    """Alert if approaching rate limits."""
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[{"role": "user", "content": "test"}]
    )

    headers = response.headers if hasattr(response, 'headers') else {}

    remaining_pct = (
        int(headers.get('x-ratelimit-remaining-requests', 60)) /
        int(headers.get('x-ratelimit-limit-requests', 60))
    )

    if remaining_pct < 0.2:  # Less than 20% remaining
        send_alert(f"Rate limit at {remaining_pct*100:.0f}%!")

# Check periodically
import schedule

schedule.every(1).minutes.do(check_rate_limit_usage)
```

---

## Advanced Strategies

### Distributed Rate Limiting

For multiple application instances.

```python
import redis

class DistributedRateLimiter:
    def __init__(self, redis_client, key_prefix="ratelimit"):
        self.redis = redis_client
        self.key_prefix = key_prefix

    def acquire(self, limit=60, window=60):
        """Try to acquire rate limit token."""
        key = f"{self.key_prefix}:requests"
        now = time.time()

        # Sliding window with Redis sorted set
        pipe = self.redis.pipeline()

        # Remove old entries
        pipe.zremrangebyscore(key, 0, now - window)

        # Count recent requests
        pipe.zcard(key)

        # Add current request
        pipe.zadd(key, {str(now): now})

        # Set expiry
        pipe.expire(key, window)

        results = pipe.execute()
        count = results[1]

        return count < limit

# Usage with Redis
redis_client = redis.Redis(host='localhost', port=6379)
limiter = DistributedRateLimiter(redis_client)

if limiter.acquire(limit=60):
    response = client.chat.completions.create(...)
else:
    time.sleep(1)  # Wait and retry
```

### Dynamic Rate Adjustment

Adjust request rate based on current limits.

```python
class AdaptiveRateLimiter:
    def __init__(self, initial_rpm=60):
        self.current_rpm = initial_rpm
        self.min_rpm = 1
        self.max_rpm = 1000

    def adjust_rate(self, response):
        """Adjust rate based on response headers."""
        headers = response.headers if hasattr(response, 'headers') else {}

        remaining = int(headers.get('x-ratelimit-remaining-requests', 60))
        limit = int(headers.get('x-ratelimit-limit-requests', 60))

        utilization = 1 - (remaining / limit)

        # Increase rate if utilization is low
        if utilization < 0.5:
            self.current_rpm = min(self.max_rpm, self.current_rpm * 1.1)

        # Decrease rate if utilization is high
        elif utilization > 0.9:
            self.current_rpm = max(self.min_rpm, self.current_rpm * 0.9)

        return self.current_rpm

limiter = AdaptiveRateLimiter()
```

---

## Common Patterns

### Pattern 1: Burst with Cooldown

Handle occasional bursts while staying under limits.

```python
def handle_burst(requests, rpm_limit=60):
    """Process burst of requests with rate limiting."""
    batch_size = rpm_limit
    batches = [requests[i:i+batch_size] for i in range(0, len(requests), batch_size)]

    results = []
    for i, batch in enumerate(batches):
        # Process batch
        for request in batch:
            result = client.chat.completions.create(**request)
            results.append(result)

        # Wait 60s before next batch (except last)
        if i < len(batches) - 1:
            time.sleep(60)

    return results
```

### Pattern 2: Priority Queue

Prioritize important requests.

```python
from queue import PriorityQueue

class PriorityRateLimiter:
    def __init__(self, rpm_limit=60):
        self.rpm_limit = rpm_limit
        self.queue = PriorityQueue()

    def add_request(self, priority, request):
        """Add request to priority queue."""
        self.queue.put((priority, request))

    async def process(self):
        """Process requests by priority."""
        while not self.queue.empty():
            priority, request = self.queue.get()

            # Rate limit
            await self._wait_if_needed()

            # Process
            result = client.chat.completions.create(**request)

            yield result

# Usage
limiter = PriorityRateLimiter()

# Add requests with priorities (lower number = higher priority)
limiter.add_request(1, {"model": "gpt-5", "messages": urgent_messages})
limiter.add_request(5, {"model": "gpt-5", "messages": normal_messages})
limiter.add_request(10, {"model": "gpt-5", "messages": low_priority_messages})

# Process in priority order
async for result in limiter.process():
    handle_result(result)
```

---

## Increasing Your Tier

### Requirements

To move to a higher tier:
1. Make qualifying payment ($5, $50, $100, $1k, or $5k)
2. Wait required period (7, 14, or 30 days)
3. Demonstrate responsible usage

### Best Practices for Tier Progression

```python
# 1. Build usage gradually
# Start with smaller workloads, scale up over time

# 2. Monitor your usage
# Track RPM and TPM to stay within limits

# 3. Implement error handling
# Gracefully handle rate limits

# 4. Use appropriate models
# Don't use gpt-5 for simple tasks

# 5. Optimize token usage
# Minimize unnecessary tokens
```

---

## Additional Resources

- **Rate Limits Guide**: https://platform.openai.com/docs/guides/rate-limits
- **Usage Dashboard**: https://platform.openai.com/usage
- **Batch API**: https://platform.openai.com/docs/guides/batch
- **Error Codes**: https://platform.openai.com/docs/guides/error-codes

---

**Next**: [Error Handling →](./error-handling.md)
