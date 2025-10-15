# Claude Agent SDK - Permissions Guide

**Source:** https://docs.claude.com/en/api/agent-sdk/permissions
**Fetched:** 2025-10-11

## Overview

The Claude Agent SDK provides four complementary ways to control tool usage and manage permissions:

1. **Permission Modes** - High-level permission policies
2. **`canUseTool` Callback** - Runtime permission validation
3. **Hooks** - Event-based control at tool execution boundaries
4. **Permission Rules** - Declarative rules in `settings.json`

## Permission Flow Order

When a tool is about to be used, the SDK checks permissions in this order:

```
1. PreToolUse Hook
2. Ask Rules (settings.json)
3. Deny Rules (settings.json)
4. Permission Mode Check
5. Allow Rules (settings.json)
6. canUseTool Callback
7. Tool Execution
8. PostToolUse Hook
```

If any step denies the tool, execution is blocked.

## 1. Permission Modes

Permission modes provide high-level control over tool usage behavior.

### Available Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `default` | Standard permission checks | General use, balanced security |
| `plan` | Read-only tool usage | Preview mode (not currently supported) |
| `acceptEdits` | Auto-approve file edits | Isolated file operations |
| `bypassPermissions` | Skip all permission checks | Testing only (dangerous!) |

### Setting Permission Mode

**TypeScript:**
```typescript
import { query, ClaudeAgentOptions } from '@anthropic-ai/claude-agent-sdk';

const options: ClaudeAgentOptions = {
  permissionMode: 'default' // or 'acceptEdits', 'bypassPermissions'
};

async function runWithMode() {
  for await (const message of query({
    prompt: "Refactor the authentication module",
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
    permission_mode="default"  # or "acceptEdits", "bypassPermissions"
)

async def run_with_mode():
    async for message in query(
        prompt="Refactor the authentication module",
        options=options
    ):
        print(message)
```

### Mode Details

#### `default` - Standard Permissions
- Requires explicit approval for sensitive operations
- Prompts user for file edits, deletions, and bash commands
- **Best for:** Interactive development, production environments

```typescript
const options: ClaudeAgentOptions = {
  permissionMode: 'default'
};
```

#### `acceptEdits` - Auto-Approve Edits
- Automatically approves file read/write/edit operations
- Still prompts for dangerous operations (delete, bash)
- **Best for:** Code refactoring, documentation updates, isolated file work

```typescript
const options: ClaudeAgentOptions = {
  permissionMode: 'acceptEdits'
};
```

#### `bypassPermissions` - No Checks (Dangerous!)
- Skips ALL permission checks
- No prompts, no validation
- **Best for:** Testing in isolated sandbox only
- **Never use in production!**

```typescript
const options: ClaudeAgentOptions = {
  permissionMode: 'bypassPermissions' // Use with extreme caution!
};
```

## 2. canUseTool Callback

Runtime callback for dynamic permission decisions.

**TypeScript:**
```typescript
const options: ClaudeAgentOptions = {
  canUseTool: async (toolName, args) => {
    // Block dangerous bash commands
    if (toolName === 'Bash') {
      const cmd = args.command as string;
      if (cmd.includes('rm -rf') || cmd.includes('sudo')) {
        console.error(`Blocked dangerous command: ${cmd}`);
        return false;
      }
    }

    // Restrict file access
    if (toolName === 'Read' || toolName === 'Write') {
      const path = args.file_path as string;
      if (path.includes('.env') || path.includes('secrets')) {
        console.error(`Blocked access to sensitive file: ${path}`);
        return false;
      }
    }

    return true; // Allow all other tools
  }
};
```

**Python:**
```python
async def can_use_tool(tool_name: str, args: dict) -> bool:
    # Block dangerous bash commands
    if tool_name == 'Bash':
        cmd = args.get('command', '')
        if 'rm -rf' in cmd or 'sudo' in cmd:
            print(f"Blocked dangerous command: {cmd}")
            return False

    # Restrict file access
    if tool_name in ['Read', 'Write']:
        path = args.get('file_path', '')
        if '.env' in path or 'secrets' in path:
            print(f"Blocked access to sensitive file: {path}")
            return False

    return True

options = ClaudeAgentOptions(
    can_use_tool=can_use_tool
)
```

## 3. Hooks for Permission Control

### PreToolUse Hook

Called before tool execution. Return `false` to block.

**TypeScript:**
```typescript
const options: ClaudeAgentOptions = {
  hooks: {
    PreToolUse: async (event) => {
      console.log(`Checking permission for: ${event.toolName}`);

      // Log all tool usage
      await logToolUsage({
        tool: event.toolName,
        args: event.arguments,
        timestamp: event.timestamp
      });

      // Block during maintenance hours
      const hour = new Date().getHours();
      if (hour >= 2 && hour <= 4) {
        console.error('Operations blocked during maintenance window');
        return false;
      }

      return true; // Allow
    }
  }
};
```

