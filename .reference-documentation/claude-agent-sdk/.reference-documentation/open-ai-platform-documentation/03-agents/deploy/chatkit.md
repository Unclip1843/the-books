# OpenAI Platform - ChatKit

**Source:** https://platform.openai.com/docs/guides/chatkit
**Fetched:** 2025-10-11

## Overview

ChatKit is a framework-agnostic, drop-in chat solution for embedding chat-based agents into your applications. It provides a complete UI with tool visualization, rich widgets, and seamless integration.

**GitHub**: https://github.com/openai/chatkit-js
**Documentation**: https://openai.github.io/chatkit-js/

---

## Key Features

### Tool & Workflow Integration

Visualize agentic actions and chain-of-thought reasoning:
- Real-time tool execution display
- Progress indicators
- Step-by-step reasoning view

### Rich Interactive Widgets

Render interactive components directly in chat:
- Forms and inputs
- Charts and visualizations
- Buttons and actions
- Custom components

### Attachment Handling

Support for file and image uploads:
- Drag-and-drop interface
- Image preview
- File management
- Progress tracking

### Thread Management

Organize complex conversations:
- Multiple conversation threads
- Thread switching
- Thread history
- Search within threads

### Source Annotations

Transparency and references:
- Citation tracking
- Source highlighting
- Entity tagging
- Confidence indicators

---

## Installation

### NPM

```bash
npm install @openai/chatkit
```

### CDN

```html
<script src="https://cdn.openai.com/chatkit/chatkit.min.js"></script>
<link rel="stylesheet" href="https://cdn.openai.com/chatkit/chatkit.css">
```

---

## Quick Start

### React

```tsx
import { ChatKit } from '@openai/chatkit';

function App() {
  return (
    <ChatKit
      agentId="agent_abc123"
      apiKey={process.env.OPENAI_API_KEY}
      userId="user_123"
    />
  );
}
```

### Web Component

```html
<div id="chatkit-container"></div>

<script>
  ChatKit.mount('#chatkit-container', {
    agentId: 'agent_abc123',
    apiKey: 'YOUR_API_KEY',
    userId: 'user_123'
  });
</script>
```

### Vanilla JavaScript

```javascript
import { ChatKit } from '@openai/chatkit';

const chatkit = new ChatKit({
  container: document.getElementById('chat-container'),
  agentId: 'agent_abc123',
  apiKey: 'YOUR_API_KEY',
  userId: 'user_123'
});

chatkit.render();
```

---

## Configuration

### Basic Configuration

```typescript
const config = {
  // Required
  agentId: 'agent_abc123',
  apiKey: 'sk-...',
  userId: 'user_123',

  // Optional
  theme: 'light' | 'dark' | 'auto',
  placeholder: 'Ask me anything...',
  welcomeMessage: 'Hello! How can I help?',
  showTimestamps: true,
  enableFileUpload: true,
  enableImageUpload: true,
  maxFileSize: 10 * 1024 * 1024, // 10MB
  allowedFileTypes: ['.pdf', '.txt', '.docx'],
};

const chatkit = new ChatKit(config);
```

### Theme Configuration

```typescript
const theme = {
  mode: 'light',
  colors: {
    primary: '#10a37f',
    secondary: '#6e6e80',
    background: '#ffffff',
    surface: '#f7f7f8',
    text: '#202123',
    textSecondary: '#6e6e80',
    border: '#e5e5e5',
    error: '#ef4444',
    success: '#10a37f',
  },
  fonts: {
    body: "'Inter', sans-serif",
    mono: "'Roboto Mono', monospace",
  },
  borderRadius: 8,
  spacing: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
  },
};

const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  apiKey: 'sk-...',
  theme: theme,
});
```

---

## Deployment Patterns

### 1. Recommended (Hosted by OpenAI)

OpenAI hosts and scales everything:

```tsx
import { ChatKit } from '@openai/chatkit';

function App() {
  return (
    <ChatKit
      agentId="agent_abc123"  // Created in Agent Builder
      apiKey={process.env.OPENAI_API_KEY}
    />
  );
}
```

**Benefits**:
- No backend required
- Automatic scaling
- Built-in security
- Easy maintenance

### 2. Advanced (Self-Hosted)

Host ChatKit on your infrastructure:

