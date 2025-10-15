# OpenAI Platform - Trace Grading

**Source:** https://platform.openai.com/docs/guides/evals/trace-grading
**Fetched:** 2025-10-11

## Overview

Trace grading enables end-to-end assessment of agentic workflows by analyzing complete execution traces. It automatically grades agent behavior, tool usage, handoffs, and overall performance to identify bottlenecks and improvement opportunities.

**Key Capabilities:**
- End-to-end workflow evaluation
- Automated grading at scale
- Step-by-step analysis
- Performance profiling
- Pattern detection

---

## Traces and Spans

### Understanding Traces

A **trace** represents a single end-to-end operation of an agent workflow.

```python
from openai import OpenAI

client = OpenAI()

# Run agent with tracing enabled
response = client.agents.run(
    agent_id="agent_abc123",
    message="Book a flight to San Francisco",
    trace_config={
        "enabled": True,
        "workflow_name": "flight_booking",
        "group_id": "conversation_xyz"  # Link related traces
    }
)

# Get trace ID
trace_id = response.trace_id
```

**Trace Properties:**
- `trace_id`: Unique identifier for this execution
- `workflow_name`: Logical workflow or app name
- `group_id`: Links multiple traces from same conversation
- `start_time`: When execution started
- `end_time`: When execution completed
- `status`: success, error, timeout
- `spans`: All operations within this trace

### Understanding Spans

A **span** represents an operation within a trace with start and end time.

**Span Types:**
1. **Agent Span**: Agent execution
2. **Generation Span**: LLM generation
3. **Function Span**: Tool execution
4. **Guardrail Span**: Safety check
5. **Handoff Span**: Agent handoff
6. **Custom Span**: User-defined operation

```python
# Retrieve trace with all spans
trace = client.traces.retrieve(trace_id)

for span in trace.spans:
    print(f"{span.type}: {span.name}")
    print(f"Duration: {span.duration_ms}ms")
    print(f"Status: {span.status}")
```

---

## Trace Collection

### Automatic Tracing

Tracing is enabled by default in the Agents SDK.

```python
from openai_agents import Agent, Runner

agent = Agent(
    name="BookingAgent",
    instructions="Help users book flights",
    model="gpt-5",
    tools=[search_flights, book_flight]
)

runner = Runner()

# Automatically traced
response = runner.run(
    agent=agent,
    messages=[{"role": "user", "content": "Book flight to SF"}]
)

# Access trace
trace = runner.get_trace()
print(f"Trace ID: {trace.id}")
print(f"Total duration: {trace.duration_ms}ms")
print(f"Spans: {len(trace.spans)}")
```

### Custom Spans

Add custom spans to track specific operations.

```python
from openai_agents import Runner, custom_span

runner = Runner()

# Custom span for business logic
with custom_span(name="validate_booking", data={"user_id": "123"}):
    # Your custom logic
    is_valid = validate_user_booking(user_id, flight_id)

    if not is_valid:
        raise ValueError("Invalid booking")

# Custom span is captured in trace
trace = runner.get_trace()
```

---

## Grading Traces

### Setting Up Trace Grading

```python
# Define trace graders
trace_graders = [
    {
        "name": "workflow_success",
        "type": "llm",
        "model": "gpt-5",
        "criteria": """
Evaluate the entire agent workflow:

1. Did the agent accomplish the user's goal?
2. Were the right tools called in the right order?
3. Were there any unnecessary steps?
4. Was the final response appropriate?

Score: 1-5 (5 = perfect execution)
""",
        "inputs": {
            "user_goal": "{original_message}",
            "trace": "{trace}",
            "final_response": "{final_response}"
        }
    },
    {
        "name": "tool_usage",
        "type": "llm",
        "criteria": "Rate the appropriateness of tool usage (1-5)",
        "focus": "spans[type=function]"
    },
    {
        "name": "handoff_quality",
        "type": "llm",
        "criteria": "Rate the quality of agent handoffs (1-5)",
        "focus": "spans[type=handoff]"
    }
]

# Grade traces
grading_run = client.evals.traces.grade(
    trace_ids=[trace_id],
    graders=trace_graders
)
```

