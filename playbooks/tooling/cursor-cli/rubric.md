# Rubric — Cursor CLI

Define the success bar before rolling this workflow to the team.

## Installation & Auth

- [ ] Automated installer covers macOS + Linux.
- [ ] API tokens stored via secrets manager (no plain-text dotfiles).
- [ ] Command verifies login status or fails fast with actionable error.

## Editing Workflow

- [ ] End-to-end example (fetch prompt → apply diff → review) documented.
- [ ] Safe preview (`--diff` or equivalent) enabled by default.
- [ ] Rollback path tested (git stash/reset or file backups).

## Integration

- [ ] tmux or shell integration alias tested on remote host.
- [ ] Works alongside other agents without stepping on env vars.

## Observability

- [ ] CLI logs/errors captured in a structured location.
- [ ] Usage guidance includes rate limit handling and fallback plan.
