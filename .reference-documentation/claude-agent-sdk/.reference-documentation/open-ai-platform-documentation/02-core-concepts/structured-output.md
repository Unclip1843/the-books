# OpenAI Platform - Structured Output

**Source:** https://platform.openai.com/docs/guides/structured-outputs
**Fetched:** 2025-10-11

## Overview

Structured Outputs ensure that model-generated outputs exactly match JSON Schemas you provide. This guarantees reliable, parseable responses for integrations with business processes and applications.

---

## Structured Outputs vs JSON Mode

| Feature | Structured Outputs | JSON Mode |
|---------|-------------------|-----------|
| Valid JSON | ✅ | ✅ |
| Schema adherence | ✅ **100%** | ❌ Not guaranteed |
| Type safety | ✅ | ⚠️ Limited |
| Use cases | Production systems | Simple formatting |
| Strict mode | Required | N/A |

**Recommendation**: Always use Structured Outputs over JSON Mode when schema adherence is critical.

---

## Supported Models

- gpt-5
- gpt-5-mini
- gpt-4.1
- gpt-4o (2024-08-06+)
- gpt-4o-mini (2024-07-18+)

---

## Two Implementation Methods

### 1. Function Calling with `strict: true`

```python
from openai import OpenAI

client = OpenAI()

tools = [
    {
        "type": "function",
        "function": {
            "name": "extract_contact",
            "description": "Extract contact information from text",
            "strict": True,  # Enable structured outputs
            "parameters": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "email": {"type": "string"},
                    "phone": {"type": "string"}
                },
                "required": ["name", "email"],
                "additionalProperties": False
            }
        }
    }
]

response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "John Doe, john@example.com, 555-1234"}
    ],
    tools=tools,
    tool_choice={"type": "function", "function": {"name": "extract_contact"}}
)

# Extract structured data
tool_call = response.choices[0].message.tool_calls[0]
arguments = json.loads(tool_call.function.arguments)
print(arguments)
# {"name": "John Doe", "email": "john@example.com", "phone": "555-1234"}
```

### 2. Response Format with `json_schema`

```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Extract: John Doe, john@example.com, 555-1234"}
    ],
    response_format={
        "type": "json_schema",
        "json_schema": {
            "name": "contact_extraction",
            "strict": True,
            "schema": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "email": {"type": "string"},
                    "phone": {"type": "string"}
                },
                "required": ["name", "email"],
                "additionalProperties": False
            }
        }
    }
)

data = json.loads(response.choices[0].message.content)
print(data)
```

---

## JSON Schema Support

### Supported Types

```python
{
    "type": "object",
    "properties": {
        "string_field": {"type": "string"},
        "number_field": {"type": "number"},
        "integer_field": {"type": "integer"},
        "boolean_field": {"type": "boolean"},
        "array_field": {
            "type": "array",
            "items": {"type": "string"}
        },
        "object_field": {
            "type": "object",
            "properties": {
                "nested": {"type": "string"}
            }
        },
        "enum_field": {
            "type": "string",
            "enum": ["option1", "option2", "option3"]
        }
    },
    "required": ["string_field"],
    "additionalProperties": False
}
```

### Unsupported Features

❌ `format` keyword (e.g., `"format": "date-time"`)
❌ `pattern` for regex validation
❌ `minLength` / `maxLength`
❌ `minimum` / `maximum`
❌ `anyOf` / `oneOf` / `allOf`
❌ `$ref` for schema references

**Workaround**: Use `enum` for constrained values:
```python
{
    "type": "string",
    "enum": ["2024-01-01", "2024-01-02", "2024-01-03"]  # Instead of date format
}
```

---

## Common Patterns

### 1. Data Extraction

```python
def extract_user_info(text):
    """Extract structured user information."""
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": "Extract user information from the text."
            },
            {"role": "user", "content": text}
        ],
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "user_info",
                "strict": True,
                "schema": {
                    "type": "object",
                    "properties": {
                        "full_name": {"type": "string"},
                        "email": {"type": "string"},
                        "age": {"type": "integer"},
                        "interests": {
                            "type": "array",
                            "items": {"type": "string"}
                        }
                    },
                    "required": ["full_name", "email"],
                    "additionalProperties": False
                }
            }
        }
    )

    return json.loads(response.choices[0].message.content)
```

### 2. Classification

