# Claude Agent SDK - TypeScript API Reference

**Source:** https://docs.claude.com/en/api/agent-sdk/typescript
**Fetched:** 2025-10-11

## Installation

```bash
npm install @anthropic-ai/claude-agent-sdk
```

**Requirements:**
- Node.js (LTS version recommended)

## Core Functions

### `query()`

Primary function for interacting with Claude Code. Creates an async generator that streams messages as they arrive.

```typescript
import { query } from '@anthropic-ai/claude-agent-sdk';

async function basicQuery() {
  for await (const message of query({ prompt: "What is 2 + 2?" })) {
    console.log(message);
  }
}
```

**Parameters:**

```typescript
query(params: {
  prompt: string | AsyncIterable<string>;
  options?: ClaudeAgentOptions;
}): AsyncGenerator<string, void, unknown>
```

- `prompt`: The query string or async iterable of strings
- `options`: Optional configuration object

**Returns:**
- AsyncGenerator that yields string messages from Claude

### `tool()`

Creates a type-safe MCP tool definition.

```typescript
import { tool } from '@anthropic-ai/claude-agent-sdk';
import { z } from 'zod';

const weatherTool = tool(
  "get_weather",
  "Get current weather for a location",
  {
    location: z.string().describe("City name or coordinates"),
    units: z.enum(["celsius", "fahrenheit"]).default("celsius")
  },
  async (args) => {
    // Implementation
    const data = await fetchWeather(args.location, args.units);
    return {
      content: [{
        type: "text",
        text: `Temperature: ${data.temp}°${args.units[0].toUpperCase()}`
      }]
    };
  }
);
```

**Type Signature:**
```typescript
function tool<TSchema extends z.ZodObject<any>>(
  name: string,
  description: string,
  inputSchema: TSchema,
  handler: (args: z.infer<TSchema>) => Promise<ToolResponse>
): ToolDefinition
```

**Parameters:**
- `name` (string): Tool name (will be prefixed with `mcp__{server_name}__`)
- `description` (string): Human-readable description
- `inputSchema` (ZodObject): Zod schema for input validation
- `handler` (function): Async function that implements the tool logic

**Returns:**
- ToolDefinition object for use with `createSdkMcpServer()`

### `createSdkMcpServer()`

Creates an MCP server instance that runs in the same process.

```typescript
import { createSdkMcpServer } from '@anthropic-ai/claude-agent-sdk';

const customServer = createSdkMcpServer({
  name: "my-custom-tools",
  version: "1.0.0",
  tools: [weatherTool, calculatorTool, databaseTool]
});
```

**Type Signature:**
```typescript
function createSdkMcpServer(config: {
  name: string;
  version: string;
  tools: ToolDefinition[];
}): McpServer
```

**Parameters:**
- `name` (string): Server name
- `version` (string): Server version (semantic versioning)
- `tools` (ToolDefinition[]): Array of tool definitions

**Returns:**
- McpServer instance

## Type Definitions

### `ClaudeAgentOptions`

Configuration options for Claude agent behavior.

```typescript
interface ClaudeAgentOptions {
  model?: string;
  systemPrompt?: string;
  permissionMode?: PermissionMode;
  allowedTools?: string[];
  mcpServers?: McpServer[];
  hooks?: HookConfiguration;
  agents?: Record<string, SubagentConfig>;
}
```

**Fields:**

#### `model?: string`
Claude model to use. Examples:
- `"claude-sonnet-4.5"` (default)
- `"claude-opus-4"`
- `"claude-haiku-4"`

#### `systemPrompt?: string`
Custom system prompt defining agent behavior and role.

```typescript
const options: ClaudeAgentOptions = {
  systemPrompt: `You are an expert TypeScript developer.
    Focus on type safety and best practices.
    Provide clear explanations with code examples.`
};
```

