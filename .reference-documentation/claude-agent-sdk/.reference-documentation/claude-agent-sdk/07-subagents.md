# Claude Agent SDK - Subagents Guide

**Source:** https://docs.claude.com/en/api/agent-sdk/subagents
**Fetched:** 2025-10-11

## Overview

Subagents are specialized AI agents within the Claude Agent SDK that can be orchestrated by a main agent to perform specific tasks. They provide context isolation, parallel execution, and specialized instructions.

## Key Benefits

### 1. Context Management
- **Separate context:** Each subagent maintains its own conversation context, independent of the main agent
- **Prevent overload:** Avoid overwhelming the main agent with specialized task details
- **Focused interactions:** Keep each agent's context relevant to its specific domain

```typescript
// Main agent coordinates, subagents handle specifics
const agents = {
  'security-reviewer': {
    // Has its own context for security analysis
    description: 'Security expert for code review',
    prompt: 'Focus only on security vulnerabilities...'
  },
  'performance-analyzer': {
    // Separate context for performance analysis
    description: 'Performance optimization specialist',
    prompt: 'Identify performance bottlenecks...'
  }
};
```

### 2. Parallelization
- **Concurrent execution:** Multiple subagents can run simultaneously
- **Faster workflows:** Dramatically reduce total execution time
- **Efficient resource use:** Maximize throughput for complex tasks

```typescript
// Both run in parallel
"Use security-reviewer and performance-analyzer to review this code"
```

### 3. Specialized Instructions
- **Tailored expertise:** Each subagent has specific domain knowledge
- **Focused prompts:** Provide detailed instructions without cluttering main agent
- **Reduced noise:** Only relevant information in each agent's context

```typescript
const agents = {
  'test-writer': {
    description: 'Expert test engineer',
    prompt: `You are a testing expert specializing in Jest and React Testing Library.
      Write comprehensive unit tests with:
      - Edge case coverage
      - Clear test descriptions
      - Mock data patterns
      - Assertion best practices`
  }
};
```

### 4. Tool Restrictions
- **Limited capabilities:** Restrict subagents to specific tools
- **Security:** Reduce risk of unintended actions
- **Controlled operations:** Each subagent only does what it needs

```typescript
const agents = {
  'read-only-analyzer': {
    description: 'Code analysis without modifications',
    prompt: 'Analyze code structure and patterns',
    tools: ['Read', 'Grep', 'Glob'] // Read-only tools
  },
  'refactoring-agent': {
    description: 'Code refactoring specialist',
    prompt: 'Refactor code following best practices',
    tools: ['Read', 'Write', 'Edit', 'Grep'] // Can modify files
  }
};
```

## Creating Subagents

### Method 1: Programmatic Definition (Recommended)

Define subagents directly in code using the `agents` parameter.

**TypeScript:**
```typescript
import { query, ClaudeAgentOptions } from '@anthropic-ai/claude-agent-sdk';

const options: ClaudeAgentOptions = {
  agents: {
    'code-reviewer': {
      description: 'Expert code review specialist focusing on quality and security',
      prompt: `You are a senior code reviewer with expertise in:
        - Code quality and maintainability
        - Security vulnerabilities
        - Performance optimization
        - Best practices and design patterns

        Provide specific, actionable feedback with examples.`,
      tools: ['Read', 'Grep', 'Glob'],
      model: 'claude-sonnet-4.5'
    },

    'test-engineer': {
      description: 'Testing specialist for comprehensive test coverage',
      prompt: `You are a testing expert specializing in:
        - Unit testing with Jest/Mocha
        - Integration testing
        - Test coverage analysis
        - Mock/stub patterns

        Write clear, maintainable tests with good coverage.`,
      tools: ['Read', 'Write', 'Grep'],
      model: 'claude-sonnet-4.5'
    },

    'documentation-writer': {
      description: 'Technical documentation specialist',
      prompt: `You are a technical writer specializing in:
        - API documentation
        - Code comments and JSDoc
        - README files
        - Architecture diagrams

        Write clear, comprehensive documentation.`,
      tools: ['Read', 'Write', 'Grep'],
      model: 'claude-sonnet-4.5'
    }
  }
};

async function reviewWithSubagents() {
  for await (const message of query({
    prompt: "Review src/auth.ts using the code-reviewer and test-engineer subagents",
    options
  })) {
    console.log(message);
  }
}
```

