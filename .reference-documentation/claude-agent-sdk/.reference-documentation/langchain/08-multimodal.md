# LangChain - Multimodal Models

**Sources:**
- https://python.langchain.com/docs/concepts/multimodality/
- https://python.langchain.com/docs/how_to/multimodal_inputs/
- https://js.langchain.com/docs/how_to/multimodal_inputs/

**Fetched:** 2025-10-11

## What is Multimodality?

Multimodal models can process multiple types of input:
- **Text** - Standard text prompts
- **Images** - Photos, screenshots, diagrams
- **Audio** - Speech, music, sounds (limited support)
- **Video** - Video frames (some models)

## Supported Models

| Provider | Model | Vision | Audio | Video |
|----------|-------|--------|-------|-------|
| OpenAI | GPT-4 Vision | ✅ | ❌ | ❌ |
| OpenAI | GPT-4o | ✅ | ✅ | ❌ |
| Anthropic | Claude 3.5 Sonnet | ✅ | ❌ | ❌ |
| Anthropic | Claude 3 Opus | ✅ | ❌ | ❌ |
| Google | Gemini Pro Vision | ✅ | ✅ | ✅ |
| Google | Gemini 1.5 Pro | ✅ | ✅ | ✅ |

## Vision - Image Inputs

### Basic Image Input

**Python - URL:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage

llm = ChatOpenAI(model="gpt-4o")

message = HumanMessage(
    content=[
        {"type": "text", "text": "What's in this image?"},
        {
            "type": "image_url",
            "image_url": {
                "url": "https://example.com/image.jpg"
            }
        }
    ]
)

response = llm.invoke([message])
print(response.content)
```

**Python - Base64:**
```python
import base64
from pathlib import Path

# Read and encode image
image_path = Path("image.jpg")
image_data = base64.b64encode(image_path.read_bytes()).decode()

message = HumanMessage(
    content=[
        {"type": "text", "text": "What's in this image?"},
        {
            "type": "image_url",
            "image_url": {
                "url": f"data:image/jpeg;base64,{image_data}"
            }
        }
    ]
)

response = llm.invoke([message])
```

**TypeScript:**
```typescript
import { ChatOpenAI } from "@langchain/openai";
import { HumanMessage } from "@langchain/core/messages";
import * as fs from "fs";

const llm = new ChatOpenAI({ model: "gpt-4o" });

// From URL
const message1 = new HumanMessage({
  content: [
    { type: "text", text: "What's in this image?" },
    {
      type: "image_url",
      image_url: { url: "https://example.com/image.jpg" }
    }
  ]
});

// From file
const imageData = fs.readFileSync("image.jpg").toString("base64");

const message2 = new HumanMessage({
  content: [
    { type: "text", text: "What's in this image?" },
    {
      type: "image_url",
      image_url: { url: `data:image/jpeg;base64,${imageData}` }
    }
  ]
});

const response = await llm.invoke([message1]);
console.log(response.content);
```

### Multiple Images

**Python:**
```python
message = HumanMessage(
    content=[
        {"type": "text", "text": "Compare these two images"},
        {
            "type": "image_url",
            "image_url": {"url": "https://example.com/image1.jpg"}
        },
        {
            "type": "image_url",
            "image_url": {"url": "https://example.com/image2.jpg"}
        }
    ]
)

response = llm.invoke([message])
```

### Image Detail Level

Control image processing detail:

**Python:**
```python
message = HumanMessage(
    content=[
        {"type": "text", "text": "Describe this image"},
        {
            "type": "image_url",
            "image_url": {
                "url": "https://example.com/image.jpg",
                "detail": "high"  # "low", "auto", or "high"
            }
        }
    ]
)

response = llm.invoke([message])
```

- **low:** Faster, cheaper, less detail
- **auto:** Model chooses (default)
- **high:** Slower, more expensive, more detail

## Provider-Specific Examples

### Claude 3.5 Sonnet (Anthropic)

**Python:**
```python
from langchain_anthropic import ChatAnthropic
from langchain_core.messages import HumanMessage
import base64

llm = ChatAnthropic(model="claude-3-5-sonnet-20241022")

# Load image
with open("image.jpg", "rb") as f:
    image_data = base64.b64encode(f.read()).decode()

message = HumanMessage(
    content=[
        {"type": "text", "text": "What's in this image?"},
        {
            "type": "image_url",
            "image_url": {
                "url": f"data:image/jpeg;base64,{image_data}"
            }
        }
    ]
)

