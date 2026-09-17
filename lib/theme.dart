// lib/theme.dart — Vezoo Design System v6 "VOID"
//
// Cinematic dark-first design language.
//   • one accent  (amber)  — no more purple/pink aurora soup
//   • flat surfaces        — no blur, no glass, no noise (fast on low-end devices)
//   • 1px hairline rules   — structure comes from lines, not shadows
//   • two modes            — VOID (dark) / DAYLIGHT (light)
//
// Public API is unchanged (Vz, Sp, Rad, Ty, Mo, VzTheme…) so every existing
// screen keeps compiling while getting the new look for free.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'vz_presets.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  THEME MODE
// ─────────────────────────────────────────────────────────────────────────────
enum VzThemeMode { system, dark, light }

/// انتخاب بک‌گراند: رنگ پرسِت، یا گرادیان پرسِت، یا خاموش (تخت).
enum VzBgMode { gradient, solid, off }

// ─────────────────────────────────────────────────────────────────────────────
//  PALETTE — از پرسِت فعال خوانده می‌شود (vz_presets.dart)
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
//  ACCENTS — انتخاب کاربر. هر اکسنت نسخه‌ی تیره و روشن دارد تا روی هر دو
//  پالت خوانا بماند. رنگ‌های semantic (سبز/قرمز/…) مستقل می‌مانند.
// ─────────────────────────────────────────────────────────────────────────────
class VzAccent {
  final String name;
  final Color dark, darkHi, darkDeep;
  final Color light, lightHi, lightDeep;
  const VzAccent(
    this.name, {
    required this.dark,
    required this.darkHi,
    required this.darkDeep,
    required this.light,
    required this.lightHi,
    required this.lightDeep,
  });
}

const List<VzAccent> kVzAccents = [
  VzAccent('Cyan',
    dark: Color(0xFF22D3EE), darkHi: Color(0xFF67E8F9), darkDeep: Color(0xFF0E7490),
    light: Color(0xFF0891B2), lightHi: Color(0xFF06B6D4), lightDeep: Color(0xFF155E75)),
  VzAccent('Emerald',
    dark: Color(0xFF34D399), darkHi: Color(0xFF6EE7B7), darkDeep: Color(0xFF047857),
    light: Color(0xFF059669), lightHi: Color(0xFF10B981), lightDeep: Color(0xFF065F46)),
  VzAccent('Sky',
    dark: Color(0xFF60A5FA), darkHi: Color(0xFF93C5FD), darkDeep: Color(0xFF1D4ED8),
    light: Color(0xFF2563EB), lightHi: Color(0xFF3B82F6), lightDeep: Color(0xFF1E40AF)),
  VzAccent('Violet',
    dark: Color(0xFFA78BFA), darkHi: Color(0xFFC4B5FD), darkDeep: Color(0xFF6D28D9),
    light: Color(0xFF7C3AED), lightHi: Color(0xFF8B5CF6), lightDeep: Color(0xFF5B21B6)),
  VzAccent('Rose',
    dark: Color(0xFFFB7185), darkHi: Color(0xFFFDA4AF), darkDeep: Color(0xFFBE123C),
    light: Color(0xFFE11D48), lightHi: Color(0xFFF43F5E), lightDeep: Color(0xFF9F1239)),
  VzAccent('Orange',
    dark: Color(0xFFFB923C), darkHi: Color(0xFFFDBA74), darkDeep: Color(0xFFC2410C),
    light: Color(0xFFEA580C), lightHi: Color(0xFFF97316), lightDeep: Color(0xFF9A3412)),
  VzAccent('Lime',
    dark: Color(0xFFA3E635), darkHi: Color(0xFFBEF264), darkDeep: Color(0xFF4D7C0F),
    light: Color(0xFF65A30D), lightHi: Color(0xFF84CC16), lightDeep: Color(0xFF3F6212)),
  VzAccent('Fuchsia',
    dark: Color(0xFFE879F9), darkHi: Color(0xFFF0ABFC), darkDeep: Color(0xFFA21CAF),
    light: Color(0xFFC026D3), lightHi: Color(0xFFD946EF), lightDeep: Color(0xFF86198F)),
  VzAccent('Teal',
    dark: Color(0xFF2DD4BF), darkHi: Color(0xFF5EEAD4), darkDeep: Color(0xFF0F766E),
    light: Color(0xFF0D9488), lightHi: Color(0xFF14B8A6), lightDeep: Color(0xFF115E59)),
  VzAccent('Ice',
    dark: Color(0xFFE2E8F0), darkHi: Color(0xFFF8FAFC), darkDeep: Color(0xFF94A3B8),
    light: Color(0xFF1E293B), lightHi: Color(0xFF334155), lightDeep: Color(0xFF0F172A)),
  VzAccent('Amber',
    dark: Color(0xFFF59E0B), darkHi: Color(0xFFFBBF24), darkDeep: Color(0xFFB45309),
    light: Color(0xFFB45309), lightHi: Color(0xFFD97706), lightDeep: Color(0xFF92400E)),
];

