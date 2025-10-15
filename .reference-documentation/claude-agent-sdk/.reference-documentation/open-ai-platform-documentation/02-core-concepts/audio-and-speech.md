# OpenAI Platform - Audio and Speech

**Source:** https://platform.openai.com/docs/guides/audio
**Fetched:** 2025-10-11

## Overview

OpenAI provides two main audio APIs:
- **Speech-to-Text** (Whisper): Transcribe and translate audio
- **Text-to-Speech** (TTS): Generate natural-sounding speech

---

## Speech-to-Text (Whisper)

Convert audio to text with OpenAI's Whisper models.

### Quick Start

```python
from openai import OpenAI

client = OpenAI()

audio_file = open("speech.mp3", "rb")

transcription = client.audio.transcriptions.create(
    model="whisper-1",
    file=audio_file
)

print(transcription.text)
```

### Supported Models

| Model | Languages | Max File Size |
|-------|-----------|---------------|
| whisper-1 | 95+ | 25 MB |
| whisper-large-v3 | 95+ | 25 MB |
| gpt-4o-transcribe | 95+ | 25 MB |

---

## Transcription

Convert audio in any supported language to text.

### Basic Transcription

```python
transcription = client.audio.transcriptions.create(
    model="whisper-1",
    file=audio_file
)

print(transcription.text)
# Output: "Hello, how are you today?"
```

### With Prompts

Provide context to improve accuracy:

```python
transcription = client.audio.transcriptions.create(
    model="whisper-1",
    file=audio_file,
    prompt="This is a medical consultation about diabetes treatment."
)
```

### Response Formats

```python
# JSON (default)
transcription = client.audio.transcriptions.create(
    model="whisper-1",
    file=audio_file,
    response_format="json"
)

# Verbose JSON (includes timestamps)
transcription = client.audio.transcriptions.create(
    model="whisper-1",
    file=audio_file,
    response_format="verbose_json"
)

# Text only
transcription = client.audio.transcriptions.create(
    model="whisper-1",
    file=audio_file,
    response_format="text"
)

# SRT subtitles
transcription = client.audio.transcriptions.create(
    model="whisper-1",
    file=audio_file,
    response_format="srt"
)

# VTT subtitles
transcription = client.audio.transcriptions.create(
    model="whisper-1",
    file=audio_file,
    response_format="vtt"
)
```

### Timestamps

Get word-level or segment-level timestamps:

```python
transcription = client.audio.transcriptions.create(
    model="whisper-1",
    file=audio_file,
    response_format="verbose_json",
    timestamp_granularities=["word", "segment"]
)

# Access segments
for segment in transcription.segments:
    print(f"[{segment['start']:.2f}s - {segment['end']:.2f}s]: {segment['text']}")

# Access words
for word in transcription.words:
    print(f"{word['word']} ({word['start']:.2f}s)")
```

---

## Translation

Translate audio in any language to English.

```python
translation = client.audio.translations.create(
    model="whisper-1",
    file=audio_file
)

print(translation.text)
# Input: French audio
# Output: "Hello, how are you today?" (English)
```

---

## Supported Audio Formats

- **MP3**
- **MP4**
- **MPEG**
- **MPGA**
- **M4A**
- **WAV**
- **WEBM**

**Max file size**: 25 MB

### Handling Large Files

```python
from pydub import AudioSegment

def split_audio(file_path, chunk_length_ms=10*60*1000):  # 10 minutes
    """Split audio into chunks."""
    audio = AudioSegment.from_file(file_path)
    chunks = []

    for i in range(0, len(audio), chunk_length_ms):
        chunk = audio[i:i + chunk_length_ms]
        chunk_path = f"chunk_{i//chunk_length_ms}.mp3"
        chunk.export(chunk_path, format="mp3")
        chunks.append(chunk_path)

    return chunks

def transcribe_long_audio(file_path):
    """Transcribe audio longer than 25MB."""
    chunks = split_audio(file_path)
    full_transcription = ""

    for chunk_path in chunks:
        with open(chunk_path, "rb") as audio_file:
            transcription = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file
            )
            full_transcription += transcription.text + " "

    return full_transcription.strip()
```

---

## Text-to-Speech (TTS)

Generate natural-sounding speech from text.

### Quick Start

```python
from pathlib import Path

speech_file_path = Path(__file__).parent / "speech.mp3"

response = client.audio.speech.create(
    model="tts-1",
    voice="alloy",
    input="Hello! This is a test of the text to speech API."
)

response.stream_to_file(speech_file_path)
```

### Available Models

