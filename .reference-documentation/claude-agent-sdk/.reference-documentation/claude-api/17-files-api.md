# Claude API - Files API

**Sources:**
- https://docs.claude.com/en/docs/build-with-claude/files
- https://docs.claude.com/en/api/files

**Fetched:** 2025-10-11

## Overview

The Files API (Beta) allows you to upload files once and reference them in multiple Message requests, avoiding the need to re-upload content repeatedly. This simplifies working with documents, images, and other file types.

## ⚠️ Beta Status

- Requires beta header: `anthropic-beta: files-api-2025-04-14`
- Features may change
- Rate limits subject to adjustment

## Supported File Types

| Type | MIME Type | Support |
|------|-----------|---------|
| PDF | `application/pdf` | ✅ Claude 3.5+ |
| Plain Text | `text/plain` | ✅ All models |
| JPEG | `image/jpeg` | ✅ Claude 3+ |
| PNG | `image/png` | ✅ Claude 3+ |
| GIF | `image/gif` | ✅ Claude 3+ |
| WebP | `image/webp` | ✅ Claude 3+ |

## Storage Limits

| Limit | Value |
|-------|-------|
| Max file size | 500 MB |
| Max organization storage | 100 GB |
| File retention | Indefinite (until deleted) |

## Python Implementation

### Upload a File

```python
import anthropic

client = anthropic.Anthropic()

# Upload file
with open("document.pdf", "rb") as f:
    file = client.files.create(
        file=f,
        purpose="user_message"
    )

print(f"File ID: {file.id}")
print(f"Filename: {file.filename}")
print(f"Size: {file.bytes} bytes")
```

### Use File in Message

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=2048,
    messages=[{
        "role": "user",
        "content": [
            {
                "type": "document",
                "source": {
                    "type": "file",
                    "file_id": file.id
                }
            },
            {
                "type": "text",
                "text": "Summarize this document"
            }
        ]
    }],
    betas=["files-api-2025-04-14"]
)
```

### List Files

```python
# List all files
files = client.files.list()

for file in files.data:
    print(f"{file.id}: {file.filename} ({file.bytes} bytes)")
```

### Delete File

```python
# Delete file
deleted = client.files.delete(file.id)

print(f"Deleted: {deleted.id}")
```

## TypeScript Implementation

```typescript
import Anthropic from '@anthropic-ai/sdk';
import * as fs from 'fs';

const client = new Anthropic();

// Upload file
const file = await client.files.create({
  file: fs.createReadStream('document.pdf'),
  purpose: 'user_message',
});

// Use in message
const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 2048,
  messages: [{
    role: 'user',
    content: [
      {
        type: 'document',
        source: {
          type: 'file',
          file_id: file.id,
        },
      },
      { type: 'text', text: 'Summarize this document' },
    ],
  }],
  betas: ['files-api-2025-04-14'],
});
```

## Pricing

- File API operations (upload, list, delete) are **free**
- File content used in messages is priced as **input tokens**
- Token count varies by file type (PDFs ~1,500-3,000 tokens/page)

## Best Practices

1. **Upload once, use many times** - Avoid re-uploading same file
2. **Delete unused files** - Manage storage limits
3. **Use appropriate content types** - `document` for PDFs/text, `image` for images
4. **Check file size** - Stay under 500MB limit

## Related Documentation

- [Messages API](./03-messages-api.md)
- [PDF Support](./18-pdf-support.md)
- [Vision](./07-vision.md)
