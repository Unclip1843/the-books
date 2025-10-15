# OpenAI Platform - WebSocket Connection

**Source:** https://platform.openai.com/docs/guides/realtime/websocket
**Fetched:** 2025-10-11

## Overview

Connect to Realtime API using WebSocket for server-side applications.

---

## Setup

```python
import websocket
import json

# Connect to Realtime API
url = "wss://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview-2024-12-17"
headers = {
    "Authorization": f"Bearer {api_key}",
    "OpenAI-Beta": "realtime=v1"
}

ws = websocket.create_connection(url, header=headers)

# Send audio
audio_data = base64.b64encode(audio_bytes).decode()
ws.send(json.dumps({
    "type": "input_audio_buffer.append",
    "audio": audio_data
}))

# Receive response
response = json.loads(ws.recv())
```

---

**Source:** https://platform.openai.com/docs/guides/realtime/websocket
