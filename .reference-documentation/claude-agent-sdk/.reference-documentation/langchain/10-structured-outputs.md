# LangChain - Structured Outputs

**Sources:**
- https://python.langchain.com/docs/how_to/structured_output/
- https://python.langchain.com/docs/concepts/structured_outputs/
- https://js.langchain.com/docs/how_to/structured_output/

**Fetched:** 2025-10-11

## What are Structured Outputs?

Structured outputs convert free-form LLM text into **typed, validated data structures**:

```python
# Unstructured
"John is 30 years old and works as an engineer"

# Structured
{
    "name": "John",
    "age": 30,
    "occupation": "engineer"
}
```

## Why Use Structured Outputs?

1. **Type Safety** - Guaranteed data types
2. **Validation** - Automatic schema validation
3. **Integration** - Easy to use in downstream systems
4. **Reliability** - Catch errors early
5. **Consistency** - Same format every time

## Methods for Structured Outputs

### 1. with_structured_output() (Recommended)

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.pydantic_v1 import BaseModel, Field

class Person(BaseModel):
    name: str = Field(description="Person's name")
    age: int = Field(description="Person's age")
    occupation: str = Field(description="Person's occupation")

llm = ChatOpenAI(model="gpt-4")
structured_llm = llm.with_structured_output(Person)

result = structured_llm.invoke("John is a 30 year old engineer")

print(result.name)        # "John"
print(result.age)         # 30
print(result.occupation)  # "engineer"
```

**TypeScript:**
```typescript
import { ChatOpenAI } from "@langchain/openai";
import { z } from "zod";

const PersonSchema = z.object({
  name: z.string().describe("Person's name"),
  age: z.number().describe("Person's age"),
  occupation: z.string().describe("Person's occupation")
});

const llm = new ChatOpenAI({ model: "gpt-4" });
const structuredLlm = llm.withStructuredOutput(PersonSchema);

const result = await structuredLlm.invoke("John is a 30 year old engineer");

console.log(result.name);        // "John"
console.log(result.age);         // 30
console.log(result.occupation);  // "engineer"
```

### 2. JSON Mode

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate

llm = ChatOpenAI(model="gpt-4", model_kwargs={"response_format": {"type": "json_object"}})

prompt = ChatPromptTemplate.from_template(
    "Extract person info as JSON: {text}"
)

chain = prompt | llm

result = chain.invoke({"text": "John is a 30 year old engineer"})
print(result.content)  # JSON string
```

### 3. Pydantic Output Parser

**Python:**
```python
from langchain_core.output_parsers import PydanticOutputParser
from langchain_core.pydantic_v1 import BaseModel, Field

class Person(BaseModel):
    name: str = Field(description="Person's name")
    age: int = Field(description="Person's age")

parser = PydanticOutputParser(pydantic_object=Person)

prompt = ChatPromptTemplate.from_template(
    "Extract info: {text}\n\n{format_instructions}"
)

chain = prompt | llm | parser

result = chain.invoke({
    "text": "John is 30 years old",
    "format_instructions": parser.get_format_instructions()
})
```

## Pydantic Models

### Basic Model

**Python:**
```python
from langchain_core.pydantic_v1 import BaseModel, Field

class Product(BaseModel):
    name: str = Field(description="Product name")
    price: float = Field(description="Product price")
    in_stock: bool = Field(description="Is product in stock")

llm = ChatOpenAI(model="gpt-4")
structured_llm = llm.with_structured_output(Product)

result = structured_llm.invoke("iPhone 15 costs $999 and is available")
```

### Nested Models

**Python:**
```python
class Address(BaseModel):
    street: str
    city: str
    country: str

class Person(BaseModel):
    name: str
    age: int
    address: Address

structured_llm = llm.with_structured_output(Person)

result = structured_llm.invoke(
    "John is 30, lives at 123 Main St, San Francisco, USA"
)

print(result.address.city)  # "San Francisco"
```

### Optional Fields

**Python:**
```python
from typing import Optional

class Person(BaseModel):
    name: str
    age: Optional[int] = None  # Optional field
    email: Optional[str] = None

structured_llm = llm.with_structured_output(Person)

result = structured_llm.invoke("Alice works here")
# name: "Alice", age: None, email: None
```

### Lists

**Python:**
```python
from typing import List

class People(BaseModel):
    people: List[Person]

structured_llm = llm.with_structured_output(People)

result = structured_llm.invoke(
    "John is 30, Alice is 25, Bob is 35"
)

for person in result.people:
    print(f"{person.name}: {person.age}")
```

### Enums

