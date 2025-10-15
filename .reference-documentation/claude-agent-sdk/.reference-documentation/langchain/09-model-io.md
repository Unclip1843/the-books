# LangChain - Model I/O

**Sources:**
- https://python.langchain.com/docs/concepts/prompt_templates/
- https://python.langchain.com/docs/concepts/messages/
- https://python.langchain.com/docs/concepts/output_parsers/

**Fetched:** 2025-10-11

## Overview

Model I/O is the interface layer between your application and language models:

```
┌──────────────────────────────────────┐
│         Your Application             │
└────────────┬─────────────────────────┘
             │
┌────────────▼─────────────────────────┐
│        Prompt Templates              │ Input formatting
│        Few-shot Examples             │
│        Example Selectors             │
└────────────┬─────────────────────────┘
             │
┌────────────▼─────────────────────────┐
│        Language Model                │
└────────────┬─────────────────────────┘
             │
┌────────────▼─────────────────────────┐
│        Output Parsers                │ Output parsing
│        Structured Data               │
└──────────────────────────────────────┘
```

## Prompt Templates

### Basic Templates

**Python:**
```python
from langchain_core.prompts import ChatPromptTemplate

# Simple template
prompt = ChatPromptTemplate.from_template(
    "Tell me a joke about {topic}"
)

# Format
formatted = prompt.invoke({"topic": "programming"})
print(formatted)
# Output: [HumanMessage(content='Tell me a joke about programming')]
```

**TypeScript:**
```typescript
import { ChatPromptTemplate } from "@langchain/core/prompts";

const prompt = ChatPromptTemplate.fromTemplate(
  "Tell me a joke about {topic}"
);

const formatted = await prompt.invoke({ topic: "programming" });
console.log(formatted);
```

### Message Templates

**Python:**
```python
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful AI assistant specializing in {domain}"),
    ("human", "{input}")
])

formatted = prompt.invoke({
    "domain": "Python programming",
    "input": "How do I use list comprehensions?"
})
```

**TypeScript:**
```typescript
import { ChatPromptTemplate } from "@langchain/core/prompts";

const prompt = ChatPromptTemplate.fromMessages([
  ["system", "You are a helpful AI assistant specializing in {domain}"],
  ["human", "{input}"]
]);

const formatted = await prompt.invoke({
  domain: "Python programming",
  input: "How do I use list comprehensions?"
});
```

### Multiple Variables

```python
prompt = ChatPromptTemplate.from_template(
    "Translate {text} from {source_lang} to {target_lang}"
)

formatted = prompt.invoke({
    "text": "Hello, world!",
    "source_lang": "English",
    "target_lang": "Spanish"
})
```

## Messages

### Message Types

**Python:**
```python
from langchain_core.messages import (
    SystemMessage,
    HumanMessage,
    AIMessage,
    FunctionMessage
)

# System message - Set behavior
system = SystemMessage(content="You are a helpful assistant")

# Human message - User input
human = HumanMessage(content="What is AI?")

# AI message - Assistant response
ai = AIMessage(content="AI stands for Artificial Intelligence...")

# Function message - Function results
function = FunctionMessage(
    name="get_weather",
    content="Sunny, 72°F"
)
```

**TypeScript:**
```typescript
import {
  SystemMessage,
  HumanMessage,
  AIMessage,
  FunctionMessage
} from "@langchain/core/messages";

const system = new SystemMessage("You are a helpful assistant");
const human = new HumanMessage("What is AI?");
const ai = new AIMessage("AI stands for...");
```

### MessagesPlaceholder

Dynamic message insertion:

**Python:**
```python
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant"),
    MessagesPlaceholder("chat_history"),
    ("human", "{input}")
])

# Use with history
formatted = prompt.invoke({
    "chat_history": [
        HumanMessage(content="Hi, I'm Alice"),
        AIMessage(content="Hello Alice!")
    ],
    "input": "What's my name?"
})
```

### Message Construction

**Python:**
```python
from langchain_core.messages import HumanMessage

# Simple text
msg1 = HumanMessage(content="Hello")

# With metadata
msg2 = HumanMessage(
    content="Hello",
    additional_kwargs={"user_id": "123"}
)

# Multimodal
msg3 = HumanMessage(
    content=[
        {"type": "text", "text": "What's in this image?"},
        {"type": "image_url", "image_url": {"url": "https://..."}}
    ]
)
```

