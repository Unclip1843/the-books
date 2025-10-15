# LangChain - Few-Shot Prompting

**Sources:**
- https://python.langchain.com/docs/how_to/few_shot_examples/
- https://python.langchain.com/docs/how_to/few_shot_examples_chat/
- https://js.langchain.com/docs/how_to/few_shot_examples/

**Fetched:** 2025-10-11

## What is Few-Shot Prompting?

Few-shot prompting provides the LLM with **examples** of the task before asking it to perform the same task. This:
- Improves output quality
- Ensures consistent formatting
- Guides the model's behavior
- Reduces ambiguity

**Structure:**
```
System: Instructions
Example 1: Input → Output
Example 2: Input → Output
Example 3: Input → Output
User: New Input
AI: ?
```

## Basic Few-Shot

### Static Examples

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate, FewShotChatMessagePromptTemplate

# Define examples
examples = [
    {"input": "apple", "output": "fruit"},
    {"input": "carrot", "output": "vegetable"},
    {"input": "chicken", "output": "meat"}
]

# Example prompt template
example_prompt = ChatPromptTemplate.from_messages([
    ("human", "{input}"),
    ("ai", "{output}")
])

# Create few-shot prompt
few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    examples=examples
)

# Final prompt
final_prompt = ChatPromptTemplate.from_messages([
    ("system", "Classify the following into fruit, vegetable, or meat"),
    few_shot_prompt,
    ("human", "{input}")
])

# Use
llm = ChatOpenAI()
chain = final_prompt | llm

result = chain.invoke({"input": "banana"})
print(result.content)  # "fruit"
```

**TypeScript:**
```typescript
import { ChatOpenAI } from "@langchain/openai";
import { ChatPromptTemplate, FewShotChatMessagePromptTemplate } from "@langchain/core/prompts";

const examples = [
  { input: "apple", output: "fruit" },
  { input: "carrot", output: "vegetable" },
  { input: "chicken", output: "meat" }
];

const examplePrompt = ChatPromptTemplate.fromMessages([
  ["human", "{input}"],
  ["ai", "{output}"]
]);

const fewShotPrompt = new FewShotChatMessagePromptTemplate({
  examplePrompt,
  examples
});

const finalPrompt = ChatPromptTemplate.fromMessages([
  ["system", "Classify the following into fruit, vegetable, or meat"],
  fewShotPrompt,
  ["human", "{input}"]
]);

const llm = new ChatOpenAI();
const chain = finalPrompt.pipe(llm);

const result = await chain.invoke({ input: "banana" });
```

## Dynamic Example Selection

### Semantic Similarity Selector

Select examples most similar to the input:

**Python:**
```python
from langchain_core.example_selectors import SemanticSimilarityExampleSelector
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma

# More examples
examples = [
    {"input": "apple", "output": "fruit"},
    {"input": "banana", "output": "fruit"},
    {"input": "orange", "output": "fruit"},
    {"input": "carrot", "output": "vegetable"},
    {"input": "broccoli", "output": "vegetable"},
    {"input": "spinach", "output": "vegetable"},
    {"input": "chicken", "output": "meat"},
    {"input": "beef", "output": "meat"},
    {"input": "pork", "output": "meat"}
]

# Create selector
example_selector = SemanticSimilarityExampleSelector.from_examples(
    examples,
    OpenAIEmbeddings(),
    Chroma,
    k=2  # Select 2 most similar examples
)

# Test selector
selected = example_selector.select_examples({"input": "grape"})
print(selected)
# Will select fruit-related examples like apple and banana

# Use in few-shot prompt
few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    example_selector=example_selector
)

final_prompt = ChatPromptTemplate.from_messages([
    ("system", "Classify into fruit, vegetable, or meat"),
    few_shot_prompt,
    ("human", "{input}")
])
```

### Length-Based Selector

Select examples to fit within token limit:

**Python:**
```python
from langchain_core.example_selectors import LengthBasedExampleSelector

example_selector = LengthBasedExampleSelector(
    examples=examples,
    example_prompt=example_prompt,
    max_length=100  # Maximum tokens
)

# Automatically selects fewer examples for long inputs
few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    example_selector=example_selector
)
```

## Use Cases

### 1. Classification

**Python:**
```python
examples = [
    {
        "text": "I love this product! It's amazing!",
        "sentiment": "positive"
    },
    {
        "text": "This is terrible. Very disappointed.",
        "sentiment": "negative"
    },
    {
        "text": "It's okay, nothing special.",
        "sentiment": "neutral"
    }
]

example_prompt = ChatPromptTemplate.from_messages([
    ("human", "{text}"),
    ("ai", "{sentiment}")
])

few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    examples=examples
)

final_prompt = ChatPromptTemplate.from_messages([
    ("system", "Classify the sentiment as positive, negative, or neutral"),
    few_shot_prompt,
    ("human", "{text}")
])

