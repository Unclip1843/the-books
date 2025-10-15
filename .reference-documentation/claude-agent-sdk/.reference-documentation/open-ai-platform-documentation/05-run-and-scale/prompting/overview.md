# OpenAI Platform - Prompting Overview

**Source:** https://platform.openai.com/docs/guides/prompt-engineering
**Fetched:** 2025-10-11

## Overview

Prompt engineering is the practice of designing and refining prompts to get the best possible outputs from AI models. Well-crafted prompts can dramatically improve response quality, consistency, and usefulness.

**Key Principles:**
- ✍️ Be specific and clear
- 📝 Provide context and examples
- 🎯 Define desired format and constraints
- 🔄 Iterate based on results
- 🧪 Test systematically

---

## Why Prompt Engineering Matters

### The Impact of Good Prompts

**Poor Prompt:**
```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Write about dogs"}]
)
# Result: Generic, unfocused essay about dogs
```

**Good Prompt:**
```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
        "role": "user",
        "content": """Write a 200-word product description for premium dog food.

Target audience: Health-conscious pet owners
Tone: Professional yet warm
Key benefits to highlight:
- Natural ingredients
- Veterinarian-approved
- Supports joint health

Format: 3 paragraphs with bullet points for benefits"""
    }]
)
# Result: Focused, targeted product description matching requirements
```

---

## Core Prompting Techniques

### 1. Be Specific and Clear

**❌ Vague:**
```
"Tell me about the weather"
```

**✅ Specific:**
```
"Provide a 5-day weather forecast for San Francisco, CA, including daily highs/lows in Fahrenheit, chance of rain, and whether it's suitable for outdoor activities."
```

### 2. Use System Messages

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {
            "role": "system",
            "content": """You are a technical documentation expert.
Write concise, accurate explanations.
Use code examples when relevant.
Assume the audience has intermediate programming knowledge."""
        },
        {
            "role": "user",
            "content": "Explain async/await in JavaScript"
        }
    ]
)
```

### 3. Provide Examples (Few-Shot Learning)

```python
messages = [
    {"role": "system", "content": "Extract key information from customer reviews."},

    # Example 1
    {"role": "user", "content": "The product arrived damaged and customer service was unhelpful."},
    {"role": "assistant", "content": "Sentiment: Negative\nIssues: Damaged product, poor customer service\nAction: Escalate to support team"},

    # Example 2
    {"role": "user", "content": "Great quality! Fast shipping and exactly as described."},
    {"role": "assistant", "content": "Sentiment: Positive\nHighlights: Quality, shipping speed, accuracy\nAction: None needed"},

    # Actual request
    {"role": "user", "content": "Product is okay but took 3 weeks to arrive."}
]

response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages
)
```

### 4. Define Output Format

**Structured JSON:**
```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
        "role": "user",
        "content": """Extract contact information from this text:
"Contact John Smith at john@example.com or call 555-0123"

Return as JSON with fields: name, email, phone"""
    }]
)
```

**With Strict Schema (Guaranteed):**
```python
from pydantic import BaseModel

class ContactInfo(BaseModel):
    name: str
    email: str
    phone: str

response = client.beta.chat.completions.parse(
    model="gpt-4o",
    messages=[{
        "role": "user",
        "content": """Extract contact information:
"Contact John Smith at john@example.com or call 555-0123" """
    }],
    response_format=ContactInfo
)

# Guaranteed to match schema
contact = response.choices[0].message.parsed
```

### 5. Break Down Complex Tasks

**❌ One Complex Prompt:**
```
"Analyze this document, summarize key points, extract action items, identify risks, and create a project timeline"
```

**✅ Sequential Steps:**
```python
# Step 1: Summarize
summary = get_summary(document)

# Step 2: Extract action items
action_items = extract_actions(document, summary)

# Step 3: Identify risks
risks = identify_risks(document, summary)