**Python:**
```python
from claude_agent_sdk import query, ClaudeAgentOptions

options = ClaudeAgentOptions(
    agents={
        'code-reviewer': {
            'description': 'Expert code review specialist',
            'prompt': '''You are a senior code reviewer...''',
            'tools': ['Read', 'Grep', 'Glob'],
            'model': 'claude-sonnet-4.5'
        },
        'test-engineer': {
            'description': 'Testing specialist',
            'prompt': '''You are a testing expert...''',
            'tools': ['Read', 'Write', 'Grep'],
            'model': 'claude-sonnet-4.5'
        }
    }
)

async def review_with_subagents():
    async for message in query(
        prompt="Review src/auth.ts",
        options=options
    ):
        print(message)
```

### Method 2: Filesystem-Based Definition

Create markdown files in `.claude/agents/` directories.

#### Project-Level Subagents
Located in `.claude/agents/` within your project.

**File:** `.claude/agents/security-reviewer.md`
```markdown
---
description: Security-focused code reviewer
tools: [Read, Grep, Glob]
model: claude-sonnet-4.5
---

You are a security expert specializing in:
- OWASP Top 10 vulnerabilities
- Authentication and authorization issues
- Data exposure risks
- Input validation
- Cryptography best practices

Review code for security vulnerabilities and provide specific remediation steps.
```

#### User-Level Subagents
Located in `~/.claude/agents/` for global availability.

**File:** `~/.claude/agents/api-designer.md`
```markdown
---
description: REST API design specialist
tools: [Read, Write, Grep]
model: claude-sonnet-4.5
---

You are an API design expert focusing on:
- RESTful principles
- OpenAPI/Swagger specifications
- Versioning strategies
- Error handling patterns
- Rate limiting and pagination

Design clean, consistent, well-documented APIs.
```

## Subagent Configuration

### Required Fields

```typescript
interface SubagentConfig {
  description: string;  // Used by main agent to decide when to invoke
  prompt: string;       // System prompt for the subagent
  tools?: string[];     // Allowed tools (defaults to main agent's tools)
  model?: string;       // Claude model to use (defaults to main agent's model)
}
```

### Field Details

#### `description` (required)
- Clear, concise description of the subagent's expertise
- Used by main agent to decide when to invoke this subagent
- Should indicate the specific domain or task

```typescript
{
  description: 'Database query optimization specialist'
  // Main agent knows to use this for DB performance issues
}
```

#### `prompt` (required)
- Detailed system prompt defining the subagent's role and expertise
- Can be much more specific than the main agent's prompt
- Should include constraints, guidelines, and expected output format

```typescript
{
  prompt: `You are a database optimization expert.

    Focus on:
    - Query performance analysis
    - Index recommendations
    - N+1 query detection
    - Caching strategies

    Always provide:
    1. Specific query improvements
    2. Expected performance gains
    3. Implementation steps`
}
```

#### `tools` (optional)
- Array of allowed tool names
- Restricts what the subagent can do
- Defaults to main agent's allowed tools if not specified

```typescript
{
  // Read-only analyst
  tools: ['Read', 'Grep', 'Glob']
}

{
  // Can modify code
  tools: ['Read', 'Write', 'Edit', 'Grep', 'Glob']
}

{
  // Can execute tests
  tools: ['Read', 'Bash', 'Grep']
}
```

#### `model` (optional)
- Claude model for this subagent
- Defaults to main agent's model if not specified
- Can use different models for different tasks

```typescript
{
  // Use faster model for simple tasks
  model: 'claude-haiku-4'
}

{
  // Use more capable model for complex tasks
  model: 'claude-opus-4'
}
```

## Invocation Patterns

### Automatic Invocation

The main agent automatically selects appropriate subagents based on the task and subagent descriptions.

```typescript
const options: ClaudeAgentOptions = {
  agents: {
    'security-expert': {
      description: 'Security vulnerability analysis and remediation',
      prompt: '...'
    },
    'performance-expert': {
      description: 'Performance optimization and profiling',
      prompt: '...'
    }
  }
};

// Main agent will automatically use security-expert
await query({
  prompt: "Check this code for security issues",
  options
});

// Main agent will automatically use performance-expert
await query({
  prompt: "Optimize this code for better performance",
  options
});
```

### Explicit Invocation

Users can explicitly request specific subagents.

```typescript
// Explicitly request specific subagents
await query({
  prompt: "Use security-expert and performance-expert to review auth.ts",
  options
});

// Or reference by name
await query({
  prompt: "Have the test-engineer write tests for the login function",
  options
});
```

