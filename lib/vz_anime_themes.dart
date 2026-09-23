// lib/vz_anime_themes.dart — دو تم پایه (سبک Namida)
//
// Namida فقط دو تم دارد و رنگ‌ها را از **آرت‌ورک آلبوم/پوستر** می‌گیرد.
// همین مدل را داریم:
//
//   • Shade — تیره (پیش‌فرض). مشکی خنثی، اکسنت از رنگ دانه.
//   • Day   — روشن. سطح سفید گرم، اکسنت از رنگ دانه.
//
// هویت هر «تم» در واقع فقط **رنگ دانه** است؛ بقیه توسط
// [vzBuildPalette] در vz_theme.dart ساخته می‌شود. پس تعداد تم‌ها کم اما
// تنوع رنگ‌ها بی‌نهایت است (کاربر هر رنگی بدهد).
import 'package:flutter/material.dart';

import 'vz_theme.dart';

/// یک تم پایه.
@immutable
class VzThemeDef {
  final String id;
  final String name;
  final String tagline;

  /// رنگ دانه‌ی پیش‌فرض این تم.
  final Color seed;

  /// سبک پس‌زمینه‌ی پیش‌فرض.
  final VzBgStyle bg;

  /// مقیاس گردی گوشه.
  final double radiusScale;

  /// رنگ پایه‌ی پس‌زمینه — اگر خالی نباشد، به‌جای رنگ مشتق از seed
  /// استفاده می‌شود. برای تم‌هایی که پس‌زمینه‌ی رنگی خاص دارند (سرمه‌ای/خونی).
  final Color? bgTint;

  /// اگر خالی نباشد، اکسنت **دقیقاً** همین رنگ می‌شود (بدون مشتق‌گیری).
  /// برای تم‌هایی که رنگ دقیق برند مهم است (سبز Tako، قرمز MHT).
  final Color? accentLock;

  /// حالت پیش‌فرض این تم. تم‌های روشن (مثل Day) این را false می‌گذارند تا
  /// با انتخاب آن‌ها، حالت سیستم به‌طور خودکار روشن شود.
  final bool dark;

  /// حروف لوگوی اسپلش (پیش‌فرض VEZOO) — هر تم می‌تواند برند خودش را داشته باشد.
  final String splashLetters;

  /// حرف‌های الل کوتاه — گوشه‌ی شیت‌ها/هدرها؛ خالی = از [splashLetters].
  final String monogram;

  /// آیکون‌شناسهی برند اپ برای این تم (نام VzIcons) — وقتی خالی باشد پیش‌فرض.
  final String logoGlyph;

  const VzThemeDef({
    required this.id,
    required this.name,
    required this.tagline,
    required this.seed,
    required this.bg,
    required this.radiusScale,
    this.bgTint,
    this.accentLock,
    this.dark = true,
    this.splashLetters = 'VEZOO',
    this.monogram = '',
    this.logoGlyph = 'play',
  });

  /// رنگ دانه‌ی مؤثر برای ساخت پالت.
  Color get effectiveSeed => accentLock ?? seed;
}

/// تم‌های آماده. **اولی پیش‌فرض است.**
///
/// هر تم فقط یک رنگ دانه + سبک پس‌زمینه + مقیاس گردی است؛ بقیه‌ی پالت
/// خودکار ساخته می‌شود. تم‌های `tako` و `mht` از روی طرح‌های واقعی
/// (Tako Play و MHT Anime Streaming) گرفته شده‌اند.
const List<VzThemeDef> kVzThemes = [
  // ── Tako — سبز نئونی روی مشکی سرمه‌ای (از اپ Tako Play) ──
  VzThemeDef(
    id: 'tako', name: 'Tako',
    tagline: 'Neon green · dark navy',
    seed: Color(0xFF2FD97A),
    bg: VzBgStyle.soft, radiusScale: 1.15,
    splashLetters: 'TAKO', monogram: 'T', logoGlyph: 'play',
    // پس‌زمینه‌ی سرد سرمه‌ای، نه خنثی
    bgTint: Color(0xFF0B0F14),
    // اکسنت دقیقاً سبز نئونی، نه مشتق از seed
    accentLock: Color(0xFF2FD97A),
  ),

  // ── MHT Anime — قرمز خون روی مشکی (از Figma MHT) ──
  VzThemeDef(
    id: 'mht', name: 'MHT Anime',
    tagline: 'Crimson · blood · cinematic',
    seed: Color(0xFFE11D2E),
    bg: VzBgStyle.vivid, radiusScale: 1.25,
    bgTint: Color(0xFF0A0507),
    accentLock: Color(0xFFE11D2E),
    splashLetters: 'MHT', monogram: 'M', logoGlyph: 'fav',
  ),

  // ── Shade — تیره‌ی Namida ──
  VzThemeDef(
    id: 'shade', name: 'Shade',
    tagline: 'Dark · neutral · dynamic',
    seed: Color(0xFF00AEEC),
    bg: VzBgStyle.soft, radiusScale: 1.4,
    splashLetters: 'VEZOO', monogram: 'V', logoGlyph: 'movie',
  ),

  // ── Day — روشنِ Namida ──
  VzThemeDef(
    id: 'day', name: 'Day',
    tagline: 'Light · warm · clean',
    seed: Color(0xFF2563EB),
    bg: VzBgStyle.flat, radiusScale: 1.4,
    dark: false,
    splashLetters: 'VEZOO', monogram: 'V', logoGlyph: 'light',
  ),

  // ── Anime — صورتی موئه، گردترین ──
  VzThemeDef(
    id: 'anime', name: 'Anime',
    tagline: 'Moe · sakura · max round',
    seed: Color(0xFFFB7299),
    bg: VzBgStyle.vivid, radiusScale: 2.0,
    splashLetters: 'SAKURA', monogram: 'S', logoGlyph: 'sparkle',
  ),
];

/// تم را با شناسه می‌خواند (با fallback به اولی).
VzThemeDef vzThemeById(String? id) =>
    kVzThemes.firstWhere((t) => t.id == id, orElse: () => kVzThemes.first);
