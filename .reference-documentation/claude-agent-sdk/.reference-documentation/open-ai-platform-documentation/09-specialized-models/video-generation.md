# OpenAI Platform - Video Generation

**Source:** https://platform.openai.com/docs/guides/video
**Fetched:** 2025-10-11

## Overview

Generate videos using Sora models.

---

## Generate Videos

```python
response = client.videos.generate(
    model="sora-1.0",
    prompt="A timelapse of a flower blooming",
    duration=5,  # seconds
    resolution="1080p"
)

video_url = response.data[0].url
```

---

## Capabilities

- Text-to-video generation
- Custom durations
- Multiple resolutions
- Scene composition

---

**Source:** https://platform.openai.com/docs/guides/video
