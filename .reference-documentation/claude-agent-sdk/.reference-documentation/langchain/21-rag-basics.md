# LangChain - RAG Basics

**Sources:**
- https://python.langchain.com/docs/tutorials/rag/
- https://python.langchain.com/docs/how_to/#qa-with-rag
- https://js.langchain.com/docs/tutorials/rag/

**Fetched:** 2025-10-11

## What is RAG?

**Retrieval Augmented Generation** combines:
1. **Retrieval** - Find relevant documents
2. **Augmentation** - Add documents to prompt
3. **Generation** - LLM generates answer

```
User Question
    ↓
Retrieve Relevant Docs
    ↓
Combine Question + Docs
    ↓
LLM Generation
    ↓
Answer
```

**Why RAG:**
- Ground responses in your data
- Reduce hallucinations
- Keep information up-to-date
- No model fine-tuning needed

## Basic RAG Pipeline

**Python:**
```python
from langchain_community.document_loaders import TextLoader
from langchain.text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_community.vectorstores import Chroma
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser

# 1. Load documents
loader = TextLoader("knowledge_base.txt")
documents = loader.load()

# 2. Split into chunks
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)
splits = text_splitter.split_documents(documents)

# 3. Create embeddings and vector store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(splits, embeddings)

# 4. Create retriever
retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

# 5. Create prompt
prompt = ChatPromptTemplate.from_template("""
Answer the question based only on the following context:

{context}

Question: {question}

Answer:""")

# 6. Create LLM
llm = ChatOpenAI(model="gpt-4")

# 7. Create RAG chain
rag_chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

# 8. Query
question = "What is the main topic of this document?"
answer = rag_chain.invoke(question)
print(answer)
```

**TypeScript:**
```typescript
import { TextLoader } from "langchain/document_loaders/fs/text";
import { RecursiveCharacterTextSplitter } from "langchain/text_splitter";
import { OpenAIEmbeddings, ChatOpenAI } from "@langchain/openai";
import { MemoryVectorStore } from "langchain/vectorstores/memory";
import { ChatPromptTemplate } from "@langchain/core/prompts";
import { RunnableSequence, RunnablePassthrough } from "@langchain/core/runnables";
import { StringOutputParser } from "@langchain/core/output_parsers";

// 1-2. Load and split
const loader = new TextLoader("knowledge_base.txt");
const documents = await loader.load();

const textSplitter = new RecursiveCharacterTextSplitter({
  chunkSize: 1000,
  chunkOverlap: 200
});
const splits = await textSplitter.splitDocuments(documents);

// 3-4. Vector store and retriever
const embeddings = new OpenAIEmbeddings();
const vectorstore = await MemoryVectorStore.fromDocuments(splits, embeddings);
const retriever = vectorstore.asRetriever({ k: 3 });

// 5. Prompt
const prompt = ChatPromptTemplate.fromTemplate(`
Answer based on context:

{context}

Question: {question}
`);

// 6-7. Chain
const llm = new ChatOpenAI({ model: "gpt-4" });

const ragChain = RunnableSequence.from([
  {
    context: retriever,
    question: new RunnablePassthrough()
  },
  prompt,
  llm,
  new StringOutputParser()
]);

// 8. Query
const answer = await ragChain.invoke("What is the main topic?");
```

## Simple RAG with Helper Functions

**Python:**
```python
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

# Create document chain
document_chain = create_stuff_documents_chain(llm, prompt)

# Create retrieval chain
retrieval_chain = create_retrieval_chain(retriever, document_chain)

# Query
response = retrieval_chain.invoke({"input": "What is LangChain?"})
print(response["answer"])

# Also returns source documents
print(response["context"])
```

## Conversational RAG

Add chat history to RAG:

