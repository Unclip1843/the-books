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
npm install
# optional: cp .env.example .env and set overrides
npm run bootstrap               # mac-bootstrap subagent (interactive)
npm run tailscale-status        # tailscale-auditor subagent (read-only)
```

### Environment resolution

`src/index.ts` loads secrets in this order (later entries override earlier ones):

1. Repository root `.env`
2. Repository root `.env.local`
3. `claude-runner/.env` (optional project-specific overrides)

Required variables:

- `ANTHROPIC_API_KEY` – Claude Agent SDK access token.

Optional:

- `TAILSCALE_AUTH_KEY` – allows unattended `tailscale up`; add it to `.env.local` so the agent never pauses for a browser login.
- `DRY_RUN=1` – when set manually, forces scripts to simulate actions.

### Available commands

| Command | Behaviour | Prompts |
| --- | --- | --- |
| `npm run bootstrap` | Runs preflight snapshot (script existence, sudo cache, tailscale state), lints `bootstrap-mac-host.sh`, executes `run-bootstrap-and-verify.sh`, describes results in ✅/⚠️ format. | Confirms before sudo use; either enter the password, run `sudo -v` ahead of time, or add a targeted `/etc/sudoers.d/` rule. Without `TAILSCALE_AUTH_KEY`, you may still need to approve the Tailscale login in a browser. |
| `npm run bootstrap -- --dry-run` | Same as above but exports `DRY_RUN=1` so scripts only log planned actions. | Still confirms intent but does not change the system. |
| `npm run bootstrap:auto` | Non-interactive run; sets `AUTO_CONFIRM=1` and performs the full bootstrap workflow. | Requires `TAILSCALE_AUTH_KEY` and either cached sudo (`sudo -v`) or a sudoers rule. No manual prompts. |
| `npm run tailscale-status` | Collects `tailscale status --peers=false --json`, `tailscale ip`, and conditionally `tailscale netcheck`; produces a short health report (SSH availability, tags, IPs). | Asks you to approve the read-only commands inside the Claude CLI session. |

### Subagents

| Name | Tools | Responsibilities |
| --- | --- | --- |
| `mac-bootstrap` | Bash, Read, Grep | Preflight lint check, run bootstrap/verify scripts, highlight manual follow-ups, respect `DRY_RUN` & `TAILSCALE_AUTH_KEY`. |
| `tailscale-auditor` | Bash, Read | Run read-only Tailscale diagnostics and render a concise status summary. |
| `client-advisor` | Read, Grep | Surface client workflows straight from `playbook.md` and implementation templates (no command execution). |

### Approval & safety guidelines

- **Sudo**: the orchestrator detects whether credentials are cached. If not, the agent warns you before running sudo. For unattended runs, either execute `sudo -v` once beforehand or grant passwordless access to `run-bootstrap-and-verify.sh` via `/etc/sudoers.d/`.
- **Tailscale**: scripts install the Homebrew CLI and call `sudo tailscaled install-system-daemon`. Provide a reusable auth key so the agent can run `tailscale up --ssh` without opening the App Store GUI. If no auth key is provided, the bootstrap script prints a login URL. Approve the device in the Tailscale admin console; the agent reruns `tailscale status` afterwards.
- **Read-only commands**: tailscale audits still request approval inside the Claude CLI to avoid surprises.
- **Secrets**: the agent never prints `TAILSCALE_AUTH_KEY` or the Claude API key. Rotate keys after use if operational policy requires it.

### Testing & troubleshooting

- `npx tsc --noEmit` – Type-check the harness.
- `npm run bootstrap -- --dry-run` – Fast smoke test to confirm prompts, preflight detection, and script linting.
- If a Bash command fails, the agent reports the exit code and replays the command so you can rerun it manually.
- Logs from the underlying scripts still appear in your terminal; copy them into incident reports as needed.

💡 Keep the scripts in `../scripts/` intact—the subagents call them directly. Manual and agentic workflows stay in sync by sharing the same underlying automation.
