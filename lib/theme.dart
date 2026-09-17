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

// ─────────────────────────────────────────────────────────────────────────────
//  THEME MODE
// ─────────────────────────────────────────────────────────────────────────────
enum VzThemeMode { system, dark, light }

// ─────────────────────────────────────────────────────────────────────────────
//  PALETTE — VOID (dark) / DAYLIGHT (light)
// ─────────────────────────────────────────────────────────────────────────────
class _P {
  // VOID base — neutral near-black, no color cast
  static const bg       = Color(0xFF0A0A0C);
  static const bgDeep   = Color(0xFF050507);
  static const surface  = Color(0xFF121216);
  static const card     = Color(0xFF17171C);
  static const cardHi   = Color(0xFF1F1F26);
  static const border   = Color(0xFF26262E);
  static const borderHi = Color(0xFF33333D);

  // Single accent — amber. `magenta`/`deep` kept as secondary hues for
  // favourites and warnings so old call sites still resolve.
  static const accent   = Color(0xFFF59E0B);
  static const accentHi = Color(0xFFFBBF24);
  static const magenta  = Color(0xFFFB7185);
  static const deep     = Color(0xFFB45309);

  // Semantic
  static const green    = Color(0xFF4ADE80);
  static const amber    = Color(0xFFFBBF24);
  static const red      = Color(0xFFF87171);
  static const mauve    = Color(0xFF71717A);

  // Text
  static const text     = Color(0xFFF5F5F7);
  static const textSec  = Color(0xFFA1A1AA);
  static const textDim  = Color(0xFF6B6B76);

  // Scrim on media thumbnails (identical in both modes)
  static const scrimTop = Color(0x000A0A0C);
  static const scrimMid = Color(0x800A0A0C);
  static const scrimBot = Color(0xE60A0A0C);

  // Overlays
  static const glassCard = Color(0xF217171C);
  static const glassDark = Color(0x66000000);
  static const glassLine = Color(0x1FFFFFFF);
  static const dockFill  = Color(0xF5121216);
  static const badgeBg   = Color(0xB3000000);
  static const sheen     = Color(0x0AFFFFFF);

  static const hero1 = Color(0xFF1A1A20);
  static const hero2 = Color(0xFF101014);
}

class _L {
  // DAYLIGHT base — clean neutral paper
  static const bg       = Color(0xFFF6F6F8);
  static const bgDeep   = Color(0xFFEDEDF1);
  static const surface  = Color(0xFFFFFFFF);
  static const card     = Color(0xFFFFFFFF);
  static const cardHi   = Color(0xFFF1F1F4);
  static const border   = Color(0xFFE3E3E8);
  static const borderHi = Color(0xFFCFCFD6);

  static const accent   = Color(0xFFB45309);
  static const accentHi = Color(0xFFD97706);
  static const magenta  = Color(0xFFE11D48);
  static const deep     = Color(0xFF92400E);

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

  static const glassCard = Color(0xF7FFFFFF);
  static const glassDark = Color(0x33000000);
  static const glassLine = Color(0x14000000);
  static const dockFill  = Color(0xF7FFFFFF);
  static const badgeBg   = Color(0xB3000000);
  static const sheen     = Color(0x08000000);

  static const hero1 = Color(0xFFE9E9EF);
  static const hero2 = Color(0xFFF6F6F8);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Vz — runtime palette. Resolves dark/light at build time.
// ─────────────────────────────────────────────────────────────────────────────
class Vz {
  Vz._();

  static bool _dark = true;

  /// Whether the active palette is dark. Set by VzTheme before first frame.
  static bool get isDark => _dark;

  /// Internal: called by VzTheme / buildVezooTheme before building.
  static void _setDark(bool v) { _dark = v; }

  // ── base ──
  static Color get bg       => _dark ? _P.bg       : _L.bg;
  static Color get bgDeep   => _dark ? _P.bgDeep   : _L.bgDeep;
  static Color get surface  => _dark ? _P.surface  : _L.surface;
  static Color get card     => _dark ? _P.card     : _L.card;
  static Color get cardHi   => _dark ? _P.cardHi   : _L.cardHi;
  static Color get border   => _dark ? _P.border   : _L.border;
  static Color get borderHi => _dark ? _P.borderHi : _L.borderHi;

