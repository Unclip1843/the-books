# Claude API - Integrations

**Sources:**
- https://docs.claude.com/en/api
- https://docs.claude.com/en/docs/third-party

**Fetched:** 2025-10-11

## Overview

Claude is available through multiple platforms and integrations beyond the direct Anthropic API, including Amazon Bedrock, Google Vertex AI, and OpenAI SDK compatibility.

## Integration Options

### 1. Direct Anthropic API

**Best for:** Full feature access, latest updates

```python
import anthropic
client = anthropic.Anthropic(api_key="...")
```

**Advantages:**
- Latest features first
- Full API control
- Direct pricing
- Complete documentation

### 2. Amazon Bedrock

**Best for:** AWS-native applications, enterprise security

Claude is available on AWS Bedrock with:
- AWS IAM authentication
- VPC endpoints
- CloudWatch monitoring
- AWS pricing model

```python
import boto3

bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')

response = bedrock.invoke_model(
    modelId='anthropic.claude-sonnet-4-5-20250929',
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 1024,
        "messages": [{"role": "user", "content": "Hello"}]
    })
)
```

### 3. Google Vertex AI

**Best for:** GCP-native applications, Google Cloud integration

Claude available on Vertex AI with:
- Google Cloud authentication
- Vertex AI endpoints
- Google Cloud monitoring
- GCP pricing

```python
from anthropic import AnthropicVertex

client = AnthropicVertex(
    region="us-central1",
    project_id="your-project-id"
)

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}]
)
```

### 4. OpenAI SDK Compatibility

**Best for:** Migrating from OpenAI, minimal code changes

Anthropic provides OpenAI-compatible endpoints:

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://api.anthropic.com/v1/openai",
    api_key="your-anthropic-key"
)

response = client.chat.completions.create(
    model="claude-sonnet-4-5-20250929",
    messages=[{"role": "user", "content": "Hello"}]
)
```

## Feature Comparison

| Feature | Direct API | Bedrock | Vertex AI | OpenAI SDK |
|---------|-----------|---------|-----------|------------|
| Latest Models | ✅ First | ⏱ Delayed | ⏱ Delayed | ✅ Yes |
| Streaming | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Tool Use | ✅ Yes | ✅ Yes | ✅ Yes | ⚠️ Limited |
| Vision | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Prompt Caching | ✅ Yes | ⚠️ Limited | ⚠️ Limited | ✅ Yes |
| Extended Thinking | ✅ Yes | ❌ No | ❌ No | ❌ No |

## Choosing an Integration

### Use Direct API When:
- You want latest features immediately
- You need full API control
- You're building new applications
- You want comprehensive documentation

### Use Bedrock When:
- You're already on AWS
- You need AWS security/compliance
- You want AWS monitoring
- Your team uses AWS tools

### Use Vertex AI When:
- You're already on Google Cloud
- You need GCP integration
- You want Google Cloud tools
- Your infrastructure is on GCP

### Use OpenAI SDK When:
- Migrating from OpenAI
- You have existing OpenAI code
- You want minimal changes
- You're familiar with OpenAI patterns

## Model Names by Platform

| Anthropic Name | Bedrock ID | Vertex AI ID |
|----------------|------------|--------------|
| Claude Sonnet 4.5 | `anthropic.claude-sonnet-4-5` | `claude-sonnet-4-5` |
| Claude Opus 4.1 | `anthropic.claude-opus-4-1` | `claude-opus-4-1` |
| Claude Haiku 3.5 | `anthropic.claude-3-5-haiku` | `claude-3-5-haiku` |

## Related Documentation

- [Getting Started](./02-getting-started.md)
- [Python SDK](./04-python-sdk.md)
- [TypeScript SDK](./05-typescript-sdk.md)
- [Models](./10-models.md)
