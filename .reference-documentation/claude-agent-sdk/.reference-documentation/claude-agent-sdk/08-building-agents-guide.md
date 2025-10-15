# Building Agents with the Claude Agent SDK

**Source:** https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
**Fetched:** 2025-10-11

## Overview

The Claude Agent SDK helps developers build powerful AI agents by giving Claude access to a computer. This guide covers the core principles and patterns for building effective autonomous agents.

## The Core Agent Loop

Agents follow a fundamental cycle:

```
1. Gather Context → 2. Take Action → 3. Verify Work → Repeat
```

This loop enables agents to work autonomously while maintaining quality and accuracy.

## 1. Gather Context

Before an agent can take effective action, it needs to understand the problem space.

### File System Access

Use file operations to retrieve relevant information:

```typescript
import { query } from '@anthropic-ai/claude-agent-sdk';

async function gatherProjectContext() {
  for await (const message of query({
    prompt: `Analyze the project structure in ./src and identify:
      - Main entry points
      - Key dependencies
      - Architecture patterns
      - Configuration files`,
    options: {
      allowedTools: ['Read', 'Grep', 'Glob']
    }
  })) {
    console.log(message);
  }
}
```

### Agentic Search

Implement intelligent search to find relevant information:

```typescript
const searchAgent = {
  'code-searcher': {
    description: 'Search codebase for relevant patterns and implementations',
    prompt: `You are a code search specialist.
      Find relevant code by:
      - Understanding semantic intent
      - Searching across files
      - Identifying patterns
      - Ranking results by relevance`,
    tools: ['Read', 'Grep', 'Glob']
  }
};

async function searchForPattern() {
  for await (const message of query({
    prompt: "Find all authentication implementations using code-searcher",
    options: { agents: searchAgent }
  })) {
    console.log(message);
  }
}
```

### Subagents for Parallel Processing

Use subagents to gather context in parallel:

```typescript
const contextGatherers = {
  'dependency-analyzer': {
    description: 'Analyze project dependencies and their usage',
    prompt: 'Extract all dependencies and how they are used',
    tools: ['Read', 'Grep', 'Bash']
  },
  'api-mapper': {
    description: 'Map all API endpoints and their handlers',
    prompt: 'Find and document all API routes',
    tools: ['Read', 'Grep', 'Glob']
  },
  'config-reader': {
    description: 'Read and analyze configuration files',
    prompt: 'Extract configuration and environment settings',
    tools: ['Read', 'Grep']
  }
};

async function gatherComprehensiveContext() {
  for await (const message of query({
    prompt: `Use all subagents in parallel to gather complete project context:
      - dependency-analyzer for dependencies
      - api-mapper for API structure
      - config-reader for configuration`,
    options: { agents: contextGatherers }
  })) {
    console.log(message);
  }
}
```

### Context Compaction

Manage context limits during long interactions:

```typescript
import { ClaudeSDKClient, ClaudeAgentOptions } from '@anthropic-ai/claude-agent-sdk';

async function longRunningAgent() {
  const options: ClaudeAgentOptions = {
    systemPrompt: `You are a project analyst.
      Maintain a running summary of key findings.
      Periodically compact old context.`
  };

  const client = ClaudeSDKClient(options);

  // Agent automatically manages context
  for (const task of tasks) {
    async for (const message of client.query(task)) {
      console.log(message);
    }
  }
}
```

## 2. Take Action

Once context is gathered, agents can take meaningful actions.

### Primary Tools

Define the agent's core capabilities:

```typescript
const options: ClaudeAgentOptions = {
  allowedTools: [
    'Read',      // Read files
    'Write',     // Create files
    'Edit',      // Modify files
    'Bash',      // Execute commands
    'Grep',      // Search content
    'Glob'       // Find files
  ]
};
```

### Bash Scripts for Flexibility

Use bash commands for complex operations:

```typescript
async function deploymentAgent() {
  for await (const message of query({
    prompt: `Deploy the application:
      1. Run tests
      2. Build production bundle
      3. Deploy to staging
      4. Run smoke tests`,
    options: {
      allowedTools: ['Bash', 'Read'],
      permissionMode: 'acceptEdits'
    }
  })) {
    console.log(message);
  }
}
```

