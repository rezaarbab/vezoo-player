// lib/vz_anime_themes.dart — تم‌های آماده‌ی انیمه
//
// هر تم فقط یک «رنگ دانه» + یک سبک پس‌زمینه + یک سبک گوشه است؛ بقیه‌ی
// پالت خودکار در vz_theme.dart ساخته می‌شود (مثل Namida که از آرت‌ورک
// رنگ می‌گیرد). پس تم‌ها همیشه هارمونیک‌اند.
//
// دسته‌ها:
//   • Sakura  — دخترونه، صورتی/آبی
//   • Neko    — گربه‌ای، کرم/قهوه‌ای
//   • Neon    — پسرونه، سایبر
//   • Shonen  — پسرونه، نارنجی-قرمز انرژی‌دار
//   • Moe     — انیمه‌ی آبی-صورتی (سبک Bilibili)
//   • Ghost   — مونوکروم، تیره و آرام
import 'package:flutter/material.dart';

import 'vz_theme.dart';

/// یک تم آماده.
@immutable
class VzThemeDef {
  final String id;
  final String name;
  final String tagline;
  final Color seed;
  final VzBgStyle bg;
  final double radiusScale;
  final _Vibe vibe;

  const VzThemeDef({
    required this.id,
    required this.name,
    required this.tagline,
    required this.seed,
    required this.bg,
    required this.radiusScale,
    required this.vibe,
  });
}

/// حس کلی تم — برای گروه‌بندی و آیکون نمایشی.
enum _Vibe { girly, boyish, anime, neutral }

/// تم‌های آماده. **اولی پیش‌فرض است.**
const List<VzThemeDef> kVzThemes = [
  // ── انیمه‌ی موئه (پیش‌فرض — آبی/صورتی) ──
  VzThemeDef(
    id: 'moe', name: 'Moe',
    tagline: 'Sky blue · sakura pink',
    seed: Color(0xFF00AEEC),
    bg: VzBgStyle.glow, radiusScale: 1.9,
    vibe: _Vibe.anime,
  ),

  // ── دخترونه: صورتی گل ──
  VzThemeDef(
    id: 'sakura', name: 'Sakura',
    tagline: 'Pink blossom · soft',
    seed: Color(0xFFFB7299),
    bg: VzBgStyle.soft, radiusScale: 2.1,
    vibe: _Vibe.girly,
  ),

  // ── دخترونه: یاس پاستلی ──
  VzThemeDef(
    id: 'lilac', name: 'Lilac',
    tagline: 'Pastel violet · dreamy',
    seed: Color(0xFFC084FC),
    bg: VzBgStyle.glow, radiusScale: 1.8,
    vibe: _Vibe.girly,
  ),

  // ── گربه‌ای: نارنجی/کرم ──
  VzThemeDef(
    id: 'neko', name: 'Neko',
    tagline: 'Warm cream · orange cat',
    seed: Color(0xFFF59E0B),
    bg: VzBgStyle.soft, radiusScale: 2.0,
    vibe: _Vibe.anime,
  ),

  // ── پسرونه: سایبر نئون ──
  VzThemeDef(
    id: 'neon', name: 'Neon',
    tagline: 'Cyber lime · glitch',
    seed: Color(0xFF22C55E),
    bg: VzBgStyle.vivid, radiusScale: 0.85,
    vibe: _Vibe.boyish,
  ),

  // ── پسرونه: انرژی قرمز-نارنجی ──
  VzThemeDef(
    id: 'shonen', name: 'Shonen',
    tagline: 'Blazing orange · bold',
    seed: Color(0xFFF97316),
    bg: VzBgStyle.vivid, radiusScale: 0.9,
    vibe: _Vibe.boyish,
  ),

  // ── پسرونه: نیلی تیره ──
  VzThemeDef(
    id: 'midnight', name: 'Midnight',
    tagline: 'Deep indigo · calm',
    seed: Color(0xFF2563EB),
    bg: VzBgStyle.flat, radiusScale: 1.0,
    vibe: _Vibe.boyish,
  ),

  // ── مونوکروم ──
  VzThemeDef(
    id: 'ghost', name: 'Ghost',
    tagline: 'Monochrome · quiet',
    seed: Color(0xFF64748B),
    bg: VzBgStyle.flat, radiusScale: 1.1,
    vibe: _Vibe.neutral,
  ),
];

/// تم را با شناسه می‌خواند (با fallback به اولی).
VzThemeDef vzThemeById(String? id) =>
    kVzThemes.firstWhere((t) => t.id == id, orElse: () => kVzThemes.first);

/// آیکون نمایشی هر تم (برای گالری).
IconData vzVibeIcon(String id) => switch (vzThemeById(id).vibe) {
      _Vibe.girly  => Icons.favorite_rounded,
      _Vibe.boyish => Icons.bolt_rounded,
      _Vibe.anime  => Icons.auto_awesome_rounded,
      _Vibe.neutral => Icons.circle_outlined,
    };
