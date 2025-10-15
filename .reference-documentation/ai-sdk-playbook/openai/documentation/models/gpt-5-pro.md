Docs
API reference
Models
gpt-5-pro
GPT-5 pro
Version of GPT-5 that produces smarter and more precise responses
Reasoning
Highest
Speed
Slowest
Price
$15
•
$120
Input
•
Output
Input
Text, image
Output
Text
GPT-5 pro uses more compute to think harder and provide consistently better answers.

GPT-5 pro is available in the Responses API only to enable support for multi-turn model interactions before responding to API requests, and other advanced API features in the future. Since GPT-5 pro is designed to tackle tough problems, some requests may take several minutes to finish. To avoid timeouts, try using background mode. As our most advanced reasoning model, GPT-5 pro defaults to (and only supports) reasoning.effort: high. GPT-5 pro does not support code interpreter.

400,000 context window
272,000 max output tokens
Sep 30, 2024 knowledge cutoff
Reasoning token support
Pricing
Pricing is based on the number of tokens used, or other metrics based on the model type. For tool-specific models, like search and computer use, there's a fee per tool call. See details in the pricing page.
Text tokens
Per 1M tokens
∙
Batch API price
Input
$15.00
Output
$120.00
Quick comparison
Input
Output
o3-pro
$20.00
GPT-5 pro
$15.00
GPT-5
$1.25
Modalities
Text
Input and output
Image
Input only
Audio
Not supported
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
Streaming
Not supported
Function calling
Supported
Structured outputs
Supported
Fine-tuning
Not supported
Distillation
Not supported
Tools
Tools supported by this model when using the Responses API.
Web search
Supported
File search
Supported
Image generation
Supported
Code interpreter
Not supported
Computer use
Not supported
MCP
Supported
Snapshots
Snapshots let you lock in a specific version of the model so that performance and behavior remain consistent. Below is a list of all available snapshots and aliases for GPT-5 pro.
gpt-5-pro
gpt-5-pro
gpt-5-pro-2025-10-06
gpt-5-pro-2025-10-06
Rate limits
Rate limits ensure fair and reliable access to the API by placing specific caps on requests or tokens used within a given time period. Your usage tier determines how high these limits are set and automatically increases as you send more requests and spend more on the API.
Tier	RPM	TPM	Batch queue limit
Free	Not supported
Tier 1	500	30,000	90,000
Tier 2	5,000	450,000	1,350,000
Tier 3	5,000	800,000	50,000,000
Tier 4	10,000	2,000,000	200,000,000
Tier 5	10,000	30,000,000	5,000,000,000
