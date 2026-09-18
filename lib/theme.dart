// lib/theme.dart — Vezoo Design System v7 "Namida-like"
//
// یک موتور تم مبتنی بر **رنگ دانه** (seed color) به سبک Namida:
//   • کل پالت (سطح‌ها، متن، اکسنت، semantic) از یک seed ساخته می‌شود
//   • seed می‌تواند از پوستر ویدیو استخراج شود (رنگ داینامیک)
//   • تم‌های آماده فقط چند seed از پیش تعریف‌شده‌اند
//   • دو حالت تیره/روشن، هر دو از همان seed
//
// API عمومی (Vz, Sp, Rad, Ty, Mo, VzTheme…) حفظ شده است تا بقیه‌ی فایل‌ها
// بدون تغییر کامپایل شوند.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'vz_theme.dart';
import 'vz_anime_themes.dart';

export 'vz_theme.dart'
    show VzPalette, VzBgStyle, vzBuildPalette, vzBackground, vzOnColor,
         vzContrast, kVzSeeds;
export 'vz_anime_themes.dart' show VzThemeDef, kVzThemes, vzThemeById;

// ─────────────────────────────────────────────────────────────────────────────
//  THEME MODE
// ─────────────────────────────────────────────────────────────────────────────
enum VzThemeMode { system, dark, light }

// ─────────────────────────────────────────────────────────────────────────────
//  Vz — runtime palette source
// ─────────────────────────────────────────────────────────────────────────────
class Vz {
  Vz._();

  static bool _dark = true;
  static bool _anim = true;

  /// تم انتخاب‌شده.
  static VzThemeDef _theme = kVzThemes.first;
  static VzBgStyle _bgOverride = kVzThemes.first.bg;

  /// رنگ داینامیک استخراج‌شده از آرت‌ورک (اگر باشد، بر تم اولویت دارد).
  static Color? _dynamicSeed;

  /// رنگ دلخواه دستی کاربر (اولویت بالاتر از همه).
  static Color? _customSeed;

  /// پالت ساخته‌شده‌ی فعال — کش می‌شود تا هر فریم بازساخته نشود.
  static VzPalette? _palette;
  static int? _paletteKey;

  // ── seed مؤثر: دستی > داینامیک > تم ──
  static Color get seed =>
      _customSeed ?? _dynamicSeed ?? _theme.seed;

  /// تم فعال.
  static VzThemeDef get theme => _theme;

  /// سبک پس‌زمینه‌ی مؤثر.
  static VzBgStyle get bgStyle => _bgOverride;

  /// آیا رنگ از آرت‌ورک گرفته شده؟
  static bool get hasDynamicSeed => _dynamicSeed != null;

  /// آیا کاربر رنگ دستی انتخاب کرده؟
  static bool get hasCustomSeed => _customSeed != null;

  static Color? get customSeed => _customSeed;

  // ── پالت فعال ──
  static VzPalette get pal {
    final key = Object.hash(seed, _dark);
    if (_palette == null || _paletteKey != key) {
      _palette = vzBuildPalette(seed, dark: _dark);
      _paletteKey = key;
    }
    return _palette!;
  }

  static bool get isDark => _dark;
  static bool get animations => _anim;

  /// Internal setters — فقط VzTheme صدا می‌زند.
  static void _setDark(bool v) { _dark = v; }
  static void _setAnimations(bool v) { _anim = v; }
  static void _setTheme(VzThemeDef t) { _theme = t; }
  static void _setBgOverride(VzBgStyle s) { _bgOverride = s; }
  static void _setDynamicSeed(Color? c) { _dynamicSeed = c; }
  static void _setCustomSeed(Color? c) { _customSeed = c; }

  @visibleForTesting
  static void previewAnimations(bool v) => _anim = v;

  // ── base ──
  static Color get bg       => pal.bg;
  static Color get bgDeep   => pal.bgDeep;
  static Color get surface  => pal.surface;
  static Color get surfaceHi=> pal.surfaceHi;
  static Color get card     => pal.card;
  static Color get cardHi   => pal.cardHi;
  static Color get border   => pal.border;
  static Color get borderHi => pal.borderHi;

  // ── accent ──
  static Color get accent     => pal.accent;
  static Color get accentHi   => pal.accentHi;
  static Color get accentDeep => pal.accentDeep;
  static Color get accentSoft => pal.accentSoft;
  static Color get onAccent   => pal.onAccent;
  static Color get accent2    => pal.pink;
  static Color get magenta    => pal.pink;

