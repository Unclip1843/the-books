# OpenAI Platform - Getting Started

**Source:** https://platform.openai.com/docs/quickstart
**Fetched:** 2025-10-11

## Quick Start Guide

This guide will walk you through making your first API call to the OpenAI Platform in less than 5 minutes. By the end, you'll have a working application that uses GPT models for text generation.

**What You'll Learn:**
- Create an OpenAI account and API key
- Install the official SDK
- Make your first API request
- Handle responses and errors
- Next steps for building your application

---

## Prerequisites

**Required:**
- Programming knowledge (Python, TypeScript, or another supported language)
- Command line/terminal access
- Internet connection

**Optional but Recommended:**
- Git for version control
- Code editor (VS Code, PyCharm, etc.)
- Python 3.7+ or Node.js 18+

---

## Step 1: Create Your Account

### Sign Up

1. Visit **https://platform.openai.com**
2. Click **Sign up** or **Get started**
3. Create account with:
   - Email address
   - Google account
   - Microsoft account

### Verify Email

Check your email and click the verification link to activate your account.

---

## Step 2: Generate API Key

### Create Your First API Key

1. **Navigate to API Keys**
   - Go to https://platform.openai.com/api-keys
   - Or click your profile → "API keys"

2. **Create New Key**
   ```
   Click "Create new secret key"
   ```

3. **Name Your Key**
   ```
   Name: "My First Key" (or "Development", "Production", etc.)
   Project: Default project or create new
   ```

4. **Copy and Save**
   ```
   sk-proj-...
   ```
   **IMPORTANT:** Save this key immediately. You won't be able to see it again!

### Secure Your API Key

**✅ DO:**
```bash
# Store in environment variable
export OPENAI_API_KEY='sk-proj-...'

# Or in .env file
echo "OPENAI_API_KEY=sk-proj-..." > .env
```

**❌ DON'T:**
```python
# Never hardcode in code
client = OpenAI(api_key="sk-proj-...")  # Bad!

# Never commit to Git
git add config.py  # containing API key - Bad!
```

### Add Payment Method

**Note:** As of 2025, OpenAI requires payment information before making API calls (no free trial credits by default).

1. Go to **Settings → Billing**
2. Click **Add payment method**
3. Enter credit card information
4. Set usage limits (recommended):
   ```
   Soft limit: $10/month (get notified)
   Hard limit: $50/month (prevent overage)
   ```

---

## Step 3: Install SDK

### Python

```bash
# Install with pip
pip install openai

# Or with poetry
poetry add openai

# Verify installation
python -c "import openai; print(openai.__version__)"
```

**Requirements:**
- Python 3.7.1 or newer
- pip or poetry

### TypeScript / Node.js

```bash
# Install with npm
npm install openai

# Or with yarn
yarn add openai

# Or with pnpm
pnpm add openai

# Verify installation
node -e "console.log(require('openai').VERSION)"
```

**Requirements:**
- Node.js 18 or newer
- npm, yarn, or pnpm

### Other Languages

```bash
# Go
go get github.com/openai/openai-go

# .NET
dotnet add package OpenAI

# Java
# Add to pom.xml or build.gradle
```

---

## Step 4: Your First API Call

### Python Example

Create a file called `hello_openai.py`:

```python
from openai import OpenAI
import os

# Initialize client (reads OPENAI_API_KEY from environment)
client = OpenAI()

# Alternative: explicitly pass API key
# client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

def main():
    """Make your first API call."""
    try:
        # Create chat completion
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "system",
                    "content": "You are a helpful assistant."
                },
                {
                    "role": "user",
                    "content": "Explain what the OpenAI API is in one sentence."
                }
            ]
        )

        # Print the response
        print("Response:")
        print(response.choices[0].message.content)

        # Print usage statistics
        print(f"\nTokens used: {response.usage.total_tokens}")
        print(f"  Prompt: {response.usage.prompt_tokens}")
        print(f"  Completion: {response.usage.completion_tokens}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
```

