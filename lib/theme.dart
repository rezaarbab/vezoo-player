// lib/theme.dart - Vezoo Design System v5 "NOVA Duo"
// Dual-mode: Obsidian dark + Porcelain light + aurora accents + glass surfaces
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  THEME MODE
// ─────────────────────────────────────────────────────────────────────────────
enum VzThemeMode { system, dark, light }

// ─────────────────────────────────────────────────────────────────────────────
//  PALETTES - Obsidian (dark) & Porcelain (light)
// ─────────────────────────────────────────────────────────────────────────────
class _P {
  // Obsidian base - deep near-black with cool violet undertone
  static const bg       = Color(0xFF0B0B10);
  static const bgDeep   = Color(0xFF07070B);
  static const surface  = Color(0xFF131319);
  static const card     = Color(0xFF1A1A23);
  static const cardHi   = Color(0xFF22222E);
  static const border   = Color(0xFF2A2A38);
  static const borderHi = Color(0xFF3A3A4C);

  // Aurora accents
  static const accent   = Color(0xFF8B5CF6);
  static const accentHi = Color(0xFFA78BFA);
  static const magenta  = Color(0xFFEC4899);
  static const deep     = Color(0xFF6D28D9);

  // Semantic
  static const green    = Color(0xFF34D399);
  static const amber    = Color(0xFFFBBF24);
  static const red      = Color(0xFFF87171);
  static const mauve    = Color(0xFF9CA0B4);

  // Text
  static const text     = Color(0xFFF4F4F8);
  static const textSec  = Color(0xFF9CA0B4);
  static const textDim  = Color(0xFF5C5F73);

  // Scrim on media thumbnails
  static const scrimTop = Color(0x000B0B10);
  static const scrimMid = Color(0x800B0B10);
  static const scrimBot = Color(0xE60B0B10);

  // Glass
  static const glassCard = Color(0xB81A1A23); // card @ 72%
  static const glassDark = Color(0x52000000); // player overlay button bg
  static const glassLine = Color(0x24FFFFFF); // white @ 14%
  static const dockFill  = Color(0xE0131319); // surface @ 88%
  static const badgeBg   = Color(0x8C000000); // black @ 55%
  static const sheen     = Color(0x14FFFFFF); // inner highlight

  static const hero1 = Color(0xFF2A1E4A);
  static const hero2 = Color(0xFF16122A);
}

class _L {
  // Porcelain base - warm paper white with violet undertone
  static const bg       = Color(0xFFF7F5FB);
  static const bgDeep   = Color(0xFFEFEDF6);
  static const surface  = Color(0xFFFFFFFF);
  static const card     = Color(0xFFFFFFFF);
  static const cardHi   = Color(0xFFF1EEF9);
  static const border   = Color(0xFFE4E1EE);
  static const borderHi = Color(0xFFCFCADF);

  // Aurora accents - saturated for light bg
  static const accent   = Color(0xFF7C3AED);
  static const accentHi = Color(0xFF8B5CF6);
  static const magenta  = Color(0xFFDB2777);
  static const deep     = Color(0xFF6D28D9);

  // Semantic
  static const green    = Color(0xFF059669);
  static const amber    = Color(0xFFD97706);
  static const red      = Color(0xFFDC2626);
  static const mauve    = Color(0xFF64748B);

  // Text
  static const text     = Color(0xFF171522);
  static const textSec  = Color(0xFF5D5A6E);
  static const textDim  = Color(0xFF9A97AB);

  // Scrim on media thumbnails (same dark scrim works on both)
  static const scrimTop = Color(0x000B0B10);
  static const scrimMid = Color(0x800B0B10);
  static const scrimBot = Color(0xE60B0B10);

  // Glass
  static const glassCard = Color(0xD9FFFFFF); // white @ 85%
  static const glassDark = Color(0x2E0F0B1A);  // dark overlay for media controls
  static const glassLine = Color(0x1F171522);  // ink @ 12%
  static const dockFill  = Color(0xE6FFFFFF);  // white @ 90%
  static const badgeBg   = Color(0x8C000000);
  static const sheen     = Color(0x0A171522);

  static const hero1 = Color(0xFFEDE9F8);
  static const hero2 = Color(0xFFF7F5FB);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Vz - runtime palette. Resolves dark/light at build time.
// ─────────────────────────────────────────────────────────────────────────────
class Vz {
  Vz._();

  // ── runtime state ──
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

  // ── glass ──
  static Color get glassCard => _dark ? _P.glassCard : _L.glassCard;
  static Color get glassDark => _dark ? _P.glassDark : _L.glassDark;
  static Color get glassLine => _dark ? _P.glassLine : _L.glassLine;
  static Color get dockFill  => _dark ? _P.dockFill  : _L.dockFill;
  static Color get badgeBg   => _dark ? _P.badgeBg   : _L.badgeBg;
  static Color get sheen     => _dark ? _P.sheen     : _L.sheen;

