# OpenAI Platform - Background Mode & Async Processing

**Source:** https://platform.openai.com/docs/guides/background-processing
**Fetched:** 2025-10-11

## Overview

Background processing allows you to handle OpenAI API calls asynchronously, improving application responsiveness and enabling large-scale operations. This guide covers patterns and tools for implementing background jobs, task queues, and async processing.

**Use Cases:**
- Long-running API calls (don't block user)
- Batch processing of documents
- Scheduled AI tasks
- High-throughput applications
- Distributed processing across workers

---

## Why Background Processing?

### Problem: Synchronous Blocking

```python
# ❌ Bad: Blocks user for 10+ seconds
def process_document(document):
    # User waits here...
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": f"Analyze: {document}"}]
    )
    return response.choices[0].message.content

# User sees loading spinner for 10+ seconds
result = process_document(large_document)
```

### Solution: Async Background Processing

```python
# ✅ Good: Returns immediately, processes in background
def process_document_async(document_id):
    # Return immediately
    task = process_task.delay(document_id)
    return {"task_id": task.id, "status": "processing"}

# User sees: "Processing... check back soon"
# Task runs in background
```

---

## Async with asyncio

### Basic Async Client

```python
import asyncio
from openai import AsyncOpenAI

client = AsyncOpenAI()

async def async_chat(message):
    """Make async API call."""
    response = await client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": message}]
    )
    return response.choices[0].message.content

# Run single async call
result = asyncio.run(async_chat("Hello!"))
```

### Concurrent API Calls

```python
import asyncio
from openai import AsyncOpenAI

client = AsyncOpenAI()

async def process_multiple(items):
    """Process multiple items concurrently."""
    tasks = [
        client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": f"Process: {item}"}]
        )
        for item in items
    ]

    # Run all concurrently
    responses = await asyncio.gather(*tasks)

    return [r.choices[0].message.content for r in responses]

# Usage
items = ["Item 1", "Item 2", "Item 3"]
results = asyncio.run(process_multiple(items))
```

### Rate Limiting with Semaphore

```python
import asyncio
from openai import AsyncOpenAI

client = AsyncOpenAI()

async def process_with_limit(items, max_concurrent=10):
    """Process items with concurrency limit."""
    semaphore = asyncio.Semaphore(max_concurrent)

    async def process_one(item):
        async with semaphore:
            response = await client.chat.completions.create(
                model="gpt-4o",
                messages=[{"role": "user", "content": f"Process: {item}"}]
            )
            return response.choices[0].message.content

    tasks = [process_one(item) for item in items]
    return await asyncio.gather(*tasks)

# Process 100 items, max 10 at a time
results = asyncio.run(process_with_limit(items, max_concurrent=10))
```

---

## Celery Task Queue

### Setup

**Install Dependencies:**

```bash
pip install celery redis
```

**Project Structure:**

```
project/
├── celery_app.py      # Celery configuration
├── tasks.py           # Task definitions
├── app.py             # Main application
└── requirements.txt
```

### Basic Celery Configuration

**celery_app.py:**

```python
from celery import Celery

# Configure Celery
app = Celery(
    'openai_tasks',
    broker='redis://localhost:6379/0',
    backend='redis://localhost:6379/0'
)

# Configuration
app.conf.update(
    task_serializer='json',
    result_serializer='json',
    accept_content=['json'],
    timezone='UTC',
    enable_utc=True,
    task_track_started=True,
    task_time_limit=300,  # 5 minutes
    task_soft_time_limit=240,  # 4 minutes warning
)
```

### Defining Tasks

**tasks.py:**

```python
from celery_app import app
from openai import OpenAI
import time

client = OpenAI()

@app.task(bind=True, max_retries=3)
def process_document(self, document_id):
    """Process document with OpenAI API."""
    try:
        # Get document
        document = get_document(document_id)

        # Call OpenAI API
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[{
                "role": "user",
                "content": f"Analyze this document:\n\n{document.content}"
            }]
        )

        result = response.choices[0].message.content

        # Save result
        save_result(document_id, result)

        return {
            "document_id": document_id,
            "status": "completed",
            "result": result
        }

    except Exception as e:
        # Retry with exponential backoff
        raise self.retry(
            exc=e,
            countdown=60 * (2 ** self.request.retries)
        )

@app.task
def summarize_text(text):
    """Summarize text."""
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "user",
            "content": f"Summarize this text:\n\n{text}"
        }]
    )
    return response.choices[0].message.content

@app.task
def generate_title(content):
    """Generate title for content."""
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "user",
            "content": f"Generate a short title for:\n\n{content[:500]}"
        }]
    )
    return response.choices[0].message.content
```

### Using Tasks in Application

**app.py:**

```python
from flask import Flask, jsonify, request
from tasks import process_document, summarize_text
from celery.result import AsyncResult

app = Flask(__name__)

@app.route('/process', methods=['POST'])
def process():
    """Queue document for processing."""
    document_id = request.json.get('document_id')

    # Queue task
    task = process_document.delay(document_id)

    return jsonify({
        "task_id": task.id,
        "status": "queued"
    }), 202

@app.route('/status/<task_id>')
def status(task_id):
    """Check task status."""
    result = AsyncResult(task_id)

    if result.state == 'PENDING':
        response = {
            "state": result.state,
            "status": "Task is waiting..."
        }
    elif result.state == 'STARTED':
        response = {
            "state": result.state,
            "status": "Task is processing..."
        }
    elif result.state == 'SUCCESS':
        response = {
            "state": result.state,
            "status": "Task completed!",
            "result": result.result
        }
    elif result.state == 'FAILURE':
        response = {
            "state": result.state,
            "status": "Task failed",
            "error": str(result.info)
        }

    return jsonify(response)

if __name__ == '__main__':
    app.run()
```

### Running Celery Worker

```bash
# Start Redis
redis-server

# Start Celery worker
celery -A celery_app worker --loglevel=info

# Start web application
python app.py
```

---

## Advanced Celery Patterns

### Chain Tasks

Execute tasks sequentially:

```python
from celery import chain
from tasks import summarize_text, generate_title

# Chain: summarize → generate_title
workflow = chain(
    summarize_text.s("Long text..."),
    generate_title.s()
)

result = workflow.apply_async()
```

### Group Tasks

Execute tasks in parallel:

```python
from celery import group
from tasks import summarize_text

# Process multiple documents in parallel
job = group(
    summarize_text.s(doc1),
    summarize_text.s(doc2),
    summarize_text.s(doc3)
)

result = job.apply_async()
```

### Chord (Group + Callback)

Execute tasks in parallel, then run callback:

```python
from celery import chord
from tasks import summarize_text, combine_summaries

# Summarize docs in parallel, then combine
workflow = chord([
    summarize_text.s(doc1),
    summarize_text.s(doc2),
    summarize_text.s(doc3)
])(combine_summaries.s())

result = workflow.apply_async()
```

### Periodic Tasks with Celery Beat

**celery_app.py (add schedule):**

```python
from celery.schedules import crontab

app.conf.beat_schedule = {
    # Run daily report at 9 AM
    'daily-report': {
        'task': 'tasks.generate_daily_report',
        'schedule': crontab(hour=9, minute=0),
    },
    # Process pending documents every 5 minutes
    'process-pending': {
        'task': 'tasks.process_pending_documents',
        'schedule': 300.0,  # 5 minutes in seconds
    },
}
```

**Run beat scheduler:**

```bash
celery -A celery_app beat --loglevel=info
```

---

## FastAPI Background Tasks

### Simple Background Tasks

```python
from fastapi import FastAPI, BackgroundTasks
from openai import OpenAI

app = FastAPI()
client = OpenAI()

def process_in_background(document_id: str):
    """Background processing function."""
    document = get_document(document_id)

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": f"Analyze: {document.content}"
        }]
    )

    save_result(document_id, response.choices[0].message.content)

@app.post("/process")
async def process_document(document_id: str, background_tasks: BackgroundTasks):
    """Queue document for background processing."""
    background_tasks.add_task(process_in_background, document_id)

    return {"message": "Processing started", "document_id": document_id}
```

### FastAPI + Celery

```python
from fastapi import FastAPI
from tasks import process_document

app = FastAPI()

@app.post("/process")
async def process(document_id: str):
    """Queue document with Celery."""
    task = process_document.delay(document_id)

    return {
        "task_id": task.id,
        "status": "queued"
    }

@app.get("/status/{task_id}")
async def get_status(task_id: str):
    """Check Celery task status."""
    from celery.result import AsyncResult
    result = AsyncResult(task_id)

    return {
        "task_id": task_id,
        "state": result.state,
        "result": result.result if result.ready() else None
    }
```

---

## Production Patterns

### Error Handling with Retries

```python
@app.task(bind=True, max_retries=5, default_retry_delay=60)
def robust_api_call(self, prompt):
    """API call with robust error handling."""
    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": prompt}],
            timeout=30.0
        )
        return response.choices[0].message.content

    except openai.RateLimitError as e:
        # Retry after rate limit
        retry_after = int(e.response.headers.get('retry-after', 60))
        raise self.retry(exc=e, countdown=retry_after)

    except openai.APITimeoutError as e:
        # Retry timeout
        raise self.retry(exc=e, countdown=10)

    except openai.APIError as e:
        # Don't retry for certain errors
        if 'invalid_request_error' in str(e):
            raise  # Don't retry invalid requests

        # Retry other API errors
        if self.request.retries < self.max_retries:
            raise self.retry(exc=e)
        raise

    except Exception as e:
        # Log unexpected errors
        logger.exception(f"Unexpected error: {e}")
        raise
```

### Progress Tracking

```python
@app.task(bind=True)
def process_large_dataset(self, items):
    """Process with progress updates."""
    total = len(items)

    for i, item in enumerate(items):
        # Update progress
        self.update_state(
            state='PROGRESS',
            meta={
                'current': i + 1,
                'total': total,
                'percent': int((i + 1) / total * 100)
            }
        )

        # Process item
        result = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": f"Process: {item}"}]
        )

        save_result(item, result.choices[0].message.content)

    return {'status': 'complete', 'total': total}
```

### Resource Pooling

```python
from celery.signals import worker_process_init
from openai import OpenAI

# Global client (one per worker)
client = None

@worker_process_init.connect
def init_worker(**kwargs):
    """Initialize OpenAI client per worker process."""
    global client
    client = OpenAI()

@app.task
def process_with_pooled_client(prompt):
    """Use pooled client."""
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content
```

---

## Monitoring and Observability

### Celery Flower

Monitor tasks with Flower web UI:

```bash
# Install Flower
pip install flower

# Start Flower
celery -A celery_app flower

# Access at http://localhost:5555
```

### Custom Monitoring

```python
from celery.signals import task_prerun, task_postrun, task_failure
import logging

logger = logging.getLogger(__name__)

@task_prerun.connect
def task_prerun_handler(sender=None, task_id=None, task=None, **kwargs):
    """Log when task starts."""
    logger.info(f"Task {task.name} started: {task_id}")

@task_postrun.connect
def task_postrun_handler(sender=None, task_id=None, task=None, retval=None, **kwargs):
    """Log when task completes."""
    logger.info(f"Task {task.name} completed: {task_id}")

@task_failure.connect
def task_failure_handler(sender=None, task_id=None, exception=None, **kwargs):
    """Log when task fails."""
    logger.error(f"Task {sender.name} failed: {task_id}, Error: {exception}")
```

---

## Best Practices

### 1. Use Appropriate Method

| Use Case | Method | Reason |
|----------|--------|--------|
| Simple, short tasks | FastAPI BackgroundTasks | Lightweight, no dependencies |
| Concurrent API calls | asyncio | Built-in, efficient |
| Production queues | Celery | Robust, scalable, retries |
| Scheduled tasks | Celery Beat | Built-in scheduling |
| Very large batches | Batch API | 50% cost savings |

### 2. Set Timeouts

```python
@app.task(time_limit=300, soft_time_limit=240)
def process_task(data):
    """Task with timeout."""
    # Will raise exception after 5 minutes
    pass
```

### 3. Implement Idempotency

```python
@app.task
def idempotent_task(item_id):
    """Task that can safely retry."""
    # Check if already processed
    if is_processed(item_id):
        return {"status": "already_processed"}

    # Process
    result = process_item(item_id)

    # Mark as processed
    mark_processed(item_id)

    return result
```

### 4. Monitor Costs

```python
@app.task
def cost_aware_task(prompt):
    """Track API costs."""
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}]
    )

    # Calculate cost
    input_cost = response.usage.prompt_tokens * 0.0025 / 1000
    output_cost = response.usage.completion_tokens * 0.01 / 1000
    total_cost = input_cost + output_cost

    # Log cost
    log_cost(task_id=self.request.id, cost=total_cost)

    return response.choices[0].message.content
```

---

## Next Steps

1. **[Streaming →](./streaming.md)** - Real-time response streaming
2. **[Webhooks →](./webhooks.md)** - Event-driven architecture
3. **[Batch API →](./batch-api.md)** - Large-scale processing
4. **[File Inputs →](./file-inputs.md)** - Handle file uploads

---

## Additional Resources

- **Celery Documentation**: https://docs.celeryproject.org/
- **AsyncOpenAI**: https://github.com/openai/openai-python#async-usage
- **FastAPI Background Tasks**: https://fastapi.tiangolo.com/tutorial/background-tasks/
- **Redis**: https://redis.io/

---

**Next**: [Streaming →](./streaming.md)
