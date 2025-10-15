# Claude API - Examples and Use Cases

**Sources:**
- https://github.com/anthropics/anthropic-cookbook
- https://docs.claude.com/en/docs/build-with-claude

**Fetched:** 2025-10-11

## Overview

This guide provides practical examples and common use cases for building with Claude. All examples include both Python and TypeScript implementations.

## Quick Start Examples

### 1. Basic Chat

**Python:**
```python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Explain quantum computing in simple terms"}
    ]
)

print(message.content[0].text)
```

**TypeScript:**
```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [
    { role: 'user', content: 'Explain quantum computing in simple terms' }
  ],
});

console.log(message.content[0].text);
```

### 2. Conversational Agent

**Python:**
```python
class ChatBot:
    def __init__(self):
        self.client = anthropic.Anthropic()
        self.conversation_history = []

    def send_message(self, user_message):
        # Add user message
        self.conversation_history.append({
            "role": "user",
            "content": user_message
        })

        # Get response
        response = self.client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            messages=self.conversation_history
        )

        # Add assistant response
        assistant_message = response.content[0].text
        self.conversation_history.append({
            "role": "assistant",
            "content": assistant_message
        })

        return assistant_message

# Usage
bot = ChatBot()
print(bot.send_message("Hello! What's your name?"))
print(bot.send_message("Tell me a joke"))
print(bot.send_message("Explain the previous joke"))
```

**TypeScript:**
```typescript
class ChatBot {
  private client: Anthropic;
  private conversationHistory: Anthropic.MessageParam[] = [];

  constructor() {
    this.client = new Anthropic();
  }

  async sendMessage(userMessage: string): Promise<string> {
    this.conversationHistory.push({
      role: 'user',
      content: userMessage,
    });

    const response = await this.client.messages.create({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 2048,
      messages: this.conversationHistory,
    });

    const assistantMessage = response.content[0].text;
    this.conversationHistory.push({
      role: 'assistant',
      content: assistantMessage,
    });

    return assistantMessage;
  }
}

// Usage
const bot = new ChatBot();
console.log(await bot.sendMessage("Hello! What's your name?"));
console.log(await bot.sendMessage("Tell me a joke"));
```

## Text Processing

### 3. Text Summarization

**Python:**
```python
def summarize_text(text, length="medium"):
    length_prompts = {
        "short": "in 2-3 sentences",
        "medium": "in 1-2 paragraphs",
        "long": "in detail"
    }

    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": f"Summarize the following text {length_prompts[length]}:\n\n{text}"
        }]
    )

    return message.content[0].text

# Example
article = """
    [Long article text here...]
"""
summary = summarize_text(article, length="short")
print(summary)
```

### 4. Text Classification

**Python:**
```python
def classify_text(text, categories):
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=100,
        messages=[{
            "role": "user",
            "content": f"""Classify the following text into one of these categories: {', '.join(categories)}

Text: {text}

Respond with only the category name."""
        }]
    )

    return message.content[0].text.strip()

# Example
categories = ["Technology", "Sports", "Politics", "Entertainment"]
text = "The new iPhone features an improved camera system"
category = classify_text(text, categories)
print(f"Category: {category}")
```

### 5. Sentiment Analysis

**Python:**
```python
def analyze_sentiment(text):
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=200,
        messages=[{
            "role": "user",
            "content": f"""Analyze the sentiment of this text and respond in JSON format:

Text: {text}

Format:
{{
    "sentiment": "positive/negative/neutral",
    "confidence": 0-100,
    "explanation": "brief explanation"
}}"""
        }]
    )

    import json
    return json.loads(message.content[0].text)

# Example
text = "I absolutely love this product! Best purchase ever!"
result = analyze_sentiment(text)
print(f"Sentiment: {result['sentiment']} ({result['confidence']}%)")
```

## Data Extraction

### 6. Named Entity Recognition

**Python:**
```python
def extract_entities(text):
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": f"""Extract named entities from this text. Return JSON with these categories:
- people: list of person names
- organizations: list of organizations
- locations: list of places
- dates: list of dates

Text: {text}"""
        }]
    )

    import json
    return json.loads(message.content[0].text)

# Example
text = "Apple CEO Tim Cook announced new products in Cupertino on September 12th"
entities = extract_entities(text)
print(entities)
```

### 7. Structured Data Extraction

**Python:**
```python
def extract_product_info(description):
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": f"""Extract product information from this description in JSON format:

Description: {description}

Format:
{{
    "name": "product name",
    "price": "price",
    "features": ["feature1", "feature2"],
    "specs": {{"spec_name": "value"}},
    "brand": "brand name"
}}"""
        }]
    )

    import json
    return json.loads(message.content[0].text)

# Example
desc = "iPhone 15 Pro - $999. Features: A17 chip, titanium design, 48MP camera. 256GB storage."
product = extract_product_info(desc)
print(product)
```