### Automated Trace Grading

Grade traces at scale automatically.

```python
# Grade last 1000 traces
grading_run = client.evals.traces.grade(
    workflow_name="flight_booking",
    limit=1000,
    graders=trace_graders,
    filter={
        "start_date": "2025-10-01",
        "end_date": "2025-10-11",
        "status": "success"
    }
)

# Get results
results = client.evals.traces.grading_results(grading_run.id)
print(f"Average workflow score: {results.average_score}")
print(f"Pass rate: {results.pass_rate}")
```

---

## Analyzing Traces

### Trace Overview

```python
# Get trace details
trace = client.traces.retrieve(trace_id)

print(f"Workflow: {trace.workflow_name}")
print(f"Duration: {trace.duration_ms}ms")
print(f"Status: {trace.status}")
print(f"Spans: {len(trace.spans)}")
print(f"Cost: ${trace.total_cost_usd}")

# Breakdown by type
span_types = {}
for span in trace.spans:
    span_types[span.type] = span_types.get(span.type, 0) + 1

print("\nSpan breakdown:")
for span_type, count in span_types.items():
    print(f"  {span_type}: {count}")
```

### Performance Analysis

```python
# Analyze performance
def analyze_trace_performance(trace):
    total_time = trace.duration_ms
    llm_time = sum(s.duration_ms for s in trace.spans if s.type == "generation")
    tool_time = sum(s.duration_ms for s in trace.spans if s.type == "function")
    other_time = total_time - llm_time - tool_time

    return {
        "total_ms": total_time,
        "llm_ms": llm_time,
        "llm_pct": (llm_time / total_time) * 100,
        "tool_ms": tool_time,
        "tool_pct": (tool_time / total_time) * 100,
        "overhead_ms": other_time,
        "overhead_pct": (other_time / total_time) * 100
    }

perf = analyze_trace_performance(trace)
print(f"LLM: {perf['llm_pct']:.1f}%")
print(f"Tools: {perf['tool_pct']:.1f}%")
print(f"Overhead: {perf['overhead_pct']:.1f}%")
```

### Tool Usage Analysis

```python
# Analyze tool usage
def analyze_tool_usage(trace):
    tool_calls = [s for s in trace.spans if s.type == "function"]

    analysis = {
        "total_calls": len(tool_calls),
        "successful_calls": len([t for t in tool_calls if t.status == "success"]),
        "failed_calls": len([t for t in tool_calls if t.status == "error"]),
        "tools_used": {},
        "avg_duration_ms": sum(t.duration_ms for t in tool_calls) / len(tool_calls) if tool_calls else 0
    }

    for tool_call in tool_calls:
        tool_name = tool_call.name
        analysis["tools_used"][tool_name] = analysis["tools_used"].get(tool_name, 0) + 1

    return analysis

tool_analysis = analyze_tool_usage(trace)
print(f"Tool calls: {tool_analysis['total_calls']}")
print(f"Success rate: {tool_analysis['successful_calls'] / tool_analysis['total_calls'] * 100:.1f}%")
print(f"Tools used: {tool_analysis['tools_used']}")
```

### Handoff Analysis

```python
# Analyze handoffs
def analyze_handoffs(trace):
    handoffs = [s for s in trace.spans if s.type == "handoff"]

    analysis = {
        "total_handoffs": len(handoffs),
        "handoff_chain": [],
        "avg_handoff_time_ms": sum(h.duration_ms for h in handoffs) / len(handoffs) if handoffs else 0
    }

    for handoff in handoffs:
        analysis["handoff_chain"].append({
            "from": handoff.source_agent,
            "to": handoff.destination_agent,
            "duration_ms": handoff.duration_ms
        })

    return analysis

handoff_analysis = analyze_handoffs(trace)
print(f"Handoffs: {handoff_analysis['total_handoffs']}")
print("Handoff chain:")
for h in handoff_analysis["handoff_chain"]:
    print(f"  {h['from']} → {h['to']} ({h['duration_ms']}ms)")
```

---

## Trace Comparison

### Compare Traces

