# Claude Agent SDK Documentation

**Comprehensive reference documentation for the Claude Agent SDK**

**Sources:**
- Official Claude Documentation: https://docs.claude.com/en/api/agent-sdk/
- Anthropic Engineering Blog: https://www.anthropic.com/engineering/
- GitHub: https://github.com/anthropics/claude-agent-sdk-python

**Last Updated:** 2025-10-11

---

## Quick Links

### Getting Started
- [01. Overview](./01-overview.md) - Introduction to Claude Agent SDK
- [02. Getting Started](./02-getting-started.md) - Quick start guides and basic examples

### API References
- [03. Python API Reference](./03-api-reference-python.md) - Complete Python SDK documentation
- [04. TypeScript API Reference](./04-api-reference-typescript.md) - Complete TypeScript SDK documentation

### Guides
- [05. Custom Tools Guide](./05-custom-tools.md) - Creating custom tools with MCP
- [06. Permissions Guide](./06-permissions.md) - Managing agent permissions and security
- [07. Subagents Guide](./07-subagents.md) - Building specialized subagents
- [08. Building Agents Guide](./08-building-agents-guide.md) - Best practices and patterns

---

## What is the Claude Agent SDK?

The Claude Agent SDK is a comprehensive toolkit for building autonomous AI agents powered by Claude. Built on the same foundation as Claude Code, it provides:

- **Automatic context management** - Smart handling of conversation context
- **Rich tool ecosystem** - File operations, code execution, web search, and MCP extensibility
- **Advanced permissions** - Fine-grained control over agent capabilities
- **Production features** - Error handling, session management, monitoring
- **Optimized integration** - Prompt caching and performance optimizations

---

## Installation

### Python
```bash
pip install claude-agent-sdk
```

**Requirements:** Python 3.10+, Node.js, Claude Code 2.0.0+

### TypeScript/Node.js
```bash
npm install @anthropic-ai/claude-agent-sdk
```

**Requirements:** Node.js (LTS version recommended)

---

## Quick Examples

### Python: Basic Query
```python
import anyio
from claude_agent_sdk import query

async def main():
    async for message in query(prompt="What is 2 + 2?"):
        print(message)

anyio.run(main)
```

### TypeScript: Basic Query
```typescript
import { query } from '@anthropic-ai/claude-agent-sdk';

async function main() {
  for await (const message of query({ prompt: "What is 2 + 2?" })) {
    console.log(message);
  }
}

main();
```

### Custom Tools
```typescript
import { createSdkMcpServer, tool } from '@anthropic-ai/claude-agent-sdk';
import { z } from 'zod';

const weatherTool = tool(
  "get_weather",
  "Get current weather for a location",
  {
    location: z.string(),
    units: z.enum(["celsius", "fahrenheit"]).default("celsius")
  },
  async (args) => {
    // Implementation
    return {
      content: [{
        type: "text",
        text: `Weather in ${args.location}: 22°${args.units[0].toUpperCase()}`
      }]
    };
  }
);

const server = createSdkMcpServer({
  name: "weather-tools",
  version: "1.0.0",
  tools: [weatherTool]
});
```

### Subagents
```typescript
const options = {
  agents: {
    'code-reviewer': {
      description: 'Expert code review specialist',
      prompt: 'You are a senior code reviewer...',
      tools: ['Read', 'Grep', 'Glob'],
      model: 'claude-sonnet-4.5'
    }
  }
};

for await (const message of query({
  prompt: "Review src/auth.ts using code-reviewer",
  options
})) {
  console.log(message);
}
```

---

## Documentation Structure

### 01. Overview
- What is the Claude Agent SDK
- Key features and capabilities
- What you can build
- Core concepts
- Installation and setup

### 02. Getting Started
- Quick start for Python and TypeScript
- Core functions (`query()`, `tool()`, `createSdkMcpServer()`)
- Session management
- Configuration options
- Error handling

### 03. Python API Reference
- Complete API documentation
- `query()` function
- `ClaudeSDKClient()` class
- `tool()` decorator
- `create_sdk_mcp_server()` function
- `ClaudeAgentOptions` configuration
- Hooks system
- Error handling

### 04. TypeScript API Reference
- Complete API documentation
- `query()` function
- `tool()` function
- `createSdkMcpServer()` function
- Type definitions
- Hooks system
- Streaming input
- Error handling

### 05. Custom Tools Guide
- What are custom tools
- Benefits of in-process tools
- Creating tools with type safety
- Tool response formats
- Advanced examples (database, API gateway, calculator, file system, image analysis)
- Best practices

