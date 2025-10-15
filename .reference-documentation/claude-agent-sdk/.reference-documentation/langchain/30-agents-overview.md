# LangChain - Agents Overview

**Sources:**
- https://python.langchain.com/docs/concepts/agents/
- https://python.langchain.com/docs/tutorials/agents/
- https://js.langchain.com/docs/concepts/agents/

**Fetched:** 2025-10-11

## What are Agents?

Agents use LLMs to **decide which actions to take**:

```
Question → Agent → Choose Tool → Execute → Repeat → Answer
```

**Key difference from chains:**
- **Chains:** Fixed sequence
- **Agents:** Dynamic decisions

## Basic Agent

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.tools import tool

# Define tools
@tool
def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b

@tool
def add(a: int, b: int) -> int:
    """Add two numbers."""
    return a + b

tools = [multiply, add]

# Create agent
llm = ChatOpenAI(model="gpt-4")

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant"),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}")
])

agent = create_tool_calling_agent(llm, tools, prompt)

# Create executor
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True
)

# Run
result = agent_executor.invoke({
    "input": "What is 5 multiplied by 3, then add 2?"
})

print(result["output"])
```

**TypeScript:**
```typescript
import { ChatOpenAI } from "@langchain/openai";
import { createToolCallingAgent, AgentExecutor } from "langchain/agents";
import { ChatPromptTemplate } from "@langchain/core/prompts";
import { tool } from "@langchain/core/tools";
import { z } from "zod";

const multiplyTool = tool(
  async ({ a, b }) => a * b,
  {
    name: "multiply",
    description: "Multiply two numbers",
    schema: z.object({ a: z.number(), b: z.number() })
  }
);

const addTool = tool(
  async ({ a, b }) => a + b,
  {
    name: "add",
    description: "Add two numbers",
    schema: z.object({ a: z.number(), b: z.number() })
  }
);

const llm = new ChatOpenAI({ model: "gpt-4" });

const prompt = ChatPromptTemplate.fromMessages([
  ["system", "You are a helpful assistant"],
  ["human", "{input}"],
  ["placeholder", "{agent_scratchpad}"]
]);

const agent = await createToolCallingAgent({ llm, tools: [multiplyTool, addTool], prompt });
const agentExecutor = new AgentExecutor({ agent, tools: [multiplyTool, addTool] });

const result = await agentExecutor.invoke({
  input: "What is 5 multiplied by 3, then add 2?"
});
```

## Agent Types

### 1. Tool Calling Agent (Recommended)

Uses native function calling:

**Python:**
```python
from langchain.agents import create_tool_calling_agent

agent = create_tool_calling_agent(llm, tools, prompt)
```

**When to use:**
- OpenAI, Anthropic models
- Best reliability
- Structured tool inputs

### 2. ReAct Agent

Reasoning + Acting:

**Python:**
```python
from langchain.agents import create_react_agent

prompt = ChatPromptTemplate.from_template("""
Answer the following questions as best you can. You have access to these tools:

{tools}

Use this format:

Question: the input question
Thought: think about what to do
Action: the action to take, should be one of [{tool_names}]
Action Input: the input to the action
Observation: the result of the action
... (repeat Thought/Action/Observation as needed)
Thought: I now know the final answer
Final Answer: the final answer

Question: {input}
{agent_scratchpad}
""")

agent = create_react_agent(llm, tools, prompt)
```

### 3. Structured Chat Agent

For chat models with structured inputs:

**Python:**
```python
from langchain.agents import create_structured_chat_agent

agent = create_structured_chat_agent(llm, tools, prompt)
```

## Tools

### Built-in Tools

**Python:**
```python
from langchain_community.tools import DuckDuckGoSearchRun, WikipediaQueryRun
from langchain_community.utilities import WikipediaAPIWrapper

# Search tool
search = DuckDuckGoSearchRun()

# Wikipedia tool
wikipedia = WikipediaQueryRun(api_wrapper=WikipediaAPIWrapper())

tools = [search, wikipedia]
```

### Custom Tools

**Simple tool:**
```python
@tool
def get_word_length(word: str) -> int:
    """Returns the length of a word."""
    return len(word)
```

**Tool with error handling:**
```python
@tool
def safe_divide(a: float, b: float) -> str:
    """Safely divide two numbers."""
    try:
        result = a / b
        return f"Result: {result}"
    except ZeroDivisionError:
        return "Error: Cannot divide by zero"
```

**Tool from function:**
```python
from langchain_core.tools import StructuredTool

def search_api(query: str, max_results: int = 5) -> str:
    """Search for information."""
    # Implementation
    return f"Results for {query}"

search_tool = StructuredTool.from_function(
    func=search_api,
    name="search",
    description="Search for information online"
)
```

## Agent Executor

Controls agent execution:

**Python:**
```python
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,           # Print steps
    max_iterations=10,      # Max steps
    max_execution_time=60,  # Timeout (seconds)
    return_intermediate_steps=True  # Return reasoning
)

