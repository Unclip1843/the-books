# Code From Anywhere – Repository Guide

This directory contains everything you need to provision and operate the **Mac Studio + Tailscale** remote workstation described in `playbook.md`. Use this README as the entry point when you need to understand how the scripts, agentic workflow, and supporting assets fit together.

## Directory Layout

```
code-from-anywhere/
├─ playbook.md                 # Human-friendly guide (host + client workflows)
├─ rubric.md                   # Verification checklist
├─ README.md                   # ← this file
├─ implementation/             # Config templates referenced by the playbook
│  ├─ tmux.conf
│  └─ ssh/
│     ├─ config.home-dev
│     └─ sshd_config.macos
├─ scripts/                    # Bash helpers (see below)
├─ agentic/                    # Claude Agent SDK harness
└─ tests/                      # Top-level test harness (see ../../../../tests/test-code-from-anywhere.sh)
```

## Script Reference (`scripts/`)

All scripts are POSIX shell with `set -euo pipefail`. They are safe to run multiple times.

| Script | Purpose | Key Flags / Env | Notes |
| --- | --- | --- | --- |
| `bootstrap-mac-host.sh` | Idempotently prepares the Mac Studio host (pmset, Homebrew, Fail2Ban, Tailscale, SSH hardening). | `TAILSCALE_AUTH_KEY` (optional) – lets you skip browser auth; `DRY_RUN=1` (respected when invoked via agentic harness). | Requires sudo. Installs the Homebrew Tailscale CLI even if the App Store GUI is present so SSH mode works. |
| `run-bootstrap-and-verify.sh` | Wrapper that runs the tests, refreshes sudo, executes the bootstrap script, then performs post-flight checks (`tailscale status`, `tmux -V`). | Inherits same env as bootstrap script. | Use this if you want a single command that validates before/after changes. |
| `start-dev-session.sh` | Creates/attaches to a persistent `tmux` session named `dev` (override via `SESSION_NAME`). | `SESSION_NAME` (default `dev`). | Designed for client devices: copy to `~/bin` and invoke after SSH login. |

### Usage Examples

```bash
# Run the full bootstrap (interactive; sudo & tailscale login required)
./scripts/run-bootstrap-and-verify.sh

# Quick tmux attach from a client after copying the script into ~/bin
SESSION_NAME=pair ~/bin/start-dev-session
```

## Agentic Automation (`agentic/`)

The `agentic/claude-runner` package wraps the scripts with the Claude Agent SDK so you can ask an orchestrated agent to apply the playbook.

### Setup

```bash
cd agentic/claude-runner
npm install
cp .env.example .env     # optional; the runner already reads ../../../../.env(.local)
```

Required environment variables (loaded in priority order: repo `.env`, repo `.env.local`, project `.env`):

- `ANTHROPIC_API_KEY` – Claude Agent SDK access.
- `TAILSCALE_AUTH_KEY` (optional but recommended for unattended runs) – add it to `.env.local` so the agent can rejoin the tailnet without prompting you.

### Commands

| Command | What happens | Prompts |
| --- | --- | --- |
| `npm run bootstrap` | Preflight checks (script presence, sudo cache, current Tailscale state) → runs `run-bootstrap-and-verify.sh` via agent → summarizes actions & TODOs. | Confirms before running sudo; either enter the password, run `sudo -v` ahead of time, or configure `/etc/sudoers.d/` for passwordless execution. Without `TAILSCALE_AUTH_KEY`, the agent may still require you to approve the login in a browser. |
| `npm run bootstrap -- --dry-run` | Same as above but sets `DRY_RUN=1`, so scripts only report planned actions. | Prompts for confirmation but does **not** change the system. |
| `npm run tailscale-status` | Runs `tailscale status --json`, `tailscale ip`, and `tailscale netcheck` (if needed) and prints a health summary. | Requests approval in the Claude CLI before executing read-only commands. |

Agent behaviour highlights:

- **Preflight snapshot**: the orchestrator tells the agent what’s already running (e.g., tailscale IP, whether sudo is cached). If Tailscale is already up, the agent reports “already running” instead of repeating work.
- **Safety first**: commands are linted (`bash -n`) before execution, sudo usage is announced, and the agent doesn’t guess at secrets—if something must be entered (password, auth key), it asks you to do it manually.
- **Structured summaries**: every run ends with ✅ completed items, ⚠️ manual follow-ups, and 🔁 suggested next steps.

See `agentic/README.md` and `agentic/claude-runner/DESIGN.md` for deeper details.

## Tests & Validation

- `tests/test-code-from-anywhere.sh` – local harness that stubs risky commands, runs `bash -n`, and exercises the scripts end-to-end with mocks. Execute from repo root:
  ```bash
  bash tests/test-code-from-anywhere.sh
  ```
- `npm run bootstrap -- --dry-run` – quick smoke test for the agentic path.

Always run one of the above before committing changes to scripts or the agent harness.

## Security & Operational Notes

- Sudo and Tailscale approvals cannot be automated safely unless you pre-seed them. Run `sudo -v` before the agent or create a targeted rule in `/etc/sudoers.d/` if you want fully unattended bootstraps.
- Keep `TAILSCALE_AUTH_KEY` scoped to a single-use or reusable key with limited privileges; store it in `.env.local` for the agent and revoke it via the Tailscale admin console when done.
- `Fail2Ban` is installed via Homebrew and managed with `brew services`. Adjust `/opt/homebrew/etc/fail2ban/jail.local` to tune policies.
- The bootstrap workflow expects the Homebrew Tailscale CLI; the App Store GUI alone cannot provide `tailscale up --ssh`.
- Update the playbook (`playbook.md`) whenever you diverge from the documented workflow—future you will thank you.

## Related Documentation

- `playbook.md` – full narrative guide (host preparation, Tailscale, clients).
- `rubric.md` – checklist to confirm success criteria.
- `implementation/README.md` – explains the config templates you copy onto hosts/clients.
- `agentic/README.md` & `agentic/claude-runner/DESIGN.md` – deeper dive into the Claude-based automation.

Need a quick reminder of the workflow? Start in the playbook, then return here when you need the exact command or agent entry point.
