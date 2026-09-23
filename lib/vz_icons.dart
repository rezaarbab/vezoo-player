// lib/vz_icons.dart — لایه‌ی آیکون قابل‌تعویض با پک‌های آماده
//
// سه پک داخلی:
//   • [SolarIconPack]  — ۷۰۰۰+ آیکون گرد Solar (پیش‌فرض، سبک و نرم)
//   • [AnimatedIconPack] — آیکون‌های متحرک Lottie برای تعامل‌های حسّی
//   • [MaterialIconPack] — fallback متریال
//
// هر آیکون می‌تواند نسخه‌ی «متحرک» داشته باشد. برای آن، نام را در
// [kVzAnimatedIcons] ثبت کن (کلیدهای نام → دارایی Lottie). اگر نامی نبود،
// نسخه‌ی استاتیک استفاده می‌شود.
//
// ── پک سفارشی (مثلاً انیمه) ────────────────────────────────────────────────
//   class AnimeIconPack extends VzIconPack {
//     const AnimeIconPack();
//     @override
//     Widget? build(String name, {double? size, Color? color}) =>
//       SvgPicture.asset('assets/icons/anime/$name.svg', width: size, height: size,
//         colorFilter: ColorFilter.mode(color ?? const Color(0xFFF5F5F7), BlendMode.srcIn));
//   }
//   VzIcons.pack = const AnimeIconPack();
//
// اگر نامی در پک نبود، [VzIconPack.fallback] به Solar/متریال برمی‌گردد، پس
// هیچ صفحه‌ای خالی نمی‌ماند.
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:solar_icons/solar_icons.dart';

/// قرارداد یک پک آیکون.
abstract class VzIconPack {
  const VzIconPack();

  /// آیکون را می‌سازد. اگر [name] پشتیبانی نشود باید null برگرداند تا
  /// fallback استفاده شود.
  Widget? build(String name, {double? size, Color? color});

  /// IconData جایگزین برای این نام.
  IconData fallback(String name) => kVzIconMap[name] ?? Icons.circle_outlined;
}

/// پک آیکون موئه VanFont — فونت آیکونی که از وب Bilibili استخراج شده.
///
/// این فونت ۶۲ گلیف دارد. ۵ تای آن با اطمینان شناسایی شده‌اند (از فایل‌های
/// SVG اصلی که اسمشان coin/like/share/star/logo بود) و بقیه با نام
/// `van<hex>` در دسترس‌اند تا بتوان بعداً نام‌گذاری کرد.
///
/// چون این فونت فقط چند آیکون دارد، برای نام‌های ناشناخته به [SolarIconPack]
/// برمی‌گردد — یعنی آیکون‌های عملیاتی (پوشه، تنظیمات، …) از Solar می‌آیند و
/// آیکون‌های احساسی (لایک، سکه، اشتراک) موئه می‌شوند.
class BiliIconPack extends VzIconPack {
  const BiliIconPack();

  /// گلیف‌هایی که با اطمینان شناسایی شده‌اند.
  static const Map<String, int> known = {
    'like':     0xE6E0, // قلب/لایک — از pic/like.svg
    'star':     0xE6E1, // ستاره — از pic/star.svg
    'coin':     0xE6E4, // سکه — از pic/coin.svg
    'share':    0xE70F, // اشتراک — از pic/share.svg
    'logo':     0xE725, // لوگو — از pic/logo.svg
  };

  /// همه‌ی ۶۲ کدپوینت فونت.
  static const List<int> allCodePoints = [
    0xE604, 0xE616, 0xE62B, 0xE62F, 0xE634, 0xE635, 0xE638, 0xE639,
    0xE63A, 0xE63C, 0xE63D, 0xE63E, 0xE646, 0xE658, 0xE664, 0xE665,
    0xE666, 0xE670, 0xE672, 0xE673, 0xE67D, 0xE6CB, 0xE6CC, 0xE6CD,
    0xE6CE, 0xE6CF, 0xE6D0, 0xE6D1, 0xE6E0, 0xE6E1, 0xE6E2, 0xE6E3,
    0xE6E4, 0xE6E5, 0xE6E6, 0xE6E7, 0xE6E8, 0xE6E9, 0xE6EA, 0xE6EB,
    0xE6EC, 0xE6ED, 0xE6EE, 0xE6EF, 0xE6F0, 0xE6F1, 0xE6F2, 0xE6F7,
    0xE706, 0xE707, 0xE70F, 0xE71C, 0xE71D, 0xE71E, 0xE71F, 0xE720,
    0xE721, 0xE723, 0xE724, 0xE725, 0xE744, 0xEEE3,
  ];

