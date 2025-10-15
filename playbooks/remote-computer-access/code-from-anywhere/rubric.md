# Rubric — Code From Anywhere

Use this checklist before you rely on the setup for daily work or hand it to someone else.

## Host Readiness

- [ ] Host OS fully patched within the last 30 days.
- [ ] Dedicated non-root user (`coder` or equivalent) exists and owns the workspace.
- [ ] SSH daemon configured for key-only auth and restricted to the dedicated user.
- [ ] Fail2Ban (or equivalent) running and covering the SSH jail.
- [ ] Firewall/ACL allows SSH only from tunnel networks.

## Persistence & Tooling

- [ ] `tmux` installed, `~/.tmux.conf` tuned for history + mouse.
- [ ] `scripts/start-dev-session.sh` executable and stored in `~/bin` or similar.
- [ ] At least one tmux session survives an SSH disconnect (verified manually).

## Tunnel & Reachability

- [ ] Chosen tunnel (Tailscale/WireGuard/Cloudflare) connects automatically on boot.
- [ ] Connection documented in `~/.ssh/config` with keepalive values.
- [ ] Non-admin user can run `tailscale status` without `--operator` errors.
- [ ] External DNS/IP recorded for future reuse (Tailscale IP, WG subnet, etc.).

## Client Coverage

- [ ] Desktop/laptop tested end-to-end (connect → run command → detach).
- [ ] Mobile device (iOS or Android) tested end-to-end with hardware keyboard or key remap.
- [ ] Emergency disconnect path documented (disable tunnel, revoke key).

## Observability & Maintenance

- [ ] System metrics accessible (`uptime`, `journalctl`, or monitoring agent).
- [ ] Monthly maintenance reminder scheduled (patches, key rotation review).
- [ ] Troubleshooting checklist validated (simulate a failed tunnel once).
