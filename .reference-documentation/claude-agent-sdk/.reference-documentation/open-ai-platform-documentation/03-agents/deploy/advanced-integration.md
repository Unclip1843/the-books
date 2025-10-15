# OpenAI Platform - Advanced Integration

**Source:** https://platform.openai.com/docs/guides/chatkit/advanced
**Fetched:** 2025-10-11

## Overview

Advanced integration patterns for deploying ChatKit with custom backends, authentication systems, and enterprise infrastructure.

---

## Custom Backend Integration

### Backend Architecture

```
Frontend (ChatKit)
    ↓ WebSocket/HTTP
Your Backend
    ↓ API
OpenAI Agent
```

### Backend Setup

```typescript
// backend/server.ts
import express from 'express';
import { OpenAI } from 'openai';

const app = express();
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

// Chat endpoint
app.post('/api/chat', async (req, res) => {
  const { message, userId, sessionId } = req.body;

  // Your business logic
  const user = await getUserFromDatabase(userId);
  const session = await getSessionFromDatabase(sessionId);

  // Call OpenAI
  const response = await openai.chat.completions.create({
    model: 'gpt-5',
    messages: [
      { role: 'system', content: getSystemPrompt(user) },
      ...session.messages,
      { role: 'user', content: message },
    ],
  });

  // Store response
  await saveToDatabase(sessionId, response);

  // Return to frontend
  res.json({
    message: response.choices[0].message.content,
    sessionId: sessionId,
  });
});

app.listen(3000);
```

### Frontend Configuration

```typescript
import { ChatKit } from '@openai/chatkit';

const chatkit = new ChatKit({
  backend: {
    url: 'https://your-backend.com/api/chat',
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${userToken}`,
    },
  },
  userId: 'user_123',
});
```

---

## Authentication

### JWT Authentication

```typescript
// Backend: Generate JWT
import jwt from 'jsonwebtoken';

app.post('/api/auth/chat-token', authenticateUser, (req, res) => {
  const token = jwt.sign(
    {
      userId: req.user.id,
      agentId: 'agent_abc123',
      permissions: req.user.permissions,
    },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );

  res.json({ token });
});

// Middleware to verify JWT
function verifyJWT(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
}

// Protected chat endpoint
app.post('/api/chat', verifyJWT, async (req, res) => {
  // User is authenticated via req.user
  ...
});
```

```typescript
// Frontend: Use JWT
const chatkit = new ChatKit({
  backend: {
    url: '/api/chat',
  },
  authenticate: async () => {
    const response = await fetch('/api/auth/chat-token');
    const { token } = await response.json();
    return token;
  },
  onAuthError: async () => {
    // Token expired, refresh
    const newToken = await refreshToken();
    return newToken;
  },
});
```

### OAuth Integration

```typescript
// Backend: OAuth flow
app.get('/auth/oauth/callback', async (req, res) => {
  const { code } = req.query;

  // Exchange code for tokens
  const tokens = await exchangeOAuthCode(code);

  // Create session
  const session = await createSession(tokens.userId);

  res.redirect(`/chat?session=${session.id}`);
});

// Frontend: OAuth login
function loginWithOAuth() {
  const oauthUrl = 'https://auth-provider.com/oauth/authorize?' +
    `client_id=${CLIENT_ID}&` +
    `redirect_uri=${REDIRECT_URI}&` +
    `response_type=code`;

  window.location.href = oauthUrl;
}
```

---

## WebSocket Integration

### Real-time Communication

```typescript
// Backend: WebSocket server
import { WebSocketServer } from 'ws';

const wss = new WebSocketServer({ port: 8080 });

wss.on('connection', (ws, req) => {
  const userId = getUserIdFromRequest(req);

  ws.on('message', async (message) => {
    const data = JSON.parse(message);

    // Process message
    const response = await processMessage(data, userId);

    // Send response
    ws.send(JSON.stringify(response));
  });

  ws.on('close', () => {
    console.log('Client disconnected');
  });
});
```

```typescript
// Frontend: WebSocket client
const chatkit = new ChatKit({
  backend: {
    type: 'websocket',
    url: 'wss://your-backend.com',
    reconnect: true,
    reconnectDelay: 1000,
  },
});
```

---

## Database Integration

### Session Persistence

```typescript
// Store conversation in database
import { prisma } from './db';

