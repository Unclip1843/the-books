# OpenAI Platform - File Inputs

**Source:** https://platform.openai.com/docs/guides/pdf-files
**Fetched:** 2025-10-11

## Overview

OpenAI APIs support various file input types including PDFs, images, audio, and data files. This guide covers how to upload, process, and work with files across different OpenAI endpoints.

**Supported File Types:**
- 📄 PDFs (direct processing since March 2025)
- 🖼️ Images (JPG, PNG, GIF, WebP)
- 🎵 Audio (MP3, MP4, WAV, M4A, MPEG, WebM)
- 📊 Data files (JSONL, CSV for fine-tuning/batch)

**Use Cases:**
- Document analysis and extraction
- Image understanding and OCR
- Audio transcription and generation
- Batch processing with file I/O
- Fine-tuning with training data

---

## PDF Files (March 2025+)

### Direct PDF Processing

Since March 18, 2025, you can send PDF files directly to vision-capable models.

**Supported Models:**
- GPT-4o
- GPT-4o-mini
- O1 series

**Features:**
- ✅ Text extraction
- ✅ Image extraction from pages
- ✅ Diagrams and charts understanding
- ✅ Multi-page support (up to 100 pages)
- ✅ Structured output support

### Basic PDF Processing

```python
from openai import OpenAI

client = OpenAI()

# Method 1: Base64 encoding
import base64

with open("document.pdf", "rb") as pdf_file:
    pdf_data = base64.b64encode(pdf_file.read()).decode('utf-8')

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
        "role": "user",
        "content": [
            {"type": "text", "text": "Summarize this document"},
            {
                "type": "file",
                "file": {
                    "data": pdf_data,
                    "mime_type": "application/pdf"
                }
            }
        ]
    }]
)

print(response.choices[0].message.content)
```

```python
# Method 2: Upload via Files API
with open("document.pdf", "rb") as pdf_file:
    file = client.files.create(
        file=pdf_file,
        purpose="assistants"
    )

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
        "role": "user",
        "content": [
            {"type": "text", "text": "Analyze this document"},
            {"type": "file", "file_id": file.id}
        ]
    }]
)
```

### PDF Analysis Examples

**Extract Key Information:**

```python
def extract_invoice_data(pdf_path):
    """Extract structured data from invoice PDF."""
    with open(pdf_path, "rb") as f:
        pdf_data = base64.b64encode(f.read()).decode()

    response = client.beta.chat.completions.parse(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": "Extract invoice data"},
                {
                    "type": "file",
                    "file": {
                        "data": pdf_data,
                        "mime_type": "application/pdf"
                    }
                }
            ]
        }],
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "InvoiceData",
                "schema": {
                    "type": "object",
                    "properties": {
                        "invoice_number": {"type": "string"},
                        "date": {"type": "string"},
                        "total": {"type": "number"},
                        "items": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "properties": {
                                    "description": {"type": "string"},
                                    "quantity": {"type": "number"},
                                    "price": {"type": "number"}
                                }
                            }
                        }
                    }
                }
            }
        }
    )

    return response.choices[0].message.parsed
```

**Document Q&A:**

```python
def pdf_qa(pdf_path, question):
    """Ask questions about PDF content."""
    with open(pdf_path, "rb") as f:
        pdf_data = base64.b64encode(f.read()).decode()

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": question},
                {
                    "type": "file",
                    "file": {
                        "data": pdf_data,
                        "mime_type": "application/pdf"
                    }
                }
            ]
        }]
    )

    return response.choices[0].message.content

# Usage
answer = pdf_qa("contract.pdf", "What is the termination clause?")
```

### PDF Limitations

**Size Limits:**
- Maximum 100 pages per request
- Maximum 32MB total content per request
- Includes all files combined if multiple

**Token Usage:**
- Text: ~1 token per 4 characters
- Images: ~85-170 tokens per page (depends on detail level)
- A 10-page PDF with images can use 1,000-2,000 tokens

---

## Image Inputs

### Image Understanding with Vision

```python
# Method 1: Image URL
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
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
    }]
)

# Method 2: Base64 encoding
import base64

with open("image.jpg", "rb") as image_file:
    image_data = base64.b64encode(image_file.read()).decode('utf-8')

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
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
    }]
)
```

### Image Detail Levels

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
        "role": "user",
        "content": [
            {"type": "text", "text": "Analyze this chart"},
            {
                "type": "image_url",
                "image_url": {
                    "url": "https://example.com/chart.png",
                    "detail": "high"  # "low", "auto", or "high"
                }
            }
        ]
    }]
)
```

**Detail Levels:**
- **low**: 85 tokens, faster, less detailed
- **auto**: Automatically choose based on image size (default)
- **high**: Up to 170 tokens per 512x512 tile, more detailed

### Multiple Images

```python
def compare_images(image1_path, image2_path):
    """Compare two images."""
    with open(image1_path, "rb") as f1:
        img1 = base64.b64encode(f1.read()).decode()
    with open(image2_path, "rb") as f2:
        img2 = base64.b64encode(f2.read()).decode()

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": "Compare these two images"},
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{img1}"}
                },
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{img2}"}
                }
            ]
        }]
    )

    return response.choices[0].message.content
