# Mobile Proof-of-Concept Clients

This folder houses prototype apps that exercise the Code From Anywhere workflow
from smartphones and tablets. The goal is not to replace Blink or Termux, but to
offer a minimal “smoke test” client you can build yourself to confirm SSH +
tmux works end-to-end before investing in bespoke UI.

Currently implemented:

- `flutter/tailscale_probe/` — a single Flutter app that builds for both iOS and
  Android, using the `dartssh2` package to open an SSH session and run a sanity
  command through Tailscale.

Follow the subdirectory’s README for build and deployment steps on each
platform.
