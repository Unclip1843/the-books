# LangChain - Prompt Templates

**Sources:**
- https://python.langchain.com/docs/concepts/prompt_templates/
- https://python.langchain.com/docs/how_to/prompts/
- https://js.langchain.com/docs/how_to/prompts/

**Fetched:** 2025-10-11

## What are Prompt Templates?

Prompt templates are **parameterized prompts** that allow you to:
- Reuse prompts with different inputs
- Separate prompt logic from application logic
- Version control your prompts
- Compose complex prompts from simple parts

## Basic Usage

### String Template

**Python:**
```python
from langchain_core.prompts import ChatPromptTemplate

# Simple template
prompt = ChatPromptTemplate.from_template(
    "Tell me a joke about {topic}"
)

# Format
result = prompt.invoke({"topic": "programming"})
print(result)
# [HumanMessage(content='Tell me a joke about programming')]
```

**TypeScript:**
```typescript
import { ChatPromptTemplate } from "@langchain/core/prompts";

const prompt = ChatPromptTemplate.fromTemplate(
  "Tell me a joke about {topic}"
);

const result = await prompt.invoke({ topic: "programming" });
console.log(result);
```

### Multiple Variables

**Python:**
```python
prompt = ChatPromptTemplate.from_template(
    "Translate {text} from {source_lang} to {target_lang}"
)

result = prompt.invoke({
    "text": "Hello, world!",
    "source_lang": "English",
    "target_lang": "Spanish"
})
```

## Message Templates

### from_messages()

**Python:**
```python
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful AI assistant"),
    ("human", "Tell me about {topic}")
])

result = prompt.invoke({"topic": "AI"})
print(result)
# [
#   SystemMessage(content='You are a helpful AI assistant'),
#   HumanMessage(content='Tell me about AI')
# ]
```

**TypeScript:**
```typescript
import { ChatPromptTemplate } from "@langchain/core/prompts";

const prompt = ChatPromptTemplate.fromMessages([
  ["system", "You are a helpful AI assistant"],
  ["human", "Tell me about {topic}"]
]);

const result = await prompt.invoke({ topic: "AI" });
```

### Multiple Messages

**Python:**
```python
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a {role}"),
    ("human", "{user_input}"),
    ("ai", "I understand you want to know about {topic}"),
    ("human", "Yes, please explain")
])

result = prompt.invoke({
    "role": "Python expert",
    "user_input": "How do decorators work?",
    "topic": "decorators"
})
```

## Message Placeholders

### MessagesPlaceholder

Insert dynamic message lists:

**Python:**
```python
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.messages import HumanMessage, AIMessage

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant"),
    MessagesPlaceholder("chat_history"),
    ("human", "{input}")
])

result = prompt.invoke({
    "chat_history": [
        HumanMessage(content="Hi, I'm Alice"),
        AIMessage(content="Hello Alice! How can I help?")
    ],
    "input": "What's my name?"
})
```

**TypeScript:**
```typescript
import { ChatPromptTemplate, MessagesPlaceholder } from "@langchain/core/prompts";
import { HumanMessage, AIMessage } from "@langchain/core/messages";

const prompt = ChatPromptTemplate.fromMessages([
  ["system", "You are a helpful assistant"],
  new MessagesPlaceholder("chat_history"),
  ["human", "{input}"]
]);

const result = await prompt.invoke({
  chat_history: [
    new HumanMessage("Hi, I'm Alice"),
    new AIMessage("Hello Alice!")
  ],
  input: "What's my name?"
});
```

### Optional Placeholder

**Python:**
```python
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant"),
    MessagesPlaceholder("chat_history", optional=True),
    ("human", "{input}")
])

# Works with or without chat_history
result1 = prompt.invoke({"input": "Hello"})

result2 = prompt.invoke({
    "input": "Hello",
    "chat_history": [HumanMessage(content="Previous message")]
})
```

## Partial Variables

### Partial with Fixed Values

**Python:**
```python
from datetime import datetime

prompt = ChatPromptTemplate.from_template(
    "Today is {date}. Tell me about {topic}"
)

# Partial application
partial_prompt = prompt.partial(date=datetime.now().strftime("%Y-%m-%d"))

# Only need topic now
result = partial_prompt.invoke({"topic": "AI"})
```

### Partial with Functions

**Python:**
```python
def get_current_date():
    return datetime.now().strftime("%Y-%m-%d")

prompt = ChatPromptTemplate.from_template(
    "Today is {date}. Tell me about {topic}"
)

# Partial with function (called at invoke time)
partial_prompt = prompt.partial(date=get_current_date)

result = partial_prompt.invoke({"topic": "AI"})
```

