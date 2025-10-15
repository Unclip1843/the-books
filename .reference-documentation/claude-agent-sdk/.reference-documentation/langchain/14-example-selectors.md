# LangChain - Example Selectors

**Sources:**
- https://python.langchain.com/docs/how_to/example_selectors/
- https://python.langchain.com/docs/concepts/example_selectors/
- https://js.langchain.com/docs/how_to/example_selectors/

**Fetched:** 2025-10-11

## What are Example Selectors?

Example selectors **dynamically choose** which few-shot examples to include in a prompt based on:
- **Similarity** to the input
- **Length** constraints (token limits)
- **Relevance** to the task
- **Diversity** of examples
- **Custom** logic

## Why Use Example Selectors?

1. **Context Management** - Fit within token limits
2. **Relevance** - Show most relevant examples
3. **Cost Optimization** - Include only necessary examples
4. **Quality** - Better examples = better outputs
5. **Flexibility** - Adapt to different inputs

## Selector Types

### 1. Semantic Similarity

Select examples most similar to the input:

**Python:**
```python
from langchain_core.example_selectors import SemanticSimilarityExampleSelector
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma

examples = [
    {"input": "apple", "output": "fruit"},
    {"input": "banana", "output": "fruit"},
    {"input": "carrot", "output": "vegetable"},
    {"input": "broccoli", "output": "vegetable"},
    {"input": "chicken", "output": "meat"},
    {"input": "beef", "output": "meat"}
]

# Create selector
selector = SemanticSimilarityExampleSelector.from_examples(
    examples,
    OpenAIEmbeddings(),
    Chroma,
    k=2  # Select 2 most similar examples
)

# Test
selected = selector.select_examples({"input": "grape"})
print(selected)
# Output: [
#   {"input": "apple", "output": "fruit"},
#   {"input": "banana", "output": "fruit"}
# ]
```

**How it works:**
1. Embeds all example inputs
2. Embeds the new input
3. Finds k most similar examples using cosine similarity
4. Returns selected examples

### 2. Length-Based

Select examples to fit within token limit:

**Python:**
```python
from langchain_core.example_selectors import LengthBasedExampleSelector
from langchain_core.prompts import PromptTemplate

examples = [
    {"input": "apple", "output": "fruit"},
    {"input": "carrot", "output": "vegetable"},
    {"input": "chicken", "output": "meat"}
]

example_prompt = PromptTemplate(
    input_variables=["input", "output"],
    template="Input: {input}\nOutput: {output}"
)

selector = LengthBasedExampleSelector(
    examples=examples,
    example_prompt=example_prompt,
    max_length=100  # Maximum total tokens
)

# For short inputs: includes more examples
selected = selector.select_examples({"input": "grape"})
print(f"Short input: {len(selected)} examples")

# For long inputs: includes fewer examples
long_input = "This is a very long input " * 20
selected = selector.select_examples({"input": long_input})
print(f"Long input: {len(selected)} examples")
```

**How it works:**
1. Estimates token count for input + examples
2. Includes examples until reaching max_length
3. Prioritizes examples in order provided

### 3. MaxMarginalRelevance (MMR)

Select relevant but diverse examples:

**Python:**
```python
from langchain_core.example_selectors import MaxMarginalRelevanceExampleSelector

examples = [
    {"input": "apple", "output": "fruit"},
    {"input": "banana", "output": "fruit"},
    {"input": "orange", "output": "fruit"},
    {"input": "carrot", "output": "vegetable"},
    {"input": "chicken", "output": "meat"}
]

selector = MaxMarginalRelevanceExampleSelector.from_examples(
    examples,
    OpenAIEmbeddings(),
    Chroma,
    k=3  # Select 3 examples
)

# Selects relevant AND diverse examples
selected = selector.select_examples({"input": "strawberry"})
# Might return: apple (similar), carrot (diverse), chicken (diverse)
```

**How it works:**
1. Finds relevant examples (similar to input)
2. Also considers diversity (different from each other)
3. Balances relevance and diversity

### 4. NGram Overlap

Select based on character n-gram overlap:

