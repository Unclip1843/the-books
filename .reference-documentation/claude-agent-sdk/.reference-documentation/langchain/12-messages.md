# LangChain - Messages

**Sources:**
- https://python.langchain.com/docs/concepts/messages/
- https://python.langchain.com/docs/how_to/chat_history/
- https://js.langchain.com/docs/concepts/messages/

**Fetched:** 2025-10-11

## What are Messages?

Messages are the fundamental unit of communication with chat models. Each message has:
- **Type/Role:** System, Human (User), AI (Assistant), Function, Tool
- **Content:** The actual message text or multimodal content
- **Metadata:** Additional information (optional)

## Message Types

### SystemMessage

Sets the behavior and context for the AI:

**Python:**
```python
from langchain_core.messages import SystemMessage

message = SystemMessage(content="You are a helpful AI assistant specialized in Python programming")
```

**TypeScript:**
```typescript
import { SystemMessage } from "@langchain/core/messages";

const message = new SystemMessage("You are a helpful AI assistant specialized in Python programming");
```

**When to use:**
- Define AI personality
- Set instructions
- Provide context
- Establish guardrails

### HumanMessage

Represents user input:

**Python:**
```python
from langchain_core.messages import HumanMessage

message = HumanMessage(content="How do I use list comprehensions in Python?")
```

**TypeScript:**
```typescript
import { HumanMessage } from "@langchain/core/messages";

const message = new HumanMessage("How do I use list comprehensions in Python?");
```

**When to use:**
- User questions
- User commands
- User-provided context

### AIMessage

Represents assistant responses:

**Python:**
```python
from langchain_core.messages import AIMessage

message = AIMessage(content="List comprehensions are a concise way to create lists in Python...")
```

**TypeScript:**
```typescript
import { AIMessage } from "@langchain/core/messages";

const message = new AIMessage("List comprehensions are a concise way to create lists in Python...");
```

**When to use:**
- Storing previous AI responses
- Building conversation history
- Few-shot examples

### FunctionMessage (Legacy)

Results from function calls:

**Python:**
```python
from langchain_core.messages import FunctionMessage

message = FunctionMessage(
    name="get_weather",
    content="Sunny, 72°F"
)
```

**Note:** FunctionMessage is legacy. Use ToolMessage for new code.

### ToolMessage

Results from tool calls:

**Python:**
```python
from langchain_core.messages import ToolMessage

message = ToolMessage(
    content="Search results: ...",
    tool_call_id="call_123"
)
```

**When to use:**
- Agent tool execution
- Function calling responses
- Structured tool outputs

## Message Construction

### Basic Messages

**Python:**
```python
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage

# System message
system = SystemMessage(content="You are a helpful assistant")

# Human message
human = HumanMessage(content="What is AI?")

# AI message
ai = AIMessage(content="AI stands for Artificial Intelligence...")
```

### With Metadata

**Python:**
```python
message = HumanMessage(
    content="Hello",
    additional_kwargs={
        "user_id": "123",
        "timestamp": "2024-01-15T10:30:00",
        "session_id": "abc"
    }
)

# Access metadata
print(message.additional_kwargs["user_id"])  # "123"
```

### Multimodal Messages

**Python:**
```python
from langchain_core.messages import HumanMessage

# Text + Image
message = HumanMessage(
    content=[
        {"type": "text", "text": "What's in this image?"},
        {
            "type": "image_url",
            "image_url": {"url": "https://example.com/image.jpg"}
        }
    ]
)

# Text + Multiple Images
message = HumanMessage(
    content=[
        {"type": "text", "text": "Compare these images"},
        {"type": "image_url", "image_url": {"url": "https://example.com/img1.jpg"}},
        {"type": "image_url", "image_url": {"url": "https://example.com/img2.jpg"}}
    ]
)
```

## Chat History

### Building Conversation History

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage

llm = ChatOpenAI()

# Conversation history
messages = [
    SystemMessage(content="You are a helpful assistant"),
    HumanMessage(content="Hi, I'm Alice"),
    AIMessage(content="Hello Alice! How can I help you today?"),
    HumanMessage(content="What's my name?")
]

response = llm.invoke(messages)
print(response.content)  # "Your name is Alice"
```

**TypeScript:**
```typescript
import { ChatOpenAI } from "@langchain/openai";
import { HumanMessage, AIMessage, SystemMessage } from "@langchain/core/messages";

const llm = new ChatOpenAI();