  // ── accents ──
  static Color get accent   => _dark ? _P.accent   : _L.accent;
  static Color get accentHi => _dark ? _P.accentHi : _L.accentHi;
  static Color get magenta  => _dark ? _P.magenta  : _L.magenta;
  static Color get deep     => _dark ? _P.deep     : _L.deep;

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
  static Color get glassCard => _dark ? _P.glassCard : _L.glassCard;
  static Color get glassDark => _dark ? _P.glassDark : _L.glassDark;
  static Color get glassLine => _dark ? _P.glassLine : _L.glassLine;
  static Color get dockFill  => _dark ? _P.dockFill  : _L.dockFill;
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
    colors: [accentHi, accent, _dark ? _P.deep : _L.deep],
    stops: const [0.0, 0.55, 1.0],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static LinearGradient get accentGrad => LinearGradient(
    colors: [accentHi, accent],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  /// Flat cinematic wash for headers/hero areas.
  static LinearGradient get heroGrad => LinearGradient(
    colors: [_dark ? _P.hero1 : _L.hero1, _dark ? _P.hero2 : _L.hero2, bg],
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
    color: accent.withOpacity(0.22), blurRadius: 24, offset: const Offset(0, 8),
  );
  static BoxShadow get glowSoft => BoxShadow(
    color: accent.withOpacity(0.14), blurRadius: 14, offset: const Offset(0, 4),
  );
  static BoxShadow get shadow => BoxShadow(
    color: (_dark ? const Color(0xFF000000) : const Color(0xFF6B6480)).withOpacity(0.18),
    blurRadius: 20, offset: const Offset(0, 6),
  );
  static BoxShadow get amberGlow => BoxShadow(
    color: amber.withOpacity(0.20), blurRadius: 18, offset: const Offset(0, 6),
  );
  static BoxShadow get redGlow => BoxShadow(
    color: red.withOpacity(0.20), blurRadius: 18, offset: const Offset(0, 6),
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
abstract final class Rad {
  static const xs = 10.0, sm = 14.0, md = 18.0;
  static const lg = 24.0, xl = 28.0, full = 999.0;
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
// ─────────────────────────────────────────────────────────────────────────────
abstract final class Mo {
  static const press = Duration(milliseconds: 150);
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 280);
  static const sheet = Duration(milliseconds: 320);
  static const easeOut = Curves.easeOut;
  static const decel = Curves.decelerate;
  static const emphasized = Curves.easeOutCubic;
}

// ─────────────────────────────────────────────────────────────────────────────
//  VzTheme - InheritedWidget bridging mode changes to the Vz getters
// ─────────────────────────────────────────────────────────────────────────────
class VzThemeScope extends InheritedWidget {
  const VzThemeScope({
    super.key,
    required this.isDark,
    required this.mode,
    required super.child,
  });

  /// Snapshot of dark mode captured at build time — dependents rebuild on change.
  final bool isDark;

  /// Snapshot of the user's chosen mode (system/dark/light).
  final VzThemeMode mode;

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

  @override
  bool updateShouldNotify(VzThemeScope oldWidget) =>
      isDark != oldWidget.isDark || mode != oldWidget.mode;
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

  VzThemeMode get mode => _mode;

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

  bool get _isDarkNow {
    if (_mode != VzThemeMode.system) return _mode == VzThemeMode.dark;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final dark = _isDarkNow;
    Vz._setDark(dark);
    return VzThemeScope(isDark: dark, mode: _mode, child: widget.child);
  }
}

/// Hook set by Store so theme.dart stays free of package imports.
/// (main.dart wires these to SharedPreferences)
Future<String?> Function()? storeThemePrefs;
Future<void> Function(String)? storeThemeSave;

// ─────────────────────────────────────────────────────────────────────────────
//  AMBIENT BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────
/// پس‌زمینه VOID: پایه‌ی تیره + یک هاله‌ی بسیار ملایم accent در بالا.
/// عمداً ساده و بدون blur — روی دستگاه‌های ضعیف هم روان می‌ماند.
class VzAmbientBg extends StatelessWidget {
  final Widget child;
  const VzAmbientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Vz.bg),
      child: Stack(children: [
        Positioned(
          top: -240, right: -180,
          child: IgnorePointer(
            child: Container(
              width: 520, height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Vz.accent.withOpacity(Vz.isDark ? 0.07 : 0.05),
                  Vz.accent.withOpacity(0),
                ]),
              ),
            ),
          ),
        ),
        child,
      ]),
    );
  }
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
                widget.color.withOpacity(0),widget.color.withOpacity(0.55),widget.color.withOpacity(0)]),
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
    onPrimary: dark ? const Color(0xFF1A1203) : Colors.white,
    secondary: Vz.accentHi,
    onSecondary: dark ? const Color(0xFF1A1203) : Colors.white,
    surface: Vz.surface,
    onSurface: Vz.text,
    error: Vz.red,
    onError: Colors.white,
  );
  final rSm = BorderRadius.circular(Rad.sm);
  final rLg = BorderRadius.circular(Rad.lg);
  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: Vz.bg,
    canvasColor: Vz.bg,
    splashColor: Vz.accent.withOpacity(0.10),
    highlightColor: Vz.accent.withOpacity(0.05),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.xl)),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Vz.accent,
      inactiveTrackColor: Vz.border,
      thumbColor: Vz.accent,
      overlayColor: Vz.accent.withOpacity(0.14),
      trackHeight: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Vz.accent : Vz.mauve),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? Vz.accent.withOpacity(0.35) : Vz.cardHi),
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
      foregroundColor: dark ? const Color(0xFF1A1203) : Colors.white,
      elevation: 0, focusElevation: 0, hoverElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: rSm),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Vz.accent,
        foregroundColor: dark ? const Color(0xFF1A1203) : Colors.white,
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