```python
def classify_ticket(ticket_text):
    """Classify support ticket."""
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {"role": "user", "content": f"Classify this ticket: {ticket_text}"}
        ],
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "ticket_classification",
                "strict": True,
                "schema": {
                    "type": "object",
                    "properties": {
                        "category": {
                            "type": "string",
                            "enum": ["billing", "technical", "account", "other"]
                        },
                        "priority": {
                            "type": "string",
                            "enum": ["low", "medium", "high", "urgent"]
                        },
                        "requires_escalation": {"type": "boolean"}
                    },
                    "required": ["category", "priority", "requires_escalation"],
                    "additionalProperties": False
                }
            }
        }
    )

    return json.loads(response.choices[0].message.content)
```

### 3. Nested Structures

```python
schema = {
    "type": "object",
    "properties": {
        "company": {"type": "string"},
        "employees": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "role": {"type": "string"},
                    "department": {"type": "string"}
                },
                "required": ["name", "role"],
                "additionalProperties": False
            }
        },
        "founded_year": {"type": "integer"}
    },
    "required": ["company", "employees"],
    "additionalProperties": False
}
```

### 4. Optional Fields

```python
{
    "type": "object",
    "properties": {
        "name": {"type": "string"},        # Required
        "email": {"type": "string"},       # Required
        "phone": {"type": "string"},       # Optional
        "address": {"type": "string"}      # Optional
    },
    "required": ["name", "email"],  # Only these are required
    "additionalProperties": False
}
```

---

## TypeScript / Pydantic Integration

### Python with Pydantic

```python
from pydantic import BaseModel
from openai import OpenAI

class Contact(BaseModel):
    name: str
    email: str
    phone: str | None = None

client = OpenAI()

# Pydantic model automatically converted to JSON Schema
response = client.beta.chat.completions.parse(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Extract: John Doe (john@example.com)"}
    ],
    response_format=Contact
)

# Automatically parsed into Pydantic model
contact = response.choices[0].message.parsed
print(contact.name)   # "John Doe"
print(contact.email)  # "john@example.com"
```

### TypeScript with Zod

```typescript
import { z } from 'zod';
import { zodResponseFormat } from 'openai/helpers/zod';

const ContactSchema = z.object({
  name: z.string(),
  email: z.string().email(),
  phone: z.string().optional(),
});

const response = await client.beta.chat.completions.parse({
  model: 'gpt-5',
  messages: [
    { role: 'user', content: 'Extract: John Doe (john@example.com)' },
  ],
  response_format: zodResponseFormat(ContactSchema, 'contact'),
});

const contact = response.choices[0].message.parsed;
console.log(contact.name);  // "John Doe"
```

---

## Advanced Examples

### 1. Multi-Entity Extraction

```python
def extract_entities(document):
    """Extract multiple entity types from document."""
    schema = {
        "type": "object",
        "properties": {
            "people": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "name": {"type": "string"},
                        "role": {"type": "string"}
                    },
                    "required": ["name"],
                    "additionalProperties": False
                }
            },
            "organizations": {
                "type": "array",
                "items": {"type": "string"}
            },
            "locations": {
                "type": "array",
                "items": {"type": "string"}
            },
            "dates": {
                "type": "array",
                "items": {"type": "string"}
            }
        },
        "required": ["people", "organizations", "locations", "dates"],
        "additionalProperties": False
    }

    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {"role": "system", "content": "Extract entities from the document."},
            {"role": "user", "content": document}
        ],
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "entity_extraction",
                "strict": True,
                "schema": schema
            }
        }
    )

    return json.loads(response.choices[0].message.content)
```

### 2. Sentiment Analysis

```python
def analyze_sentiment(reviews):
    """Analyze sentiment with structured output."""
    schema = {
        "type": "object",
        "properties": {
            "overall_sentiment": {
                "type": "string",
                "enum": ["positive", "negative", "neutral", "mixed"]
            },
            "confidence": {
                "type": "number"
            },
            "key_themes": {
                "type": "array",
                "items": {"type": "string"}
            },
            "action_items": {
                "type": "array",
                "items": {"type": "string"}
            }
        },
        "required": ["overall_sentiment", "confidence"],
        "additionalProperties": False
    }

    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {"role": "user", "content": f"Analyze these reviews:\n{reviews}"}
        ],
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "sentiment_analysis",
                "strict": True,
                "schema": schema
            }
        }
    )

    return json.loads(response.choices[0].message.content)
```

### 3. Resume Parsing

