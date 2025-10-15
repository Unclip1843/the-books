# OpenAI Platform - Agent Evals

**Source:** https://platform.openai.com/docs/guides/evals/agents
**Fetched:** 2025-10-11

## Overview

Agent Evals is OpenAI's comprehensive evaluation framework for testing, measuring, and optimizing agent performance. It enables systematic testing of agentic workflows through datasets, automated grading, trace analysis, and continuous improvement.

**Key Benefits:**
- Cut development time by 50%+
- Increase agent accuracy by 30%+
- Automate quality assurance
- Track performance over time

---

## Core Components

### 1. Datasets

Build and manage evaluation datasets for your agents.

```python
from openai import OpenAI

client = OpenAI()

# Create dataset
dataset = client.evals.datasets.create(
    name="customer_support_v1",
    description="Customer support agent test cases",
    items=[
        {
            "input": "How do I reset my password?",
            "expected_output": "password_reset_flow",
            "metadata": {
                "category": "authentication",
                "difficulty": "easy"
            }
        },
        {
            "input": "My order hasn't arrived in 3 weeks",
            "expected_output": "escalate_to_human",
            "metadata": {
                "category": "shipping",
                "difficulty": "medium"
            }
        }
    ]
)
```

**Dataset Features:**
- **Versioning**: Track dataset changes over time
- **Import/Export**: CSV, JSON, JSONL formats
- **Collaborative**: Share datasets across teams
- **Expandable**: Add new cases from production

### 2. Trace Grading

Evaluate entire agent workflows end-to-end.

```python
# Run evaluation with trace grading
eval_run = client.evals.runs.create(
    dataset_id="dataset_abc123",
    agent_id="agent_xyz789",
    graders=[
        {
            "type": "llm",
            "model": "gpt-5",
            "criteria": "Response accurately addresses the user's question",
            "scale": "1-5"
        },
        {
            "type": "llm",
            "model": "gpt-5",
            "criteria": "Agent uses appropriate tools",
            "scale": "pass/fail"
        },
        {
            "type": "rule",
            "check": "response_time_ms < 3000"
        }
    ]
)

# Get results
results = client.evals.runs.retrieve(eval_run.id)
print(f"Average score: {results.average_score}")
print(f"Pass rate: {results.pass_rate}")
```

**Grader Types:**
- **LLM Graders**: Use GPT-5 to evaluate quality
- **Rule Graders**: Check specific conditions
- **Human Graders**: Manual review interface
- **Custom Graders**: Define your own logic

---

## Evaluation Metrics

### Quality Metrics

```python
# Define quality graders
quality_graders = [
    {
        "name": "accuracy",
        "type": "llm",
        "prompt": """
Rate the accuracy of the agent's response on a scale of 1-5:
1 = Completely incorrect
2 = Mostly incorrect
3 = Partially correct
4 = Mostly correct
5 = Completely correct

Input: {input}
Expected: {expected}
Actual: {output}
""",
        "scale": "1-5"
    },
    {
        "name": "helpfulness",
        "type": "llm",
        "prompt": "Rate how helpful this response is (1-5)",
        "scale": "1-5"
    },
    {
        "name": "safety",
        "type": "llm",
        "prompt": "Does this response follow safety guidelines? (yes/no)",
        "scale": "pass/fail"
    }
]
```

### Performance Metrics

```python
# Automatically tracked
performance_metrics = {
    "response_time_ms": 1234,
    "total_tokens": 567,
    "cost_usd": 0.012,
    "tool_calls": 3,
    "handoffs": 1,
    "conversation_turns": 5
}
```

### Tool Usage Metrics

```python
# Analyze tool usage
tool_analysis = {
    "tools_available": 10,
    "tools_used": 3,
    "tool_success_rate": 0.95,
    "average_tool_latency_ms": 456,
    "tool_breakdown": {
        "search_knowledge_base": 8,
        "create_ticket": 2,
        "send_email": 1
    }
}
```

---

## Eval Types

### 1. Unit Evals

Test individual agent capabilities.