  /// کدپوینت → IconData به‌صورت **const**.
  ///
  /// مهم: AOT باید بیلد بده بدون `--no-tree-shake-icons`. هر `IconData` که در
  /// زمان اجرا ساخته شود، tree-shaking آیکون‌های فونت را می‌شکند. چون کدپوینت
  /// این فونت ثابت است، همه از پیش به const تبدیل شده‌اند.
  static const Map<int, IconData> _glyphs = {
    0xE604: IconData(0xE604, fontFamily: 'VanFont'),
    0xE616: IconData(0xE616, fontFamily: 'VanFont'),
    0xE62B: IconData(0xE62B, fontFamily: 'VanFont'),
    0xE62F: IconData(0xE62F, fontFamily: 'VanFont'),
    0xE634: IconData(0xE634, fontFamily: 'VanFont'),
    0xE635: IconData(0xE635, fontFamily: 'VanFont'),
    0xE638: IconData(0xE638, fontFamily: 'VanFont'),
    0xE639: IconData(0xE639, fontFamily: 'VanFont'),
    0xE63A: IconData(0xE63A, fontFamily: 'VanFont'),
    0xE63C: IconData(0xE63C, fontFamily: 'VanFont'),
    0xE63D: IconData(0xE63D, fontFamily: 'VanFont'),
    0xE63E: IconData(0xE63E, fontFamily: 'VanFont'),
    0xE646: IconData(0xE646, fontFamily: 'VanFont'),
    0xE658: IconData(0xE658, fontFamily: 'VanFont'),
    0xE664: IconData(0xE664, fontFamily: 'VanFont'),
    0xE665: IconData(0xE665, fontFamily: 'VanFont'),
    0xE666: IconData(0xE666, fontFamily: 'VanFont'),
    0xE670: IconData(0xE670, fontFamily: 'VanFont'),
    0xE672: IconData(0xE672, fontFamily: 'VanFont'),
    0xE673: IconData(0xE673, fontFamily: 'VanFont'),
    0xE67D: IconData(0xE67D, fontFamily: 'VanFont'),
    0xE6CB: IconData(0xE6CB, fontFamily: 'VanFont'),
    0xE6CC: IconData(0xE6CC, fontFamily: 'VanFont'),
    0xE6CD: IconData(0xE6CD, fontFamily: 'VanFont'),
    0xE6CE: IconData(0xE6CE, fontFamily: 'VanFont'),
    0xE6CF: IconData(0xE6CF, fontFamily: 'VanFont'),
    0xE6D0: IconData(0xE6D0, fontFamily: 'VanFont'),
    0xE6D1: IconData(0xE6D1, fontFamily: 'VanFont'),
    0xE6E0: IconData(0xE6E0, fontFamily: 'VanFont'),
    0xE6E1: IconData(0xE6E1, fontFamily: 'VanFont'),
    0xE6E2: IconData(0xE6E2, fontFamily: 'VanFont'),
    0xE6E3: IconData(0xE6E3, fontFamily: 'VanFont'),
    0xE6E4: IconData(0xE6E4, fontFamily: 'VanFont'),
    0xE6E5: IconData(0xE6E5, fontFamily: 'VanFont'),
    0xE6E6: IconData(0xE6E6, fontFamily: 'VanFont'),
    0xE6E7: IconData(0xE6E7, fontFamily: 'VanFont'),
    0xE6E8: IconData(0xE6E8, fontFamily: 'VanFont'),
    0xE6E9: IconData(0xE6E9, fontFamily: 'VanFont'),
    0xE6EA: IconData(0xE6EA, fontFamily: 'VanFont'),
    0xE6EB: IconData(0xE6EB, fontFamily: 'VanFont'),
    0xE6EC: IconData(0xE6EC, fontFamily: 'VanFont'),
    0xE6ED: IconData(0xE6ED, fontFamily: 'VanFont'),
    0xE6EE: IconData(0xE6EE, fontFamily: 'VanFont'),
    0xE6EF: IconData(0xE6EF, fontFamily: 'VanFont'),
    0xE6F0: IconData(0xE6F0, fontFamily: 'VanFont'),
    0xE6F1: IconData(0xE6F1, fontFamily: 'VanFont'),
    0xE6F2: IconData(0xE6F2, fontFamily: 'VanFont'),
    0xE6F7: IconData(0xE6F7, fontFamily: 'VanFont'),
    0xE706: IconData(0xE706, fontFamily: 'VanFont'),
    0xE707: IconData(0xE707, fontFamily: 'VanFont'),
    0xE70F: IconData(0xE70F, fontFamily: 'VanFont'),
    0xE71C: IconData(0xE71C, fontFamily: 'VanFont'),
    0xE71D: IconData(0xE71D, fontFamily: 'VanFont'),
    0xE71E: IconData(0xE71E, fontFamily: 'VanFont'),
    0xE71F: IconData(0xE71F, fontFamily: 'VanFont'),
    0xE720: IconData(0xE720, fontFamily: 'VanFont'),
    0xE721: IconData(0xE721, fontFamily: 'VanFont'),
    0xE723: IconData(0xE723, fontFamily: 'VanFont'),
    0xE724: IconData(0xE724, fontFamily: 'VanFont'),
    0xE725: IconData(0xE725, fontFamily: 'VanFont'),
    0xE744: IconData(0xE744, fontFamily: 'VanFont'),
    0xEEE3: IconData(0xEEE3, fontFamily: 'VanFont'),
  };