### Parallel Invocation

Multiple subagents can run concurrently.

```typescript
await query({
  prompt: `Run these analyses in parallel:
    1. Security-expert should check for vulnerabilities
    2. Performance-expert should identify bottlenecks
    3. Test-engineer should review test coverage`,
  options
});
```

## Complete Examples

### Example 1: Comprehensive Code Review System

```typescript
import { query, ClaudeAgentOptions } from '@anthropic-ai/claude-agent-sdk';

async function comprehensiveReview(filePath: string) {
  const options: ClaudeAgentOptions = {
    model: 'claude-sonnet-4.5',
    systemPrompt: 'You coordinate code reviews by delegating to specialist subagents.',

    agents: {
      'security-reviewer': {
        description: 'Security vulnerability detection and remediation',
        prompt: `You are a security expert. Review code for:
          - Authentication/authorization issues
          - SQL injection vulnerabilities
          - XSS vulnerabilities
          - CSRF protection
          - Sensitive data exposure
          - Input validation

          Provide specific fixes with code examples.`,
        tools: ['Read', 'Grep', 'Glob'],
        model: 'claude-sonnet-4.5'
      },

      'performance-analyzer': {
        description: 'Performance optimization and profiling',
        prompt: `You are a performance expert. Analyze:
          - Time complexity issues
          - Memory leaks
          - Inefficient algorithms
          - Database query optimization
          - Caching opportunities

          Suggest specific optimizations with benchmarks.`,
        tools: ['Read', 'Grep', 'Bash'],
        model: 'claude-sonnet-4.5'
      },

      'test-coverage-analyst': {
        description: 'Test coverage analysis and improvement',
        prompt: `You are a testing expert. Review:
          - Existing test coverage
          - Missing test cases
          - Edge cases
          - Integration test needs
          - Mock/stub patterns

          Suggest specific tests to add.`,
        tools: ['Read', 'Grep', 'Glob', 'Bash'],
        model: 'claude-sonnet-4.5'
      },

      'code-quality-reviewer': {
        description: 'Code quality and maintainability',
        prompt: `You are a code quality expert. Review:
          - SOLID principles adherence
          - Design patterns usage
          - Code duplication
          - Naming conventions
          - Documentation quality

          Suggest refactoring improvements.`,
        tools: ['Read', 'Grep', 'Glob'],
        model: 'claude-sonnet-4.5'
      }
    },

    hooks: {
      PreToolUse: async (event) => {
        console.log(`→ [${event.toolName}]`);
        return true;
      },
      PostToolUse: async (event) => {
        console.log(`✓ [${event.toolName}] ${event.duration}ms`);
      }
    }
  };

  for await (const message of query({
    prompt: `Perform a comprehensive review of ${filePath}.

      Use all specialist subagents in parallel:
      - security-reviewer for security analysis
      - performance-analyzer for performance issues
      - test-coverage-analyst for test gaps
      - code-quality-reviewer for maintainability

      Consolidate findings into a prioritized action plan.`,
    options
  })) {
    console.log(message);
  }
}

comprehensiveReview('./src/api/auth.ts');
```

### Example 2: Documentation Generation System

```typescript
async function generateDocumentation(projectPath: string) {
  const options: ClaudeAgentOptions = {
    agents: {
      'api-documenter': {
        description: 'API documentation specialist',
        prompt: `Generate comprehensive API documentation including:
          - Endpoint descriptions
          - Request/response schemas
          - Authentication requirements
          - Example requests
          - Error codes`,
        tools: ['Read', 'Write', 'Grep'],
        model: 'claude-sonnet-4.5'
      },

      'code-commentor': {
        description: 'Code comment and JSDoc specialist',
        prompt: `Add clear, helpful comments and JSDoc:
          - Function purpose and parameters
          - Complex logic explanations
          - Edge case handling
          - Return value descriptions`,
        tools: ['Read', 'Write', 'Edit'],
        model: 'claude-sonnet-4.5'
      },

      'readme-writer': {
        description: 'README and getting started guide writer',
        prompt: `Create comprehensive README with:
          - Project overview
          - Installation instructions
          - Usage examples
          - Configuration options
          - Troubleshooting`,
        tools: ['Read', 'Write', 'Grep', 'Bash'],
        model: 'claude-sonnet-4.5'
      },

      'architecture-documenter': {
        description: 'System architecture documentation',
        prompt: `Document system architecture including:
          - Component diagrams
          - Data flow
          - Dependencies
          - Design decisions
          - Deployment architecture`,
        tools: ['Read', 'Write', 'Grep'],
        model: 'claude-sonnet-4.5'
      }
    }
  };

  for await (const message of query({
    prompt: `Generate complete documentation for ${projectPath}:

      1. api-documenter: Create API docs from src/api/
      2. code-commentor: Add JSDoc to all functions
      3. readme-writer: Create comprehensive README.md
      4. architecture-documenter: Document system design

      Ensure all docs are consistent and cross-referenced.`,
    options
  })) {
    console.log(message);
  }
}
```

