# LangChain - Quickstart

**Sources:**
- https://python.langchain.com/docs/tutorials/llm_chain/
- https://js.langchain.com/docs/tutorials/llm_chain/

**Fetched:** 2025-10-11

## First LLM Call

### Python

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4")
response = llm.invoke("What is LangChain?")
print(response.content)
```

### TypeScript

```typescript
import { ChatOpenAI } from "@langchain/openai";

const llm = new ChatOpenAI({ model: "gpt-4" });
const response = await llm.invoke("What is LangChain?");
console.log(response.content);
```

## First Chain

### Python

```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Create components
llm = ChatOpenAI()
prompt = ChatPromptTemplate.from_template("Tell me a joke about {topic}")
output_parser = StrOutputParser()

# Compose chain
chain = prompt | llm | output_parser

# Invoke
result = chain.invoke({"topic": "programming"})
print(result)
```

### TypeScript

```typescript
import { ChatOpenAI } from "@langchain/openai";
import { ChatPromptTemplate } from "@langchain/core/prompts";
import { StringOutputParser } from "@langchain/core/output_parsers";

const llm = new ChatOpenAI();
const prompt = ChatPromptTemplate.fromTemplate("Tell me a joke about {topic}");
const outputParser = new StringOutputParser();

const chain = prompt.pipe(llm).pipe(outputParser);

const result = await chain.invoke({ topic: "programming" });
console.log(result);
```

## First RAG Application

### Python

```python
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_community.vectorstores import Chroma
from langchain_core.prompts import ChatPromptTemplate
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

# Sample documents
from langchain_core.documents import Document

docs = [
    Document(page_content="LangChain is a framework for LLM applications"),
    Document(page_content="It supports chains, agents, and retrieval"),
]

# Create vector store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(docs, embeddings)

# Create retrieval chain
llm = ChatOpenAI()

prompt = ChatPromptTemplate.from_template("""
Answer based on the context:

Context: {context}

Question: {input}
""")

document_chain = create_stuff_documents_chain(llm, prompt)
retrieval_chain = create_retrieval_chain(
    vectorstore.as_retriever(),
    document_chain
)

# Query
response = retrieval_chain.invoke({"input": "What is LangChain?"})
print(response["answer"])
```

### TypeScript

```typescript
import { ChatOpenAI, OpenAIEmbeddings } from "@langchain/openai";
import { MemoryVectorStore } from "langchain/vectorstores/memory";
import { ChatPromptTemplate } from "@langchain/core/prompts";
import { createRetrievalChain } from "langchain/chains/retrieval";
import { createStuffDocumentsChain } from "langchain/chains/combine_documents";
import { Document } from "@langchain/core/documents";

const docs = [
  new Document({ pageContent: "LangChain is a framework for LLM applications" }),
  new Document({ pageContent: "It supports chains, agents, and retrieval" }),
];

const embeddings = new OpenAIEmbeddings();
const vectorstore = await MemoryVectorStore.fromDocuments(docs, embeddings);

const llm = new ChatOpenAI();
const prompt = ChatPromptTemplate.fromTemplate(`
Answer based on the context:

Context: {context}

Question: {input}
`);

const documentChain = await createStuffDocumentsChain({ llm, prompt });
const retrievalChain = await createRetrievalChain({
  retriever: vectorstore.asRetriever(),
  combineDocsChain: documentChain,
});

const response = await retrievalChain.invoke({
  input: "What is LangChain?"
});
console.log(response.answer);
```

## First Agent

### Python

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
    ("placeholder", "{agent_scratchpad}"),
])

agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# Run agent
result = agent_executor.invoke({"input": "What is 5 multiplied by 3, then add 2?"})
print(result["output"])
```

### TypeScript

```typescript
import { ChatOpenAI } from "@langchain/openai";
import { createToolCallingAgent, AgentExecutor } from "langchain/agents";
import { ChatPromptTemplate } from "@langchain/core/prompts";
import { tool } from "@langchain/core/tools";
import { z } from "zod";

const multiplyTool = tool(
  async ({ a, b }: { a: number; b: number }) => {
    return a * b;
  },
  {
    name: "multiply",
    description: "Multiply two numbers",
    schema: z.object({
      a: z.number(),
      b: z.number(),
    }),
  }
);

const addTool = tool(
  async ({ a, b }: { a: number; b: number }) => {
    return a + b;
  },
  {
    name: "add",
    description: "Add two numbers",
    schema: z.object({
      a: z.number(),
      b: z.number(),
    }),
  }
);

const tools = [multiplyTool, addTool];

const llm = new ChatOpenAI({ model: "gpt-4" });

const prompt = ChatPromptTemplate.fromMessages([
  ["system", "You are a helpful assistant"],
  ["human", "{input}"],
  ["placeholder", "{agent_scratchpad}"],
]);

const agent = await createToolCallingAgent({ llm, tools, prompt });
const agentExecutor = new AgentExecutor({ agent, tools, verbose: true });

const result = await agentExecutor.invoke({
  input: "What is 5 multiplied by 3, then add 2?"
});
console.log(result.output);
```

## Conversational RAG

### Python

```python
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_community.vectorstores import Chroma
from langchain.chains import create_history_aware_retriever, create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.messages import HumanMessage, AIMessage

# Load documents
from langchain_core.documents import Document
docs = [
    Document(page_content="LangChain supports conversational memory"),
    Document(page_content="You can build chatbots with LangChain"),
]

# Create vector store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(docs, embeddings)

# Create retriever with history awareness
llm = ChatOpenAI()

contextualize_prompt = ChatPromptTemplate.from_messages([
    ("system", "Reformulate the question based on chat history"),
    MessagesPlaceholder("chat_history"),
    ("human", "{input}"),
])

history_aware_retriever = create_history_aware_retriever(
    llm,
    vectorstore.as_retriever(),
    contextualize_prompt
)

# Create QA chain
qa_prompt = ChatPromptTemplate.from_messages([
    ("system", "Answer based on context:\n\n{context}"),
    MessagesPlaceholder("chat_history"),
    ("human", "{input}"),
])

document_chain = create_stuff_documents_chain(llm, qa_prompt)

retrieval_chain = create_retrieval_chain(
    history_aware_retriever,
    document_chain
)

# Chat with history
chat_history = []

response = retrieval_chain.invoke({
    "input": "What does LangChain support?",
    "chat_history": chat_history
})
print(response["answer"])

chat_history.append(HumanMessage(content="What does LangChain support?"))
chat_history.append(AIMessage(content=response["answer"]))

response = retrieval_chain.invoke({
    "input": "Can you elaborate?",
    "chat_history": chat_history
})
print(response["answer"])
```

## Streaming

### Python

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()

for chunk in llm.stream("Tell me a story"):
    print(chunk.content, end="", flush=True)
```

### TypeScript

```typescript
import { ChatOpenAI } from "@langchain/openai";

const llm = new ChatOpenAI();

const stream = await llm.stream("Tell me a story");

for await (const chunk of stream) {
  process.stdout.write(chunk.content);
}
```

## Next Steps

- [Chat Models](./06-chat-models.md) - Deep dive into LLMs
- [Prompt Templates](./11-prompt-templates.md) - Advanced prompting
- [RAG Basics](./21-rag-basics.md) - Complete RAG guide
- [Agents Overview](./30-agents-overview.md) - Build agents
- [Chains Overview](./25-chains-overview.md) - Compose chains

## Related Documentation

- [Overview](./01-overview.md)
- [Installation](./02-installation.md)
- [Architecture](./04-architecture.md)