```python
# Test single tool usage
unit_eval = client.evals.runs.create(
    name="test_search_tool",
    dataset_id="search_tool_dataset",
    agent_id="agent_abc123",
    eval_type="unit",
    focus="tool:search_knowledge_base"
)
```

### 2. Integration Evals

Test agent interactions and workflows.

```python
# Test multi-step workflow
integration_eval = client.evals.runs.create(
    name="test_order_fulfillment",
    dataset_id="order_flows_dataset",
    agent_id="agent_abc123",
    eval_type="integration",
    trace_full_workflow=True
)
```

### 3. Regression Evals

Ensure changes don't break existing behavior.

```python
# Compare against baseline
regression_eval = client.evals.runs.create(
    name="v2_regression_test",
    dataset_id="regression_suite",
    agent_id="agent_abc123_v2",
    baseline_agent_id="agent_abc123_v1",
    eval_type="regression"
)

# View comparison
comparison = client.evals.runs.compare(
    run_id_1=baseline_run_id,
    run_id_2=new_run_id
)
```

### 4. Stress Evals

Test agent performance under load.

```python
# Stress test
stress_eval = client.evals.runs.create(
    name="stress_test",
    dataset_id="stress_test_cases",
    agent_id="agent_abc123",
    eval_type="stress",
    concurrent_requests=100,
    duration_minutes=10
)
```

---

## Automated Grading

### LLM-Based Grading

```python
# Define LLM grader
llm_grader = {
    "type": "llm",
    "model": "gpt-5",
    "criteria": """
Evaluate the agent's response on these dimensions:

1. **Accuracy**: Does it answer the question correctly?
2. **Completeness**: Does it provide all necessary information?
3. **Clarity**: Is the response easy to understand?
4. **Tone**: Is the tone appropriate for the context?

Provide scores for each dimension (1-5) and an overall pass/fail.
""",
    "output_schema": {
        "accuracy": "integer (1-5)",
        "completeness": "integer (1-5)",
        "clarity": "integer (1-5)",
        "tone": "integer (1-5)",
        "overall": "pass/fail",
        "reasoning": "string"
    }
}
```

### Rule-Based Grading

```python
# Define rule graders
rule_graders = [
    {
        "name": "response_time",
        "type": "rule",
        "check": "response_time_ms < 3000",
        "error_message": "Response took too long"
    },
    {
        "name": "token_limit",
        "type": "rule",
        "check": "total_tokens < 2000",
        "error_message": "Response too long"
    },
    {
        "name": "required_tool",
        "type": "rule",
        "check": "'search_knowledge_base' in tools_used",
        "error_message": "Agent should have searched knowledge base"
    }
]
```

### Custom Grading Functions

```python
# Register custom grader
def custom_sentiment_grader(input_data, output_data, expected):
    """Check if response sentiment matches expected."""
    from textblob import TextBlob

    actual_sentiment = TextBlob(output_data["text"]).sentiment.polarity
    expected_sentiment = expected.get("sentiment", 0)

    # Within 0.2 tolerance
    passed = abs(actual_sentiment - expected_sentiment) < 0.2

    return {
        "passed": passed,
        "score": 1.0 if passed else 0.0,
        "details": {
            "actual_sentiment": actual_sentiment,
            "expected_sentiment": expected_sentiment
        }
    }

# Use in eval
client.evals.graders.register(
    name="sentiment_match",
    function=custom_sentiment_grader
)
```

---

## Running Evaluations

### Basic Eval Run

```python
# Run evaluation
run = client.evals.runs.create(
    name="customer_support_eval_v1",
    dataset_id="dataset_abc123",
    agent_id="agent_xyz789",
    graders=[
        {"type": "llm", "criteria": "Accuracy (1-5)"},
        {"type": "rule", "check": "response_time_ms < 3000"}
    ]
)

# Wait for completion
while run.status == "running":
    run = client.evals.runs.retrieve(run.id)
    time.sleep(1)

# View results
print(f"Status: {run.status}")
print(f"Average score: {run.average_score}")
print(f"Pass rate: {run.pass_rate}")
print(f"Failed cases: {run.failed_count}")
```

### Batch Evaluation