  /// آیکون ثابت برای یک کدپوینت (بدون ساخت runtime).
  static IconData glyph(int codePoint) =>
      _glyphs[codePoint] ?? Icons.help_outline;

  /// نام‌هایی که این پک پشتیبانی می‌کند.
  static bool has(String name) =>
      known.containsKey(name) || name.startsWith('van');

  /// ساخت IconData از یک کدپوینت فونت — همیشه از map ثابت، پس AOT-safe.
  static IconData _icon(String name) {
    final cp = known[name] ?? _parseHex(name);
    return glyph(cp);
  }

  static int _parseHex(String name) {
    if (name.startsWith('van')) {
      final hex = name.substring(3);
      final v = int.tryParse(hex, radix: 16);
      if (v != null && allCodePoints.contains(v)) return v;
    }
    return 0xE725; // لوگو به‌عنوان fallback امن
  }

  @override
  IconData fallback(String name) {
    if (has(name)) return _icon(name);
    // آیکون‌های عملیاتی از پک پیش‌فرض (Solar) می‌آیند
    return const SolarIconPack().fallback(name);
  }

  @override
  Widget? build(String name, {double? size, Color? color}) {
    if (!has(name)) return null; // به Solar برمی‌گردد
    return Icon(_icon(name), size: size, color: color);
  }
}

/// پک پیش‌فرض — آیکون‌های گرد Solar (نرم‌تر از متریال، بدون گرافیک اضافه).
class SolarIconPack extends VzIconPack {
  const SolarIconPack();

