# Claude Agent SDK - Overview

**Source:** https://docs.claude.com/en/api/agent-sdk/overview
**Fetched:** 2025-10-11

## What is the Claude Agent SDK?

The Claude Agent SDK is a comprehensive toolkit for building custom AI agents with advanced features. Built on top of the agent harness that powers Claude Code, the SDK provides all the building blocks you need to build production-ready agents.

## Installation

### TypeScript/Node.js
```bash
npm install @anthropic-ai/claude-agent-sdk
```

### Python
```bash
pip install claude-agent-sdk
```

### Requirements
- **Python SDK:** Python 3.10+, Node.js, Claude Code 2.0.0+
- **TypeScript SDK:** Node.js

## Key Features

### 1. Automatic Context Management
- Automatic compaction and context management to ensure your agent doesn't run out of context
- Smart handling of long conversations
- Context preservation across sessions (with ClaudeSDKClient in Python)

### 2. Rich Tool Ecosystem
- File operations (Read, Write, Edit)
- Code execution (Bash)
- Web search capabilities
- MCP (Model Context Protocol) extensibility
- Custom tool creation

### 3. Advanced Permissions
- Fine-grained control over agent capabilities
- Multiple permission modes (default, acceptEdits, bypassPermissions)
- Hook-based permission validation
- Settings.json permission rules

### 4. Production Essentials
- Built-in error handling
- Session management
- Monitoring and observability
- Streaming and batch modes

### 5. Optimized Claude Integration
- Automatic prompt caching
- Performance optimizations
- Support for multiple Claude models
- Third-party provider support (Amazon Bedrock, Google Vertex AI)

## What You Can Build

### Coding Agents
- **SRE Diagnostic Agents:** Troubleshoot system issues and analyze logs
- **Security Review Bots:** Scan code for vulnerabilities
- **Oncall Engineering Assistants:** Handle incident response
- **Code Review Agents:** Automated code quality checks

### Business Agents
- **Legal Contract Reviewers:** Analyze contracts for key terms
- **Finance Analysis Assistants:** Process financial data
- **Customer Support Agents:** Handle customer inquiries
- **Content Creation Tools:** Generate and edit content

## Core Concepts

### Authentication
1. Retrieve your API key from the [Claude Console](https://console.anthropic.com/)
2. Set the `ANTHROPIC_API_KEY` environment variable
3. Optionally configure third-party providers (Amazon Bedrock, Google Vertex AI)

### System Prompts
Define your agent's:
- Role and expertise
- Behavior patterns
- Task-specific instructions
- Constraints and guidelines

### Tool Permissions
Control what your agent can do:
- Configure allowed/disallowed tools
- Set permission strategies
- Implement custom validation logic

### Subagents
Create specialized sub-agents for:
- Parallel processing
- Context isolation
- Domain-specific tasks
- Tool restriction

### Custom Hooks
Implement custom behavior at key points:
- `PreToolUse`: Before tool execution
- `PostToolUse`: After tool execution
- `UserPromptSubmit`: When user submits input
- `SessionStart`: At session initialization
- `SessionEnd`: At session termination

### Slash Commands
Create custom commands for:
- Frequently used workflows
- Complex operations
- Team-specific actions

### Project Memory
Manage long-term context:
- Store important information
- Retrieve relevant history
- Maintain conversation state

## SDK Options

### Streaming Mode
- Interactive, low-latency user experience
- Real-time message updates
- Suitable for chat interfaces

### Single Input Mode
- Batch processing
- Deterministic runs
- Suitable for automation pipelines

## Related Resources

- **CLI Reference:** Command-line interface documentation
- **GitHub Actions Integration:** CI/CD workflows
- **Model Context Protocol (MCP):** Tool extensibility protocol
- **Common Workflows:** Best practices and patterns
- **Troubleshooting Guide:** Common issues and solutions

## Reporting Bugs

- **TypeScript SDK:** [GitHub Issues](https://github.com/anthropics/claude-agent-sdk-typescript/issues)
- **Python SDK:** [GitHub Issues](https://github.com/anthropics/claude-agent-sdk-python/issues)

## GitHub Repositories

- **Python SDK:** https://github.com/anthropics/claude-agent-sdk-python
- **TypeScript SDK:** https://github.com/anthropics/claude-agent-sdk-typescript (implied)

## Next Steps

1. Read the [Getting Started Guide](./02-getting-started.md)
2. Explore [API References](./03-api-reference-python.md)
3. Learn about [Custom Tools](./05-custom-tools.md)
4. Understand [Permissions](./06-permissions.md)
5. Implement [Subagents](./07-subagents.md)
