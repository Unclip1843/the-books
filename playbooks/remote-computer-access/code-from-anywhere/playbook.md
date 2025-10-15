# Code From Anywhere Playbook

## Overview

Turn a spare computer into an always-on dev box you can reach from laptops and phones. Follow the implementation path end to end once, then use the quick-reference commands to hop back in whenever you need them.

- **Host focus**: Mac Studio bootstrap script, hardened SSH, tmux defaults.
- **Access path**: Tailscale with built-in SSH, MagicDNS, and tagged ACLs.
- **Client coverage**: MacBook, iPad/iPhone (Blink), Android via Termux.

## Rubric

Use `rubric.md` to confirm the host is hardened, reachable, and observable before you invite others onto the box.

## Implementation

### 1. Prep the Mac Studio Host

1. **Keep the Mac awake.**
   ```bash
   sudo pmset -a sleep 0 displaysleep 0 disksleep 0
   sudo pmset -a disablesleep 1
   ```
   Also disable “Put hard disks to sleep” in System Settings → Energy.
2. **Stay patched.** Run `softwareupdate --install --all` and reboot.
3. **Create a dedicated user** (`codeops` in this example) if others use the machine:
   - System Settings → Users & Groups → add user with “Standard” role.
   - Grant sudo only if needed via `sudo dseditgroup -o edit -a codeops -t user admin`.
4. **Install baseline tooling.**
   ```bash
   xcode-select --install            # command line tools
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   brew install tmux fail2ban        # Fail2Ban via Homebrew
   sudo systemsetup -setremotelogin on
   ```
5. **Optional automation.** Run `./playbooks/remote-computer-access/code-from-anywhere/scripts/bootstrap-mac-host.sh` for the commands above plus safety checks. The script keeps Homebrew on your login shell’s `$PATH` and accepts `TAILSCALE_AUTH_KEY` for unattended tailnet joins.
6. **Agentic run (beta).** Prefer orchestrating via Claude? See `./playbooks/remote-computer-access/code-from-anywhere/agentic/README.md` for the subagent harness that wraps the same scripts with the Claude Agent SDK.

### 2. Harden SSH on macOS

1. **Unique keys per client.** On each device run:
   ```bash
   ssh-keygen -t ed25519 -C "device-name@code-from-anywhere"
   ```
2. **Install the public key on the Mac Studio.**
   ```bash
   ssh-copy-id codeops@MAC_STUDIO_LAN_IP
   ```
   If `ssh-copy-id` is unavailable, append the key to `~codeops/.ssh/authorized_keys` manually.
3. **Lock down `sshd_config`.** Copy `./playbooks/remote-computer-access/code-from-anywhere/implementation/ssh/sshd_config.macos` to `/etc/ssh/sshd_config.d/10-codeops.conf`:
   ```
   PermitRootLogin no
   PasswordAuthentication no
   PubkeyAuthentication yes
   AllowUsers codeops
   ```
   Reload SSH:
   ```bash
   sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
   sudo launchctl load /System/Library/LaunchDaemons/ssh.plist
   ```
4. **Fail2Ban on macOS.**
   ```bash
   sudo cp /opt/homebrew/etc/fail2ban/jail.conf /opt/homebrew/etc/fail2ban/jail.local
   brew services start fail2ban
   ```
   Confirm `/opt/homebrew/etc/fail2ban/jail.local` has the `sshd` jail enabled.
5. **Firewall.** Ensure the macOS application firewall is active:
   ```bash
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
   ```

### 3. Install tmux + Helper Script

1. **Apply our opinionated config.**
   ```bash
   mkdir -p ~/.config/tmux
   cp ./playbooks/remote-computer-access/code-from-anywhere/implementation/tmux.conf ~/.config/tmux/tmux.conf
   ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf
   ```
2. **Stage the helper script.**
   ```bash
   mkdir -p ~/bin
   cp ./playbooks/remote-computer-access/code-from-anywhere/scripts/start-dev-session.sh ~/bin/start-dev-session
   chmod +x ~/bin/start-dev-session
   ```
   Add `export PATH="$HOME/bin:$PATH"` to `~/.zshrc` if needed.
3. **Create the session once.**
   ```bash
   ~/bin/start-dev-session
   ```
   Detach with `Ctrl-b d`.

### 4. Wire Up Tailscale Access