### Generate Code for Precision

Create reusable, precise code:

```typescript
const codeGenerationAgent = {
  'api-generator': {
    description: 'Generate REST API endpoints with validation',
    prompt: `Generate production-ready API code with:
      - Input validation
      - Error handling
      - OpenAPI documentation
      - Unit tests`,
    tools: ['Read', 'Write', 'Grep']
  }
};

async function generateAPI() {
  for await (const message of query({
    prompt: "Generate a user registration API endpoint using api-generator",
    options: { agents: codeGenerationAgent }
  })) {
    console.log(message);
  }
}
```

### External Service Integration via MCP

Integrate with external services using Model Context Protocol:

```typescript
import { createSdkMcpServer, tool } from '@anthropic-ai/claude-agent-sdk';
import { z } from 'zod';

// Create external service tool
const slackTool = tool(
  "send_slack_message",
  "Send a message to Slack",
  {
    channel: z.string(),
    message: z.string()
  },
  async (args) => {
    await slackClient.chat.postMessage({
      channel: args.channel,
      text: args.message
    });
    return {
      content: [{ type: "text", text: "Message sent successfully" }]
    };
  }
);

const externalServices = createSdkMcpServer({
  name: "external-services",
  version: "1.0.0",
  tools: [slackTool]
});

async function notificationAgent() {
  for await (const message of query({
    prompt: "Monitor the deployment and notify #engineering on Slack when complete",
    options: {
      mcpServers: [externalServices],
      allowedTools: ['Bash', 'mcp__external-services__send_slack_message']
    }
  })) {
    console.log(message);
  }
}
```

## 3. Verify Work

Always validate agent outputs to ensure quality.

### Establish Clear Rules

Define validation criteria:

```typescript
const validationRules = `
Before completing any task:
1. Run all relevant tests
2. Check code formatting
3. Verify no errors in logs
4. Confirm output matches requirements
`;

const options: ClaudeAgentOptions = {
  systemPrompt: `You are a software development agent.
    ${validationRules}

    Never mark a task complete until all checks pass.`
};
```

### Visual Feedback for UI

For UI/formatting work, use visual verification:

```typescript
import * as fs from 'fs/promises';

const uiValidationTool = tool(
  "capture_screenshot",
  "Capture screenshot of rendered UI",
  {
    url: z.string().url(),
    selector: z.string().optional()
  },
  async (args) => {
    const screenshot = await captureScreenshot(args.url, args.selector);
    const base64 = screenshot.toString('base64');

    return {
      content: [{
        type: "image",
        source: {
          type: "base64",
          media_type: "image/png",
          data: base64
        }
      }]
    };
  }
);

async function uiDevelopmentAgent() {
  for await (const message of query({
    prompt: `Create a login form, then verify it looks correct:
      1. Generate the component
      2. Capture screenshot
      3. Verify visual design matches requirements`,
    options: {
      mcpServers: [createSdkMcpServer({
        name: "ui-tools",
        version: "1.0.0",
        tools: [uiValidationTool]
      })]
    }
  })) {
    console.log(message);
  }
}
```

### Use Another LLM to Judge Quality

Employ a second agent for quality assurance:

```typescript
const qaAgent = {
  'quality-checker': {
    description: 'Quality assurance and validation specialist',
    prompt: `You are a QA engineer.
      Validate work by:
      - Reviewing code quality
      - Checking test coverage
      - Verifying documentation
      - Testing edge cases

      Provide pass/fail assessment with specific issues.`,
    tools: ['Read', 'Bash', 'Grep'],
    model: 'claude-opus-4' // Use more capable model for validation
  }
};

async function validatedDevelopment() {
  // Development agent creates feature
  for await (const message of query({
    prompt: "Implement user authentication feature",
    options: { allowedTools: ['Read', 'Write', 'Edit', 'Bash'] }
  })) {
    console.log(message);
  }

  // QA agent validates
  for await (const message of query({
    prompt: "Use quality-checker to validate the authentication implementation",
    options: { agents: qaAgent }
  })) {
    console.log(message);
  }
}
```