**Run it:**

```bash
# Set your API key
export OPENAI_API_KEY='sk-proj-...'

# Run the script
python hello_openai.py
```

**Expected Output:**

```
Response:
The OpenAI API is a service that provides access to powerful AI models for tasks like text generation, image creation, and language understanding.

Tokens used: 42
  Prompt: 28
  Completion: 14
```

### TypeScript Example

Create a file called `hello_openai.ts`:

```typescript
import OpenAI from 'openai';

// Initialize client (reads OPENAI_API_KEY from environment)
const client = new OpenAI();

async function main() {
  try {
    // Create chat completion
    const response = await client.chat.completions.create({
      model: 'gpt-4o',
      messages: [
        {
          role: 'system',
          content: 'You are a helpful assistant.',
        },
        {
          role: 'user',
          content: 'Explain what the OpenAI API is in one sentence.',
        },
      ],
    });

    // Print the response
    console.log('Response:');
    console.log(response.choices[0].message.content);

    // Print usage statistics
    console.log(`\nTokens used: ${response.usage?.total_tokens}`);
    console.log(`  Prompt: ${response.usage?.prompt_tokens}`);
    console.log(`  Completion: ${response.usage?.completion_tokens}`);

  } catch (error) {
    console.error('Error:', error);
  }
}

main();
```

**Run it:**

```bash
# Set your API key
export OPENAI_API_KEY='sk-proj-...'

# Run with ts-node
npx ts-node hello_openai.ts

# Or compile and run
tsc hello_openai.ts && node hello_openai.js
```

---

## Step 5: Understanding the Response

### Response Structure

```python
response = {
    "id": "chatcmpl-abc123",
    "object": "chat.completion",
    "created": 1728691200,
    "model": "gpt-4o-2024-08-06",
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "The OpenAI API is..."
            },
            "finish_reason": "stop"
        }
    ],
    "usage": {
        "prompt_tokens": 28,
        "completion_tokens": 14,
        "total_tokens": 42
    }
}
```

### Key Fields

**id**: Unique identifier for this completion

**model**: The actual model used (may include version)

**choices**: Array of completions (usually just one)
- **message.content**: The generated text
- **finish_reason**: Why completion stopped
  - `stop`: Natural end
  - `length`: Hit token limit
  - `content_filter`: Filtered by moderation

**usage**: Token counts for billing
- **prompt_tokens**: Your input tokens
- **completion_tokens**: Generated tokens
- **total_tokens**: Sum (what you're billed for)

---

## Step 6: Common Errors and Solutions

### Error: Authentication Invalid

```
openai.AuthenticationError: Incorrect API key provided
```

**Solution:**
```python
# Check your API key
import os
print(os.environ.get("OPENAI_API_KEY"))

# Make sure it starts with sk-proj-
# Make sure there are no extra spaces or quotes
```

### Error: Rate Limit Exceeded

```
openai.RateLimitError: Rate limit reached for requests
```

**Solution:**
```python
import time
from openai import RateLimitError

try:
    response = client.chat.completions.create(...)
except RateLimitError:
    print("Rate limited. Waiting 60 seconds...")
    time.sleep(60)
    response = client.chat.completions.create(...)
```

### Error: Insufficient Quota

```
openai.InsufficientQuotaError: You exceeded your current quota
```

**Solution:**
- Add payment method at https://platform.openai.com/account/billing
- Purchase credits or set up auto-reload
- Check usage at https://platform.openai.com/usage

### Error: Invalid Request

```
openai.InvalidRequestError: The model 'gpt-5' does not exist
```

**Solution:**
```python
# Use correct model names
models = [
    "gpt-4o",           # Latest GPT-4 model
    "gpt-4o-mini",      # Fast, affordable
    "gpt-4-turbo",      # GPT-4 Turbo
    "gpt-3.5-turbo",    # Cost-effective
]
```

---

## Step 7: Building on Your First Call

### Add Conversation History

```python
messages = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "What is the capital of France?"},
]

response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages
)

# Add assistant's response to history
messages.append({
    "role": "assistant",
    "content": response.choices[0].message.content
})

# Continue conversation
messages.append({
    "role": "user",
    "content": "What is its population?"
})

response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages
)
```

### Add Parameters

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages,

    # Control randomness (0.0 = deterministic, 2.0 = very random)
    temperature=0.7,

    # Limit response length
    max_tokens=500,

    # Alternative to temperature
    top_p=0.9,

    # Penalize repeated tokens
    frequency_penalty=0.0,
    presence_penalty=0.0,

    # Stop generation at certain strings
    stop=["\n\n", "---"],
)
```

### Stream Responses

```python
stream = client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    stream=True  # Enable streaming
)

