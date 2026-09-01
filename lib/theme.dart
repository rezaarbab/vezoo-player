// lib/theme.dart — Vezoo Design System (plum / berry palette)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Vz {
  static const bg       = Color(0xFF140C15);
  static const bgDeep   = Color(0xFF0E080F);
  static const surface  = Color(0xFF1D1220);
  static const card     = Color(0xFF241627);
  static const cardHi   = Color(0xFF2C1B2E);
  static const border   = Color(0xFF3A2537);
  static const borderHi = Color(0xFF4E3049);
  static const accent   = Color(0xFFA26592);
  static const accentHi = Color(0xFFC08CA9);
  static const rose     = Color(0xFF953637);
  static const wine     = Color(0xFF531931);
  static const mauve    = Color(0xFF5D4662);
  static const lav      = Color(0xFFA78BC0);
  static const text     = Color(0xFFE3DDE5);
  static const textSec  = Color(0xFFB4A3B4);
  static const textDim  = Color(0xFF7C6B80);
  static const green    = Color(0xFF7BC49A);
  static const amber    = Color(0xFFE2A65B);
  static const red      = Color(0xFFE06C6C);
  static const pink     = Color(0xFFC76B93);

  static const heroGrad = LinearGradient(
    colors: [wine, rose, accent],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const accentGrad = LinearGradient(
    colors: [accentHi, accent, rose],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const glow = BoxShadow(
    color: Color(0x59A26592), blurRadius: 24, offset: Offset(0, 6),
  );
}

ThemeData buildVezooTheme() {
  const scheme = ColorScheme.dark(
    primary: Vz.accent,
    onPrimary: Colors.white,
    secondary: Vz.lav,
    onSecondary: Colors.white,
    surface: Vz.surface,
    onSurface: Vz.text,
    error: Vz.red,
    onError: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: Vz.bg,
    canvasColor: Vz.bg,
    splashColor: Vz.accent.withOpacity(0.12),
    highlightColor: Vz.accent.withOpacity(0.06),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0, scrolledUnderElevation: 0,
      foregroundColor: Vz.text,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Vz.bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontSize: 17, fontWeight: FontWeight.w700,
        letterSpacing: 0.3, color: Vz.text,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Vz.surface,
      modalBackgroundColor: Vz.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Vz.accent,
      inactiveTrackColor: Color(0x29E3DDE5),
      thumbColor: Colors.white,
      overlayShape: SliderComponentShape.noOverlay,
      trackHeight: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
        (s) => s.contains(MaterialState.selected) ? Colors.white : Vz.mauve),
      trackColor: MaterialStateProperty.resolveWith(
        (s) => s.contains(MaterialState.selected) ? Vz.accent : Vz.cardHi),
      trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Vz.cardHi,
      side: BorderSide(color: Vz.border, width: 0.6),
      labelStyle: TextStyle(fontSize: 12, color: Vz.text),
    ),
    tabBarTheme: const TabBarTheme(
      indicatorColor: Vz.accent,
      labelColor: Vz.accentHi,
      unselectedLabelColor: Vz.textDim,
      indicatorSize: TabBarIndicatorSize.label,
    ),
    dividerColor: Vz.border.withOpacity(0.55),
    dialogTheme: const DialogTheme(
      backgroundColor: Vz.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Vz.text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      iconColor: Vz.textSec,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Vz.cardHi.withOpacity(0.7),
      hintStyle: const TextStyle(color: Vz.textDim, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Vz.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Vz.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Vz.accent, width: 1.2),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Vz.cardHi,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Vz.accent,
      foregroundColor: Colors.white,
      elevation: 0, focusElevation: 0, hoverElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Vz.accent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Vz.text,
        side: const BorderSide(color: Vz.borderHi),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Vz.accentHi),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Vz.cardHi,
      contentTextStyle: const TextStyle(color: Vz.text, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Vz.border.withOpacity(0.8)),
      ),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
    ),
    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(
        color: Vz.cardHi,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      textStyle: TextStyle(fontSize: 11, color: Vz.text),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Vz.accent, linearTrackColor: Vz.cardHi,
    ),
    iconTheme: const IconThemeData(color: Vz.text),
    textTheme: const TextTheme(
      titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2, color: Vz.text),
      bodySmall: TextStyle(color: Vz.textSec),
    ),
  );
}
