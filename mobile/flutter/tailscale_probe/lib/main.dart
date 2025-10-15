import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import 'ui/home_page.dart';

void main() {
  _setupLogging();
  runApp(const ProviderScope(child: TailscaleProbeApp()));
}

void _setupLogging() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '[${record.loggerName}] ${record.level.name} ${record.time.toIso8601String()} ${record.message}',
    );
  });
}

class TailscaleProbeApp extends StatelessWidget {
  const TailscaleProbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );

    return MaterialApp(
      title: 'Tailscale Probe',
      theme: theme,
      home: const HomePage(),
    );
  }
}
