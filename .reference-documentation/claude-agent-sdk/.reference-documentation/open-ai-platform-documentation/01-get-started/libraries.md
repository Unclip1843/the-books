# OpenAI Platform - Libraries

**Source:** https://platform.openai.com/docs/libraries
**Fetched:** 2025-10-11

## Overview

OpenAI provides official client libraries for popular programming languages, making it easy to integrate OpenAI's API into your applications.

---

## Official Libraries

### Python

**openai-python** - The official Python library for the OpenAI API

- **Repository**: https://github.com/openai/openai-python
- **Package**: https://pypi.org/project/openai/
- **Requirements**: Python 3.8+

**Installation**:
```bash
pip install openai
```

**Features**:
- ✅ Type definitions and autocomplete
- ✅ Synchronous and asynchronous clients
- ✅ Streaming support
- ✅ Automatic retries
- ✅ Error handling with specific exception types

**Basic Usage**:
```python
from openai import OpenAI

client = OpenAI(api_key="your-api-key")

response = client.chat.completions.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Hello!"}
    ]
)

print(response.choices[0].message.content)
```

**Async Usage**:
```python
from openai import AsyncOpenAI

client = AsyncOpenAI(api_key="your-api-key")

async def main():
    response = await client.chat.completions.create(
        model="gpt-5",
        messages=[{"role": "user", "content": "Hello!"}]
    )
    print(response.choices[0].message.content)
```

---

### TypeScript / JavaScript

**openai-node** - The official Node.js / TypeScript library for the OpenAI API

- **Repository**: https://github.com/openai/openai-node
- **Package**: https://www.npmjs.com/package/openai
- **Requirements**: Node.js 18+, TypeScript 4.9+

**Installation**:
```bash
npm install openai
# or
yarn add openai
# or
pnpm add openai
```

**Features**:
- ✅ Full TypeScript support with types
- ✅ Promise-based async/await API
- ✅ Streaming support
- ✅ Automatic retries
- ✅ Works in Node.js, Deno, Bun, Cloudflare Workers, Vercel Edge

**Basic Usage (TypeScript)**:
```typescript
import OpenAI from 'openai';

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function main() {
  const response = await client.chat.completions.create({
    model: 'gpt-5',
    messages: [{ role: 'user', content: 'Hello!' }],
  });

  console.log(response.choices[0].message.content);
}

main();
```

**JavaScript (CommonJS)**:
```javascript
const OpenAI = require('openai');

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function main() {
  const response = await client.chat.completions.create({
    model: 'gpt-5',
    messages: [{ role: 'user', content: 'Hello!' }],
  });

  console.log(response.choices[0].message.content);
}

main();
```

---

### Go

**openai-go** - The official Go library for the OpenAI API

- **Repository**: https://github.com/openai/openai-go
- **Package**: `github.com/openai/openai-go`
- **Requirements**: Go 1.18+

**Installation**:
```bash
go get github.com/openai/openai-go
```

**Basic Usage**:
```go
package main

import (
    "context"
    "fmt"
    "github.com/openai/openai-go"
)

func main() {
    client := openai.NewClient(
        option.WithAPIKey("your-api-key"),
    )

    response, err := client.Chat.Completions.New(context.Background(), openai.ChatCompletionNewParams{
        Messages: openai.F([]openai.ChatCompletionMessageParamUnion{
            openai.UserMessage("Hello!"),
        }),
        Model: openai.F("gpt-5"),
    })

    if err != nil {
        panic(err)
    }

    fmt.Println(response.Choices[0].Message.Content)
}
```

---

### Java

**openai-java** - The official Java library for the OpenAI API

- **Repository**: https://github.com/openai/openai-java
- **Package**: Maven Central
- **Requirements**: Java 8+

**Installation (Maven)**:
```xml
<dependency>
    <groupId>com.openai</groupId>
    <artifactId>openai-java</artifactId>
    <version>0.1.0</version>
</dependency>
```

**Installation (Gradle)**:
```gradle
implementation 'com.openai:openai-java:0.1.0'
```

**Basic Usage**:
```java
import com.openai.client.OpenAIClient;
import com.openai.models.ChatCompletion;

public class Main {
    public static void main(String[] args) {
        OpenAIClient client = OpenAIClient.builder()
            .apiKey("your-api-key")
            .build();

        ChatCompletion response = client.chat().completions().create(
            CreateChatCompletionRequest.builder()
                .model("gpt-5")
                .addMessage(ChatCompletionMessage.user("Hello!"))
                .build()
        );

        System.out.println(response.choices().get(0).message().content());
    }
}
```