```typescript
import { ChatKit, ChatKitBackend } from '@openai/chatkit';

// Your backend
const backend = new ChatKitBackend({
  apiEndpoint: 'https://your-api.com/chat',
  authToken: 'your-auth-token',
});

// ChatKit with custom backend
const chatkit = new ChatKit({
  backend: backend,
  userId: 'user_123',
});
```

**Benefits**:
- Full control
- Custom business logic
- Data sovereignty
- Integration flexibility

---

## Messages

### Text Messages

```typescript
// Send message
await chatkit.sendMessage('Hello!');

// Get messages
const messages = chatkit.getMessages();

// Listen for new messages
chatkit.on('message', (message) => {
  console.log('New message:', message);
});
```

### Rich Messages

```typescript
// Message with formatting
await chatkit.sendMessage({
  text: '**Bold** and *italic* text',
  format: 'markdown',
});

// Message with metadata
await chatkit.sendMessage({
  text: 'Order confirmed',
  metadata: {
    orderId: '12345',
    status: 'confirmed',
  },
});
```

---

## Attachments

### File Upload

```typescript
// Enable file upload
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  apiKey: 'sk-...',
  enableFileUpload: true,
  maxFileSize: 10 * 1024 * 1024,  // 10MB
  allowedFileTypes: ['.pdf', '.txt', '.docx'],
});

// Programmatic upload
const file = document.getElementById('file-input').files[0];
await chatkit.uploadFile(file);

// Listen for uploads
chatkit.on('fileUploaded', (file) => {
  console.log('Uploaded:', file.name);
});
```

### Image Upload

```typescript
// Enable image upload
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  apiKey: 'sk-...',
  enableImageUpload: true,
  maxImageSize: 5 * 1024 * 1024,  // 5MB
  imagePreview: true,
});

// Upload image
const image = document.getElementById('image-input').files[0];
await chatkit.uploadImage(image);
```

---

## Widgets

### Built-in Widgets

ChatKit supports interactive widgets:

```typescript
// Button widget
{
  type: 'button',
  text: 'Confirm Order',
  action: 'confirm_order',
  style: 'primary'
}

// Form widget
{
  type: 'form',
  fields: [
    { name: 'email', type: 'email', required: true },
    { name: 'phone', type: 'tel', required: false }
  ],
  submitLabel: 'Subscribe'
}

// Chart widget
{
  type: 'chart',
  chartType: 'line',
  data: [...],
  options: {...}
}

// Card widget
{
  type: 'card',
  title: 'Product Name',
  description: 'Description...',
  image: 'https://...',
  actions: [
    { label: 'Buy Now', action: 'purchase' }
  ]
}
```

### Custom Widgets

```typescript
// Register custom widget
chatkit.registerWidget('custom-widget', {
  render: (data) => {
    return `
      <div class="custom-widget">
        <h3>${data.title}</h3>
        <p>${data.content}</p>
      </div>
    `;
  },
  handlers: {
    click: (event, data) => {
      console.log('Widget clicked:', data);
    },
  },
});

// Use custom widget
await chatkit.sendMessage({
  text: 'Check this out:',
  widget: {
    type: 'custom-widget',
    data: {
      title: 'Custom Widget',
      content: 'This is a custom widget',
    },
  },
});
```

---

## Events

### Message Events

```typescript
// New message received
chatkit.on('message', (message) => {
  console.log('Message:', message);
});

// Message sent
chatkit.on('messageSent', (message) => {
  console.log('Sent:', message);
});

// Typing indicator
chatkit.on('typing', (isTyping) => {
  console.log('Agent typing:', isTyping);
});
```

### State Events

```typescript
// Connection state
chatkit.on('connected', () => {
  console.log('Connected');
});

chatkit.on('disconnected', () => {
  console.log('Disconnected');
});

// Error handling
chatkit.on('error', (error) => {
  console.error('Error:', error);
});
```

### Tool Events

```typescript
// Tool execution started
chatkit.on('toolStart', (tool) => {
  console.log('Tool started:', tool.name);
});

// Tool execution completed
chatkit.on('toolComplete', (tool, result) => {
  console.log('Tool completed:', tool.name, result);
});

// Tool execution failed
chatkit.on('toolError', (tool, error) => {
  console.error('Tool error:', tool.name, error);
});
```

---

## Thread Management

### Multiple Threads

