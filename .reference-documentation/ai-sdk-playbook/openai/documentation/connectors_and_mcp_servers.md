https://platform.openai.com/docs/guides/tools-connectors-mcp

Docs
API reference
Connectors and MCP servers
Beta
Use connectors and remote MCP servers to give models new capabilities.
In addition to tools you make available to the model with function calling, you can give models new capabilities using connectors and remote MCP servers. These tools give the model the ability to connect to and control external services when needed to respond to a user's prompt. These tool calls can either be allowed automatically, or restricted with explicit approval required by you as the developer.

Connectors are OpenAI-maintained MCP wrappers for popular services like Google Workspace or Dropbox, like the connectors available in ChatGPT.
Remote MCP servers can be any server on the public Internet that implements a remote Model Context Protocol (MCP) server.
This guide will show how to use both remote MCP servers and connectors to give the model access to new capabilities.

Quickstart
Check out the examples below to see how remote MCP servers and connectors work through the Responses API. Both connectors and remote MCP servers can be used with the mcp built-in tool type.

Using remote MCP servers
Using connectors
Remote MCP servers require a server_url. Depending on the server, you may also need an OAuth authorization parameter containing an access token.

Using a remote MCP server in the Responses API
from openai import OpenAI

client = OpenAI()

resp = client.responses.create(
    model="gpt-5",
    tools=[
        {
            "type": "mcp",
            "server_label": "dmcp",
            "server_description": "A Dungeons and Dragons MCP server to assist with dice rolling.",
            "server_url": "https://dmcp-server.deno.dev/sse",
            "require_approval": "never",
        },
    ],
    input="Roll 2d4+1",
)

print(resp.output_text)
It is very important that developers trust any remote MCP server they use with the Responses API. A malicious server can exfiltrate sensitive data from anything that enters the model's context. Carefully review the Risks and Safety section below before using this tool.
The API will return new items in the output array of the model response. If the model decides to use a Connector or MCP server, it will first make a request to list available tools from the server, which will create a mcp_list_tools output item. From the simple remote MCP server example above, it contains only one tool definition:

{
    "id": "mcpl_68a6102a4968819c8177b05584dd627b0679e572a900e618",
    "type": "mcp_list_tools",
    "server_label": "dmcp",
    "tools": [
        {
            "annotations": null,
            "description": "Given a string of text describing a dice roll...",
            "input_schema": {
                "$schema": "https://json-schema.org/draft/2020-12/schema",
                "type": "object",
                "properties": {
                    "diceRollExpression": {
                        "type": "string"
                    }
                },
                "required": ["diceRollExpression"],
                "additionalProperties": false
            },
            "name": "roll"
        }
    ]
}
If the model decides to call one of the available tools from the MCP server, you will also find a mcp_call output which will show what the model sent to the MCP tool, and what the MCP tool sent back as output.

{
    "id": "mcp_68a6102d8948819c9b1490d36d5ffa4a0679e572a900e618",
    "type": "mcp_call",
    "approval_request_id": null,
    "arguments": "{\"diceRollExpression\":\"2d4 + 1\"}",
    "error": null,
    "name": "roll",
    "output": "4",
    "server_label": "dmcp"
}
Read on in the guide below to learn more about how the MCP tool works, how to filter available tools, and how to handle tool call approval requests.

How it works
The MCP tool (for both remote MCP servers and connectors) is available in the Responses API in most recent models. Check MCP tool compatibility for your model here. When you're using the MCP tool, you only pay for tokens used when importing tool definitions or making tool calls. There are no additional fees involved per tool call.

Below, we'll step through the process the API takes when calling an MCP tool.

Step 1: Listing available tools
When you specify a remote MCP server in the tools parameter, the API will attempt to get a list of tools from the server. The Responses API works with remote MCP servers that support either the Streamable HTTP or the HTTP/SSE transport protocols.

If successful in retrieving the list of tools, a new mcp_list_tools output item will appear in the model response output. The tools property of this object will show the tools that were successfully imported.