  /// سازگاری با کد قدیمی.
  static Color get deep => accentDeep;

  // ── semantic ──
  static Color get green => pal.green;
  static Color get amber => pal.amber;
  static Color get red   => pal.red;

  // ── text ──
  static Color get text    => pal.text;
  static Color get textSec => pal.textSec;
  static Color get textDim => pal.textDim;

  // ── overlays (نمایانگر، همیشه تیره چون روی ویدیو می‌نشینند) ──
  static Color get glassCard => surface;
  static Color get glassDark => _dark ? const Color(0x66000000) : const Color(0x33000000);
  static Color get glassLine => _dark ? const Color(0x1FFFFFFF) : const Color(0x14000000);
  static Color get dockFill  => surfaceHi;
  static Color get badgeBg   => const Color(0xB3000000);
  static Color get sheen     => _dark ? const Color(0x0AFFFFFF) : const Color(0x08000000);

  // ── scrim روی thumbnails (در هر دو مود یکسان) ──
  static const scrimTop = Color(0x00000000);
  static const scrimMid = Color(0x80000000);
  static const scrimBot = Color(0xE6000000);

  // ── OVI: پالت پلیر — همیشه تیره، چون روی ویدیو می‌نشیند ──
  static const oviBg      = Color(0xFF08080B);
  static const oviSurface = Color(0xFF141419);
  static const oviCard    = Color(0xFF1A1A20);
  static const oviCardHi  = Color(0xFF22222A);
  static const oviBorder  = Color(0xFF2A2A34);
  static const oviText    = Color(0xFFF2F2F5);
  static const oviTextSec = Color(0xFFA6A6B0);
  static const oviTextDim = Color(0xFF6E6E7A);

  // ── gradients ──
  static LinearGradient get accentGrad => LinearGradient(
    colors: [accentHi, accent], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static LinearGradient get auroraGrad => LinearGradient(
    colors: [accentHi, accent, accentDeep],
    stops: const [0.0, 0.55, 1.0],
    begin: Alignment.topLeft, end: Alignment.bottomRight);
  static LinearGradient get heroGrad => LinearGradient(
    colors: [Color.lerp(bg, accent, 0.20)!, bg, bg],
    stops: const [0.0, 0.55, 1.0],
    begin: Alignment.topLeft, end: Alignment.bottomRight);
  static LinearGradient get scrimGrad => const LinearGradient(
    begin: Alignment.bottomCenter, end: Alignment.topCenter,
    colors: [scrimBot, scrimMid, scrimTop],
    stops: [0.0, 0.45, 1.0]);

  static LinearGradient get bgGradient => vzBackground(pal, bgStyle);
  static List<Color> get bgGradientColors =>
      [Color.lerp(bg, accent, 0.18)!, bg, Color.lerp(bg, accentHi, 0.12)!];
  static bool get bgDecor => bgStyle != VzBgStyle.flat;

  /// مقیاس گردی گوشه — از تم فعال.
  static double get radiusScale => _theme.radiusScale;

  // ── shadows ──
  static BoxShadow get glow => BoxShadow(
    color: accent.withValues(alpha: 0.22), blurRadius: 24, offset: const Offset(0, 8));
  static BoxShadow get glowSoft => BoxShadow(
    color: accent.withValues(alpha: 0.14), blurRadius: 14, offset: const Offset(0, 4));
  static BoxShadow get shadow => BoxShadow(
    color: (_dark ? Colors.black : const Color(0xFF6B6480)).withValues(alpha: 0.18),
    blurRadius: 20, offset: const Offset(0, 6));
  static BoxShadow get amberGlow => BoxShadow(
    color: amber.withValues(alpha: 0.20), blurRadius: 18, offset: const Offset(0, 6));
  static BoxShadow get redGlow => BoxShadow(
    color: red.withValues(alpha: 0.20), blurRadius: 18, offset: const Offset(0, 6));

  /// بهترین رنگ متن روی یک پس‌زمینه‌ی دلخواه.
  static Color onColorOf(Color background) => vzOnColor(background);

  /// رنگ اکسنت اگر روی surface خوانا باشد، وگرنه متن معمولی.
  static Color accentOnSurface(Color surfaceColor) =>
      vzContrast(accent, surfaceColor) >= 3.0 ? accent : text;

  static double get _ratio => Vz.radiusScale;
  static double scaled(double base) => base * _ratio;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SPACING - 4pt scale
// ─────────────────────────────────────────────────────────────────────────────
abstract final class Sp {
  static const xs = 4.0, sm = 8.0, md = 12.0;
  static const lg = 16.0, xl = 20.0, xxl = 24.0;
  static const xxxl = 32.0, huge = 40.0, giant = 56.0;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHAPES - radius scaled by the active theme
// ─────────────────────────────────────────────────────────────────────────────
abstract final class Rad {
  static const xs = 10.0, sm = 14.0, md = 18.0;
  static const lg = 24.0, xl = 28.0, full = 999.0;

  /// مقدار مقیاس‌شده با تم فعال.
  static double s(double base) => base * Vz.radiusScale;

  /// BorderRadius آماده از یک پایه‌ی مقیاس‌شده.
  static BorderRadius r(double base) => BorderRadius.circular(s(base));
}

// ─────────────────────────────────────────────────────────────────────────────
//  TYPOGRAPHY
// ─────────────────────────────────────────────────────────────────────────────
abstract final class Ty {
  static TextStyle get display => TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Vz.text, height: 1.15);
  static TextStyle get title   => TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: Vz.text, height: 1.2);
  static TextStyle get heading => TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: Vz.text, height: 1.3);
  static TextStyle get body    => TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.0, color: Vz.text, height: 1.45);
  static TextStyle get bodySec => TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.0, color: Vz.textSec, height: 1.45);
  static TextStyle get label   => TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: Vz.text, height: 1.3);
  static TextStyle get caption => TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Vz.textSec, height: 1.3);
  static TextStyle get overline=> TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Vz.textDim, height: 1.2);
  static TextStyle get mono    => TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Vz.text, height: 1.2, fontFeatures: [const FontFeature.tabularFigures()]);
}

