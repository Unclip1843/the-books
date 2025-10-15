# OpenAI Platform - Webhooks

**Source:** https://platform.openai.com/docs/guides/webhooks
**Fetched:** 2025-10-11

## Overview

Webhooks allow your application to receive real-time notifications when events occur in OpenAI services. Instead of polling for status updates, OpenAI pushes events to your server when operations complete.

**Benefits:**
- 🔔 Real-time event notifications
- 🚫 No polling required
- ⚡ Faster response to events
- 💰 Reduced API costs
- 📊 Event-driven architecture

**Use Cases:**
- Batch job completions
- Fine-tuning completion
- File processing status
- Deep Research API results
- Async operation updates

---

## Understanding Webhooks

### How Webhooks Work

**Traditional Polling:**
```python
# ❌ Inefficient: Poll every 30 seconds
while True:
    status = client.batches.retrieve(batch_id)
    if status.status == "completed":
        break
    time.sleep(30)  # Wait and check again
```

**With Webhooks:**
```python
# ✅ Efficient: Get notified when complete
@app.post("/webhook")
async def webhook_handler(request):
    event = await request.json()
    if event["type"] == "batch.completed":
        handle_batch_completion(event["data"])
```

### Event Flow

```
1. Create operation (batch, fine-tune, etc.)
   ↓
2. OpenAI processes asynchronously
   ↓
3. Operation completes
   ↓
4. OpenAI sends HTTP POST to your webhook URL
   ↓
5. Your server processes event
   ↓
6. Return 200 OK to acknowledge
```

---

## Setting Up Webhooks

### 1. Create Webhook Endpoint

**Requirements:**
- Publicly accessible HTTPS URL
- Returns 200 OK quickly (< 5 seconds)
- Verifies webhook signatures
- Handles duplicate events (idempotent)

### 2. Register Webhook

**Via Dashboard:**
```
1. Go to Platform Settings → Webhooks
2. Click "Create webhook"
3. Enter endpoint URL: https://yourapp.com/webhook
4. Select events to subscribe to
5. Save signing secret (shown only once!)
```

**Via API:**
```python
from openai import OpenAI

client = OpenAI()

webhook = client.webhooks.create(
    url="https://yourapp.com/webhook",
    events=["batch.completed", "fine_tune.completed"],
    description="Production webhook"
)

# Save this! Shown only once
signing_secret = webhook.signing_secret
```

---

## Event Types

### Batch Events

**batch.created**
```json
{
  "type": "batch.created",
  "data": {
    "id": "batch_abc123",
    "object": "batch",
    "endpoint": "/v1/chat/completions",
    "status": "validating"
  }
}
```

**batch.in_progress**
```json
{
  "type": "batch.in_progress",
  "data": {
    "id": "batch_abc123",
    "status": "in_progress",
    "request_counts": {
      "total": 100,
      "completed": 45,
      "failed": 2
    }
  }
}
```

**batch.completed**
```json
{
  "type": "batch.completed",
  "data": {
    "id": "batch_abc123",
    "status": "completed",
    "output_file_id": "file-xyz789",
    "request_counts": {
      "total": 100,
      "completed": 98,
      "failed": 2
    }
  }
}
```

**batch.failed**
```json
{
  "type": "batch.failed",
  "data": {
    "id": "batch_abc123",
    "status": "failed",
    "errors": {
      "message": "Batch processing failed",
      "code": "batch_error"
    }
  }
}
```

### Fine-Tuning Events

**fine_tune.completed**
```json
{
  "type": "fine_tune.completed",
  "data": {
    "id": "ft-abc123",
    "model": "gpt-4o:ft-acmecorp-2025-01-01",
    "status": "succeeded",
    "trained_tokens": 50000
  }
}
```

**fine_tune.failed**
```json
{
  "type": "fine_tune.failed",
  "data": {
    "id": "ft-abc123",
    "status": "failed",
    "error": {
      "message": "Training data invalid",
      "code": "invalid_training_data"
    }
  }
}
```

### File Events

**file.processed**
```json
{
  "type": "file.processed",
  "data": {
    "id": "file-abc123",
    "purpose": "fine-tune",
    "status": "processed",
    "bytes": 1048576
  }
}
```

---

