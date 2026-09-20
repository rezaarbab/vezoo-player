// test/theme_live_repaint_test.dart
//
// کاربر گزارش داد در تم لایت بعضی متن‌ها/آیکون‌ها تیره می‌مانند، مخصوصاً
// روی صفحه‌های تازه ساخته‌شده. این تست تضمین می‌کند که یک ویجت که فقط
// رنگ سراسری Vz.* را می‌خواند (و به VzThemeScope وابسته نیست) بعد از
// تغییر تم، رنگ تازه را ببیند — هم در ریشه و هم در یک route که با push
// باز شده است.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/theme.dart';

void main() {
  testWidgets('a pushed route repaints after a theme switch', (tester) async {
    final key = GlobalKey<VzThemeState>();
    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(VzTheme(
      key: key,
      child: MaterialApp(
        navigatorKey: navKey,
        home: const _RootProbe(),
      ),
    ));
    await tester.pumpAndSettle();

    key.currentState!.setMode(VzThemeMode.dark);
    await tester.pumpAndSettle();
    expect(Vz.isDark, isTrue);

    // یک صفحه‌ی تازه روی Navigator باز کن
    navKey.currentState!.push(MaterialPageRoute(builder: (_) => const _Probe()));
    await tester.pumpAndSettle();
    final colorOnPush = tester.widget<Text>(_probeText).style!.color;
    expect(colorOnPush, equals(Vz.text));

    // حالا تم را روشن کن — همان route باز باید رنگ تازه بگیرد
    key.currentState!.setMode(VzThemeMode.light);
    await tester.pumpAndSettle();

    expect(Vz.isDark, isFalse);
    final colorAfter = tester.widget<Text>(_probeText).style!.color;
    expect(colorAfter, equals(Vz.text),
        reason: 'route باز با رنگ کهنه رندر شده');
  });

  testWidgets('unmounted-then-recreated widget reads fresh colors',
      (tester) async {
    final key = GlobalKey<VzThemeState>();
    await tester.pumpWidget(VzTheme(
      key: key,
      child: const MaterialApp(home: _RootProbe()),
    ));
    await tester.pumpAndSettle();

    key.currentState!.setMode(VzThemeMode.light);
    await tester.pumpAndSettle();
    final c1 = tester.widget<Text>(_probeText).style!.color;

    // ویجت را کامل از درخت بیرون ببر و دوباره بساز
    await tester.pumpWidget(VzTheme(
      key: key,
      child: const MaterialApp(home: SizedBox()),
    ));
    await tester.pumpAndSettle();
    await tester.pumpWidget(VzTheme(
      key: key,
      child: const MaterialApp(home: _RootProbe()),
    ));
    await tester.pumpAndSettle();
    final c2 = tester.widget<Text>(_probeText).style!.color;

    expect(c1, equals(c2));
    expect(c2, equals(Vz.text));
  });
}

final _probeText = find.byKey(const ValueKey('probe'));

class _RootProbe extends StatelessWidget {
  const _RootProbe();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: _Probe()));
}

class _Probe extends StatelessWidget {
  const _Probe();
  @override
  Widget build(BuildContext context) {
    // فقط رنگ سراسری می‌خواند — به VzThemeScope وابسته نیست.
    return Text('probe', key: const ValueKey('probe'),
        style: TextStyle(color: Vz.text));
  }
}