// ─────────────────────────────────────────────────────────────────────────────
//  MOTION — getters so the animation toggle is respected everywhere
// ─────────────────────────────────────────────────────────────────────────────
abstract final class Mo {
  static Duration get press => Vz.animations ? const Duration(milliseconds: 150) : Duration.zero;
  static Duration get fast => Vz.animations ? const Duration(milliseconds: 180) : Duration.zero;
  static Duration get normal => Vz.animations ? const Duration(milliseconds: 280) : Duration.zero;
  static Duration get sheet => Vz.animations ? const Duration(milliseconds: 320) : Duration.zero;
  static Curve get easeOut => Vz.animations ? Curves.easeOut : Curves.linear;
  static Curve get decel => Vz.animations ? Curves.decelerate : Curves.linear;
  static Curve get emphasized => Vz.animations ? Curves.easeOutCubic : Curves.linear;
}

// ─────────────────────────────────────────────────────────────────────────────
//  VzThemeScope — exposes snapshots so widgets rebuild on change
// ─────────────────────────────────────────────────────────────────────────────
class VzThemeScope extends InheritedWidget {
  const VzThemeScope({
    super.key,
    required this.isDark,
    required this.mode,
    required this.themeId,
    required this.bgStyle,
    required this.animations,
    required this.dynamicSeed,
    required this.customSeed,
    required super.child,
  });

  final bool isDark;
  final VzThemeMode mode;
  final String themeId;
  final VzBgStyle bgStyle;
  final bool animations;

  /// رنگ استخراج‌شده از آرت‌ورک (اگر باشد).
  final Color? dynamicSeed;

  /// رنگ دستی کاربر (اگر باشد).
  final Color? customSeed;

  static VzThemeScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VzThemeScope>();

  static bool of(BuildContext context) => maybeOf(context)?.isDark ?? Vz.isDark;
  static VzThemeMode modeOf(BuildContext context) =>
      maybeOf(context)?.mode ?? VzThemeMode.system;
  static String themeIdOf(BuildContext context) =>
      maybeOf(context)?.themeId ?? Vz.theme.id;
  static VzBgStyle bgStyleOf(BuildContext context) =>
      maybeOf(context)?.bgStyle ?? Vz.bgStyle;
  static bool animationsOf(BuildContext context) =>
      maybeOf(context)?.animations ?? Vz.animations;
  static Color? dynamicSeedOf(BuildContext context) =>
      maybeOf(context)?.dynamicSeed ?? Vz._dynamicSeed;
  static Color? customSeedOf(BuildContext context) =>
      maybeOf(context)?.customSeed ?? Vz.customSeed;

