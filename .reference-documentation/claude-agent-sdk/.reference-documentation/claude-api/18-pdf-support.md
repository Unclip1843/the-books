# Claude API - PDF Support

**Sources:**
- https://docs.claude.com/en/docs/build-with-claude/pdf-support

**Fetched:** 2025-10-11

## Overview

Claude can directly process PDF documents, extracting text, analyzing charts, understanding visual content, and answering questions about the document.

## Capabilities

✅ Extract text from PDFs
✅ Analyze charts and graphs
✅ Understand visual content
✅ Answer questions about content
✅ Summarize documents
✅ Extract structured data

## Supported Models

- Claude Sonnet 4.5
- Claude Opus 4.1
- Claude Haiku 3.5
- All Claude 3.5+ models

## PDF Limits

| Limit | Value |
|-------|-------|
| Max file size | 32 MB |
| Max pages | 100 pages per request |
| Processing method | Convert each page to image + extract text |

## Python Implementation

### PDF from URL

```python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=2048,
    messages=[{
        "role": "user",
        "content": [
            {
                "type": "document",
                "source": {
                    "type": "url",
                    "url": "https://example.com/document.pdf"
                }
            },
            {"type": "text", "text": "Summarize this PDF"}
        ]
    }]
)

print(message.content[0].text)
```

### PDF from Base64

```python
import base64

with open("document.pdf", "rb") as f:
    pdf_data = base64.standard_b64encode(f.read()).decode()

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=2048,
    messages=[{
        "role": "user",
        "content": [
            {
                "type": "document",
                "source": {
                    "type": "base64",
                    "media_type": "application/pdf",
                    "data": pdf_data
                }
            },
            {"type": "text", "text": "What are the key points?"}
        ]
    }]
)
```

### With Files API

```python
# Upload PDF
with open("document.pdf", "rb") as f:
    file = client.files.create(file=f, purpose="user_message")

# Use in message
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=2048,
    messages=[{
        "role": "user",
        "content": [
            {
                "type": "document",
                "source": {"type": "file", "file_id": file.id}
            },
            {"type": "text", "text": "Analyze this document"}
        ]
    }],
    betas=["files-api-2025-04-14"]
)
```

## Pricing

PDFs are converted to images and text:
- Approximately **1,500-3,000 tokens per page**
- Varies by content density and visual complexity

**Example (10-page PDF at Sonnet 4.5):**
```
10 pages × 2,000 tokens/page = 20,000 tokens
Cost: (20,000 / 1,000,000) × $3.00 = $0.06
```

## Best Practices

1. **Place PDF first** in content array
2. **Use clear fonts** for better OCR
3. **Split large documents** if over 100 pages
4. **Check file size** - stay under 32MB

## Limitations

❌ No password-protected PDFs
❌ No encrypted PDFs
❌ Maximum 100 pages per request
❌ Maximum 32MB file size

## Related Documentation

- [Vision](./07-vision.md)
- [Files API](./17-files-api.md)
- [Messages API](./03-messages-api.md)
