# OpenAI Platform - Speech to Text

**Source:** https://platform.openai.com/docs/guides/speech-to-text
**Fetched:** 2025-10-11

## Overview

Transcribe audio using Whisper models.

---

## Transcribe Audio

```python
with open("audio.mp3", "rb") as audio_file:
    transcript = client.audio.transcriptions.create(
        model="whisper-1",
        file=audio_file,
        response_format="text"  # or "json", "srt", "vtt"
    )

print(transcript)
```

---

## Translation

```python
# Translate to English
with open("spanish.mp3", "rb") as audio_file:
    translation = client.audio.translations.create(
        model="whisper-1",
        file=audio_file
    )

print(translation.text)
```

---

**Source:** https://platform.openai.com/docs/guides/speech-to-text
