# OpenAI Platform - Models

**Source:** https://platform.openai.com/docs/models
**Fetched:** 2025-10-11

## Overview

OpenAI provides a diverse range of models with varying capabilities, pricing, and performance characteristics. Choose the right model based on your use case, budget, and performance requirements.

---

## GPT-5 Series (Latest - Released August 2025)

OpenAI's most advanced model family with built-in reasoning capabilities.

### gpt-5

**Our smartest, fastest, most useful model yet**

- **Context Window**: 256,000 tokens
- **Output**: Up to 16,384 tokens
- **Training Data**: Up to April 2025
- **Pricing**: $1.25/1M input tokens, $10/1M output tokens

**Capabilities:**
- Expert-level intelligence across math, coding, multimodal understanding
- 94.6% on AIME 2025 (mathematics)
- 74.9% on SWE-bench Verified (coding)
- 84.2% on MMMU (multimodal understanding)
- 46.2% on HealthBench Hard
- 45% less likely to contain factual errors than GPT-4o
- 80% less likely to contain errors than o3 when thinking
- Native multimodal input (text, image, audio, video)
- Integrated tool usage and persistent memory

**Best for:**
- Complex reasoning tasks
- Advanced coding and debugging
- Multimodal applications
- Research and analysis
- Expert-level problem solving

### gpt-5-mini

**Faster, cost-efficient version with strong performance**

- **Context Window**: 128,000 tokens
- **Output**: Up to 16,384 tokens
- **Pricing**: Lower cost than GPT-5 (contact sales)

**Best for:**
- Production applications requiring speed
- Cost-sensitive deployments
- High-volume requests
- Defined, repetitive tasks

### gpt-5-nano

**Fastest, most cost-effective GPT-5 variant**

- **Context Window**: 128,000 tokens
- **Pricing**: Lowest in GPT-5 family

**Best for:**
- Ultra-high volume applications
- Real-time responses
- Simple classification tasks
- Edge deployments

### gpt-5-chat

**Optimized for conversational applications**

- **Context Window**: 256,000 tokens
- **Specialization**: Chat and dialogue systems

**Best for:**
- Chatbots and virtual assistants
- Customer support systems
- Interactive applications

### gpt-5-codex

**GPT-5 optimized for agentic coding**

- **Specialization**: Advanced code generation and agent workflows
- **Integration**: Native Codex platform support

**Best for:**
- Code generation and completion
- Automated debugging
- Software engineering agents
- IDE integrations

---

## GPT-4.1 Series (Released April 2025)

Latest non-reasoning models with enhanced capabilities.

### gpt-4.1

**Advanced model with 1M token context**

- **Context Window**: 1,000,000 tokens
- **Output**: Up to 16,384 tokens
- **Training Data**: Up to October 2024
- **Pricing**: $2.50/1M input tokens, $10/1M output tokens

**Improvements over GPT-4o:**
- Major gains in coding
- Better instruction following
- Improved long-context comprehension
- Enhanced reasoning capabilities

**Best for:**
- Long document analysis
- Large codebase understanding
- Complex instruction following
- Multi-turn conversations

### gpt-4.1-mini

**Efficient model with extended context**

- **Context Window**: 1,000,000 tokens
- **Pricing**: $0.15/1M input tokens, $0.60/1M output tokens

**Best for:**
- Cost-effective long-context tasks
- Document processing at scale
- High-volume applications

### gpt-4.1-nano

**Fastest GPT-4.1 variant**

- **Context Window**: 128,000 tokens
- **Pricing**: Ultra-low cost

**Best for:**
- Real-time applications
- Simple tasks at scale
- Latency-sensitive workloads

---

## GPT-4o Series

Omnimodal models supporting text, vision, and audio.

### gpt-4o

**Flagship omnimodal model**

- **Context Window**: 128,000 tokens
- **Output**: 4,096 tokens
- **Training Data**: Up to October 2023
- **Pricing**: $2.50/1M input tokens, $10/1M output tokens
- **Modalities**: Text, image, audio input/output

**Capabilities:**
- Vision understanding
- Audio processing
- Real-time voice conversations
- Function calling
- JSON mode

**Best for:**
- Multimodal applications
- Vision + text tasks
- Audio transcription and generation
- Real-time interactions

### gpt-4o-mini

**Cost-efficient multimodal model**

- **Context Window**: 128,000 tokens
- **Output**: 16,384 tokens
- **Pricing**: $0.15/1M input tokens, $0.60/1M output tokens
- **Modalities**: Text, vision

**Best for:**
- Affordable multimodal tasks
- High-volume vision applications
- Production chatbots with vision

### gpt-4o-transcribe

**Specialized for speech recognition**

- **Specialization**: Audio to text
- **Quality**: High-accuracy transcription
- **Languages**: 95+ supported

**Best for:**
- Speech-to-text applications
- Meeting transcription
- Voice assistants

### gpt-4o-mini-tts

**Fast text-to-speech**

- **Specialization**: Natural voice synthesis
- **Voices**: Multiple voice options
- **Latency**: Optimized for speed

**Best for:**
- Voice response systems
- Accessibility applications
- Audio content generation

---

## O-Series (Reasoning Models)

Specialized models for complex reasoning tasks.

### o3

**Advanced reasoning model**

- **Specialization**: Complex problem solving
- **Context**: Extended reasoning chains
- **Performance**: State-of-the-art on reasoning benchmarks

**Best for:**
- Mathematical proofs
- Complex coding challenges
- Scientific reasoning
- Multi-step problem solving

### o3-mini

**Efficient reasoning model**