## Implementing Webhook Handler

### Basic Handler (Flask)

```python
from flask import Flask, request, jsonify
import hmac
import hashlib

app = Flask(__name__)

WEBHOOK_SECRET = "whsec_..."  # From OpenAI dashboard

@app.route('/webhook', methods=['POST'])
def webhook_handler():
    """Handle OpenAI webhook events."""
    # Verify signature
    if not verify_signature(request):
        return jsonify({"error": "Invalid signature"}), 401

    # Parse event
    event = request.json
    event_type = event.get("type")

    # Handle event
    if event_type == "batch.completed":
        handle_batch_completed(event["data"])
    elif event_type == "fine_tune.completed":
        handle_fine_tune_completed(event["data"])
    else:
        print(f"Unhandled event: {event_type}")

    # Acknowledge receipt
    return jsonify({"received": True}), 200

def verify_signature(request):
    """Verify webhook signature."""
    signature = request.headers.get('X-OpenAI-Signature')
    timestamp = request.headers.get('X-OpenAI-Timestamp')

    if not signature or not timestamp:
        return False

    # Construct signed payload
    signed_payload = f"{timestamp}.{request.data.decode()}"

    # Compute expected signature
    expected_signature = hmac.new(
        WEBHOOK_SECRET.encode(),
        signed_payload.encode(),
        hashlib.sha256
    ).hexdigest()

    # Compare signatures
    return hmac.compare_digest(signature, expected_signature)

def handle_batch_completed(data):
    """Process completed batch."""
    batch_id = data["id"]
    output_file_id = data["output_file_id"]

    # Download results
    file_response = client.files.content(output_file_id)
    results = file_response.read().decode()

    # Process results
    process_batch_results(batch_id, results)

def handle_fine_tune_completed(data):
    """Process completed fine-tune."""
    model_id = data["model"]

    # Update model in database
    update_model_status(model_id, "ready")

    # Notify user
    send_notification(f"Fine-tune complete: {model_id}")

if __name__ == '__main__':
    app.run(port=8000)
```

### FastAPI Handler

```python
from fastapi import FastAPI, Request, HTTPException, Header
import hmac
import hashlib
from typing import Optional

app = FastAPI()

WEBHOOK_SECRET = "whsec_..."

@app.post("/webhook")
async def webhook_handler(
    request: Request,
    x_openai_signature: Optional[str] = Header(None),
    x_openai_timestamp: Optional[str] = Header(None)
):
    """Handle OpenAI webhook events."""
    # Get raw body
    body = await request.body()

    # Verify signature
    if not verify_signature(body, x_openai_signature, x_openai_timestamp):
        raise HTTPException(status_code=401, detail="Invalid signature")

    # Parse event
    event = await request.json()
    event_type = event.get("type")

    # Route to handler
    handlers = {
        "batch.completed": handle_batch_completed,
        "batch.failed": handle_batch_failed,
        "fine_tune.completed": handle_fine_tune_completed,
    }

    handler = handlers.get(event_type)
    if handler:
        await handler(event["data"])
    else:
        print(f"Unhandled event: {event_type}")

    return {"received": True}

def verify_signature(body: bytes, signature: str, timestamp: str) -> bool:
    """Verify webhook signature."""
    if not signature or not timestamp:
        return False

    # Check timestamp (prevent replay attacks)
    import time
    if abs(time.time() - int(timestamp)) > 300:  # 5 minutes
        return False

    # Construct signed payload
    signed_payload = f"{timestamp}.{body.decode()}"

    # Compute expected signature
    expected = hmac.new(
        WEBHOOK_SECRET.encode(),
        signed_payload.encode(),
        hashlib.sha256
    ).hexdigest()

    return hmac.compare_digest(signature, expected)

async def handle_batch_completed(data: dict):
    """Handle batch completion."""
    batch_id = data["id"]
    output_file_id = data["output_file_id"]

    # Process asynchronously
    import asyncio
    asyncio.create_task(process_batch_results(batch_id, output_file_id))

async def handle_batch_failed(data: dict):
    """Handle batch failure."""
    batch_id = data["id"]
    error = data.get("errors", {})

    # Log error and notify
    print(f"Batch {batch_id} failed: {error}")
    await send_alert(f"Batch processing failed: {batch_id}")

async def handle_fine_tune_completed(data: dict):
    """Handle fine-tune completion."""
    model_id = data["model"]

    # Update status
    await update_model_status(model_id, "ready")

    # Deploy model
    await deploy_model(model_id)
```