const messages = [
  new SystemMessage("You are a helpful assistant"),
  new HumanMessage("Hi, I'm Alice"),
  new AIMessage("Hello Alice! How can I help you today?"),
  new HumanMessage("What's my name?")
];

const response = await llm.invoke(messages);
console.log(response.content);
```

### Managing Conversation State

**Python:**
```python
class ConversationManager:
    def __init__(self, system_message: str):
        self.messages = [SystemMessage(content=system_message)]
        self.llm = ChatOpenAI()

    def send_message(self, user_input: str) -> str:
        # Add user message
        self.messages.append(HumanMessage(content=user_input))

        # Get AI response
        response = self.llm.invoke(self.messages)

        # Add AI response to history
        self.messages.append(AIMessage(content=response.content))

        return response.content

    def clear_history(self):
        # Keep only system message
        self.messages = self.messages[:1]

# Usage
conv = ConversationManager("You are a helpful assistant")

print(conv.send_message("Hi, I'm Bob"))
# "Hello Bob! How can I help you?"

print(conv.send_message("What's my name?"))
# "Your name is Bob"
```

### Trimming History

**Python:**
```python
from langchain_core.messages import trim_messages

messages = [
    SystemMessage(content="System prompt"),
    HumanMessage(content="Message 1"),
    AIMessage(content="Response 1"),
    HumanMessage(content="Message 2"),
    AIMessage(content="Response 2"),
    HumanMessage(content="Message 3"),
]

# Keep last 3 messages + system
trimmed = trim_messages(
    messages,
    max_tokens=100,
    strategy="last",
    token_counter=len  # Use actual token counter
)
```

### Sliding Window

Keep only recent messages:

**Python:**
```python
def get_recent_messages(messages, window_size=5):
    """Keep only last N messages (plus system message)"""
    system_messages = [m for m in messages if isinstance(m, SystemMessage)]
    recent = messages[-window_size:]
    return system_messages + recent

messages = [...]  # Long conversation
recent = get_recent_messages(messages, window_size=10)
```

## Message Formatting

### Convert to String

**Python:**
```python
from langchain_core.messages import HumanMessage

message = HumanMessage(content="Hello")

# Get content as string
print(message.content)  # "Hello"

# String representation
print(str(message))  # "content='Hello' additional_kwargs={}"
```

### Convert to Dict

**Python:**
```python
message = HumanMessage(
    content="Hello",
    additional_kwargs={"user_id": "123"}
)

# Convert to dictionary
message_dict = message.dict()
print(message_dict)
# {
#   'content': 'Hello',
#   'additional_kwargs': {'user_id': '123'},
#   'type': 'human'
# }
```

### From Dict

**Python:**
```python
from langchain_core.messages import messages_from_dict

message_dicts = [
    {"type": "human", "content": "Hello"},
    {"type": "ai", "content": "Hi there!"}
]

messages = messages_from_dict(message_dicts)
```

## Conversation Patterns

### Question-Answer

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage

llm = ChatOpenAI()

def qa_conversation(question: str, history: list = None):
    messages = [SystemMessage(content="You are a helpful assistant")]

    if history:
        messages.extend(history)

    messages.append(HumanMessage(content=question))

    response = llm.invoke(messages)
    return response.content

# First question
answer1 = qa_conversation("What is Python?")

# Follow-up with history
history = [
    HumanMessage(content="What is Python?"),
    AIMessage(content=answer1)
]
answer2 = qa_conversation("What are its main features?", history)
```

### Multi-Turn Dialogue

**Python:**
```python
class Chatbot:
    def __init__(self):
        self.llm = ChatOpenAI()
        self.history = [
            SystemMessage(content="You are a friendly chatbot")
        ]

    def chat(self, user_input: str) -> str:
        # Add user message
        self.history.append(HumanMessage(content=user_input))

        # Get response
        response = self.llm.invoke(self.history)

        # Store response
        self.history.append(AIMessage(content=response.content))

        return response.content

bot = Chatbot()
print(bot.chat("Hi!"))
print(bot.chat("Tell me a joke"))
print(bot.chat("Another one!"))
```

### Contextual Conversation

**Python:**
```python
def contextual_chat(user_input: str, context: str, history: list = None):
    messages = [
        SystemMessage(content=f"Context: {context}\n\nAnswer based on this context.")
    ]

    if history:
        messages.extend(history)

    messages.append(HumanMessage(content=user_input))

    llm = ChatOpenAI()
    response = llm.invoke(messages)

    return response.content

# Usage
context = "Our product is a cloud-based CRM system launched in 2020."
answer = contextual_chat("When was the product launched?", context)
```

