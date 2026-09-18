// lib/vz_theme.dart — موتور تم به سبک Namida
//
// فلسفه‌ی این تم (الهام از Namida، بدون کپی کد):
//   • **رنگ داینامیک**: کل پالت از یک «رنگ دانه» (seed) ساخته می‌شود —
//     یا رنگ انتخابی کاربر، یا رنگی که از پوستر/آرت‌ورک استخراج شده.
//   • **لایه‌بندی M3**: surface / surfaceContainer / surfaceContainerHigh …
//     به‌جای شمردن دستی چند رنگ ثابت. هر سطح از tonal palette می‌آید.
//   • **دو حالت** تیره/روشن که کاملاً از یک seed مشتق می‌شوند.
//   • **تم‌های آماده** فقط چند seed از پیش تعریف‌شده‌اند (lib/vz_anime_themes.dart).
//
// این فایل هیچ وابستگی‌ای به UI ندارد — فقط پالت و توکن.
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SEED → TONAL PALETTE
// ─────────────────────────────────────────────────────────────────────────────

/// یک پالت کامل که از یک seed ساخته می‌شود.
/// همه‌ی رنگ‌ها نسبت به هم هارمونیک‌اند چون از یک hue می‌آیند.
@immutable
class VzPalette {
  final Color seed;
  final bool dark;

  // پایه
  final Color bg;
  final Color bgDeep;
  final Color surface;
  final Color surfaceHi;   // یک پله بالاتر از surface
  final Color card;
  final Color cardHi;
  final Color border;
  final Color borderHi;

  // اکسنت
  final Color accent;
  final Color accentHi;
  final Color accentDeep;
  final Color onAccent;
  final Color accentSoft;  // زمینه‌ی کم‌رنگ برای چیپ/بج

  // متن
  final Color text;
  final Color textSec;
  final Color textDim;

  // semantic (از seed مشتق می‌شوند تا هماهنگ بمانند)
  final Color green;
  final Color amber;
  final Color red;
  final Color pink;

  const VzPalette({
    required this.seed,
    required this.dark,
    required this.bg,
    required this.bgDeep,
    required this.surface,
    required this.surfaceHi,
    required this.card,
    required this.cardHi,
    required this.border,
    required this.borderHi,
    required this.accent,
    required this.accentHi,
    required this.accentDeep,
    required this.onAccent,
    required this.accentSoft,
    required this.text,
    required this.textSec,
    required this.textDim,
    required this.green,
    required this.amber,
    required this.red,
    required this.pink,
  });
}

/// نسبت کنتراست WCAG بین دو رنگ.
double vzContrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// بهترین رنگ متن (تیره یا روشن) برای یک پس‌زمینه.
Color vzOnColor(Color background) {
  const dark = Color(0xFF0C0C0F);
  return vzContrast(background, dark) >= vzContrast(background, Colors.white)
      ? dark
      : Colors.white;
}

