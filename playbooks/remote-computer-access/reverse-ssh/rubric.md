# Rubric — Reverse SSH

Fill these in as the playbook matures.

## Bastion Hygiene

- [ ] Hardened `sshd_config` with key-only auth and restricted ports.
- [ ] Audit logging captures tunnel activity (auth log, fail2ban, etc.).

## Target Service

- [ ] Outbound tunnel managed by `systemd` or `autossh` with restart policy.
- [ ] SSH keys scoped per target; stored securely with rotation plan.
- [ ] Connection survives network blips (retry logic validated).

## Client Experience

- [ ] One-command access path defined (ProxyJump or `ssh_config` entry).
- [ ] Emergency shutdown documented (systemctl stop tunnel, revoke key).

## Monitoring & Alerts

- [ ] Health probe alerts when tunnel disconnects for > N minutes.
- [ ] Logs centralised or shipped for forensics.