## Vision / Image Analysis

### 8. Image Description

**Python:**
```python
import base64

def describe_image(image_path):
    with open(image_path, "rb") as img:
        image_data = base64.standard_b64encode(img.read()).decode()

    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": "Describe this image in detail"},
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/jpeg",
                        "data": image_data
                    }
                }
            ]
        }]
    )

    return message.content[0].text

# Example
description = describe_image("photo.jpg")
print(description)
```

### 9. OCR / Text Extraction

**Python:**
```python
def extract_text_from_image(image_path):
    with open(image_path, "rb") as img:
        image_data = base64.standard_b64encode(img.read()).decode()

    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": "Extract all text from this image. Maintain formatting and structure."},
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/png",
                        "data": image_data
                    }
                }
            ]
        }]
    )

    return message.content[0].text

# Example
text = extract_text_from_image("document.png")
print(text)
```

### 10. Chart Analysis

**Python:**
```python
def analyze_chart(image_path):
    with open(image_path, "rb") as img:
        image_data = base64.standard_b64encode(img.read()).decode()

    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        messages=[{
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Analyze this chart. Describe:\n1. Type of chart\n2. Key data points\n3. Trends and patterns\n4. Insights and conclusions"
                },
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/png",
                        "data": image_data
                    }
                }
            ]
        }]
    )

    return message.content[0].text

# Example
analysis = analyze_chart("sales_chart.png")
print(analysis)
```

## Tool Use / Function Calling

### 11. Calculator Agent

**Python:**
```python
import math
import json

tools = [{
    "name": "calculate",
    "description": "Perform mathematical calculations",
    "input_schema": {
        "type": "object",
        "properties": {
            "expression": {
                "type": "string",
                "description": "Mathematical expression to evaluate (e.g., '2 + 2', 'sqrt(16)')"
            }
        },
        "required": ["expression"]
    }
}]

def safe_eval(expression):
    """Safely evaluate math expressions"""
    allowed_names = {
        k: v for k, v in math.__dict__.items() if not k.startswith("__")
    }
    try:
        return eval(expression, {"__builtins__": {}}, allowed_names)
    except Exception as e:
        return f"Error: {str(e)}"

def calculator_agent(query):
    messages = [{"role": "user", "content": query}]

    while True:
        response = client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=1024,
            tools=tools,
            messages=messages
        )

        if response.stop_reason == "end_turn":
            return next(
                (block.text for block in response.content if hasattr(block, "text")),
                None
            )

        if response.stop_reason == "tool_use":
            messages.append({"role": "assistant", "content": response.content})

            tool_results = []
            for block in response.content:
                if block.type == "tool_use":
                    result = safe_eval(block.input["expression"])
                    tool_results.append({
                        "type": "tool_result",
                        "tool_use_id": block.id,
                        "content": str(result)
                    })

            messages.append({"role": "user", "content": tool_results})

# Example
result = calculator_agent("What's 15% of 250?")
print(result)
```

### 12. Database Query Agent

**Python:**
```python
import sqlite3

tools = [{
    "name": "query_database",
    "description": "Execute SQL queries against the customer database",
    "input_schema": {
        "type": "object",
        "properties": {
            "query": {"type": "string", "description": "SQL query to execute"}
        },
        "required": ["query"]
    }
}]

def execute_query(query):
    """Execute SQL query (read-only)"""
    if any(keyword in query.upper() for keyword in ["DROP", "DELETE", "UPDATE", "INSERT"]):
        return {"error": "Only SELECT queries allowed"}

    try:
        conn = sqlite3.connect("database.db")
        cursor = conn.cursor()
        cursor.execute(query)
        results = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]
        conn.close()

        return {
            "columns": columns,
            "rows": results,
            "count": len(results)
        }
    except Exception as e:
        return {"error": str(e)}

def database_agent(question):
    messages = [{"role": "user", "content": question}]

    while True:
        response = client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            tools=tools,
            messages=messages
        )

        if response.stop_reason == "end_turn":
            return next(
                (block.text for block in response.content if hasattr(block, "text")),
                None
            )

        if response.stop_reason == "tool_use":
            messages.append({"role": "assistant", "content": response.content})

            tool_results = []
            for block in response.content:
                if block.type == "tool_use":
                    result = execute_query(block.input["query"])
                    tool_results.append({
                        "type": "tool_result",
                        "tool_use_id": block.id,
                        "content": json.dumps(result)
                    })

            messages.append({"role": "user", "content": tool_results})

# Example
answer = database_agent("How many customers are from California?")
print(answer)
```

### 13. Web Search Agent

