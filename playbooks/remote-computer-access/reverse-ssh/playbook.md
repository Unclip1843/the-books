# Reverse SSH Playbook

## Overview

Expose an internal machine to a trusted bastion by having the target initiate an outbound SSH tunnel, keeping inbound firewalls closed.

## Rubric

See `rubric.md` for the quality bar—fill it in once the workflow is validated.

## Implementation (TODO)

- [ ] Diagram: target ↔ bastion ↔ client.
- [ ] Prerequisites: accounts, firewall rules, SSH keys.
- [ ] Setup scripts for target (`autossh` or `systemd` service).
- [ ] Bastion `sshd_config` snippets and port policies.
- [ ] Client connection examples (`ssh -J bastion target`).
- [ ] Monitoring & alerting for dropped tunnels.

## Scripts

- Drop helpers into `scripts/` (e.g., `systemd` unit generators, tunnel checks).

## Implementation Assets

- Capture configs, diagrams, and templates under `implementation/`.

Document assumptions and security considerations before marking this playbook production-ready.