| Model | Quality | Speed | Cost |
|-------|---------|-------|------|
| tts-1 | Standard | Fastest | $15/1M chars |
| tts-1-hd | High | Slower | $30/1M chars |
| gpt-4o-mini-tts | Steerable | Fast | Varies |

### Available Voices

- **alloy**: Neutral, balanced
- **echo**: Male, clear
- **fable**: British male, expressive
- **onyx**: Deep male
- **nova**: Female, friendly
- **shimmer**: Female, warm

```python
# Try different voices
for voice in ["alloy", "echo", "fable", "onyx", "nova", "shimmer"]:
    response = client.audio.speech.create(
        model="tts-1",
        voice=voice,
        input="Hello, this is a test."
    )
    response.stream_to_file(f"speech_{voice}.mp3")
```

### Audio Formats

```python
# Opus (default, best for streaming)
response = client.audio.speech.create(
    model="tts-1",
    voice="alloy",
    input="Hello!",
    response_format="opus"
)

# MP3 (widely compatible)
response = client.audio.speech.create(
    model="tts-1",
    voice="alloy",
    input="Hello!",
    response_format="mp3"
)

# AAC (good quality, smaller)
response = client.audio.speech.create(
    model="tts-1",
    voice="alloy",
    input="Hello!",
    response_format="aac"
)

# FLAC (lossless)
response = client.audio.speech.create(
    model="tts-1",
    voice="alloy",
    input="Hello!",
    response_format="flac"
)

# WAV (uncompressed)
response = client.audio.speech.create(
    model="tts-1",
    voice="alloy",
    input="Hello!",
    response_format="wav"
)

# PCM (raw audio)
response = client.audio.speech.create(
    model="tts-1",
    voice="alloy",
    input="Hello!",
    response_format="pcm"
)
```

### Speed Control

```python
response = client.audio.speech.create(
    model="tts-1",
    voice="alloy",
    input="This will be spoken faster",
    speed=1.5  # 0.25 to 4.0
)
```

---

## Steerable TTS (gpt-4o-mini-tts)

Control *how* the model speaks, not just *what* it says.

```python
response = client.audio.speech.create(
    model="gpt-4o-mini-tts",
    voice="alloy",
    input="I'm sorry to hear that happened. How can I help you today?",
    instructions="Speak in a sympathetic, customer service tone"
)
```

### Instruction Examples

```python
# Excited tone
instructions="Speak excitedly like announcing good news"

# Professional tone
instructions="Speak professionally like a business presenter"

# Casual tone
instructions="Speak casually like talking to a friend"

# Urgent tone
instructions="Speak urgently like delivering important information"

# Calm tone
instructions="Speak calmly and slowly like a meditation guide"
```

---

## Common Use Cases

### 1. Meeting Transcription

```python
def transcribe_meeting(audio_path):
    """Transcribe a meeting with timestamps."""
    with open(audio_path, "rb") as audio_file:
        transcription = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file,
            response_format="verbose_json",
            timestamp_granularities=["segment"]
        )

    # Format output
    transcript = ""
    for segment in transcription.segments:
        start = segment['start']
        text = segment['text']
        transcript += f"[{start:.1f}s] {text}\n"

    return transcript
```

### 2. Subtitle Generation

```python
def generate_subtitles(video_audio_path, format="srt"):
    """Generate subtitles from video audio."""
    with open(video_audio_path, "rb") as audio_file:
        subtitles = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file,
            response_format=format  # "srt" or "vtt"
        )

    with open(f"subtitles.{format}", "w") as f:
        f.write(subtitles)

    return subtitles
```

### 3. Voice Assistant

```python
def voice_assistant():
    """Simple voice assistant loop."""
    # Record audio (using your recording library)
    audio_path = record_audio()

    # Transcribe
    with open(audio_path, "rb") as audio_file:
        transcription = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file
        )

    user_input = transcription.text

    # Get response
    chat_response = client.chat.completions.create(
        model="gpt-5",
        messages=[{"role": "user", "content": user_input}]
    )

    assistant_text = chat_response.choices[0].message.content

    # Speak response
    speech_response = client.audio.speech.create(
        model="tts-1",
        voice="nova",
        input=assistant_text
    )

    speech_response.stream_to_file("response.mp3")
    play_audio("response.mp3")
```

### 4. Podcast/Audio Content Generation

```python
def generate_podcast_segment(script, voice="nova", model="tts-1-hd"):
    """Generate high-quality audio content."""
    response = client.audio.speech.create(
        model=model,
        voice=voice,
        input=script,
        response_format="mp3"
    )

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_path = f"podcast_segment_{timestamp}.mp3"

    response.stream_to_file(output_path)
    return output_path
```