async function saveMessage(sessionId: string, message: any) {
  await prisma.message.create({
    data: {
      sessionId: sessionId,
      role: message.role,
      content: message.content,
      timestamp: new Date(),
    },
  });
}

async function getSessionHistory(sessionId: string) {
  const messages = await prisma.message.findMany({
    where: { sessionId },
    orderBy: { timestamp: 'asc' },
  });

  return messages.map(msg => ({
    role: msg.role,
    content: msg.content,
  }));
}

// Use in chat endpoint
app.post('/api/chat', async (req, res) => {
  const { sessionId, message } = req.body;

  // Load history
  const history = await getSessionHistory(sessionId);

  // Get response
  const response = await openai.chat.completions.create({
    model: 'gpt-5',
    messages: [...history, { role: 'user', content: message }],
  });

  // Save messages
  await saveMessage(sessionId, { role: 'user', content: message });
  await saveMessage(sessionId, {
    role: 'assistant',
    content: response.choices[0].message.content,
  });

  res.json({ message: response.choices[0].message.content });
});
```

---

## Enterprise Features

### Multi-Tenancy

```typescript
// Tenant isolation
app.post('/api/chat', authenticateUser, async (req, res) => {
  const tenantId = req.user.tenantId;

  // Load tenant-specific configuration
  const tenantConfig = await getTenantConfig(tenantId);

  // Use tenant-specific agent
  const response = await openai.chat.completions.create({
    model: tenantConfig.model,
    messages: [
      { role: 'system', content: tenantConfig.systemPrompt },
      ...req.body.messages,
    ],
  });

  // Log for tenant
  await logTenantUsage(tenantId, response.usage);

  res.json(response);
});
```

### Custom Domain

```typescript
// Serve ChatKit from custom domain
app.use('/chat', express.static('chatkit-dist'));

// Configure CORS
app.use(cors({
  origin: 'https://chat.yourdomain.com',
  credentials: true,
}));
```

### SSO Integration

```typescript
// SAML SSO
import { SAMLStrategy } from 'passport-saml';

passport.use(new SAMLStrategy(
  {
    entryPoint: 'https://sso.company.com/saml',
    issuer: 'your-app',
    callbackUrl: 'https://your-app.com/auth/saml/callback',
  },
  async (profile, done) => {
    const user = await findOrCreateUser(profile);
    return done(null, user);
  }
));

// Protect chat endpoint
app.post('/api/chat',
  passport.authenticate('saml', { session: false }),
  async (req, res) => {
    // User authenticated via SAML
    ...
  }
);
```

---

## Load Balancing

### Horizontal Scaling

```typescript
// Load balancer configuration (nginx)
upstream chatkit_backend {
  least_conn;
  server backend1.example.com:3000;
  server backend2.example.com:3000;
  server backend3.example.com:3000;
}

