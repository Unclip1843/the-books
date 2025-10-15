https://platform.openai.com/docs/models/gpt-realtime-mini


Docs
API reference
Models
gpt-realtime-mini
gpt-realtime-mini
A cost-efficient version of GPT Realtime
Performance
Higher
Speed
Very fast
Price
$0.6
•
$2.4
Input
•
Output
Input
Text, image, audio
Output
Text, audio
A cost-efficient version of GPT Realtime - capable of responding to audio and text inputs in realtime over WebRTC, WebSocket, or SIP connections.

32,000 context window
4,096 max output tokens
Oct 01, 2023 knowledge cutoff
Pricing
Pricing is based on the number of tokens used, or other metrics based on the model type. For tool-specific models, like search and computer use, there's a fee per tool call. See details in the pricing page.
Text tokens
Per 1M tokens
Input
$0.60
Cached input
$0.06
Output
$2.40
Quick comparison
Input
Cached input
Output
GPT-5
$1.25
gpt-realtime-mini
$0.60
Audio tokens
Per 1M tokens
Input
$10.00
Cached input
$0.30
Output
$20.00
Image tokens
Per 1M tokens
Input
$0.80
Cached input
$0.08
Modalities
Text
Input and output
Image
Input only
Audio
Input and output
Video
Not supported
Endpoints
Chat Completions
v1/chat/completions
Responses
v1/responses
Realtime
v1/realtime
Assistants
v1/assistants
Batch
v1/batch
Fine-tuning
v1/fine-tuning
Embeddings
v1/embeddings
Image generation
v1/images/generations
Videos
v1/videos
Image edit
v1/images/edits
Speech generation
v1/audio/speech
Transcription
v1/audio/transcriptions
Translation
v1/audio/translations
Moderation
v1/moderations
Completions (legacy)
v1/completions
Features
Function calling
Supported
Structured outputs
Not supported
Fine-tuning
Not supported
Distillation
Not supported
Predicted outputs
Not supported
Snapshots
Snapshots let you lock in a specific version of the model so that performance and behavior remain consistent. Below is a list of all available snapshots and aliases for gpt-realtime-mini.
gpt-realtime-mini
gpt-realtime-mini
gpt-realtime-mini-2025-10-06
gpt-realtime-mini-2025-10-06
Rate limits
Rate limits ensure fair and reliable access to the API by placing specific caps on requests or tokens used within a given time period. Your usage tier determines how high these limits are set and automatically increases as you send more requests and spend more on the API.
Tier	RPM	TPM
Free	Not supported
Tier 1	200	40,000
Tier 2	400	200,000
Tier 3	5,000	800,000
Tier 4	10,000	4,000,000
Tier 5	20,000	15,000,000