**Python:**
```python
def web_search_agent(query):
    """Agent with server-side web search tool"""
    response = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        tools=[{
            "type": "web_search_beta",
            "name": "web_search",
            "max_results": 5
        }],
        messages=[{"role": "user", "content": query}]
    )

    return response.content[0].text

# Example
answer = web_search_agent("What are the latest developments in quantum computing?")
print(answer)
```

## RAG (Retrieval Augmented Generation)

### 14. Document Q&A with Caching

**Python:**
```python
class DocumentQA:
    def __init__(self, document_path):
        self.client = anthropic.Anthropic()
        with open(document_path, 'r') as f:
            self.document = f.read()

    def query(self, question):
        message = self.client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            system=[
                {
                    "type": "text",
                    "text": "You answer questions based on the provided document. If the answer is not in the document, say so."
                },
                {
                    "type": "text",
                    "text": f"<document>\n{self.document}\n</document>",
                    "cache_control": {"type": "ephemeral"}
                }
            ],
            messages=[{"role": "user", "content": question}]
        )

        return message.content[0].text

# Example
qa = DocumentQA("company_handbook.txt")
answer1 = qa.query("What is the vacation policy?")
answer2 = qa.query("What are the working hours?")
print(answer1)
print(answer2)
```

### 15. Multi-Document Search

**Python:**
```python
def search_documents(query, documents):
    """Search across multiple documents"""
    # Create document context
    doc_context = "\n\n".join([
        f"<document id='{i}'>\n{doc}\n</document>"
        for i, doc in enumerate(documents)
    ])

    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        system=[
            {
                "type": "text",
                "text": "You search through multiple documents to answer questions. Cite document IDs in your answer."
            },
            {
                "type": "text",
                "text": doc_context,
                "cache_control": {"type": "ephemeral"}
            }
        ],
        messages=[{"role": "user", "content": query}]
    )

    return message.content[0].text

# Example
docs = [
    "Document 1 content...",
    "Document 2 content...",
    "Document 3 content..."
]
answer = search_documents("What are the key points?", docs)
print(answer)
```

## Code Generation

### 16. Code Generator

**Python:**
```python
def generate_code(description, language="python"):
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        system=f"You are an expert {language} programmer. Generate clean, efficient, well-documented code.",
        messages=[{
            "role": "user",
            "content": f"Write {language} code for: {description}"
        }]
    )

    return message.content[0].text

# Example
code = generate_code("A function to calculate Fibonacci numbers with memoization")
print(code)
```

### 17. Code Review

**Python:**
```python
def review_code(code, language="python"):
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        messages=[{
            "role": "user",
            "content": f"""Review this {language} code and provide:
1. Issues and bugs
2. Performance improvements
3. Best practices violations
4. Security concerns

Code:
```{language}
{code}
```"""
        }]
    )

    return message.content[0].text

# Example
code = """
def divide(a, b):
    return a / b
"""
review = review_code(code)
print(review)
```

### 18. Code Explanation

**Python:**
```python
def explain_code(code, language="python"):
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        messages=[{
            "role": "user",
            "content": f"""Explain what this {language} code does:

```{language}
{code}
```

Provide:
1. High-level overview
2. Step-by-step breakdown
3. Key concepts used
4. Time/space complexity (if applicable)"""
        }]
    )

    return message.content[0].text

# Example
code = """
def quicksort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quicksort(left) + middle + quicksort(right)
"""
explanation = explain_code(code)
print(explanation)
```

## Streaming Examples

### 19. Streaming Chat

**Python:**
```python
def streaming_chat(message):
    """Stream response in real-time"""
    with client.messages.stream(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        messages=[{"role": "user", "content": message}]
    ) as stream:
        for text in stream.text_stream:
            print(text, end="", flush=True)

        print("\n")
        final_message = stream.get_final_message()
        return final_message.usage

# Example
usage = streaming_chat("Write a short story about a robot")
print(f"Tokens used: {usage.output_tokens}")
```

**TypeScript:**
```typescript
async function streamingChat(message: string) {
  const stream = client.messages.stream({
    model: 'claude-sonnet-4-5-20250929',
    max_tokens: 2048,
    messages: [{ role: 'user', content: message }],
  });

  stream.on('text', (text) => {
    process.stdout.write(text);
  });

  const finalMessage = await stream.finalMessage();
  console.log('\nTokens used:', finalMessage.usage.output_tokens);
}

await streamingChat('Write a short story about a robot');
```

### 20. Streaming with Progress

**Python:**
```python
def streaming_with_progress(message):
    """Stream with progress tracking"""
    tokens_received = 0

    with client.messages.stream(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        messages=[{"role": "user", "content": message}]
    ) as stream:
        for event in stream:
            if event.type == "content_block_delta":
                if hasattr(event.delta, 'text'):
                    print(event.delta.text, end="", flush=True)
                    tokens_received += len(event.delta.text.split())

                    # Show progress every 10 tokens
                    if tokens_received % 10 == 0:
                        print(f"\n[{tokens_received} words]", end="", flush=True)

# Example
streaming_with_progress("Explain machine learning")
```