  @override
  bool updateShouldNotify(VzThemeScope old) =>
      isDark != old.isDark ||
      mode != old.mode ||
      themeId != old.themeId ||
      bgStyle != old.bgStyle ||
      animations != old.animations ||
      dynamicSeed != old.dynamicSeed ||
      customSeed != old.customSeed;
}

/// Root theming widget — must sit above MaterialApp.
class VzTheme extends StatefulWidget {
  final Widget child;
  const VzTheme({super.key, required this.child});
  @override
  State<VzTheme> createState() => VzThemeState();
}

/// Public state so Settings can drive the theme.
class VzThemeState extends State<VzTheme> with WidgetsBindingObserver {
  VzThemeMode _mode = VzThemeMode.system;
  VzThemeDef _theme = kVzThemes.first;
  VzBgStyle _bg = kVzThemes.first.bg;
  bool _anim = true;
  Color? _customSeed;
  Color? _dynamicSeed;

  VzThemeMode get mode => _mode;
  VzThemeDef get theme => _theme;
  VzBgStyle get bgStyle => _bg;
  bool get animations => _anim;
  Color? get customSeed => _customSeed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (_mode == VzThemeMode.system) setState(() {});
  }

  Future<void> _load() async {
    final raw = await storeThemePrefs?.call() ?? 'system';
    _mode = switch (raw) {
      'dark'  => VzThemeMode.dark,
      'light' => VzThemeMode.light,
      _       => VzThemeMode.system,
    };
    _theme = vzThemeById(await storeThemeIdPrefs?.call());
    _bg = _theme.bg;
    final bgRaw = await storeBgPrefs?.call();
    if (bgRaw != null) {
      _bg = VzBgStyle.values.firstWhere(
        (s) => s.name == bgRaw, orElse: () => _theme.bg);
    }
    _anim = await storeAnimPrefs?.call() ?? true;
    final cs = await storeCustomSeedPrefs?.call();
    _customSeed = cs == null ? null : Color(cs);
    if (mounted) setState(() {});
  }

  Future<void> setMode(VzThemeMode m) async {
    _mode = m;
    setState(() {});
    await storeThemeSave?.call(switch (m) {
      VzThemeMode.dark  => 'dark',
      VzThemeMode.light => 'light',
      _                 => 'system',
    });
  }

  /// انتخاب تم آماده — پس‌زمینه هم پیش‌فرض همان تم می‌شود.
  Future<void> setTheme(VzThemeDef t) async {
    _theme = t;
    _bg = t.bg;
    _customSeed = null; // تم جدید یعنی seed خودش
    setState(() {});
    await storeThemeIdSave?.call(t.id);
    await storeBgSave?.call(t.bg.name);
    await storeCustomSeedSave?.call(null);
  }

  Future<void> setBgStyle(VzBgStyle s) async {
    _bg = s;
    setState(() {});
    await storeBgSave?.call(s.name);
  }

  /// رنگ دستی کاربر — بالاترین اولویت.
  Future<void> setCustomSeed(Color c) async {
    _customSeed = c;
    setState(() {});
    await storeCustomSeedSave?.call(c.toARGB32());
  }

  Future<void> clearCustomSeed() async {
    _customSeed = null;
    setState(() {});
    await storeCustomSeedSave?.call(null);
  }

  /// رنگ داینامیک از آرت‌ورک — وقتی پلیر پوستر عوض می‌کند.
  void setDynamicSeed(Color? c) {
    if (_dynamicSeed == c) return;
    _dynamicSeed = c;
    if (mounted) setState(() {});
  }

  Future<void> setAnimations(bool v) async {
    _anim = v;
    setState(() {});
    await storeAnimSave?.call(v);
  }

  bool get _isDarkNow {
    if (_mode != VzThemeMode.system) return _mode == VzThemeMode.dark;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final dark = _isDarkNow;
    Vz._setDark(dark);
    Vz._setAnimations(_anim);
    Vz._setTheme(_theme);
    Vz._setBgOverride(_bg);
    Vz._setCustomSeed(_customSeed);
    Vz._setDynamicSeed(_dynamicSeed);
    return VzThemeScope(
      isDark: dark,
      mode: _mode,
      themeId: _theme.id,
      bgStyle: _bg,
      animations: _anim,
      dynamicSeed: _dynamicSeed,
      customSeed: _customSeed,
      child: widget.child,
    );
  }
}