response = llm.invoke([message])
print(response.content)
```

### Gemini Pro Vision (Google)

**Python:**
```python
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage

llm = ChatGoogleGenerativeAI(model="gemini-pro-vision")

message = HumanMessage(
    content=[
        {"type": "text", "text": "Describe this image"},
        {
            "type": "image_url",
            "image_url": {"url": "https://example.com/image.jpg"}
        }
    ]
)

response = llm.invoke([message])
```

## Common Use Cases

### 1. Image Description

```python
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage

llm = ChatOpenAI(model="gpt-4o")

def describe_image(image_url: str) -> str:
    message = HumanMessage(
        content=[
            {"type": "text", "text": "Provide a detailed description of this image"},
            {"type": "image_url", "image_url": {"url": image_url}}
        ]
    )
    response = llm.invoke([message])
    return response.content

description = describe_image("https://example.com/photo.jpg")
print(description)
```

### 2. OCR - Text Extraction

```python
def extract_text(image_url: str) -> str:
    message = HumanMessage(
        content=[
            {"type": "text", "text": "Extract all text from this image"},
            {"type": "image_url", "image_url": {"url": image_url}}
        ]
    )
    response = llm.invoke([message])
    return response.content

text = extract_text("https://example.com/document.jpg")
```

### 3. Visual Question Answering

```python
def answer_about_image(image_url: str, question: str) -> str:
    message = HumanMessage(
        content=[
            {"type": "text", "text": question},
            {"type": "image_url", "image_url": {"url": image_url}}
        ]
    )
    response = llm.invoke([message])
    return response.content

answer = answer_about_image(
    "https://example.com/chart.jpg",
    "What is the trend in this chart?"
)
```

### 4. Image Classification

```python
def classify_image(image_url: str, categories: list) -> str:
    categories_str = ", ".join(categories)
    message = HumanMessage(
        content=[
            {
                "type": "text",
                "text": f"Classify this image into one of: {categories_str}"
            },
            {"type": "image_url", "image_url": {"url": image_url}}
        ]
    )
    response = llm.invoke([message])
    return response.content

category = classify_image(
    "https://example.com/animal.jpg",
    ["dog", "cat", "bird", "other"]
)
```

### 5. Screenshot Analysis

```python
def analyze_screenshot(screenshot_path: str) -> dict:
    with open(screenshot_path, "rb") as f:
        image_data = base64.b64encode(f.read()).decode()

    message = HumanMessage(
        content=[
            {
                "type": "text",
                "text": "Analyze this UI screenshot. Describe the layout, components, and any issues."
            },
            {
                "type": "image_url",
                "image_url": {"url": f"data:image/png;base64,{image_data}"}
            }
        ]
    )

    response = llm.invoke([message])
    return response.content
```

### 6. Chart/Graph Analysis

```python
def analyze_chart(chart_url: str) -> str:
    message = HumanMessage(
        content=[
            {
                "type": "text",
                "text": "Analyze this chart. Describe the data, trends, and key insights."
            },
            {"type": "image_url", "image_url": {"url": chart_url}}
        ]
    )
    response = llm.invoke([message])
    return response.content
```

## Multimodal RAG

Combine vision with retrieval:

**Python:**
```python
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_community.vectorstores import Chroma
from langchain_core.documents import Document
from langchain_core.messages import HumanMessage

# Store image descriptions in vector store
documents = [
    Document(
        page_content="Image of a cat sitting on a couch",
        metadata={"image_url": "https://example.com/cat.jpg"}
    ),
    Document(
        page_content="Image of a dog playing in a park",
        metadata={"image_url": "https://example.com/dog.jpg"}
    )
]

vectorstore = Chroma.from_documents(
    documents,
    OpenAIEmbeddings()
)

# Retrieve relevant images
query = "Show me pets relaxing"
docs = vectorstore.similarity_search(query, k=2)

# Analyze with vision model
llm = ChatOpenAI(model="gpt-4o")

for doc in docs:
    message = HumanMessage(
        content=[
            {"type": "text", "text": "Describe this image in detail"},
            {
                "type": "image_url",
                "image_url": {"url": doc.metadata["image_url"]}
            }
        ]
    )
    response = llm.invoke([message])
    print(response.content)
