# OpenAI Platform - Prompt Optimizer

**Source:** https://platform.openai.com/docs/guides/evals/prompt-optimizer
**Fetched:** 2025-10-11

## Overview

Automatically optimize prompts based on evaluation results.

---

## Using Prompt Optimizer

```python
# Define optimization goal
optimizer = PromptOptimizer(
    objective="maximize_accuracy",
    eval_dataset=eval_data
)

# Run optimization
optimized_prompt = optimizer.optimize(initial_prompt)
```

---

**Source:** https://platform.openai.com/docs/guides/evals/prompt-optimizer