/// رنگ‌های پایه‌ی پرسِت فعال. مقادیر در زمان build از [_preset] خوانده می‌شوند.
class _P {
  static Color get bg       => Vz._preset.bgDark;
  static Color get bgDeep   => Vz._preset.bgDeepDark;
  static Color get surface  => Vz._preset.surfaceDark;
  static Color get card     => Vz._preset.cardDark;
  static Color get cardHi   => Vz._preset.cardHiDark;
  static Color get border   => Vz._preset.borderDark;
  static Color get borderHi => Vz._preset.borderHiDark;

  // رنگ‌های semantic — بین همه‌ی پرسِت‌ها ثابت می‌مانند
  static const magenta  = Color(0xFFFB7185);
  static const green    = Color(0xFF4ADE80);
  static const amber    = Color(0xFFFBBF24);
  static const red      = Color(0xFFF87171);
  static const mauve    = Color(0xFF71717A);

  static const text     = Color(0xFFF5F5F7);
  static const textSec  = Color(0xFFA1A1AA);
  static const textDim  = Color(0xFF6B6B76);

  static const scrimTop = Color(0x000A0A0C);
  static const scrimMid = Color(0x800A0A0C);
  static const scrimBot = Color(0xE60A0A0C);

  static const glassDark = Color(0x66000000);
  static const badgeBg   = Color(0xB3000000);
  static const sheen     = Color(0x0AFFFFFF);
}

class _L {
  static Color get bg       => Vz._preset.bgLight;
  static Color get bgDeep   => Vz._preset.bgDeepLight;
  static Color get surface  => Vz._preset.surfaceLight;
  static Color get card     => Vz._preset.cardLight;
  static Color get cardHi   => Vz._preset.cardHiLight;
  static Color get border   => Vz._preset.borderLight;
  static Color get borderHi => Vz._preset.borderHiLight;

  static const magenta  = Color(0xFFE11D48);
  static const green    = Color(0xFF059669);
  static const amber    = Color(0xFFD97706);
  static const red      = Color(0xFFDC2626);
  static const mauve    = Color(0xFF71717A);

  static const text     = Color(0xFF101014);
  static const textSec  = Color(0xFF52525B);
  static const textDim  = Color(0xFF8E8E99);

  static const scrimTop = Color(0x000A0A0C);
  static const scrimMid = Color(0x800A0A0C);
  static const scrimBot = Color(0xE60A0A0C);

  static const glassDark = Color(0x33000000);
  static const badgeBg   = Color(0xB3000000);
  static const sheen     = Color(0x08000000);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Vz — runtime palette. Resolves dark/light at build time.
// ─────────────────────────────────────────────────────────────────────────────
class Vz {
  Vz._();

  static bool _dark = true;
  static int _accentIndex = 0;
  static bool _anim = true;
  static VzPreset _preset = kVzPresets.first;
  static VzBgMode _bgMode = VzBgMode.gradient;

  /// Whether the active palette is dark. Set by VzTheme before first frame.
  static bool get isDark => _dark;

  /// Whether entrance/transition animations are enabled (user toggle).
  static bool get animations => _anim;

  /// Index into [kVzAccents].
  static int get accentIndex => _accentIndex;

  /// پرسِت فعال — منبع همه‌ی رنگ‌های پایه و شکل‌ها.
  static VzPreset get preset => _preset;

  /// حالت بک‌گراند انتخاب‌شده.
  static VzBgMode get bgMode => _bgMode;

