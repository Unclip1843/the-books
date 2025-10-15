# LangChain - Architecture

**Sources:**
- https://python.langchain.com/docs/concepts/architecture/

**Fetched:** 2025-10-11

## Package Structure

### Core Packages

```
langchain-core       # Base abstractions
    ├── Runnable     # Base interface
    ├── Messages     # Chat messages
    ├── Prompts      # Prompt templates
    └── Outputs      # Output parsers

langchain            # Chains & agents
    ├── Chains       # Pre-built chains
    ├── Agents       # Agent implementations
    └── Memory       # Conversation memory

langchain-community  # Integrations
    ├── LLMs         # LLM integrations
    ├── VectorStores # Vector DB integrations
    └── Tools        # Tool integrations
```

## Runnable Interface

Everything implements `Runnable`:

```python
class Runnable:
    def invoke(self, input): ...
    def stream(self, input): ...
    def batch(self, inputs): ...
    async def ainvoke(self, input): ...
    async def astream(self, input): ...
    async def abatch(self, inputs): ...
```

## Design Principles

1. **Composability** - Build complex from simple
2. **Modularity** - Swap components easily
3. **Streaming** - Stream all the way through
4. **Async** - Native async support

## Related Documentation

- [LCEL](./26-lcel.md)
- [Runnable Interface](./25-chains-overview.md)