```

### Image Use Cases

**OCR (Optical Character Recognition):**

```python
def extract_text_from_image(image_path):
    """Extract text from image."""
    with open(image_path, "rb") as f:
        image_data = base64.b64encode(f.read()).decode()

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": "Extract all text from this image"},
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/jpeg;base64,{image_data}",
                        "detail": "high"
                    }
                }
            ]
        }]
    )

    return response.choices[0].message.content
```

**Chart Analysis:**

```python
def analyze_chart(chart_path):
    """Analyze data visualization."""
    with open(chart_path, "rb") as f:
        chart_data = base64.b64encode(f.read()).decode()

    response = client.beta.chat.completions.parse(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": "Extract data from this chart"},
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/png;base64,{chart_data}",
                        "detail": "high"
                    }
                }
            ]
        }],
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "ChartData",
                "schema": {
                    "type": "object",
                    "properties": {
                        "title": {"type": "string"},
                        "type": {"type": "string"},
                        "data_points": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "properties": {
                                    "label": {"type": "string"},
                                    "value": {"type": "number"}
                                }
                            }
                        }
                    }
                }
            }
        }
    )

    return response.choices[0].message.parsed
```

---

## Audio Files

### Speech-to-Text (Whisper)

```python
# Transcribe audio file
with open("audio.mp3", "rb") as audio_file:
    transcript = client.audio.transcriptions.create(
        model="whisper-1",
        file=audio_file,
        response_format="text"  # or "json", "srt", "vtt"
    )

print(transcript)
```

### Transcription with Timestamps

```python
# Get detailed transcription with timestamps
with open("audio.mp3", "rb") as audio_file:
    transcript = client.audio.transcriptions.create(
        model="whisper-1",
        file=audio_file,
        response_format="verbose_json",
        timestamp_granularities=["word"]
    )

# Access words with timestamps
for word in transcript.words:
    print(f"{word.word}: {word.start}s - {word.end}s")
```

### Translation

```python
# Translate audio to English
with open("spanish.mp3", "rb") as audio_file:
    translation = client.audio.translations.create(
        model="whisper-1",
        file=audio_file
    )

print(translation.text)
```

### Text-to-Speech

```python
# Generate speech from text
response = client.audio.speech.create(
    model="tts-1",  # or "tts-1-hd" for higher quality
    voice="alloy",  # alloy, echo, fable, onyx, nova, shimmer
    input="Hello! This is a test of text-to-speech."
)

# Save to file
response.stream_to_file("output.mp3")
```

**Supported Audio Formats:**
- MP3
- MP4
- MPEG
- MPGA
- M4A
- WAV
- WebM

**Limitations:**
- Maximum file size: 25 MB
- Maximum duration: Varies by model

---

## Files API

### Upload Files

```python
# Upload file for assistants
with open("data.csv", "rb") as file:
    uploaded_file = client.files.create(
        file=file,
        purpose="assistants"  # or "fine-tune", "batch"
    )

print(f"File ID: {uploaded_file.id}")
```

### List Files

```python
# List all uploaded files
files = client.files.list()

for file in files.data:
    print(f"{file.filename}: {file.id} ({file.bytes} bytes)")
```

### Retrieve File

```python
# Get file info
file = client.files.retrieve("file-abc123")
print(f"Filename: {file.filename}")
print(f"Purpose: {file.purpose}")
print(f"Size: {file.bytes} bytes")
```

### Download File Content

```python
# Download file content
content = client.files.content("file-abc123")

# Save to disk
with open("downloaded.txt", "wb") as f:
    f.write(content.read())
```

### Delete File

```python
# Delete file
client.files.delete("file-abc123")
```

---

## Batch Processing with Files

### Create Batch Input File

```python
import json

# Prepare batch requests
batch_requests = [
    {
        "custom_id": f"request-{i}",
        "method": "POST",
        "url": "/v1/chat/completions",
        "body": {
            "model": "gpt-4o",
            "messages": [{"role": "user", "content": f"Process item {i}"}]
        }
    }
    for i in range(100)
]

# Write to JSONL file
with open("batch_input.jsonl", "w") as f:
    for request in batch_requests:
        f.write(json.dumps(request) + "\n")

# Upload for batch processing
with open("batch_input.jsonl", "rb") as f:
    batch_file = client.files.create(file=f, purpose="batch")

# Create batch job
batch_job = client.batches.create(
    input_file_id=batch_file.id,
    endpoint="/v1/chat/completions",
    completion_window="24h"
)
```

### Process Batch Results

```python
# Download results
result_file_id = batch_job.output_file_id
content = client.files.content(result_file_id)

# Parse results
results = []
for line in content.text.split('\n'):
    if line.strip():
        result = json.loads(line)
        results.append(result)

# Process each result
for result in results:
    custom_id = result["custom_id"]
    response = result["response"]["body"]["choices"][0]["message"]["content"]
    print(f"{custom_id}: {response}")
