# OpenAI Platform - Images and Vision

**Source:** https://platform.openai.com/docs/guides/vision
**Fetched:** 2025-10-11

## Overview

OpenAI's vision-enabled models like GPT-4o, GPT-4 Turbo, and GPT-5 can analyze and understand images, enabling applications from document analysis to visual question answering.

---

## Supported Models

| Model | Vision Support | Max Images | Detail Modes |
|-------|---------------|------------|--------------|
| gpt-5 | ✅ | 10 per request | low, high, auto |
| gpt-4o | ✅ | 10 per request | low, high, auto |
| gpt-4-turbo | ✅ | 10 per request | low, high, auto |
| gpt-4.1 | ✅ | 10 per request | low, high, auto |
| gpt-4o-mini | ✅ | 10 per request | low, high, auto |
| gpt-4 | ❌ | - | - |
| gpt-3.5-turbo | ❌ | - | - |

---

## Quick Start

### Python Example

```python
from openai import OpenAI

client = OpenAI()

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "What's in this image?"},
                {
                    "type": "image_url",
                    "image_url": {
                        "url": "https://example.com/image.jpg"
                    }
                }
            ]
        }
    ]
)

print(response.choices[0].message.content)
```

### TypeScript Example

```typescript
import OpenAI from 'openai';

const client = new OpenAI();

const response = await client.chat.completions.create({
  model: 'gpt-4o',
  messages: [
    {
      role: 'user',
      content: [
        { type: 'text', text: "What's in this image?" },
        {
          type: 'image_url',
          image_url: {
            url: 'https://example.com/image.jpg',
          },
        },
      ],
    },
  ],
});

console.log(response.choices[0].message.content);
```

---

## Image Input Methods

### 1. Public URL

```python
{
    "type": "image_url",
    "image_url": {
        "url": "https://example.com/image.jpg"
    }
}
```

### 2. Base64 Encoded

```python
import base64

def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

image_data = encode_image("path/to/image.jpg")

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Describe this image"},
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/jpeg;base64,{image_data}"
                    }
                }
            ]
        }
    ]
)
```

**Format**: `data:image/jpeg;base64,{base64_string}`

**Supported formats**: JPEG, PNG, GIF, WebP

**Recommended max size**: 20MB

---

## Detail Levels

Control the fidelity of image analysis:

### low

Fast, low-cost analysis at 512×512 resolution.

```python
{
    "type": "image_url",
    "image_url": {
        "url": "https://example.com/image.jpg",
        "detail": "low"
    }
}
```

**Use for**:
- Simple classification
- General scene understanding
- Low-resolution images

**Cost**: ~85 tokens per image

### high

Detailed analysis at full resolution (up to 2048×2048).

```python
{
    "type": "image_url",
    "image_url": {
        "url": "https://example.com/image.jpg",
        "detail": "high"
    }
}
```

**Use for**:
- Text extraction (OCR)
- Detailed object detection
- Fine-grained analysis

**Cost**: ~85 tokens + (number of 512px tiles × 170 tokens)

### auto (default)

Model automatically chooses based on image size.

```python
{
    "type": "image_url",
    "image_url": {
        "url": "https://example.com/image.jpg",
        "detail": "auto"
    }
}
```

---

## Multiple Images

Analyze multiple images in a single request (max 10):

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Compare these two images. What's different?"},
                {
                    "type": "image_url",
                    "image_url": {"url": "https://example.com/image1.jpg"}
                },
                {
                    "type": "image_url",
                    "image_url": {"url": "https://example.com/image2.jpg"}
                }
            ]
        }
    ]
)
```

---

## Common Use Cases

### 1. Image Description

```python
def describe_image(image_url):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": "Describe this image in detail."},
                    {"type": "image_url", "image_url": {"url": image_url}}
                ]
            }
        ]
    )
    return response.choices[0].message.content
```

### 2. OCR (Text Extraction)

```python
def extract_text(image_url):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": "Extract all text from this image."},
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": image_url,
                            "detail": "high"  # Use high detail for OCR
                        }
                    }
                ]
            }
        ]
    )
    return response.choices[0].message.content
```

### 3. Object Detection

```python
def detect_objects(image_url):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": "List all objects visible in this image with their approximate locations."},
                    {"type": "image_url", "image_url": {"url": image_url, "detail": "high"}}
                ]
            }
        ]
    )
    return response.choices[0].message.content
```

### 4. Image Classification

```python
def classify_image(image_url, categories):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": f"Classify this image into one of these categories: {', '.join(categories)}"
                    },
                    {"type": "image_url", "image_url": {"url": image_url, "detail": "low"}}
                ]
            }
        ],
        temperature=0.0  # Deterministic for classification
    )
    return response.choices[0].message.content
```

### 5. Visual Question Answering

```python
def answer_about_image(image_url, question):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": question},
                    {"type": "image_url", "image_url": {"url": image_url}}
                ]
            }
        ]
    )
    return response.choices[0].message.content

# Usage
answer = answer_about_image(
    "https://example.com/street.jpg",
    "How many people are in this image?"
)
```

### 6. Document Analysis

```python
def analyze_document(image_url):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Analyze this document. Extract key information in JSON format."
                    },
                    {"type": "image_url", "image_url": {"url": image_url, "detail": "high"}}
                ]
            }
        ],
        temperature=0.0
    )
    return response.choices[0].message.content