# Step 4: Create timeline
timeline = create_timeline(action_items, risks)
```

### 6. Use Delimiters

```python
prompt = """Analyze the following customer feedback:

---START FEEDBACK---
{feedback_text}
---END FEEDBACK---

Provide:
1. Overall sentiment (Positive/Negative/Neutral)
2. Main concerns (if any)
3. Suggested response
"""
```

### 7. Specify Constraints

```python
prompt = """Write a product description with these constraints:
- Maximum 150 words
- Include exactly 3 key benefits
- Use active voice
- No technical jargon
- Mention the price ($49.99)
- Call-to-action at end

Product: Wireless earbuds with noise cancellation
"""
```

---

## Advanced Techniques

### Chain of Thought (CoT)

Encourage step-by-step reasoning:

```python
prompt = """Solve this problem step by step:

Problem: A store has 1,234 items. If 15% are sold today and 8% are damaged, how many items remain in good condition?

Let's think through this step by step:
1) First, calculate items sold
2) Then, calculate items damaged
3) Finally, subtract both from total
"""

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": prompt}]
)
```

### Role Prompting

Assign specific personas:

```python
system_messages = {
    "technical_writer": "You are a technical writer who explains complex concepts clearly and concisely.",
    "code_reviewer": "You are a senior engineer reviewing code for best practices, security, and performance.",
    "creative_writer": "You are a creative writer crafting engaging narratives with vivid descriptions."
}

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": system_messages["code_reviewer"]},
        {"role": "user", "content": "Review this Python function..."}
    ]
)
```

### Iterative Refinement

```python
def refine_prompt(initial_prompt, feedback):
    """Iteratively improve prompts based on output."""
    refinements = {
        "too_long": "Limit response to 200 words.",
        "too_technical": "Use simple language suitable for beginners.",
        "missing_examples": "Include 2-3 concrete examples.",
        "wrong_tone": "Use a professional but friendly tone."
    }

    refined = initial_prompt + "\n\n" + refinements.get(feedback, "")
    return refined

# Usage
prompt = "Explain machine learning"
result = call_api(prompt)

# Too technical? Refine
prompt = refine_prompt(prompt, "too_technical")
result = call_api(prompt)
```

### Self-Consistency

Generate multiple responses and pick the most consistent:

```python
def get_consistent_answer(question, num_attempts=5):
    """Get most consistent answer across multiple attempts."""
    answers = []

    for _ in range(num_attempts):
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": question}],
            temperature=0.7  # Some variation
        )
        answers.append(response.choices[0].message.content)

    # Find most common answer
    from collections import Counter
    most_common = Counter(answers).most_common(1)[0][0]

    return most_common
```

### ReAct (Reasoning + Acting)

Combine reasoning with actions:

```python
prompt = """You have access to a search tool. For each question:
1. Think: Analyze what information you need
2. Act: Use the search tool
3. Observe: Review the results
4. Think: Determine if you have enough information
5. Answer: Provide the final answer

Question: What is the population of the capital of France?

Think: I need to know (1) the capital of France and (2) its population.
Act: search("capital of France")
Observe: The capital of France is Paris.
Think: Now I need Paris's population.
Act: search("population of Paris")
Observe: Paris has approximately 2.16 million people.
Answer: The population of Paris, the capital of France, is approximately 2.16 million people.
"""
```

---

## Model-Specific Tips

### GPT-4o / GPT-5

**Strengths:**
- Follows instructions very precisely
- Excellent at complex reasoning
- Strong context understanding

**Tips:**
- Be very explicit about desired format
- Use structured outputs for reliability
- Leverage large context window (128K tokens)

```python
# Highly steerable
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
        "role": "user",
        "content": """Act as a data analyst. Be extremely precise.

Data: [1, 5, 3, 9, 2, 8, 4]

Calculate:
1. Mean (show formula)
2. Median (explain method)
3. Mode (if exists)

Format each calculation as:
Metric: [name]
Formula: [formula]
Calculation: [step-by-step]
Result: [answer]"""
    }]
)
```

### GPT-4o-mini

**Strengths:**
- Fast responses
- Cost-effective
- Good for simpler tasks

**Tips:**
- More concise prompts work well
- Focus on single, clear objectives
- Use for high-volume tasks

```python
# Efficient for simple tasks
response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{
        "role": "user",
        "content": "Classify sentiment (Positive/Negative/Neutral): 'This product exceeded my expectations!'"
    }]
)
```

### O1 (Reasoning Models)

**Strengths:**
- Extended reasoning capabilities
- Complex problem-solving
- Multi-step analysis

**Tips:**
- Let model show its reasoning
- Provide detailed context
- Allow longer responses

```python
response = client.chat.completions.create(
    model="o1-preview",
    messages=[{
        "role": "user",
        "content": """Analyze this chess position and recommend the best move.
Show your reasoning process including:
- Material count
- Positional advantages
- Tactical threats
- Strategic plans

Position: FEN string here..."""
    }]
)
```

---

## Common Patterns

### Classification

```python
prompt = """Classify the following text into one of these categories:
- Technical Support
- Billing Question
- Feature Request
- Bug Report
- General Inquiry

Text: "{user_message}"

Respond with only the category name."""
```

### Extraction

```python
prompt = """Extract the following information from the email:
- Sender name
- Request type
- Deadline (if mentioned)
- Priority (High/Medium/Low based on language)

Email:
{email_text}

Return as JSON."""
```

### Transformation

```python
prompt = """Transform this bullet list into a narrative paragraph:

{bullet_points}

Requirements:
- Professional tone
- Logical flow between points
- 100-150 words
"""
```

### Generation

```python
prompt = """Generate 5 creative taglines for:

Product: {product_name}
Target audience: {audience}
Key benefit: {benefit}
Tone: {tone}

Make each tagline:
- Under 10 words
- Memorable and catchy
- Focused on the key benefit
"""
```

### Summarization

```python
prompt = """Summarize this article in 3 sentences:

Article:
{article_text}

Focus on:
1. Main argument/finding
2. Supporting evidence
3. Practical implications

Keep each sentence under 25 words."""
```

---

## Optimization Tips

### 1. Set Temperature Appropriately

```python
# Factual, consistent outputs
response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    temperature=0  # Deterministic
)

