#!/usr/bin/env bash
#
# Convenience wrapper that validates helper scripts, refreshes sudo, runs the
# Mac bootstrap routine, and performs quick post-flight checks. Intended for the
# real Mac Studio host.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
PLAYBOOK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This verification helper is only meant for macOS hosts." >&2
  exit 1
fi

echo "==> Running local validation harness"
pushd "$REPO_ROOT" >/dev/null
bash tests/test-code-from-anywhere.sh
popd >/dev/null

echo "==> Pre-authorising sudo (enter your macOS password if prompted)"
sudo -v

# Keep the sudo timestamp fresh while the script runs.
keep_alive() {
  while true; do
    sleep 30
    sudo -n true >/dev/null 2>&1 || true
  done
}
keep_alive &
KEEP_ALIVE_PID=$!
trap 'kill "$KEEP_ALIVE_PID" >/dev/null 2>&1 || true' EXIT

echo "==> Executing Mac Studio bootstrap routine"
"$SCRIPT_DIR/bootstrap-mac-host.sh"

echo "==> Post-flight checks"
TAILSCALE_BIN="$(command -v tailscale || true)"
if [[ -z "${TAILSCALE_BIN}" && -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]]; then
  TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi
if [[ -n "${TAILSCALE_BIN}" ]]; then
  "${TAILSCALE_BIN}" status
else
  echo "tailscale CLI not found on PATH; skip status check." >&2
fi
tmux -V
brew list tmux >/dev/null 2>&1 && echo "tmux installed via Homebrew"
brew list fail2ban >/dev/null 2>&1 && echo "fail2ban installed via Homebrew"

cat <<'EOF'
✅ Bootstrap run complete.

If the script printed a Tailscale login link, open it in your browser, sign in,
and approve the Mac Studio host. Once approved you should see the device in the
admin console and in `tailscale status`.

Next steps:
  - Verify you can reach the host from a client by running `ssh mac-studio "~/bin/start-dev-session"`.
  - Update the playbook if you needed any environment-specific tweaks.
EOF