```

### 7. Image Comparison

```python
def compare_images(url1, url2):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": "Compare these two images. List similarities and differences."},
                    {"type": "image_url", "image_url": {"url": url1}},
                    {"type": "image_url", "image_url": {"url": url2}}
                ]
            }
        ]
    )
    return response.choices[0].message.content
```

---

## Cost Calculation

### Low Detail

**Fixed cost**: ~85 tokens per image

### High Detail

**Formula**: 85 base tokens + (number of 512×512 tiles × 170 tokens)

**Examples**:
- 1024×1024 image = 4 tiles = 85 + (4 × 170) = **765 tokens**
- 2048×2048 image = 16 tiles = 85 + (16 × 170) = **2,805 tokens**
- 512×512 image = 1 tile = 85 + (1 × 170) = **255 tokens**

**Tile calculation**:
1. Image is scaled to fit within 2048×2048
2. Image is divided into 512×512 tiles
3. Partial tiles count as full tiles

---

## Limitations

### What Vision Models Can't Do

❌ **Precise pixel coordinates**: Can describe locations, but not exact x,y coordinates

❌ **Count many small objects**: Struggles with >20 similar objects

❌ **3D depth perception**: No depth information

❌ **Medical diagnosis**: Not trained for medical use

❌ **Read rotated or distorted text**: Works best with clear, upright text

❌ **Process video**: Must extract frames first

### Best Practices

✅ **Use high detail for text**: OCR requires high-resolution processing

✅ **Crop images**: Focus on relevant areas to reduce costs

✅ **Use clear images**: Higher quality = better results

✅ **Be specific in prompts**: "Count the red cars" vs "Analyze this"

✅ **Use low detail for simple tasks**: Classification doesn't need high-res

---

## Advanced Techniques

### Structured Output with Vision

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Extract product information as JSON: {name, price, brand, color}"
                },
                {"type": "image_url", "image_url": {"url": image_url, "detail": "high"}}
            ]
        }
    ],
    response_format={"type": "json_object"}
)
```

### Multi-Turn Vision Conversations

```python
messages = [
    {
        "role": "user",
        "content": [
            {"type": "text", "text": "What's in this image?"},
            {"type": "image_url", "image_url": {"url": image_url}}
        ]
    }
]

response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages
)

messages.append({"role": "assistant", "content": response.choices[0].message.content})

# Follow-up question (image context retained)
messages.append({
    "role": "user",
    "content": "What color is the car?"
})

response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages
)
```

### Vision with Function Calling

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "identify_product",
            "description": "Identify a product from an image",
            "parameters": {
                "type": "object",
                "properties": {
                    "product_name": {"type": "string"},
                    "category": {"type": "string"},
                    "price_range": {"type": "string"}
                },
                "required": ["product_name", "category"]
            }
        }
    }
]

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Identify this product"},
                {"type": "image_url", "image_url": {"url": image_url}}
            ]
        }
    ],
    tools=tools,
    tool_choice="auto"
)
```

---

## Error Handling

```python
from openai import OpenAI, APIError

client = OpenAI()

try:
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[...]
    )
except APIError as e:
    if "image_parse_error" in str(e):
        print("Failed to parse image. Check format and size.")
    elif "invalid_image_url" in str(e):
        print("Invalid image URL. Check URL accessibility.")
    else:
        print(f"API error: {e}")
```

---

## Performance Tips

### 1. Optimize Image Size

```python
from PIL import Image
import io
import base64

def optimize_image(image_path, max_size=(2048, 2048)):
    """Resize image to optimal size."""
    img = Image.open(image_path)
    img.thumbnail(max_size, Image.Resampling.LANCZOS)

    buffer = io.BytesIO()
    img.save(buffer, format="JPEG", quality=85)
    return base64.b64encode(buffer.getvalue()).decode()
```

### 2. Batch Processing

```python
async def process_images_parallel(image_urls):
    """Process multiple images in parallel."""
    from openai import AsyncOpenAI
    client = AsyncOpenAI()

    tasks = []
    for url in image_urls:
        task = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": "Describe this image"},
                        {"type": "image_url", "image_url": {"url": url, "detail": "low"}}
                    ]
                }
            ]
        )
        tasks.append(task)

    return await asyncio.gather(*tasks)
```

### 3. Caching for Repeated Images

```python
import hashlib
import json

cache = {}

def analyze_image_cached(image_url, prompt):
    """Cache image analysis results."""
    cache_key = hashlib.md5(f"{image_url}{prompt}".encode()).hexdigest()

    if cache_key in cache:
        return cache[cache_key]

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {"type": "image_url", "image_url": {"url": image_url}}
                ]
            }
        ]
    )

    result = response.choices[0].message.content
    cache[cache_key] = result
    return result
```

---

## Additional Resources

- **Vision Guide**: https://platform.openai.com/docs/guides/vision
- **API Reference**: https://platform.openai.com/docs/api-reference/chat
- **Vision Fine-Tuning**: https://platform.openai.com/docs/guides/fine-tuning/vision
- **Cookbook Examples**: https://cookbook.openai.com/examples/gpt_with_vision

---

**Next**: [Audio and Speech →](./audio-and-speech.md)
