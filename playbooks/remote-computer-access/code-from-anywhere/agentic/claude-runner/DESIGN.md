# Code From Anywhere Agent Design (Claude SDK)

## Objectives

1. **Automate the Mac Studio bootstrap end to end** using Claude Agent SDK subagents so operators only approve privileged actions (e.g., sudo, Tailscale auth).
2. **Handle errors gracefully** with retry guidance, self-healing steps, and human escalation when automation can’t continue safely.
3. **Stay extensible** for new workflows (client device onboarding, maintenance routines, auditing) without rewiring the entire orchestration.

## High-Level Architecture

```
┌───────────────────────────────────────────────────────────────┐
│ Orchestrator CLI (src/index.ts)                               │
│   • Parses command (`bootstrap`, `tailscale-status`, …)        │
│   • Instantiates agent runtime with shared context             │
│   • Streams messages + handles structured events               │
└───────────────────────────────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────┐
│ Claude Agent SDK                                               │
│   • Main agent delegates to subagents via `agents` map          │
│   • Tools: Bash (command exec), Read/Grep (context fetch)       │
│   • Maintains separate context per subagent                     │
└───────────────────────────────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────┐
│ Subagents (src/agents/index.ts)                                │
│   • mac-bootstrap: host provisioning, hardening                 │
│   • tailscale-auditor: connectivity checks                      │
│   • client-advisor: doc helper                                  │
│   • (future) termux-onboarder, blink-helper, maintenance-runner │
└───────────────────────────────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────┐
│ Tool Layer                                                     │
│   • `Bash`: executes commands/scripts with captured stdout/err │
│   • `Read`/`Grep`: surface repo files (playbook, configs)       │
│   • (future) `Edit`: patch files when automation needs updates  │
└───────────────────────────────────────────────────────────────┘

## Subagent Responsibilities

### mac-bootstrap
- **Inputs**: path to scripts, optional `TAILSCALE_AUTH_KEY`, sudo availability (`sudo -n true`).
- **Flow**:
  1. Run quick health checks (presence of brew, tailscale CLI).
  2. Execute `scripts/run-bootstrap-and-verify.sh` with environment variables (so we reuse the canonical script).
  3. If `sudo` fails (no tty password), prompt the operator:
     ```
     ⚠️ Need sudo password to continue. Please re-run the command and enter it when prompted.
     ```
  4. On Tailscale login URLs, remind the operator to follow the link; afterwards re-run `tailscale status`.
  5. Summaries include:
     - What changed (brew installs, services enabled).
     - Outstanding manual steps.
     - Next checks for clients.

### tailscale-auditor
- Runs `tailscale status --peers=false --json`, parses JSON (via `jq` if available or manual parsing).
- Detects:
  - SSH capability (`ssh` feature true/false).
  - Device approval status, last seen time.
  - IP/MagicDNS values.
- On degraded state, suggests remediation (restart tailscaled, run `tailscale up`, re-approve device).

### client-advisor
- Pure documentation agent:
  - Uses `Read`/`Grep` on `playbook.md` and `implementation/`.
  - Delivers tailored instructions per client (MacBook, Blink, Termux).
  - Points to relevant files (tmux.conf, ssh configs).

### Future Subagents
- **termux-onboarder**: run Termux-specific commands via SSH relay (requires remote execution).
- **maintenance-runner**: handle updates (`brew upgrade`, `tailscale status`, log rotation).
- **incident-responder**: gather logs (`log show`, Fail2Ban status) and compile reports.

## Error Handling Strategy

1. **Pre-checks** before destructive commands: confirm scripts exist, check `command -v`.
2. **Guardrails** for `sudo`: always confirm `sudo -n true` before invoking; if failure, request user password.
3. **Retry logic**:
   - For transient errors (network, brew locks), attempt 1–2 retries with cool-off (`sleep 10`).
   - For persistent failure, escalate with actionable guidance.
4. **Structured summaries**: capture successes, warnings, failures, manual TODOs.
5. **Logs**: leverage `run-bootstrap-and-verify.sh` to save logs to temp dir; agent references log path in recap.

## Prompts & Tooling Notes

- All prompts explicitly instruct agents to ask for human input only when:
  - `sudo` password is required and non-cached.
  - Tailscale login/auth key missing.
  - Irreversible actions need confirmation.
- Encourage conservative execution:
  - Validate scripts with `bash -n` before run.
  - Inspect file diffs (future `Edit` tool).
- Use environment fallback:
  - `TAILSCALE_AUTH_KEY` for unattended runs.
  - `SUDO_PASSWORD` (optional) via askpass helper if we decide to script password entry (requires secure storage strategy).

## Orchestrator Enhancements (Roadmap)

- **Command registry**: map CLI commands to scenario definitions (bootstrap, audit, maintenance).
- **Dry-run mode**: set env flag to replace `sudo`/command exec with echoes (useful for planning).
- **Progress events**: parse tool outputs and convert to structured events (start/complete/fail) for richer UX.
- **State persistence**: emit JSON summary file (`tmp/agent-report.json`) for CI dashboards or audit logs.
- **Notification hooks**: optional Slack/webhook integration when runs finish or fail.

## Security & Secrets

- `.env` precedence:
  1. Repo-level `.env` (shared defaults).
  2. Repo-level `.env.local` (host-specific secrets such as API & Tailscale keys).
  3. Project `.env` (agent-specific overrides).
- Never print secrets in agent outputs; mask `TAILSCALE_AUTH_KEY` and API keys.
- Consider macOS Keychain integration for sudo/SSH passwords in future iterations.

## Open Questions

1. Do we want a single “uber agent” that orchestrates multiple tasks sequentially (bootstrap + audit + report)?
2. Should the agent proactively patch configs (`sshd_config`, `tmux.conf`) if they drift, or only alert?
3. What remote execution capabilities do we need for client onboarding (e.g., pushing configs over SSH)?
4. How will we expose this agent in UI/CLI (e.g., integrate with Cursor, custom CLI, or remote automation server)?

Addressing these will guide the next iteration of implementation beyond the skeleton currently committed.
