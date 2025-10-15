# OpenAI Platform - Conversation State Management

**Source:** https://platform.openai.com/docs/guides/conversation-state
**Fetched:** 2025-10-11

## Overview

The OpenAI API is stateless—each request is independent and doesn't remember previous interactions. This guide covers strategies for managing conversation history and context across multiple API calls.

**Key Concepts:**
- APIs are stateless by default
- You must manually maintain conversation history
- Context window limits require strategic management
- Different patterns for different use cases

---

## Understanding Stateless APIs

### How It Works

Unlike ChatGPT (which maintains conversation context), the API treats each request independently.

**What This Means:**

```python
# First request
response1 = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "My name is Alice"}]
)

# Second request (has NO memory of first!)
response2 = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "What's my name?"}]
)
# Response: "I don't have access to previous conversations..."
```

### Why Stateless?

**Benefits:**
- ✅ Scalability: No server-side state to manage
- ✅ Reliability: No session persistence required
- ✅ Flexibility: Full control over context
- ✅ Privacy: No automatic conversation storage

**Tradeoff:**
- ❌ Manual state management required
- ❌ Higher token usage (resending history)
- ❌ More complex application logic

---

## Basic Conversation State

### Maintaining Context

To maintain context, include previous messages in each request:

```python
from openai import OpenAI

client = OpenAI()
messages = []

def chat(user_message):
    """Chat with context preservation."""
    # Add user message
    messages.append({"role": "user", "content": user_message})

    # Send all messages
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=messages
    )

    # Add assistant response
    assistant_message = response.choices[0].message.content
    messages.append({"role": "assistant", "content": assistant_message})

    return assistant_message

# Usage
print(chat("My name is Alice"))        # Introduces self
print(chat("What's my name?"))         # Remembers: "Alice"
print(chat("What's my favorite color?"))  # No info yet
```

### Message Format

```python
messages = [
    {
        "role": "system",
        "content": "You are a helpful assistant."
    },
    {
        "role": "user",
        "content": "Hello!"
    },
    {
        "role": "assistant",
        "content": "Hi! How can I help you?"
    },
    {
        "role": "user",
        "content": "Tell me a joke."
    }
]
```

**Roles:**
- **system**: Instructions for assistant behavior (optional, typically first)
- **user**: User messages
- **assistant**: Assistant responses (previous messages)

---

## Context Window Management

### Understanding Limits

Different models have different context window sizes:

| Model | Context Window | Notes |
|-------|----------------|-------|
| gpt-4o | 128,000 tokens | ~96,000 words |
| gpt-4o-mini | 128,000 tokens | More cost-effective |
| gpt-4-turbo | 128,000 tokens | Older version |
| gpt-3.5-turbo | 16,385 tokens | ~12,000 words |

**Token Usage:**
```
Total tokens = System prompt + All messages + Response
```

### Counting Tokens

```python
import tiktoken

def count_tokens(messages, model="gpt-4o"):
    """Count tokens in message list."""
    encoding = tiktoken.encoding_for_model(model)

    tokens = 0
    for message in messages:
        # Each message has overhead: 4 tokens per message
        tokens += 4

        for key, value in message.items():
            tokens += len(encoding.encode(value))

    tokens += 2  # Every reply is primed with assistant tokens

    return tokens

# Usage
messages = [
    {"role": "system", "content": "You are helpful."},
    {"role": "user", "content": "Hello!"}
]

print(f"Tokens: {count_tokens(messages)}")
```

### Handling Window Limits

**Strategy 1: Truncate Old Messages**

```python
def truncate_conversation(messages, max_tokens=120000, model="gpt-4o"):
    """Keep only recent messages within token limit."""
    # Always keep system message
    system_message = [m for m in messages if m["role"] == "system"]
    conversation = [m for m in messages if m["role"] != "system"]

    # Remove oldest messages until under limit
    while count_tokens(system_message + conversation, model) > max_tokens:
        if len(conversation) > 2:  # Keep at least one exchange
            conversation.pop(0)  # Remove oldest message
        else:
            break

    return system_message + conversation

# Usage
if count_tokens(messages) > 120000:
    messages = truncate_conversation(messages)
```