```python
# Evaluate multiple agents
agents_to_test = ["agent_v1", "agent_v2", "agent_v3"]

runs = []
for agent_id in agents_to_test:
    run = client.evals.runs.create(
        dataset_id="dataset_abc123",
        agent_id=agent_id,
        graders=graders
    )
    runs.append(run)

# Compare results
comparison = client.evals.runs.compare(
    run_ids=[r.id for r in runs]
)

# Best performing agent
best_agent = max(comparison, key=lambda x: x["average_score"])
print(f"Best agent: {best_agent['agent_id']}")
```

---

## Analyzing Results

### View Detailed Results

```python
# Get evaluation results
results = client.evals.runs.retrieve("run_abc123")

# Overall metrics
print(f"Pass rate: {results.pass_rate}")
print(f"Average score: {results.average_score}")
print(f"Total cost: ${results.total_cost_usd}")

# Per-case results
for case in results.cases:
    print(f"\nCase: {case.input}")
    print(f"Status: {case.status}")
    print(f"Score: {case.score}")

    # Grader feedback
    for grader_result in case.grader_results:
        print(f"  {grader_result.grader_name}: {grader_result.score}")
        if grader_result.reasoning:
            print(f"    Reason: {grader_result.reasoning}")
```

### Trace Analysis

```python
# Analyze agent traces
trace = client.evals.traces.retrieve("trace_abc123")

# View agent steps
for step in trace.steps:
    print(f"\nStep {step.index}: {step.type}")
    print(f"Duration: {step.duration_ms}ms")

    if step.type == "tool_call":
        print(f"Tool: {step.tool_name}")
        print(f"Success: {step.success}")

    if step.type == "handoff":
        print(f"From: {step.from_agent}")
        print(f"To: {step.to_agent}")

# Performance breakdown
print(f"\nTotal time: {trace.total_duration_ms}ms")
print(f"Tool time: {trace.tool_time_ms}ms")
print(f"LLM time: {trace.llm_time_ms}ms")
```

### Failed Case Analysis

```python
# Get failed cases
failed_cases = client.evals.runs.list_cases(
    run_id="run_abc123",
    status="failed"
)

# Analyze failures
failure_categories = {}
for case in failed_cases:
    category = case.metadata.get("category", "unknown")
    failure_categories[category] = failure_categories.get(category, 0) + 1

print("Failures by category:")
for category, count in failure_categories.items():
    print(f"  {category}: {count}")
```

---

## Continuous Evaluation

### Automated Eval Pipeline

```python
# Set up automated evals
eval_config = {
    "schedule": "daily",  # Run every day
    "dataset_id": "dataset_abc123",
    "agent_id": "agent_xyz789",
    "graders": graders,
    "notifications": {
        "on_failure": ["team@example.com"],
        "on_regression": ["leads@example.com"]
    },
    "thresholds": {
        "min_pass_rate": 0.95,
        "max_avg_response_time_ms": 2000
    }
}

# Create scheduled eval
schedule = client.evals.schedules.create(**eval_config)
```

### Production Sampling

```python
# Evaluate production traffic
sampling_config = {
    "agent_id": "agent_xyz789",
    "sample_rate": 0.01,  # 1% of traffic
    "graders": [
        {"type": "llm", "criteria": "Quality check (1-5)"},
        {"type": "rule", "check": "response_time_ms < 3000"}
    ],
    "alert_on_score_below": 3.5
}

# Enable production sampling
client.evals.sampling.enable(**sampling_config)
```

---

## Prompt Optimization

### Automated Prompt Improvement

```python
# Analyze failing cases
failed_cases = client.evals.runs.list_cases(
    run_id="run_abc123",
    status="failed"
)

# Generate improved prompt
optimization = client.evals.optimize.prompt(
    agent_id="agent_xyz789",
    failed_cases=failed_cases,
    optimization_goal="Improve accuracy on failed cases"
)

print("Current prompt:")
print(optimization.current_prompt)

print("\nSuggested prompt:")
print(optimization.suggested_prompt)

print("\nExpected improvement:")
print(f"+{optimization.expected_improvement_pct}% accuracy")

# Apply improved prompt
if optimization.expected_improvement_pct > 10:
    client.agents.update(
        agent_id="agent_xyz789",
        instructions=optimization.suggested_prompt
    )
```