```typescript
// Create new thread
const thread = await chatkit.createThread({
  title: 'Project Discussion',
  metadata: { projectId: '123' },
});

// Switch threads
await chatkit.switchThread(thread.id);

// List threads
const threads = await chatkit.getThreads();

// Delete thread
await chatkit.deleteThread(thread.id);
```

### Thread Persistence

```typescript
// Save thread state
const state = chatkit.getThreadState();
localStorage.setItem('chat-state', JSON.stringify(state));

// Restore thread state
const savedState = JSON.parse(localStorage.getItem('chat-state'));
chatkit.restoreThreadState(savedState);
```

---

## Authentication

### API Key Authentication

```typescript
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  apiKey: process.env.OPENAI_API_KEY,  // Never expose in frontend
  userId: 'user_123',
});
```

### JWT Authentication

```typescript
// Backend generates JWT
const jwt = generateJWT({
  userId: 'user_123',
  agentId: 'agent_abc123',
  permissions: ['chat', 'upload'],
});

// Frontend uses JWT
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  authToken: jwt,
  userId: 'user_123',
});
```

### Custom Authentication

```typescript
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  authenticate: async () => {
    const response = await fetch('/api/chat-token');
    const { token } = await response.json();
    return token;
  },
});
```

---

## Styling

### CSS Variables

```css
:root {
  --chatkit-primary: #10a37f;
  --chatkit-background: #ffffff;
  --chatkit-text: #202123;
  --chatkit-border: #e5e5e5;
  --chatkit-border-radius: 8px;
  --chatkit-spacing: 16px;
  --chatkit-font-family: 'Inter', sans-serif;
}
```

### Custom CSS

```css
/* Override message styles */
.chatkit-message {
  padding: 12px 16px;
  border-radius: 8px;
}

.chatkit-message-user {
  background-color: #10a37f;
  color: white;
}

.chatkit-message-agent {
  background-color: #f7f7f8;
  color: #202123;
}

/* Override input styles */
.chatkit-input {
  border: 2px solid #e5e5e5;
  border-radius: 8px;
  padding: 12px;
  font-size: 14px;
}
```

---

## Advanced Features

### Streaming Responses

```typescript
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  apiKey: 'sk-...',
  streaming: true,
});

// Listen for streaming chunks
chatkit.on('messageChunk', (chunk) => {
  console.log('Chunk:', chunk.text);
});
```

### Custom Renderers

```typescript
// Custom message renderer
chatkit.setMessageRenderer((message) => {
  if (message.type === 'code') {
    return `
      <pre><code class="language-${message.language}">
        ${message.content}
      </code></pre>
    `;
  }
  return message.content;
});
```

### Analytics Integration

```typescript
chatkit.on('message', (message) => {
  // Track with your analytics
  analytics.track('Chat Message', {
    userId: message.userId,
    messageLength: message.content.length,
    timestamp: message.timestamp,
  });
});
```

---

## Best Practices

### 1. Security

```typescript
// ❌ Never expose API key in frontend
const chatkit = new ChatKit({
  apiKey: 'sk-...',  // Exposed!
});

// ✅ Use backend proxy
const chatkit = new ChatKit({
  backend: {
    url: '/api/chat',  // Your secure backend
  },
});
```

### 2. Performance

```typescript
// Enable message pagination
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  pagination: {
    enabled: true,
    pageSize: 20,
  },
});

// Lazy load attachments
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  lazyLoadAttachments: true,
});
```

### 3. Accessibility

```typescript
const chatkit = new ChatKit({
  agentId: 'agent_abc123',
  accessibility: {
    announceMessages: true,
    keyboardNavigation: true,
    highContrast: false,
  },
});
```

---

## Troubleshooting

### Common Issues

**ChatKit not rendering**:
- Verify container exists
- Check API key validity
- Review browser console for errors

**Messages not sending**:
- Check network connectivity
- Verify agent ID
- Ensure proper authentication

**Styling conflicts**:
- Use CSS isolation
- Adjust z-index values
- Check for conflicting styles

---

## Additional Resources

- **ChatKit Docs**: https://openai.github.io/chatkit-js/
- **GitHub**: https://github.com/openai/chatkit-js
- **Starter App**: https://github.com/openai/openai-chatkit-starter-app
- **Advanced Samples**: https://github.com/openai/openai-chatkit-advanced-samples

---

**Next**: [Custom Theming →](./custom-theming.md)