---

### .NET / C#

**openai-dotnet** - The official .NET library for the OpenAI API

- **Repository**: https://github.com/openai/openai-dotnet
- **Package**: NuGet
- **Requirements**: .NET 6.0+

**Installation**:
```bash
dotnet add package OpenAI
```

**Basic Usage**:
```csharp
using OpenAI;

var client = new OpenAIClient("your-api-key");

var response = await client.Chat.Completions.CreateAsync(
    model: "gpt-5",
    messages: new[]
    {
        new { role = "user", content = "Hello!" }
    }
);

Console.WriteLine(response.Choices[0].Message.Content);
```

---

## Specialized SDKs

### OpenAI Agents SDK (Python)

**openai-agents-python** - Build agentic AI applications

- **Repository**: https://github.com/openai/openai-agents-python
- **Package**: https://pypi.org/project/openai-agents/
- **Replaces**: Swarm (experimental framework)

**Installation**:
```bash
pip install openai-agents
```

**Features**:
- Multi-agent orchestration
- Tool integration
- Conversation management
- Production-ready agent patterns

**Basic Usage**:
```python
from openai_agents import Agent, Runner

agent = Agent(
    name="Assistant",
    instructions="You are a helpful assistant",
    model="gpt-5"
)

runner = Runner()
response = runner.run(agent, "Hello!")
print(response.messages[-1].content)
```

---

### OpenAI Agents SDK (TypeScript)

**openai-agents-js** - Build agentic AI applications in TypeScript

- **Repository**: https://github.com/openai/openai-agents-js
- **Package**: https://www.npmjs.com/package/openai-agents

**Installation**:
```bash
npm install openai-agents
```

**Basic Usage**:
```typescript
import { Agent, Runner } from 'openai-agents';

const agent = new Agent({
  name: 'Assistant',
  instructions: 'You are a helpful assistant',
  model: 'gpt-5',
});

const runner = new Runner();
const response = await runner.run(agent, 'Hello!');
console.log(response.messages[response.messages.length - 1].content);
```

---

## Community Libraries

OpenAI does not officially maintain libraries for these languages, but the community has created high-quality options:

### Ruby

**ruby-openai** (Community-maintained)
- Repository: https://github.com/alexrudall/ruby-openai
- Package: https://rubygems.org/gems/ruby-openai

```bash
gem install ruby-openai
```

```ruby
require "openai"

client = OpenAI::Client.new(access_token: "your-api-key")

response = client.chat(
    parameters: {
        model: "gpt-5",
        messages: [{ role: "user", content: "Hello!" }]
    }
)

puts response.dig("choices", 0, "message", "content")
```

---

### PHP

**openai-php/client** (Community-maintained)
- Repository: https://github.com/openai-php/client
- Package: https://packagist.org/packages/openai-php/client

```bash
composer require openai-php/client
```

```php
<?php

$client = OpenAI::client('your-api-key');

$response = $client->chat()->create([
    'model' => 'gpt-5',
    'messages' => [
        ['role' => 'user', 'content' => 'Hello!'],
    ],
]);

echo $response->choices[0]->message->content;
```

---

### Rust

**async-openai** (Community-maintained)
- Repository: https://github.com/64bit/async-openai
- Package: https://crates.io/crates/async-openai

```bash
cargo add async-openai
```

```rust
use async_openai::{Client, types::*};

#[tokio::main]
async fn main() {
    let client = Client::new();

    let request = CreateChatCompletionRequestArgs::default()
        .model("gpt-5")
        .messages(vec![
            ChatCompletionRequestMessageArgs::default()
                .role("user")
                .content("Hello!")
                .build()
                .unwrap()
        ])
        .build()
        .unwrap();

    let response = client.chat().create(request).await.unwrap();
    println!("{}", response.choices[0].message.content);
}
```

---

### Swift

**MacPaw/OpenAI** (Community-maintained)
- Repository: https://github.com/MacPaw/OpenAI
- Package: Swift Package Manager

```swift
import OpenAI

let client = OpenAI(apiToken: "your-api-key")

let query = ChatQuery(
    model: .gpt5,
    messages: [.user(.init(content: "Hello!"))]
)

let response = try await client.chats(query: query)
print(response.choices[0].message.content)
```

