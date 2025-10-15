# OpenAI Platform - Batch API for Cost Optimization

**Source:** https://platform.openai.com/docs/guides/batch
**Fetched:** 2025-10-11

## Overview

Use Batch API for 50% cost savings on async workloads.

---

## When to Use Batch

- Large-scale processing
- Non-urgent requests
- Offline analysis
- Data processing pipelines

---

## Cost Savings

- **50% discount** on all requests
- Separate quota from real-time API
- 24-hour completion window

---

## Example

```python
# Batch processing
batch_file = client.files.create(
    file=open("batch_input.jsonl", "rb"),
    purpose="batch"
)

batch_job = client.batches.create(
    input_file_id=batch_file.id,
    endpoint="/v1/chat/completions",
    completion_window="24h"
)
```

---

**Source:** https://platform.openai.com/docs/guides/batch