**Python:**
```python
from enum import Enum

class Sentiment(str, Enum):
    POSITIVE = "positive"
    NEGATIVE = "negative"
    NEUTRAL = "neutral"

class Review(BaseModel):
    text: str
    sentiment: Sentiment
    score: int = Field(ge=1, le=5)  # 1-5 range

structured_llm = llm.with_structured_output(Review)

result = structured_llm.invoke("Great product! Highly recommend.")
print(result.sentiment)  # Sentiment.POSITIVE
```

## TypeScript with Zod

### Basic Schema

```typescript
import { ChatOpenAI } from "@langchain/openai";
import { z } from "zod";

const ProductSchema = z.object({
  name: z.string(),
  price: z.number(),
  inStock: z.boolean()
});

const llm = new ChatOpenAI({ model: "gpt-4" });
const structuredLlm = llm.withStructuredOutput(ProductSchema);

const result = await structuredLlm.invoke("iPhone 15 costs $999 and is available");
console.log(result.name);  // "iPhone 15"
```

### Nested Schemas

```typescript
const AddressSchema = z.object({
  street: z.string(),
  city: z.string(),
  country: z.string()
});

const PersonSchema = z.object({
  name: z.string(),
  age: z.number(),
  address: AddressSchema
});

const structuredLlm = llm.withStructuredOutput(PersonSchema);

const result = await structuredLlm.invoke(
  "John is 30, lives at 123 Main St, San Francisco, USA"
);
```

### Optional Fields

```typescript
const PersonSchema = z.object({
  name: z.string(),
  age: z.number().optional(),
  email: z.string().email().optional()
});
```

### Arrays

```typescript
const PeopleSchema = z.object({
  people: z.array(PersonSchema)
});

const structuredLlm = llm.withStructuredOutput(PeopleSchema);

const result = await structuredLlm.invoke("John is 30, Alice is 25");
```

### Enums

```typescript
const SentimentSchema = z.enum(["positive", "negative", "neutral"]);

const ReviewSchema = z.object({
  text: z.string(),
  sentiment: SentimentSchema,
  score: z.number().min(1).max(5)
});
```

## Real-World Examples

### 1. Contact Information Extraction

**Python:**
```python
from typing import Optional, List

class ContactInfo(BaseModel):
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    company: Optional[str] = None

structured_llm = llm.with_structured_output(ContactInfo)

text = """
Hi, I'm John Smith from Acme Corp.
You can reach me at john@acme.com or 555-1234.
"""

result = structured_llm.invoke(text)
print(result.model_dump())
# {
#   "name": "John Smith",
#   "email": "john@acme.com",
#   "phone": "555-1234",
#   "company": "Acme Corp"
# }
```

### 2. Product Reviews

**Python:**
```python
class Review(BaseModel):
    product: str
    rating: int = Field(ge=1, le=5)
    sentiment: str
    pros: List[str]
    cons: List[str]
    would_recommend: bool

structured_llm = llm.with_structured_output(Review)

text = """
The iPhone 15 is amazing! Great camera and battery life.
However, it's quite expensive. Still, I'd recommend it.
Rating: 4/5
"""

result = structured_llm.invoke(text)
```

### 3. Meeting Notes

**Python:**
```python
from datetime import datetime

class MeetingNote(BaseModel):
    title: str
    date: str
    attendees: List[str]
    topics: List[str]
    action_items: List[str]
    next_meeting: Optional[str] = None

structured_llm = llm.with_structured_output(MeetingNote)

text = """
Team Standup - Jan 15, 2024
Present: Alice, Bob, Charlie

Topics:
- Q1 planning
- Bug fixes

Actions:
- Alice: Fix login bug
- Bob: Update docs

Next meeting: Jan 22
"""

result = structured_llm.invoke(text)
```

### 4. Invoice Parsing

**Python:**
```python
class LineItem(BaseModel):
    description: str
    quantity: int
    unit_price: float
    total: float

class Invoice(BaseModel):
    invoice_number: str
    date: str
    vendor: str
    items: List[LineItem]
    subtotal: float
    tax: float
    total: float

structured_llm = llm.with_structured_output(Invoice)

invoice_text = """
Invoice #12345
Date: 2024-01-15
Vendor: Acme Corp

Items:
1. Widget A - 5x $10 = $50
2. Widget B - 3x $20 = $60

Subtotal: $110
Tax: $11
Total: $121
"""

result = structured_llm.invoke(invoice_text)
```

### 5. Resume Parsing

**Python:**
```python
class Education(BaseModel):
    degree: str
    institution: str
    year: int

class Experience(BaseModel):
    title: str
    company: str
    duration: str
    responsibilities: List[str]

class Resume(BaseModel):
    name: str
    email: str
    phone: str
    education: List[Education]
    experience: List[Experience]
    skills: List[str]

structured_llm = llm.with_structured_output(Resume)

resume_text = """
John Doe
john@email.com | 555-1234

Education:
- BS Computer Science, MIT, 2018
- MS AI, Stanford, 2020

Experience:
Software Engineer at Google (2020-2023)
- Built ML models
- Improved performance

Skills: Python, ML, TensorFlow
"""

result = structured_llm.invoke(resume_text)
```

