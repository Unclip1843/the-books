# Claude API - TypeScript SDK Reference

**Source:** https://github.com/anthropics/anthropic-sdk-typescript  
**Fetched:** 2025-10-11

## Installation

```bash
npm install @anthropic-ai/sdk
```

**Requirements:**
- Node.js 16+

## Quick Start

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [
    { role: 'user', content: 'Hello, Claude' }
  ],
});

console.log(message.content[0].text);
```

## Client Initialization

### Basic Client

```typescript
import Anthropic from '@anthropic-ai/sdk';

// From environment variable
const client = new Anthropic();  // Uses ANTHROPIC_API_KEY

// Explicit API key
const client = new Anthropic({
  apiKey: 'your-api-key',
});

// Custom configuration
const client = new Anthropic({
  apiKey: 'your-api-key',
  baseURL: 'https://api.anthropic.com',
  timeout: 60 * 1000,  // 60 seconds
  maxRetries: 2,
});
```

## Messages API

### Creating Messages

```typescript
const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [
    { role: 'user', content: 'What is the capital of France?' }
  ],
});

console.log(message.content[0].text);
console.log(message.usage);
```

### With System Prompt

```typescript
const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  system: 'You are a helpful assistant that speaks like Shakespeare',
  messages: [
    { role: 'user', content: 'Hello, how are you?' }
  ],
});
```

### Multi-Turn Conversation

```typescript
const conversation: Anthropic.MessageParam[] = [];

// First turn
conversation.push({ role: 'user', content: "What's 2+2?" });
let response = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: conversation,
});
conversation.push({ role: 'assistant', content: response.content[0].text });

// Second turn
conversation.push({ role: 'user', content: "And 3+3?" });
response = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: conversation,
});
```

## Streaming

### Basic Streaming

```typescript
const stream = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Write a story' }],
  stream: true,
});

for await (const event of stream) {
  if (event.type === 'content_block_delta') {
    process.stdout.write(event.delta.text || '');
  }
}
```

### Stream Helpers

```typescript
const stream = client.messages.stream({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Write a story' }],
});

stream.on('text', (text) => {
  process.stdout.write(text);
});

stream.on('message', (message) => {
  console.log('\nFinal message:', message);
});

const message = await stream.finalMessage();
console.log(message.content[0].text);
```

## Vision (Images)

### Base64 Image

```typescript
import * as fs from 'fs';

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
```

### Image URL

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

## Tool Use (Function Calling)

### Defining Tools

```typescript
const tools: Anthropic.Tool[] = [
  {
    name: 'get_weather',
    description: 'Get the current weather in a given location',
    input_schema: {
      type: 'object',
      properties: {
        location: {
          type: 'string',
          description: 'The city and state, e.g. San Francisco, CA',
        },
        unit: {
          type: 'string',
          enum: ['celsius', 'fahrenheit'],
          description: 'The unit of temperature',
        },
      },
      required: ['location'],
    },
  },
];

const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  tools,
  messages: [{ role: 'user', content: "What's the weather in SF?" }],
});
```

### Handling Tool Use

```typescript
function processToolCall(toolName: string, toolInput: any) {
  if (toolName === 'get_weather') {
    return {
      location: toolInput.location,
      temperature: '72°F',
      condition: 'Sunny',
    };
  }
}

// Initial request
let response = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  tools,
  messages: [{ role: 'user', content: "What's the weather in SF?" }],
});

// Check if Claude wants to use a tool
if (response.stop_reason === 'tool_use') {
  const toolUse = response.content.find(
    (block): block is Anthropic.ToolUseBlock => block.type === 'tool_use'
  );

  if (toolUse) {
    const toolResult = processToolCall(toolUse.name, toolUse.input);

    response = await client.messages.create({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 1024,
      tools,
      messages: [
        { role: 'user', content: "What's the weather in SF?" },
        { role: 'assistant', content: response.content },
        {
          role: 'user',
          content: [
            {
              type: 'tool_result',
              tool_use_id: toolUse.id,
              content: JSON.stringify(toolResult),
            },
          ],
        },
      ],
    });
  }
}
```

## Prompt Caching

```typescript
const message = await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  system: [
    {
      type: 'text',
      text: 'You are an AI assistant...',
      cache_control: { type: 'ephemeral' },
    },
  ],
  messages: [{ role: 'user', content: 'Hello' }],
});

console.log('Cache creation:', message.usage.cache_creation_input_tokens);
console.log('Cache read:', message.usage.cache_read_input_tokens);
```

## Error Handling

```typescript
try {
  const message = await client.messages.create({
    model: 'claude-sonnet-4-5-20250929',
    max_tokens: 1024,
    messages: [{ role: 'user', content: 'Hello' }],
  });
} catch (error) {
  if (error instanceof Anthropic.APIError) {
    console.error(`API Error (${error.status}): ${error.message}`);
    console.error('Error type:', error.type);
    console.error('Request ID:', error.headers?.['request-id']);
  } else {
    console.error('Unexpected error:', error);
  }
}
```

## Complete Example

```typescript
import Anthropic from '@anthropic-ai/sdk';
import * as fs from 'fs';

class ClaudeAssistant {
  private client: Anthropic;
  private conversation: Anthropic.MessageParam[] = [];

  constructor() {
    this.client = new Anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY,
    });
  }

  async sendMessage(content: string): Promise<string> {
    this.conversation.push({ role: 'user', content });

    const response = await this.client.messages.create({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 2048,
      messages: this.conversation,
    });

    const assistantMessage = response.content[0].text;
    this.conversation.push({
      role: 'assistant',
      content: assistantMessage,
    });

    return assistantMessage;
  }

  async streamResponse(content: string): Promise<string> {
    this.conversation.push({ role: 'user', content });

    const stream = this.client.messages.stream({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 2048,
      messages: this.conversation,
    });

    let fullResponse = '';

    stream.on('text', (text) => {
      process.stdout.write(text);
      fullResponse += text;
    });

    await stream.finalMessage();
    console.log();

    this.conversation.push({
      role: 'assistant',
      content: fullResponse,
    });

    return fullResponse;
  }
}

// Usage
const assistant = new ClaudeAssistant();
const response = await assistant.sendMessage('Hello, Claude!');
console.log(response);
```

## Related Documentation

- [Getting Started](./02-getting-started.md)
- [Messages API Reference](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)
- [Streaming Guide](./06-streaming.md)
- [Vision Guide](./07-vision.md)
- [Tool Use Guide](./08-tool-use.md)
