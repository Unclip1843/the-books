# OpenAI Platform - Supervised Fine-Tuning

**Source:** https://platform.openai.com/docs/guides/fine-tuning
**Fetched:** 2025-10-11

## Overview

Fine-tune models on your data for improved performance.

---

## Process

### 1. Prepare Training Data

```python
training_data = [
    {
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "What is 2+2?"},
            {"role": "assistant", "content": "4"}
        ]
    },
    # More examples...
]

# Save as JSONL
with open("training.jsonl", "w") as f:
    for example in training_data:
        f.write(json.dumps(example) + "\n")
```

### 2. Upload Training File

```python
with open("training.jsonl", "rb") as f:
    training_file = client.files.create(
        file=f,
        purpose="fine-tune"
    )
```

### 3. Create Fine-Tuning Job

```python
job = client.fine_tuning.jobs.create(
    training_file=training_file.id,
    model="gpt-4o-mini-2025-07-18"
)
```

### 4. Monitor Progress

```python
# Check status
status = client.fine_tuning.jobs.retrieve(job.id)
print(status.status)  # validating_files, running, succeeded, failed
```

### 5. Use Fine-Tuned Model

```python
response = client.chat.completions.create(
    model=status.fine_tuned_model,
    messages=[{"role": "user", "content": "Test"}]
)
```

---

**Source:** https://platform.openai.com/docs/guides/fine-tuning
