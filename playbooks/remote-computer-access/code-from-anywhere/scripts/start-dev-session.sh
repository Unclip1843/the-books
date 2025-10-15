#!/usr/bin/env bash
#
# Ensure a reusable tmux session exists, then attach to it.
# Usage: ./start-dev-session.sh

set -euo pipefail

SESSION_NAME="${SESSION_NAME:-dev}"

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found. Install tmux before running this script." >&2
  exit 1
fi

tmux has-session -t "${SESSION_NAME}" 2>/dev/null || tmux new-session -d -s "${SESSION_NAME}"
exec tmux attach -t "${SESSION_NAME}"