```python
# Compare two traces
comparison = client.traces.compare(
    trace_id_1=baseline_trace_id,
    trace_id_2=new_trace_id
)

print("Comparison:")
print(f"Duration: {comparison.trace_1.duration_ms}ms → {comparison.trace_2.duration_ms}ms")
print(f"Tool calls: {comparison.trace_1.tool_calls} → {comparison.trace_2.tool_calls}")
print(f"Cost: ${comparison.trace_1.cost_usd} → ${comparison.trace_2.cost_usd}")

if comparison.trace_2.duration_ms < comparison.trace_1.duration_ms:
    improvement = ((comparison.trace_1.duration_ms - comparison.trace_2.duration_ms) / comparison.trace_1.duration_ms) * 100
    print(f"Performance improved by {improvement:.1f}%")
```

### Batch Comparison

```python
# Compare multiple traces
traces = client.traces.list(
    workflow_name="flight_booking",
    limit=100
)

# Find fastest and slowest
fastest = min(traces, key=lambda t: t.duration_ms)
slowest = max(traces, key=lambda t: t.duration_ms)

print(f"Fastest: {fastest.duration_ms}ms")
print(f"Slowest: {slowest.duration_ms}ms")
print(f"Average: {sum(t.duration_ms for t in traces) / len(traces):.0f}ms")

# Analyze slowest trace
slow_trace = client.traces.retrieve(slowest.id)
print("\nBottlenecks in slowest trace:")
for span in sorted(slow_trace.spans, key=lambda s: s.duration_ms, reverse=True)[:5]:
    print(f"  {span.name}: {span.duration_ms}ms")
```

---

## Pattern Detection

### Identify Common Patterns

```python
# Analyze many traces to find patterns
def find_patterns(traces):
    patterns = {
        "tool_sequences": {},
        "common_failures": {},
        "handoff_patterns": {}
    }

    for trace in traces:
        # Tool sequences
        tool_sequence = " → ".join([
            s.name for s in trace.spans if s.type == "function"
        ])
        patterns["tool_sequences"][tool_sequence] = patterns["tool_sequences"].get(tool_sequence, 0) + 1

        # Failures
        if trace.status == "error":
            error_type = trace.error.type
            patterns["common_failures"][error_type] = patterns["common_failures"].get(error_type, 0) + 1

        # Handoffs
        handoff_sequence = " → ".join([
            f"{s.source_agent}→{s.destination_agent}" for s in trace.spans if s.type == "handoff"
        ])
        if handoff_sequence:
            patterns["handoff_patterns"][handoff_sequence] = patterns["handoff_patterns"].get(handoff_sequence, 0) + 1

    return patterns

traces = client.traces.list(workflow_name="flight_booking", limit=1000)
patterns = find_patterns(traces)

print("Most common tool sequences:")
for seq, count in sorted(patterns["tool_sequences"].items(), key=lambda x: x[1], reverse=True)[:5]:
    print(f"  {seq}: {count} times")
```

---

## Optimization with Trace Grading

### Identify Optimization Opportunities

```python
# Grade traces and find optimization opportunities
grading_run = client.evals.traces.grade(
    workflow_name="flight_booking",
    limit=500,
    graders=[
        {"type": "llm", "criteria": "Overall quality (1-5)"},
        {"type": "rule", "check": "duration_ms < 5000"},
        {"type": "rule", "check": "tool_errors == 0"}
    ]
)

# Get low-scoring traces
low_scores = client.evals.traces.grading_results(
    grading_run.id,
    filter={"score_below": 3}
)

# Analyze what's wrong
optimization_insights = client.evals.traces.analyze_failures(
    trace_ids=[t.trace_id for t in low_scores]
)

print("Optimization opportunities:")
for insight in optimization_insights:
    print(f"- {insight.issue}")
    print(f"  Impact: {insight.affected_traces} traces")
    print(f"  Suggestion: {insight.suggestion}")
```

### A/B Test with Trace Grading