### Example 3: Testing Pipeline

```typescript
async function testingPipeline(feature: string) {
  const options: ClaudeAgentOptions = {
    agents: {
      'unit-test-writer': {
        description: 'Unit test specialist for Jest/Mocha',
        prompt: `Write comprehensive unit tests:
          - Test all code paths
          - Edge cases and error handling
          - Mock external dependencies
          - Clear test descriptions
          - Arrange-Act-Assert pattern`,
        tools: ['Read', 'Write', 'Bash'],
        model: 'claude-sonnet-4.5'
      },

      'integration-test-writer': {
        description: 'Integration test specialist',
        prompt: `Write integration tests:
          - API endpoint testing
          - Database integration
          - External service mocking
          - End-to-end workflows`,
        tools: ['Read', 'Write', 'Bash'],
        model: 'claude-sonnet-4.5'
      },

      'test-runner': {
        description: 'Test execution and reporting',
        prompt: `Execute tests and analyze results:
          - Run test suites
          - Generate coverage reports
          - Identify failing tests
          - Suggest fixes`,
        tools: ['Read', 'Bash', 'Grep'],
        model: 'claude-sonnet-4.5'
      }
    }
  };

  for await (const message of query({
    prompt: `Create complete test suite for ${feature}:

      1. unit-test-writer: Write unit tests
      2. integration-test-writer: Write integration tests
      3. test-runner: Execute all tests and report

      Ensure 80%+ coverage and all tests pass.`,
    options
  })) {
    console.log(message);
  }
}
```

## Best Practices

### 1. Clear, Specific Descriptions
```typescript
// Good: Specific and actionable
{
  description: 'SQL query optimization specialist for PostgreSQL'
}

// Bad: Too vague
{
  description: 'Database helper'
}
```

### 2. Focused Prompts
```typescript
// Good: Detailed instructions
{
  prompt: `You are a React performance expert.

    Focus on:
    - Component re-render optimization
    - useMemo and useCallback usage
    - Code splitting strategies
    - Virtual scrolling for large lists

    Always provide:
    - Specific code changes
    - Performance impact estimates
    - Implementation steps`
}

// Bad: Generic prompt
{
  prompt: 'Help with React performance'
}
```

### 3. Appropriate Tool Restrictions
```typescript
// Good: Minimal necessary tools
{
  description: 'Code analyzer (read-only)',
  tools: ['Read', 'Grep', 'Glob']
}

// Good: Write access when needed
{
  description: 'Code refactoring specialist',
  tools: ['Read', 'Write', 'Edit', 'Grep']
}

// Bad: Unnecessary permissions
{
  description: 'Code analyzer',
  tools: ['Read', 'Write', 'Edit', 'Bash', 'Grep'] // Too many!
}
```

### 4. Use Parallel Execution
```typescript
// Good: Parallel for independent tasks
prompt: `Run in parallel:
  - security-reviewer: Check for vulnerabilities
  - performance-analyzer: Find bottlenecks`

// Bad: Sequential when parallel would work
prompt: `First use security-reviewer, then when done use performance-analyzer`
```

### 5. Coordinate with Main Agent
```typescript
// Good: Main agent coordinates, subagents specialize
{
  systemPrompt: 'You coordinate specialist subagents for comprehensive code review',
  agents: {
    'security': { /* specialized */ },
    'performance': { /* specialized */ },
    'testing': { /* specialized */ }
  }
}
```

## Related Documentation

- [Overview](./01-overview.md)
- [TypeScript API Reference](./04-api-reference-typescript.md)
- [Python API Reference](./03-api-reference-python.md)
- [Custom Tools Guide](./05-custom-tools.md)
- [Permissions Guide](./06-permissions.md)
- [Building Agents Guide](./08-building-agents-guide.md)