**Python:**
```python
from langchain_core.example_selectors import NGramOverlapExampleSelector

examples = [
    {"input": "The quick brown fox", "output": "animal"},
    {"input": "A lazy dog sleeps", "output": "animal"},
    {"input": "The red car speeds", "output": "vehicle"}
]

selector = NGramOverlapExampleSelector(
    examples=examples,
    example_prompt=example_prompt,
    threshold=-1.0  # Minimum similarity threshold
)

selected = selector.select_examples({"input": "The fast brown car"})
# Selects examples with most character overlap
```

## Using Selectors with Prompts

### With FewShotPromptTemplate

**Python:**
```python
from langchain_core.prompts import FewShotChatMessagePromptTemplate, ChatPromptTemplate

# Create selector
selector = SemanticSimilarityExampleSelector.from_examples(
    examples,
    OpenAIEmbeddings(),
    Chroma,
    k=3
)

# Example template
example_prompt = ChatPromptTemplate.from_messages([
    ("human", "{input}"),
    ("ai", "{output}")
])

# Few-shot prompt with selector
few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    example_selector=selector  # Use selector instead of static examples
)

# Final prompt
final_prompt = ChatPromptTemplate.from_messages([
    ("system", "Classify into fruit, vegetable, or meat"),
    few_shot_prompt,
    ("human", "{input}")
])

# Use with chain
from langchain_openai import ChatOpenAI

chain = final_prompt | ChatOpenAI()
result = chain.invoke({"input": "strawberry"})
```

## Custom Example Selector

### Basic Custom Selector

**Python:**
```python
from langchain_core.example_selectors import BaseExampleSelector
from typing import Dict, List

class CustomExampleSelector(BaseExampleSelector):
    def __init__(self, examples: List[Dict[str, str]]):
        self.examples = examples

    def add_example(self, example: Dict[str, str]) -> None:
        """Add new example to store."""
        self.examples.append(example)

    def select_examples(self, input_variables: Dict[str, str]) -> List[Dict]:
        """Select examples based on custom logic."""
        # Custom selection logic here
        user_input = input_variables["input"]

        # Example: Select by string length similarity
        input_len = len(user_input)
        sorted_examples = sorted(
            self.examples,
            key=lambda x: abs(len(x["input"]) - input_len)
        )

        # Return top 3
        return sorted_examples[:3]

# Usage
selector = CustomExampleSelector(examples)
selected = selector.select_examples({"input": "test"})
```

### Advanced Custom Selector

**Python:**
```python
class SmartExampleSelector(BaseExampleSelector):
    def __init__(
        self,
        examples: List[Dict],
        embeddings,
        vectorstore_cls,
        k: int = 3
    ):
        self.examples = examples
        self.k = k

        # Create vector store
        texts = [ex["input"] for ex in examples]
        self.vectorstore = vectorstore_cls.from_texts(
            texts,
            embeddings,
            metadatas=examples
        )

    def add_example(self, example: Dict) -> None:
        self.examples.append(example)
        # Update vector store
        self.vectorstore.add_texts(
            [example["input"]],
            metadatas=[example]
        )

    def select_examples(self, input_variables: Dict) -> List[Dict]:
        user_input = input_variables["input"]

        # Semantic search
        results = self.vectorstore.similarity_search(
            user_input,
            k=self.k
        )

        # Extract examples from results
        return [r.metadata for r in results]

# Usage
selector = SmartExampleSelector(
    examples,
    OpenAIEmbeddings(),
    Chroma,
    k=3
)
```

### Conditional Selector

**Python:**
```python
class ConditionalExampleSelector(BaseExampleSelector):
    def __init__(self, example_sets: Dict[str, List[Dict]]):
        self.example_sets = example_sets

    def add_example(self, example: Dict, category: str) -> None:
        if category not in self.example_sets:
            self.example_sets[category] = []
        self.example_sets[category].append(example)

    def select_examples(self, input_variables: Dict) -> List[Dict]:
        user_input = input_variables["input"]

        # Determine category
        if "python" in user_input.lower():
            category = "python"
        elif "javascript" in user_input.lower():
            category = "javascript"
        else:
            category = "general"

        # Return examples for that category
        return self.example_sets.get(category, [])[:3]

# Usage
selector = ConditionalExampleSelector({
    "python": python_examples,
    "javascript": js_examples,
    "general": general_examples
})
```