**Strategy 2: Sliding Window**

```python
def sliding_window(messages, window_size=10):
    """Keep only last N messages plus system message."""
    system_messages = [m for m in messages if m["role"] == "system"]
    conversation = [m for m in messages if m["role"] != "system"]

    # Keep last N messages
    recent = conversation[-window_size:]

    return system_messages + recent

# Usage
messages = sliding_window(messages, window_size=20)
```

**Strategy 3: Summarization**

```python
def summarize_history(messages):
    """Summarize old conversation to save tokens."""
    # Separate system, old messages, recent messages
    system = [m for m in messages if m["role"] == "system"]
    conversation = [m for m in messages if m["role"] != "system"]

    if len(conversation) <= 10:
        return messages  # Too short to summarize

    # Messages to summarize
    old_messages = conversation[:-6]  # All but last 3 exchanges
    recent_messages = conversation[-6:]  # Last 3 exchanges

    # Create summary
    summary_prompt = {
        "role": "user",
        "content": f"Summarize this conversation concisely:\n\n{format_messages(old_messages)}"
    }

    summary_response = client.chat.completions.create(
        model="gpt-4o-mini",  # Use cheaper model
        messages=[summary_prompt]
    )

    summary = {
        "role": "system",
        "content": f"Previous conversation summary: {summary_response.choices[0].message.content}"
    }

    return system + [summary] + recent_messages

def format_messages(messages):
    """Format messages for summarization."""
    return "\n".join([
        f"{m['role']}: {m['content']}"
        for m in messages
    ])
```

**Strategy 4: Semantic Compression**

```python
def semantic_compression(messages, importance_threshold=0.7):
    """Keep only semantically important messages."""
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.metrics.pairwise import cosine_similarity

    # Extract content
    contents = [m["content"] for m in messages if m["role"] != "system"]

    # Calculate importance using TF-IDF
    vectorizer = TfidfVectorizer()
    tfidf_matrix = vectorizer.fit_transform(contents)

    # Calculate similarity to most recent message
    recent_vector = tfidf_matrix[-1]
    similarities = cosine_similarity(recent_vector, tfidf_matrix).flatten()

    # Keep system messages and important messages
    compressed = []
    for i, message in enumerate(messages):
        if message["role"] == "system":
            compressed.append(message)
        elif message["role"] != "system":
            idx = len([m for m in messages[:i] if m["role"] != "system"])
            if idx < len(similarities) and similarities[idx] >= importance_threshold:
                compressed.append(message)

    return compressed
```

---

## State Management Patterns

### Pattern 1: In-Memory State

**Best for:** Single-user applications, development

```python
class ConversationManager:
    def __init__(self):
        self.conversations = {}  # user_id -> messages

    def get_messages(self, user_id):
        """Get conversation for user."""
        if user_id not in self.conversations:
            self.conversations[user_id] = []
        return self.conversations[user_id]

    def add_message(self, user_id, role, content):
        """Add message to conversation."""
        messages = self.get_messages(user_id)
        messages.append({"role": role, "content": content})

    def chat(self, user_id, user_message):
        """Chat with context."""
        self.add_message(user_id, "user", user_message)

        response = client.chat.completions.create(
            model="gpt-4o",
            messages=self.get_messages(user_id)
        )

        assistant_message = response.choices[0].message.content
        self.add_message(user_id, "assistant", assistant_message)

        return assistant_message

# Usage
manager = ConversationManager()
manager.chat("user123", "Hello!")
manager.chat("user123", "What's my name?")  # Has context
```

### Pattern 2: Database State

**Best for:** Multi-user applications, persistence required

