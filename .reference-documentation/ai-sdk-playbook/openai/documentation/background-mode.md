https://platform.openai.com/docs/guides/background

Docs
API reference
Background mode
Run long running tasks asynchronously in the background.
Agents like Codex and Deep Research show that reasoning models can take several minutes to solve complex problems. Background mode enables you to execute long-running tasks on models like o3 and o1-pro reliably, without having to worry about timeouts or other connectivity issues.

Background mode kicks off these tasks asynchronously, and developers can poll response objects to check status over time. To start response generation in the background, make an API request with background set to true:

Generate a response in the background
from openai import OpenAI

client = OpenAI()

resp = client.responses.create(
  model="o3",
  input="Write a very long novel about otters in space.",
  background=True,
)

print(resp.status)
Polling background responses
To check the status of background requests, use the GET endpoint for Responses. Keep polling while the request is in the queued or in_progress state. When it leaves these states, it has reached a final (terminal) state.

Retrieve a response executing in the background
from openai import OpenAI
from time import sleep

client = OpenAI()

resp = client.responses.create(
  model="o3",
  input="Write a very long novel about otters in space.",
  background=True,
)

while resp.status in {"queued", "in_progress"}:
  print(f"Current status: {resp.status}")
  sleep(2)
  resp = client.responses.retrieve(resp.id)

print(f"Final status: {resp.status}\nOutput:\n{resp.output_text}")
Cancelling a background response
You can also cancel an in-flight response like this:

Cancel an ongoing response
from openai import OpenAI
client = OpenAI()

resp = client.responses.cancel("resp_123")

print(resp.status)
Cancelling twice is idempotent - subsequent calls simply return the final Response object.

Streaming a background response
You can create a background Response and start streaming events from it right away. This may be helpful if you expect the client to drop the stream and want the option of picking it back up later. To do this, create a Response with both background and stream set to true. You will want to keep track of a "cursor" corresponding to the sequence_number you receive in each streaming event.

Currently, the time to first token you receive from a background response is higher than what you receive from a synchronous one. We are working to reduce this latency gap in the coming weeks.

Generate and stream a background response
from openai import OpenAI

client = OpenAI()

# Fire off an async response but also start streaming immediately
stream = client.responses.create(
  model="o3",
  input="Write a very long novel about otters in space.",
  background=True,
  stream=True,
)

cursor = None
for event in stream:
  print(event)
  cursor = event.sequence_number

# If your connection drops, the response continues running and you can reconnect:
# SDK support for resuming the stream is coming soon.
# for event in client.responses.stream(resp.id, starting_after=cursor):
#     print(event)
Limits
Background sampling requires store=true; stateless requests are rejected.
To cancel a synchronous response, terminate the connection
You can only start a new stream from a background response if you created it with stream=true.
Overview
Polling
Cancelling
Streaming
Limits