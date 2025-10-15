import 'package:dartssh2/dartssh2.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ssh_probe_service.dart';

final sshProbeControllerProvider =
    StateNotifierProvider<SshProbeController, SshProbeState>(
  (ref) => SshProbeController(const SshProbeService()),
);

class SshProbeController extends StateNotifier<SshProbeState> {
  SshProbeController(this._service) : super(const SshProbeState.idle());

  final SshProbeService _service;

  Future<void> runProbe(SshProbeRequest request) async {
    state = const SshProbeState.loading();
    try {
      final result = await _service.runProbe(request);
      state = SshProbeState.success(result);
    } on SSHAuthFailError catch (error) {
      state = SshProbeState.failure('Authentication failed: ${error.message}');
    } on Object catch (error) {
      state = SshProbeState.failure(error.toString());
    }
  }

  void reset() {
    state = const SshProbeState.idle();
  }
}

class SshProbeState {
  const SshProbeState._({
    required this.isLoading,
    this.result,
    this.errorMessage,
  });

  const SshProbeState.idle() : this._(isLoading: false);

  const SshProbeState.loading() : this._(isLoading: true);

  const SshProbeState.success(SshProbeResult result)
      : this._(isLoading: false, result: result);

  const SshProbeState.failure(String message)
      : this._(isLoading: false, errorMessage: message);

  final bool isLoading;
  final SshProbeResult? result;
  final String? errorMessage;

  bool get hasResult => result != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
}