---

## Security Best Practices

### 1. Verify Signatures

**Always verify webhook signatures:**

```python
import hmac
import hashlib
import time

def verify_webhook(request, secret):
    """Verify webhook authenticity."""
    signature = request.headers.get('X-OpenAI-Signature')
    timestamp = request.headers.get('X-OpenAI-Timestamp')
    body = request.get_data()

    # Check timestamp (prevent replay attacks)
    current_time = int(time.time())
    if abs(current_time - int(timestamp)) > 300:  # 5 minutes
        return False, "Timestamp too old"

    # Verify signature
    signed_payload = f"{timestamp}.{body.decode()}"
    expected_signature = hmac.new(
        secret.encode(),
        signed_payload.encode(),
        hashlib.sha256
    ).hexdigest()

    if not hmac.compare_digest(signature, expected_signature):
        return False, "Invalid signature"

    return True, None
```

### 2. Handle Idempotency

```python
import redis

redis_client = redis.Redis()

@app.post("/webhook")
async def webhook_handler(request: Request):
    """Idempotent webhook handler."""
    event = await request.json()
    event_id = event.get("id")

    # Check if already processed
    if redis_client.exists(f"webhook:{event_id}"):
        return {"received": True}  # Already processed

    # Process event
    await handle_event(event)

    # Mark as processed (expire after 24 hours)
    redis_client.setex(f"webhook:{event_id}", 86400, "processed")

    return {"received": True}
```

### 3. Rate Limiting

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["100 per hour"]
)

@app.route('/webhook', methods=['POST'])
@limiter.limit("1000 per hour")  # Per IP
def webhook_handler():
    """Rate-limited webhook handler."""
    pass
```

### 4. Secure Secret Storage

```python
import os
from cryptography.fernet import Fernet

# ✅ Good: Environment variable
WEBHOOK_SECRET = os.environ.get("OPENAI_WEBHOOK_SECRET")

# ✅ Better: Secrets manager
def get_webhook_secret():
    """Get secret from vault."""
    import boto3
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId='openai/webhook-secret')
    return response['SecretString']

# ❌ Bad: Hardcoded
WEBHOOK_SECRET = "whsec_abc123..."  # NEVER DO THIS!
```

---

## Testing Webhooks

### Local Development with ngrok

```bash
# Install ngrok
brew install ngrok  # macOS
# or download from https://ngrok.com

# Start your local server
python app.py  # Running on http://localhost:8000

# Expose to internet
ngrok http 8000

# Use ngrok URL in OpenAI dashboard
# https://abc123.ngrok.io/webhook
```

### Manual Testing

```bash
# Send test webhook event
curl -X POST https://yourapp.com/webhook \
  -H "Content-Type: application/json" \
  -H "X-OpenAI-Signature: test_signature" \
  -H "X-OpenAI-Timestamp: $(date +%s)" \
  -d '{
    "type": "batch.completed",
    "data": {
      "id": "batch_test123",
      "status": "completed"
    }
  }'
```

### Testing Framework

```python
import pytest
from unittest.mock import patch

def test_webhook_handler():
    """Test webhook processing."""
    # Mock event
    event = {
        "type": "batch.completed",
        "data": {
            "id": "batch_test123",
            "output_file_id": "file_test456"
        }
    }

    # Mock signature verification
    with patch('app.verify_signature', return_value=True):
        response = client.post('/webhook', json=event)

    assert response.status_code == 200
    assert response.json() == {"received": True}

def test_invalid_signature():
    """Test signature verification."""
    with patch('app.verify_signature', return_value=False):
        response = client.post('/webhook', json={})

    assert response.status_code == 401
```

---

## Advanced Patterns

### Event Queue Processing

```python
from celery import Celery
from flask import Flask, request

app = Flask(__name__)
celery = Celery('tasks', broker='redis://localhost:6379')