#### `permissionMode?: PermissionMode`
Controls tool usage permissions. See [Permission Modes](#permission-modes).

#### `allowedTools?: string[]`
List of allowed tool names.

```typescript
const options: ClaudeAgentOptions = {
  allowedTools: [
    "Read",
    "Write",
    "Bash",
    "Grep",
    "Glob",
    "mcp__my-tools__custom_function"
  ]
};
```

#### `mcpServers?: McpServer[]`
Custom MCP servers to enable.

```typescript
const options: ClaudeAgentOptions = {
  mcpServers: [customServer, weatherServer]
};
```

#### `hooks?: HookConfiguration`
Event hooks for custom behavior. See [Hooks System](#hooks-system).

#### `agents?: Record<string, SubagentConfig>`
Subagent configurations. See [Subagents Guide](./07-subagents.md).

### `PermissionMode`

```typescript
type PermissionMode =
  | 'default'           // Standard permission checks
  | 'plan'              // Read-only mode (not currently supported)
  | 'acceptEdits'       // Auto-approve file edits
  | 'bypassPermissions' // Skip all permission checks
```

**Usage:**
```typescript
// Safest - requires explicit approval
const options1: ClaudeAgentOptions = {
  permissionMode: 'default'
};

// Auto-approve file edits
const options2: ClaudeAgentOptions = {
  permissionMode: 'acceptEdits'
};

// Dangerous - bypasses all checks
const options3: ClaudeAgentOptions = {
  permissionMode: 'bypassPermissions'
};
```

### `HookConfiguration`

```typescript
interface HookConfiguration {
  PreToolUse?: (event: PreToolUseEvent) => Promise<boolean>;
  PostToolUse?: (event: PostToolUseEvent) => Promise<void>;
  UserPromptSubmit?: (event: UserPromptSubmitEvent) => Promise<void>;
  SessionStart?: (event: SessionStartEvent) => Promise<void>;
  SessionEnd?: (event: SessionEndEvent) => Promise<void>;
  Stop?: (event: StopEvent) => Promise<void>;
}
```

### `ToolResponse`

```typescript
interface ToolResponse {
  content: Array<{
    type: 'text' | 'image';
    text?: string;
    source?: {
      type: 'base64';
      media_type: string;
      data: string;
    };
  }>;
  isError?: boolean;
}
```

### `SubagentConfig`

```typescript
interface SubagentConfig {
  description: string;
  prompt: string;
  tools?: string[];
  model?: string;
}
```

## Hooks System

### PreToolUse Hook

Called before a tool is executed. Can prevent tool execution by returning `false`.

```typescript
import { ClaudeAgentOptions } from '@anthropic-ai/claude-agent-sdk';

const options: ClaudeAgentOptions = {
  hooks: {
    PreToolUse: async (event) => {
      console.log(`About to use tool: ${event.toolName}`);
      console.log(`Arguments:`, event.arguments);

      // Validate or block tool usage
      if (event.toolName === 'Bash' && event.arguments.command?.includes('rm -rf')) {
        console.error('Dangerous command blocked!');
        return false; // Block execution
      }

      return true; // Allow execution
    }
  }
};
```

**Event Type:**
```typescript
interface PreToolUseEvent {
  toolName: string;
  arguments: Record<string, unknown>;
  timestamp: Date;
}
```

### PostToolUse Hook

Called after a tool is executed.

```typescript
const options: ClaudeAgentOptions = {
  hooks: {
    PostToolUse: async (event) => {
      console.log(`Tool ${event.toolName} completed in ${event.duration}ms`);
      console.log(`Result:`, event.result);

      // Log to monitoring service
      await logToMonitoring({
        tool: event.toolName,
        duration: event.duration,
        success: !event.error
      });
    }
  }
};
```

**Event Type:**
```typescript
interface PostToolUseEvent {
  toolName: string;
  arguments: Record<string, unknown>;
  result: unknown;
  error?: Error;
  duration: number;
  timestamp: Date;
}
```

### Other Hooks

```typescript
const options: ClaudeAgentOptions = {
  hooks: {
    UserPromptSubmit: async (event) => {
      console.log(`User submitted: ${event.prompt}`);
    },
    SessionStart: async (event) => {
      console.log('Session started:', event.sessionId);
    },
    SessionEnd: async (event) => {
      console.log('Session ended:', event.sessionId);
    },
    Stop: async (event) => {
      console.log('Agent stopped:', event.reason);
    }
  }
};
```

## Streaming Input

For interactive applications, use async iterables:

```typescript
import { query } from '@anthropic-ai/claude-agent-sdk';

async function* streamPrompts() {
  yield "First, analyze the project structure";
  await delay(1000);
  yield "Then identify security issues";
  await delay(1000);
  yield "Finally, suggest improvements";
}

async function interactiveAgent() {
  const customServer = createSdkMcpServer({
    name: "analysis-tools",
    version: "1.0.0",
    tools: [analysisTool]
  });

  for await (const message of query({
    prompt: streamPrompts(),
    options: {
      mcpServers: [customServer],
      allowedTools: ["mcp__analysis-tools__analyze"]
    }
  })) {
    console.log(message);
  }
}
```

## Complete Example

### Code Review Agent

```typescript
import {
  query,
  createSdkMcpServer,
  tool,
  ClaudeAgentOptions
} from '@anthropic-ai/claude-agent-sdk';
import { z } from 'zod';
import * as fs from 'fs/promises';

// Define custom tool
const analyzeCodeTool = tool(
  "analyze_code",
  "Analyze code for quality and security issues",
  {
    filePath: z.string().describe("Path to code file"),
    checkTypes: z.array(z.enum(["security", "performance", "style"])).describe("Types of checks to perform")
  },
  async (args) => {
    const code = await fs.readFile(args.filePath, 'utf-8');

    // Simulated analysis
    const issues = analyzeCodeQuality(code, args.checkTypes);

    return {
      content: [{
        type: "text",
        text: JSON.stringify(issues, null, 2)
      }]
    };
  }
);

// Create MCP server
const codeAnalysisServer = createSdkMcpServer({
  name: "code-analysis",
  version: "1.0.0",
  tools: [analyzeCodeTool]
});

// Define subagents
const agents = {
  'security-reviewer': {
    description: 'Security-focused code reviewer',
    prompt: 'You are a security expert. Focus on identifying vulnerabilities.',
    tools: ['Read', 'Grep', 'mcp__code-analysis__analyze_code'],
    model: 'claude-sonnet-4.5'
  },
  'performance-reviewer': {
    description: 'Performance optimization specialist',
    prompt: 'You are a performance expert. Identify bottlenecks and optimization opportunities.',
    tools: ['Read', 'Grep', 'mcp__code-analysis__analyze_code'],
    model: 'claude-sonnet-4.5'
  }
};

// Configure agent
const options: ClaudeAgentOptions = {
  model: 'claude-sonnet-4.5',
  systemPrompt: `You are an expert code reviewer.
    Coordinate with specialized subagents for comprehensive analysis.
    Provide actionable feedback with specific examples.`,
  mcpServers: [codeAnalysisServer],
  agents,
  hooks: {
    PreToolUse: async (event) => {
      console.log(`→ ${event.toolName}`);
      return true;
    },
    PostToolUse: async (event) => {
      console.log(`✓ ${event.toolName} (${event.duration}ms)`);
    }
  }
};

// Run code review
async function reviewCode(filePath: string) {
  for await (const message of query({
    prompt: `Please review ${filePath} for security and performance issues. Use the security-reviewer and performance-reviewer subagents.`,
    options
  })) {
    console.log(message);
  }
}

// Execute
reviewCode('./src/api/auth.ts').catch(console.error);
```

## Error Handling

```typescript
import { query } from '@anthropic-ai/claude-agent-sdk';

async function safeQuery() {
  try {
    for await (const message of query({
      prompt: "Analyze the codebase",
      options: {
        allowedTools: ["Read", "Grep"]
      }
    })) {
      console.log(message);
    }
  } catch (error) {
    if (error instanceof Error) {
      console.error('Query failed:', error.message);
      // Handle specific error types
      if (error.message.includes('Permission denied')) {
        console.error('Check tool permissions');
      }
    }
  }
}
```

## Best Practices

1. **Type Safety:** Use Zod schemas for custom tools
2. **Permission Control:** Start with `default` mode, only use `bypassPermissions` when necessary
3. **Hook Monitoring:** Use hooks to track tool usage and performance
4. **Subagents:** Delegate specialized tasks to focused subagents
5. **Error Handling:** Always wrap queries in try-catch
6. **Streaming:** Use async iterables for interactive experiences
7. **Resource Management:** Close connections and clean up resources

## See Also

- [Python API Reference](./03-api-reference-python.md)
- [Custom Tools Guide](./05-custom-tools.md)
- [Permissions Guide](./06-permissions.md)
- [Subagents Guide](./07-subagents.md)
- [Building Agents Guide](./08-building-agents-guide.md)
