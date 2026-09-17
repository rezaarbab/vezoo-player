// lib/ink/ink_tokens.dart
// INK — a design language written from scratch for Vezoo.
// Deliberately independent from the legacy Vz/NOVA tokens: no imports of theme.dart.
//
// Visual rules of INK:
//   • paper-first, flat surfaces, no glass, no blur, no glow
//   • sharp geometry (2–10 px radii), 1.4 px ink outlines
//   • hard offset shadows (zero blur) instead of soft elevation
//   • uppercase micro-labels with wide tracking for meta text
import 'package:flutter/material.dart';

/// 4-pt spacing scale.
class InkSp {
  const InkSp._();
  static const double x1 = 4, x2 = 8, x3 = 12, x4 = 16, x5 = 20, x6 = 28, x7 = 40;
}

/// Radius scale — intentionally sharp.
class InkRad {
  const InkRad._();
  static const double sharp = 2, card = 10, pill = 999;
}

/// Type scale. Colors are applied per-widget with `copyWith` so the same
/// style object works on paper and on carbon.
class InkType {
  const InkType._();
  static const display = TextStyle(
      fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1.2, height: 1.04);
  static const title = TextStyle(
      fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.6);
  static const heading = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2);
  static const body = TextStyle(fontSize: 14, height: 1.45);
  static const label = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
  /// Uppercase meta text ("12 FILES", "SORT BY DATE").
  static const micro = TextStyle(
      fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.6);
  /// Tabular numbers for counters and durations.
  static const mono = TextStyle(
      fontSize: 12, fontFamily: 'monospace', letterSpacing: 0.2);
}

class _Paper {
  const _Paper._();
  static const canvas = Color(0xFFF6F1E7);
  static const sheet = Color(0xFFFFFDF8);
  static const ink = Color(0xFF16130F);
  static const inkSoft = Color(0xFF4A443A);
  static const inkFaint = Color(0xFF8A8172);
  static const rule = Color(0xFF16130F);
  static const accent = Color(0xFFC2410C);
  static const accentInk = Color(0xFFFFF8F2);
  static const accentSoft = Color(0xFFFBE3D1);
  static const ok = Color(0xFF166534);
  static const warn = Color(0xFFB45309);
  static const danger = Color(0xFFB91C1C);
  static const shadow = Color(0x2E16130F);
  static const hatch = Color(0x1416130F);
}

class _Carbon {
  const _Carbon._();
  static const canvas = Color(0xFF111110);
  static const sheet = Color(0xFF1C1A17);
  static const ink = Color(0xFFF5F1E8);
  static const inkSoft = Color(0xFFC9C2B4);
  static const inkFaint = Color(0xFF8B8477);
  static const rule = Color(0xFFF5F1E8);
  static const accent = Color(0xFFF97316);
  static const accentInk = Color(0xFF1A0F05);
  static const accentSoft = Color(0xFF3A2313);
  static const ok = Color(0xFF4ADE80);
  static const warn = Color(0xFFFCD34D);
  static const danger = Color(0xFFF87171);
  static const shadow = Color(0x80000000);
  static const hatch = Color(0x14F5F1E8);
}

/// Runtime INK palette. Switch with [setDark] (the app rebuilds through
/// [inkNotifier]).
class Ink {
  const Ink._();

  static bool _dark = false;
  static bool get isDark => _dark;
  static void setDark(bool value) {
    if (_dark == value) return;
    _dark = value;
    inkNotifier.value = value;
  }

  static Color get canvas => _dark ? _Carbon.canvas : _Paper.canvas;
  static Color get sheet => _dark ? _Carbon.sheet : _Paper.sheet;
  static Color get ink => _dark ? _Carbon.ink : _Paper.ink;
  static Color get inkSoft => _dark ? _Carbon.inkSoft : _Paper.inkSoft;
  static Color get inkFaint => _dark ? _Carbon.inkFaint : _Paper.inkFaint;
  static Color get accent => _dark ? _Carbon.accent : _Paper.accent;
  static Color get accentInk => _dark ? _Carbon.accentInk : _Paper.accentInk;
  static Color get accentSoft => _dark ? _Carbon.accentSoft : _Paper.accentSoft;
  static Color get ok => _dark ? _Carbon.ok : _Paper.ok;
  static Color get warn => _dark ? _Carbon.warn : _Paper.warn;
  static Color get danger => _dark ? _Carbon.danger : _Paper.danger;