## Real-World Examples

### 1. Code Examples by Language

**Python:**
```python
class LanguageAwareSelector(BaseExampleSelector):
    def __init__(self, examples_by_language: Dict[str, List[Dict]]):
        self.examples_by_language = examples_by_language

    def add_example(self, example: Dict, language: str) -> None:
        if language not in self.examples_by_language:
            self.examples_by_language[language] = []
        self.examples_by_language[language].append(example)

    def select_examples(self, input_variables: Dict) -> List[Dict]:
        # Detect language from input
        user_input = input_variables["input"].lower()

        for lang in self.examples_by_language.keys():
            if lang in user_input:
                return self.examples_by_language[lang][:3]

        # Default to first language
        return list(self.examples_by_language.values())[0][:3]

# Usage
selector = LanguageAwareSelector({
    "python": [
        {"input": "create list", "output": "my_list = []"},
        {"input": "loop", "output": "for i in range(10):"}
    ],
    "javascript": [
        {"input": "create array", "output": "const arr = []"},
        {"input": "loop", "output": "for (let i = 0; i < 10; i++)"}
    ]
})
```

### 2. Domain-Specific Selector

**Python:**
```python
class DomainSelector(BaseExampleSelector):
    def __init__(self, examples: List[Dict], embeddings):
        self.examples = examples
        self.embeddings = embeddings

        # Group examples by domain
        self.domains = {}
        for ex in examples:
            domain = ex.get("domain", "general")
            if domain not in self.domains:
                self.domains[domain] = []
            self.domains[domain].append(ex)

    def select_examples(self, input_variables: Dict) -> List[Dict]:
        user_input = input_variables["input"]

        # Detect domain (simplified)
        detected_domain = self._detect_domain(user_input)

        # Get examples from that domain
        domain_examples = self.domains.get(detected_domain, self.examples)

        # Select most similar from domain
        return domain_examples[:3]

    def _detect_domain(self, text: str) -> str:
        # Custom domain detection logic
        text_lower = text.lower()
        if any(word in text_lower for word in ["medical", "health", "patient"]):
            return "medical"
        elif any(word in text_lower for word in ["legal", "law", "court"]):
            return "legal"
        else:
            return "general"
```

### 3. Difficulty-Based Selector

**Python:**
```python
class DifficultySelector(BaseExampleSelector):
    def __init__(self, examples: List[Dict]):
        self.examples = examples

    def add_example(self, example: Dict) -> None:
        self.examples.append(example)

    def select_examples(self, input_variables: Dict) -> List[Dict]:
        user_input = input_variables["input"]

        # Estimate difficulty
        difficulty = self._estimate_difficulty(user_input)

        # Filter examples by similar difficulty
        similar_difficulty = [
            ex for ex in self.examples
            if abs(ex.get("difficulty", 0) - difficulty) <= 1
        ]

        return similar_difficulty[:3]

    def _estimate_difficulty(self, text: str) -> int:
        """Estimate difficulty from 1-5"""
        # Simple heuristic: longer = harder
        length = len(text.split())
        if length < 5:
            return 1
        elif length < 10:
            return 2
        elif length < 20:
            return 3
        elif length < 40:
            return 4
        else:
            return 5

# Usage
examples_with_difficulty = [
    {"input": "2 + 2", "output": "4", "difficulty": 1},
    {"input": "solve x^2 + 5x + 6 = 0", "output": "x = -2 or -3", "difficulty": 3}
]

selector = DifficultySelector(examples_with_difficulty)
```

## Combining Selectors

### Sequential Selection

**Python:**
```python
class CompositeSelector(BaseExampleSelector):
    def __init__(self, selectors: List[BaseExampleSelector]):
        self.selectors = selectors

    def add_example(self, example: Dict) -> None:
        for selector in self.selectors:
            selector.add_example(example)

    def select_examples(self, input_variables: Dict) -> List[Dict]:
        # Apply selectors in sequence
        candidates = None

        for selector in self.selectors:
            if candidates is None:
                candidates = selector.examples
            else:
                # Filter candidates through next selector
                # (Implementation depends on selector type)
                pass

        return candidates[:5]
```