### 5. Multilingual Transcription

```python
def transcribe_multilingual(audio_path):
    """Transcribe and identify language."""
    with open(audio_path, "rb") as audio_file:
        transcription = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file,
            response_format="verbose_json"
        )

    return {
        "text": transcription.text,
        "language": transcription.language,
        "duration": transcription.duration
    }
```

### 6. Real-Time Streaming (with Realtime API)

```python
# For bidirectional audio streaming, use the Realtime API
# See: https://platform.openai.com/docs/guides/realtime

from openai import OpenAI

client = OpenAI()

# Connect to realtime API for bidirectional audio
# This enables true voice conversations
```

---

## Advanced Techniques

### Diarization (Speaker Identification)

```python
def diarize_audio(audio_path):
    """
    Basic speaker diarization using prompts.
    For production, use dedicated diarization services.
    """
    with open(audio_path, "rb") as audio_file:
        transcription = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file,
            prompt="This is a conversation between Alice and Bob."
        )

    # Post-process with GPT to identify speakers
    analysis = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {
                "role": "system",
                "content": "Label each line with the speaker (Alice or Bob)."
            },
            {
                "role": "user",
                "content": f"Transcript:\n{transcription.text}"
            }
        ]
    )

    return analysis.choices[0].message.content
```

### Accent/Dialect Handling

```python
def transcribe_with_dialect(audio_path, dialect_info):
    """Improve accuracy for specific accents."""
    with open(audio_path, "rb") as audio_file:
        transcription = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file,
            prompt=f"This speaker has a {dialect_info} accent."
        )

    return transcription.text
```

### Audio Quality Enhancement

```python
from pydub import AudioSegment
from pydub.effects import normalize

def preprocess_audio(input_path, output_path):
    """Enhance audio before transcription."""
    audio = AudioSegment.from_file(input_path)

    # Normalize volume
    audio = normalize(audio)

    # Convert to mono
    audio = audio.set_channels(1)

    # Set sample rate to 16kHz (optimal for speech)
    audio = audio.set_frame_rate(16000)

    audio.export(output_path, format="wav")
    return output_path
```

---

## Pricing

### Whisper (Speech-to-Text)

**$0.006 per minute** of audio

Example costs:
- 1 hour = $0.36
- 10 hours = $3.60
- 100 hours = $36.00

### TTS (Text-to-Speech)

| Model | Price |
|-------|-------|
| tts-1 | **$15.00** / 1M characters |
| tts-1-hd | **$30.00** / 1M characters |

Example costs (tts-1):
- 1,000 chars = $0.015
- 10,000 chars = $0.15
- 100,000 chars = $1.50

---

## Best Practices

### Transcription

✅ **Use prompts** for domain-specific content
✅ **Clean audio** before transcribing (normalize, denoise)
✅ **Split long files** into chunks < 25MB
✅ **Include context** in prompts for technical terms
✅ **Use verbose_json** when you need timestamps

### TTS

✅ **Use tts-1** for real-time applications
✅ **Use tts-1-hd** for content production
✅ **Test multiple voices** for your use case
✅ **Adjust speed** for accessibility
✅ **Break long text** into natural chunks

---

## Limitations

### Whisper Limitations

❌ Cannot distinguish between speakers automatically
❌ May hallucinate for very quiet audio
❌ Accuracy decreases with heavy background noise
❌ 25MB file size limit
❌ Limited formatting (no punctuation customization)

### TTS Limitations

❌ Cannot control pronunciation of specific words precisely
❌ Limited emotional range (use steerable TTS for control)
❌ No custom voice creation
❌ May not pronounce rare words correctly
❌ Limited SSML support

---

## Error Handling

```python
from openai import OpenAI, APIError

client = OpenAI()

try:
    transcription = client.audio.transcriptions.create(
        model="whisper-1",
        file=audio_file
    )
except APIError as e:
    if "file_size" in str(e):
        print("File too large. Split into smaller chunks.")
    elif "invalid_file_format" in str(e):
        print("Unsupported format. Convert to MP3/WAV.")
    else:
        print(f"API error: {e}")
```

---

## Additional Resources

- **Audio API Reference**: https://platform.openai.com/docs/api-reference/audio
- **Whisper Model Card**: https://github.com/openai/whisper
- **Realtime API**: https://platform.openai.com/docs/guides/realtime
- **Cookbook Examples**: https://cookbook.openai.com/examples/whisper

---

**Next**: [Structured Output →](./structured-output.md)