**Python:**
```python
from langchain.chains import create_history_aware_retriever
from langchain_core.prompts import MessagesPlaceholder
from langchain_core.messages import HumanMessage, AIMessage

# Contextualize question prompt
contextualize_q_prompt = ChatPromptTemplate.from_messages([
    ("system", "Given chat history and latest question, formulate a standalone question"),
    MessagesPlaceholder("chat_history"),
    ("human", "{input}")
])

# Create history-aware retriever
history_aware_retriever = create_history_aware_retriever(
    llm,
    retriever,
    contextualize_q_prompt
)

# QA prompt
qa_prompt = ChatPromptTemplate.from_messages([
    ("system", "Answer based on context:\\n\\n{context}"),
    MessagesPlaceholder("chat_history"),
    ("human", "{input}")
])

# Create chains
document_chain = create_stuff_documents_chain(llm, qa_prompt)
rag_chain = create_retrieval_chain(history_aware_retriever, document_chain)

# Conversation
chat_history = []

# First question
response1 = rag_chain.invoke({
    "input": "What is LangChain?",
    "chat_history": chat_history
})
print(response1["answer"])

# Update history
chat_history.extend([
    HumanMessage(content="What is LangChain?"),
    AIMessage(content=response1["answer"])
])

# Follow-up question
response2 = rag_chain.invoke({
    "input": "What are its main features?",
    "chat_history": chat_history
})
print(response2["answer"])
```

## RAG with Sources

Return source documents:

**Python:**
```python
from langchain_core.runnables import RunnableParallel

# Chain that returns answer and source docs
rag_chain_with_source = RunnableParallel(
    {
        "context": retriever,
        "question": RunnablePassthrough()
    }
).assign(answer=prompt | llm | StrOutputParser())

# Invoke
result = rag_chain_with_source.invoke("What is LangChain?")

print("Answer:", result["answer"])
print("\nSources:")
for doc in result["context"]:
    print(f"- {doc.metadata.get('source')}: {doc.page_content[:100]}...")
```

## Streaming RAG

Stream the response:

**Python:**
```python
# Create streaming chain
rag_chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

# Stream
for chunk in rag_chain.stream("What is LangChain?"):
    print(chunk, end="", flush=True)
```

## RAG Patterns

### Pattern 1: Stuff

Stuff all documents into prompt (simplest):

**Python:**
```python
from langchain.chains.combine_documents import create_stuff_documents_chain

# All docs in one prompt
chain = create_stuff_documents_chain(llm, prompt)
```

**Pros:**
- Simple
- One LLM call
- All context available

**Cons:**
- Limited by context window
- Expensive for many docs

### Pattern 2: Map-Reduce

Process docs individually, then combine:

**Python:**
```python
from langchain.chains import MapReduceDocumentsChain, ReduceDocumentsChain
from langchain.chains.llm import LLMChain

# Map prompt - process each doc
map_template = "Summarize: {context}"
map_prompt = ChatPromptTemplate.from_template(map_template)
map_chain = LLMChain(llm=llm, prompt=map_prompt)

# Reduce prompt - combine summaries
reduce_template = "Combine these summaries: {context}"
reduce_prompt = ChatPromptTemplate.from_template(reduce_template)
reduce_chain = LLMChain(llm=llm, prompt=reduce_prompt)

# Combine
combine_documents_chain = ReduceDocumentsChain(
    combine_documents_chain=reduce_chain
)

map_reduce_chain = MapReduceDocumentsChain(
    llm_chain=map_chain,
    reduce_documents_chain=combine_documents_chain
)
```

**Pros:**
- Handles many documents
- Parallelizable

**Cons:**
- Multiple LLM calls (expensive)
- May lose context between docs

### Pattern 3: Refine

Iteratively refine answer:

**Python:**
```python
from langchain.chains import RefineDocumentsChain

# Initial prompt
initial_prompt = ChatPromptTemplate.from_template(
    "Answer based on context:\\n{context}\\n\\nQuestion: {question}"
)

# Refine prompt
refine_prompt = ChatPromptTemplate.from_template(
    "Original answer: {existing_answer}\\n"
    "Refine with: {context}"
)

refine_chain = RefineDocumentsChain(
    initial_llm_chain=LLMChain(llm=llm, prompt=initial_prompt),
    refine_llm_chain=LLMChain(llm=llm, prompt=refine_prompt)
)
```

**Pros:**
- Iteratively improves
- Good for long documents

**Cons:**
- Sequential (slow)
- Many LLM calls

## Complete RAG Application

