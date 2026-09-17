// lib/vz_presets.dart — VOID Theme Engine
//
// یک پرسِت تم = پالت + گردی گوشه + بک‌گراند گرادیانی + سبک تایپوگرافی.
// کاربر یک پرسِت انتخاب می‌کند، یا رنگ اکسنت را جدا عوض می‌کند.
//
// این فایل عمداً هیچ وابستگی‌ای به theme.dart ندارد تا از چرخه import
// جلوگیری شود؛ theme.dart از اینجا استفاده می‌کند.
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PRESET MODEL
// ─────────────────────────────────────────────────────────────────────────────

/// سبک بصری کلی اپ.
enum VzStyle {
  /// گرد، نرم، آبرنگی — مثل اپ‌های دخترونه/کیوت
  kawaii,
  /// تیزتر، تیره، انرژی‌دار — مثل اپ‌های پسرونه/گیمینگ
  shonen,
  /// انیمه/موئه — سبک Bilibili / Gainax: آبی-صورتی، خطوط نازک، گردی بالا
  anime,
  /// خنثی و مینیمال
  mono,
}

class VzPreset {
  final String id;
  final String name;
  final String tagline;
  final VzStyle style;

  // ── رنگ‌های پایه (تیره) ──
  final Color bgDark, bgDeepDark, surfaceDark, cardDark, cardHiDark,
      borderDark, borderHiDark;
  // ── رنگ‌های پایه (روشن) — این‌ها باید واقعاً روشن باشند ──
  final Color bgLight, bgDeepLight, surfaceLight, cardLight, cardHiLight,
      borderLight, borderHiLight;

  // ── اکسنت پیش‌فرض این پرسِت (تیره/روشن/hi/deep) ──
  final Color accentDark, accentDarkHi, accentDarkDeep;
  final Color accentLight, accentLightHi, accentLightDeep;
  final Color accent2; // رنگ مکمل برای گرادیان‌ها

  // ── بک‌گراند گرادیانی ──
  final List<Color> bgGradientsDark;
  final List<Color> bgGradientsLight;

  // ── شکل و متن ──
  final double radiusScale; // 0.6 تیز … 1.6 خیلی گرد
  final double? fontScale;  // پیش‌فرض 1

