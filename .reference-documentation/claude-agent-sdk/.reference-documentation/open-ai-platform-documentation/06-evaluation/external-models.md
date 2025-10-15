# OpenAI Platform - External Models

**Source:** https://platform.openai.com/docs/guides/evals/external-models
**Fetched:** 2025-10-11

## Overview

Evaluate external models alongside OpenAI models.

---

## Comparing Models

```python
# Compare OpenAI model vs external model
results_openai = run_eval(dataset, model="gpt-4o")
results_external = run_eval(dataset, model=external_model)

# Compare metrics
compare_results(results_openai, results_external)
```

---

**Source:** https://platform.openai.com/docs/guides/evals/external-models
