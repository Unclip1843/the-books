# Claude API - Testing & Evaluation

**Sources:**
- https://docs.claude.com/en/docs/test-and-evaluate

**Fetched:** 2025-10-11

## Overview

Testing and evaluation ensures your Claude integration performs reliably and meets quality standards. This guide covers defining success criteria, developing test cases, and measuring performance.

## Defining Success Criteria

### Characteristics of Good Criteria

- **Specific** - Clearly defined goals
- **Measurable** - Quantitative or consistent qualitative scales
- **Achievable** - Based on realistic benchmarks
- **Relevant** - Aligned with application purpose

### Common Criteria Categories

| Category | Examples |
|----------|----------|
| **Accuracy** | Correct answers, factual precision |
| **Consistency** | Same query → similar response |
| **Relevance** | On-topic, addresses question |
| **Tone** | Professional, friendly, formal |
| **Latency** | Response time < 2 seconds |
| **Cost** | < $0.01 per request |

## Measurement Methods

### Quantitative Metrics

```python
def calculate_accuracy(predictions, ground_truth):
    correct = sum(p == g for p, g in zip(predictions, ground_truth))
    return correct / len(predictions)

def calculate_f1_score(predictions, ground_truth):
    # For classification tasks
    from sklearn.metrics import f1_score
    return f1_score(ground_truth, predictions, average='weighted')
```

### Qualitative Assessment

- **Likert scales** (1-5 rating)
- **Expert rubrics** (structured evaluation)
- **User feedback** (surveys, ratings)
- **Edge case analysis** (handle corner cases)

## Developing Test Cases

### Basic Test Suite

```python
test_cases = [
    {
        "input": "What is 2+2?",
        "expected": "4",
        "category": "math"
    },
    {
        "input": "Translate 'hello' to Spanish",
        "expected": "hola",
        "category": "translation"
    },
    {
        "input": "Summarize: [long text]",
        "expected": "[key points]",
        "category": "summarization"
    }
]
```

### Running Tests

```python
def run_test_suite(test_cases, model="claude-sonnet-4-5-20250929"):
    results = []

    for test in test_cases:
        response = client.messages.create(
            model=model,
            max_tokens=1024,
            messages=[{"role": "user", "content": test["input"]}]
        )

        result = {
            "input": test["input"],
            "expected": test["expected"],
            "actual": response.content[0].text,
            "passed": evaluate(response.content[0].text, test["expected"])
        }
        results.append(result)

    return results
```

## Evaluation Approaches

### A/B Testing

```python
def ab_test(prompt_a, prompt_b, test_cases):
    results_a = run_with_prompt(prompt_a, test_cases)
    results_b = run_with_prompt(prompt_b, test_cases)

    print(f"Prompt A accuracy: {calculate_accuracy(results_a)}")
    print(f"Prompt B accuracy: {calculate_accuracy(results_b)}")
```

### Regression Testing

```python
# Ensure changes don't break existing functionality
baseline_results = load_baseline()
current_results = run_test_suite(test_cases)

for baseline, current in zip(baseline_results, current_results):
    if baseline["passed"] and not current["passed"]:
        print(f"Regression detected: {current['input']}")
```

## Best Practices

1. **Start with clear criteria** before building
2. **Test edge cases** - unusual inputs, errors
3. **Use diverse examples** - represent real usage
4. **Automate testing** - run regularly
5. **Track metrics over time** - identify trends
6. **Iterate based on results** - continuous improvement

## Related Documentation

- [Prompt Engineering](./19-prompt-engineering.md)
- [Examples](./11-examples.md)
- [Models](./10-models.md)
