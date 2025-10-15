# Claude API - Vision Guide

**Sources:**
- https://docs.claude.com/en/docs/build-with-claude/vision
- https://github.com/anthropics/anthropic-cookbook

**Fetched:** 2025-10-11

## Overview

Claude 3 and 4 model families support vision capabilities, allowing Claude to understand and analyze images. This enables applications like:

- Image description and analysis
- Document and chart interpretation  
- Visual Q&A
- OCR and text extraction
- Screenshot analysis
- Product image analysis

## Supported Models

| Model | Vision Support |
|-------|----------------|
| Claude Sonnet 4.5 | ✅ Yes |
| Claude Opus 4.1 | ✅ Yes |
| Claude Haiku 3.5 | ✅ Yes |
| All Claude 3/4 models | ✅ Yes |

## Image Requirements

### Supported Formats
- **JPEG** (.jpg, .jpeg)
- **PNG** (.png)
- **GIF** (.gif)
- **WebP** (.webp)

### Size Limits
- **Maximum dimensions:** 8000 x 8000 pixels
- **Recommended maximum:** 1568 pixels on longest edge
- **Optimal size:** ~1.15 megapixels
- **Minimum recommended:** 200 pixels (smaller degrades performance)

### Upload Limits
- **API:** Up to 100 images per request
- **claude.ai:** Up to 20 images
- **Request size:** 32 MB maximum

## Image Formats

### 1. Base64 Encoding

**Python:**
```python
import anthropic
import base64

client = anthropic.Anthropic()

# Read and encode image
with open("image.jpg", "rb") as image_file:
    image_data = base64.standard_b64encode(image_file.read()).decode("utf-8")

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "What's in this image?"
                },
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/jpeg",
                        "data": image_data,
                    },
                },
            ],
        }
    ],
)

print(message.content[0].text)
```

**TypeScript:**
```typescript
import Anthropic from '@anthropic-ai/sdk';
import * as fs from 'fs';

const client = new Anthropic();

const imageBuffer = fs.readFileSync('image.jpg');
const base64Image = imageBuffer.toString('base64');

const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{
    role: 'user',
    content: [
      { type: 'text', text: "What's in this image?" },
      {
        type: 'image',
        source: {
          type: 'base64',
          media_type: 'image/jpeg',
          data: base64Image,
        },
      },
    ],
  }],
});

console.log(message.content[0].text);
```

### 2. Image URL

**Python:**
```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Describe this image"},
                {
                    "type": "image",
                    "source": {
                        "type": "url",
                        "url": "https://example.com/image.jpg",
                    },
                },
            ],
        }
    ],
)
```

**TypeScript:**
```typescript
const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{
    role: 'user',
    content: [
      { type: 'text', text: 'Describe this image' },
      {
        type: 'image',
        source: {
          type: 'url',
          url: 'https://example.com/image.jpg',
        },
      },
    ],
  }],
});
```

## Multiple Images

**Python:**
```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Compare these images"},
                {
                    "type": "image",
                    "source": {"type": "url", "url": "https://example.com/image1.jpg"},
                },
                {
                    "type": "image",
                    "source": {"type": "url", "url": "https://example.com/image2.jpg"},
                },
                {
                    "type": "image",
                    "source": {"type": "url", "url": "https://example.com/image3.jpg"},
                },
            ],
        }
    ],
)
```

## Common Use Cases

### 1. Image Description

```python
def describe_image(image_path):
    with open(image_path, "rb") as img:
        image_data = base64.standard_b64encode(img.read()).decode()

    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": "Provide a detailed description of this image"},
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
```

### 2. OCR / Text Extraction

```python
def extract_text(image_path):
    with open(image_path, "rb") as img:
        image_data = base64.standard_b64encode(img.read()).decode()

    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": "Extract all text from this image"},
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
```