## Validation

### Field Constraints

**Python:**
```python
from langchain_core.pydantic_v1 import validator

class Person(BaseModel):
    name: str
    age: int = Field(ge=0, le=150)  # 0-150 range
    email: str

    @validator('email')
    def validate_email(cls, v):
        if '@' not in v:
            raise ValueError('Invalid email')
        return v

    @validator('name')
    def validate_name(cls, v):
        if len(v) < 2:
            raise ValueError('Name too short')
        return v
```

### Custom Validators

**Python:**
```python
class Product(BaseModel):
    name: str
    price: float

    @validator('price')
    def price_must_be_positive(cls, v):
        if v <= 0:
            raise ValueError('Price must be positive')
        return v

    @validator('name')
    def name_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v.strip()
```

## Error Handling

### Try/Except

```python
try:
    result = structured_llm.invoke(text)
except Exception as e:
    print(f"Parsing error: {e}")
    # Fallback logic
```

### Output Fixing Parser

```python
from langchain_core.output_parsers import OutputFixingParser

base_parser = PydanticOutputParser(pydantic_object=Person)

fixing_parser = OutputFixingParser.from_llm(
    parser=base_parser,
    llm=ChatOpenAI()
)

# Attempts to fix malformed output
result = fixing_parser.parse(malformed_json)
```

### Retry Parser

```python
from langchain_core.output_parsers import RetryWithErrorOutputParser

retry_parser = RetryWithErrorOutputParser.from_llm(
    parser=base_parser,
    llm=ChatOpenAI()
)

result = retry_parser.parse_with_prompt(
    completion=llm_output,
    prompt_value=original_prompt
)
```

## JSON Schema

### Generate Schema

**Python:**
```python
class Person(BaseModel):
    name: str
    age: int

# Get JSON schema
schema = Person.schema()
print(schema)
# {
#   "title": "Person",
#   "type": "object",
#   "properties": {
#     "name": {"title": "Name", "type": "string"},
#     "age": {"title": "Age", "type": "integer"}
#   },
#   "required": ["name", "age"]
# }
```

### Use Schema Directly

**Python:**
```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4")

# Pass JSON schema
structured_llm = llm.with_structured_output(
    schema={
        "type": "object",
        "properties": {
            "name": {"type": "string"},
            "age": {"type": "integer"}
        },
        "required": ["name", "age"]
    }
)
```

## Best Practices

### 1. Use Descriptive Field Names

```python
# Good
class Person(BaseModel):
    full_name: str = Field(description="Person's full legal name")
    age_in_years: int = Field(description="Age in complete years")

# Avoid
class Person(BaseModel):
    n: str
    a: int
```

### 2. Add Field Descriptions

```python
# Good
class Product(BaseModel):
    name: str = Field(description="Product name as shown on packaging")
    price: float = Field(description="Price in USD, without currency symbol")

# Avoid
class Product(BaseModel):
    name: str
    price: float
```

### 3. Use Appropriate Types

```python
# Good
from datetime import datetime

class Event(BaseModel):
    name: str
    date: str  # Or datetime for parsing
    attendee_count: int
    is_virtual: bool

# Avoid
class Event(BaseModel):
    name: str
    date: str
    attendee_count: str  # Should be int
    is_virtual: str      # Should be bool
```

### 4. Handle Optional Fields

```python
from typing import Optional

class Person(BaseModel):
    name: str  # Required
    email: Optional[str] = None  # Optional
    phone: Optional[str] = None  # Optional
```

### 5. Validate Input

```python
class Person(BaseModel):
    name: str
    age: int = Field(ge=0, le=150)  # Validation

    @validator('name')
    def name_not_empty(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v.strip()
```

## Performance Tips

### 1. Use Specific Models

```python
# Good: Use smaller model for simple extraction
llm = ChatOpenAI(model="gpt-3.5-turbo")

# Avoid: Using expensive model unnecessarily
llm = ChatOpenAI(model="gpt-4")
```

### 2. Set Temperature to 0

```python
# Deterministic structured outputs
llm = ChatOpenAI(model="gpt-4", temperature=0)
```

### 3. Cache Results

```python
from functools import lru_cache

@lru_cache(maxsize=1000)
def extract_person(text: str) -> Person:
    return structured_llm.invoke(text)
```

## Related Documentation

- [Model I/O](./09-model-io.md)
- [Output Parsers](./70-output-parsers.md)
- [Chat Models](./06-chat-models.md)
- [Prompt Templates](./11-prompt-templates.md)
