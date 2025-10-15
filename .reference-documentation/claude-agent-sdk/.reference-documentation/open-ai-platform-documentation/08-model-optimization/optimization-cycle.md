# OpenAI Platform - Optimization Cycle

**Source:** https://platform.openai.com/docs/guides/optimization-cycle
**Fetched:** 2025-10-11

## Overview

Systematic approach to optimizing model performance.

---

## Optimization Cycle

1. **Baseline** - Establish initial performance
2. **Evaluate** - Run systematic evals
3. **Identify** - Find improvement areas
4. **Optimize** - Apply improvements (prompts, fine-tuning, etc.)
5. **Measure** - Re-evaluate performance
6. **Iterate** - Repeat cycle

---

## Key Steps

### 1. Establish Baseline

```python
# Run initial eval
baseline_results = run_eval(model="gpt-4o", dataset=eval_data)
baseline_accuracy = baseline_results["accuracy"]
```

### 2. Apply Optimizations

- Prompt engineering
- Few-shot examples
- Fine-tuning
- Model selection

### 3. Measure Improvement

```python
# Compare results
improvement = new_accuracy - baseline_accuracy
```

---

**Source:** https://platform.openai.com/docs/guides/optimization-cycle