@app.post('/webhook')
def webhook_handler():
    """Queue webhook events for processing."""
    event = request.json

    # Queue for async processing
    process_webhook_event.delay(event)

    # Return immediately
    return {"received": True}, 200

@celery.task(bind=True, max_retries=3)
def process_webhook_event(self, event):
    """Process webhook event asynchronously."""
    try:
        event_type = event["type"]

        if event_type == "batch.completed":
            handle_batch_completed(event["data"])

    except Exception as e:
        # Retry on failure
        raise self.retry(exc=e, countdown=60)
```

### Webhook Retry Logic

```python
@app.post('/webhook')
async def webhook_handler(request: Request):
    """Handle webhook with retry support."""
    try:
        event = await request.json()
        await process_event(event)
        return {"received": True}

    except Exception as e:
        # Log error for debugging
        print(f"Webhook processing failed: {e}")

        # Return 500 so OpenAI retries
        return {"error": str(e)}, 500
```

### Multiple Webhook Handlers

```python
# Route events to specialized handlers
handlers = {
    "batch.completed": BatchHandler(),
    "batch.failed": BatchHandler(),
    "fine_tune.completed": FineTuneHandler(),
    "file.processed": FileHandler(),
}

@app.post('/webhook')
async def webhook_handler(request: Request):
    """Route to specialized handlers."""
    event = await request.json()
    event_type = event["type"]

    handler = handlers.get(event_type)
    if handler:
        await handler.process(event["data"])
    else:
        print(f"No handler for: {event_type}")

    return {"received": True}
```

---

## Monitoring and Logging

### Comprehensive Logging

```python
import logging
import json

logger = logging.getLogger(__name__)

@app.post('/webhook')
async def webhook_handler(request: Request):
    """Webhook with comprehensive logging."""
    # Log incoming event
    event = await request.json()
    logger.info(f"Webhook received: {event['type']}", extra={
        "event_id": event.get("id"),
        "event_type": event.get("type"),
        "timestamp": event.get("timestamp")
    })

    try:
        await process_event(event)

        logger.info(f"Webhook processed: {event['type']}")
        return {"received": True}

    except Exception as e:
        logger.error(f"Webhook processing failed: {event['type']}", exc_info=True)
        raise
```

### Metrics Tracking

```python
from prometheus_client import Counter, Histogram

webhook_events = Counter(
    'webhook_events_total',
    'Total webhook events received',
    ['event_type', 'status']
)

webhook_duration = Histogram(
    'webhook_processing_duration_seconds',
    'Time to process webhook'
)

@app.post('/webhook')
@webhook_duration.time()
async def webhook_handler(request: Request):
    """Track webhook metrics."""
    event = await request.json()
    event_type = event["type"]

    try:
        await process_event(event)
        webhook_events.labels(event_type=event_type, status="success").inc()
        return {"received": True}

    except Exception as e:
        webhook_events.labels(event_type=event_type, status="error").inc()
        raise
```

---

## Troubleshooting

### Common Issues

**Issue: Webhooks not received**

Solutions:
- Verify URL is publicly accessible (use ngrok for testing)
- Check HTTPS is configured correctly
- Verify webhook is registered in OpenAI dashboard
- Check firewall/security groups allow incoming traffic

**Issue: Signature verification fails**

Solutions:
- Verify secret matches what's in OpenAI dashboard
- Check timestamp isn't too old (< 5 minutes)
- Ensure using raw request body for verification
- Verify HMAC computation is correct

**Issue: Duplicate events**

Solutions:
- Implement idempotency with unique event IDs
- Use Redis or database to track processed events
- Return 200 OK even if already processed

---

## Next Steps

1. **[Streaming →](./streaming.md)** - Real-time response streaming
2. **[Background Mode →](./background-mode.md)** - Async processing
3. **[Batch API →](./batch-api.md)** - Large-scale processing
4. **[File Inputs →](./file-inputs.md)** - Handle file uploads

---

## Additional Resources

- **Webhook Guide**: https://platform.openai.com/docs/guides/webhooks
- **Webhook Events Reference**: https://platform.openai.com/docs/api-reference/webhook-events
- **ngrok**: https://ngrok.com
- **Security Best Practices**: https://platform.openai.com/docs/guides/production-best-practices

---

**Next**: [File Inputs →](./file-inputs.md)
