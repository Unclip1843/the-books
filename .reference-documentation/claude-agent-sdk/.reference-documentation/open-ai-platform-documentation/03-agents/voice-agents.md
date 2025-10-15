# OpenAI Platform - Voice Agents

**Source:** https://platform.openai.com/docs/guides/voice-agents
**Fetched:** 2025-10-11

## Overview

Voice agents enable natural, real-time speech-to-speech interactions using OpenAI's Realtime API. With the `gpt-realtime` model and Voice Agents SDK, you can build production-ready voice assistants that support streaming audio, text, tool calls, and phone integration.

**Key Features:**
- End-to-end speech processing
- Ultra-low latency (< 300ms)
- Natural and expressive voices
- Tool calling during conversation
- Phone integration (SIP)
- Image input support

---

## GPT-Realtime Model

### Model Capabilities

The `gpt-realtime` model processes and generates audio directly through a single model, reducing latency and preserving speech nuance.

**Performance Benchmarks:**
- Big Bench Audio: 82.8% accuracy (up from 65.6%)
- MultiChallenge Audio: 30.5% (up from 20.6%)
- Complex instruction following
- Precise tool calling
- Natural, expressive speech

**Supported Features:**
- Streaming audio input/output
- Text generation
- Tool calling
- Image input
- Remote MCP server support
- Phone calling (SIP)

---

## Quick Start

### Installation

```bash
npm install @openai/agents
# or
npm install @openai/agents-realtime  # Standalone browser package
```

### Basic Voice Agent

```typescript
import { RealtimeAgent, RealtimeSession } from '@openai/agents/realtime';

// Create voice agent
const agent = new RealtimeAgent({
    name: "VoiceAssistant",
    instructions: "You are a helpful voice assistant.",
    model: "gpt-realtime",
    voice: "alloy",
    tools: [get_weather, search_knowledge_base]
});

// Start session
const session = new RealtimeSession({
    agent: agent,
    apiKey: process.env.OPENAI_API_KEY
});

// Connect and start listening
await session.connect();
await session.start();
```

---

## Transport Mechanisms

### WebRTC (Browser)

In the browser, the SDK uses WebRTC and automatically configures audio.

```typescript
// Browser implementation
import { RealtimeAgent, RealtimeSession } from '@openai/agents-realtime';

const agent = new RealtimeAgent({
    name: "BrowserVoiceAgent",
    model: "gpt-realtime",
    voice: "shimmer"
});

const session = new RealtimeSession({
    agent: agent,
    apiKey: API_KEY,
    transport: 'webrtc'  // Automatic in browser
});

// Automatically uses microphone and speakers
await session.connect();
await session.start();
```

### WebSocket (Server)

On backend servers, the SDK automatically uses WebSocket.

```typescript
// Node.js implementation
import { RealtimeAgent, RealtimeSession } from '@openai/agents/realtime';
import { OpenAIRealtimeWebSocket } from '@openai/agents/realtime/transports';

const agent = new RealtimeAgent({
    name: "ServerVoiceAgent",
    model: "gpt-realtime"
});

// WebSocket transport (manual audio handling)
const transport = new OpenAIRealtimeWebSocket({
    apiKey: process.env.OPENAI_API_KEY,
    model: "gpt-realtime"
});

const session = new RealtimeSession({
    agent: agent,
    transport: transport
});

// Handle audio manually
transport.on('audio', (audioData) => {
    // Process audio output
    sendToPhoneSystem(audioData);
});

// Send audio input
session.sendAudio(incomingAudioData);
```

---

## Voice Configuration

### Available Voices

```typescript
const voices = [
    'alloy',    // Neutral, balanced
    'echo',     // Male, authoritative
    'shimmer',  // Female, warm
    'ash',      // Male, calm
    'ballad',   // Female, expressive
    'coral',    // Female, friendly
    'sage',     // Male, thoughtful
    'verse'     // Male, conversational
];

const agent = new RealtimeAgent({
    name: "Assistant",
    model: "gpt-realtime",
    voice: "shimmer"  // Choose voice
});
```

### Voice Settings

```typescript
const agent = new RealtimeAgent({
    name: "Assistant",
    model: "gpt-realtime",
    voice: "alloy",
    voice_settings: {
        speed: 1.0,        // 0.5 - 2.0
        pitch: 1.0,        // 0.5 - 2.0
        stability: 0.8,    // 0.0 - 1.0 (higher = more consistent)
        style: "natural"   // natural, conversational, professional
    }
});
```

---

## Audio Processing

### Audio Formats

```typescript
// Supported formats
const audioConfig = {
    format: 'pcm16',        // Raw PCM16 audio
    sampleRate: 24000,      // 24kHz (default)
    channels: 1             // Mono
};

// Configure session
const session = new RealtimeSession({
    agent: agent,
    audioConfig: audioConfig
});
```

### Streaming Audio Input