  const VzPreset({
    required this.id,
    required this.name,
    required this.tagline,
    required this.style,
    required this.bgDark,
    required this.bgDeepDark,
    required this.surfaceDark,
    required this.cardDark,
    required this.cardHiDark,
    required this.borderDark,
    required this.borderHiDark,
    required this.bgLight,
    required this.bgDeepLight,
    required this.surfaceLight,
    required this.cardLight,
    required this.cardHiLight,
    required this.borderLight,
    required this.borderHiLight,
    required this.accentDark,
    required this.accentDarkHi,
    required this.accentDarkDeep,
    required this.accentLight,
    required this.accentLightHi,
    required this.accentLightDeep,
    required this.accent2,
    required this.bgGradientsDark,
    required this.bgGradientsLight,
    this.radiusScale = 1.0,
    this.fontScale,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  ۶ پرسِت — ۳ کیوت/دخترونه + ۳ انرژی‌دار/پسرونه
// ─────────────────────────────────────────────────────────────────────────────

const List<VzPreset> kVzPresets = [
  // ══════════════════ ۰) BILIBILI — آبی/صورتی، سبک موئه ══════════════════
  // رنگ برند Bilibili (#00AEEC) + صورتی لایک (#FB7299).
  // گردترین پرسِت و مرجع سبک «انیمه» در این اپ.
  VzPreset(
    id: 'bilibili',
    name: 'Bilibili',
    tagline: 'Sky blue · pink · moe',
    style: VzStyle.anime,
    bgDark: Color(0xFF10141C),
    bgDeepDark: Color(0xFF0A0D13),
    surfaceDark: Color(0xFF171D28),
    cardDark: Color(0xFF1D2531),
    cardHiDark: Color(0xFF26303F),
    borderDark: Color(0xFF2E3A4D),
    borderHiDark: Color(0xFF42536B),
    // روشن: آبی خیلی کم‌رنگ با ته‌مایه صورتی، نه سفید مرده
    bgLight: Color(0xFFF2F8FE),
    bgDeepLight: Color(0xFFE6F2FC),
    surfaceLight: Color(0xFFFFFFFF),
    cardLight: Color(0xFFFFFFFF),
    cardHiLight: Color(0xFFE9F4FD),
    borderLight: Color(0xFFD3E6F7),
    borderHiLight: Color(0xFFA8CDEC),
    accentDark: Color(0xFF00AEEC),
    accentDarkHi: Color(0xFF5CD0FF),
    accentDarkDeep: Color(0xFF00759E),
    accentLight: Color(0xFF0091C7),
    accentLightHi: Color(0xFF00AEEC),
    accentLightDeep: Color(0xFF00688A),
    accent2: Color(0xFFFB7299),
    bgGradientsDark: [Color(0xFF0E2233), Color(0xFF10141C), Color(0xFF2A1526)],
    bgGradientsLight: [Color(0xFFD9EEFF), Color(0xFFF2F8FE), Color(0xFFFFE4EE)],
    radiusScale: 1.8,
  ),

  // ══════════════════ ۰.۵) GAINAX — انیمه کامل، نئون/پاپ ══════════════════
  // انیمه‌ی ۹۰ها: نارنجی-قرمز روی سرمه‌ای، کنتراست بالا، گردی زیاد.
  VzPreset(
    id: 'gainax',
    name: 'Gainax',
    tagline: 'Anime pop · bold · retro',
    style: VzStyle.anime,
    bgDark: Color(0xFF0D0A18),
    bgDeepDark: Color(0xFF070510),
    surfaceDark: Color(0xFF151024),
    cardDark: Color(0xFF1D1730),
    cardHiDark: Color(0xFF272040),
    borderDark: Color(0xFF332A52),
    borderHiDark: Color(0xFF4A3F73),
    bgLight: Color(0xFFFDF6F3),
    bgDeepLight: Color(0xFFFCEAE2),
    surfaceLight: Color(0xFFFFFFFF),
    cardLight: Color(0xFFFFFFFF),
    cardHiLight: Color(0xFFFDECE4),
    borderLight: Color(0xFFF3D6C8),
    borderHiLight: Color(0xFFE7B39A),
    accentDark: Color(0xFFFF6B35),
    accentDarkHi: Color(0xFFFF9A6B),
    accentDarkDeep: Color(0xFFB33A12),
    accentLight: Color(0xFFE8481C),
    accentLightHi: Color(0xFFFF6B35),
    accentLightDeep: Color(0xFFA82F0F),
    accent2: Color(0xFFFFD23F),
    bgGradientsDark: [Color(0xFF231535), Color(0xFF0D0A18), Color(0xFF33131F)],
    bgGradientsLight: [Color(0xFFFFE0D0), Color(0xFFFDF6F3), Color(0xFFFFF3D6)],
    radiusScale: 1.6,
  ),

  // ══════════════════ ۱) SAKURA — دخترونه، صورتی/آبرنگی ══════════════════
  VzPreset(
    id: 'sakura',
    name: 'Sakura',
    tagline: 'Soft pink · airy · kawaii',
    style: VzStyle.kawaii,
    bgDark: Color(0xFF1A1218),
    bgDeepDark: Color(0xFF120C11),
    surfaceDark: Color(0xFF241A22),
    cardDark: Color(0xFF2C2029),
    cardHiDark: Color(0xFF3A2A35),
    borderDark: Color(0xFF4A3542),
    borderHiDark: Color(0xFF66485A),
    // روشن: صورتی بسیار روشن، نه سفید خالص
    bgLight: Color(0xFFFFF5F9),
    bgDeepLight: Color(0xFFFDEBF3),
    surfaceLight: Color(0xFFFFFCFE),
    cardLight: Color(0xFFFFFFFF),
    cardHiLight: Color(0xFFFCE9F2),
    borderLight: Color(0xFFF2D5E3),
    borderHiLight: Color(0xFFE2B3CA),
    accentDark: Color(0xFFF472B6),
    accentDarkHi: Color(0xFFF9A8D4),
    accentDarkDeep: Color(0xFFBE185D),
    accentLight: Color(0xFFDB2777),
    accentLightHi: Color(0xFFEC4899),
    accentLightDeep: Color(0xFF9D174D),
    accent2: Color(0xFFA78BFA),
    bgGradientsDark: [Color(0xFF2A1520), Color(0xFF1A1218), Color(0xFF1E1526)],
    bgGradientsLight: [Color(0xFFFFEAF3), Color(0xFFFFF5F9), Color(0xFFF3ECFF)],
    radiusScale: 1.5,
  ),

  // ══════════════════ ۲) MOMOKO — دخترونه، هلویی/نارنجی ══════════════════
  VzPreset(
    id: 'momoko',
    name: 'Momoko',
    tagline: 'Peach · warm · bubbly',
    style: VzStyle.kawaii,
    bgDark: Color(0xFF1C1410),
    bgDeepDark: Color(0xFF130D0A),
    surfaceDark: Color(0xFF251A15),
    cardDark: Color(0xFF2E211A),
    cardHiDark: Color(0xFF3D2C22),
    borderDark: Color(0xFF4D382C),
    borderHiDark: Color(0xFF6B4E3D),
    bgLight: Color(0xFFFFF7F1),
    bgDeepLight: Color(0xFFFDEDE1),
    surfaceLight: Color(0xFFFFFCFA),
    cardLight: Color(0xFFFFFFFF),
    cardHiLight: Color(0xFFFCEBE0),
    borderLight: Color(0xFFF3D9C7),
    borderHiLight: Color(0xFFE5BBA0),
    accentDark: Color(0xFFFB923C),
    accentDarkHi: Color(0xFFFDBA74),
    accentDarkDeep: Color(0xFFC2410C),
    accentLight: Color(0xFFEA580C),
    accentLightHi: Color(0xFFF97316),
    accentLightDeep: Color(0xFF9A3412),
    accent2: Color(0xFFFBBF24),
    bgGradientsDark: [Color(0xFF2E1B12), Color(0xFF1C1410), Color(0xFF241612)],
    bgGradientsLight: [Color(0xFFFFECE0), Color(0xFFFFF7F1), Color(0xFFFFF3E0)],
    radiusScale: 1.6,
  ),

  // ══════════════════ ۳) LILAC — دخترونه، یاسی/پاستلی ══════════════════
  VzPreset(
    id: 'lilac',
    name: 'Lilac',
    tagline: 'Pastel violet · dreamy',
    style: VzStyle.kawaii,
    bgDark: Color(0xFF16121F),
    bgDeepDark: Color(0xFF0F0C16),
    surfaceDark: Color(0xFF1E1929),
    cardDark: Color(0xFF261F33),
    cardHiDark: Color(0xFF332A44),
    borderDark: Color(0xFF413755),
    borderHiDark: Color(0xFF5B4D78),
    bgLight: Color(0xFFF8F5FF),
    bgDeepLight: Color(0xFFEFE9FF),
    surfaceLight: Color(0xFFFEFCFF),
    cardLight: Color(0xFFFFFFFF),
    cardHiLight: Color(0xFFF1EAFE),
    borderLight: Color(0xFFE0D5F7),
    borderHiLight: Color(0xFFC3B0EC),
    accentDark: Color(0xFFC084FC),
    accentDarkHi: Color(0xFFD8B4FE),
    accentDarkDeep: Color(0xFF7E22CE),
    accentLight: Color(0xFF9333EA),
    accentLightHi: Color(0xFFA855F7),
    accentLightDeep: Color(0xFF6B21A8),
    accent2: Color(0xFFF0ABFC),
    bgGradientsDark: [Color(0xFF221A33), Color(0xFF16121F), Color(0xFF1C1730)],
    bgGradientsLight: [Color(0xFFEFE6FF), Color(0xFFF8F5FF), Color(0xFFFBE9FF)],
    radiusScale: 1.4,
  ),

  // ══════════════════ ۴) MIDNIGHT — پسرونه، نیلی/تیره ══════════════════
  VzPreset(
    id: 'midnight',
    name: 'Midnight',
    tagline: 'Deep blue · sharp · moody',
    style: VzStyle.shonen,
    bgDark: Color(0xFF0A0E17),
    bgDeepDark: Color(0xFF060911),
    surfaceDark: Color(0xFF111725),
    cardDark: Color(0xFF161D2E),
    cardHiDark: Color(0xFF1E2740),
    borderDark: Color(0xFF232E4A),
    borderHiDark: Color(0xFF33436B),
    bgLight: Color(0xFFF1F5FC),
    bgDeepLight: Color(0xFFE4EBF8),
    surfaceLight: Color(0xFFFFFFFF),
    cardLight: Color(0xFFFFFFFF),
    cardHiLight: Color(0xFFE9EFFA),
    borderLight: Color(0xFFD5DEEE),
    borderHiLight: Color(0xFFAFC0DC),
    accentDark: Color(0xFF60A5FA),
    accentDarkHi: Color(0xFF93C5FD),
    accentDarkDeep: Color(0xFF1D4ED8),
    accentLight: Color(0xFF2563EB),
    accentLightHi: Color(0xFF3B82F6),
    accentLightDeep: Color(0xFF1E40AF),
    accent2: Color(0xFF22D3EE),
    bgGradientsDark: [Color(0xFF0F1A33), Color(0xFF0A0E17), Color(0xFF101D38)],
    bgGradientsLight: [Color(0xFFDFE9FB), Color(0xFFF1F5FC), Color(0xFFE7F0FF)],
    radiusScale: 0.8,
  ),

  // ══════════════════ ۵) SHONEN — پسرونه، نارنجی/قرمز انرژی‌دار ══════════════════
  VzPreset(
    id: 'shonen',
    name: 'Shonen',
    tagline: 'Blazing orange · bold · loud',
    style: VzStyle.shonen,
    bgDark: Color(0xFF16100C),
    bgDeepDark: Color(0xFF0E0A07),
    surfaceDark: Color(0xFF1F1611),
    cardDark: Color(0xFF281D16),
    cardHiDark: Color(0xFF35261C),
    borderDark: Color(0xFF43301F),
    borderHiDark: Color(0xFF5F452C),
    bgLight: Color(0xFFFDF6F0),
    bgDeepLight: Color(0xFFF8EAE0),
    surfaceLight: Color(0xFFFFFFFF),
    cardLight: Color(0xFFFFFFFF),
    cardHiLight: Color(0xFFFBEBDF),
    borderLight: Color(0xFFEFD8C6),
    borderHiLight: Color(0xFFDDB598),
    accentDark: Color(0xFFF97316),
    accentDarkHi: Color(0xFFFB923C),
    accentDarkDeep: Color(0xFF9A3412),
    accentLight: Color(0xFFDC2626),
    accentLightHi: Color(0xFFEF4444),
    accentLightDeep: Color(0xFF991B1B),
    accent2: Color(0xFFFACC15),
    bgGradientsDark: [Color(0xFF2A1408), Color(0xFF16100C), Color(0xFF23120A)],
    bgGradientsLight: [Color(0xFFFFE8D6), Color(0xFFFDF6F0), Color(0xFFFFF2DC)],
    radiusScale: 0.7,
  ),

  // ══════════════════ ۶) NEON EDGE — پسرونه، سایبر/سبز ══════════════════
  VzPreset(
    id: 'neon',
    name: 'Neon Edge',
    tagline: 'Cyber lime · glitch · fast',
    style: VzStyle.shonen,
    bgDark: Color(0xFF08100C),
    bgDeepDark: Color(0xFF040906),
    surfaceDark: Color(0xFF0E1913),
    cardDark: Color(0xFF12211A),
    cardHiDark: Color(0xFF182C22),
    borderDark: Color(0xFF1D3628),
    borderHiDark: Color(0xFF2B5140),
    bgLight: Color(0xFFF0FAF4),
    bgDeepLight: Color(0xFFE0F5E8),
    surfaceLight: Color(0xFFFFFFFF),
    cardLight: Color(0xFFFFFFFF),
    cardHiLight: Color(0xFFE6F7ED),
    borderLight: Color(0xFFCFEEDD),
    borderHiLight: Color(0xFFA3DBBE),
    accentDark: Color(0xFF4ADE80),
    accentDarkHi: Color(0xFF86EFAC),
    accentDarkDeep: Color(0xFF15803D),
    accentLight: Color(0xFF059669),
    accentLightHi: Color(0xFF10B981),
    accentLightDeep: Color(0xFF065F46),
    accent2: Color(0xFF22D3EE),
    bgGradientsDark: [Color(0xFF0A2016), Color(0xFF08100C), Color(0xFF0B2418)],
    bgGradientsLight: [Color(0xFFD9F7E6), Color(0xFFF0FAF4), Color(0xFFE2FBF0)],
    radiusScale: 0.75,
  ),
];

VzPreset vPresetById(String? id) =>
    kVzPresets.firstWhere((p) => p.id == id, orElse: () => kVzPresets.first);

// ─────────────────────────────────────────────────────────────────────────────
//  BACKGROUND FLAVOURS — چیدمان گرادیان بک‌گراند
//  همان رنگ‌های پرسِت، ولی با چیدمان/شدت متفاوت. کاربر مستقل از پرسِت
//  می‌تواند این را عوض کند.
// ─────────────────────────────────────────────────────────────────────────────
enum VzBgStyle {
  /// دو گوشه، مورب — پیش‌فرض
  diagonal,
  /// شعاعی از بالا — مثل نور خورشید
  sunrise,
  /// سه‌رنگ افقی — پهن و آرام
  horizon,
  /// تیره در مرکز، رنگ در لبه‌ها — مثل ویگنت رنگی
  vignette,
  /// سه هاله‌ی متقاطع — پرجنب‌وجوش
  mesh,
  /// تخت، تک‌رنگ
  flat,
}

/// چیدمان گرادیان را می‌سازد. [stops] رنگ‌های پرسِت است (۲ یا ۳ رنگ).
LinearGradient vzBgGradient({
  required VzBgStyle style,
  required List<Color> stops,
  required Color fallback,
}) {
  final c = stops.isEmpty ? [fallback, fallback] : stops;
  final a = c[0];
  final b = c.length > 1 ? c[1] : fallback;
  final d = c.length > 2 ? c[2] : b;

  switch (style) {
    case VzBgStyle.diagonal:
      return LinearGradient(
        colors: c, begin: Alignment.topLeft, end: Alignment.bottomRight);
    case VzBgStyle.sunrise:
      return LinearGradient(
        colors: [a, b, d],
        stops: const [0.0, 0.45, 1.0],
        begin: Alignment.topCenter, end: Alignment.bottomCenter);
    case VzBgStyle.horizon:
      return LinearGradient(
        colors: [a, b, d],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.centerLeft, end: Alignment.centerRight);
    case VzBgStyle.vignette:
      return LinearGradient(
        colors: [d, b, d],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft, end: Alignment.bottomRight);
    case VzBgStyle.mesh:
      return LinearGradient(
        colors: [a, d, b, a],
        stops: const [0.0, 0.35, 0.7, 1.0],
        begin: Alignment.topLeft, end: Alignment.bottomRight);
    case VzBgStyle.flat:
      return LinearGradient(
        colors: [fallback, fallback],
        begin: Alignment.topCenter, end: Alignment.bottomCenter);
  }
}
