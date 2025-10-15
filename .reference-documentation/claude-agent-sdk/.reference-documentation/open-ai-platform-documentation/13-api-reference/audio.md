# OpenAI Platform - Audio API Reference

**Source:** https://platform.openai.com/docs/api-reference/audio
**Fetched:** 2025-10-11

## Create Transcription

**POST** `/v1/audio/transcriptions`

```python
client.audio.transcriptions.create(
    file=open("audio.mp3", "rb"),
    model="whisper-1",
    response_format="text"
)
```

## Create Translation

**POST** `/v1/audio/translations`

```python
client.audio.translations.create(
    file=open("audio.mp3", "rb"),
    model="whisper-1"
)
```

## Create Speech

**POST** `/v1/audio/speech`

```python
client.audio.speech.create(
    model="tts-1",
    voice="alloy",
    input="Hello world"
)
```

---

**Source:** https://platform.openai.com/docs/api-reference/audio
