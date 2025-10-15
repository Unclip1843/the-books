# Rubric — Computer Use

Validate these requirements before granting agents hands-on desktop access.

## Environment Security

- [ ] Execution environment isolated from production networks.
- [ ] Credentials scoped to least privilege; auto-rotated or ephemeral.
- [ ] Session recording and audit logging enabled by default.

## Agent Control

- [ ] Clear API/command contract documented and versioned.
- [ ] Emergency stop / manual takeover tested (hotkey, webhook, etc.).
- [ ] Action rate limiting enforced to prevent runaway behaviour.

## Observability & Compliance

- [ ] Session replays stored securely with retention policy.
- [ ] Alerts when agents touch restricted apps or domains.
- [ ] Privacy review completed for screen/keystroke capture.

## User Experience

- [ ] Bring-your-own tooling instructions for operators (debugging, override).
- [ ] Playbook includes recovery steps when agents get stuck.
- [ ] Documentation covers accessibility (keyboard mappings, timezone sync).