### PostToolUse Hook

Called after tool execution. Cannot block, but can log/audit.

**TypeScript:**
```typescript
const options: ClaudeAgentOptions = {
  hooks: {
    PostToolUse: async (event) => {
      // Audit trail
      await auditLog({
        tool: event.toolName,
        args: event.arguments,
        result: event.result,
        duration: event.duration,
        success: !event.error
      });

      // Alert on errors
      if (event.error) {
        await sendAlert({
          message: `Tool ${event.toolName} failed`,
          error: event.error,
          context: event.arguments
        });
      }
    }
  }
};
```

## 4. Permission Rules (settings.json)

Declarative permission rules defined in your project's `.claude/settings.json`.

### File Location

```
.claude/settings.json
```

### Rule Format

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Read(~/.zshrc)",
      "Write(src/**/*.ts)"
    ],
    "deny": [
      "Bash(curl:*)",
      "Bash(rm:*)",
      "Read(./.env)",
      "Write(/etc/**)"
    ],
    "ask": [
      "Bash(git push*)",
      "Write(package.json)"
    ]
  }
}
```

### Rule Syntax

#### Allow Rules
Pre-approve specific tool + argument patterns.

```json
{
  "permissions": {
    "allow": [
      "Read(src/**/*.ts)",           // Read any TypeScript file in src
      "Write(docs/**/*.md)",          // Write any markdown in docs
      "Bash(npm run test)",           // Run tests
      "Bash(git status)",             // Check git status
      "Grep(*.js)"                    // Search JavaScript files
    ]
  }
}
```

#### Deny Rules
Block specific tool + argument patterns.

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf*)",                // Block destructive deletes
      "Bash(curl*)",                  // Block external requests
      "Read(.env*)",                  // Block env files
      "Read(**/secrets/**)",          // Block secrets directories
      "Write(/etc/**)",               // Block system files
      "Write(*.sh)"                   // Block shell scripts
    ]
  }
}
```

#### Ask Rules
Prompt user for specific operations.

```json
{
  "permissions": {
    "ask": [
      "Bash(git push*)",              // Confirm before pushing
      "Bash(npm publish*)",           // Confirm before publishing
      "Write(package.json)",          // Confirm package changes
      "Write(tsconfig.json)"          // Confirm config changes
    ]
  }
}
```

### Pattern Matching

- `*` - Matches any characters within a segment
- `**` - Matches any characters across segments
- `~` - Home directory
- Exact matches - No wildcards

**Examples:**
```json
{
  "permissions": {
    "allow": [
      "Read(src/utils/*.ts)",         // Matches src/utils/foo.ts
      "Read(src/**/*.test.ts)",       // Matches any .test.ts in src tree
      "Read(~/Documents/**)",         // Matches anything in Documents
      "Bash(npm run lint)"            // Exact match only
    ]
  }
}
```

## Combining Permission Methods

Layer multiple permission controls for robust security:

```typescript
import { query, ClaudeAgentOptions } from '@anthropic-ai/claude-agent-sdk';

const options: ClaudeAgentOptions = {
  // 1. Set base permission mode
  permissionMode: 'default',

  // 2. Add runtime validation
  canUseTool: async (toolName, args) => {
    // Custom logic
    if (toolName === 'Bash') {
      const cmd = args.command as string;
      // Check against allowed commands list
      return isCommandAllowed(cmd);
    }
    return true;
  },

  // 3. Add hooks for monitoring
  hooks: {
    PreToolUse: async (event) => {
      console.log(`→ ${event.toolName}`);
      await logToMonitoring(event);
      return true;
    },
    PostToolUse: async (event) => {
      console.log(`✓ ${event.toolName} (${event.duration}ms)`);
      await auditToolUsage(event);
    }
  }
};

// 4. settings.json provides declarative rules
// (loaded automatically from .claude/settings.json)
```

## Complete Examples

### Example 1: Secure Code Review Agent

```typescript
import { query, ClaudeAgentOptions } from '@anthropic-ai/claude-agent-sdk';

async function secureCodeReview() {
  const options: ClaudeAgentOptions = {
    // Only allow read operations and safe bash commands
    permissionMode: 'default',

    // Restrict tools
    allowedTools: [
      'Read',
      'Grep',
      'Glob',
      'Bash' // Only specific bash commands via canUseTool
    ],

    // Runtime validation
    canUseTool: async (toolName, args) => {
      if (toolName === 'Bash') {
        const cmd = args.command as string;
        const allowedCommands = ['git diff', 'git log', 'npm run lint'];
        if (!allowedCommands.some(allowed => cmd.startsWith(allowed))) {
          console.error(`Blocked unauthorized command: ${cmd}`);
          return false;
        }
      }
      return true;
    },

    hooks: {
      PreToolUse: async (event) => {
        await auditLog('TOOL_USE_ATTEMPT', event);
        return true;
      },
      PostToolUse: async (event) => {
        await auditLog('TOOL_USE_COMPLETE', event);
      }
    }
  };

  for await (const message of query({
    prompt: "Review the auth module for security issues",
    options
  })) {
    console.log(message);
  }
}
```

