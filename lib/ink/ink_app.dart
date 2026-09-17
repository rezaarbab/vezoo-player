// lib/ink/ink_app.dart
// Standalone app entry for the INK interface. Nothing here imports the legacy
// theme/glass/shell files, so the default build is untouched.
import 'package:flutter/material.dart' hide Ink;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_service.dart';
import '../l10n.dart';
import '../store.dart';
import 'ink_components.dart';
import 'ink_shell.dart';

class InkApp extends StatefulWidget {
  const InkApp({super.key});
  @override
  State<InkApp> createState() => _InkAppState();
}

class _InkAppState extends State<InkApp> {
  static const String _themeKey = 'ink_theme';
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Ink.setDark(prefs.getString(_themeKey) == 'dark');
      await L.load();
      await Store.load();
      await ApiService.init();
    } catch (error, stack) {
      debugPrint('INK boot failed: $error\n$stack');
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: inkNotifier,
      builder: (context, dark, _) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          systemNavigationBarIconBrightness:
              dark ? Brightness.light : Brightness.dark,
        ));
        return MaterialApp(
          title: 'Vezoo · INK',
          debugShowCheckedModeBanner: false,
          theme: inkThemeData(dark: false),
          darkTheme: inkThemeData(dark: true),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          builder: (ctx, child) => Directionality(
            textDirection: langDir(L.current),
            child: child ?? const SizedBox.shrink(),
          ),
          home: _ready ? const InkShell() : const InkBoot(),
        );
      },
    );
  }
}

/// Flat boot screen: wordmark over the paper texture, hairline progress bar.
class InkBoot extends StatelessWidget {
  const InkBoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ink.canvas,
      body: InkPatternBackground(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('VEZOO',
                style: InkType.micro.copyWith(
                    fontSize: 12, color: Ink.inkFaint)),
            const SizedBox(height: InkSp.x2),
            Text('INK',
                style: InkType.display.copyWith(color: Ink.ink)),
            const SizedBox(height: InkSp.x4),
            SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: Ink.ink.withValues(alpha: 0.12),
                color: Ink.accent,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}