### A/B Testing

```python
# Create variant
variant_agent = client.agents.create(
    name="Agent V2 (optimized prompt)",
    instructions=optimization.suggested_prompt,
    model="gpt-5",
    tools=original_agent.tools
)

# Run A/B test
ab_test = client.evals.ab_test.create(
    name="Prompt optimization test",
    dataset_id="dataset_abc123",
    agent_a_id="agent_v1",
    agent_b_id=variant_agent.id,
    traffic_split=0.5,  # 50/50 split
    duration_days=7
)

# Monitor results
results = client.evals.ab_test.results(ab_test.id)
if results.b_is_better and results.confidence > 0.95:
    print("Variant B is significantly better!")
```

---

## Integration Examples

### CI/CD Integration

```yaml
# .github/workflows/agent-eval.yml
name: Agent Evaluation

on:
  pull_request:
    paths:
      - 'agents/**'

jobs:
  evaluate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run evals
        run: |
          python -m openai_evals run \
            --dataset regression_suite \
            --agent-config agents/config.yaml \
            --output results.json

      - name: Check results
        run: |
          python scripts/check_eval_results.py results.json
```

### Langfuse Integration

```python
from langfuse import Langfuse
from openai import OpenAI

langfuse = Langfuse()
client = OpenAI()

# Run agent with tracing
trace = langfuse.trace(name="customer_support")

response = client.agents.run(
    agent_id="agent_abc123",
    message="How do I return my order?",
    trace_id=trace.id
)

# Evaluate trace
evaluation = langfuse.score(
    trace_id=trace.id,
    name="quality",
    value=4.5,
    comment="Good response, covered all points"
)
```

---

## Best Practices

### 1. Build Comprehensive Datasets

```python
# ✅ Good dataset
dataset = [
    # Cover edge cases
    {"input": "empty order list", "expected": "no_orders_message"},

    # Test error handling
    {"input": "invalid order ID", "expected": "error_invalid_id"},

    # Different user intents
    {"input": "cancel my order", "expected": "cancel_order_flow"},
    {"input": "track my package", "expected": "tracking_info"},

    # Varying complexity
    {"input": "simple question", "difficulty": "easy"},
    {"input": "complex multi-step task", "difficulty": "hard"}
]
```

### 2. Use Multiple Graders

```python
# Evaluate different aspects
graders = [
    {"type": "llm", "criteria": "Accuracy"},
    {"type": "llm", "criteria": "Helpfulness"},
    {"type": "llm", "criteria": "Safety"},
    {"type": "rule", "check": "response_time_ms < 3000"},
    {"type": "rule", "check": "tool_errors == 0"}
]
```

### 3. Track Over Time

```python
# Store eval results for comparison
eval_history = client.evals.runs.list(
    agent_id="agent_abc123",
    limit=30
)

# Plot trends
import matplotlib.pyplot as plt

dates = [r.created_at for r in eval_history]
scores = [r.average_score for r in eval_history]

plt.plot(dates, scores)
plt.title("Agent Performance Over Time")
plt.show()
```

### 4. Iterate Based on Results

```python
# Analyze failures -> Update agent -> Re-evaluate
def improvement_loop(agent_id, dataset_id, iterations=5):
    for i in range(iterations):
        # Run eval
        run = client.evals.runs.create(
            agent_id=agent_id,
            dataset_id=dataset_id
        )

        # Analyze failures
        failures = get_failure_patterns(run)

        # Update agent
        if failures:
            update_agent_based_on_failures(agent_id, failures)

        # Check if good enough
        if run.pass_rate > 0.95:
            break
```

---

## Additional Resources

- **Evals API Documentation**: https://platform.openai.com/docs/api-reference/evals
- **Evals GitHub**: https://github.com/openai/evals
- **Cookbook Examples**: https://cookbook.openai.com/examples/evaluation
- **AgentKit Announcement**: https://openai.com/index/introducing-agentkit

---

**Next**: [Trace Grading →](./trace-grading.md)
