# Agentic Automation Overview

This folder houses an agent-driven alternative to the direct shell scripts in `scripts/`.
Instead of asking operators to copy+paste commands, we define Claude-based subagents that
bootstrap the Mac Studio host, audit Tailscale status, and prepare client device workflows.

## Goals

- **Repeatable automation**: invoke a single command (`npm run bootstrap`) that instructs the
  Claude Agent SDK to run the same sequence captured in `bootstrap-mac-host.sh`.
- **Context isolation**: subagents keep host automation, Tailscale management, and client docs
  separate so they stay focused.
- **Extensibility**: add new subagents (e.g., “Termux setup helper”) without rewriting the entire
  flow.

## Layout

- `claude-runner/` — Node/TypeScript harness that defines subagents and exposes CLI commands.
  - `src/index.ts` — entry point that wires together the subagents.
  - `src/agents/` — prompts and tool restrictions for each subagent.
  - `.env.example` — documents required environment variables (`ANTHROPIC_API_KEY`, optional
    `TAILSCALE_AUTH_KEY`).

## Running the agentic flow

```bash
cd claude-runner
cp .env.example .env            # add your API key(s)
npm install
npm run bootstrap               # kicks off the host bootstrap subagent
npm run tailscale-status        # runs the tailscale audit subagent
```

The host subagent still requires the local machine to provide `sudo` credentials. For unattended
flows provide a reusable `TAILSCALE_AUTH_KEY` in the environment file. Add `--dry-run` to any task
to generate the plan without executing changes (the agent will pass `DRY_RUN=1` downstream).

💡 Keep the scripts in `scripts/` intact — the subagents call into them directly, so manual and
agentic workflows stay in sync.