# Creative outputs
response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    temperature=0.9  # More creative
)
```

### 2. Use max_tokens Wisely

```python
# Short responses
response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    max_tokens=100  # Brief answer
)

# Detailed analysis
response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    max_tokens=2000  # Comprehensive
)
```

### 3. Leverage Context Window

```python
# For GPT-4o (128K context)
large_document = read_file("large_document.txt")  # Can be very large

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
        "role": "user",
        "content": f"""Analyze this entire document and extract key themes:

{large_document}

List the top 5 themes with supporting quotes."""
    }]
)
```

---

## Testing and Evaluation

### A/B Testing Prompts

```python
def compare_prompts(prompt_a, prompt_b, test_cases):
    """Compare two prompts across test cases."""
    results = {"a": [], "b": []}

    for test in test_cases:
        # Test prompt A
        response_a = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": prompt_a.format(**test)}]
        )
        results["a"].append(response_a.choices[0].message.content)

        # Test prompt B
        response_b = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": prompt_b.format(**test)}]
        )
        results["b"].append(response_b.choices[0].message.content)

    return results

# Usage
prompt_a = "Summarize: {text}"
prompt_b = "Provide a concise 2-sentence summary of: {text}"

test_cases = [
    {"text": "Long article 1..."},
    {"text": "Long article 2..."}
]

results = compare_prompts(prompt_a, prompt_b, test_cases)
```

### Prompt Versioning

```python
PROMPT_VERSIONS = {
    "v1": "Extract name and email from: {text}",
    "v2": "Extract contact information (name, email) from the following text: {text}. Return as JSON.",
    "v3": """Extract contact information from the text below.

Text: {text}

Return a JSON object with:
- name: Full name
- email: Email address
- confidence: High/Medium/Low"""
}

def use_prompt(version, text):
    """Use specific prompt version."""
    prompt = PROMPT_VERSIONS[version].format(text=text)
    return client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}]
    )
```

---

## Best Practices Checklist

### Before Sending

- [ ] Is the instruction clear and specific?
- [ ] Have I provided enough context?
- [ ] Did I specify the desired format?
- [ ] Are constraints clearly stated?
- [ ] Have I included examples if needed?
- [ ] Is the temperature appropriate for the task?
- [ ] Have I set a reasonable max_tokens?

### After Receiving

- [ ] Does the output match expectations?
- [ ] Is the format correct?
- [ ] Is the information accurate?
- [ ] Does it follow all constraints?
- [ ] Should I refine the prompt?

---

## Next Steps

1. **[Prompt Caching →](./prompt-caching.md)** - Reduce costs with caching
2. **[Prompt Engineering →](./prompt-engineering.md)** - Advanced techniques
3. **[Structured Output →](../../02-core-concepts/structured-output.md)** - Guaranteed schemas
4. **[Function Calling →](../../02-core-concepts/function-calling.md)** - Tool use

---

## Additional Resources

- **Prompt Engineering Guide**: https://platform.openai.com/docs/guides/prompt-engineering
- **OpenAI Cookbook**: https://cookbook.openai.com/
- **Best Practices**: https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering
- **GPT-4.1 Guide**: https://cookbook.openai.com/examples/gpt4-1_prompting_guide

---

**Next**: [Prompt Caching →](./prompt-caching.md)
