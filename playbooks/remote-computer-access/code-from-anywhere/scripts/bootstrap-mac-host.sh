#!/usr/bin/env bash
#
# Bootstrap a macOS host (tested on Ventura/Sonoma) for the Code From Anywhere playbook.
# Runs idempotent system tweaks, installs Homebrew packages, and enables remote login.

set -euo pipefail

SCRIPT_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$HOME"
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  TARGET_HOME=$(eval echo "~${SUDO_USER}")
fi

TARGET_SHELL="${SHELL:-/bin/zsh}"
if command -v dscl >/dev/null 2>&1; then
  dscl_shell=$(dscl . -read "/Users/${SCRIPT_USER}" UserShell 2>/dev/null || true)
  maybe_shell=$(printf '%s\n' "$dscl_shell" | awk 'NR==1 {print $2}')
  if [[ -n "$maybe_shell" ]]; then
    TARGET_SHELL="$maybe_shell"
  fi
fi

ensure_brew_shellenv() {
  local brew_snippet="${HOMEBREW_SHELLENV_SNIPPET:-}"
  local shell_profile

  case "$(basename "$TARGET_SHELL")" in
    zsh) shell_profile="${TARGET_HOME}/.zprofile" ;;
    bash) shell_profile="${TARGET_HOME}/.bash_profile" ;;
    *) shell_profile="${TARGET_HOME}/.profile" ;;
  esac

  if [[ -n "$shell_profile" ]]; then
    if [[ ! -f "$shell_profile" ]]; then
      touch "$shell_profile"
    fi
    if ! grep -Fq "$brew_snippet" "$shell_profile" 2>/dev/null; then
      {
        printf '\n# Added by bootstrap-mac-host.sh to expose Homebrew on PATH\n'
        printf '%s\n' "$brew_snippet"
      } >> "$shell_profile"
      echo "Appended Homebrew shellenv to ${shell_profile}"
    fi
  fi
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is intended for macOS hosts only." >&2
  exit 1
fi

echo "==> Ensuring the Mac stays awake"
sudo pmset -a sleep 0 displaysleep 0 disksleep 0
sudo pmset -a disablesleep 1

echo "==> Installing Xcode command line tools (if missing)"
if ! xcode-select --print-path >/dev/null 2>&1; then
  xcode-select --install || true
  # Wait until the tools are installed; user may need to confirm GUI prompt.
  until xcode-select --print-path >/dev/null 2>&1; do
    echo "Waiting for command line tools..."
    sleep 20
  done
fi

echo "==> Installing Homebrew (if missing)"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
BREW_BIN=$(command -v brew 2>/dev/null || true)
if [[ -z "${BREW_BIN}" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    BREW_BIN="/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    BREW_BIN="/usr/local/bin/brew"
  fi
fi
if [[ -z "${BREW_BIN}" ]]; then
  echo "Unable to locate Homebrew binary after installation." >&2
  exit 1
fi
BREW_PREFIX="$("${BREW_BIN}" --prefix)"
HOMEBREW_SHELLENV_SNIPPET=$(printf 'eval "$(%s/bin/brew shellenv)"' "$BREW_PREFIX")
eval "$("${BREW_BIN}" shellenv)"
ensure_brew_shellenv

echo "==> Installing tmux and fail2ban"
"${BREW_BIN}" update
"${BREW_BIN}" install tmux fail2ban

echo "==> Ensuring Tailscale CLI is available"
TAILSCALE_BIN="$(command -v tailscale || true)"
if [[ -z "${TAILSCALE_BIN}" && -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]]; then
  TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi
if [[ -z "${TAILSCALE_BIN}" ]]; then
  if "${BREW_BIN}" list tailscale >/dev/null 2>&1; then
    :
  else
    echo "==> Installing Tailscale via Homebrew (CLI formula)"
    "${BREW_BIN}" install tailscale
  fi
  PREF="$("${BREW_BIN}" --prefix tailscale 2>/dev/null || true)"
  if [[ -n "${PREF}" && -x "${PREF}/bin/tailscale" ]]; then
    TAILSCALE_BIN="${PREF}/bin/tailscale"
  else
    TAILSCALE_BIN="$(command -v tailscale || true)"
  fi
fi
if [[ -z "${TAILSCALE_BIN}" && -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]]; then
  TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi
if [[ -z "${TAILSCALE_BIN}" ]]; then
  cat <<'EOF' >&2
Tailscale CLI not found. Install it manually with one of:
  brew install tailscale
  brew install --cask tailscale
Then rerun this script.
EOF
  exit 1
fi
echo "    Using ${TAILSCALE_BIN}"

echo "==> Enabling fail2ban via launchctl"
if ! "${BREW_BIN}" services list | grep -q fail2ban; then
  sudo "${BREW_BIN}" services start fail2ban
else
  sudo "${BREW_BIN}" services restart fail2ban
fi

echo "==> Enabling remote login (SSH)"
sudo systemsetup -setremotelogin on

echo "==> Bringing the host onto your tailnet"
TAILSCALE_OPERATOR="${SCRIPT_USER}"
TAILSCALE_FLAGS=(--ssh --accept-dns --advertise-tags=tag:devhost "--operator=${TAILSCALE_OPERATOR}")
if [[ -n "${TAILSCALE_AUTH_KEY:-}" ]]; then
  echo "==> Using provided Tailscale auth key for unattended login"
  TAILSCALE_FLAGS+=("--authkey=${TAILSCALE_AUTH_KEY}")
else
  echo "==> Tailscale will prompt for login in your browser."
  echo "    Set TAILSCALE_AUTH_KEY for fully unattended bootstrap."
fi
if sudo "${TAILSCALE_BIN}" up "${TAILSCALE_FLAGS[@]}"; then
  echo "==> Tailscale login succeeded."
else
  echo "⚠️  tailscale up exited non-zero. Complete authentication manually with:" >&2
  echo "    sudo \"${TAILSCALE_BIN}\" up --ssh --accept-dns --advertise-tags=tag:devhost --operator=\"${TAILSCALE_OPERATOR}\"" >&2
  if [[ -z "${TAILSCALE_AUTH_KEY:-}" ]]; then
    echo "    # add --authkey=tskey-... if you want unattended login" >&2
  fi
fi

echo "==> Verifying Tailscale status"
if "${TAILSCALE_BIN}" status >/dev/null 2>&1; then
  "${TAILSCALE_BIN}" status
else
  echo "tailscale status is not ready yet; complete authentication and rerun 'tailscale status'." >&2
fi

echo "✅ Bootstrap complete. Review the Tailscale login prompt and approve the device in the admin console."
