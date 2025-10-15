# Claude API - Computer Use

**Sources:**
- https://docs.claude.com/en/docs/build-with-claude/computer-use
- https://github.com/anthropics/anthropic-cookbook

**Fetched:** 2025-10-11

## Overview

Computer Use is a groundbreaking feature that enables Claude to interact with computer interfaces like a human would - viewing screens, moving the mouse, clicking buttons, and typing text. This allows Claude to perform tasks that require desktop automation.

## ⚠️ Beta Feature

Computer Use is currently in **public beta**:
- Requires beta header: `anthropic-beta: computer-use-2025-01-24`
- May have limitations and edge cases
- Best used in sandboxed environments
- Not recommended for production without human oversight

## Supported Models

| Model | Computer Use | Tool Version |
|-------|--------------|--------------|
| Claude Sonnet 4.5 | ✅ Yes | computer_20250124 |
| Claude Sonnet 4 | ✅ Yes | computer_20250124 |
| Claude Sonnet 3.7 | ✅ Yes | computer_20250124 |
| Claude Opus 4.1 | ✅ Yes | computer_20250124 |
| Claude Haiku | ❌ No | N/A |

## How It Works

Computer Use operates through a **multi-agent loop**:

```
1. Claude analyzes the screen (screenshot)
2. Claude decides on an action (click, type, scroll, etc.)
3. Your application executes the action
4. Screenshot is taken
5. Claude sees result and decides next action
6. Repeat until task complete
```

## Capabilities

### Supported Actions

| Action | Description | Parameters |
|--------|-------------|------------|
| `key` | Press keyboard keys | `text` (key to press) |
| `type` | Type text | `text` (string to type) |
| `mouse_move` | Move cursor | `coordinate` ([x, y]) |
| `left_click` | Click left button | None |
| `left_click_drag` | Drag with left button | `coordinate` ([x, y] destination) |
| `right_click` | Click right button | None |
| `middle_click` | Click middle button | None |
| `double_click` | Double-click | None |
| `screenshot` | Capture screen | None |
| `cursor_position` | Get cursor location | None |
| `scroll` | Scroll up/down | `clicks` (positive=down, negative=up) |

## Python Implementation

### Setup

```python
import anthropic
import base64
from PIL import ImageGrab
import pyautogui

client = anthropic.Anthropic()

# Enable computer use beta
COMPUTER_USE_BETA_FLAG = "computer-use-2025-01-24"
```

### Tool Definition

```python
computer_tool = {
    "type": "computer_20250124",
    "name": "computer",
    "display_width_px": 1920,
    "display_height_px": 1080,
    "display_number": 1
}
```

### Basic Computer Use Agent

```python
def take_screenshot():
    """Capture current screen"""
    screenshot = ImageGrab.grab()
    buffer = io.BytesIO()
    screenshot.save(buffer, format='PNG')
    return base64.b64encode(buffer.getvalue()).decode()

def execute_computer_action(action, **params):
    """Execute computer action"""
    if action == "mouse_move":
        x, y = params['coordinate']
        pyautogui.moveTo(x, y)

    elif action == "left_click":
        pyautogui.click()

    elif action == "type":
        pyautogui.write(params['text'])

    elif action == "key":
        pyautogui.press(params['text'])

    elif action == "screenshot":
        return take_screenshot()

    elif action == "scroll":
        pyautogui.scroll(params['clicks'] * 10)

    # Add delay for UI responsiveness
    time.sleep(0.5)

def computer_use_agent(task):
    """Run computer use task"""
    messages = [{
        "role": "user",
        "content": task
    }]

    while True:
        # Get current screenshot
        screenshot_b64 = take_screenshot()

        # Add screenshot to context
        messages.append({
            "role": "user",
            "content": [{
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": "image/png",
                    "data": screenshot_b64
                }
            }]
        })

        # Request Claude's next action
        response = client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=2048,
            tools=[computer_tool],
            messages=messages,
            betas=[COMPUTER_USE_BETA_FLAG]
        )

        if response.stop_reason == "end_turn":
            # Task complete
            final_text = next(
                (block.text for block in response.content if hasattr(block, "text")),
                None
            )
            return final_text

        if response.stop_reason == "tool_use":
            # Execute computer actions
            messages.append({"role": "assistant", "content": response.content})

            tool_results = []
            for block in response.content:
                if block.type == "tool_use":
                    result = execute_computer_action(
                        block.input.get("action"),
                        **block.input
                    )
                    tool_results.append({
                        "type": "tool_result",
                        "tool_use_id": block.id,
                        "content": result or "Action completed"
                    })

            messages.append({"role": "user", "content": tool_results})

# Usage
result = computer_use_agent("Open a web browser and search for 'anthropic claude'")
print(result)
```

