// lib/ink/ink_shell.dart
// INK shell: flat index bar + paper background over an IndexedStack.
import 'package:flutter/material.dart';

import 'ink_components.dart';
import 'ink_screens.dart';

class InkShell extends StatefulWidget {
  const InkShell({super.key});
  @override
  State<InkShell> createState() => _InkShellState();
}

class _InkShellState extends State<InkShell> {
  static const List<InkTabItem> _items = [
    InkTabItem(id: 'files', icon: Icons.folder_copy_outlined, label: 'Files'),
    InkTabItem(id: 'recent', icon: Icons.history_rounded, label: 'Recent'),
    InkTabItem(id: 'setup', icon: Icons.tune_rounded, label: 'Setup'),
  ];

  String _current = 'files';

  int get _index {
    final i = _items.indexWhere((item) => item.id == _current);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ink.canvas,
      body: InkPatternBackground(
        child: SafeArea(
          top: false,
          child: IndexedStack(
            index: _index,
            children: const [
              InkFilesScreen(),
              InkRecentScreen(),
              InkSetupScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: InkTabBar(
        items: _items,
        current: _current,
        onSelect: (id) => setState(() => _current = id),
      ),
    );
  }
}