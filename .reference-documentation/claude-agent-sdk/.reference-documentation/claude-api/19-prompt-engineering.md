# Claude API - Prompt Engineering

**Sources:**
- https://docs.claude.com/en/docs/build-with-claude/prompt-engineering

**Fetched:** 2025-10-11

## Overview

Prompt engineering is the process of structuring text to guide Claude toward producing desired outputs. Effective prompts can dramatically improve response quality, consistency, and relevance.

## Core Principles

### 1. Be Clear and Direct

```python
# Vague
"Tell me about dogs"

# Clear
"List 5 key differences between Golden Retrievers and German Shepherds in terms of temperament, size, and exercise needs"
```

### 2. Use Examples (Few-Shot)

```python
system_prompt = """Classify customer feedback as positive, negative, or neutral.

Examples:
"Great service!" → positive
"Terrible experience" → negative
"It was okay" → neutral"""

message = {"role": "user", "content": "The product arrived on time"}
# Response: "positive"
```

### 3. Assign a Role

```python
system = "You are an expert Python developer who writes clean, well-documented code following PEP 8 standards."
```

### 4. Use XML Tags for Structure

```python
prompt = """
<document>
{long_document}
</document>

<question>
What are the main conclusions?
</question>
"""
```

### 5. Chain of Thought

```python
"Solve this step by step, showing your reasoning at each stage:
What is 15% of 250?"
```

### 6. Prefill Responses

```python
messages = [
    {"role": "user", "content": "Write a haiku about coding"},
    {"role": "assistant", "content": "Here is a haiku:\n"}  # Prefill
]
```

## Techniques

### System Prompts

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    system="You are a helpful assistant that always responds in JSON format",
    messages=[{"role": "user", "content": "What's the weather?"}]
)
```

### Multishot Prompting

```python
conversation = [
    {"role": "user", "content": "Translate 'hello' to Spanish"},
    {"role": "assistant", "content": "hola"},
    {"role": "user", "content": "Translate 'goodbye' to Spanish"},
    {"role": "assistant", "content": "adiós"},
    {"role": "user", "content": "Translate 'thank you' to Spanish"}
]
```

### Complex Prompts

```python
prompt = """You are a technical writer creating API documentation.

Task: Document this function
Context: REST API for user management
Requirements:
- Include description, parameters, return values
- Provide code example
- Note any edge cases

Function:
{function_code}

Format your response in Markdown.
"""
```

## Best Practices

1. **Start simple, iterate** - Begin with basic prompts, refine based on results
2. **Test with examples** - Try multiple test cases
3. **Be specific** - Exact requirements = better results
4. **Use clear formatting** - XML tags, markdown, structure
5. **Provide context** - Background information helps
6. **Set constraints** - Length, format, tone requirements

## Common Patterns

### JSON Output

```python
prompt = """Return your answer as JSON with this schema:
{
    "answer": "the answer text",
    "confidence": 0-100,
    "sources": ["source1", "source2"]
}
"""
```

### Classification

```python
prompt = """Classify this text into one of these categories: {categories}

Text: {text}

Category:"""
```

### Extraction

```python
prompt = """Extract the following entities from the text:
- People (names)
- Organizations
- Locations
- Dates

Return as JSON.

Text: {text}
"""
```

## Related Documentation

- [Messages API](./03-messages-api.md)
- [Examples](./11-examples.md)
- [Testing & Evaluation](./20-testing-evaluation.md)