1. **Install Tailscale (CLI).**
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   sudo tailscale up --ssh --accept-dns --advertise-tags=tag:devhost --operator=$(whoami)
   ```
   Use SSO or MagicDNS during the `tailscale up` prompt. Set `TAILSCALE_AUTH_KEY=tskey-...` in the environment if you want the bootstrap to finish without interactive login.
2. **Tag ACLs.** In the Tailscale admin console define an ACL granting SSH to `tag:devhost` from your user identities.
3. **Auto-start.** Verify the daemon is running:
   ```bash
   tailscale status
   ```
   (Tailscale’s installer handles the launchd wiring automatically on macOS.)
4. **Record the stable IP/hostname.** MagicDNS gives you something like `mac-studio.tailnet-name.ts.net`. Use that in client configs.
5. **Audit.** Run `tailscale status` and confirm `codeops@mac-studio` is listening for SSH via Tailscale.

### 5. MacBook Client Workflow (macOS)

1. Install Tailscale from the Mac App Store or via Homebrew (`brew install --cask tailscale`) and sign in.
2. Copy `./playbooks/remote-computer-access/code-from-anywhere/implementation/ssh/config.home-dev` to `~/.ssh/config` (merge if the file already exists). Replace placeholders with your MagicDNS hostname and key path.
3. Import your device-specific private key into the macOS keychain or store it with `chmod 600`.
4. Test the connection:
   ```bash
   ssh mac-studio "~/bin/start-dev-session"
   ```
5. Add an alias to your shell:
   ```bash
   echo 'alias studio="ssh mac-studio \"~/bin/start-dev-session\""' >> ~/.zshrc
   ```

### 6. iPad + iPhone Workflow

1. Install **Tailscale** from the App Store → log in → enable the VPN profile.
2. Install **Blink Shell** (recommended) or **Termius**.
3. In Blink, generate a new key (`Settings → Keys → +`). Copy the public key to the host (AirDrop to the Mac Studio and append to `authorized_keys`).
4. Configure the host entry in Blink `dotfiles`:
   ```sh
   host mac-studio {
     hostname mac-studio.tailnet-name.ts.net
     user codeops
     identity blink-iphone
     commands "~/bin/start-dev-session"
   }
   ```
5. Optional quality-of-life:
   - Enable “Use Caps Lock as Ctrl” under Blink settings.
   - Pair a Magic Keyboard or any Bluetooth keyboard for tmux shortcuts.

### 7. Android Workflow (Termux)

1. Install **Tailscale** from the Play Store and authenticate; leave the VPN toggle on.
2. Install **Termux** (F-Droid version preferred for current packages).
3. In Termux, update packages and install OpenSSH + Git:
   ```bash
   pkg update
   pkg upgrade
   pkg install openssh git
   ```
4. Generate an SSH key inside Termux:
   ```bash
   ssh-keygen -t ed25519 -C "pixel-termux@code-from-anywhere"
   ```
5. Copy the public key to the Mac Studio. Use `termux-open-url` to share or run:
   ```bash
   termux-clipboard-set "$(cat ~/.ssh/id_ed25519.pub)"
   ```
   Then paste into `~/.ssh/authorized_keys` on the host.
6. Add an SSH config entry in `~/.ssh/config` within Termux (copy the template from `./playbooks/remote-computer-access/code-from-anywhere/implementation/ssh/config.home-dev`).
7. Connect:
   ```bash
   ssh mac-studio "~/bin/start-dev-session"
   ```
8. Map volume buttons for tmux shortcuts:
   - Termux Settings → Enable “Use volume keys for control”.

### 8. Daily Quick Reference

- `ssh mac-studio "~/bin/start-dev-session"` — resume tmux session.
- `Ctrl-b d` — detach when you have to jet.
- `tmux ls` — list sessions if you need parallel workspaces.
- `tmux new -s pair` — spin up a second session (pairing, experiments).
- `tailscale status` — confirm tunnel state before panicking.
- `tailscale netcheck` — verify upstream connectivity.

### 9. Optional: Build Your Own Mobile Probe

Want to ship a bespoke mobile controller instead of relying on Blink/Termux? The
repository includes a Flutter proof-of-concept under
`mobile/flutter/tailscale_probe/` that dials the host over SSH, runs a command
(default `tmux ls`), and shows stdout/stderr. Follow the README in that folder to
generate the Flutter platforms (`flutter create .`), sign into your tailnet from
the emulator or device, and press **Run Probe** to validate end-to-end.

## Care & Feeding

- Apply OS/security updates monthly.
- Rotate SSH keys yearly or after device loss.
- Review `~/.ssh/authorized_keys` for stale entries.
- Monitor `log show --predicate 'process == "sshd"' --style syslog --last 1h` for suspicious attempts.
- Keep backups of your host machine (Time Machine, `rsnapshot`, etc.).

## Troubleshooting Cheat Sheet

- **SSH freezes immediately.** Check that the tunnel/VPN is up; verify `tailscale status`.
- **Permission denied (publickey).** Confirm the device-specific key exists on the host and file permissions are `chmod 600 ~/.ssh/authorized_keys`.
- **tmux refuses to attach.** Kill stray sockets with `tmux kill-session -t dev` and re-run the helper script.
- **Mobile typing is painful.** Pair a Bluetooth keyboard or use apps with customizable key bindings.
- **Battery drain on host laptop.** Use `pmset -g` (macOS) or `powertop` (Linux) to tune power settings while staying awake.

Keep this playbook in sync with reality—note any commands you change, and commit updates so future-you can re-create the setup without guesswork. Refer to `scripts/start-dev-session.sh` for the helper referenced above.