---

## Library Comparison

| Language | Official | Async Support | Streaming | Type Safety |
|----------|----------|---------------|-----------|-------------|
| Python | ✅ | ✅ | ✅ | ✅ (with types) |
| TypeScript | ✅ | ✅ | ✅ | ✅ |
| Go | ✅ | ✅ | ✅ | ✅ |
| Java | ✅ | ✅ | ✅ | ✅ |
| .NET/C# | ✅ | ✅ | ✅ | ✅ |
| Ruby | ❌ (Community) | ✅ | ✅ | ❌ |
| PHP | ❌ (Community) | ⚠️ Varies | ✅ | ⚠️ Limited |
| Rust | ❌ (Community) | ✅ | ✅ | ✅ |
| Swift | ❌ (Community) | ✅ | ✅ | ✅ |

---

## Common Features Across Official SDKs

### Automatic Retries

All official SDKs automatically retry failed requests with exponential backoff:

```python
# Python
from openai import OpenAI

client = OpenAI(
    max_retries=3,  # Default is 2
)
```

```typescript
// TypeScript
import OpenAI from 'openai';

const client = new OpenAI({
  maxRetries: 3,  // Default is 2
});
```

### Custom Timeouts

```python
# Python
client = OpenAI(timeout=30.0)  # 30 seconds
```

```typescript
// TypeScript
const client = new OpenAI({
  timeout: 30 * 1000,  // 30 seconds (in ms)
});
```

### Streaming

```python
# Python
stream = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Hello!"}],
    stream=True
)

for chunk in stream:
    print(chunk.choices[0].delta.content, end="")
```

```typescript
// TypeScript
const stream = await client.chat.completions.create({
  model: 'gpt-5',
  messages: [{ role: 'user', content: 'Hello!' }],
  stream: true,
});

for await (const chunk of stream) {
  process.stdout.write(chunk.choices[0]?.delta?.content || '');
}
```

### Error Handling

```python
# Python
from openai import APIError, RateLimitError, APIConnectionError

try:
    response = client.chat.completions.create(...)
except RateLimitError as e:
    print(f"Rate limit exceeded: {e}")
except APIConnectionError as e:
    print(f"Connection error: {e}")
except APIError as e:
    print(f"API error: {e}")
```

```typescript
// TypeScript
import OpenAI from 'openai';

try {
  const response = await client.chat.completions.create(...);
} catch (error) {
  if (error instanceof OpenAI.APIError) {
    console.error(`API Error: ${error.status} - ${error.message}`);
  }
}
```

---

## Framework Integrations

### LangChain

OpenAI models integrate seamlessly with LangChain:

**Python**:
```python
from langchain.chat_models import ChatOpenAI
from langchain.schema import HumanMessage

chat = ChatOpenAI(model="gpt-5", temperature=0.7)
response = chat([HumanMessage(content="Hello!")])
print(response.content)
```

**TypeScript**:
```typescript
import { ChatOpenAI } from "langchain/chat_models/openai";
import { HumanMessage } from "langchain/schema";

const chat = new ChatOpenAI({ modelName: "gpt-5", temperature: 0.7 });
const response = await chat.call([new HumanMessage("Hello!")]);
console.log(response.content);
```

### LlamaIndex

```python
from llama_index.llms import OpenAI

llm = OpenAI(model="gpt-5", temperature=0.7)
response = llm.complete("Hello!")
print(response.text)
```

### Haystack

```python
from haystack.nodes import PromptNode

prompt_node = PromptNode(
    model_name_or_path="gpt-5",
    api_key="your-api-key"
)
```

---

## HTTP API (No Library)

If no library is available for your language, you can use the REST API directly:

**cURL Example**:
```bash
curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
    "model": "gpt-5",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

**HTTP Request Format**:
```http
POST /v1/chat/completions HTTP/1.1
Host: api.openai.com
Content-Type: application/json
Authorization: Bearer YOUR_API_KEY

{
  "model": "gpt-5",
  "messages": [{"role": "user", "content": "Hello!"}]
}
```

---

## Additional Resources

- **Official Libraries**: https://platform.openai.com/docs/libraries
- **API Reference**: https://platform.openai.com/docs/api-reference
- **Community Libraries**: https://platform.openai.com/docs/libraries/community-libraries
- **Cookbook Examples**: https://cookbook.openai.com

---

**Next**: [Core Concepts →](../02-core-concepts/text-generation.md)