```

## Audio Processing

### GPT-4o Audio

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage
import base64

llm = ChatOpenAI(model="gpt-4o-audio-preview")

# Load audio file
with open("audio.mp3", "rb") as f:
    audio_data = base64.b64encode(f.read()).decode()

message = HumanMessage(
    content=[
        {"type": "text", "text": "Transcribe this audio"},
        {
            "type": "audio_url",
            "audio_url": {
                "url": f"data:audio/mp3;base64,{audio_data}"
            }
        }
    ]
)

response = llm.invoke([message])
print(response.content)
```

### Gemini Audio

**Python:**
```python
from langchain_google_genai import ChatGoogleGenerativeAI

llm = ChatGoogleGenerativeAI(model="gemini-1.5-pro")

# Gemini can process audio directly
message = HumanMessage(
    content=[
        {"type": "text", "text": "What is being said in this audio?"},
        {
            "type": "audio_url",
            "audio_url": {"url": "https://example.com/audio.mp3"}
        }
    ]
)

response = llm.invoke([message])
```

## Error Handling

### Image Loading Errors

```python
import requests
from PIL import Image
import io

def validate_image(image_url: str) -> bool:
    try:
        response = requests.get(image_url, timeout=10)
        response.raise_for_status()

        # Verify it's a valid image
        img = Image.open(io.BytesIO(response.content))
        img.verify()

        return True
    except Exception as e:
        print(f"Invalid image: {e}")
        return False

# Use before sending to LLM
if validate_image(image_url):
    response = llm.invoke([message])
```

### Size Limits

```python
from PIL import Image
import io
import base64

def resize_image_if_needed(image_path: str, max_size_mb: float = 20) -> str:
    with open(image_path, "rb") as f:
        image_bytes = f.read()

    # Check size
    size_mb = len(image_bytes) / (1024 * 1024)

    if size_mb > max_size_mb:
        # Resize
        img = Image.open(io.BytesIO(image_bytes))
        img.thumbnail((1024, 1024))

        buffer = io.BytesIO()
        img.save(buffer, format="JPEG", quality=85)
        image_bytes = buffer.getvalue()

    return base64.b64encode(image_bytes).decode()
```

## Best Practices

### 1. Choose Appropriate Detail Level

```python
# For quick analysis: low detail
message = HumanMessage(
    content=[
        {"type": "text", "text": "Is this a cat or dog?"},
        {
            "type": "image_url",
            "image_url": {"url": image_url, "detail": "low"}
        }
    ]
)

# For detailed analysis: high detail
message = HumanMessage(
    content=[
        {"type": "text", "text": "Analyze all elements in this UI"},
        {
            "type": "image_url",
            "image_url": {"url": image_url, "detail": "high"}
        }
    ]
)
```

### 2. Provide Clear Instructions

```python
# Good: Specific instructions
message = HumanMessage(
    content=[
        {
            "type": "text",
            "text": "List all visible objects in this image with their approximate locations"
        },
        {"type": "image_url", "image_url": {"url": image_url}}
    ]
)

# Avoid: Vague instructions
message = HumanMessage(
    content=[
        {"type": "text", "text": "Look at this"},
        {"type": "image_url", "image_url": {"url": image_url}}
    ]
)
```

### 3. Handle Multiple Images Efficiently

```python
# Process multiple images in one call when comparing
message = HumanMessage(
    content=[
        {"type": "text", "text": "Which image has more people?"},
        {"type": "image_url", "image_url": {"url": image1_url}},
        {"type": "image_url", "image_url": {"url": image2_url}}
    ]
)
```

### 4. Cache Image Descriptions

```python
from functools import lru_cache

@lru_cache(maxsize=100)
def get_image_description(image_url: str) -> str:
    message = HumanMessage(
        content=[
            {"type": "text", "text": "Describe this image"},
            {"type": "image_url", "image_url": {"url": image_url}}
        ]
    )
    response = llm.invoke([message])
    return response.content
```

## Cost Considerations

Vision API calls are more expensive than text-only:

| Model | Text (1K tokens) | Vision (low) | Vision (high) |
|-------|------------------|--------------|---------------|
| GPT-4o | $0.005 | ~$0.01 | ~$0.03 |
| Claude 3.5 | $0.003 | ~$0.01 | ~$0.02 |
| Gemini Pro | $0.001 | ~$0.002 | ~$0.005 |

**Optimization:**
- Use "low" detail for simple tasks
- Cache descriptions of frequently-used images
- Batch multiple questions about same image

## Related Documentation

- [Chat Models](./06-chat-models.md)
- [Messages](./12-messages.md)
- [RAG Basics](./21-rag-basics.md)
- [Document Loaders](./15-document-loaders.md)