  /// Solar نسخه‌ی «خطی» و «پر» دارد؛ اینجا از نسخه‌ی Linear استفاده می‌کنیم
  /// چون با ظاهر تخت VOID هم‌خوان است.
  static const _map = <String, IconData>{
    // ── ناوبری ──
    'home': SolarIconsOutline.widget,
    'live': SolarIconsOutline.tv,
    'discover': SolarIconsOutline.compass,
    'library': SolarIconsOutline.videoLibrary,
    'settings': SolarIconsOutline.settings,
    'search': SolarIconsOutline.minimalisticMagnifier,
    'close': SolarIconsOutline.closeCircle,
    'back': SolarIconsOutline.arrowLeft,
    'forward': SolarIconsOutline.arrowRight,
    'up': SolarIconsOutline.arrowUp,
    'chevron-right': SolarIconsOutline.altArrowRight,
    'chevron-left': SolarIconsOutline.altArrowLeft,

    // ── پخش ──
    'play': SolarIconsOutline.play,
    'pause': SolarIconsOutline.pause,
    'stop': SolarIconsOutline.stop,
    'next': SolarIconsOutline.skipNext,
    'prev': SolarIconsOutline.skipPrevious,
    'replay': SolarIconsOutline.refresh,
    'fast-forward': SolarIconsOutline.rewindForward,
    'rewind': SolarIconsOutline.rewindBack,
    'pip': SolarIconsOutline.pip,
    'fullscreen': SolarIconsOutline.maximize,
    'rotate': SolarIconsOutline.refresh,
    'volume': SolarIconsOutline.volumeLoud,
    'mute': SolarIconsOutline.volumeCross,
    'brightness': SolarIconsOutline.sun,
    'speed': SolarIconsOutline.speedometerMiddle,
    'lock': SolarIconsOutline.lock,
    'unlock': SolarIconsOutline.lockUnlocked,
    'sleep': SolarIconsOutline.moon,

    // ── محتوا ──
    'folder': SolarIconsOutline.folder,
    'folder-open': SolarIconsOutline.folderOpen,
    'folder-empty': SolarIconsOutline.folderError,
    'video': SolarIconsOutline.videoFrame,
    'movie': SolarIconsOutline.clapperboard,
    'music': SolarIconsOutline.musicNote,
    'subtitle': SolarIconsOutline.subtitles,
    'audio': SolarIconsOutline.headphonesRound,
    'grid': SolarIconsOutline.widget,
    'list': SolarIconsOutline.listCheck,
    'compact': SolarIconsOutline.hamburgerMenu,
    'layout': SolarIconsOutline.widget,
    'sort': SolarIconsOutline.sortFromTopToBottom,
    'storage': SolarIconsOutline.server,
    'sd': SolarIconsOutline.sdCard,
    'download': SolarIconsOutline.download,
    'upload': SolarIconsOutline.upload,
    'link': SolarIconsOutline.link,
    'clock': SolarIconsOutline.clockCircle,
    'size': SolarIconsOutline.ruler,

    // ── وضعیت ──
    'bookmark': SolarIconsOutline.bookmark,
    'bookmark-off': SolarIconsOutline.bookmark,
    'favorite': SolarIconsOutline.heart,
    'favorite-off': SolarIconsOutline.heart,
    'star': SolarIconsOutline.star,
    'star-off': SolarIconsOutline.star,
    'check': SolarIconsOutline.checkCircle,
    'check-circle': SolarIconsOutline.checkCircle,
    'circle': SolarIconsOutline.recordMinimalistic,
    'history': SolarIconsOutline.clockCircle,
    'queue': SolarIconsOutline.playlist,
    'pin': SolarIconsOutline.pin,
    'pin-off': SolarIconsOutline.pin,
    'trash': SolarIconsOutline.trashBinMinimalistic,
    'edit': SolarIconsOutline.pen,
    'rename': SolarIconsOutline.pen,
    'copy': SolarIconsOutline.copy,
    'move': SolarIconsOutline.moveToFolder,
    'share': SolarIconsOutline.share,
    'more': SolarIconsOutline.menuDots,
    'info': SolarIconsOutline.infoCircle,
    'refresh': SolarIconsOutline.refresh,
    'add': SolarIconsOutline.addCircle,
    'cancel': SolarIconsOutline.closeCircle,

    // ── تم و ظاهر ──
    'palette': SolarIconsOutline.palette,
    'theme': SolarIconsOutline.paintRoller,
    'background': SolarIconsOutline.gallery,
    'dark': SolarIconsOutline.moon,
    'light': SolarIconsOutline.sun,
    'auto': SolarIconsOutline.sun2,
    'animation': SolarIconsOutline.playCircle,
    'sparkle': SolarIconsOutline.stars,

    // ── AI و زیرنویس ──
    'ai': SolarIconsOutline.stars,
    'voice': SolarIconsOutline.microphone2,
    'translate': SolarIconsOutline.translation,
    'mic': SolarIconsOutline.microphone,
    'wave': SolarIconsOutline.soundwave,
    'record': SolarIconsOutline.recordCircle,
    'cloud': SolarIconsOutline.cloudDownload,
    'terminal': SolarIconsOutline.code,
    'tune': SolarIconsOutline.tuning,

    // ── عمومی ──
    'user': SolarIconsOutline.userCircle,
    'bug': SolarIconsOutline.bug,
    'telegram': SolarIconsOutline.plain,
    'update': SolarIconsOutline.refreshCircle,
    'warning': SolarIconsOutline.dangerTriangle,
    'error': SolarIconsOutline.dangerCircle,
    'wifi-off': SolarIconsOutline.wifiRouter,
    'visibility': SolarIconsOutline.eye,
    'eye-off': SolarIconsOutline.eyeClosed,
    'logout': SolarIconsOutline.logout,
    'backup': SolarIconsOutline.database,
    'restore': SolarIconsOutline.restart,
    'shield': SolarIconsOutline.shieldCheck,
    'flash': SolarIconsOutline.bolt,
    'chat': SolarIconsOutline.chatRound,
    'tv': SolarIconsOutline.tv,
    'phone': SolarIconsOutline.smartphone,
    'battery': SolarIconsOutline.batteryCharge,
    'screen': SolarIconsOutline.monitor,
    'language': SolarIconsOutline.global,
  };

