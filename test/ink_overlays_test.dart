// test/ink_overlays_test.dart
// INK sheets and dialogs.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/ink/ink_components.dart';

Widget _host(Widget child) => MaterialApp(
      theme: inkThemeData(dark: Ink.isDark),
      home: Scaffold(body: child),
    );

void main() {
  tearDown(() => Ink.setDark(false));

  testWidgets('showInkConfirm resolves true/false from its actions',
      (tester) async {
    bool? answer;
    await tester.pumpWidget(_host(Builder(
      builder: (context) => InkButton(
        label: 'Ask',
        onTap: () async {
          answer = await showInkConfirm(
            context: context,
            title: 'clear history',
            message: 'Removes watch history only.',
          );
        },
      ),
    )));
    await tester.tap(find.text('ASK'));
    await tester.pumpAndSettle();
    expect(find.text('CLEAR HISTORY'), findsOneWidget);
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(answer, isFalse);

    await tester.tap(find.text('ASK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();
    expect(answer, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('showInkSheet shows the flat frame and closes', (tester) async {
    await tester.pumpWidget(_host(Builder(
      builder: (context) => InkButton(
        label: 'Open',
        onTap: () => showInkSheet<void>(
          context: context,
          title: 'clip.mp4',
          kicker: '12.4 MB',
          child: const Padding(
            padding: EdgeInsets.all(InkSp.x4),
            child: Text('sheet body'),
          ),
        ),
      ),
    )));
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
    expect(find.text('clip.mp4'), findsOneWidget);
    expect(find.text('12.4 MB'), findsOneWidget);
    expect(find.text('sheet body'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('sheet body'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}