/// Hooks wired to SharedPreferences by main.dart.
Future<String?> Function()? storeThemePrefs;
Future<void> Function(String)? storeThemeSave;
Future<String?> Function()? storeThemeIdPrefs;
Future<void> Function(String)? storeThemeIdSave;
Future<String?> Function()? storeBgPrefs;
Future<void> Function(String)? storeBgSave;
Future<bool?> Function()? storeAnimPrefs;
Future<void> Function(bool)? storeAnimSave;
Future<int?> Function()? storeCustomSeedPrefs;
Future<void> Function(int?)? storeCustomSeedSave;

// ─────────────────────────────────────────────────────────────────────────────
//  AMBIENT BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────
/// پس‌زمینه‌ی اپ — گرادیان پالت + هاله‌های نرم که آرام حرکت می‌کنند.
/// در حالت flat فقط رنگ پایه می‌ماند (سبک Namida).
class VzAmbientBg extends StatefulWidget {
  final Widget child;
  const VzAmbientBg({super.key, required this.child});
  @override State<VzAmbientBg> createState() => _VzAmbientBgState();
}

class _VzAmbientBgState extends State<VzAmbientBg> with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void initState() { super.initState(); _sync(); }

  @override
  void didChangeDependencies() { super.didChangeDependencies(); _sync(); }

  void _sync() {
    final want = Vz.animations && Vz.bgDecor;
    if (want && _c == null) {
      _c = AnimationController(vsync: this, duration: const Duration(seconds: 20))
        ..repeat(reverse: true);
    } else if (!want && _c != null) {
      _c!.dispose();
      _c = null;
    }
  }

  @override
  void dispose() { _c?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(gradient: Vz.bgGradient);
    if (!Vz.bgDecor) {
      return DecoratedBox(decoration: decoration, child: widget.child);
    }

    final strength = switch (Vz.bgStyle) {
      VzBgStyle.glow  => 0.20,
      VzBgStyle.vivid => 0.30,
      _               => 0.12,
    };
    final a = _c;
    final content = Stack(children: [
      Positioned(top: -220, right: -160,
        child: _blob(Vz.accent.withValues(alpha: Vz.isDark ? strength : strength + 0.10))),
      Positioned(bottom: -260, left: -200,
        child: _blob(Vz.accentHi.withValues(alpha: Vz.isDark ? strength * 0.85 : strength + 0.08))),
      if (a != null)
        Positioned(top: 140, left: -120,
          child: _moving(a, Vz.accentDeep.withValues(alpha: Vz.isDark ? strength * 0.6 : strength))),
      widget.child,
    ]);

    return DecoratedBox(
      decoration: decoration,
      child: a == null ? content : RepaintBoundary(child: content));
  }

  Widget _blob(Color color) => IgnorePointer(child: Container(
    width: 520, height: 520,
    decoration: BoxDecoration(shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]))));

  Widget _moving(AnimationController c, Color color) => IgnorePointer(
    child: AnimatedBuilder(animation: c, builder: (ctx, _) {
      final t = Curves.easeInOut.transform(c.value);
      return Transform.translate(
        offset: Offset(60 * (t * 2 - 1), 90 * (t * 2 - 1)),
        child: Container(width: 420, height: 420,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]))));
    }));

}