```python
import json
from datetime import datetime
import sqlite3

class DatabaseConversationManager:
    def __init__(self, db_path="conversations.db"):
        self.conn = sqlite3.connect(db_path)
        self.create_tables()

    def create_tables(self):
        """Create database tables."""
        self.conn.execute("""
            CREATE TABLE IF NOT EXISTS conversations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                role TEXT NOT NULL,
                content TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)
        self.conn.commit()

    def get_messages(self, user_id, limit=50):
        """Get recent messages for user."""
        cursor = self.conn.execute("""
            SELECT role, content
            FROM conversations
            WHERE user_id = ?
            ORDER BY timestamp DESC
            LIMIT ?
        """, (user_id, limit))

        messages = [
            {"role": row[0], "content": row[1]}
            for row in cursor.fetchall()
        ]

        return list(reversed(messages))  # Oldest first

    def add_message(self, user_id, role, content):
        """Save message to database."""
        self.conn.execute("""
            INSERT INTO conversations (user_id, role, content)
            VALUES (?, ?, ?)
        """, (user_id, role, content))
        self.conn.commit()

    def chat(self, user_id, user_message):
        """Chat with persistent context."""
        # Save user message
        self.add_message(user_id, "user", user_message)

        # Get conversation history
        messages = self.get_messages(user_id)

        # Get response
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=messages
        )

        # Save assistant message
        assistant_message = response.choices[0].message.content
        self.add_message(user_id, "assistant", assistant_message)

        return assistant_message

# Usage
manager = DatabaseConversationManager()
manager.chat("user123", "Hello!")
```

### Pattern 3: Redis State

**Best for:** Distributed applications, high performance

```python
import redis
import json

class RedisConversationManager:
    def __init__(self, redis_host='localhost', redis_port=6379):
        self.redis = redis.Redis(host=redis_host, port=redis_port)
        self.ttl = 3600  # 1 hour expiration

    def get_messages(self, user_id):
        """Get conversation from Redis."""
        key = f"conversation:{user_id}"
        data = self.redis.get(key)

        if data:
            return json.loads(data)
        return []

    def save_messages(self, user_id, messages):
        """Save conversation to Redis."""
        key = f"conversation:{user_id}"
        self.redis.setex(
            key,
            self.ttl,
            json.dumps(messages)
        )

    def chat(self, user_id, user_message):
        """Chat with Redis-backed context."""
        # Get current conversation
        messages = self.get_messages(user_id)

        # Add user message
        messages.append({"role": "user", "content": user_message})

        # Get response
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=messages
        )

        # Add assistant message
        assistant_message = response.choices[0].message.content
        messages.append({"role": "assistant", "content": assistant_message})

        # Save updated conversation
        self.save_messages(user_id, messages)

        return assistant_message

# Usage
manager = RedisConversationManager()
manager.chat("user123", "Hello!")
```

---

## Advanced Techniques

### Multi-Turn Conversations with Metadata

```python
class EnhancedConversation:
    def __init__(self):
        self.messages = []
        self.metadata = []  # Track metadata per message

    def add_message(self, role, content, **metadata):
        """Add message with metadata."""
        self.messages.append({"role": role, "content": content})
        self.metadata.append({
            "timestamp": datetime.now().isoformat(),
            "tokens": count_tokens([{"role": role, "content": content}]),
            **metadata
        })

    def get_stats(self):
        """Get conversation statistics."""
        return {
            "total_messages": len(self.messages),
            "total_tokens": sum(m["tokens"] for m in self.metadata),
            "duration": (
                datetime.fromisoformat(self.metadata[-1]["timestamp"]) -
                datetime.fromisoformat(self.metadata[0]["timestamp"])
            ).total_seconds() if len(self.metadata) > 1 else 0
        }

# Usage
conv = EnhancedConversation()
conv.add_message("user", "Hello!", user_id="user123")
print(conv.get_stats())
```

### Context Injection

