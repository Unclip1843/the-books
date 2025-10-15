# Computer Use Playbook

## Overview

Enable agents to operate full desktop sessions (Cursor, browsers, shell) with guardrails for execution, auditing, and human takeover.

## Rubric

Once the workflow is built out, ensure it meets the guardrails defined in `rubric.md`.

## Implementation (TODO)

- [ ] Choose execution substrate (VNC, RDP, OrbStack VM, Headless Chrome).
- [ ] Provision template images with required tooling.
- [ ] Define agent interface (API schema, command set, observation format).
- [ ] Implement logging + replay (asciinema, screen recordings, telemetry).
- [ ] Create escalation path for manual intervention.
- [ ] Security checklist (network segmentation, credential scoping).

## Scripts

- Stage automation glue (session launchers, cleanup hooks) in `scripts/`.

## Implementation Assets

- Store VM templates, Dockerfiles, and policy documents under `implementation/`.

Document constraints and fail-safes before onboarding real tasks.