result = agent_executor.invoke({"input": "question"})

# Get intermediate steps
print(result["intermediate_steps"])
```

### Early Stopping

**Python:**
```python
from langchain.agents import AgentExecutor

agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    early_stopping_method="generate"  # or "force"
)

# "generate": LLM generates final answer
# "force": Returns last output
```

## Agent with Memory

**Python:**
```python
from langchain.memory import ConversationBufferMemory

memory = ConversationBufferMemory(
    memory_key="chat_history",
    return_messages=True
)

agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    memory=memory,
    verbose=True
)

# First question
result1 = agent_executor.invoke({"input": "My name is Alice"})

# Second question - remembers context
result2 = agent_executor.invoke({"input": "What's my name?"})
```

## Streaming Agents

**Python:**
```python
# Stream intermediate steps
for step in agent_executor.stream({"input": "question"}):
    print(step)
```

**Stream with callbacks:**
```python
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler

agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    callbacks=[StreamingStdOutCallbackHandler()],
    verbose=True
)
```

## Complete Example: Research Agent

**Python:**
```python
from langchain_openai import ChatOpenAI
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.tools import tool
from langchain_community.tools import DuckDuckGoSearchRun

# Tools
@tool
def calculate(expression: str) -> str:
    """Evaluate a mathematical expression."""
    try:
        result = eval(expression)
        return str(result)
    except Exception as e:
        return f"Error: {e}"

search = DuckDuckGoSearchRun()

tools = [calculate, search]

# Agent
llm = ChatOpenAI(model="gpt-4", temperature=0)

prompt = ChatPromptTemplate.from_messages([
    ("system", """You are a helpful research assistant.
    Use the search tool to find information.
    Use the calculator for math.
    Always cite your sources."""),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}")
])

agent = create_tool_calling_agent(llm, tools, prompt)

agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,
    max_iterations=5
)

# Use
result = agent_executor.invoke({
    "input": "What is the population of Tokyo? Then calculate what 10% of that is."
})

print(result["output"])
```

## Best Practices

### 1. Clear Tool Descriptions

```python
# Good: Specific description
@tool
def get_weather(city: str) -> str:
    """Get current weather for a specific city.
    Args:
        city: Name of the city (e.g., 'Tokyo', 'London')
    Returns:
        Weather information as string
    """
    pass

# Avoid: Vague
@tool
def get_weather(city: str) -> str:
    """Get weather"""
    pass
```

### 2. Set Max Iterations

```python
# Good: Prevent infinite loops
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    max_iterations=10
)

# Avoid: No limit
agent_executor = AgentExecutor(agent=agent, tools=tools)
```

### 3. Handle Tool Errors

```python
# Good: Error handling
@tool
def safe_tool(input: str) -> str:
    """Tool with error handling."""
    try:
        result = process(input)
        return result
    except Exception as e:
        return f"Error: {e}"
```

### 4. Use Verbose for Debugging

```python
# Development: Verbose on
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True  # See reasoning steps
)

# Production: Verbose off
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=False
)
```

### 5. Limit Tool Access

```python
# Good: Only necessary tools
tools = [search_tool, calculator_tool]  # Specific tools

# Avoid: Too many tools (confuses agent)
tools = [tool1, tool2, tool3, ..., tool20]  # Too many
```

## Common Patterns

### Agent + RAG

**Python:**
```python
# Create retrieval tool
@tool
def search_docs(query: str) -> str:
    """Search internal documentation."""
    docs = retriever.invoke(query)
    return "\n".join([doc.page_content for doc in docs])

tools = [search_docs, calculator, web_search]

agent_executor = AgentExecutor(agent=agent, tools=tools)
```

### Multi-Step Reasoning

**Python:**
```python
# Agent automatically breaks down complex tasks
result = agent_executor.invoke({
    "input": """
    1. Search for the population of New York
    2. Search for the population of Los Angeles
    3. Calculate which is larger and by how much
    """
})
```

### Conversational Agent

**Python:**
```python
from langchain.memory import ConversationBufferMemory

memory = ConversationBufferMemory(
    memory_key="chat_history",
    return_messages=True
)

agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    memory=memory
)

# Multi-turn conversation
agent_executor.invoke({"input": "I need help planning a trip"})
agent_executor.invoke({"input": "What's the weather like there?"})
```

## Debugging Agents

**Python:**
```python
# Enable verbose mode
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,
    return_intermediate_steps=True
)

result = agent_executor.invoke({"input": "question"})

# Inspect steps
for step in result["intermediate_steps"]:
    action, observation = step
    print(f"Action: {action}")
    print(f"Observation: {observation}")
```

## Related Documentation

- [Tools](./31-tools.md)
- [Agent Types](./32-agent-types.md)
- [Agent Executors](./33-agent-executors.md)
- [Chains](./25-chains-overview.md)
- [Memory](./36-memory-overview.md)
