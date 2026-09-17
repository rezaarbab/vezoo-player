// test/ink_navigation_test.dart
// InkTabBar behaviour across themes, directions, sizes and text scaling.
import 'package:flutter/material.dart' hide Ink;
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/ink/ink_components.dart';

const List<InkTabItem> _items = [
  InkTabItem(id: 'files', icon: Icons.folder_copy_outlined, label: 'Files'),
  InkTabItem(id: 'recent', icon: Icons.history_rounded, label: 'Recent'),
  InkTabItem(id: 'setup', icon: Icons.tune_rounded, label: 'Setup'),
];

void main() {
  tearDown(() => Ink.setDark(false));

  for (final dark in [false, true]) {
    for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
      testWidgets('InkTabBar dark=$dark dir=$direction narrow + large text',
          (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Ink.setDark(dark);

        final handle = tester.ensureSemantics();
        try {
          var current = 'files';
          await tester.pumpWidget(MaterialApp(
            theme: inkThemeData(dark: dark),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 640),
                textScaler: TextScaler.linear(2),
                padding: EdgeInsets.only(bottom: 24),
              ),
              child: Directionality(
                textDirection: direction,
                child: StatefulBuilder(
                  builder: (context, setState) => Scaffold(
                    bottomNavigationBar: InkTabBar(
                      items: _items,
                      current: current,
                      onSelect: (id) => setState(() => current = id),
                    ),
                  ),
                ),
              ),
            ),
          ));

          for (final item in _items) {
            final label = find.text(item.label.toUpperCase());
            expect(label, findsOneWidget);
            await tester.tap(label);
            await tester.pumpAndSettle();
            expect(current, item.id);
            final node = tester.getSemantics(find.bySemanticsLabel(item.label));
            expect(node.hasFlag(SemanticsFlag.isSelected), isTrue);
            expect(
                node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
            expect(tester.takeException(), isNull);
          }
        } finally {
          handle.dispose();
        }
      });
    }
  }

  testWidgets('InkTabBar keeps every destination inside the viewport',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: inkThemeData(dark: false),
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(2),
        ),
        child: Scaffold(
          bottomNavigationBar: InkTabBar(
            items: _items,
            current: 'files',
            onSelect: (_) {},
          ),
        ),
      ),
    ));
    final barRect = tester.getRect(find.byType(InkTabBar));
    expect(barRect.width, lessThanOrEqualTo(320));
    for (final item in _items) {
      final rect = tester.getRect(find.text(item.label.toUpperCase()));
      expect(rect.left, greaterThanOrEqualTo(-0.5));
      expect(rect.right, lessThanOrEqualTo(320.5));
    }
    expect(tester.takeException(), isNull);
  });
}