## Message History Storage

### In-Memory

**Python:**
```python
class InMemoryHistory:
    def __init__(self):
        self.messages = []

    def add_message(self, message):
        self.messages.append(message)

    def get_messages(self):
        return self.messages

    def clear(self):
        self.messages = []

history = InMemoryHistory()
history.add_message(HumanMessage(content="Hello"))
```

### File-Based

**Python:**
```python
import json
from pathlib import Path
from langchain_core.messages import messages_from_dict, messages_to_dict

class FileHistory:
    def __init__(self, filepath: str):
        self.filepath = Path(filepath)
        self.messages = self._load()

    def _load(self):
        if self.filepath.exists():
            with open(self.filepath) as f:
                data = json.load(f)
                return messages_from_dict(data)
        return []

    def _save(self):
        with open(self.filepath, 'w') as f:
            json.dump(messages_to_dict(self.messages), f)

    def add_message(self, message):
        self.messages.append(message)
        self._save()

    def get_messages(self):
        return self.messages

history = FileHistory("chat_history.json")
```

### Database

**Python:**
```python
from langchain_community.chat_message_histories import SQLChatMessageHistory

history = SQLChatMessageHistory(
    session_id="user_123",
    connection_string="sqlite:///chat_history.db"
)

# Add messages
history.add_user_message("Hello")
history.add_ai_message("Hi there!")

# Get messages
messages = history.messages
```

## Best Practices

### 1. Always Include System Message

```python
# Good: Clear system context
messages = [
    SystemMessage(content="You are a helpful Python expert"),
    HumanMessage(content="Explain decorators")
]

# Avoid: No system context
messages = [
    HumanMessage(content="Explain decorators")
]
```

### 2. Manage History Length

```python
# Good: Limit history
def get_limited_history(messages, max_messages=20):
    system = [m for m in messages if isinstance(m, SystemMessage)]
    recent = [m for m in messages if not isinstance(m, SystemMessage)][-max_messages:]
    return system + recent

# Avoid: Unlimited history (expensive)
messages = all_messages  # Could be 1000s of messages
```

### 3. Use Appropriate Message Types

```python
# Good: Correct message types
messages = [
    SystemMessage(content="Instructions"),
    HumanMessage(content="User question"),
    AIMessage(content="AI response")
]

# Avoid: All as human messages
messages = [
    HumanMessage(content="System: Instructions"),  # Wrong
    HumanMessage(content="User: Question"),        # Wrong
]
```

### 4. Store Conversation Context

```python
# Good: Include relevant context
messages = [
    SystemMessage(content=f"User: {user_name}, Subscription: {sub_type}"),
    HumanMessage(content=user_input)
]

# Avoid: Missing context
messages = [
    HumanMessage(content=user_input)
]
```

### 5. Clear Metadata

```python
# Good: Useful metadata
message = HumanMessage(
    content="Hello",
    additional_kwargs={
        "user_id": "123",
        "timestamp": "2024-01-15",
        "language": "en"
    }
)
```

## Message Utilities

### Get Message Type

**Python:**
```python
from langchain_core.messages import HumanMessage, AIMessage

message = HumanMessage(content="Hello")

print(type(message).__name__)  # "HumanMessage"
print(isinstance(message, HumanMessage))  # True
```

### Filter Messages

**Python:**
```python
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage

messages = [
    SystemMessage(content="System"),
    HumanMessage(content="Hello"),
    AIMessage(content="Hi"),
    HumanMessage(content="Bye")
]

# Get only human messages
human_messages = [m for m in messages if isinstance(m, HumanMessage)]

# Get non-system messages
conversation = [m for m in messages if not isinstance(m, SystemMessage)]
```

### Merge Messages

**Python:**
```python
def merge_conversations(conv1, conv2):
    """Merge two conversations, keeping only one system message"""
    system = [m for m in conv1 if isinstance(m, SystemMessage)][:1]
    messages1 = [m for m in conv1 if not isinstance(m, SystemMessage)]
    messages2 = [m for m in conv2 if not isinstance(m, SystemMessage)]

    return system + messages1 + messages2
```

## Related Documentation

- [Prompt Templates](./11-prompt-templates.md)
- [Chat Models](./06-chat-models.md)
- [Memory](./36-memory-overview.md)
- [Conversation Memory](./38-conversation-memory.md)