### Fallback Selection

**Python:**
```python
class FallbackSelector(BaseExampleSelector):
    def __init__(
        self,
        primary_selector: BaseExampleSelector,
        fallback_selector: BaseExampleSelector,
        min_examples: int = 1
    ):
        self.primary = primary_selector
        self.fallback = fallback_selector
        self.min_examples = min_examples

    def add_example(self, example: Dict) -> None:
        self.primary.add_example(example)
        self.fallback.add_example(example)

    def select_examples(self, input_variables: Dict) -> List[Dict]:
        # Try primary selector
        selected = self.primary.select_examples(input_variables)

        # Fall back if not enough examples
        if len(selected) < self.min_examples:
            selected = self.fallback.select_examples(input_variables)

        return selected
```

## Best Practices

### 1. Choose Appropriate Selector

```python
# Good: Semantic similarity for large, diverse example sets
if len(examples) > 50:
    selector = SemanticSimilarityExampleSelector.from_examples(...)

# Good: Length-based for strict token limits
if strict_token_limit:
    selector = LengthBasedExampleSelector(...)

# Good: Custom for specific business logic
if custom_requirements:
    selector = CustomExampleSelector(...)
```

### 2. Set Appropriate k Value

```python
# Good: 3-5 examples for most tasks
selector = SemanticSimilarityExampleSelector.from_examples(
    examples,
    embeddings,
    vectorstore,
    k=3  # Sweet spot for most tasks
)

# Avoid: Too many examples
selector = SemanticSimilarityExampleSelector.from_examples(
    examples,
    embeddings,
    vectorstore,
    k=20  # Too many, expensive and may confuse model
)
```

### 3. Cache Embeddings

```python
# Good: Embed examples once
vectorstore = Chroma.from_texts(
    [ex["input"] for ex in examples],
    embeddings,
    metadatas=examples
)

selector = SemanticSimilarityExampleSelector(
    vectorstore=vectorstore,
    k=3
)

# Avoid: Re-embedding every time
# selector = SemanticSimilarityExampleSelector.from_examples(...)  # Embeds again!
```

### 4. Monitor Selection Quality

```python
# Good: Log selected examples
def select_with_logging(selector, input_variables):
    selected = selector.select_examples(input_variables)
    print(f"Selected {len(selected)} examples for: {input_variables['input']}")
    for ex in selected:
        print(f"  - {ex['input']}")
    return selected
```

### 5. Combine with Length Limits

```python
# Good: Ensure examples fit in context
max_examples = 5
max_tokens = 2000

def select_within_limits(selector, input_variables):
    selected = selector.select_examples(input_variables)

    # Limit by count
    selected = selected[:max_examples]

    # Limit by tokens (simplified)
    total_tokens = 0
    limited = []
    for ex in selected:
        ex_tokens = len(str(ex))  # Use real token counter
        if total_tokens + ex_tokens < max_tokens:
            limited.append(ex)
            total_tokens += ex_tokens

    return limited
```

## Performance Considerations

### 1. Vector Store Choice

```python
# Fast but in-memory
Chroma  # Good for development

# Persistent and scalable
Pinecone  # Good for production
Qdrant    # Good for production
```

### 2. Embedding Model

```python
# Fast but less accurate
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")

# Slower but more accurate
embeddings = OpenAIEmbeddings(model="text-embedding-3-large")
```

### 3. Batch Processing

```python
# Good: Batch similar queries
inputs = ["query1", "query2", "query3"]

for inp in inputs:
    selected = selector.select_examples({"input": inp})
    # Use selected examples
```

## Related Documentation

- [Few-Shot Prompting](./13-few-shot-prompting.md)
- [Prompt Templates](./11-prompt-templates.md)
- [Embeddings](./18-embeddings.md)
- [Vector Stores](./19-vector-stores.md)
