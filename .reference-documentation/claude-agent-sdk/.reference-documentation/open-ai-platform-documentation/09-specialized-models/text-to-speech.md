# OpenAI Platform - Text to Speech

**Source:** https://platform.openai.com/docs/guides/text-to-speech
**Fetched:** 2025-10-11

## Overview

Convert text to speech using TTS models.

---

## Generate Speech

```python
response = client.audio.speech.create(
    model="tts-1",  # or "tts-1-hd"
    voice="alloy",  # alloy, echo, fable, onyx, nova, shimmer
    input="Hello! Welcome to our service."
)

response.stream_to_file("output.mp3")
```

---

## Models

- **tts-1**: Fast, real-time
- **tts-1-hd**: Higher quality

---

## Voices

- alloy
- echo
- fable
- onyx
- nova
- shimmer

---

**Source:** https://platform.openai.com/docs/guides/text-to-speech
