# Tailscale Probe (Flutter)

A minimal Flutter client that proves SSH connectivity to your Code From Anywhere
host from both iOS and Android. The app collects host credentials, dials the SSH
server over Tailscale, runs a lightweight command (default `tailscale status`),
and displays the output. It doubles as a starting point for custom workflows
that need to run backend helpers from mobile devices.

## Why Flutter?

- Single codebase → iOS + Android binaries.
- Strong package ecosystem; `dartssh2` provides a pure-Dart SSH client so we
  avoid native wrappers.
- Works with local emulators or real devices for pre-flight testing.

## Prerequisites

- Flutter SDK 3.19 or newer (`brew install --cask flutter` on macOS).
- Xcode + CocoaPods for iOS builds.
- Android Studio (or command-line tools) + a recent SDK platform for Android.
- Access to your Tailscale tailnet from the development machine so the emulator
  can reach the host.

## Bootstrap

```bash
cd mobile/flutter/tailscale_probe
flutter pub get
# If the platform folders are missing (fresh clone), generate them:
flutter create .
```

> The repository ships only the Dart sources to keep noise low. `flutter create`
> scaffolds `android/`, `ios/`, and other platform directories for you.

## Configuration

The demo UI expects:

- **Host / MagicDNS** — e.g. `mac-studio.tailnet-name.ts.net`.
- **Username** — the macOS user configured in the playbook.
- **Auth Method** — pick password or private key. For keys, paste the PEM
  string (ed25519 is supported).
- **Command** — defaults to `tmux ls`; change to anything lightweight.

For unattended tests, create a `.env.dart` file with defaults:

```dart
// lib/env/env_override.dart (optional, never commit secrets)
const defaultHost = 'mac-studio.tailnet-name.ts.net';
const defaultUser = 'codeops';
const defaultCommand = 'tmux ls';
const defaultPrivateKey = '''
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
''';
```

The UI uses these constants if present.

## Running Locally

**iOS Simulator**

```bash
flutter run -d ios
```

Ensure the Mac running the simulator is on the same tailnet (Tailscale logged
in); the simulator leverages the host network.

**Android Emulator**

```bash
flutter emulators
flutter emulators --launch pixel_7_api_34
flutter run -d emulator-5554
```

Install the Tailscale Android app inside the emulator, log in, and keep the VPN
toggle on so the app can reach the host.

## Building for Devices

```bash
# Android
flutter build apk --release

# iOS (produces an xcarchive for deployment)
flutter build ipa --release
```

See Flutter docs for code signing specifics.

## Next Steps

- Add persistence (secure storage) for saved host profiles.
- Wrap the SSH call in background isolates so the UI stays responsive on slow
  links.
- Extend the command palette to launch the `start-dev-session` helper directly.
