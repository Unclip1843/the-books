https://platform.openai.com/docs/guides/tools

Docs
API reference
Using tools
Use tools like remote MCP servers or web search to extend the model's capabilities.
When generating model responses, you can extend capabilities using built‑in tools and remote MCP servers. These enable the model to search the web, retrieve from your files, call your own functions, or access third‑party services.

Web search
File search
Function calling
Remote MCP
Include web search results for the model response
import OpenAI from "openai";
const client = new OpenAI();

const response = await client.responses.create({
    model: "gpt-5",
    tools: [
        { type: "web_search" },
    ],
    input: "What was a positive news story from today?",
});

console.log(response.output_text);
Available tools
Here's an overview of the tools available in the OpenAI platform—select one of them for further guidance on usage.

Function calling
Call custom code to give the model access to additional data and capabilities.

Web search
Include data from the Internet in model response generation.

Remote MCP servers
Give the model access to new capabilities via Model Context Protocol (MCP) servers.

File search
Search the contents of uploaded files for context when generating a response.

Image generation
Generate or edit images using GPT Image.

Code interpreter
Allow the model to execute code in a secure container.

Computer use
Create agentic workflows that enable a model to control a computer interface.

Usage in the API
When making a request to generate a model response, you can enable tool access by specifying configurations in the tools parameter. Each tool has its own unique configuration requirements—see the Available tools section for detailed instructions.

Based on the provided prompt, the model automatically decides whether to use a configured tool. For instance, if your prompt requests information beyond the model's training cutoff date and web search is enabled, the model will typically invoke the web search tool to retrieve relevant, up-to-date information.

You can explicitly control or guide this behavior by setting the tool_choice parameter in the API request.

Function calling
In addition to built-in tools, you can define custom functions using the tools array. These custom functions allow the model to call your application's code, enabling access to specific data or capabilities not directly available within the model.

Learn more in the function calling guide.

Overview
Available tools
API usage
Starter app
Experiment with built-in tools in the Responses API.