## Composing Templates

### Pipe Operator

**Python:**
```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser

prompt = ChatPromptTemplate.from_template("Tell me about {topic}")
llm = ChatOpenAI()
parser = StrOutputParser()

# Compose with pipe
chain = prompt | llm | parser

result = chain.invoke({"topic": "AI"})
print(result)  # String output
```

### Template Combination

**Python:**
```python
system_prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a {role}")
])

user_prompt = ChatPromptTemplate.from_messages([
    ("human", "{input}")
])

# Combine
full_prompt = system_prompt + user_prompt

result = full_prompt.invoke({
    "role": "Python expert",
    "input": "Explain decorators"
})
```

## Template Types

### ChatPromptTemplate

For chat models (recommended):

**Python:**
```python
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a {role}"),
    ("human", "{input}")
])
```

### PromptTemplate

For LLMs (legacy):

**Python:**
```python
from langchain_core.prompts import PromptTemplate

prompt = PromptTemplate.from_template(
    "Tell me about {topic}"
)

result = prompt.invoke({"topic": "AI"})
print(result)  # "Tell me about AI"
```

### FewShotPromptTemplate

For few-shot learning:

**Python:**
```python
from langchain_core.prompts import FewShotChatMessagePromptTemplate

examples = [
    {"input": "apple", "output": "fruit"},
    {"input": "carrot", "output": "vegetable"}
]

example_prompt = ChatPromptTemplate.from_messages([
    ("human", "{input}"),
    ("ai", "{output}")
])

few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    examples=examples
)

final_prompt = ChatPromptTemplate.from_messages([
    ("system", "Classify the following"),
    few_shot_prompt,
    ("human", "{input}")
])
```

## Advanced Features

### Custom Separators

**Python:**
```python
from langchain_core.prompts import PromptTemplate

prompt = PromptTemplate(
    template="Items:\n{items}",
    input_variables=["items"]
)

result = prompt.invoke({
    "items": "\n- ".join(["apple", "banana", "orange"])
})
```

### Conditional Content

**Python:**
```python
prompt = ChatPromptTemplate.from_template(
    """Answer the question: {question}

    {context_instruction}"""
)

def get_context_instruction(has_context):
    if has_context:
        return "Use the following context: {context}"
    return "Use your general knowledge"

result = prompt.partial(
    context_instruction=get_context_instruction(True)
)
```

### Nested Variables

**Python:**
```python
prompt = ChatPromptTemplate.from_template(
    "User {user_info[name]} from {user_info[company]} asks: {question}"
)

result = prompt.invoke({
    "user_info": {
        "name": "Alice",
        "company": "Acme Corp"
    },
    "question": "How does AI work?"
})
```

## Real-World Examples

### 1. Customer Support

**Python:**
```python
customer_support_prompt = ChatPromptTemplate.from_messages([
    ("system", """You are a customer support agent for {company}.
    Be helpful, friendly, and professional.

    Company policies:
    {policies}"""),
    MessagesPlaceholder("chat_history"),
    ("human", "{input}")
])

result = customer_support_prompt.invoke({
    "company": "Acme Corp",
    "policies": "- Free returns within 30 days\n- 24/7 support",
    "chat_history": [],
    "input": "How do I return a product?"
})
```

### 2. Code Review

**Python:**
```python
code_review_prompt = ChatPromptTemplate.from_template(
    """Review the following {language} code for:
    1. Bugs and errors
    2. Best practices
    3. Performance issues
    4. Security vulnerabilities

    Code:
    ```{language}
    {code}
    ```

    Provide detailed feedback."""
)

result = code_review_prompt.invoke({
    "language": "python",
    "code": "def add(a, b):\n    return a + b"
})
```

### 3. Content Generation

**Python:**
```python
blog_prompt = ChatPromptTemplate.from_template(
    """Write a {length} blog post about {topic}.

    Target audience: {audience}
    Tone: {tone}
    Include: {requirements}

    Format as markdown with:
    - Engaging title
    - Introduction
    - {num_sections} main sections
    - Conclusion"""
)

result = blog_prompt.invoke({
    "length": "500 word",
    "topic": "AI in healthcare",
    "audience": "healthcare professionals",
    "tone": "professional but accessible",
    "requirements": "statistics and real examples",
    "num_sections": 3
})
```

### 4. Data Analysis

**Python:**
```python
analysis_prompt = ChatPromptTemplate.from_template(
    """Analyze the following data:

    {data}

    Provide:
    1. Summary statistics
    2. Key trends
    3. Anomalies or outliers
    4. Actionable insights

    Focus on: {focus_areas}"""
)

result = analysis_prompt.invoke({
    "data": "Sales data...",
    "focus_areas": "revenue trends and customer segments"
})
```

