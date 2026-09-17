// test/ink_components_test.dart
// Widget coverage for the INK component set.
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/ink/ink_components.dart';

Widget _host(Widget child, {TextDirection? direction, double textScale = 1}) {
  return MaterialApp(
    theme: inkThemeData(dark: Ink.isDark),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Directionality(
        textDirection: direction ?? TextDirection.ltr,
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  tearDown(() => Ink.setDark(false));

  testWidgets('InkCard shows the ledger index, accent bar and fires onTap',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(InkCard(
      index: 3,
      accentBar: true,
      onTap: () => taps++,
      child: const Text('clip.mp4'),
    )));
    expect(find.text('03'), findsOneWidget);
    expect(find.text('clip.mp4'), findsOneWidget);
    await tester.tap(find.text('clip.mp4'));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('InkCard without onTap is not announced as a button',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(_host(const InkCard(
        semanticLabel: 'row',
        child: Text('static row'),
      )));
      final node = tester.getSemantics(find.bySemanticsLabel('row'));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('InkButton and InkIconButton report taps and semantics',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      var buttonTaps = 0;
      var iconTaps = 0;
      await tester.pumpWidget(_host(Column(children: [
        InkButton(
            label: 'Play',
            icon: Icons.play_arrow_rounded,
            onTap: () => buttonTaps++),
        InkIconButton(
            icon: Icons.more_horiz_rounded,
            tooltip: 'Actions',
            onTap: () => iconTaps++),
      ])));
      expect(find.text('PLAY'), findsOneWidget);
      await tester.tap(find.text('PLAY'));
      await tester.tap(find.bySemanticsLabel('Actions'));
      expect(buttonTaps, 1);
      expect(iconTaps, 1);
      final node = tester.getSemantics(find.bySemanticsLabel('Actions'));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('InkButton with a null onTap stays inert', (tester) async {
    await tester.pumpWidget(_host(const InkButton(label: 'Disabled')));
    await tester.tap(find.text('DISABLED'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('InkEmpty renders title, hint and action', (tester) async {
    await tester.pumpWidget(_host(InkEmpty(
      icon: Icons.movie_filter_rounded,
      title: 'Nothing here',
      hint: 'Open another folder',
      action: InkButton(label: 'Retry', onTap: () {}),
    )));
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Open another folder'), findsOneWidget);
    expect(find.text('RETRY'), findsOneWidget);
    expect(find.byIcon(Icons.movie_filter_rounded), findsOneWidget);
  });

  testWidgets('InkField renders its uppercase caption and hint',
      (tester) async {
    await tester.pumpWidget(_host(const InkField(
      label: 'filter',
      hint: 'Filter by name',
    )));
    expect(find.text('FILTER'), findsOneWidget);
    expect(find.text('Filter by name'), findsOneWidget);
  });

  testWidgets('InkHeader and InkRule render their copy', (tester) async {
    await tester.pumpWidget(_host(const Column(children: [
      InkHeader(title: 'Files', kicker: 'download'),
      InkRule(label: '12 items'),
      InkBadge(text: 'mp4'),
    ])));
    expect(find.text('Files'), findsOneWidget);
    expect(find.text('DOWNLOAD'), findsOneWidget);
    expect(find.text('12 ITEMS'), findsOneWidget);
    expect(find.text('MP4'), findsOneWidget);
  });

  testWidgets('InkPatternBackground paints and keeps its child',
      (tester) async {
    await tester.pumpWidget(_host(const InkPatternBackground(
      child: Text('paper'),
    )));
    expect(find.text('paper'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}