## Complete Example: Email Agent

A comprehensive example implementing all three principles.

```typescript
import { query, createSdkMcpServer, tool, ClaudeAgentOptions } from '@anthropic-ai/claude-agent-sdk';
import { z } from 'zod';
import { ImapFlow } from 'imapflow';
import * as nodemailer from 'nodemailer';

// 1. GATHER CONTEXT: Define search capabilities
const searchEmailTool = tool(
  "search_emails",
  "Search email history for relevant messages",
  {
    query: z.string().describe("Search query"),
    folder: z.string().default("INBOX"),
    limit: z.number().default(10)
  },
  async (args) => {
    const client = new ImapFlow({/* config */});
    await client.connect();

    const messages = await client.search({
      body: args.query
    }, { max: args.limit });

    const results = messages.map(msg => ({
      from: msg.from,
      subject: msg.subject,
      date: msg.date,
      body: msg.text
    }));

    await client.logout();

    return {
      content: [{
        type: "text",
        text: JSON.stringify(results, null, 2)
      }]
    };
  }
);

const fetchInboxTool = tool(
  "fetch_inbox",
  "Fetch recent emails from inbox",
  {
    count: z.number().default(20)
  },
  async (args) => {
    const client = new ImapFlow({/* config */});
    await client.connect();

    const messages = await client.fetch(
      { seq: `1:${args.count}` },
      { envelope: true, bodyStructure: true }
    );

    await client.logout();

    return {
      content: [{
        type: "text",
        text: JSON.stringify(Array.from(messages), null, 2)
      }]
    };
  }
);

// 2. TAKE ACTION: Define email composition
const sendEmailTool = tool(
  "send_email",
  "Send an email",
  {
    to: z.string().email(),
    subject: z.string(),
    body: z.string()
  },
  async (args) => {
    const transporter = nodemailer.createTransport({/* config */});

    await transporter.sendMail({
      to: args.to,
      subject: args.subject,
      text: args.body,
      html: args.body
    });

    return {
      content: [{
        type: "text",
        text: `Email sent to ${args.to}`
      }]
    };
  }
);

// 3. VERIFY: Validation tools
const validateEmailTool = tool(
  "validate_email",
  "Validate email address format",
  {
    email: z.string()
  },
  async (args) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const isValid = emailRegex.test(args.email);

    return {
      content: [{
        type: "text",
        text: isValid ? "Valid email address" : "Invalid email address"
      }],
      isError: !isValid
    };
  }
);

// Create MCP server with all tools
const emailServer = createSdkMcpServer({
  name: "email-tools",
  version: "1.0.0",
  tools: [searchEmailTool, fetchInboxTool, sendEmailTool, validateEmailTool]
});

// Define specialized subagents
const emailAgents = {
  'email-searcher': {
    description: 'Search and retrieve relevant emails from history',
    prompt: `You are an email search specialist.
      Search email history efficiently and summarize relevant findings.`,
    tools: [
      'mcp__email-tools__search_emails',
      'mcp__email-tools__fetch_inbox'
    ]
  },

  'email-composer': {
    description: 'Compose professional emails',
    prompt: `You are a professional email writer.
      Compose clear, concise, professional emails.
      Always validate email addresses before sending.`,
    tools: [
      'mcp__email-tools__send_email',
      'mcp__email-tools__validate_email'
    ]
  },

  'tone-checker': {
    description: 'Review email tone and professionalism',
    prompt: `You are a communication expert.
      Review emails for:
      - Professional tone
      - Clarity
      - Appropriate formality
      - Grammar and spelling

      Suggest improvements.`,
    tools: ['Read']
  }
};

// Main email agent
async function emailAgent() {
  const options: ClaudeAgentOptions = {
    systemPrompt: `You are an email management assistant.
      Coordinate subagents to handle email tasks efficiently.

      Workflow:
      1. Use email-searcher to find relevant context
      2. Use email-composer to draft responses
      3. Use tone-checker to validate before sending`,

    mcpServers: [emailServer],

    agents: emailAgents,

    hooks: {
      PreToolUse: async (event) => {
        console.log(`→ ${event.toolName}`);
        // Extra validation for sending emails
        if (event.toolName === 'mcp__email-tools__send_email') {
          console.log('⚠️  About to send email, validating...');
        }
        return true;
      },
      PostToolUse: async (event) => {
        console.log(`✓ ${event.toolName} (${event.duration}ms)`);
      }
    }
  };

  // Example: Respond to customer inquiry
  for await (const message of query({
    prompt: `A customer asked about our refund policy.
      1. Search previous refund-related emails
      2. Draft a helpful response
      3. Validate tone and content
      4. Send the email`,
    options
  })) {
    console.log(message);
  }
}

emailAgent().catch(console.error);
```