```typescript
// Stream audio to agent
async function streamAudio(audioStream) {
    for await (const chunk of audioStream) {
        await session.sendAudio(chunk);
    }
}

// From microphone (browser)
const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
session.connectAudioStream(stream);

// From file
const audioBuffer = await fs.readFile('audio.wav');
await session.sendAudio(audioBuffer);
```

### Receiving Audio Output

```typescript
// Listen for audio output
session.on('audio', (audioData) => {
    // audioData is PCM16 audio buffer
    playAudio(audioData);
});

// With transcription
session.on('audio', (audioData, transcription) => {
    console.log('Agent said:', transcription.text);
    playAudio(audioData);
});
```

---

## Turn Detection

### Voice Activity Detection (VAD)

Automatically detect when user stops speaking.

```typescript
const session = new RealtimeSession({
    agent: agent,
    turnDetection: {
        type: 'server_vad',
        threshold: 0.5,           // Detection sensitivity
        prefix_padding_ms: 300,   // Include before speech
        silence_duration_ms: 500  // Wait before cutting off
    }
});

// Listen for turn events
session.on('turn:started', () => {
    console.log('User started speaking');
});

session.on('turn:ended', () => {
    console.log('User stopped speaking');
});
```

### Manual Turn Control

```typescript
// Disable automatic detection
const session = new RealtimeSession({
    agent: agent,
    turnDetection: {
        type: 'none'
    }
});

// Manually signal turns
session.startTurn();   // User starts speaking
session.endTurn();     // User done speaking
```

---

## Tool Calling

### Define Tools

```typescript
// Define tools for voice agent
const tools = [
    {
        name: "get_weather",
        description: "Get current weather for a location",
        parameters: {
            type: "object",
            properties: {
                location: {
                    type: "string",
                    description: "City name"
                }
            },
            required: ["location"]
        },
        execute: async (args) => {
            const weather = await fetchWeather(args.location);
            return {
                temperature: weather.temp,
                condition: weather.condition
            };
        }
    }
];

const agent = new RealtimeAgent({
    name: "WeatherAssistant",
    model: "gpt-realtime",
    tools: tools
});
```

### Tool Call Events

```typescript
// Listen for tool calls
session.on('tool:call', (toolCall) => {
    console.log(`Calling tool: ${toolCall.name}`);
    console.log('Arguments:', toolCall.arguments);
});

session.on('tool:result', (toolCall, result) => {
    console.log(`Tool ${toolCall.name} returned:`, result);
});
```

---

## Phone Integration (SIP)

### SIP Configuration

```typescript
import { RealtimeAgent, SIPTransport } from '@openai/agents/realtime';

// Configure SIP transport
const sipTransport = new SIPTransport({
    sipServer: 'sip.example.com',
    username: 'your-username',
    password: 'your-password',
    domain: 'example.com'
});

const agent = new RealtimeAgent({
    name: "PhoneAgent",
    model: "gpt-realtime",
    voice: "alloy"
});

const session = new RealtimeSession({
    agent: agent,
    transport: sipTransport
});

// Handle incoming calls
sipTransport.on('call:incoming', async (call) => {
    await session.connect(call);
    await session.start();
});
```

### Twilio Integration

```typescript
import twilio from 'twilio';

const client = twilio(ACCOUNT_SID, AUTH_TOKEN);

// Create TwiML for voice agent
app.post('/voice', (req, res) => {
    const twiml = new twilio.twiml.VoiceResponse();

    // Connect to WebSocket
    const connect = twiml.connect();
    connect.stream({
        url: 'wss://your-server.com/voice-agent',
    });

    res.type('text/xml');
    res.send(twiml.toString());
});

// WebSocket handler
wss.on('connection', async (ws) => {
    const session = new RealtimeSession({
        agent: agent,
        transport: new WebSocketTransport(ws)
    });

    await session.start();
});
```

---

## Image Input

### Send Images

```typescript
// Send image during conversation
await session.sendImage({
    type: 'url',
    url: 'https://example.com/image.jpg'
});

// Or base64
await session.sendImage({
    type: 'base64',
    data: base64ImageData,
    mimeType: 'image/jpeg'
});

// Agent can describe image
// User: "What's in this image?"
// Agent will analyze and respond with speech
```

---

## Session Management

### Session Events

```typescript
const session = new RealtimeSession({ agent });

// Connection events
session.on('connected', () => {
    console.log('Connected to Realtime API');
});

session.on('disconnected', () => {
    console.log('Disconnected');
});

// Conversation events
session.on('message', (message) => {
    console.log('Message:', message);
});

session.on('audio', (audio) => {
    playAudio(audio);
});

session.on('transcript', (text) => {
    console.log('Agent said:', text);
});

// Error handling
session.on('error', (error) => {
    console.error('Session error:', error);
});
```

### Session State