chain = final_prompt | ChatOpenAI()

result = chain.invoke({"text": "Great service and fast delivery!"})
```

### 2. Entity Extraction

**Python:**
```python
examples = [
    {
        "text": "John Smith works at Google in San Francisco",
        "entities": "Person: John Smith, Company: Google, Location: San Francisco"
    },
    {
        "text": "Alice Brown is the CEO of Acme Corp in New York",
        "entities": "Person: Alice Brown, Title: CEO, Company: Acme Corp, Location: New York"
    }
]

example_prompt = ChatPromptTemplate.from_messages([
    ("human", "{text}"),
    ("ai", "{entities}")
])

few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    examples=examples
)

final_prompt = ChatPromptTemplate.from_messages([
    ("system", "Extract named entities from the text"),
    few_shot_prompt,
    ("human", "{text}")
])
```

### 3. Format Conversion

**Python:**
```python
examples = [
    {
        "input": "The meeting is on January 15, 2024 at 3:30 PM",
        "output": "2024-01-15T15:30:00"
    },
    {
        "input": "Conference call scheduled for Feb 20, 2024, 10:00 AM",
        "output": "2024-02-20T10:00:00"
    }
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
    ("system", "Convert natural language dates to ISO format"),
    few_shot_prompt,
    ("human", "{input}")
])
```

### 4. Translation Style

**Python:**
```python
examples = [
    {
        "english": "Hello, how are you?",
        "spanish": "Hola, ¿cómo estás?"
    },
    {
        "english": "Good morning, have a nice day!",
        "spanish": "Buenos días, ¡que tengas un buen día!"
    },
    {
        "english": "Thank you very much for your help.",
        "spanish": "Muchas gracias por tu ayuda."
    }
]

example_prompt = ChatPromptTemplate.from_messages([
    ("human", "{english}"),
    ("ai", "{spanish}")
])

few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    examples=examples
)

final_prompt = ChatPromptTemplate.from_messages([
    ("system", "Translate English to Spanish in a friendly, casual tone"),
    few_shot_prompt,
    ("human", "{english}")
])
```

### 5. Code Generation

**Python:**
```python
examples = [
    {
        "description": "Create a list of numbers from 1 to 10",
        "code": "numbers = list(range(1, 11))"
    },
    {
        "description": "Filter even numbers from a list",
        "code": "evens = [x for x in numbers if x % 2 == 0]"
    },
    {
        "description": "Calculate sum of a list",
        "code": "total = sum(numbers)"
    }
]

example_prompt = ChatPromptTemplate.from_messages([
    ("human", "{description}"),
    ("ai", "```python\n{code}\n```")
])

few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    examples=examples
)

final_prompt = ChatPromptTemplate.from_messages([
    ("system", "Generate Python code for the given description"),
    few_shot_prompt,
    ("human", "{description}")
])
```

### 6. Q&A Format

**Python:**
```python
examples = [
    {
        "question": "What is Python?",
        "answer": "Python is a high-level, interpreted programming language known for its simplicity and readability."
    },
    {
        "question": "What is a list?",
        "answer": "A list is an ordered, mutable collection of items in Python, created using square brackets []."
    }
]

example_prompt = ChatPromptTemplate.from_messages([
    ("human", "{question}"),
    ("ai", "{answer}")
])

few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    examples=examples
)

final_prompt = ChatPromptTemplate.from_messages([
    ("system", "Answer programming questions concisely and accurately"),
    few_shot_prompt,
    ("human", "{question}")
])
```

## Advanced Patterns

### Conditional Examples

Select examples based on input characteristics:

**Python:**
```python
def get_examples_for_input(user_input: str):
    """Return different examples based on input type"""
    if "python" in user_input.lower():
        return python_examples
    elif "javascript" in user_input.lower():
        return javascript_examples
    else:
        return general_examples

# Create selector function
class ConditionalExampleSelector:
    def __init__(self, example_groups):
        self.example_groups = example_groups

    def select_examples(self, input_variables):
        user_input = input_variables.get("input", "")
        # Logic to select appropriate example group
        return get_examples_for_input(user_input)

selector = ConditionalExampleSelector({
    "python": python_examples,
    "javascript": javascript_examples
})
```

### Hierarchical Examples

Different example sets for different complexity levels:

**Python:**
```python
basic_examples = [
    {"input": "2 + 2", "output": "4"}
]

intermediate_examples = [
    {"input": "2 * 3 + 4", "output": "10"}
]

advanced_examples = [
    {"input": "(2 + 3) * (4 - 1)", "output": "15"}
]

def select_by_complexity(input_text):
    # Determine complexity
    if "(" in input_text:
        return advanced_examples
    elif "*" in input_text or "/" in input_text:
        return intermediate_examples
    else:
        return basic_examples
```

### Multi-Modal Examples

Examples with different content types:

**Python:**
```python
from langchain_core.messages import HumanMessage