## Recommendations for Improvement

### 1. Test Agent Performance Thoroughly

```typescript
// Create test scenarios
const testScenarios = [
  { task: "Handle customer complaint", expectedOutcome: "Professional response sent" },
  { task: "Schedule meeting", expectedOutcome: "Calendar invite sent" },
  { task: "Refund request", expectedOutcome: "Refund processed and confirmed" }
];

async function testAgent() {
  for (const scenario of testScenarios) {
    console.log(`Testing: ${scenario.task}`);

    const result = await runAgent(scenario.task);

    if (result.includes(scenario.expectedOutcome)) {
      console.log('✓ Test passed');
    } else {
      console.log('✗ Test failed');
      console.log('Expected:', scenario.expectedOutcome);
      console.log('Got:', result);
    }
  }
}
```

### 2. Analyze Failure Cases

```typescript
const options: ClaudeAgentOptions = {
  hooks: {
    PostToolUse: async (event) => {
      if (event.error) {
        // Log failures for analysis
        await logFailure({
          tool: event.toolName,
          args: event.arguments,
          error: event.error,
          timestamp: event.timestamp
        });

        // Adjust behavior based on failure patterns
        if (failureCount[event.toolName] > 3) {
          console.warn(`Tool ${event.toolName} failing frequently`);
          // Consider disabling or replacing tool
        }
      }
    }
  }
};
```

### 3. Adjust Search APIs and Tools

Continuously improve based on usage patterns:

```typescript
// Track tool usage
const toolUsageStats = new Map();

const options: ClaudeAgentOptions = {
  hooks: {
    PostToolUse: async (event) => {
      const count = toolUsageStats.get(event.toolName) || 0;
      toolUsageStats.set(event.toolName, count + 1);

      // Optimize frequently used tools
      if (count > 100) {
        console.log(`High usage tool: ${event.toolName}`);
        // Consider adding caching, indexing, etc.
      }
    }
  }
};
```

### 4. Create Representative Test Sets

```typescript
// Collect real-world examples
const productionExamples = await collectRealUsage();

// Create test dataset
const testDataset = productionExamples.map(example => ({
  input: example.userQuery,
  expectedTools: example.toolsUsed,
  expectedOutcome: example.result,
  context: example.contextData
}));

// Validate against test set
for (const test of testDataset) {
  const result = await runAgent(test.input, test.context);
  validateResult(result, test.expectedOutcome);
}
```

## Key Takeaways

1. **Gather Context First:** Use file system, search, and subagents to understand before acting
2. **Take Precise Action:** Leverage bash, code generation, and external integrations
3. **Always Verify:** Implement validation rules, visual checks, and quality reviews
4. **Iterate and Improve:** Test thoroughly, analyze failures, and refine tools
5. **Use Subagents:** Delegate specialized tasks for better results
6. **Manage Context:** Implement compaction for long-running agents

## Related Documentation

- [Overview](./01-overview.md)
- [Getting Started](./02-getting-started.md)
- [Python API Reference](./03-api-reference-python.md)
- [TypeScript API Reference](./04-api-reference-typescript.md)
- [Custom Tools Guide](./05-custom-tools.md)
- [Permissions Guide](./06-permissions.md)
- [Subagents Guide](./07-subagents.md)
