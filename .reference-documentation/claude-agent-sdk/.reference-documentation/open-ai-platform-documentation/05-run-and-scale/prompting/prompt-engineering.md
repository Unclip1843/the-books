# OpenAI Platform - Prompt Engineering

**Source:** https://platform.openai.com/docs/guides/prompt-engineering
**Fetched:** 2025-10-11

## Overview

This guide covers advanced prompt engineering techniques for getting optimal results from OpenAI models. These techniques build on the fundamentals and help solve complex problems systematically.

---

## Advanced Techniques

### Chain of Thought (CoT)

Encourage step-by-step reasoning for complex problems.

```python
prompt = """Let's solve this step by step:

Problem: A company has 150 employees. 40% work remotely, 30% work hybrid, and the rest work in-office. If 20% of remote workers and 50% of hybrid workers come to the office on a given day, how many total people are in the office?

Step 1: Calculate remote workers
Step 2: Calculate hybrid workers
Step 3: Calculate in-office workers
Step 4: Calculate remote workers coming in
Step 5: Calculate hybrid workers coming in
Step 6: Sum all office workers
"""
```

### ReAct (Reasoning + Acting)

Combine reasoning with tool use.

```python
prompt = """You have access to search and calculator tools.

Question: What is the square root of the population of Tokyo?

Thought: I need Tokyo's population first
Action: search("population of Tokyo 2025")
Observation: Tokyo has 37.4 million people
Thought: Now I need the square root
Action: calculator("sqrt(37400000)")
Observation: 6115.7
Answer: The square root of Tokyo's population is approximately 6,116.
"""
```

### Tree of Thoughts

Explore multiple reasoning paths.

```python
prompt = """Consider multiple approaches:

Problem: Design a recommendation system

Approach 1: Collaborative filtering
- Pros: [list]
- Cons: [list]
- Feasibility: [assessment]

Approach 2: Content-based filtering
- Pros: [list]
- Cons: [list]
- Feasibility: [assessment]

Approach 3: Hybrid approach
- Pros: [list]
- Cons: [list]
- Feasibility: [assessment]

Best approach: [selection with reasoning]
"""
```

---

## Next Steps

- [Prompting Overview](./overview.md) - Core concepts
- [Prompt Caching](./prompt-caching.md) - Cost optimization

---

**Source:** https://platform.openai.com/docs/guides/prompt-engineering
