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
import 'package:player/vz_bubble.dart';

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

  group('Bubble settings', () {
    test('every bubble style paints without throwing', () {
      // همه‌ی ۲۰ مدل باید بدون خطا روی بوم رسم شوند.
      expect(VzBubbleStyle.values.length, equals(20));
      for (final s in VzBubbleStyle.values) {
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        for (final t in [0.05, 0.5, 0.95]) {
          VzBubblePainter(
            origin: const Offset(80, 120), t: t,
            color: const Color(0xFF2FD97A), style: s,
          ).paint(canvas, const Size(200, 300));
        }
        recorder.endRecording();
      }
    });

    testWidgets('bubble style/color/size/speed round-trip through state',
        (tester) async {
      final key = GlobalKey<VzThemeState>();
      await tester.pumpWidget(VzTheme(
        key: key, child: const MaterialApp(home: _Probe())));
      await tester.pumpAndSettle();
      final st = key.currentState!;

      st.setBubbleOn(false);
      await tester.pumpAndSettle();
      expect(Vz.bubbleOn, isFalse);

      st.setBubbleStyle(VzBubbleStyle.confetti);
      await tester.pumpAndSettle();
      expect(Vz.bubbleStyle, VzBubbleStyle.confetti);

      st.setBubbleColor(const Color(0xFFFF5A5F));
      await tester.pumpAndSettle();
      expect(Vz.bubbleColor, const Color(0xFFFF5A5F));
      expect(Vz.bubbleEffectiveColor, const Color(0xFFFF5A5F));

      st.setBubbleSize(1.6);
      await tester.pumpAndSettle();
      expect(Vz.bubbleSize, 1.6);

      st.setBubbleSpeed(0.7);
      await tester.pumpAndSettle();
      expect(Vz.bubbleSpeed, 0.7);
    });
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