```typescript
// Get session state
const state = session.getState();
console.log('Status:', state.status);          // connected, disconnected
console.log('Active turn:', state.activeTurn); // user, agent
console.log('Duration:', state.durationMs);

// Pause/Resume
await session.pause();
await session.resume();

// End session
await session.disconnect();
```

---

## Converting Text Agents to Voice

### Simple Conversion

```typescript
// Existing text agent
import { Agent } from '@openai/agents';

const textAgent = new Agent({
    name: "TextAssistant",
    instructions: "You are helpful",
    model: "gpt-5",
    tools: [get_weather]
});

// Convert to voice agent
import { RealtimeAgent } from '@openai/agents/realtime';

const voiceAgent = new RealtimeAgent({
    name: textAgent.name,
    instructions: textAgent.instructions,
    model: "gpt-realtime",
    voice: "alloy",
    tools: textAgent.tools  // Same tools work!
});
```

---

## Advanced Features

### Interruption Handling

```typescript
const agent = new RealtimeAgent({
    name: "Assistant",
    model: "gpt-realtime",
    interruption: {
        enabled: true,
        threshold: 0.5  // How much user speech needed to interrupt
    }
});

// Listen for interruptions
session.on('interrupted', () => {
    console.log('Agent interrupted by user');
});
```

### Background Sounds

```typescript
const agent = new RealtimeAgent({
    name: "Assistant",
    model: "gpt-realtime",
    audio: {
        background_sound: 'office',  // office, cafe, none
        background_volume: 0.2       // 0.0 - 1.0
    }
});
```

### Conversation History

```typescript
// Access conversation history
const history = session.getHistory();

for (const turn of history) {
    console.log(`${turn.role}: ${turn.text}`);
}

// Save for later
const savedHistory = session.exportHistory();
localStorage.setItem('conversation', JSON.stringify(savedHistory));

// Restore
const restored = JSON.parse(localStorage.getItem('conversation'));
session.loadHistory(restored);
```

---

## Use Cases

### Customer Support

```typescript
const supportAgent = new RealtimeAgent({
    name: "SupportAgent",
    model: "gpt-realtime",
    voice: "shimmer",
    instructions: `
You are a customer support agent for Acme Corp.

Guidelines:
- Be friendly and helpful
- Verify customer identity before accessing account info
- Use tools to look up orders and account details
- Escalate to human if customer is upset
`,
    tools: [
        verify_customer,
        lookup_order,
        create_ticket,
        escalate_to_human
    ]
});
```

### Voice Shopping

```typescript
const shoppingAgent = new RealtimeAgent({
    name: "ShoppingAssistant",
    model: "gpt-realtime",
    voice: "coral",
    instructions: `
Help users shop for products.

- Ask about their needs
- Recommend products
- Show images of products
- Add items to cart
- Process checkout
`,
    tools: [
        search_products,
        show_product_image,
        add_to_cart,
        checkout
    ]
});
```

### Voice Navigation

```typescript
const navigationAgent = new RealtimeAgent({
    name: "NavigationAssistant",
    model: "gpt-realtime",
    voice: "sage",
    instructions: "Provide turn-by-turn navigation guidance",
    tools: [
        get_current_location,
        calculate_route,
        get_traffic,
        find_parking
    ]
});
```

---

## Best Practices

### 1. Clear Instructions

```typescript
// ✅ Good instructions for voice
const agent = new RealtimeAgent({
    instructions: `
You are a friendly restaurant booking assistant.

Speaking style:
- Keep responses under 20 seconds
- Speak naturally, don't use special characters
- Use "um" and "uh" sparingly for naturalness
- Confirm important details by repeating them
`,
    model: "gpt-realtime"
});
```

### 2. Handle Silence

```typescript
// Prompt user if silent too long
session.on('silence', (durationMs) => {
    if (durationMs > 5000) {
        session.speak("Are you still there? Let me know if you need help.");
    }
});
```

### 3. Manage Latency

```typescript
// Use streaming for faster responses
const agent = new RealtimeAgent({
    model: "gpt-realtime",
    streaming: true,  // Start speaking as soon as possible
    max_response_time_ms: 3000
});
```

### 4. Error Recovery

```typescript
session.on('error', async (error) => {
    console.error('Error:', error);

    // Speak error to user
    await session.speak("Sorry, I'm having technical difficulties. Let me try again.");

    // Attempt reconnection
    await session.reconnect();
});
```

---

## Additional Resources

- **Voice Agents SDK**: https://openai.github.io/openai-agents-js/guides/voice-agents/
- **Realtime API Guide**: https://platform.openai.com/docs/guides/realtime
- **gpt-realtime Announcement**: https://openai.com/index/introducing-gpt-realtime/
- **Voice Agent Examples**: https://cookbook.openai.com/examples/agents_sdk/app_assistant_voice_agents

---

**Next**: [Tools Overview →](../04-tools/overview.md)
