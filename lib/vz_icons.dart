// lib/vz_icons.dart — لایه‌ی آیکون قابل‌تعویض
//
// همه‌ی آیکون‌های اپ از اینجا رد می‌شوند، نه مستقیم از Icons.
// با این کار می‌توان کل ست آیکون را عوض کرد (مثلاً پک انیمه/چیبی) بدون
// دست زدن به هیچ ویجتی.
//
// ── چطور یک پک انیمه وصل کنم؟ ─────────────────────────────────────────────
//
//  ۱) فایل‌های SVG/PNG پک را در assets/icons/<pack>/ بریز و در pubspec
//     ثبت کن:
//       flutter:
//         assets:
//           - assets/icons/anime/
//
//  ۲) یک زیرکلاس از [VzIconPack] بساز و هر نام را به دارایی‌اش map کن:
//
//       class AnimeIconPack extends VzIconPack {
//         const AnimeIconPack();
//         @override
//         Widget build(String name, {double? size, Color? color}) =>
//           SvgPicture.asset('assets/icons/anime/$name.svg',
//             width: size, height: size,
//             colorFilter: ColorFilter.mode(
//               color ?? Vz.text, BlendMode.srcIn));
//         // یا برای PNG: Image.asset('assets/icons/anime/$name.png', ...)
//       }
//
//  ۳) هنگام بوت اپ پک را فعال کن:
//       VzIcons.pack = const AnimeIconPack();
//
// نکته: اگر نامی در پک نبود، [VzIconPack.fallback] به آیکون متریال برمی‌گردد،
// پس هیچ صفحه‌ای خالی نمی‌ماند.
import 'package:flutter/material.dart';

/// قرارداد یک پک آیکون.
abstract class VzIconPack {
  const VzIconPack();

  /// آیکون را می‌سازد. اگر [name] پشتیبانی نشود باید null برگرداند تا
  /// fallback متریال استفاده شود.
  Widget? build(String name, {double? size, Color? color});

  /// آیکون پیش‌فرضِ متریال برای هر نام — پایه‌ی رندر پیش‌فرض.
  IconData fallback(String name) =>
      kVzIconMap[name] ?? Icons.circle_outlined;

  /// آیا پک این نام را دارد؟
  bool supports(String name) => true;
}

/// پک پیش‌فرض — آیکون‌های متریال (rounded برای حس نرم‌تر).
class MaterialIconPack extends VzIconPack {
  const MaterialIconPack();
  @override
  Widget? build(String name, {double? size, Color? color}) => null; // fallback
}

/// ویجت آیکون اپ. همه‌جا از این استفاده کن، نه Icon مستقیم.
class VzIcon extends StatelessWidget {
  final String name;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const VzIcon(
    this.name, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color;
    final s = size ?? IconTheme.of(context).size ?? 24;

    final custom = VzIcons.pack.build(name, size: s, color: c);
    if (custom != null) {
      return custom;
    }
    return Icon(
      VzIcons.pack.fallback(name),
      size: s,
      color: c,
      semanticLabel: semanticLabel,
    );
  }
}

/// رجیستری آیکون‌ها.
class VzIcons {
  VzIcons._();

  static VzIconPack _pack = const MaterialIconPack();

  /// پک فعال. با ست کردن این، کل اپ آیکون‌های جدید را می‌گیرد.
  static VzIconPack get pack => _pack;
  static set pack(VzIconPack p) => _pack = p;

  /// خواندن یک آیکون به‌صورت IconData (برای جاهایی که IconData لازم است،
  /// مثل TabBar یا مدل‌های داده).
  static IconData data(String name) => _pack.fallback(name);

  /// سازنده‌ی سریع ویجت.
  static Widget widget(String name, {double? size, Color? color}) =>
      VzIcon(name, size: size, color: color);
}