## Few-Shot Prompting

### Static Examples

**Python:**
```python
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

# Few-shot prompt
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
formatted = final_prompt.invoke({"input": "banana"})
```

**TypeScript:**
```typescript
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
```

## Example Selectors

### Semantic Similarity

Select examples based on similarity to input:

**Python:**
```python
from langchain_core.example_selectors import SemanticSimilarityExampleSelector
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma

# Examples
examples = [
    {"input": "apple", "output": "fruit"},
    {"input": "carrot", "output": "vegetable"},
    {"input": "chicken", "output": "meat"},
    {"input": "banana", "output": "fruit"},
    {"input": "broccoli", "output": "vegetable"}
]

# Create selector
example_selector = SemanticSimilarityExampleSelector.from_examples(
    examples,
    OpenAIEmbeddings(),
    Chroma,
    k=2  # Select 2 most similar
)

# Use in few-shot prompt
few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    example_selector=example_selector
)

# Input "grape" will select similar fruit examples
formatted = final_prompt.invoke({"input": "grape"})
```

### Length-Based Selection

Select examples to fit token limit:

**Python:**
```python
from langchain_core.example_selectors import LengthBasedExampleSelector

example_selector = LengthBasedExampleSelector(
    examples=examples,
    example_prompt=example_prompt,
    max_length=100  # Token limit
)

few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    example_selector=example_selector
)
```

## Output Parsers

### String Output Parser

**Python:**
```python
from langchain_core.output_parsers import StrOutputParser
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()
parser = StrOutputParser()

chain = prompt | llm | parser

# Returns string instead of AIMessage
result = chain.invoke({"topic": "AI"})
print(result)  # "Here's a joke about AI..."
```

### JSON Output Parser

**Python:**
```python
from langchain_core.output_parsers import JsonOutputParser

prompt = ChatPromptTemplate.from_template(
    "Extract information from this text: {text}\n"
    "Return JSON with keys: name, age, occupation"
)

parser = JsonOutputParser()

chain = prompt | llm | parser

result = chain.invoke({"text": "John is a 30 year old engineer"})
print(result)  # {"name": "John", "age": 30, "occupation": "engineer"}
```

### Pydantic Output Parser

**Python:**
```python
from langchain_core.output_parsers import PydanticOutputParser
from langchain_core.pydantic_v1 import BaseModel, Field

class Person(BaseModel):
    name: str = Field(description="Person's name")
    age: int = Field(description="Person's age")
    occupation: str = Field(description="Person's occupation")

parser = PydanticOutputParser(pydantic_object=Person)

prompt = ChatPromptTemplate.from_template(
    "Extract information: {text}\n{format_instructions}"
)

chain = prompt | llm | parser

result = chain.invoke({
    "text": "John is a 30 year old engineer",
    "format_instructions": parser.get_format_instructions()
})

print(result.name)  # "John"
print(result.age)   # 30
```

### List Output Parser

**Python:**
```python
from langchain_core.output_parsers import CommaSeparatedListOutputParser

parser = CommaSeparatedListOutputParser()

prompt = ChatPromptTemplate.from_template(
    "List 5 colors\n{format_instructions}"
)

chain = prompt | llm | parser

result = chain.invoke({
    "format_instructions": parser.get_format_instructions()
})

print(result)  # ["red", "blue", "green", "yellow", "orange"]
```

### Structured Output Parser

**Python:**
```python
from langchain_core.output_parsers import StructuredOutputParser, ResponseSchema

# Define schema
response_schemas = [
    ResponseSchema(name="name", description="Person's name"),
    ResponseSchema(name="age", description="Person's age"),
    ResponseSchema(name="occupation", description="Person's occupation")
]

parser = StructuredOutputParser.from_response_schemas(response_schemas)

prompt = ChatPromptTemplate.from_template(
    "Extract information: {text}\n{format_instructions}"
)

chain = prompt | llm | parser

result = chain.invoke({
    "text": "John is a 30 year old engineer",
    "format_instructions": parser.get_format_instructions()
})

print(result)  # {"name": "John", "age": "30", "occupation": "engineer"}
```

## Complete Example

### Sentiment Analysis with Structured Output

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import PydanticOutputParser
from langchain_core.pydantic_v1 import BaseModel, Field

# Define output structure
class SentimentAnalysis(BaseModel):
    sentiment: str = Field(description="Sentiment: positive, negative, or neutral")
    confidence: float = Field(description="Confidence score 0-1")
    reasoning: str = Field(description="Brief explanation")