print("Response: ", end="")
for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)
print()  # New line at end
```

### Handle Errors Gracefully

```python
from openai import OpenAI, APIError, RateLimitError, APIConnectionError

client = OpenAI()

def make_api_call(messages, max_retries=3):
    """Make API call with retry logic."""
    for attempt in range(max_retries):
        try:
            return client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                timeout=30.0  # 30 second timeout
            )

        except RateLimitError:
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt  # Exponential backoff
                print(f"Rate limited. Retrying in {wait_time}s...")
                time.sleep(wait_time)
            else:
                raise

        except APIConnectionError:
            if attempt < max_retries - 1:
                print(f"Connection error. Retrying...")
                time.sleep(1)
            else:
                raise

        except APIError as e:
            print(f"API error: {e}")
            raise

# Usage
response = make_api_call(messages)
```

---

## Step 8: Explore More Features

### Use Different Models

```python
# GPT-4o: Best for complex tasks
response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages
)

# GPT-4o-mini: Fast and affordable
response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=messages
)

# GPT-3.5-turbo: Cost-effective
response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=messages
)
```

### Add Vision Capabilities

```python
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
```

### Use Function Calling

```python
tools = [{
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": "Get current weather",
        "parameters": {
            "type": "object",
            "properties": {
                "location": {"type": "string"},
                "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]}
            },
            "required": ["location"]
        }
    }
}]

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "What's the weather in Boston?"}],
    tools=tools
)

# Check if model wants to call function
if response.choices[0].message.tool_calls:
    tool_call = response.choices[0].message.tool_calls[0]
    print(f"Model wants to call: {tool_call.function.name}")
    print(f"With arguments: {tool_call.function.arguments}")
```

---

## Example Projects

### Simple Chatbot

```python
from openai import OpenAI

client = OpenAI()
messages = [{"role": "system", "content": "You are a helpful assistant."}]

print("Chatbot ready! Type 'quit' to exit.\n")

while True:
    user_input = input("You: ")
    if user_input.lower() == 'quit':
        break

    messages.append({"role": "user", "content": user_input})

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=messages
    )

    assistant_message = response.choices[0].message.content
    messages.append({"role": "assistant", "content": assistant_message})

    print(f"Assistant: {assistant_message}\n")
```

### Text Summarizer

```python
def summarize_text(text, max_words=100):
    """Summarize text to specified length."""
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "user",
            "content": f"Summarize this text in {max_words} words or less:\n\n{text}"
        }]
    )
    return response.choices[0].message.content

# Usage
long_text = "..." # Your long text here
summary = summarize_text(long_text, max_words=50)
print(summary)
```

### Language Translator

```python
def translate(text, target_language):
    """Translate text to target language."""
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "user",
            "content": f"Translate this to {target_language}:\n\n{text}"
        }]
    )
    return response.choices[0].message.content

# Usage
translated = translate("Hello, how are you?", "Spanish")
print(translated)  # "Hola, ¿cómo estás?"
```

---

## Best Practices

### 1. Security

✅ **Never expose API keys**
```python
# Good
client = OpenAI()  # Reads from OPENAI_API_KEY env var

