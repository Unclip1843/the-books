# OpenAI Platform - Local Shell Tool

**Source:** https://platform.openai.com/docs/guides/codex/shell
**Fetched:** 2025-10-11

## Overview

Enable coding agents to execute commands on your local machine.

---

## Setup

```bash
# Install Codex CLI
npm install -g @openai/codex-cli

# Authenticate
codex auth login

# Enable shell tool
codex tools enable shell
```

---

## Usage

```python
# Agent can now execute shell commands
response = agent.run("List files in current directory")
# Agent uses shell tool to execute: ls -la
```

---

## Security

- Review permissions carefully
- Limit command access
- Monitor execution
- Use in sandboxed environments

---

**Source:** https://platform.openai.com/docs/guides/codex/shell