/// خط اسکن افقی — انیمیشن ریز در هدرهای فعال.
class VzScanLine extends StatefulWidget {
  final double height;
  final Color color;
  const VzScanLine({super.key, this.height = 2, this.color = Colors.transparent});
  @override State<VzScanLine> createState()=>_VzScanLineState();
}
class _VzScanLineState extends State<VzScanLine> with SingleTickerProviderStateMixin{
  late final AnimationController _c = AnimationController(
    vsync:this,duration:const Duration(seconds:4))..repeat();
  @override void dispose(){_c.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    return AnimatedBuilder(animation:_c,builder:(ctx,_){
      return LayoutBuilder(builder:(ctx,box){
        final w=box.maxWidth;
        final x=(w+80)*_c.value-40;
        return SizedBox(height:widget.height,child:Stack(children:[
          Positioned(left:x.clamp(-40,w+40)-20,top:0,bottom:0,width:60,
            child:Container(decoration:BoxDecoration(
              gradient:LinearGradient(colors:[
                widget.color.withValues(alpha:0),
                widget.color.withValues(alpha:0.55),
                widget.color.withValues(alpha:0)])))),
        ]));
      });
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  THEME DATA
// ─────────────────────────────────────────────────────────────────────────────
SystemUiOverlayStyle _overlay(bool dark) => SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  systemNavigationBarColor: Colors.transparent,
  statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
  systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
);

ThemeData buildVezooTheme({bool dark = true}) {
  Vz._setDark(dark);
  final p = Vz.pal;
  final scheme = ColorScheme(
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: p.accent,
    onPrimary: p.onAccent,
    primaryContainer: p.accentSoft,
    onPrimaryContainer: p.accent,
    secondary: p.accentHi,
    onSecondary: p.onAccent,
    surface: p.surface,
    onSurface: p.text,
    surfaceContainerLowest: p.bgDeep,
    surfaceContainerLow: p.bg,
    surfaceContainer: p.surface,
    surfaceContainerHigh: p.card,
    surfaceContainerHighest: p.cardHi,
    outline: p.border,
    outlineVariant: p.borderHi,
    error: p.red,
    onError: Colors.white,
  );
  final rSm = Rad.r(Rad.sm);
  final rLg = Rad.r(Rad.lg);
  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: Vz.bgStyle == VzBgStyle.flat ? Vz.bg : Colors.transparent,
    canvasColor: Vz.bg,
    splashColor: Vz.accent.withValues(alpha: 0.10),
    highlightColor: Vz.accent.withValues(alpha: 0.05),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0, scrolledUnderElevation: 0,
      foregroundColor: Vz.text, centerTitle: false,
      systemOverlayStyle: _overlay(dark),
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
        letterSpacing: -0.3, color: Vz.text),
      iconTheme: IconThemeData(color: Vz.text),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Vz.surface,
      modalBackgroundColor: Vz.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.s(Rad.xl)))),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Vz.accent,
      inactiveTrackColor: Vz.border,
      thumbColor: Vz.accent,
      overlayColor: Vz.accent.withValues(alpha: 0.14),
      trackHeight: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Vz.onAccent : Vz.textDim),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Vz.accent : Vz.cardHi),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Vz.card,
      side: BorderSide(color: Vz.border, width: 1),
      labelStyle: TextStyle(fontSize: 12, color: Vz.text),
      shape: RoundedRectangleBorder(borderRadius: rSm),
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: Vz.accent, labelColor: Vz.text,
      unselectedLabelColor: Vz.textDim,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(color: Vz.border, thickness: 1, space: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: Vz.surface, surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Vz.text),
      shape: RoundedRectangleBorder(borderRadius: rLg),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 2),
      iconColor: Vz.textSec,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Vz.card,
      hintStyle: TextStyle(color: Vz.textDim, fontSize: 13),
      border: OutlineInputBorder(borderRadius: rSm, borderSide: BorderSide(color: Vz.border)),
      enabledBorder: OutlineInputBorder(borderRadius: rSm, borderSide: BorderSide(color: Vz.border)),
      focusedBorder: OutlineInputBorder(borderRadius: rSm, borderSide: BorderSide(color: Vz.accent, width: 1.4)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Vz.cardHi, surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: rSm),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Vz.accent, foregroundColor: Vz.onAccent,
      elevation: 0, focusElevation: 0, hoverElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: rSm),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Vz.accent, foregroundColor: Vz.onAccent,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: rSm)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Vz.text, side: BorderSide(color: Vz.borderHi),
        shape: RoundedRectangleBorder(borderRadius: rSm)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Vz.accent),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Vz.cardHi,
      contentTextStyle: TextStyle(color: Vz.text, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: rSm, side: BorderSide(color: Vz.border)),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: Vz.cardHi, borderRadius: BorderRadius.circular(8)),
      textStyle: TextStyle(fontSize: 11, color: Vz.text),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Vz.accent, linearTrackColor: Vz.cardHi),
    iconTheme: IconThemeData(color: Vz.text),
    textTheme: TextTheme(
      titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2, color: Vz.text),
      bodySmall: TextStyle(color: Vz.textSec),
    ),
  );
}