# Bad
client = OpenAI(api_key="sk-proj-...")  # Hardcoded!
```

✅ **Add .env to .gitignore**
```bash
echo ".env" >> .gitignore
```

### 2. Cost Management

✅ **Set usage limits**
```
Platform → Settings → Billing → Usage limits
Soft limit: $10 (notification)
Hard limit: $50 (stop billing)
```

✅ **Monitor usage**
```python
# Always check token usage
print(f"Tokens used: {response.usage.total_tokens}")

# Estimate costs
input_cost = response.usage.prompt_tokens * 0.0025 / 1000  # $2.50/1M
output_cost = response.usage.completion_tokens * 0.01 / 1000  # $10/1M
total = input_cost + output_cost
print(f"Cost: ${total:.6f}")
```

✅ **Use appropriate models**
```python
# Simple tasks → cheaper model
if task_complexity == "simple":
    model = "gpt-4o-mini"  # Cheaper
else:
    model = "gpt-4o"  # More capable
```

### 3. Error Handling

✅ **Always use try-except**
```python
try:
    response = client.chat.completions.create(...)
except Exception as e:
    print(f"Error: {e}")
    # Handle gracefully
```

✅ **Implement retries**
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
def make_api_call():
    return client.chat.completions.create(...)
```

### 4. Performance

✅ **Use streaming for better UX**
```python
stream = client.chat.completions.create(..., stream=True)
for chunk in stream:
    print(chunk.choices[0].delta.content, end="")
```

✅ **Set appropriate timeouts**
```python
response = client.chat.completions.create(
    ...,
    timeout=30.0  # 30 seconds
)
```

---

## Next Steps

### Learn More

1. **[Authentication Guide →](./authentication.md)** - API key management and security
2. **[Models Overview →](./models.md)** - Choose the right model for your use case
3. **[Pricing Guide →](./pricing.md)** - Understand token pricing and costs
4. **[Core Concepts →](../02-core-concepts/text-generation.md)** - Deep dive into capabilities

### Explore Advanced Features

- **[Agents →](../03-agents/overview.md)** - Build autonomous agents
- **[Tools →](../04-tools/overview.md)** - Function calling and external tools
- **[Streaming →](../05-run-and-scale/streaming.md)** - Real-time responses
- **[Fine-tuning →](../08-model-optimization/fine-tuning/supervised.md)** - Custom models

### Join the Community

- **Community Forum**: https://community.openai.com
- **GitHub Examples**: https://github.com/openai/openai-cookbook
- **Discord**: Join the OpenAI developer community
- **Twitter**: Follow @OpenAI and @OpenAIDevs

---

## Troubleshooting

### Installation Issues

**Problem:** `pip install openai` fails

**Solution:**
```bash
# Upgrade pip
python -m pip install --upgrade pip

# Try with --user flag
pip install --user openai

# Or use virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install openai
```

### Import Errors

**Problem:** `ModuleNotFoundError: No module named 'openai'`

**Solution:**
```bash
# Check Python version
python --version  # Need 3.7.1+

# Check if openai is installed
pip list | grep openai

# Reinstall
pip uninstall openai
pip install openai
```

### API Key Not Found

**Problem:** `openai.OpenAIError: API key not provided`

**Solution:**
```bash
# Set environment variable
export OPENAI_API_KEY='sk-proj-...'

# Or create .env file
echo "OPENAI_API_KEY=sk-proj-..." > .env

# Load in Python
from dotenv import load_dotenv
load_dotenv()
```

---

## Additional Resources

- **API Reference**: https://platform.openai.com/docs/api-reference
- **Playground**: https://platform.openai.com/playground
- **Cookbook**: https://github.com/openai/openai-cookbook
- **Examples**: https://platform.openai.com/examples
- **Status Page**: https://status.openai.com

---

**Next**: [Authentication →](./authentication.md)
