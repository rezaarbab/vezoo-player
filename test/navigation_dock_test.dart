import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/glass.dart';
import 'package:player/theme.dart';

void main() {
  for (final dark in [true, false]) {
    for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
      testWidgets('Dock: dark=$dark direction=$direction, narrow and large text',
          (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(() => buildVezooTheme());
        final semantics = tester.ensureSemantics();
        addTearDown(semantics.dispose);
        var selected = VzNavDest.home;
        await tester.pumpWidget(MaterialApp(
          theme: buildVezooTheme(dark: dark),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(2),
              padding: EdgeInsets.only(bottom: 24),
            ),
            child: Directionality(
              textDirection: direction,
              child: StatefulBuilder(builder: (context, setState) => Scaffold(
                bottomNavigationBar: VzNavDock(
                  current: selected,
                  onSelect: (dest) => setState(() => selected = dest),
                ),
              )),
            ),
          ),
        ));
        final labels = direction == TextDirection.rtl
            ? ['خانه', 'زنده', 'آنلاین', 'کتابخانه', 'تنظیمات']
            : ['Home', 'Live', 'Discover', 'Library', 'Settings'];
        for (var i = 0; i < labels.length; i++) {
          final text = find.text(labels[i]);
          expect(text, findsOneWidget);
          await tester.tap(text);
          await tester.pumpAndSettle();
          expect(selected, VzNavDest.values[i]);
          final node = tester.getSemantics(find.bySemanticsLabel(labels[i]));
          expect(node.hasFlag(SemanticsFlag.isSelected), isTrue);
          expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}