### 06. Permissions Guide
- Permission modes (`default`, `acceptEdits`, `bypassPermissions`)
- `canUseTool` callback
- Hooks for permission control
- Permission rules in `settings.json`
- Permission flow order
- Complete examples
- Best practices

### 07. Subagents Guide
- What are subagents
- Benefits (context management, parallelization, specialization, tool restrictions)
- Creating subagents (programmatic vs filesystem)
- Subagent configuration
- Invocation patterns (automatic, explicit, parallel)
- Complete examples
- Best practices

### 08. Building Agents Guide
- The core agent loop (gather context → take action → verify work)
- Context gathering strategies
- Action patterns
- Verification methods
- Complete email agent example
- Performance testing and improvement
- Best practices

---

## Core Concepts

### Authentication
Set your API key:
```bash
export ANTHROPIC_API_KEY=your_api_key_here
```

### Permission Modes
- **default** - Standard permission checks
- **acceptEdits** - Auto-approve file edits
- **bypassPermissions** - Skip all checks (dangerous!)

### Available Tools
- **Read** - Read files
- **Write** - Create/overwrite files
- **Edit** - Modify existing files
- **Bash** - Execute shell commands
- **Grep** - Search file contents
- **Glob** - Find files by pattern
- **Custom MCP tools** - Your own tools via `createSdkMcpServer()`

### Hooks
- **PreToolUse** - Before tool execution (can block)
- **PostToolUse** - After tool execution (audit/log)
- **UserPromptSubmit** - When user submits input
- **SessionStart** - At session start
- **SessionEnd** - At session end

---

## Common Use Cases

### Code Development
- Code review agents
- Refactoring assistants
- Test generation
- Documentation writers

### DevOps & SRE
- Deployment automation
- Log analysis
- Incident response
- System monitoring

### Business Automation
- Email management
- Document processing
- Data analysis
- Report generation

### Research & Analysis
- Codebase analysis
- Dependency mapping
- Security audits
- Performance profiling

---

## Best Practices

1. **Start with restrictive permissions** - Use `default` mode, only relax as needed
2. **Use subagents for specialization** - Delegate specific tasks to focused agents
3. **Implement proper error handling** - Catch and handle errors gracefully
4. **Validate inputs** - Use Zod (TypeScript) or Pydantic (Python) for type safety
5. **Monitor tool usage** - Use hooks to track and audit agent actions
6. **Test thoroughly** - Create test scenarios for common use cases
7. **Manage context** - Use subagents and compaction for long conversations
8. **Document agent behavior** - Clear system prompts and descriptions
9. **Layer security** - Combine permission modes, hooks, and settings.json rules
10. **Iterate based on feedback** - Analyze failures and improve tools/prompts

---

## Additional Resources

### Official Links
- **Documentation:** https://docs.claude.com/en/api/agent-sdk/
- **Blog:** https://www.anthropic.com/engineering/
- **Python SDK GitHub:** https://github.com/anthropics/claude-agent-sdk-python
- **TypeScript SDK GitHub:** (implied) https://github.com/anthropics/claude-agent-sdk-typescript

### Related Technologies
- **Model Context Protocol (MCP):** https://modelcontextprotocol.io/
- **Claude Console:** https://console.anthropic.com/
- **Claude Code:** https://claude.com/claude-code

### Support
- **TypeScript SDK Issues:** https://github.com/anthropics/claude-agent-sdk-typescript/issues
- **Python SDK Issues:** https://github.com/anthropics/claude-agent-sdk-python/issues

---

## License

The Claude Agent SDK (Python) is released under the MIT License.

---

## Contributing to This Documentation

This documentation was scraped and compiled from official sources on 2025-10-11. To update:

1. Check official docs for changes
2. Update relevant markdown files
3. Update this README with new sections/links
4. Update the "Last Updated" date

---

## Quick Navigation

**New to Claude Agent SDK?**
→ Start with [01. Overview](./01-overview.md)

**Want to get coding quickly?**
→ Jump to [02. Getting Started](./02-getting-started.md)

**Building with Python?**
→ See [03. Python API Reference](./03-api-reference-python.md)

**Building with TypeScript?**
→ See [04. TypeScript API Reference](./04-api-reference-typescript.md)

**Need to extend functionality?**
→ Read [05. Custom Tools Guide](./05-custom-tools.md)

**Security and permissions?**
→ Read [06. Permissions Guide](./06-permissions.md)

**Want specialized agents?**
→ Read [07. Subagents Guide](./07-subagents.md)

**Looking for patterns and best practices?**
→ Read [08. Building Agents Guide](./08-building-agents-guide.md)