```python
def parse_resume(resume_text):
    """Parse resume into structured format."""
    schema = {
        "type": "object",
        "properties": {
            "personal_info": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "email": {"type": "string"},
                    "phone": {"type": "string"},
                    "location": {"type": "string"}
                },
                "required": ["name"],
                "additionalProperties": False
            },
            "work_experience": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "company": {"type": "string"},
                        "title": {"type": "string"},
                        "start_date": {"type": "string"},
                        "end_date": {"type": "string"},
                        "description": {"type": "string"}
                    },
                    "required": ["company", "title"],
                    "additionalProperties": False
                }
            },
            "education": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "institution": {"type": "string"},
                        "degree": {"type": "string"},
                        "field": {"type": "string"},
                        "graduation_year": {"type": "string"}
                    },
                    "required": ["institution", "degree"],
                    "additionalProperties": False
                }
            },
            "skills": {
                "type": "array",
                "items": {"type": "string"}
            }
        },
        "required": ["personal_info", "work_experience", "education", "skills"],
        "additionalProperties": False
    }

    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {"role": "user", "content": f"Parse this resume:\n{resume_text}"}
        ],
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "resume_parser",
                "strict": True,
                "schema": schema
            }
        }
    )

    return json.loads(response.choices[0].message.content)
```

---

## Best Practices

### 1. Always Set `additionalProperties: false`

```python
# Good
{
    "type": "object",
    "properties": {...},
    "required": [...],
    "additionalProperties": False  # Prevents unexpected fields
}

# Bad - may include extra fields
{
    "type": "object",
    "properties": {...},
    "required": [...]
}
```

### 2. Use Enums for Constrained Values

```python
{
    "status": {
        "type": "string",
        "enum": ["draft", "published", "archived"]  # Only these values allowed
    }
}
```

### 3. Provide Clear Descriptions

```python
{
    "type": "object",
    "properties": {
        "priority": {
            "type": "string",
            "description": "Priority level: low (routine), medium (important), high (urgent), critical (emergency)",
            "enum": ["low", "medium", "high", "critical"]
        }
    }
}
```

### 4. Handle Missing Data Gracefully

```python
# Make optional fields truly optional
{
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "middle_name": {"type": "string"},  # Optional, may be missing
        "age": {"type": "integer"}
    },
    "required": ["name"]  # Only require what you need
}
```

### 5. Test Schema Thoroughly

```python
def test_schema(schema, test_inputs):
    """Test schema with various inputs."""
    for test_input in test_inputs:
        response = client.chat.completions.create(
            model="gpt-5",
            messages=[{"role": "user", "content": test_input}],
            response_format={
                "type": "json_schema",
                "json_schema": {
                    "name": "test",
                    "strict": True,
                    "schema": schema
                }
            }
        )
        result = json.loads(response.choices[0].message.content)
        print(f"Input: {test_input}")
        print(f"Output: {result}\n")
```

---

## Error Handling

```python
from openai import OpenAI, APIError

try:
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[...],
        response_format={
            "type": "json_schema",
            "json_schema": {...}
        }
    )
except APIError as e:
    if "invalid_schema" in str(e):
        print("Schema validation failed. Check your JSON Schema.")
    elif "unsupported_property" in str(e):
        print("Schema uses unsupported JSON Schema features.")
    else:
        print(f"API error: {e}")
```

---

## Performance Considerations

### Token Usage

Structured outputs may use slightly more tokens due to schema enforcement:
- **Overhead**: +10-50 tokens typically
- **Trade-off**: Guaranteed correctness vs. small cost increase

### Latency

Minimal impact on latency (~50-100ms additional processing)

---

## Migration from JSON Mode

**Before (JSON Mode)**:
```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "system", "content": "Return JSON with fields: name, email"}
    ],
    response_format={"type": "json_object"}
)
```

**After (Structured Outputs)**:
```python
response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Extract name and email"}
    ],
    response_format={
        "type": "json_schema",
        "json_schema": {
            "name": "extraction",
            "strict": True,
            "schema": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "email": {"type": "string"}
                },
                "required": ["name", "email"],
                "additionalProperties": False
            }
        }
    }
)
```

---

## Additional Resources

- **Structured Outputs Guide**: https://platform.openai.com/docs/guides/structured-outputs
- **JSON Schema Spec**: https://json-schema.org/
- **Cookbook Examples**: https://cookbook.openai.com/examples/structured_outputs

---

**Next**: [Function Calling →](./function-calling.md)
