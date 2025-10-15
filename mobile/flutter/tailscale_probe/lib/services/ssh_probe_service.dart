import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:logging/logging.dart';

final _log = Logger('SshProbeService');

class SshProbeRequest {
  const SshProbeRequest({
    required this.host,
    required this.port,
    required this.username,
    required this.command,
    this.password,
    this.privateKeyPem,
    this.privateKeyPassphrase,
  });

  final String host;
  final int port;
  final String username;
  final String command;
  final String? password;
  final String? privateKeyPem;
  final String? privateKeyPassphrase;

  bool get usesPrivateKey =>
      (privateKeyPem != null && privateKeyPem!.trim().isNotEmpty);
}

class SshProbeResult {
  const SshProbeResult({
    required this.stdout,
    required this.stderr,
    required this.duration,
  });

  final String stdout;
  final String stderr;
  final Duration duration;
}

class SshProbeService {
  const SshProbeService();

  Future<SshProbeResult> runProbe(SshProbeRequest request) async {
    final stopwatch = Stopwatch()..start();

    SSHClient? client;
    SSHSocket? socket;

    try {
      _log.fine('Connecting to ${request.host}:${request.port}');
      socket = await SSHSocket.connect(request.host, request.port);

      final identities = <SSHIdentity>[];
      if (request.usesPrivateKey) {
        identities.add(
          SSHPrivateKey.fromPem(
            request.privateKeyPem!.trim(),
            passphrase: request.privateKeyPassphrase?.trim() ?? '',
          ),
        );
      }
      if ((request.password ?? '').isNotEmpty) {
        identities.add(
          SSHPasswordCredential(request.password!),
        );
      }

      client = SSHClient(
        socket,
        username: request.username,
        identities: identities.isEmpty ? null : identities,
        printDebug: false,
      );

      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      _log.fine('Executing "${request.command}"');
      final session = await client.execute(
        request.command,
        onStdout: (data) => stdoutBuffer.write(String.fromCharCodes(data)),
        onStderr: (data) => stderrBuffer.write(String.fromCharCodes(data)),
      );
      await session.done;

      stopwatch.stop();
      return SshProbeResult(
        stdout: stdoutBuffer.toString(),
        stderr: stderrBuffer.toString(),
        duration: stopwatch.elapsed,
      );
    } on SSHAuthFailError catch (error, stackTrace) {
      _log.warning('Auth failure: $error', error, stackTrace);
      rethrow;
    } on Object catch (error, stackTrace) {
      _log.severe('Probe failed: $error', error, stackTrace);
      rethrow;
    } finally {
      await client?.close();
      await socket?.close();
    }
  }
}