```python
def inject_context(messages, context_data):
    """Dynamically inject context into conversation."""
    # Create enriched system message
    system_context = f"""
    You are a helpful assistant.

    User Information:
    - Name: {context_data.get('name')}
    - Location: {context_data.get('location')}
    - Preferences: {context_data.get('preferences')}

    Use this information when relevant to personalize responses.
    """

    # Replace or add system message
    system_message = {"role": "system", "content": system_context}

    # Remove existing system messages
    filtered = [m for m in messages if m["role"] != "system"]

    return [system_message] + filtered

# Usage
context = {
    "name": "Alice",
    "location": "San Francisco",
    "preferences": "Prefers concise answers"
}

enriched_messages = inject_context(messages, context)
```

### Session Management

```python
class SessionManager:
    def __init__(self, session_timeout=1800):  # 30 minutes
        self.sessions = {}
        self.session_timeout = session_timeout

    def get_or_create_session(self, user_id):
        """Get existing session or create new one."""
        if user_id in self.sessions:
            session = self.sessions[user_id]

            # Check if expired
            if (datetime.now() - session['last_activity']).seconds > self.session_timeout:
                # Session expired, create new
                return self.create_session(user_id)

            return session
        else:
            return self.create_session(user_id)

    def create_session(self, user_id):
        """Create new session."""
        session = {
            "user_id": user_id,
            "messages": [],
            "created_at": datetime.now(),
            "last_activity": datetime.now()
        }
        self.sessions[user_id] = session
        return session

    def update_activity(self, user_id):
        """Update last activity timestamp."""
        if user_id in self.sessions:
            self.sessions[user_id]['last_activity'] = datetime.now()

# Usage
session_manager = SessionManager(session_timeout=1800)
session = session_manager.get_or_create_session("user123")
```

---

## Best Practices

### 1. Set Appropriate Context Limits

```python
# Don't send entire conversation every time
MAX_CONTEXT_MESSAGES = 20  # Last 10 exchanges

def get_context(messages):
    """Get appropriate context size."""
    system = [m for m in messages if m["role"] == "system"]
    conversation = [m for m in messages if m["role"] != "system"]
    recent = conversation[-MAX_CONTEXT_MESSAGES:]
    return system + recent
```

### 2. Monitor Token Usage

```python
def chat_with_monitoring(messages, user_message):
    """Chat with token usage monitoring."""
    messages.append({"role": "user", "content": user_message})

    tokens_before = count_tokens(messages)

    if tokens_before > 120000:
        print("⚠️  Approaching context limit!")
        messages = truncate_conversation(messages)

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=messages
    )

    print(f"Tokens used: {response.usage.total_tokens}")

    return response
```

### 3. Implement Graceful Degradation

```python
def chat_with_fallback(messages, user_message):
    """Chat with fallback strategies."""
    messages.append({"role": "user", "content": user_message})

    try:
        # Try with full context
        return client.chat.completions.create(
            model="gpt-4o",
            messages=messages
        )
    except Exception as e:
        if "context_length_exceeded" in str(e):
            # Fallback: truncate and retry
            print("Context too long, truncating...")
            messages = truncate_conversation(messages, max_tokens=100000)
            return client.chat.completions.create(
                model="gpt-4o",
                messages=messages
            )
        raise
```

### 4. Separate System Instructions

```python
# Keep system message separate and reusable
SYSTEM_PROMPT = """
You are a helpful assistant for a customer service chatbot.
Be friendly, concise, and professional.
"""

def create_conversation(user_id):
    """Create new conversation with standard system prompt."""
    return [
        {"role": "system", "content": SYSTEM_PROMPT}
    ]
```

---

## Next Steps

1. **[Background Mode →](./background-mode.md)** - Handle long-running operations
2. **[Streaming →](./streaming.md)** - Real-time response streaming
3. **[Webhooks →](./webhooks.md)** - Event-driven updates
4. **[Batch API →](./batch-api.md)** - Process conversations in batch

---

## Additional Resources

- **OpenAI Cookbook**: https://cookbook.openai.com/
- **Token Counting**: https://github.com/openai/tiktoken
- **Context Summarization**: https://cookbook.openai.com/examples/context_summarization_with_realtime_api
- **Best Practices**: https://platform.openai.com/docs/guides/production-best-practices

---

**Next**: [Background Mode →](./background-mode.md)