### Example 2: Automated Refactoring Agent

```typescript
async function automatedRefactoring() {
  const options: ClaudeAgentOptions = {
    // Auto-approve file edits
    permissionMode: 'acceptEdits',

    // Limit to TypeScript files
    canUseTool: async (toolName, args) => {
      if (toolName === 'Write' || toolName === 'Edit') {
        const path = args.file_path as string;
        if (!path.endsWith('.ts') && !path.endsWith('.tsx')) {
          console.error(`Blocked write to non-TypeScript file: ${path}`);
          return false;
        }
      }
      return true;
    }
  };

  for await (const message of query({
    prompt: "Refactor the API layer to use async/await",
    options
  })) {
    console.log(message);
  }
}
```

### Example 3: Read-Only Analysis Agent

```typescript
async function readOnlyAnalysis() {
  const options: ClaudeAgentOptions = {
    permissionMode: 'default',

    // Only allow read operations
    allowedTools: ['Read', 'Grep', 'Glob'],

    // Block any write attempts (defense in depth)
    canUseTool: async (toolName, args) => {
      const writingTools = ['Write', 'Edit', 'Bash'];
      if (writingTools.includes(toolName)) {
        console.error(`Blocked write operation: ${toolName}`);
        return false;
      }
      return true;
    }
  };

  for await (const message of query({
    prompt: "Analyze the codebase structure and dependencies",
    options
  })) {
    console.log(message);
  }
}
```

## Best Practices

### 1. Start Restrictive
Begin with `default` mode and only relax permissions as needed.

```typescript
// Good: Start strict
const options = {
  permissionMode: 'default',
  allowedTools: ['Read', 'Grep']
};

// Gradually add permissions
options.allowedTools.push('Write');
options.permissionMode = 'acceptEdits';
```

### 2. Layer Security
Use multiple permission methods together.

```typescript
const options: ClaudeAgentOptions = {
  permissionMode: 'default',           // Base policy
  allowedTools: [...],                 // Tool allowlist
  canUseTool: validateTool,            // Runtime checks
  hooks: { PreToolUse: auditTool }     // Monitoring
  // Plus settings.json rules
};
```

### 3. Audit Everything
Log all tool usage for security review.

```typescript
const options: ClaudeAgentOptions = {
  hooks: {
    PreToolUse: async (event) => {
      await securityLog.write({
        action: 'TOOL_ATTEMPT',
        tool: event.toolName,
        args: event.arguments,
        timestamp: event.timestamp,
        user: getCurrentUser()
      });
      return true;
    }
  }
};
```

### 4. Never Bypass in Production
```typescript
// NEVER do this in production!
const badOptions: ClaudeAgentOptions = {
  permissionMode: 'bypassPermissions'
};

// Instead, use appropriate controls
const goodOptions: ClaudeAgentOptions = {
  permissionMode: 'acceptEdits', // If auto-approve is needed
  canUseTool: validateTool,      // With runtime validation
  hooks: { PreToolUse: audit }   // And monitoring
};
```

### 5. Use settings.json for Team Rules
Define shared rules in `.claude/settings.json`:

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf*)",
      "Read(**/.env*)",
      "Write(/etc/**)"
    ],
    "ask": [
      "Bash(git push*)",
      "Bash(npm publish*)"
    ]
  }
}
```

## Troubleshooting

### Permission Denied Errors

If a tool is unexpectedly blocked:

1. Check permission mode
2. Review `allowedTools` list
3. Check `canUseTool` callback logic
4. Review `.claude/settings.json` deny rules
5. Check PreToolUse hook return value

### Debugging Permissions

```typescript
const debugOptions: ClaudeAgentOptions = {
  hooks: {
    PreToolUse: async (event) => {
      console.log('=== Permission Check ===');
      console.log('Tool:', event.toolName);
      console.log('Args:', event.arguments);
      console.log('Timestamp:', event.timestamp);
      console.log('=====================');
      return true; // Log but allow
    }
  }
};
```

## Related Documentation

- [Overview](./01-overview.md)
- [Python API Reference](./03-api-reference-python.md)
- [TypeScript API Reference](./04-api-reference-typescript.md)
- [Custom Tools Guide](./05-custom-tools.md)
- [Subagents Guide](./07-subagents.md)