- **Specialization**: Reasoning at lower cost
- **Performance**: Strong reasoning with faster responses

**Best for:**
- Production reasoning tasks
- Cost-effective complex problems

### o4-mini

**Latest compact reasoning model**

- **Specialization**: Fast reasoning
- **Latency**: Optimized for speed

**Best for:**
- Real-time reasoning applications
- High-volume reasoning tasks

---

## GPT-4 Series (Previous Generation)

### gpt-4-turbo

**High-intelligence model**

- **Context Window**: 128,000 tokens
- **Training Data**: Up to December 2023
- **Pricing**: $10/1M input tokens, $30/1M output tokens

### gpt-4

**Original GPT-4**

- **Context Window**: 8,192 tokens
- **Pricing**: $30/1M input tokens, $60/1M output tokens

### gpt-4-32k

**Extended context GPT-4**

- **Context Window**: 32,768 tokens
- **Pricing**: $60/1M input tokens, $120/1M output tokens

---

## GPT-3.5 Series (Legacy)

### gpt-3.5-turbo

**Fast, affordable legacy model**

- **Context Window**: 16,385 tokens
- **Training Data**: Up to September 2021
- **Pricing**: $0.50-$2.00/1M tokens

**Status**: Legacy - consider GPT-4.1-nano or GPT-5-nano for new projects

---

## Specialized Models

### gpt-image-1

**State-of-the-art image generation**

- **Replaces**: DALL-E 3
- **Capabilities**:
  - High-resolution generation
  - Inpainting and editing
  - Advanced control workflows
- **Pricing**: Per-image pricing

### sora-2

**Video generation with audio**

- **Capabilities**:
  - Video synthesis from text
  - Synchronized audio generation
  - Multi-shot compositions
- **Status**: Available in API

### whisper-large-v3

**Speech recognition**

- **Languages**: 95+
- **Accuracy**: Industry-leading
- **Pricing**: $0.006/minute

### tts-1

**Standard text-to-speech**

- **Voices**: 6 preset voices
- **Quality**: Good for most use cases
- **Pricing**: $15/1M characters

### tts-1-hd

**High-quality text-to-speech**

- **Voices**: 6 preset voices
- **Quality**: Enhanced clarity
- **Pricing**: $30/1M characters

### text-embedding-3-large

**Large embedding model**

- **Dimensions**: 3,072 (configurable)
- **Performance**: Best-in-class retrieval
- **Pricing**: $0.00013/1M tokens

### text-embedding-3-small

**Efficient embedding model**

- **Dimensions**: 1,536 (configurable)
- **Performance**: Strong, cost-effective
- **Pricing**: $0.00002/1M tokens

### text-embedding-ada-002

**Legacy embedding model**

- **Dimensions**: 1,536
- **Status**: Replaced by text-embedding-3-small
- **Pricing**: $0.00010/1M tokens

### text-moderation-latest

**Content moderation**

- **Categories**: Hate, violence, sexual, self-harm, etc.
- **Pricing**: Free

---

## Model Selection Guide

### By Use Case

**General Intelligence**
- Premium: GPT-5
- Balanced: GPT-4.1
- Budget: GPT-5-mini

**Coding**
- Agentic: GPT-5-codex
- Complex: GPT-5
- Fast: GPT-4.1-mini

**Long Context (>100K tokens)**
- GPT-4.1 (1M tokens)
- GPT-5 (256K tokens)
- GPT-4.1-mini (1M tokens)

**Multimodal**
- Best: GPT-5
- Balanced: GPT-4o
- Budget: GPT-4o-mini

**Reasoning**
- Complex: o3
- Balanced: o3-mini
- Fast: o4-mini

**Real-time/Low Latency**
- GPT-5-nano
- GPT-4.1-nano
- o4-mini

### By Budget

**Premium** ($1-10/1M tokens)
- GPT-5
- GPT-4.1

**Mid-Range** ($0.15-2.50/1M tokens)
- GPT-5-mini
- GPT-4o
- GPT-4.1-mini

**Budget** (<$0.15/1M tokens)
- GPT-5-nano
- GPT-4.1-nano
- GPT-4o-mini
- GPT-3.5-turbo

---

## Deprecation Timeline

| Model | Deprecation Date | Replacement |
|-------|------------------|-------------|
| gpt-3.5-turbo | TBA | gpt-4.1-nano |
| gpt-4 | TBA | gpt-4.1 |
| text-embedding-ada-002 | TBA | text-embedding-3-small |

---

## Model Capabilities Comparison

| Feature | GPT-5 | GPT-4.1 | GPT-4o | o3 | GPT-3.5 |
|---------|-------|---------|--------|-----|---------|
| Text Generation | ✅ | ✅ | ✅ | ✅ | ✅ |
| Function Calling | ✅ | ✅ | ✅ | ✅ | ✅ |
| Vision | ✅ | ✅ | ✅ | ❌ | ❌ |
| Audio | ✅ | ❌ | ✅ | ❌ | ❌ |
| JSON Mode | ✅ | ✅ | ✅ | ✅ | ✅ |
| Streaming | ✅ | ✅ | ✅ | ✅ | ✅ |
| Reasoning | ✅ Built-in | ⚠️ Limited | ⚠️ Limited | ✅ Advanced | ❌ |
| Context (max) | 256K | 1M | 128K | Varies | 16K |

---

## Additional Resources

- **Pricing**: https://openai.com/api/pricing
- **Model Dashboard**: https://platform.openai.com/docs/models
- **Model Comparison Tool**: https://platform.openai.com/playground
- **Cookbook Examples**: https://cookbook.openai.com

---

**Next**: [Pricing →](./pricing.md)
