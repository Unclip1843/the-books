# OpenAI Platform - Graders

**Source:** https://platform.openai.com/docs/guides/graders
**Fetched:** 2025-10-11

## Overview

Automated grading of model outputs for evaluation.

---

## Grader Types

### Model-Based Graders

Use AI models to grade outputs:

```python
def grade_output(output, expected):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": f"""Grade this output (0-100):

Expected: {expected}
Actual: {output}

Score:"""
        }]
    )
    return int(response.choices[0].message.content)
```

### Rule-Based Graders

Use deterministic rules:

```python
def exact_match_grader(output, expected):
    return 100 if output.strip() == expected.strip() else 0
```

---

**Source:** https://platform.openai.com/docs/guides/graders
