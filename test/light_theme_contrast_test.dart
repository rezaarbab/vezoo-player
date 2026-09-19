// test/light_theme_contrast_test.dart
//
// چرا این تست: در تم روشن بعضی متن‌ها/آیکون‌ها روی سطح سفید محو می‌شدند.
// علت: ویجت‌هایی که رنگ را از Vz.* سراسری می‌خوانند و به VzThemeScope
// وابسته نیستند، بعد از عوض کردن تم rebuild نمی‌شدند و رنگِ تم قبلی
// روی‌شان می‌ماند (نتیجه: ترکیب ناهماهنگ روشن/تیره).
//
// این تست دو چیز را تضمین می‌کند:
//   ۱) پالت روشن کنتراست کافی دارد (از پالت).
//   ۲) عوض کردن تم باعث rebuild واقعی ویجت‌ها می‌شود.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/theme.dart';

double _lum(Color c) {
  double f(double v) =>
      v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055);
  double ch(double x) => (x * 255.0).round() / 255.0;
  final r = f(ch(c.r)), g = f(ch(c.g)), b = f(ch(c.b));
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrast(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('Light theme contrast', () {
    test('light palette text stays readable on every surface', () {
      final p = vzBuildPalette(const Color(0xFF6750A4), dark: false);

      // متن اصلی روی هر سطح باید ≥ 4.5 باشد
      for (final entry in {
        'bg': p.bg, 'surface': p.surface, 'card': p.card,
        'cardHi': p.cardHi, 'surfaceHi': p.surfaceHi,
      }.entries) {
        expect(_contrast(p.text, entry.value), greaterThanOrEqualTo(4.5),
            reason: 'text روی ${entry.key} خوانا نیست');
        expect(_contrast(p.textSec, entry.value), greaterThanOrEqualTo(4.0),
            reason: 'textSec روی ${entry.key} خوانا نیست');
      }

      // اکسنت روی کارت باید دیده شود
      expect(_contrast(p.accent, p.card), greaterThanOrEqualTo(3.0),
          reason: 'accent روی کارت دیده نمی‌شود');
    });

    test('dark palette text stays readable too', () {
      final p = vzBuildPalette(const Color(0xFF6750A4), dark: true);
      expect(_contrast(p.text, p.card), greaterThanOrEqualTo(4.5));
      expect(_contrast(p.textSec, p.card), greaterThanOrEqualTo(4.0));
      expect(_contrast(p.accent, p.card), greaterThanOrEqualTo(3.0));
    });
  });

  group('Theme switch rebuilds widgets', () {
    testWidgets('switching to light repaints global Vz colors', (tester) async {
      final key = GlobalKey<VzThemeState>();

      await tester.pumpWidget(VzTheme(
        key: key,
        child: const MaterialApp(home: _Probe()),
      ));

      // تم پیش‌فرض: تیره
      key.currentState!.setMode(VzThemeMode.dark);
      await tester.pumpAndSettle();
      final darkText = Vz.text;
      expect(_contrast(darkText, Vz.card), greaterThanOrEqualTo(4.5));

      // عوض کردن به روشن باید رنگ‌ها را واقعاً دوباره بسازد
      key.currentState!.setMode(VzThemeMode.light);
      await tester.pumpAndSettle();
      final lightText = Vz.text;

      expect(lightText, isNot(equals(darkText)),
          reason: 'رنگ متن بعد از عوض کردن تم عوض نشد');
      expect(_contrast(lightText, Vz.card), greaterThanOrEqualTo(4.5));

      // ویجت نشانگر دوباره ساخته شده و رنگ جدید را دیده
      final probe = tester.widget<Text>(find.byKey(const ValueKey('probe')));
      expect(probe.style?.color, equals(Vz.text),
          reason: 'ویجت با رنگ کهنه رندر شده');
    });
  });
}

class _Probe extends StatelessWidget {
  const _Probe();
  @override
  Widget build(BuildContext context) {
    // عمداً به VzThemeScope وابسته نیست — مثل اکثر ویجت‌های اپ.
    return Scaffold(
      body: Center(child: Text('probe', key: const ValueKey('probe'),
          style: TextStyle(color: Vz.text))),
    );
  }
}
