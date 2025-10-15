#!/usr/bin/env bash
#
# Fully automated bootstrap runner for the Code From Anywhere playbook.
#  - Loads env (including TAILSCALE_AUTH_KEY) from repo-level .env/.env.local
#  - Refreshes sudo so downstream scripts do not block
#  - Ensures the Homebrew Tailscale CLI is installed and logged in
#  - Executes run-bootstrap-and-verify.sh to configure the Mac Studio host

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${PLAYBOOK_ROOT}/../../.." && pwd)"
CLAUDE_RUNNER_DIR="${PLAYBOOK_ROOT}/agentic/claude-runner"

# Load environment variables so the bootstrap script and agent see the auth key.
set +u
if [[ -f "${REPO_ROOT}/.env" ]]; then
  # shellcheck disable=SC1090
  source "${REPO_ROOT}/.env"
fi
if [[ -f "${REPO_ROOT}/.env.local" ]]; then
  # shellcheck disable=SC1090
  source "${REPO_ROOT}/.env.local"
fi
set -u

if [[ -z "${TAILSCALE_AUTH_KEY:-}" ]]; then
  echo "❌ TAILSCALE_AUTH_KEY is not set. Add it to .env.local before running." >&2
  exit 1
fi

BREW_BIN="$(command -v brew || true)"
if [[ -z "${BREW_BIN}" ]]; then
  echo "❌ Homebrew is required. Install it first from https://brew.sh/" >&2
  exit 1
fi

echo "==> Refreshing sudo credentials (you may be prompted once)"
sudo -v

keep_sudo_alive() {
  while true; do
    sleep 30
    sudo -n true >/dev/null 2>&1 || exit 0
  done
}
keep_sudo_alive &
KEEP_ALIVE_PID=$!
trap 'kill "$KEEP_ALIVE_PID" >/dev/null 2>&1 || true' EXIT

echo "==> Ensuring Homebrew Tailscale CLI is installed"
TAILSCALE_BIN="$(command -v tailscale || true)"
GUI_TAILSCALE="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

if [[ -n "${TAILSCALE_BIN}" && "${TAILSCALE_BIN}" == "${GUI_TAILSCALE}" ]]; then
  TAILSCALE_BIN=""
fi

if [[ -z "${TAILSCALE_BIN}" ]]; then
  brew install tailscale
  eval "$("${BREW_BIN}" shellenv)"
  TAILSCALE_BIN="$(command -v tailscale || true)"
fi

if [[ -z "${TAILSCALE_BIN}" ]]; then
  echo "❌ Unable to locate Tailscale CLI after installation." >&2
  exit 1
fi

echo "    Using ${TAILSCALE_BIN}"

echo "==> Installing tailscaled system daemon"
if command -v tailscaled >/dev/null 2>&1; then
  sudo tailscaled install-system-daemon >/dev/null 2>&1 || true
  sudo launchctl load -w /Library/LaunchDaemons/com.tailscale.tailscaled.plist >/dev/null 2>&1 || true
fi

if "${TAILSCALE_BIN}" status >/dev/null 2>&1; then
  echo "==> Tailscale already running; skipping login"
else
  echo "==> Logging into Tailscale with auth key"
  if ! sudo "${TAILSCALE_BIN}" up --ssh --accept-dns --advertise-tags=tag:devhost \
      --operator="$(whoami)" --authkey="${TAILSCALE_AUTH_KEY}" ; then
    echo "⚠️  tailscale up returned an error. Re-run manually with the command above if needed." >&2
  fi
fi

echo "==> Installing agent dependencies (npm install)"
pushd "${CLAUDE_RUNNER_DIR}" >/dev/null
npm install >/dev/null

echo "==> Running Code From Anywhere bootstrap via Claude agent"
AUTO_CONFIRM=1 npm run bootstrap:auto
popd >/dev/null

echo "✅ Automation complete."