### Safer Implementation with Guardrails

```python
class SafeComputerUseAgent:
    def __init__(self, allowed_actions=None, sandbox_mode=True):
        self.client = anthropic.Anthropic()
        self.allowed_actions = allowed_actions or [
            "mouse_move", "left_click", "type", "screenshot", "scroll"
        ]
        self.sandbox_mode = sandbox_mode
        self.action_log = []

    def is_action_safe(self, action, params):
        """Validate action safety"""
        if action not in self.allowed_actions:
            return False, f"Action {action} not allowed"

        # Check for dangerous keyboard combinations
        if action == "key" and params.get("text") in ["cmd+q", "alt+f4"]:
            return False, "Dangerous key combination blocked"

        # Validate coordinates are in screen bounds
        if action in ["mouse_move", "left_click_drag"]:
            x, y = params.get("coordinate", [0, 0])
            if x < 0 or y < 0 or x > 1920 or y > 1080:
                return False, "Coordinates out of bounds"

        return True, None

    def execute_with_safety(self, action, **params):
        """Execute action with safety checks"""
        is_safe, error = self.is_action_safe(action, params)

        if not is_safe:
            logging.warning(f"Blocked unsafe action: {error}")
            return {"error": error}

        # Log action
        self.action_log.append({
            "action": action,
            "params": params,
            "timestamp": time.time()
        })

        # Execute
        return execute_computer_action(action, **params)
```

## TypeScript Implementation

```typescript
import Anthropic from '@anthropic-ai/sdk';
import robot from 'robotjs';
import screenshot from 'screenshot-desktop';

const client = new Anthropic();

const computerTool: Anthropic.Tool = {
  type: 'computer_20250124',
  name: 'computer',
  display_width_px: 1920,
  display_height_px: 1080,
  display_number: 1,
};

async function takeScreenshot(): Promise<string> {
  const img = await screenshot();
  return img.toString('base64');
}

function executeAction(action: string, params: any): void {
  switch (action) {
    case 'mouse_move':
      const [x, y] = params.coordinate;
      robot.moveMouse(x, y);
      break;

    case 'left_click':
      robot.mouseClick();
      break;

    case 'type':
      robot.typeString(params.text);
      break;

    case 'key':
      robot.keyTap(params.text);
      break;

    case 'scroll':
      // Platform-specific scrolling
      robot.scrollMouse(0, params.clicks);
      break;
  }

  // Small delay
  robot.setMouseDelay(100);
}

async function computerUseAgent(task: string): Promise<string> {
  const messages: Anthropic.MessageParam[] = [{
    role: 'user',
    content: task,
  }];

  while (true) {
    const screenshotB64 = await takeScreenshot();

    messages.push({
      role: 'user',
      content: [{
        type: 'image',
        source: {
          type: 'base64',
          media_type: 'image/png',
          data: screenshotB64,
        },
      }],
    });

    const response = await client.messages.create({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 2048,
      tools: [computerTool],
      messages,
      betas: ['computer-use-2025-01-24'],
    });

    if (response.stop_reason === 'end_turn') {
      const textBlock = response.content.find(
        (block): block is Anthropic.TextBlock => block.type === 'text'
      );
      return textBlock?.text || 'Task completed';
    }

    if (response.stop_reason === 'tool_use') {
      messages.push({ role: 'assistant', content: response.content });

      const toolResults: Anthropic.ToolResultBlockParam[] = [];

      for (const block of response.content) {
        if (block.type === 'tool_use') {
          executeAction(block.input.action, block.input);
          toolResults.push({
            type: 'tool_result',
            tool_use_id: block.id,
            content: 'Action completed',
          });
        }
      }

      messages.push({ role: 'user', content: toolResults });
    }
  }
}
```

## Common Use Cases

### 1. Web Automation

```python
task = """
Navigate to anthropic.com and:
1. Click on the 'Documentation' link
2. Search for 'API reference'
3. Take a screenshot of the results
"""

result = computer_use_agent(task)
```

### 2. Form Filling

```python
task = """
Fill out the form with:
- Name: John Doe
- Email: john@example.com
- Message: Testing computer use
Then click Submit
"""

result = computer_use_agent(task)
```

### 3. Application Testing

```python
task = """
Test the calculator app:
1. Open Calculator
2. Enter: 25 * 4 + 10
3. Verify the result is 110
4. Report success or failure
"""

result = computer_use_agent(task)
```