### 3. Document Analysis

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
                    "text": "Analyze this chart. Describe the data, trends, and key insights."
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
```

### 4. Screenshot Analysis

```python
def analyze_screenshot(screenshot_path):
    with open(screenshot_path, "rb") as img:
        image_data = base64.standard_b64encode(img.read()).decode()

    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=2048,
        messages=[{
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Analyze this screenshot. Describe the UI, identify any issues, and suggest improvements."
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
```

## Image Preprocessing

### Resize Large Images

```python
from PIL import Image
import io
import base64

def resize_image(image_path, max_size=1568):
    img = Image.open(image_path)

    # Calculate new size
    ratio = max_size / max(img.size)
    if ratio < 1:
        new_size = tuple([int(x * ratio) for x in img.size])
        img = img.resize(new_size, Image.Resampling.LANCZOS)

    # Convert to base64
    buffer = io.BytesIO()
    img.save(buffer, format=img.format or 'JPEG')
    image_data = base64.standard_b64encode(buffer.getvalue()).decode()

    return image_data
```

### Convert Format

```python
def convert_to_jpeg(image_path):
    img = Image.open(image_path)

    # Convert to RGB if necessary
    if img.mode in ('RGBA', 'P'):
        img = img.convert('RGB')

    buffer = io.BytesIO()
    img.save(buffer, format='JPEG', quality=85)
    image_data = base64.standard_b64encode(buffer.getvalue()).decode()

    return image_data
```

## Pricing

Images are priced based on their size in tokens:

```
tokens = (width_px × height_px) / 750
```

### Examples (Claude Sonnet 4.5 @ $3/MTok input):

| Image Size | Tokens | Cost |
|------------|--------|------|
| 200x200 px | ~53 | $0.00016 |
| 400x400 px | ~213 | $0.00064 |
| 1000x1000 px | ~1,333 | $0.004 |
| 1568x1568 px | ~3,277 | $0.0098 |

## Limitations

### What Claude CAN Do:
✅ Describe images in detail  
✅ Extract text (OCR)  
✅ Analyze charts and graphs  
✅ Identify objects and scenes  
✅ Answer questions about images  
✅ Compare multiple images  

### What Claude CANNOT Do:
❌ Identify specific people by face  
❌ Precise spatial reasoning (exact distances)  
❌ Exact object counting  
❌ Generate or edit images  
❌ Medical diagnosis from images  
❌ Read extremely small text (<12pt at normal resolution)  

## Best Practices

### 1. Image Placement

```python
# Good - Image before question
content = [
    {"type": "image", "source": {"type": "url", "url": "..."}},
    {"type": "text", "text": "What's in this image?"}
]

# Less optimal - Question before image
content = [
    {"type": "text", "text": "What's in this image?"},
    {"type": "image", "source": {"type": "url", "url": "..."}}
]
```

### 2. Clear Images

- Use high resolution (but not over 1568px)
- Ensure text is legible (12pt+)
- Avoid extreme compression
- Good lighting and contrast

### 3. Specific Questions

```python
# Vague
"Tell me about this image"

# Specific
"Identify the main objects in this image and describe their positions"
```

### 4. Batch Processing

```python
import concurrent.futures

def process_image(image_path):
    # ... image processing ...
    return result

image_paths = ["img1.jpg", "img2.jpg", "img3.jpg"]

with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
    results = list(executor.map(process_image, image_paths))
```

## Complete Example

```python
import anthropic
import base64
from pathlib import Path

class ImageAnalyzer:
    def __init__(self):
        self.client = anthropic.Anthropic()

    def analyze(self, image_path, question):
        """Analyze an image with a specific question"""
        with open(image_path, "rb") as img:
            image_data = base64.standard_b64encode(img.read()).decode()

        # Detect media type
        suffix = Path(image_path).suffix.lower()
        media_types = {
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg',
            '.png': 'image/png',
            '.gif': 'image/gif',
            '.webp': 'image/webp'
        }
        media_type = media_types.get(suffix, 'image/jpeg')

        message = self.client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            messages=[{
                "role": "user",
                "content": [
                    {"type": "text", "text": question},
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": media_type,
                            "data": image_data
                        }
                    }
                ]
            }]
        )

        return {
            "answer": message.content[0].text,
            "tokens_used": message.usage.input_tokens + message.usage.output_tokens,
            "cost_estimate": (message.usage.input_tokens / 1_000_000) * 3 +
                           (message.usage.output_tokens / 1_000_000) * 15
        }

# Usage
analyzer = ImageAnalyzer()
result = analyzer.analyze("chart.png", "What are the key trends in this chart?")
print(result["answer"])
print(f"Cost: ${result['cost_estimate']:.4f}")
```

## Related Documentation

- [Messages API](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)  
- [TypeScript SDK](./05-typescript-sdk.md)
- [Examples](./11-examples.md)
