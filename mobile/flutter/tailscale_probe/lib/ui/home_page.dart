import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ssh_probe_service.dart';
import '../state/ssh_probe_controller.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostController = useTextEditingController();
    final portController = useTextEditingController(text: '22');
    final userController = useTextEditingController();
    final passwordController = useTextEditingController();
    final passphraseController = useTextEditingController();
    final privateKeyController = useTextEditingController();
    final commandController = useTextEditingController(text: 'tmux ls');

    final usePrivateKey = useState<bool>(false);
    final keepPassword = useState<bool>(false);

    final state = ref.watch(sshProbeControllerProvider);
    final controller = ref.read(sshProbeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tailscale SSH Probe'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _Section(
                title: 'Connection',
                children: [
                  _LabeledField(
                    label: 'Host (MagicDNS or IP)',
                    child: TextField(
                      controller: hostController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        hintText: 'mac-studio.tailnet.ts.net',
                      ),
                    ),
                  ),
                  _LabeledField(
                    label: 'Port',
                    child: TextField(
                      controller: portController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '22'),
                    ),
                  ),
                  _LabeledField(
                    label: 'Username',
                    child: TextField(
                      controller: userController,
                      decoration:
                          const InputDecoration(hintText: 'codeops'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Authentication',
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Use private key (OpenSSH PEM)'),
                    value: usePrivateKey.value,
                    onChanged: (value) {
                      usePrivateKey.value = value;
                      if (!value) {
                        privateKeyController.clear();
                        passphraseController.clear();
                      }
                    },
                  ),
                  if (usePrivateKey.value)
                    _LabeledField(
                      label: 'Private key (PEM)',
                      child: TextField(
                        controller: privateKeyController,
                        decoration: const InputDecoration(
                          hintText: '-----BEGIN OPENSSH PRIVATE KEY-----',
                        ),
                        minLines: 6,
                        maxLines: 12,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  if (usePrivateKey.value)
                    _LabeledField(
                      label: 'Private key passphrase (optional)',
                      child: TextField(
                        controller: passphraseController,
                        decoration: const InputDecoration(
                          hintText: 'Passphrase if the key is encrypted',
                        ),
                        obscureText: true,
                      ),
                    ),
                  SwitchListTile.adaptive(
                    title: const Text('Send password credential'),
                    subtitle: const Text('Required if your sshd permits it'),
                    value: keepPassword.value,
                    onChanged: (value) {
                      keepPassword.value = value;
                      if (!value) {
                        passwordController.clear();
                      }
                    },
                  ),
                  if (keepPassword.value)
                    _LabeledField(
                      label: 'Password',
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Only if password auth is enabled',
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Command',
                children: [
                  _LabeledField(
                    label: 'Command to run',
                    child: TextField(
                      controller: commandController,
                      decoration: const InputDecoration(
                        hintText: 'tmux ls',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(state.isLoading ? 'Connecting…' : 'Run Probe'),
                onPressed: state.isLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        final host = hostController.text.trim();
                        final user = userController.text.trim();
                        final port =
                            int.tryParse(portController.text.trim()) ?? 22;
                        final command = commandController.text.trim();

                        if (host.isEmpty || user.isEmpty || command.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Host, username, and command are required.',
                              ),
                            ),
                          );
                          return;
                        }

                        await controller.runProbe(
                          SshProbeRequest(
                            host: host,
                            port: port,
                            username: user,
                            command: command,
                            password: keepPassword.value
                                ? passwordController.text
                                : null,
                            privateKeyPem: usePrivateKey.value
                                ? privateKeyController.text
                                : null,
                            privateKeyPassphrase: passphraseController.text,
                          ),
                        );
                      },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.stop),
                label: const Text('Reset'),
                onPressed:
                    state.isLoading ? null : () => controller.reset(),
              ),
              const SizedBox(height: 24),
              _ProbeOutput(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _ProbeOutput extends StatelessWidget {
  const _ProbeOutput({required this.state});

  final SshProbeState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const _OutputCard(
        header: 'Status',
        child: LinearProgressIndicator(),
      );
    }
    if (state.hasError) {
      return _OutputCard(
        header: 'Error',
        child: Text(
          state.errorMessage!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }
    if (state.hasResult) {
      final result = state.result!;
      return _OutputCard(
        header:
            'Success (${result.duration.inMilliseconds} ms, stdout/stderr below)',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.stdout.isEmpty ? '<no stdout>' : result.stdout,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            Text(
              result.stderr.isEmpty ? '<no stderr>' : result.stderr,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }
    return const _OutputCard(
      header: 'Status',
      child: Text('Idle — fill in details and run the probe.'),
    );
  }
}

class _OutputCard extends StatelessWidget {
  const _OutputCard({
    required this.header,
    required this.child,
  });

  final String header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              header,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