// ─────────────────────────────────────────────────────────────────────────────
//  نقشه‌ی نام → آیکون متریال
//  نام‌ها تصویری‌اند تا پک انیمه بتواند با همین کلیدها فایل بدهد
//  (مثلاً "folder-cute.svg", "play-cute.svg" …)
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, IconData> kVzIconMap = {
  // ── ناوبری ──
  'home': Icons.movie_filter_rounded,
  'live': Icons.live_tv_rounded,
  'discover': Icons.explore_rounded,
  'library': Icons.video_library_rounded,
  'settings': Icons.settings_rounded,
  'search': Icons.search_rounded,
  'close': Icons.close_rounded,
  'back': Icons.arrow_back_rounded,
  'forward': Icons.arrow_forward_rounded,
  'up': Icons.arrow_upward_rounded,
  'chevron-right': Icons.chevron_right_rounded,
  'chevron-left': Icons.chevron_left_rounded,

  // ── پخش ──
  'play': Icons.play_arrow_rounded,
  'pause': Icons.pause_rounded,
  'stop': Icons.stop_rounded,
  'next': Icons.skip_next_rounded,
  'prev': Icons.skip_previous_rounded,
  'replay': Icons.replay_rounded,
  'fast-forward': Icons.fast_forward_rounded,
  'rewind': Icons.fast_rewind_rounded,
  'pip': Icons.picture_in_picture_rounded,
  'fullscreen': Icons.fullscreen_rounded,
  'rotate': Icons.screen_rotation_rounded,
  'volume': Icons.volume_up_rounded,
  'mute': Icons.volume_off_rounded,
  'brightness': Icons.brightness_6_rounded,
  'speed': Icons.speed_rounded,
  'lock': Icons.lock_rounded,
  'unlock': Icons.lock_open_rounded,
  'sleep': Icons.bedtime_rounded,

  // ── محتوا ──
  'folder': Icons.folder_rounded,
  'folder-open': Icons.folder_open_rounded,
  'folder-empty': Icons.folder_off_rounded,
  'video': Icons.video_file_rounded,
  'movie': Icons.movie_rounded,
  'music': Icons.music_note_rounded,
  'subtitle': Icons.subtitles_rounded,
  'audio': Icons.audiotrack_rounded,
  'hdr': Icons.hdr_on_rounded,
  'quality': Icons.high_quality_rounded,
  'grid': Icons.grid_view_rounded,
  'list': Icons.view_agenda_rounded,
  'compact': Icons.view_headline_rounded,
  'layout': Icons.dashboard_customize_rounded,
  'sort': Icons.sort_rounded,
  'storage': Icons.storage_rounded,
  'sd': Icons.sd_card_rounded,
  'download': Icons.download_rounded,
  'upload': Icons.upload_rounded,
  'link': Icons.link_rounded,
  'clock': Icons.access_time_rounded,
  'size': Icons.data_usage_rounded,

  // ── وضعیت ──
  'bookmark': Icons.bookmark_rounded,
  'bookmark-off': Icons.bookmark_border_rounded,
  'favorite': Icons.favorite_rounded,
  'favorite-off': Icons.favorite_border_rounded,
  'star': Icons.star_rounded,
  'star-off': Icons.star_outline_rounded,
  'check': Icons.check_rounded,
  'check-circle': Icons.check_circle_rounded,
  'circle': Icons.circle_outlined,
  'history': Icons.history_rounded,
  'queue': Icons.queue_music_rounded,
  'pin': Icons.push_pin_rounded,
  'pin-off': Icons.push_pin_outlined,
  'trash': Icons.delete_outline_rounded,
  'edit': Icons.edit_rounded,
  'rename': Icons.drive_file_rename_outline_rounded,
  'copy': Icons.copy_rounded,
  'move': Icons.drive_file_move_rounded,
  'share': Icons.share_rounded,
  'more': Icons.more_vert_rounded,
  'info': Icons.info_outline_rounded,
  'refresh': Icons.refresh_rounded,
  'add': Icons.add_rounded,
  'cancel': Icons.cancel_rounded,

  // ── تم و ظاهر ──
  'palette': Icons.palette_rounded,
  'theme': Icons.brush_rounded,
  'background': Icons.gradient_rounded,
  'dark': Icons.dark_mode_rounded,
  'light': Icons.light_mode_rounded,
  'auto': Icons.brightness_auto_rounded,
  'animation': Icons.animation_rounded,
  'sparkle': Icons.auto_awesome_rounded,

  // ── AI و زیرنویس ──
  'ai': Icons.auto_awesome_rounded,
  'voice': Icons.record_voice_over_rounded,
  'translate': Icons.translate_rounded,
  'mic': Icons.mic_rounded,
  'wave': Icons.graphic_eq_rounded,
  'record': Icons.fiber_smart_record_rounded,
  'cloud': Icons.cloud_download_rounded,
  'terminal': Icons.terminal_rounded,
  'tune': Icons.tune_rounded,

  // ── عمومی ──
  'user': Icons.person_rounded,
  'bug': Icons.bug_report_rounded,
  'telegram': Icons.telegram,
  'update': Icons.system_update_rounded,
  'warning': Icons.warning_amber_rounded,
  'error': Icons.error_outline_rounded,
  'wifi-off': Icons.wifi_off_rounded,
  'visibility': Icons.visibility_rounded,
  'eye-off': Icons.visibility_off_rounded,
  'logout': Icons.logout_rounded,
  'backup': Icons.backup_rounded,
  'restore': Icons.restore_rounded,
  'shield': Icons.shield_rounded,
  'flash': Icons.flash_on_rounded,
  'chat': Icons.chat_bubble_outline_rounded,
  'tv': Icons.tv_rounded,
  'phone': Icons.phone_android_rounded,
  'battery': Icons.battery_full_rounded,
  'screen': Icons.screenshot_monitor_rounded,
  'language': Icons.language_rounded,
};