  @override
  IconData fallback(String name) =>
      _map[name] ?? kVzIconMap[name] ?? Icons.circle_outlined;

  @override
  Widget? build(String name, {double? size, Color? color}) => null;
}


/// ویجت آیکون اپ. همه‌جا از این استفاده کن، نه Icon مستقیم.
///
/// [animated] = true → اگر نسخه‌ی Lottie برای این نام ثبت شده باشد، آن را
/// پخش می‌کند؛ وگرنه استاتیک.
class VzIcon extends StatelessWidget {
  final String name;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  /// استفاده از نسخه‌ی متحرک (اگر موجود باشد).
  final bool animated;

  /// پخش حلقه‌ای انیمیشن — برای حالت‌های پایدار مثل «در حال ضبط».
  final bool loop;

  const VzIcon(
    this.name, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.animated = false,
    this.loop = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color;
    final s = size ?? IconTheme.of(context).size ?? 24;

    // ۱) پک فعال کاربر (مثلاً انیمه)
    final custom = VzIcons.pack.build(name, size: s, color: c);
    if (custom != null) {
      return SizedBox(width: s, height: s, child: custom);
    }

    // ۲) نسخه‌ی متحرک، اگر خواسته شده و موجود باشد
    if (animated && VzIcons.animationsEnabled()) {
      final asset = kVzAnimatedIcons[name];
      if (asset != null) {
        return VzAnimatedIcon(asset: asset, size: s, loop: loop);
      }
    }

    // ۳) استاتیک
    return Icon(
      VzIcons.pack.fallback(name),
      size: s,
      color: c,
      semanticLabel: semanticLabel,
    );
  }
}

/// آیکون متحرک Lottie — یک‌بار پخش می‌شود، یا حلقه‌ای.
/// با کلید انیمیشن کاربر خاموش می‌شود و به یک آیکون ساده برمی‌گردد.
class VzAnimatedIcon extends StatefulWidget {
  final String asset;
  final double size;
  final bool loop;
  final Color? color;
  const VzAnimatedIcon({
    super.key, required this.asset, this.size = 24,
    this.loop = false, this.color,
  });

  @override State<VzAnimatedIcon> createState() => _VzAnimatedIconState();
}

