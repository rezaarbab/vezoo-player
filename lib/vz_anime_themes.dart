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

  const VzThemeDef({
    required this.id,
    required this.name,
    required this.tagline,
    required this.seed,
    required this.bg,
    required this.radiusScale,
  });
}

/// سه تم — دو تای Namida به‌علاوه‌ی یک تم اختصاصی انیمه.
const List<VzThemeDef> kVzThemes = [
  VzThemeDef(
    id: 'shade', name: 'Shade',
    tagline: 'Dark · neutral · dynamic',
    seed: Color(0xFF00AEEC),
    bg: VzBgStyle.soft, radiusScale: 1.4,
  ),
  VzThemeDef(
    id: 'day', name: 'Day',
    tagline: 'Light · warm · clean',
    seed: Color(0xFF2563EB),
    bg: VzBgStyle.flat, radiusScale: 1.4,
  ),
  VzThemeDef(
    id: 'anime', name: 'Anime',
    tagline: 'Moe · sakura · neon · max round',
    seed: Color(0xFFFB7299),
    bg: VzBgStyle.vivid, radiusScale: 2.0,
  ),
];

/// تم را با شناسه می‌خواند (با fallback به اولی).
VzThemeDef vzThemeById(String? id) =>
    kVzThemes.firstWhere((t) => t.id == id, orElse: () => kVzThemes.first);