```python
# Compare two agent versions
agent_v1_traces = client.traces.list(agent_id="agent_v1", limit=500)
agent_v2_traces = client.traces.list(agent_id="agent_v2", limit=500)

# Grade both
v1_grading = client.evals.traces.grade(
    trace_ids=[t.id for t in agent_v1_traces],
    graders=graders
)

v2_grading = client.evals.traces.grade(
    trace_ids=[t.id for t in agent_v2_traces],
    graders=graders
)

# Compare results
v1_results = client.evals.traces.grading_results(v1_grading.id)
v2_results = client.evals.traces.grading_results(v2_grading.id)

print(f"V1 average score: {v1_results.average_score}")
print(f"V2 average score: {v2_results.average_score}")

improvement = ((v2_results.average_score - v1_results.average_score) / v1_results.average_score) * 100
print(f"Improvement: {improvement:+.1f}%")
```

---

## Integration with Third-Party Tools

### Langfuse Integration

```python
from langfuse import Langfuse
from openai_agents import Runner

langfuse = Langfuse()
runner = Runner()

# Run agent with Langfuse tracing
trace = langfuse.trace(name="flight_booking")

response = runner.run(
    agent=agent,
    messages=[{"role": "user", "content": "Book flight"}],
    trace_id=trace.id
)

# Langfuse automatically captures spans
# View in Langfuse UI at https://cloud.langfuse.com
```

### Logfire Integration

```python
import logfire
from openai_agents import Runner

logfire.configure()

runner = Runner()

# Automatic integration
with logfire.span("flight_booking"):
    response = runner.run(
        agent=agent,
        messages=[{"role": "user", "content": "Book flight"}]
    )
```

### Custom Export

```python
# Export traces to your system
def export_trace(trace):
    """Export trace to custom format."""
    return {
        "trace_id": trace.id,
        "workflow": trace.workflow_name,
        "duration_ms": trace.duration_ms,
        "status": trace.status,
        "cost": trace.total_cost_usd,
        "spans": [
            {
                "type": span.type,
                "name": span.name,
                "duration_ms": span.duration_ms,
                "status": span.status
            }
            for span in trace.spans
        ]
    }

# Export recent traces
traces = client.traces.list(limit=100)
exported = [export_trace(t) for t in traces]

# Send to your analytics system
import requests
requests.post("https://your-analytics.com/traces", json=exported)
```

---

## Best Practices

### 1. Use Descriptive Workflow Names

```python
# ✅ Good
trace_config = {
    "workflow_name": "customer_support_ticket_creation",
    "group_id": f"conversation_{user_id}"
}

# ❌ Too vague
trace_config = {
    "workflow_name": "agent_run"
}
```

### 2. Grade Representative Samples

```python
# Grade diverse set of traces
grading_run = client.evals.traces.grade(
    workflow_name="flight_booking",
    sample_strategy="stratified",
    sample_size=500,
    strata=[
        {"filter": {"status": "success"}, "size": 400},
        {"filter": {"status": "error"}, "size": 100}
    ],
    graders=graders
)
```

### 3. Monitor Trace Metrics Over Time

```python
# Track key metrics daily
def daily_trace_report(workflow_name):
    traces = client.traces.list(
        workflow_name=workflow_name,
        start_date="yesterday",
        end_date="today"
    )

    metrics = {
        "total_traces": len(traces),
        "avg_duration_ms": sum(t.duration_ms for t in traces) / len(traces),
        "success_rate": len([t for t in traces if t.status == "success"]) / len(traces),
        "avg_cost": sum(t.total_cost_usd for t in traces) / len(traces)
    }

    return metrics
```

### 4. Set Up Alerts for Anomalies

```python
# Alert on performance degradation
current_avg = get_average_trace_duration("flight_booking", days=1)
baseline_avg = get_average_trace_duration("flight_booking", days=30)

if current_avg > baseline_avg * 1.5:
    send_alert(f"Trace duration increased by {((current_avg / baseline_avg) - 1) * 100:.0f}%")
```

---

## Additional Resources

- **Tracing Documentation**: https://openai.github.io/openai-agents-python/tracing/
- **Langfuse Integration**: https://langfuse.com/guides/cookbook/example_evaluating_openai_agents
- **AgentKit Announcement**: https://openai.com/index/introducing-agentkit
- **Evaluation Best Practices**: https://platform.openai.com/docs/guides/evals

---

**Next**: [Voice Agents →](../voice-agents.md)