class _VzAnimatedIconState extends State<VzAnimatedIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    if (VzIcons.animationsEnabled()) {
      _c = AnimationController(vsync: this);
    }
  }

  @override
  void dispose() { _c?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.asset(
        widget.asset,
        controller: c,
        fit: BoxFit.contain,
        onLoaded: (comp) {
          c.duration = comp.duration;
          if (widget.loop) {
            c.repeat();
          } else {
            c.forward();
          }
        },
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

/// رجیستری آیکون‌ها.
class VzIcons {
  VzIcons._();

  /// پک پیش‌فرض: BiliIconPack آیکون‌های موئه‌ی شناسایی‌شده را می‌دهد و بقیه
  /// را از Solar می‌گیرد — پس هیچ صفحه‌ای بی‌آیکون نمی‌ماند.
  static VzIconPack _pack = const SolarIconPack();

  /// پک فعال. با ست کردن این، کل اپ آیکون‌های جدید را می‌گیرد.
  static VzIconPack get pack => _pack;
  static set pack(VzIconPack p) => _pack = p;

  /// وضعیت کلید انیمیشن — در main.dart وصل می‌شود.
  /// این callback به‌جای import مستقیم theme.dart است تا چرخه‌ی import
    static bool Function() animationsEnabled = () => true;

  /// خواندن یک آیکون به‌صورت IconData.
  static IconData data(String name) => _pack.fallback(name);

  /// سازنده‌ی سریع ویجت.
  static Widget widget(String name, {double? size, Color? color, bool animated = false}) =>
      VzIcon(name, size: size, color: color, animated: animated);
}

// ─────────────────────────────────────────────────────────────────────────────
//  نقشه‌ی نام → آیکون متریال (fallback نهایی)
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, IconData> kVzIconMap = {
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
  'bookmark': Icons.bookmark_rounded,
  'bookmark-off': Icons.bookmark_border_rounded,
  'favorite': Icons.favorite_rounded,
  'favorite-off': Icons.favorite_border_rounded,
  'star': Icons.star_rounded,
  'fav': Icons.favorite_rounded,
  'ai': Icons.auto_awesome_rounded,
  'voice': Icons.record_voice_over_rounded,
  'update': Icons.system_update_rounded,
  'telegram': Icons.send_rounded,
  'bug': Icons.bug_report_rounded,

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
  'palette': Icons.palette_rounded,
  'theme': Icons.brush_rounded,
  'background': Icons.gradient_rounded,
  'dark': Icons.dark_mode_rounded,
  'light': Icons.light_mode_rounded,
  'auto': Icons.brightness_auto_rounded,
  'animation': Icons.animation_rounded,
  'gesture': Icons.touch_app_rounded,
  'sparkle': Icons.auto_awesome_rounded,
  'mascot': Icons.pets_rounded,
  'ai': Icons.auto_awesome_rounded,
  'voice': Icons.record_voice_over_rounded,
  'translate': Icons.translate_rounded,
  'mic': Icons.mic_rounded,
  'wave': Icons.graphic_eq_rounded,
  'record': Icons.fiber_smart_record_rounded,
  'cloud': Icons.cloud_download_rounded,
  'terminal': Icons.terminal_rounded,
  'tune': Icons.tune_rounded,
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

/// نام‌هایی که نسخه‌ی متحرک Lottie دارند.
///
/// ── چطور اضافه کنم؟ ──
///  ۱) فایل `.json` را از lottiefiles.com در `assets/lottie/` بگذار.
///  ۲) در pubspec ثبت کن:
///       flutter:
///         assets:
///           - assets/lottie/
///  ۳) اینجا نگاشت کن:  'play': 'assets/lottie/play.json',
///
/// تا وقتی این نقشه خالی است، همه‌چیز استاتیک (و سریع) می‌ماند.
const Map<String, String> kVzAnimatedIcons = {
  // 'play':        'assets/lottie/play.json',
  // 'pause':       'assets/lottie/pause.json',
  // 'favorite':    'assets/lottie/heart.json',
  // 'bookmark':    'assets/lottie/bookmark.json',
  // 'star':        'assets/lottie/star.json',
  // 'check':       'assets/lottie/check.json',
  // 'download':    'assets/lottie/download.json',
  // 'record':      'assets/lottie/recording.json',
};