{
    "id": "mcpl_68a6102a4968819c8177b05584dd627b0679e572a900e618",
    "type": "mcp_list_tools",
    "server_label": "dmcp",
    "tools": [
        {
            "annotations": null,
            "description": "Given a string of text describing a dice roll...",
            "input_schema": {
                "$schema": "https://json-schema.org/draft/2020-12/schema",
                "type": "object",
                "properties": {
                    "diceRollExpression": {
                        "type": "string"
                    }
                },
                "required": ["diceRollExpression"],
                "additionalProperties": false
            },
            "name": "roll"
        }
    ]
}
As long as the mcp_list_tools item is present in the context of an API request, the API will not fetch a list of tools from the MCP server again at each turn in a conversation. We recommend you keep this item in the model's context as part of every conversation or workflow execution to optimize for latency.

Filtering tools
Some MCP servers can have dozens of tools, and exposing many tools to the model can result in high cost and latency. If you're only interested in a subset of tools an MCP server exposes, you can use the allowed_tools parameter to only import those tools.

Constrain allowed tools
from openai import OpenAI

client = OpenAI()

resp = client.responses.create(
    model="gpt-5",
    tools=[{
        "type": "mcp",
        "server_label": "dmcp",
        "server_description": "A Dungeons and Dragons MCP server to assist with dice rolling.",
        "server_url": "https://dmcp-server.deno.dev/sse",
        "require_approval": "never",
        "allowed_tools": ["roll"],
    }],
    input="Roll 2d4+1",
)

print(resp.output_text)
Step 2: Calling tools
Once the model has access to these tool definitions, it may choose to call them depending on what's in the model's context. When the model decides to call an MCP tool, the API will make an request to the remote MCP server to call the tool and put its output into the model's context. This creates an mcp_call item which looks like this:

{
    "id": "mcp_68a6102d8948819c9b1490d36d5ffa4a0679e572a900e618",
    "type": "mcp_call",
    "approval_request_id": null,
    "arguments": "{\"diceRollExpression\":\"2d4 + 1\"}",
    "error": null,
    "name": "roll",
    "output": "4",
    "server_label": "dmcp"
}
This item includes both the arguments the model decided to use for this tool call, and the output that the remote MCP server returned. All models can choose to make multiple MCP tool calls, so you may see several of these items generated in a single API request.

Failed tool calls will populate the error field of this item with MCP protocol errors, MCP tool execution errors, or general connectivity errors. The MCP errors are documented in the MCP spec here.

Approvals
By default, OpenAI will request your approval before any data is shared with a connector or remote MCP server. Approvals help you maintain control and visibility over what data is being sent to an MCP server. We highly recommend that you carefully review (and optionally log) all data being shared with a remote MCP server. A request for an approval to make an MCP tool call creates a mcp_approval_request item in the Response's output that looks like this:

{
    "id": "mcpr_68a619e1d82c8190b50c1ccba7ad18ef0d2d23a86136d339",
    "type": "mcp_approval_request",
    "arguments": "{\"diceRollExpression\":\"2d4 + 1\"}",
    "name": "roll",
    "server_label": "dmcp"
}
You can then respond to this by creating a new Response object and appending an mcp_approval_response item to it.

Approving the use of tools in an API request
from openai import OpenAI

client = OpenAI()

resp = client.responses.create(
    model="gpt-5",
    tools=[{
        "type": "mcp",
        "server_label": "dmcp",
        "server_description": "A Dungeons and Dragons MCP server to assist with dice rolling.",
        "server_url": "https://dmcp-server.deno.dev/sse",
        "require_approval": "always",
    }],
    previous_response_id="resp_682d498bdefc81918b4a6aa477bfafd904ad1e533afccbfa",
    input=[{
        "type": "mcp_approval_response",
        "approve": True,
        "approval_request_id": "mcpr_682d498e3bd4819196a0ce1664f8e77b04ad1e533afccbfa"
    }],
)

print(resp.output_text)
Here we're using the previous_response_id parameter to chain this new Response, with the previous Response that generated the approval request. But you can also pass back the outputs from one response, as inputs into another for maximum control over what enter's the model's context.

If and when you feel comfortable trusting a remote MCP server, you can choose to skip the approvals for reduced latency. To do this, you can set the require_approval parameter of the MCP tool to an object listing just the tools you'd like to skip approvals for like shown below, or set it to the value 'never' to skip approvals for all tools in that remote MCP server.

Never require approval for some tools
from openai import OpenAI

client = OpenAI()

resp = client.responses.create(
    model="gpt-5",
    tools=[
        {
            "type": "mcp",
            "server_label": "deepwiki",
            "server_url": "https://mcp.deepwiki.com/mcp",
            "require_approval": {
                "never": {
                    "tool_names": ["ask_question", "read_wiki_structure"]
                }
            }
        },
    ],
    input="What transport protocols does the 2025-03-26 version of the MCP spec (modelcontextprotocol/modelcontextprotocol) support?",
)

