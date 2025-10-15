# Scripts Overview

These helpers implement the automation described in `playbook.md`. They assume you are running them from the repository root (`playbooks/remote-computer-access/code-from-anywhere/scripts/...`). All scripts exit on error (`set -euo pipefail`) and are designed to be idempotent.

## bootstrap-mac-host.sh

Prepares a Mac Studio (Ventura/Sonoma) host for remote development:

1. Forces the machine to stay awake (`pmset`).
2. Installs Xcode CLI tools and Homebrew (if missing), then `tmux`, `fail2ban`, and the **Homebrew Tailscale CLI** (the App Store build is ignored because it cannot run `tailscale up --ssh`).
3. Ensures Homebrew’s shell environment is loaded for the target user.
4. Installs and loads the `tailscaled` system daemon so the Homebrew CLI can run headlessly.
5. Manages `brew services` for Fail2Ban (runs under sudo).
6. Enables Remote Login (SSH) and starts Tailscale with opinionated flags (`--ssh --accept-dns --advertise-tags=tag:devhost`).
7. Verifies `tailscale status` at the end.

**Usage**

```bash
./playbooks/remote-computer-access/code-from-anywhere/scripts/bootstrap-mac-host.sh
```

**Environment variables**

- `TAILSCALE_AUTH_KEY` (optional): pass a reusable auth key to avoid interactive sign-in.
- `DRY_RUN=1` (optional): when set, the script will echo planned actions instead of executing (used by the agent harness).

**Requirements**

- Run on macOS with an admin user. Sudo is required.
- Internet access for Homebrew/Tailscale installers.
- If you previously installed Tailscale from the App Store, the script will still install the Homebrew CLI to enable SSH support.

## run-bootstrap-and-verify.sh

Convenience wrapper that:

1. Runs `tests/test-code-from-anywhere.sh` (ensures scripts pass `bash -n`, etc.).
2. Refreshes sudo credentials (`sudo -v`) and keeps them alive during execution.
3. Executes `bootstrap-mac-host.sh` (honouring `TAILSCALE_AUTH_KEY`, `DRY_RUN`).
4. Performs post-flight checks (`tailscale status`, `tmux -V`, Homebrew package verification).

**Usage**

```bash
./playbooks/remote-computer-access/code-from-anywhere/scripts/run-bootstrap-and-verify.sh
```

Use this when you want a single command that validates before and after bootstrapping. The agentic harness calls this script directly.

## automate-bootstrap.sh

One-shot automation for unattended hosts. It:

1. Loads environment variables from `.env` / `.env.local` so `TAILSCALE_AUTH_KEY` is available.
2. Refreshes sudo credentials and keeps them alive during the run.
3. Installs the Homebrew Tailscale CLI, installs the `tailscaled` system daemon, and logs in with the auth key if needed.
4. Installs the agent harness dependencies (`npm install` in `agentic/claude-runner`).
5. Delegates to the Claude agent (`npm run bootstrap:auto`), which runs the standard bootstrap/verification scripts.

**Usage**

```bash
./playbooks/remote-computer-access/code-from-anywhere/scripts/automate-bootstrap.sh
```

**Prerequisites**

- `TAILSCALE_AUTH_KEY` must be defined in `.env.local`.
- You will still be prompted once for your macOS sudo password (the script runs `sudo -v` immediately). For passwordless operation, add an entry to `/etc/sudoers.d/` granting this script NOPASSWD rights.

## start-dev-session.sh

Ensures a reusable tmux session exists and attaches to it. Intended for client devices after SSH login.

```bash
./playbooks/remote-computer-access/code-from-anywhere/scripts/start-dev-session.sh
# or copy to ~/bin and call it there
```

Environment variables:

- `SESSION_NAME` – defaults to `dev`. Override to create/connect to another session (`SESSION_NAME=pair ./start-dev-session.sh`).

## Logging & Troubleshooting

- `bootstrap-mac-host.sh` and `run-bootstrap-and-verify.sh` echo each step; rerun with `DRY_RUN=1` to see what would happen without executing commands.
- When invoked by the agent harness, command transcripts and summaries are streamed in the Claude CLI; copy them into incident notes if something fails.
- Consult macOS Console (`log show --predicate 'process == "sshd"' --style syslog --last 1h`) and `/opt/homebrew/var/log/fail2ban.log` for deeper debugging.

## Related Resources

- `../README.md` – high-level guide for this directory.
- `../../implementation/` – configuration files referenced by the scripts.
- `../../agentic/` – Claude Agent SDK wrapper that calls these scripts.