### 5. Translation

**Python:**
```python
translation_prompt = ChatPromptTemplate.from_template(
    """Translate the following text from {source_lang} to {target_lang}.

    Style: {style}
    Preserve: {preserve}

    Text:
    {text}

    Provide only the translation."""
)

result = translation_prompt.invoke({
    "source_lang": "English",
    "target_lang": "Spanish",
    "style": "formal",
    "preserve": "technical terms",
    "text": "The API endpoint returns JSON"
})
```

## Template Validation

### Check Required Variables

**Python:**
```python
prompt = ChatPromptTemplate.from_template(
    "Tell me about {topic} in {language}"
)

# Get required input variables
print(prompt.input_variables)  # ['topic', 'language']

# Validate before invoking
try:
    result = prompt.invoke({"topic": "AI"})  # Missing 'language'
except KeyError as e:
    print(f"Missing variable: {e}")
```

### Provide Defaults

**Python:**
```python
prompt = ChatPromptTemplate.from_template(
    "Tell me about {topic} in {language}"
)

# Partial with default
prompt_with_default = prompt.partial(language="English")

# Now only topic is required
result = prompt_with_default.invoke({"topic": "AI"})
```

## Loading from Files

### From YAML

**prompt.yaml:**
```yaml
_type: prompt
input_variables:
  - topic
  - style
template: |
  Write a {style} explanation of {topic}.
  Make it easy to understand.
```

**Python:**
```python
from langchain_core.prompts import load_prompt

prompt = load_prompt("prompt.yaml")
result = prompt.invoke({"topic": "AI", "style": "simple"})
```

### From JSON

**prompt.json:**
```json
{
  "_type": "prompt",
  "input_variables": ["topic"],
  "template": "Explain {topic} in simple terms"
}
```

**Python:**
```python
prompt = load_prompt("prompt.json")
```

## Best Practices

### 1. Be Specific and Clear

```python
# Good: Specific instructions
prompt = ChatPromptTemplate.from_template(
    """Extract the following information from the text:
    - Name (full name)
    - Email (if present)
    - Phone (if present)

    Text: {text}

    Format as JSON."""
)

# Avoid: Vague
prompt = ChatPromptTemplate.from_template(
    "Get info from: {text}"
)
```

### 2. Use System Messages

```python
# Good: Clear role definition
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are an expert Python developer. Provide accurate, well-tested code."),
    ("human", "{question}")
])

# Avoid: No role definition
prompt = ChatPromptTemplate.from_template("{question}")
```

### 3. Provide Examples

```python
# Good: Include examples
prompt = ChatPromptTemplate.from_template(
    """Classify sentiment as positive, negative, or neutral.

    Examples:
    - "I love this!" → positive
    - "This is terrible" → negative
    - "It's okay" → neutral

    Text: {text}"""
)
```

### 4. Use Placeholders for History

```python
# Good: Flexible history
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant"),
    MessagesPlaceholder("chat_history", optional=True),
    ("human", "{input}")
])
```

### 5. Version Your Prompts

```python
# Good: Track versions
V1_PROMPT = ChatPromptTemplate.from_template("Old template")
V2_PROMPT = ChatPromptTemplate.from_template("New improved template")

# Use appropriate version
prompt = V2_PROMPT
```

## Performance Tips

### 1. Reuse Templates

```python
# Good: Create once, reuse
CUSTOMER_SUPPORT_PROMPT = ChatPromptTemplate.from_messages([...])

def handle_request(user_input):
    return CUSTOMER_SUPPORT_PROMPT.invoke({"input": user_input})

# Avoid: Creating templates repeatedly
def handle_request(user_input):
    prompt = ChatPromptTemplate.from_messages([...])  # Wasteful
    return prompt.invoke({"input": user_input})
```

### 2. Use Partials for Static Data

```python
# Good: Partial for static data
base_prompt = ChatPromptTemplate.from_template(
    "Company: {company}\nUser: {user_input}"
)
prompt = base_prompt.partial(company="Acme Corp")

# Now only user_input changes
```

### 3. Cache Formatted Prompts

```python
from functools import lru_cache

@lru_cache(maxsize=100)
def get_formatted_prompt(topic: str) -> str:
    return prompt.format(topic=topic)
```

## Related Documentation

- [Messages](./12-messages.md)
- [Few-Shot Prompting](./13-few-shot-prompting.md)
- [Example Selectors](./14-example-selectors.md)
- [Model I/O](./09-model-io.md)
- [Chat Models](./06-chat-models.md)