print(resp.output_text)
Authentication
Unlike the example MCP server we used above, most other MCP servers require authentication. The most common scheme is an OAuth access token. Provide this token using the authorization field of the MCP tool:

Use Stripe MCP tool
from openai import OpenAI

client = OpenAI()

resp = client.responses.create(
    model="gpt-5",
    input="Create a payment link for $20",
    tools=[
        {
            "type": "mcp",
            "server_label": "stripe",
            "server_url": "https://mcp.stripe.com",
            "authorization": "$STRIPE_OAUTH_ACCESS_TOKEN"
        }
    ]
)

print(resp.output_text)
To prevent the leakage of sensitive tokens, the Responses API does not store the value you provide in the authorization field. This value will also not be visible in the Response object created. Additionally, because some remote MCP servers generate authenticated URLs, we also discard the path portion of the server_url in our responses (i.e. example.com/mcp becomes example.com). Because of this, you must send the full path of the MCP server_url and the authorization value in every Responses API creation request you make.

Connectors
The Responses API has built-in support for a limited set of connectors to third-party services. These connectors let you pull in context from popular applications, like Dropbox and Gmail, to allow the model to interact with popular services.

Connectors can be used in the same way as remote MCP servers. Both let an OpenAI model access additional third-party tools in an API request. However, instead of passing a server_url as you would to call a remote MCP server, you pass a connector_id which uniquely identifies a connector available in the API.

Available connectors
Dropbox: connector_dropbox
Gmail: connector_gmail
Google Calendar: connector_googlecalendar
Google Drive: connector_googledrive
Microsoft Teams: connector_microsoftteams
Outlook Calendar: connector_outlookcalendar
Outlook Email: connector_outlookemail
SharePoint: connector_sharepoint
We prioritized services that don't have official remote MCP servers. GitHub, for instance, has an official MCP server you can connect to by passing https://api.githubcopilot.com/mcp/ to the server_url field in the MCP tool.

Authorizing a connector
In the authorization field, pass in an OAuth access token. OAuth client registration and authorization must be handled separately by your application.

For testing purposes, you can use Google's OAuth 2.0 Playground to generate temporary access tokens that you can use in an API request.

To use the playground to test the connectors API functionality, start by entering:

https://www.googleapis.com/auth/calendar.events
This authorization scope will enable the API to read Google Calendar events. In the UI under "Step 1: Select and authorize APIs".

After authorizing the application with your Google account, you will come to "Step 2: Exchange authorization code for tokens". This will generate an access token you can use in an API request using the Google Calendar connector:

Use the Google Calendar connector
from openai import OpenAI

client = OpenAI()

resp = client.responses.create(
    model="gpt-5",
    tools=[
        {
            "type": "mcp",
            "server_label": "google_calendar",
            "connector_id": "connector_googlecalendar",
            "authorization": "ya29.A0AS3H6...",
            "require_approval": "never",
        },
    ],
    input="What's on my Google Calendar for today?",
)

print(resp.output_text)
An MCP tool call from a Connector will look the same as an MCP tool call from a remote MCP server, using the mcp_call output item type. In this case, both the arguments to and the response from the Connector are JSON strings:

{
    "id": "mcp_68a62ae1c93c81a2b98c29340aa3ed8800e9b63986850588",
    "type": "mcp_call",
    "approval_request_id": null,
    "arguments": "{\"time_min\":\"2025-08-20T00:00:00\",\"time_max\":\"2025-08-21T00:00:00\",\"timezone_str\":null,\"max_results\":50,\"query\":null,\"calendar_id\":null,\"next_page_token\":null}",
    "error": null,
    "name": "search_events",
    "output": "{\"events\": [{\"id\": \"2n8ni54ani58pc3ii6soelupcs_20250820\", \"summary\": \"Home\", \"location\": null, \"start\": \"2025-08-20T00:00:00\", \"end\": \"2025-08-21T00:00:00\", \"url\": \"https://www.google.com/calendar/event?eid=Mm44bmk1NGFuaTU4cGMzaWk2c29lbHVwY3NfMjAyNTA4MjAga3doaW5uZXJ5QG9wZW5haS5jb20&ctz=America/Los_Angeles\", \"description\": \"\\n\\n\", \"transparency\": \"transparent\", \"display_url\": \"https://www.google.com/calendar/event?eid=Mm44bmk1NGFuaTU4cGMzaWk2c29lbHVwY3NfMjAyNTA4MjAga3doaW5uZXJ5QG9wZW5haS5jb20&ctz=America/Los_Angeles\", \"display_title\": \"Home\"}], \"next_page_token\": null}",
    "server_label": "Google_Calendar"
}
Available tools in each connector
The available tools depend on which scopes your OAuth token has available to it. Expand the tables below to see what tools you can use when connecting to each application.