  /// Hairline drawn at 16% — INK borders are visible but never heavy on text.
  static Color get rule =>
      (_dark ? _Carbon.rule : _Paper.rule).withValues(alpha: 0.16);
  /// Stronger outline used on interactive outlines and focus rings.
  static Color get ruleStrong =>
      (_dark ? _Carbon.rule : _Paper.rule).withValues(alpha: 0.42);
  static Color get hatch => _dark ? _Carbon.hatch : _Paper.hatch;

  /// Hard shadow: zero blur, zero spread, pure offset.
  static List<BoxShadow> get hardShadow =>
      [BoxShadow(color: _dark ? _Carbon.shadow : _Paper.shadow,
          offset: const Offset(3, 3), blurRadius: 0, spreadRadius: 0)];
  /// Pressed/active state flattens the offset.
  static List<BoxShadow> get noShadow => const [];
}

/// Rebuild signal for [Ink.setDark].
final ValueNotifier<bool> inkNotifier = ValueNotifier<bool>(false);

/// Material theme for the INK language. Flat, square-ish, ink-outlined.
ThemeData inkThemeData({required bool dark}) {
  final palette = dark
      ? (canvas: _Carbon.canvas, sheet: _Carbon.sheet, ink: _Carbon.ink,
         soft: _Carbon.inkSoft, faint: _Carbon.inkFaint, accent: _Carbon.accent,
         accentInk: _Carbon.accentInk)
      : (canvas: _Paper.canvas, sheet: _Paper.sheet, ink: _Paper.ink,
         soft: _Paper.inkSoft, faint: _Paper.inkFaint, accent: _Paper.accent,
         accentInk: _Paper.accentInk);
  final rule = palette.ink.withValues(alpha: 0.16);
  final scheme = ColorScheme.fromSeed(
    seedColor: palette.accent,
    brightness: dark ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: palette.accent,
    onPrimary: palette.accentInk,
    surface: palette.sheet,
    onSurface: palette.ink,
    outline: rule,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.canvas,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: palette.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: palette.ink,
      titleTextStyle: InkType.heading.copyWith(color: palette.ink),
      shape: Border(bottom: BorderSide(color: rule, width: 1.4)),
    ),
    dividerTheme: DividerThemeData(color: rule, thickness: 1.4, space: 1.4),
    cardTheme: CardThemeData(
      color: palette.sheet,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(InkRad.card)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.sheet,
      hintStyle: InkType.body.copyWith(color: palette.faint),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: InkSp.x3, vertical: InkSp.x3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InkRad.sharp),
        borderSide: BorderSide(color: rule, width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InkRad.sharp),
        borderSide: BorderSide(color: rule, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InkRad.sharp),
        borderSide: BorderSide(color: palette.accent, width: 1.8),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.accent,
        foregroundColor: palette.accentInk,
        elevation: 0,
        textStyle: InkType.label,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(InkRad.sharp)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.ink,
        side: BorderSide(color: palette.ink.withValues(alpha: 0.42), width: 1.4),
        textStyle: InkType.label,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(InkRad.sharp)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.accent, textStyle: InkType.label),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.sheet,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(InkRad.card)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.sheet,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(InkRad.card)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.ink,
      contentTextStyle: InkType.body.copyWith(color: palette.sheet),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(InkRad.sharp)),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: palette.accent,
      linearTrackColor: palette.ink.withValues(alpha: 0.12),
      circularTrackColor: palette.ink.withValues(alpha: 0.12),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? palette.accentInk : palette.faint),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? palette.accent
              : palette.ink.withValues(alpha: 0.12)),
      trackOutlineColor: WidgetStatePropertyAll(
          palette.ink.withValues(alpha: 0.42)),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: palette.soft,
      textColor: palette.ink,
      contentPadding: const EdgeInsets.symmetric(horizontal: InkSp.x3),
    ),
    textTheme: TextTheme(
      titleMedium: InkType.heading.copyWith(color: palette.ink),
      bodyMedium: InkType.body.copyWith(color: palette.soft),
      bodySmall: InkType.label.copyWith(color: palette.soft),
    ),
    iconTheme: IconThemeData(color: palette.ink),
  );
}