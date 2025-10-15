# OpenAI Platform - Working with Evals

**Source:** https://platform.openai.com/docs/guides/evals/working-with-evals
**Fetched:** 2025-10-11

## Overview

Deep dive into creating, running, and analyzing evaluations.

---

## Creating Eval Datasets

```python
eval_dataset = {
    "name": "Customer Support Eval",
    "samples": [
        {"input": "...", "expected_output": "..."},
    ]
}
```

---

## Running Evals

```python
# Run eval against your model
results = run_eval(dataset, model="gpt-4o")
```

---

## Analyzing Results

```python
# Review metrics
accuracy = results["accuracy"]
latency = results["avg_latency"]
```

---

**Source:** https://platform.openai.com/docs/guides/evals/working-with-evals