  /// رنگ‌های بک‌گراند گرادیانی برای مود فعال.
  static List<Color> get bgGradientColors =>
      _dark ? _preset.bgGradientsDark : _preset.bgGradientsLight;

  /// گرادیان بک‌گراند — اگر حالت off باشد، یک گرادیان تک‌رنگ برمی‌گردد
  /// تا هیچ‌جا null لازم نباشد.
  static LinearGradient get bgGradient => _bgMode == VzBgMode.solid
      ? LinearGradient(colors: [bg, bg], begin: Alignment.topCenter, end: Alignment.bottomCenter)
      : LinearGradient(
          colors: bgGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  /// آیا هاله‌های تزئینی پشت محتوا رسم شوند؟
  static bool get bgDecor => _bgMode == VzBgMode.gradient;

  /// مقیاس گردی گوشه‌ی پرسِت — همه‌ی radius ها را می‌چرخاند.
  static double get radiusScale => _preset.radiusScale;

  static final VzAccent _presetAccent = VzAccent(
    'Preset',
    dark: _preset.accentDark,
    darkHi: _preset.accentDarkHi,
    darkDeep: _preset.accentDarkDeep,
    light: _preset.accentLight,
    lightHi: _preset.accentLightHi,
    lightDeep: _preset.accentLightDeep,
  );

  static VzAccent get _acc {
    if (_accentIndex < 0) return _presetAccent; // -1 = رنگ خودِ پرسِت
    return kVzAccents[_accentIndex.clamp(0, kVzAccents.length - 1)];
  }

  /// رنگ مکمل پرسِت (برای گرادیان‌های دوتایی).
  static Color get accent2 => _preset.accent2;

  /// Text/icon color to draw on top of [accent] — picked by luminance so every
  /// accent stays readable.
  static Color get onAccent =>
      accent.computeLuminance() > 0.55 ? const Color(0xFF0C0C0F) : Colors.white;

  /// Internal: called by VzTheme / buildVezooTheme before building.
  static void _setDark(bool v) { _dark = v; }
  static void _setAccentIndex(int i) {
    // -1 یعنی «رنگ خود پرسِت»
    _accentIndex = i < 0 ? -1 : i.clamp(0, kVzAccents.length - 1);
  }
  static void _setAnimations(bool v) { _anim = v; }
  static void _setPreset(VzPreset p) { _preset = p; }
  static void _setBgMode(VzBgMode m) { _bgMode = m; }

  // ── base ──
  static Color get bg       => _dark ? _P.bg       : _L.bg;
  static Color get bgDeep   => _dark ? _P.bgDeep   : _L.bgDeep;
  static Color get surface  => _dark ? _P.surface  : _L.surface;
  static Color get card     => _dark ? _P.card     : _L.card;
  static Color get cardHi   => _dark ? _P.cardHi   : _L.cardHi;
  static Color get border   => _dark ? _P.border   : _L.border;
  static Color get borderHi => _dark ? _P.borderHi : _L.borderHi;

  // ── accents ──
  static Color get accent   => _dark ? _acc.dark     : _acc.light;
  static Color get accentHi => _dark ? _acc.darkHi   : _acc.lightHi;
  static Color get deep     => _dark ? _acc.darkDeep : _acc.lightDeep;
  static Color get magenta  => _dark ? _P.magenta    : _L.magenta;

  // ── semantic ──
  static Color get green    => _dark ? _P.green    : _L.green;
  static Color get amber    => _dark ? _P.amber    : _L.amber;
  static Color get red      => _dark ? _P.red      : _L.red;
  static Color get mauve    => _dark ? _P.mauve    : _L.mauve;

  // ── text ──
  static Color get text     => _dark ? _P.text     : _L.text;
  static Color get textSec  => _dark ? _P.textSec  : _L.textSec;
  static Color get textDim  => _dark ? _P.textDim  : _L.textDim;

  // ── overlays ──
  static Color get glassCard => surface;
  static Color get glassDark => _dark ? _P.glassDark : _L.glassDark;
  static Color get glassLine => _dark ? const Color(0x1FFFFFFF) : const Color(0x14000000);
  static Color get dockFill  => surface;
  static Color get badgeBg   => _dark ? _P.badgeBg   : _L.badgeBg;
  static Color get sheen     => _dark ? _P.sheen     : _L.sheen;

  // ── scrim: gradient روی thumbnails (در هر دو مود یکسان) ──
  static Color get scrimTop => _dark ? _P.scrimTop : _L.scrimTop;
  static Color get scrimMid => _dark ? _P.scrimMid : _L.scrimMid;
  static Color get scrimBot => _dark ? _P.scrimBot : _L.scrimBot;

  // ── OVI: overlay-video palette — ALWAYS dark, for player surfaces on top of video.
  // Player must never follow light theme (it sits on dark video content).
  static const oviBg      = Color(0xFF050507);
  static const oviSurface = Color(0xFF121216);
  static const oviCard    = Color(0xFF17171C);
  static const oviCardHi  = Color(0xFF1F1F26);
  static const oviBorder  = Color(0xFF26262E);
  static const oviText    = Color(0xFFF5F5F7);
  static const oviTextSec = Color(0xFFA1A1AA);
  static const oviTextDim = Color(0xFF6B6B76);

  // ── gradients ──
  /// Primary accent ramp — amber only. (legacy name kept)
  static LinearGradient get auroraGrad => LinearGradient(
    colors: [accentHi, accent, deep],
    stops: const [0.0, 0.55, 1.0],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static LinearGradient get accentGrad => LinearGradient(
    colors: [accentHi, accent],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  /// Flat cinematic wash for headers/hero areas.
  /// از گرادیان بک‌گراند پرسِت مشتق می‌شود تا با هر تم هماهنگ بماند.
  static LinearGradient get heroGrad => LinearGradient(
    colors: [
      bgGradientColors.first,
      bgGradientColors.length > 1 ? bgGradientColors[1] : bg,
      bg,
    ],
    stops: const [0.0, 0.55, 1.0],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static LinearGradient get scrimGrad => LinearGradient(
    begin: Alignment.bottomCenter, end: Alignment.topCenter,
    colors: [scrimBot, scrimMid, scrimTop],
    stops: const [0.0, 0.45, 1.0],
  );

  // ── shadows (tinted per mode) ──
  static BoxShadow get glow => BoxShadow(
    color: accent.withValues(alpha: 0.22), blurRadius: 24, offset: const Offset(0, 8),
  );
  static BoxShadow get glowSoft => BoxShadow(
    color: accent.withValues(alpha: 0.14), blurRadius: 14, offset: const Offset(0, 4),
  );
  static BoxShadow get shadow => BoxShadow(
    color: (_dark ? const Color(0xFF000000) : const Color(0xFF6B6480)).withValues(alpha: 0.18),
    blurRadius: 20, offset: const Offset(0, 6),
  );
  static BoxShadow get amberGlow => BoxShadow(
    color: amber.withValues(alpha: 0.20), blurRadius: 18, offset: const Offset(0, 6),
  );
  static BoxShadow get redGlow => BoxShadow(
    color: red.withValues(alpha: 0.20), blurRadius: 18, offset: const Offset(0, 6),
  );
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
//  SHAPES - radius system
// ─────────────────────────────────────────────────────────────────────────────
//  SHAPES - radius system
//  مقیاس گردی از پرسِت می‌آید: kawaii خیلی گرد، shonen تیزتر.
// ─────────────────────────────────────────────────────────────────────────────
abstract final class Rad {
  static const xs = 10.0, sm = 14.0, md = 18.0;
  static const lg = 24.0, xl = 28.0, full = 999.0;

  /// مقدار مقیاس‌شده با پرسِت — برای استفاده در ویجت‌ها.
  static double s(double base) => base * Vz.radiusScale;

  /// BorderRadius آماده از یک پایه‌ی مقیاس‌شده.
  static BorderRadius r(double base) => BorderRadius.circular(s(base));
}

// ─────────────────────────────────────────────────────────────────────────────
//  TYPOGRAPHY - scale سبک
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
//  MOTION - durations & curves
//  همه getter هستند تا کلید «انیمیشن» کاربر از هر جای اپ احترام گذاشته شود.
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
//  VzTheme - InheritedWidget bridging mode changes to the Vz getters
// ─────────────────────────────────────────────────────────────────────────────
class VzThemeScope extends InheritedWidget {
  const VzThemeScope({
    super.key,
    required this.isDark,
    required this.mode,
    required this.accentIndex,
    required this.animations,
    required this.presetId,
    required this.bgMode,
    required super.child,
  });

  /// Snapshot of dark mode captured at build time — dependents rebuild on change.
  final bool isDark;

  /// Snapshot of the user's chosen mode (system/dark/light).
  final VzThemeMode mode;

  /// Snapshot of the chosen accent (index into [kVzAccents]); -1 = preset colour.
  final int accentIndex;

  /// Snapshot of the animation toggle.
  final bool animations;

  /// Snapshot of the chosen preset id.
  final String presetId;

  /// Snapshot of the background mode.
  final VzBgMode bgMode;

  static VzThemeScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VzThemeScope>();

  static bool of(BuildContext context) {
    final w = maybeOf(context);
    return w?.isDark ?? Vz.isDark;
  }

  /// Reads the selected mode through the inherited widget, so widgets that
  /// call this rebuild whenever the mode changes — even when the resolved
  /// brightness stays the same (e.g. dark → system while still dark).
  static VzThemeMode modeOf(BuildContext context) =>
      maybeOf(context)?.mode ?? VzThemeMode.system;

  static int accentIndexOf(BuildContext context) =>
      maybeOf(context)?.accentIndex ?? Vz.accentIndex;

  static bool animationsOf(BuildContext context) =>
      maybeOf(context)?.animations ?? Vz.animations;

  static String presetIdOf(BuildContext context) =>
      maybeOf(context)?.presetId ?? Vz.preset.id;

  static VzBgMode bgModeOf(BuildContext context) =>
      maybeOf(context)?.bgMode ?? Vz.bgMode;

  @override
  bool updateShouldNotify(VzThemeScope oldWidget) =>
      isDark != oldWidget.isDark ||
      mode != oldWidget.mode ||
      accentIndex != oldWidget.accentIndex ||
      animations != oldWidget.animations ||
      presetId != oldWidget.presetId ||
      bgMode != oldWidget.bgMode;
}

/// Root stateful theming widget. Place above MaterialApp.
/// Calls Vz._setDark before every build so all Vz getters resolve correctly.
class VzTheme extends StatefulWidget {
  final Widget child;
  const VzTheme({super.key, required this.child});
  @override
  State<VzTheme> createState() => VzThemeState();
}

/// Public state so Settings can read mode & call setMode().
class VzThemeState extends State<VzTheme> with WidgetsBindingObserver {
  VzThemeMode _mode = VzThemeMode.system;
  int _accent = -1; // -1 = رنگ خودِ پرسِت
  bool _anim = true;
  VzPreset _preset = kVzPresets.first;
  VzBgMode _bg = VzBgMode.gradient;

  VzThemeMode get mode => _mode;
  int get accent => _accent;
  bool get animations => _anim;
  VzPreset get preset => _preset;
  VzBgMode get bgMode => _bg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMode();
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

  Future<void> _loadMode() async {
    // SharedPreferences loaded in Store.load() before runApp.
    final raw = await storeThemePrefs?.call() ?? 'system';
    _mode = switch (raw) {
      'dark'  => VzThemeMode.dark,
      'light' => VzThemeMode.light,
      _       => VzThemeMode.system,
    };
    final a = await storeAccentPrefs?.call();
    _accent = (a == null || a < -1 || a >= kVzAccents.length) ? -1 : a;
    _anim = await storeAnimPrefs?.call() ?? true;
    _preset = vPresetById(await storePresetPrefs?.call());
    _bg = switch (await storeBgPrefs?.call()) {
      'solid' => VzBgMode.solid,
      'off'   => VzBgMode.off,
      _       => VzBgMode.gradient,
    };
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

  Future<void> setAccent(int i) async {
    _accent = (i < 0 || i >= kVzAccents.length) ? -1 : i;
    setState(() {});
    await storeAccentSave?.call(_accent);
  }

  Future<void> setAnimations(bool v) async {
    _anim = v;
    setState(() {});
    await storeAnimSave?.call(v);
  }

  Future<void> setPreset(VzPreset p) async {
    _preset = p;
    _accent = -1; // پرسِت جدید یعنی رنگ پرسِت، تا ناسازگار نماند
    setState(() {});
    await storePresetSave?.call(p.id);
    await storeAccentSave?.call(-1);
  }

  /// فقط رنگ بک‌گراند (بدون عوض کردن پرسِت).
  Future<void> setBgMode(VzBgMode m) async {
    _bg = m;
    setState(() {});
    await storeBgSave?.call(switch (m) {
      VzBgMode.solid => 'solid',
      VzBgMode.off   => 'off',
      _              => 'gradient',
    });
  }

  bool get _isDarkNow {
    if (_mode != VzThemeMode.system) return _mode == VzThemeMode.dark;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final dark = _isDarkNow;
    Vz._setDark(dark);
    Vz._setAccentIndex(_accent);
    Vz._setAnimations(_anim);
    Vz._setPreset(_preset);
    Vz._setBgMode(_bg);
    return VzThemeScope(
      isDark: dark,
      mode: _mode,
      accentIndex: _accent,
      animations: _anim,
      presetId: _preset.id,
      bgMode: _bg,
      child: widget.child,
    );
  }
}

/// Hook set by Store so theme.dart stays free of package imports.
/// (main.dart wires these to SharedPreferences)
Future<String?> Function()? storeThemePrefs;
Future<void> Function(String)? storeThemeSave;
Future<int?> Function()? storeAccentPrefs;
Future<void> Function(int)? storeAccentSave;
Future<bool?> Function()? storeAnimPrefs;
Future<void> Function(bool)? storeAnimSave;
Future<String?> Function()? storePresetPrefs;
Future<void> Function(String)? storePresetSave;
Future<String?> Function()? storeBgPrefs;
Future<void> Function(String)? storeBgSave;

// ─────────────────────────────────────────────────────────────────────────────
//  AMBIENT BACKGROUND — بک‌گراند گرادیانی رنگی و متحرک
// ─────────────────────────────────────────────────────────────────────────────
/// پس‌زمینه‌ی اپ: گرادیان پرسِت + دو هاله‌ی نرم که آرام حرکت می‌کنند.
/// با کلید انیمیشن خاموش می‌شود و با حالت «تخت» فقط رنگ پایه می‌ماند.
class VzAmbientBg extends StatefulWidget {
  final Widget child;
  const VzAmbientBg({super.key, required this.child});
  @override State<VzAmbientBg> createState() => _VzAmbientBgState();
}

class _VzAmbientBgState extends State<VzAmbientBg> with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    final want = Vz.animations && Vz.bgDecor;
    if (want && _c == null) {
      _c = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 18),
      )..repeat(reverse: true);
    } else if (!want && _c != null) {
      _c!.dispose();
      _c = null;
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // گرادیان پایه — در هر دو حالت تخت و گرادیانی امن است
    final decoration = BoxDecoration(
      gradient: Vz.bgMode == VzBgMode.off
          ? LinearGradient(colors: [Vz.bg, Vz.bg])
          : Vz.bgGradient,
    );

    if (!Vz.bgDecor) {
      return DecoratedBox(
        decoration: decoration,
        child: widget.child,
      );
    }

    final anim = _c;
    final content = Stack(children: [
      Positioned(
        top: -220, right: -160,
        child: _blob(Vz.accent.withValues(alpha: Vz.isDark ? 0.20 : 0.30)),
      ),
      Positioned(
        bottom: -260, left: -200,
        child: _blob(Vz.accent2.withValues(alpha: Vz.isDark ? 0.16 : 0.26)),
      ),
      if (anim != null)
        Positioned(
          top: 120, left: -120,
          child: _movingBlob(anim, Vz.accent2.withValues(alpha: Vz.isDark ? 0.10 : 0.18)),
        ),
      widget.child,
    ]);

    return DecoratedBox(
      decoration: decoration,
      child: anim == null ? content : RepaintBoundary(child: content),
    );
  }

  Widget _blob(Color color) => IgnorePointer(
    child: Container(
      width: 520, height: 520,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    ),
  );

  /// هاله‌ی سوم که آرام بالا/پایین می‌رود — با کلید انیمیشن هماهنگ است.
  Widget _movingBlob(AnimationController c, Color color) => IgnorePointer(
    child: AnimatedBuilder(
      animation: c,
      builder: (ctx, _) {
        final t = Curves.easeInOut.transform(c.value);
        return Transform.translate(
          offset: Offset(60 * (t * 2 - 1), 90 * (t * 2 - 1)),
          child: Container(
            width: 420, height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
            ),
          ),
        );
      },
    ),
  );
}

/// خط اسکن افقی — انیمیشن ریز در هدرهای فعال
class VzScanLine extends StatefulWidget {
  final double height;
  final Color color;
  const VzScanLine({super.key, this.height = 2, this.color = Colors.transparent});
  @override
  State<VzScanLine> createState()=>_VzScanLineState();
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
                widget.color.withValues(alpha: 0),widget.color.withValues(alpha: 0.55),widget.color.withValues(alpha: 0)]),
            )),
          ),
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
  final scheme = ColorScheme(
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: Vz.accent,
    onPrimary: Vz.onAccent,
    secondary: Vz.accentHi,
    onSecondary: Vz.onAccent,
    surface: Vz.surface,
    onSurface: Vz.text,
    error: Vz.red,
    onError: Colors.white,
  );
  final rSm = Rad.r(Rad.sm);
  final rLg = Rad.r(Rad.lg);
  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: scheme,
    // پس‌زمینه شفاف تا گرادیانِ VzAmbientBg از پشت دیده شود
    scaffoldBackgroundColor: Vz.bgMode == VzBgMode.off ? Vz.bg : Colors.transparent,
    canvasColor: Vz.bg,
    splashColor: Vz.accent.withValues(alpha: 0.10),
    highlightColor: Vz.accent.withValues(alpha: 0.05),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0, scrolledUnderElevation: 0,
      foregroundColor: Vz.text,
      centerTitle: false,
      systemOverlayStyle: _overlay(dark),
      titleTextStyle: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700,
        letterSpacing: -0.3, color: Vz.text,
      ),
      iconTheme: IconThemeData(color: Vz.text),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Vz.surface,
      modalBackgroundColor: Vz.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.s(Rad.xl))),
      ),
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
        (s) => s.contains(WidgetState.selected) ? Vz.accent : Vz.mauve),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? Vz.accent.withValues(alpha: 0.35) : Vz.cardHi),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Vz.card,
      side: BorderSide(color: Vz.border, width: 1),
      labelStyle: TextStyle(fontSize: 12, color: Vz.text),
      shape: RoundedRectangleBorder(borderRadius: rSm),
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: Vz.accent,
      labelColor: Vz.text,
      unselectedLabelColor: Vz.textDim,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    ),
    dividerColor: Vz.border,
    dividerTheme: DividerThemeData(color: Vz.border, thickness: 1, space: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: Vz.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Vz.text),
      shape: RoundedRectangleBorder(borderRadius: rLg),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 2),
      iconColor: Vz.textSec,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Vz.card,
      hintStyle: TextStyle(color: Vz.textDim, fontSize: 13),
      border: OutlineInputBorder(borderRadius: rSm, borderSide: BorderSide(color: Vz.border)),
      enabledBorder: OutlineInputBorder(borderRadius: rSm, borderSide: BorderSide(color: Vz.border)),
      focusedBorder: OutlineInputBorder(borderRadius: rSm, borderSide: BorderSide(color: Vz.accent, width: 1.4)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Vz.cardHi,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: rSm),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Vz.accent,
      foregroundColor: Vz.onAccent,
      elevation: 0, focusElevation: 0, hoverElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: rSm),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Vz.accent,
        foregroundColor: Vz.onAccent,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: rSm),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Vz.text,
        side: BorderSide(color: Vz.borderHi),
        shape: RoundedRectangleBorder(borderRadius: rSm),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Vz.accent),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Vz.cardHi,
      contentTextStyle: TextStyle(color: Vz.text, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: rSm,
        side: BorderSide(color: Vz.border),
      ),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: Vz.cardHi, borderRadius: BorderRadius.circular(8)),
      textStyle: TextStyle(fontSize: 11, color: Vz.text),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Vz.accent, linearTrackColor: Vz.cardHi,
    ),
    iconTheme: IconThemeData(color: Vz.text),
    textTheme: TextTheme(
      titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2, color: Vz.text),
      bodySmall: TextStyle(color: Vz.textSec),
    ),
  );
}