## Content Moderation

### 21. Content Filter

**Python:**
```python
def moderate_content(text):
    """Check if content is appropriate"""
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=200,
        messages=[{
            "role": "user",
            "content": f"""Analyze this text for inappropriate content. Return JSON:

Text: {text}

Format:
{{
    "is_appropriate": true/false,
    "issues": ["issue1", "issue2"],
    "severity": "low/medium/high",
    "explanation": "brief explanation"
}}"""
        }]
    )

    import json
    return json.loads(message.content[0].text)

# Example
text = "Some user-generated content..."
result = moderate_content(text)
if not result["is_appropriate"]:
    print(f"Content blocked: {result['explanation']}")
```

## Translation

### 22. Multilingual Translation

**Python:**
```python
def translate(text, target_language, source_language="auto"):
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        messages=[{
            "role": "user",
            "content": f"Translate this text to {target_language}:\n\n{text}"
        }]
    )

    return message.content[0].text

# Example
english_text = "Hello, how are you today?"
spanish = translate(english_text, "Spanish")
french = translate(english_text, "French")
japanese = translate(english_text, "Japanese")

print(f"Spanish: {spanish}")
print(f"French: {french}")
print(f"Japanese: {japanese}")
```

## Error Handling

### 23. Robust API Client

**Python:**
```python
import time
from anthropic import APIError, RateLimitError, APIConnectionError

class RobustClaudeClient:
    def __init__(self, max_retries=3):
        self.client = anthropic.Anthropic()
        self.max_retries = max_retries

    def create_message(self, **kwargs):
        """Create message with automatic retries"""
        for attempt in range(self.max_retries):
            try:
                return self.client.messages.create(**kwargs)

            except RateLimitError as e:
                if attempt < self.max_retries - 1:
                    wait_time = 2 ** attempt
                    print(f"Rate limited. Waiting {wait_time}s...")
                    time.sleep(wait_time)
                else:
                    raise

            except APIConnectionError as e:
                if attempt < self.max_retries - 1:
                    wait_time = 2 ** attempt
                    print(f"Connection error. Retrying in {wait_time}s...")
                    time.sleep(wait_time)
                else:
                    raise

            except APIError as e:
                print(f"API Error: {e}")
                raise

# Usage
client = RobustClaudeClient()
response = client.create_message(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}]
)
```

## Best Practices

### 24. Token Optimization

```python
def optimize_prompt(prompt, max_length=1000):
    """Optimize prompt length while preserving meaning"""
    if len(prompt) <= max_length:
        return prompt

    message = client.messages.create(
        model="claude-3-5-haiku-20241022",  # Use fast model
        max_tokens=max_length,
        messages=[{
            "role": "user",
            "content": f"Compress this text to under {max_length} characters while preserving key information:\n\n{prompt}"
        }]
    )

    return message.content[0].text
```

### 25. Cost Tracking

```python
class CostTracker:
    def __init__(self):
        self.total_input_tokens = 0
        self.total_output_tokens = 0
        self.pricing = {
            "claude-sonnet-4-5-20250929": {"input": 3.00, "output": 15.00},
            "claude-opus-4-1-20250805": {"input": 15.00, "output": 75.00},
            "claude-3-5-haiku-20241022": {"input": 0.80, "output": 4.00},
        }

    def track_request(self, response, model):
        self.total_input_tokens += response.usage.input_tokens
        self.total_output_tokens += response.usage.output_tokens

        prices = self.pricing[model]
        input_cost = (response.usage.input_tokens / 1_000_000) * prices["input"]
        output_cost = (response.usage.output_tokens / 1_000_000) * prices["output"]

        return {
            "request_cost": input_cost + output_cost,
            "total_cost": self.get_total_cost(model)
        }

    def get_total_cost(self, model):
        prices = self.pricing[model]
        input_cost = (self.total_input_tokens / 1_000_000) * prices["input"]
        output_cost = (self.total_output_tokens / 1_000_000) * prices["output"]
        return input_cost + output_cost

# Usage
tracker = CostTracker()
response = client.messages.create(...)
costs = tracker.track_request(response, "claude-sonnet-4-5-20250929")
print(f"Request cost: ${costs['request_cost']:.4f}")
print(f"Total cost: ${costs['total_cost']:.4f}")
```

## Related Documentation

- [Getting Started](./02-getting-started.md)
- [Messages API](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)
- [TypeScript SDK](./05-typescript-sdk.md)
- [Streaming](./06-streaming.md)
- [Vision](./07-vision.md)
- [Tool Use](./08-tool-use.md)
- [Prompt Caching](./09-prompt-caching.md)
- [Models](./10-models.md)
