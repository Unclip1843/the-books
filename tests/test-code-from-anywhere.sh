#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAYBOOK_DIR="$ROOT_DIR/playbooks/remote-computer-access/code-from-anywhere"
SCRIPTS_DIR="$PLAYBOOK_DIR/scripts"

TMP_BIN="$(mktemp -d)"
TMP_STATE="$(mktemp -d)"
LOG_FILE="$TMP_STATE/log.txt"

cleanup() {
  rm -rf "$TMP_BIN" "$TMP_STATE"
}
trap cleanup EXIT

log() {
  printf '%s\n' "$*" >>"$LOG_FILE"
}

# Create stub commands -------------------------------------------------------

# Generic stub generator that logs invocations.
stub_cmd() {
  local name="$1"
  cat >"$TMP_BIN/$name" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "$(basename "$0") $*" >>"__LOG_FILE__"
EOF
  chmod +x "$TMP_BIN/$name"
  # Replace placeholder with actual log path.
  sed -i '' "s#__LOG_FILE__#$LOG_FILE#g" "$TMP_BIN/$name"
}

# sudo stub executes subordinate commands without escalation.
cat >"$TMP_BIN/sudo" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "sudo $*" >>"__LOG_FILE__"
if [[ "$1" == "-n" ]]; then
  shift
fi
if [[ "$1" == "-E" ]]; then
  shift
fi
exec "$@"
EOF
sed -i '' "s#__LOG_FILE__#$LOG_FILE#g" "$TMP_BIN/sudo"
chmod +x "$TMP_BIN/sudo"

# pmset stub just logs.
stub_cmd "pmset"

# xcode-select stub pretends tools are present.
cat >"$TMP_BIN/xcode-select" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "xcode-select $*" >>"__LOG_FILE__"
if [[ "${1-}" == "--print-path" ]]; then
  echo "/Library/Developer/CommandLineTools"
  exit 0
fi
if [[ "${1-}" == "--install" ]]; then
  exit 0
fi
EOF
sed -i '' "s#__LOG_FILE__#$LOG_FILE#g" "$TMP_BIN/xcode-select"
chmod +x "$TMP_BIN/xcode-select"

stub_cmd "curl"

# Homebrew stub handles update/install/services list/start/restart.
cat >"$TMP_BIN/brew" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "brew $*" >>"__LOG_FILE__"
if [[ "${1-}" == "services" && "${2-}" == "list" ]]; then
  exit 1  # cause script to run start branch
fi
exit 0
EOF
sed -i '' "s#__LOG_FILE__#$LOG_FILE#g" "$TMP_BIN/brew"
chmod +x "$TMP_BIN/brew"

stub_cmd "systemsetup"
stub_cmd "tailscale"

# tmux stub simulates session creation.
cat >"$TMP_BIN/tmux" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "tmux $*" >>"__LOG_FILE__"
STATE_FILE="__TMP_STATE__/tmux-session"
case "$1" in
  has-session)
    if [[ -f "$STATE_FILE" ]]; then
      exit 0
    else
      exit 1
    fi
    ;;
  new-session)
    touch "$STATE_FILE"
    exit 0
    ;;
  attach)
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
EOF
sed -i '' "s#__LOG_FILE__#$LOG_FILE#g" "$TMP_BIN/tmux"
sed -i '' "s#__TMP_STATE__#$TMP_STATE#g" "$TMP_BIN/tmux"
chmod +x "$TMP_BIN/tmux"

export PATH="$TMP_BIN:$PATH"

# 1. Syntax checks -----------------------------------------------------------
echo "Running bash -n on scripts..."
bash -n "$SCRIPTS_DIR/start-dev-session.sh"
bash -n "$SCRIPTS_DIR/bootstrap-mac-host.sh"

if command -v shellcheck >/dev/null 2>&1; then
  echo "Running shellcheck..."
  shellcheck "$SCRIPTS_DIR/start-dev-session.sh" "$SCRIPTS_DIR/bootstrap-mac-host.sh"
else
  echo "shellcheck not available; skipping static analysis."
fi

# 2. Execute start-dev-session with tmux stub --------------------------------
echo "Testing start-dev-session.sh..."
SESSION_NAME="testsession" "$SCRIPTS_DIR/start-dev-session.sh"

# 3. Execute bootstrap script with stubs ------------------------------------
echo "Testing bootstrap-mac-host.sh..."
"$SCRIPTS_DIR/bootstrap-mac-host.sh"

echo "Log output:"
cat "$LOG_FILE"

echo "All tests passed."