# Create parser
parser = PydanticOutputParser(pydantic_object=SentimentAnalysis)

# Create prompt
prompt = ChatPromptTemplate.from_template(
    "Analyze the sentiment of this text: {text}\n\n{format_instructions}"
)

# Create chain
llm = ChatOpenAI(model="gpt-4", temperature=0)
chain = prompt | llm | parser

# Use
result = chain.invoke({
    "text": "I absolutely loved this product! Best purchase ever!",
    "format_instructions": parser.get_format_instructions()
})

print(f"Sentiment: {result.sentiment}")
print(f"Confidence: {result.confidence}")
print(f"Reasoning: {result.reasoning}")
```

**Output:**
```
Sentiment: positive
Confidence: 0.95
Reasoning: Strong positive words like "absolutely loved" and "Best purchase ever"
```

## Partial Variables

Pre-fill some template variables:

**Python:**
```python
from datetime import datetime

prompt = ChatPromptTemplate.from_template(
    "Today is {date}. Tell me a fact about {topic}"
)

# Partial with current date
partial_prompt = prompt.partial(date=datetime.now().strftime("%Y-%m-%d"))

# Only need to provide topic
formatted = partial_prompt.invoke({"topic": "AI"})
```

## Format Instructions

Auto-generate format instructions:

**Python:**
```python
from langchain_core.output_parsers import PydanticOutputParser

parser = PydanticOutputParser(pydantic_object=Person)

# Get format instructions
format_instructions = parser.get_format_instructions()

print(format_instructions)
# Output: "The output should be formatted as a JSON instance that conforms to..."

# Use in prompt
prompt = ChatPromptTemplate.from_template(
    "Extract info: {text}\n\n{format_instructions}"
)

chain = prompt | llm | parser
```

## Error Handling

### Output Fixing Parser

Automatically fix parsing errors:

**Python:**
```python
from langchain_core.output_parsers import OutputFixingParser
from langchain_openai import ChatOpenAI

base_parser = PydanticOutputParser(pydantic_object=Person)

# Wrap with fixing parser
fixing_parser = OutputFixingParser.from_llm(
    parser=base_parser,
    llm=ChatOpenAI()
)

# Will attempt to fix malformed output
try:
    result = fixing_parser.parse(malformed_output)
except Exception as e:
    print(f"Could not fix: {e}")
```

### Retry Parser

Retry with additional context:

**Python:**
```python
from langchain_core.output_parsers import RetryWithErrorOutputParser

base_parser = PydanticOutputParser(pydantic_object=Person)

retry_parser = RetryWithErrorOutputParser.from_llm(
    parser=base_parser,
    llm=ChatOpenAI()
)

# Retry if parsing fails
result = retry_parser.parse_with_prompt(
    completion=llm_output,
    prompt_value=original_prompt
)
```

## Best Practices

### 1. Use Specific Prompts

```python
# Good: Specific
prompt = ChatPromptTemplate.from_template(
    "Extract the person's name, age, and occupation from: {text}"
)

# Avoid: Vague
prompt = ChatPromptTemplate.from_template(
    "Get info from: {text}"
)
```

### 2. Include Format Instructions

```python
# Good: Clear format
prompt = ChatPromptTemplate.from_template(
    "Extract info: {text}\n\nFormat: {format_instructions}"
)

# Avoid: Implicit format
prompt = ChatPromptTemplate.from_template(
    "Extract info: {text}"
)
```

### 3. Use Pydantic for Type Safety

```python
# Good: Type-safe
class Person(BaseModel):
    name: str
    age: int

parser = PydanticOutputParser(pydantic_object=Person)

# Avoid: Unstructured
parser = JsonOutputParser()
```

### 4. Handle Parsing Errors

```python
# Good: Error handling
try:
    result = parser.parse(output)
except Exception as e:
    print(f"Parsing error: {e}")
    # Fallback logic

# Avoid: Assuming success
result = parser.parse(output)
```

## Related Documentation

- [Prompt Templates](./11-prompt-templates.md)
- [Messages](./12-messages.md)
- [Few-Shot Prompting](./13-few-shot-prompting.md)
- [Example Selectors](./14-example-selectors.md)
- [Output Parsers](./70-output-parsers.md)
- [Structured Outputs](./10-structured-outputs.md)