examples = [
    {
        "input": HumanMessage(content=[
            {"type": "text", "text": "Describe this image"},
            {"type": "image_url", "image_url": {"url": "example1.jpg"}}
        ]),
        "output": "A cat sitting on a couch"
    }
]
```

## Example Selectors

### MaxMarginalRelevanceExampleSelector

Select diverse examples:

**Python:**
```python
from langchain_core.example_selectors import MaxMarginalRelevanceExampleSelector

selector = MaxMarginalRelevanceExampleSelector.from_examples(
    examples,
    OpenAIEmbeddings(),
    Chroma,
    k=3  # Select 3 diverse examples
)

# Selects examples that are relevant but also diverse
selected = selector.select_examples({"input": "strawberry"})
```

### Custom Selector

**Python:**
```python
from langchain_core.example_selectors import BaseExampleSelector

class CustomExampleSelector(BaseExampleSelector):
    def __init__(self, examples):
        self.examples = examples

    def add_example(self, example):
        self.examples.append(example)

    def select_examples(self, input_variables):
        # Custom logic
        user_input = input_variables["input"]

        # Example: Select examples with similar length
        input_len = len(user_input)
        selected = sorted(
            self.examples,
            key=lambda x: abs(len(x["input"]) - input_len)
        )[:3]

        return selected

selector = CustomExampleSelector(examples)
```

## Best Practices

### 1. Use Relevant Examples

```python
# Good: Examples match the task
examples = [
    {"email": "john@gmail.com", "valid": "yes"},
    {"email": "invalid.email", "valid": "no"}
]

# Avoid: Unrelated examples
examples = [
    {"text": "Hello", "translation": "Hola"}  # Wrong task
]
```

### 2. Provide Diverse Examples

```python
# Good: Diverse examples covering different cases
examples = [
    {"input": "2 + 2", "output": "4"},              # Simple
    {"input": "10 - 5", "output": "5"},             # Subtraction
    {"input": "3 * 4", "output": "12"},             # Multiplication
    {"input": "(2 + 3) * 2", "output": "10"}        # Complex
]

# Avoid: Repetitive examples
examples = [
    {"input": "2 + 2", "output": "4"},
    {"input": "3 + 3", "output": "6"},
    {"input": "4 + 4", "output": "8"}
]
```

### 3. Balance Number of Examples

```python
# Good: 3-5 examples for most tasks
examples = examples[:5]

# Avoid: Too many (expensive) or too few (ineffective)
examples = examples[:1]   # Too few
examples = examples[:20]  # Too many, expensive
```

### 4. Use Semantic Similarity for Large Example Sets

```python
# Good: Dynamic selection from large set
large_example_set = [...]  # 100+ examples

selector = SemanticSimilarityExampleSelector.from_examples(
    large_example_set,
    OpenAIEmbeddings(),
    Chroma,
    k=5
)

# Avoid: Always using all examples
few_shot_prompt = FewShotChatMessagePromptTemplate(
    examples=large_example_set  # Expensive!
)
```

### 5. Include Edge Cases

```python
# Good: Include edge cases
examples = [
    {"input": "normal case", "output": "result"},
    {"input": "", "output": "empty input"},              # Edge case
    {"input": "UPPERCASE", "output": "handles case"},    # Edge case
    {"input": "special!@#", "output": "handles special"} # Edge case
]
```

### 6. Clear, Consistent Formatting

```python
# Good: Consistent format
examples = [
    {"question": "Q1", "answer": "A1"},
    {"question": "Q2", "answer": "A2"}
]

# Avoid: Inconsistent keys
examples = [
    {"question": "Q1", "answer": "A1"},
    {"q": "Q2", "a": "A2"}  # Different keys!
]
```

## Performance Tips

### 1. Cache Example Embeddings

```python
# Embed examples once, reuse
embeddings = OpenAIEmbeddings()

# Cache in vector store
vectorstore = Chroma.from_texts(
    [ex["input"] for ex in examples],
    embeddings,
    metadatas=examples
)

# Reuse for all queries
selector = SemanticSimilarityExampleSelector(
    vectorstore=vectorstore,
    k=3
)
```

### 2. Limit Example Count

```python
# Balance quality vs cost
selector = SemanticSimilarityExampleSelector.from_examples(
    examples,
    OpenAIEmbeddings(),
    Chroma,
    k=3  # 3-5 is usually optimal
)
```

### 3. Use Length-Based Selection

```python
# Automatically adjust for context limits
selector = LengthBasedExampleSelector(
    examples=examples,
    example_prompt=example_prompt,
    max_length=2000  # Fit within context
)
```

## Related Documentation

- [Prompt Templates](./11-prompt-templates.md)
- [Example Selectors](./14-example-selectors.md)
- [Chat Models](./06-chat-models.md)
- [Embeddings](./18-embeddings.md)