**Python:**
```python
class RAGApplication:
    def __init__(self, documents_path: str):
        # Load documents
        loader = DirectoryLoader(documents_path, glob="**/*.txt")
        documents = loader.load()

        # Split
        splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000,
            chunk_overlap=200
        )
        splits = splitter.split_documents(documents)

        # Create vector store
        embeddings = OpenAIEmbeddings()
        self.vectorstore = Chroma.from_documents(
            splits,
            embeddings,
            persist_directory="./chroma_db"
        )

        # Create retriever
        self.retriever = self.vectorstore.as_retriever(
            search_kwargs={"k": 3}
        )

        # Create chain
        llm = ChatOpenAI(model="gpt-4", temperature=0)

        prompt = ChatPromptTemplate.from_template("""
        Answer the question based on the context below.
        If you cannot answer based on the context, say so.

        Context: {context}

        Question: {question}

        Answer:""")

        self.chain = (
            {"context": self.retriever, "question": RunnablePassthrough()}
            | prompt
            | llm
            | StrOutputParser()
        )

    def query(self, question: str) -> str:
        """Query the RAG system."""
        return self.chain.invoke(question)

    def query_with_sources(self, question: str) -> dict:
        """Query and return sources."""
        docs = self.retriever.invoke(question)
        answer = self.chain.invoke(question)

        return {
            "answer": answer,
            "sources": [
                {
                    "content": doc.page_content,
                    "metadata": doc.metadata
                }
                for doc in docs
            ]
        }

# Usage
rag = RAGApplication("./documents")

# Simple query
answer = rag.query("What is LangChain?")
print(answer)

# With sources
result = rag.query_with_sources("What is LangChain?")
print(result["answer"])
print("\nSources:")
for source in result["sources"]:
    print(f"- {source['metadata'].get('source')}")
```

## Best Practices

### 1. Chunk Size

```python
# For Q&A: Smaller chunks (more precise)
splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=50
)

# For summarization: Larger chunks (more context)
splitter = RecursiveCharacterTextSplitter(
    chunk_size=2000,
    chunk_overlap=200
)
```

### 2. Number of Retrieved Documents

```python
# Balance relevance and context
retriever = vectorstore.as_retriever(
    search_kwargs={"k": 3}  # 3-5 is typical
)
```

### 3. Clear Prompts

```python
# Good: Specific instructions
prompt = ChatPromptTemplate.from_template("""
Answer the question using ONLY the context below.
If the answer is not in the context, say "I don't know".

Context: {context}

Question: {question}

Answer:""")

# Avoid: Vague
prompt = ChatPromptTemplate.from_template("{context}\\n{question}")
```

### 4. Handle "I Don't Know"

```python
prompt = ChatPromptTemplate.from_template("""
Answer based on context. If not in context, say "I don't have that information".

Context: {context}

Question: {question}""")
```

### 5. Use Metadata

```python
# Include source attribution
prompt = ChatPromptTemplate.from_template("""
Answer based on context. Cite sources when possible.

Context: {context}

Question: {question}

Answer (include sources):""")
```

## Common Issues

### Issue 1: Irrelevant Retrieval

**Solution:** Improve embeddings or use metadata filtering

```python
retriever = vectorstore.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={
        "score_threshold": 0.7,  # Higher threshold
        "k": 3
    }
)
```

### Issue 2: Context Window Exceeded

**Solution:** Reduce chunk size or number of docs

```python
# Smaller chunks
splitter = RecursiveCharacterTextSplitter(chunk_size=500)

# Fewer docs
retriever = vectorstore.as_retriever(search_kwargs={"k": 2})
```

### Issue 3: Slow Response

**Solution:** Use streaming or caching

```python
# Stream response
for chunk in rag_chain.stream(question):
    print(chunk, end="")

# Cache embeddings
from langchain.embeddings import CacheBackedEmbeddings
cached_embeddings = CacheBackedEmbeddings.from_bytes_store(...)
```

## RAG Evaluation

**Python:**
```python
def evaluate_rag(questions_and_answers):
    """Simple RAG evaluation."""
    results = []

    for qa in questions_and_answers:
        question = qa["question"]
        expected = qa["answer"]

        # Get RAG answer
        actual = rag_chain.invoke(question)

        # Simple comparison
        results.append({
            "question": question,
            "expected": expected,
            "actual": actual,
            "match": expected.lower() in actual.lower()
        })

    accuracy = sum(r["match"] for r in results) / len(results)
    print(f"Accuracy: {accuracy:.2%}")

    return results

# Usage
test_cases = [
    {"question": "What is X?", "answer": "X is..."},
    {"question": "How does Y work?", "answer": "Y works by..."}
]

results = evaluate_rag(test_cases)
```

## Related Documentation

- [Retrievers](./20-retrievers.md)
- [RAG Advanced](./22-rag-advanced.md)
- [Vector Stores](./19-vector-stores.md)
- [Embeddings](./18-embeddings.md)
- [Chains](./25-chains-overview.md)