server {
  listen 80;
  server_name chat.example.com;

  location /api/chat {
    proxy_pass http://chatkit_backend;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
```

### Session Affinity

```typescript
// Backend: Use session tokens for affinity
import { createHash } from 'crypto';

function getServerForSession(sessionId: string) {
  const servers = ['server1', 'server2', 'server3'];
  const hash = createHash('md5').update(sessionId).digest('hex');
  const index = parseInt(hash.slice(0, 8), 16) % servers.length;
  return servers[index];
}
```

---

## Caching

### Response Caching

```typescript
import Redis from 'ioredis';

const redis = new Redis();

app.post('/api/chat', async (req, res) => {
  const { message } = req.body;

  // Check cache
  const cacheKey = `chat:${hashMessage(message)}`;
  const cached = await redis.get(cacheKey);

  if (cached) {
    return res.json(JSON.parse(cached));
  }

  // Get response
  const response = await openai.chat.completions.create({
    model: 'gpt-5',
    messages: [{ role: 'user', content: message }],
  });

  // Cache for 1 hour
  await redis.setex(cacheKey, 3600, JSON.stringify(response));

  res.json(response);
});
```

---

## Monitoring & Analytics

### Request Tracking

```typescript
import { v4 as uuidv4 } from 'uuid';

app.use((req, res, next) => {
  req.id = uuidv4();
  req.startTime = Date.now();
  next();
});

app.post('/api/chat', async (req, res) => {
  try {
    const response = await openai.chat.completions.create({...});

    // Log metrics
    await logMetrics({
      requestId: req.id,
      duration: Date.now() - req.startTime,
      tokens: response.usage.total_tokens,
      model: 'gpt-5',
      userId: req.user.id,
    });

    res.json(response);
  } catch (error) {
    // Log error
    await logError({
      requestId: req.id,
      error: error.message,
      userId: req.user.id,
    });

    res.status(500).json({ error: 'Internal error' });
  }
});
```

### Analytics Dashboard

```typescript
// Analytics endpoint
app.get('/api/analytics', async (req, res) => {
  const { startDate, endDate } = req.query;

  const analytics = await db.query(`
    SELECT
      DATE(timestamp) as date,
      COUNT(*) as total_requests,
      AVG(duration) as avg_duration,
      SUM(tokens) as total_tokens
    FROM chat_logs
    WHERE timestamp BETWEEN $1 AND $2
    GROUP BY DATE(timestamp)
  `, [startDate, endDate]);

  res.json(analytics);
});
```

---

## Rate Limiting

### API Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

const chatRateLimit = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 20, // 20 requests per minute
  message: 'Too many requests, please try again later',
  keyGenerator: (req) => req.user.id, // Per user
});

app.post('/api/chat', chatRateLimit, async (req, res) => {
  ...
});
```

### Token-Based Limiting

```typescript
// Track token usage
const userTokenUsage = new Map();

app.post('/api/chat', async (req, res) => {
  const userId = req.user.id;
  const usage = userTokenUsage.get(userId) || { tokens: 0, resetAt: Date.now() };

  // Reset if window expired
  if (Date.now() > usage.resetAt) {
    usage.tokens = 0;
    usage.resetAt = Date.now() + 3600000; // 1 hour
  }

  // Check limit
  if (usage.tokens > 100000) {
    return res.status(429).json({ error: 'Token limit exceeded' });
  }

  // Get response
  const response = await openai.chat.completions.create({...});

  // Update usage
  usage.tokens += response.usage.total_tokens;
  userTokenUsage.set(userId, usage);

  res.json(response);
});
```

---

## Security Hardening

### Input Sanitization

```typescript
import DOMPurify from 'isomorphic-dompurify';

app.post('/api/chat', async (req, res) => {
  // Sanitize user input
  const sanitizedMessage = DOMPurify.sanitize(req.body.message, {
    ALLOWED_TAGS: [],
    ALLOWED_ATTR: [],
  });

  // Validate length
  if (sanitizedMessage.length > 10000) {
    return res.status(400).json({ error: 'Message too long' });
  }

  // Process message
  ...
});
```

### Content Security Policy

```typescript
app.use((req, res, next) => {
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; " +
    "script-src 'self' https://cdn.openai.com; " +
    "style-src 'self' 'unsafe-inline' https://cdn.openai.com; " +
    "connect-src 'self' https://api.openai.com;"
  );
  next();
});
```

---

## Testing

### Integration Tests

```typescript
import request from 'supertest';
import { app } from './server';

describe('Chat API', () => {
  it('should return chat response', async () => {
    const response = await request(app)
      .post('/api/chat')
      .set('Authorization', `Bearer ${testToken}`)
      .send({
        message: 'Hello',
        sessionId: 'test_session',
      });

    expect(response.status).toBe(200);
    expect(response.body.message).toBeDefined();
  });

  it('should reject unauthorized requests', async () => {
    const response = await request(app)
      .post('/api/chat')
      .send({ message: 'Hello' });

    expect(response.status).toBe(401);
  });

  it('should handle rate limiting', async () => {
    // Send 21 requests (limit is 20)
    for (let i = 0; i < 21; i++) {
      const response = await request(app)
        .post('/api/chat')
        .set('Authorization', `Bearer ${testToken}`)
        .send({ message: `Message ${i}` });

      if (i < 20) {
        expect(response.status).toBe(200);
      } else {
        expect(response.status).toBe(429);
      }
    }
  });
});
```

---

## Additional Resources

- **Backend Examples**: https://github.com/openai/openai-chatkit-advanced-samples
- **Security Guide**: https://platform.openai.com/docs/guides/security
- **Enterprise Solutions**: https://openai.com/enterprise

---

**Next**: [Agent Evals →](../optimize/agent-evals.md)