### 4. Data Entry

```python
data = [
    {"name": "Alice", "score": 95},
    {"name": "Bob", "score": 87},
]

task = f"""
Enter this data into the spreadsheet:
{json.dumps(data, indent=2)}

Format as a table with headers.
"""

result = computer_use_agent(task)
```

## Best Practices

### 1. Use Sandboxed Environments

```python
# Run in Docker container or VM
# Isolate from sensitive data
# Limit network access
```

### 2. Add Action Delays

```python
def execute_with_delay(action, **params):
    execute_computer_action(action, **params)
    time.sleep(0.5)  # Wait for UI to update
```

### 3. Implement Action Limits

```python
MAX_ACTIONS = 50

def computer_use_agent_with_limit(task, max_actions=MAX_ACTIONS):
    action_count = 0

    while action_count < max_actions:
        # ... agent loop ...
        action_count += 1

    if action_count >= max_actions:
        return "Error: Max actions exceeded"
```

### 4. Validate Screen Resolution

```python
def validate_display_settings():
    actual_width, actual_height = pyautogui.size()

    if (actual_width != computer_tool["display_width_px"] or
        actual_height != computer_tool["display_height_px"]):
        print("Warning: Display resolution mismatch")
        print(f"Expected: {computer_tool['display_width_px']}x{computer_tool['display_height_px']}")
        print(f"Actual: {actual_width}x{actual_height}")
```

### 5. Log All Actions

```python
import logging

logging.basicConfig(
    filename='computer_use.log',
    level=logging.INFO,
    format='%(asctime)s - %(message)s'
)

def execute_and_log(action, **params):
    logging.info(f"Action: {action}, Params: {params}")
    result = execute_computer_action(action, **params)
    logging.info(f"Result: {result}")
    return result
```

## Security Considerations

### Risks

⚠️ **Prompt Injection** - Malicious content on screen could influence Claude
⚠️ **Sensitive Data Access** - Could interact with private information
⚠️ **Unintended Actions** - May perform unintended clicks or commands
⚠️ **Credential Exposure** - Could access saved passwords or keys

### Mitigations

✅ Run in isolated sandbox environment
✅ Block access to sensitive applications
✅ Implement action whitelisting
✅ Add human-in-the-loop confirmation
✅ Monitor and log all actions
✅ Set strict timeouts and action limits
✅ Use read-only mode when possible

## Pricing

Computer Use follows standard tool use pricing plus:

- **Screenshot tokens:** ~1,500-3,000 tokens per image (1920x1080)
- **Tool definitions:** 466-499 tokens per request
- **Agentic loops:** Multiple back-and-forth exchanges

**Example Cost (Sonnet 4.5):**
```
10 screenshot actions:
10 × 2,000 tokens × $3.00/MTok = $0.06

Plus standard input/output tokens
```

## Limitations

- ❌ **Accuracy** - May misclick or misinterpret UI elements
- ❌ **Speed** - Slower than direct API automation
- ❌ **Reliability** - UI changes can break workflows
- ❌ **Context Window** - Screenshots consume token space
- ❌ **Resolution Dependent** - Works best at specified resolutions
- ❌ **No Video** - Only sees static screenshots
- ❌ **Platform Specific** - Behavior varies by OS

## Troubleshooting

### Issue: Claude Can't Find UI Element

**Cause:** Low resolution or unclear screenshot
**Solution:** Use higher resolution, ensure good contrast

### Issue: Actions Too Fast

**Cause:** No delays between actions
**Solution:** Add `time.sleep()` after each action

### Issue: Mouse Position Incorrect

**Cause:** Resolution mismatch
**Solution:** Ensure display settings match actual resolution

### Issue: High Costs

**Cause:** Too many screenshots
**Solution:** Optimize task to minimize screen captures

## Complete Example: Web Research

```python
def web_research_task(topic):
    """Use computer to research a topic"""
    task = f"""
Research "{topic}" by:
1. Opening a web browser
2. Searching for "{topic}"
3. Clicking the top 3 results
4. Reading and summarizing key points
5. Creating a summary document

Provide the summary when done.
"""

    return computer_use_agent(task)

# Usage
summary = web_research_task("Anthropic Claude API")
print(summary)
```

## Related Documentation

- [Tool Use](./08-tool-use.md)
- [Vision](./07-vision.md)
- [Messages API](./03-messages-api.md)
- [Python SDK](./04-python-sdk.md)
- [TypeScript SDK](./05-typescript-sdk.md)
- [Models](./10-models.md)