Dropbox
Gmail
Google Calendar
Google Drive
Microsoft Teams
Outlook Calendar
Outlook Email
Sharepoint
Risks and safety
The MCP tool permits you to connect OpenAI models to external services. This is a powerful feature that comes with some risks.

For connectors, there is a risk of potentially sending sensitive data to OpenAI, or allowing models read access to potentially sensitive data in those services.

Remote MCP servers carry those same risks, but also have not been verified by OpenAI. These servers can allow models to access, send, and receive data, and take action in these services. All MCP servers are third-party services that are subject to their own terms and conditions.

If you come across a malicious MCP server, please report it to security@openai.com.

Below are some best practices to consider when integrating connectors and remote MCP servers.

Prompt injection
Prompt injection is an important security consideration in any LLM application, and is especially true when you give the model access to MCP servers and connectors which can access sensitive data or take action. Use these tools with appropriate caution and mitigations if the prompt for the model contains user-provided content.

Always require approval for sensitive actions
Use the available configurations of the require_approval and allowed_tools parameters to ensure that any sensitive actions require an approval flow.

URLs within MCP tool calls and outputs
It can be dangerous to request URLs or embed image URLs provided by tool call outputs either from connectors or remote MCP servers. Ensure that you trust the domains and services providing those URLs before embedding or otherwise using them in your application code.

Connecting to trusted servers
Pick official servers hosted by the service providers themselves (e.g. we recommend connecting to the Stripe server hosted by Stripe themselves on mcp.stripe.com, instead of a Stripe MCP server hosted by a third party). Because there aren't too many official remote MCP servers today, you may be tempted to use a MCP server hosted by an organization that doesn't operate that server and simply proxies request to that service via your API. If you must do this, be extra careful in doing your due diligence on these "aggregators", and carefully review how they use your data.

Log and review data being shared with third party MCP servers.
Because MCP servers define their own tool definitions, they may request for data that you may not always be comfortable sharing with the host of that MCP server. Because of this, the MCP tool in the Responses API defaults to requiring approvals of each MCP tool call being made. When developing your application, review the type of data being shared with these MCP servers carefully and robustly. Once you gain confidence in your trust of this MCP server, you can skip these approvals for more performant execution.

We also recommend logging any data sent to MCP servers. If you're using the Responses API with store=true, these data are already logged via the API for 30 days unless Zero Data Retention is enabled for your organization. You may also want to log these data in your own systems and perform periodic reviews on this to ensure data is being shared per your expectations.

Malicious MCP servers may include hidden instructions (prompt injections) designed to make OpenAI models behave unexpectedly. While OpenAI has implemented built-in safeguards to help detect and block these threats, it's essential to carefully review inputs and outputs, and ensure connections are established only with trusted servers.

MCP servers may update tool behavior unexpectedly, potentially leading to unintended or malicious behavior.

Implications on Zero Data Retention and Data Residency
The MCP tool is compatible with Zero Data Retention and Data Residency, but it's important to note that MCP servers are third-party services, and data sent to an MCP server is subject to their data retention and data residency policies.

In other words, if you're an organization with Data Residency in Europe, OpenAI will limit inference and storage of Customer Content to take place in Europe up until the point communication or data is sent to the MCP server. It is your responsibility to ensure that the MCP server also adheres to any Zero Data Retention or Data Residency requirements you may have. Learn more about Zero Data Retention and Data Residency here.

Usage notes
API Availability	Rate limits	Notes
Responses
Chat Completions
Assistants
Tier 1
200 RPM

Tier 2 and 3
1000 RPM

Tier 4 and 5
2000 RPM

Pricing
ZDR and data residency

Overview
How it works
Authentication
Connectors
Risks and safety
Usage notes