  // ── OVI: overlay-video palette — ALWAYS dark, for player surfaces on top of video.
  // Player must never follow light theme (it sits on dark video content).
  static const oviBg      = Color(0xFF07070B);
  static const oviSurface = Color(0xFF131319);
  static const oviCard    = Color(0xFF1A1A23);
  static const oviCardHi  = Color(0xFF22222E);
  static const oviBorder  = Color(0xFF2A2A38);
  static const oviText    = Color(0xFFF4F4F8);
  static const oviTextSec = Color(0xFF9CA0B4);
  static const oviTextDim = Color(0xFF5C5F73);

  // ── gradients ──
  static LinearGradient get auroraGrad => LinearGradient(
    colors: [accentHi, accent, magenta],
    stops: const [0.0, 0.55, 1.0],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static LinearGradient get accentGrad => LinearGradient(
    colors: [accentHi, accent],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
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
    color: accent.withOpacity(0.20), blurRadius: 28, offset: const Offset(0, 8),
  );
  static BoxShadow get glowSoft => BoxShadow(
    color: accent.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 4),
  );
  static BoxShadow get shadow => BoxShadow(
    color: (_dark ? const Color(0xFF000000) : const Color(0xFF6B6480)).withOpacity(0.16),
    blurRadius: 24, offset: const Offset(0, 6),
  );
  static BoxShadow get amberGlow => BoxShadow(
    color: amber.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 6),
  );
  static BoxShadow get redGlow => BoxShadow(
    color: red.withOpacity(0.20), blurRadius: 20, offset: const Offset(0, 6),
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
  const VzThemeScope({super.key, required this.isDark, required super.child});

  /// Snapshot of dark mode captured at build time — dependents rebuild on change.
  final bool isDark;

  static bool of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<VzThemeScope>();
    return w?.isDark ?? Vz.isDark;
  }

  @override
  bool updateShouldNotify(VzThemeScope oldWidget) => isDark != oldWidget.isDark;
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
    return VzThemeScope(isDark: dark, child: widget.child);
  }
}

/// Hook set by Store so theme.dart stays free of package imports.
/// (main.dart wires these to SharedPreferences)
Future<String?> Function()? storeThemePrefs;
Future<void> Function(String)? storeThemeSave;

// ─────────────────────────────────────────────────────────────────────────────
//  AMBIENT BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────
/// پس‌زمینه محیطی NOVA: پایه‌ی تم + دو حباب aurora در گوشه‌ها
class VzAmbientBg extends StatelessWidget {
  final Widget child;
  const VzAmbientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Vz.bg),
      child: Stack(children: [
        Positioned(left: -160, top: -180, child: _blob(Vz.accent.withOpacity(0.15))),
        Positioned(right: -180, bottom: -200, child: _blob(Vz.magenta.withOpacity(0.12))),
        child,
      ]),
    );
  }

  Widget _blob(Color color) => IgnorePointer(
    child: Container(
      width: 460, height: 460,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    ),
  );
}

/// خط اسکن Aurora - انیمیشن ریز در هدرهای فعال
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
                widget.color.withOpacity(0),widget.color.withOpacity(0.55),widget.color.withOpacity(0)])),
            )),
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
    onPrimary: Colors.white,
    secondary: Vz.magenta,
    onSecondary: Colors.white,
    surface: Vz.surface,
    onSurface: Vz.text,
    error: Vz.red,
    onError: Colors.white,
  );
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
    sliderTheme: const SliderThemeData(
      activeTrackColor: null,
      inactiveTrackColor: Color(0x22F4F4F8),
      thumbColor: Colors.white,
      trackHeight: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : Vz.mauve),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Vz.accent : Vz.cardHi),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Vz.card,
      side: BorderSide(color: Vz.border, width: 0.6),
      labelStyle: TextStyle(fontSize: 12, color: Vz.text),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Rad.full))),
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: Vz.accent,
      labelColor: Vz.text,
      unselectedLabelColor: Vz.textDim,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    ),
    dividerColor: Vz.border.withOpacity(0.55),
    dialogTheme: DialogThemeData(
      backgroundColor: Vz.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Vz.text),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Rad.lg)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 2),
      iconColor: Vz.textSec,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Vz.card.withOpacity(0.75),
      hintStyle: TextStyle(color: Vz.textDim, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rad.sm),
        borderSide: BorderSide(color: Vz.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rad.sm),
        borderSide: BorderSide(color: Vz.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rad.sm),
        borderSide: BorderSide(color: Vz.accent, width: 1.2),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Vz.cardHi,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Rad.md)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Vz.accent,
      foregroundColor: Colors.white,
      elevation: 0, focusElevation: 0, hoverElevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Rad.lg)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Vz.accent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Rad.sm)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Vz.text,
        side: BorderSide(color: Vz.borderHi),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Rad.sm)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Vz.accentHi),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Vz.cardHi,
      contentTextStyle: TextStyle(color: Vz.text, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rad.sm),
        side: BorderSide(color: Vz.border.withOpacity(0.8)),
      ),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Vz.cardHi,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
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