```

---

## Fine-Tuning with Files

### Prepare Training Data

```python
# Create training data in JSONL format
training_data = [
    {
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "What is the capital of France?"},
            {"role": "assistant", "content": "The capital of France is Paris."}
        ]
    },
    # ... more examples
]

# Save to JSONL
with open("training.jsonl", "w") as f:
    for example in training_data:
        f.write(json.dumps(example) + "\n")

# Upload training file
with open("training.jsonl", "rb") as f:
    training_file = client.files.create(
        file=f,
        purpose="fine-tune"
    )

# Create fine-tuning job
fine_tune_job = client.fine_tuning.jobs.create(
    training_file=training_file.id,
    model="gpt-4o-mini-2025-07-18"
)
```

---

## Best Practices

### 1. File Size Management

```python
import os

def check_file_size(file_path, max_size_mb=25):
    """Check if file is within size limits."""
    size_mb = os.path.getsize(file_path) / (1024 * 1024)

    if size_mb > max_size_mb:
        raise ValueError(f"File too large: {size_mb:.2f}MB (max: {max_size_mb}MB)")

    return size_mb

# Usage
try:
    size = check_file_size("audio.mp3", max_size_mb=25)
    print(f"File size OK: {size:.2f}MB")
except ValueError as e:
    print(e)
```

### 2. Image Optimization

```python
from PIL import Image

def optimize_image(image_path, max_size=(2048, 2048)):
    """Optimize image for API."""
    img = Image.open(image_path)

    # Resize if too large
    if img.size[0] > max_size[0] or img.size[1] > max_size[1]:
        img.thumbnail(max_size, Image.Resampling.LANCZOS)

    # Save optimized
    output_path = "optimized_" + os.path.basename(image_path)
    img.save(output_path, optimize=True, quality=85)

    return output_path
```

### 3. PDF Page Chunking

```python
from PyPDF2 import PdfReader, PdfWriter

def chunk_pdf(pdf_path, max_pages=50):
    """Split PDF into smaller chunks."""
    reader = PdfReader(pdf_path)
    total_pages = len(reader.pages)

    chunks = []
    for i in range(0, total_pages, max_pages):
        writer = PdfWriter()

        # Add pages to chunk
        for j in range(i, min(i + max_pages, total_pages)):
            writer.add_page(reader.pages[j])

        # Save chunk
        chunk_path = f"{pdf_path}_chunk_{i//max_pages + 1}.pdf"
        with open(chunk_path, "wb") as f:
            writer.write(f)

        chunks.append(chunk_path)

    return chunks

# Process large PDF in chunks
chunks = chunk_pdf("large_document.pdf", max_pages=50)
for chunk in chunks:
    result = process_pdf(chunk)
```

### 4. Error Handling

```python
from openai import OpenAIError

def safe_file_upload(file_path, purpose="assistants"):
    """Upload file with error handling."""
    try:
        with open(file_path, "rb") as f:
            file = client.files.create(file=f, purpose=purpose)
        return file.id

    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return None

    except OpenAIError as e:
        print(f"API error: {e}")
        return None

    except Exception as e:
        print(f"Unexpected error: {e}")
        return None
```

---

## Cost Considerations

### Token Usage by File Type

**PDFs:**
- Text: ~1 token per 4 characters
- Images in PDF: 85-170 tokens per page
- 10-page PDF with images: 1,000-2,000 tokens

**Images:**
- Low detail: 85 tokens
- High detail: 85-170 tokens per 512x512 tile

**Audio (Whisper):**
- $0.006 per minute
- No token-based pricing

### Cost Optimization

```python
def estimate_pdf_cost(pdf_path, pages=None):
    """Estimate API cost for PDF processing."""
    # Estimate tokens
    if pages is None:
        from PyPDF2 import PdfReader
        reader = PdfReader(pdf_path)
        pages = len(reader.pages)

    # Assume average: 100 tokens text + 150 tokens images per page
    estimated_tokens = pages * 250

    # GPT-4o pricing
    input_cost = estimated_tokens * 0.0025 / 1000  # $2.50 per 1M
    output_cost = 500 * 0.01 / 1000  # Assume 500 token response

    total = input_cost + output_cost
    print(f"Estimated cost: ${total:.4f}")
    return total
```

---

## Next Steps

1. **[Prompting →](./prompting/overview.md)** - Effective prompt engineering
2. **[Batch API →](./batch-api.md)** - Process files at scale
3. **[Images & Vision →](../02-core-concepts/images-and-vision.md)** - Deep dive into vision
4. **[Audio & Speech →](../02-core-concepts/audio-and-speech.md)** - Audio processing guide

---

## Additional Resources

- **PDF Files Guide**: https://platform.openai.com/docs/guides/pdf-files
- **Vision Guide**: https://platform.openai.com/docs/guides/vision
- **Audio Guide**: https://platform.openai.com/docs/guides/audio
- **Files API Reference**: https://platform.openai.com/docs/api-reference/files

---

**Next**: [Prompting Overview →](./prompting/overview.md)
