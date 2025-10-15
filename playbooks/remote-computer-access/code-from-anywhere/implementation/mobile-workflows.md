# Mobile Access Workflows (Mac Studio Tailnet)

Use this file as a quick reference for pairing phones/tablets with the Mac Studio host that runs the Code From Anywhere playbook. All instructions assume:

- The Mac Studio is already bootstrapped (`automate-bootstrap.sh` or `npm run bootstrap:auto`).
- You have MagicDNS enabled (e.g., `mac-studio.tailnet-name.ts.net`).
- `start-dev-session.sh` lives at `~/bin/start-dev-session` on the Mac Studio and tmux is configured via the playbook.

## Common Prerequisites

1. Sign into the Tailscale app on the client device and ensure the VPN is active.
2. Generate a device-specific SSH key (per phone/tablet) and add the public key to the Mac Studio user (`~codeops/.ssh/authorized_keys`).
3. Use the MagicDNS hostname in all client configs—no need to memorize the Tailscale IP.

## iPhone / iPad (Blink Shell)

1. **Install apps**
   - Tailscale (App Store) → sign in → enable VPN.
   - Blink Shell (App Store) for SSH/tmux.

2. **Generate SSH key**
   - Blink → `Settings → Keys → +` → name it (`iphone-codeops`).
   - Copy the public key (AirDrop/email) and append to the Mac Studio:
     ```bash
     echo "ssh-ed25519 AAAA... iphone-codeops" >> /Users/codeops/.ssh/authorized_keys
     ```

3. **Create host entry**
   - In Blink dotfiles (`config`), add:
     ```sh
     host mac-studio {
       hostname mac-studio.tailnet-name.ts.net
       user codeops
       identity iphone-codeops
       commands "~/bin/start-dev-session"
     }
     ```

4. **Connect**
   - In Blink, run `ssh mac-studio`.
   - You’ll land inside the tmux `dev` session (or whichever `SESSION_NAME` the helper script manages).

5. **Quality of life**
   - Enable “Use Caps Lock as Ctrl” in Blink settings for tmux shortcuts.
   - Pair an external keyboard if you prefer physical keys.

## Android (Termux)

1. **Install apps**
   - Tailscale (Play Store) → sign in → keep VPN toggle on.
   - Termux (F-Droid recommended for latest packages).

2. **Prepare Termux**
   ```bash
   pkg update && pkg upgrade
   pkg install openssh git
   ```

3. **Generate SSH key**
   ```bash
   ssh-keygen -t ed25519 -C "pixel-termux@code-from-anywhere"
   termux-clipboard-set "$(cat ~/.ssh/id_ed25519.pub)"
   ```
   Paste the clipboard contents into `/Users/codeops/.ssh/authorized_keys` on the Mac Studio.

4. **Configure SSH**
   - Copy `implementation/ssh/config.home-dev` into Termux `~/.ssh/config`, adjusting:
     ```sshconfig
     Host mac-studio
       HostName mac-studio.tailnet-name.ts.net
       User codeops
       IdentityFile ~/.ssh/id_ed25519
       IdentitiesOnly yes
       ServerAliveInterval 30
       ServerAliveCountMax 2
     ```

5. **Connect to tmux**
   ```bash
   ssh mac-studio "~/bin/start-dev-session"
   ```
   The helper script will attach you to the persistent `dev` session.

6. **Termux tips**
   - Enable “Use volume keys for control” in Termux `Settings` for tmux shortcuts.
   - Install `termux-api` if you want to share the clipboard via `termux-clipboard-set`.

## Troubleshooting Checklist

- `Permission denied (publickey)` → verify the device’s public key is present in `~codeops/.ssh/authorized_keys` and that file permissions are `600`.
- Tailscale not connecting → open the Tailscale app, ensure VPN is toggled on, confirm `tailscale status` on the Mac Studio shows the device.
- tmux session not found → run `~/bin/start-dev-session` once on the Mac Studio to seed the session, or set `SESSION_NAME` and update client commands.

## Related Files

- `scripts/start-dev-session.sh` — helper used by clients.
- `implementation/tmux.conf` — default tmux config referenced by the playbook.
- `playbook.md` — primary documentation (sections “iPad + iPhone Workflow” and “Android Workflow (Termux)”).