/// از یک seed، پالت کامل تیره می‌سازد.
/// از HSL استفاده می‌کنیم تا همه‌ی رنگ‌ها هم‌خانواده بمانند.
///
/// [bgTint] رنگ پایه‌ی پس‌زمینه را دستی تعیین می‌کند (مثل سرمه‌ای Tako).
/// [accentLock] رنگ اکسنت را دقیقاً همان مقدار می‌گذارد (بدون مشتق‌گیری).
VzPalette vzBuildPalette(
  Color seed, {
  required bool dark,
  Color? bgTint,
  Color? accentLock,
}) {
  final hsl = HSLColor.fromColor(seed);
  final h = hsl.hue;

  // رنگ‌های سطح: hue کم‌اشباع و روشنایی کنترل‌شده
  Color surf(double l, double s) =>
      HSLColor.fromAHSL(1, h, s.clamp(0.0, 1.0), l.clamp(0.0, 1.0)).toColor();

  if (dark) {
    // پس‌زمینه: اگر تم رنگ پایه داده، از آن مشتق بگیر (hue آن را نگه دار)
    final base = bgTint ?? seed;
    final bh = HSLColor.fromColor(base).hue;
    Color surfB(double l, double s) =>
        HSLColor.fromAHSL(1, bh, s.clamp(0.0, 1.0), l.clamp(0.0, 1.0)).toColor();

    final bg        = surfB(0.055, 0.22);
    final bgDeep    = surfB(0.035, 0.24);
    final surface   = surfB(0.10, 0.20);
    final surfaceHi = surfB(0.13, 0.18);
    final card      = surfB(0.145, 0.16);
    final cardHi    = surfB(0.19, 0.14);
    final border    = surfB(0.25, 0.13);
    final borderHi  = surfB(0.34, 0.15);

    // اکسنت: اگر قفل شده، همان؛ وگرنه روشن و اشباع برای دیده شدن روی تیره
    final accent    = accentLock ??
        HSLColor.fromAHSL(1, h, (hsl.saturation + 0.20).clamp(0.35, 0.95), 0.64).toColor();
    final accentHi  = accentLock != null
        ? Color.lerp(accentLock, Colors.white, 0.28)!
        : HSLColor.fromAHSL(1, h, (hsl.saturation + 0.15).clamp(0.30, 0.90), 0.76).toColor();
    final accentDeep= accentLock != null
        ? Color.lerp(accentLock, Colors.black, 0.35)!
        : HSLColor.fromAHSL(1, h, (hsl.saturation + 0.10).clamp(0.30, 0.90), 0.40).toColor();
    final accentSoft= accent.withValues(alpha: 0.16);

    return VzPalette(
      seed: seed, dark: true,
      bg: bg, bgDeep: bgDeep, surface: surface, surfaceHi: surfaceHi,
      card: card, cardHi: cardHi, border: border, borderHi: borderHi,
      accent: accent, accentHi: accentHi, accentDeep: accentDeep,
      onAccent: vzOnColor(accent), accentSoft: accentSoft,
      text: const Color(0xFFF2F2F5),
      textSec: const Color(0xFFA6A6B0),
      textDim: const Color(0xFF6E6E7A),
      green: accentLock ?? const Color(0xFF5BD69A),
      amber: const Color(0xFFF5C144),
      red:   const Color(0xFFF0736F),
      pink:  const Color(0xFFF07AAE),
    );
  }

  // ── روشن: پس‌زمینه کاغذی، کارت سفید، خطوط واقعاً دیده‌شدنی ──
  // نکته: قبلاً surface و card هر دو سفید خالص بودند و مرزها نامرئی؛
  // نتیجه «تم سفید اشغال» بود. الان پله‌ها مشخص‌اند:
  //   bg (کاغذی) < card (سفید) و خط border واضح.
  final bg        = HSLColor.fromAHSL(1, h, 0.24, 0.955).toColor();
  final bgDeep    = HSLColor.fromAHSL(1, h, 0.28, 0.915).toColor();
  final surface   = Colors.white;
  final surfaceHi = HSLColor.fromAHSL(1, h, 0.26, 0.975).toColor();
  final card      = Colors.white;
  final cardHi    = HSLColor.fromAHSL(1, h, 0.30, 0.925).toColor();
  final border    = HSLColor.fromAHSL(1, h, 0.26, 0.840).toColor();
  final borderHi  = HSLColor.fromAHSL(1, h, 0.28, 0.700).toColor();

  // اکسنت روشن باید کنتراست کافی روی سفید داشته باشد (نه پاستلی)
  final accent    = HSLColor.fromAHSL(1, h, (hsl.saturation + 0.10).clamp(0.45, 0.92), 0.36).toColor();
  final accentHi  = HSLColor.fromAHSL(1, h, (hsl.saturation + 0.08).clamp(0.40, 0.90), 0.46).toColor();
  final accentDeep= HSLColor.fromAHSL(1, h, (hsl.saturation + 0.06).clamp(0.40, 0.90), 0.26).toColor();
  final accentSoft= accent.withValues(alpha: 0.12);

  return VzPalette(
    seed: seed, dark: false,
    bg: bg, bgDeep: bgDeep, surface: surface, surfaceHi: surfaceHi,
    card: card, cardHi: cardHi, border: border, borderHi: borderHi,
    accent: accent, accentHi: accentHi, accentDeep: accentDeep,
    onAccent: vzOnColor(accent), accentSoft: accentSoft,
    // متن‌ها با کنتراست بالا روی کاغذ روشن
    text: const Color(0xFF101018),
    textSec: const Color(0xFF4A4A57),
    textDim: const Color(0xFF7A7A88),
    green: const Color(0xFF0F6E4F),
    amber: const Color(0xFF855400),
    red:   const Color(0xFFA31813),
    pink:  const Color(0xFFA33368),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  BACKGROUND STYLES
// ─────────────────────────────────────────────────────────────────────────────

/// چیدمان پس‌زمینه. Namida تخت است، ولی چند گزینه‌ی ملایم هم داریم.
enum VzBgStyle {
  /// تخت — بدون گرادیان (سبک Namida)
  flat,
  /// گرادیان ملایم از پایین
  soft,
  /// هاله‌های رنگ در گوشه‌ها
  glow,
  /// موج رنگی قوی‌تر
  vivid,
}

/// گرادیان پس‌زمینه را از پالت می‌سازد.
LinearGradient vzBackground(VzPalette p, VzBgStyle style) {
  switch (style) {
    case VzBgStyle.flat:
      return LinearGradient(colors: [p.bg, p.bg]);
    case VzBgStyle.soft:
      return LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [
          Color.lerp(p.bg, p.accent, p.dark ? 0.10 : 0.07)!,
          p.bg,
        ]);
    case VzBgStyle.glow:
      return LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [
          Color.lerp(p.bg, p.accent, p.dark ? 0.16 : 0.11)!,
          p.bg,
          Color.lerp(p.bg, p.accentHi, p.dark ? 0.09 : 0.07)!,
        ],
        stops: const [0.0, 0.55, 1.0]);
    case VzBgStyle.vivid:
      return LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [
          Color.lerp(p.bg, p.accent, p.dark ? 0.26 : 0.18)!,
          p.bg,
          Color.lerp(p.bg, p.accentHi, p.dark ? 0.18 : 0.13)!,
        ],
        stops: const [0.0, 0.5, 1.0]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ACCENT SWATCHES (چند رنگ آماده برای انتخاب سریع)
// ─────────────────────────────────────────────────────────────────────────────

/// رنگ‌های پیشنهادی برای «رنگ دانه». کاربر هر رنگ دیگری هم می‌تواند بدهد.
const List<Color> kVzSeeds = [
  Color(0xFF00AEEC), // آبی آسمانی
  Color(0xFFFB7299), // صورتی
  Color(0xFF8B5CF6), // بنفش
  Color(0xFF22C55E), // سبز
  Color(0xFFF59E0B), // کهربایی
  Color(0xFFEF4444), // قرمز
  Color(0xFF06B6D4), // فیروزه‌ای
  Color(0xFFEC4899), // ارغوانی
  Color(0xFF84CC16), // لیمویی
  Color(0xFFFAEDCD), // کرم
  Color(0xFF64748B), // خاکستری‌آبی
  Color(0xFF1E1E24), // تقریباً سیاه
];
