// lib/theme.dart — Vezoo Design System (warm noir / ember / mint palette)
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Vz {
  static const bg       = Color(0xFF050303);
  static const bgDeep   = Color(0xFF030202);
  static const surface  = Color(0xFF120B09);
  static const card     = Color(0xFF1A1210);
  static const cardHi   = Color(0xFF231813);
  static const border   = Color(0xFF33241D);
  static const borderHi = Color(0xFF473228);
  static const accent   = Color(0xFFD64531);   // ember red
  static const accentHi = Color(0xFFE8664F);
  static const rose     = Color(0xFF950707);   // deep red
  static const wine     = Color(0xFF5C100C);   // dark wine
  static const mauve    = Color(0xFF8A6D56);   // caramel
  static const lav      = Color(0xFF30F6C2);   // mint neon
  static const sand     = Color(0xFFA68672);   // warm sand
  static const text     = Color(0xFFEBE8E6);
  static const textSec  = Color(0xFFB8AEA6);
  static const textDim  = Color(0xFF7D7066);
  static const green    = Color(0xFF7FB89A);
  static const amber    = Color(0xFFD99A4E);
  static const red      = Color(0xFFD64531);
  static const pink     = Color(0xFFD66A4A);

  static const heroGrad = LinearGradient(
    colors: [wine, rose, accent],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const accentGrad = LinearGradient(
    colors: [Color(0xFFE8664F), Color(0xFFD64531), Color(0xFF950707)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const mintGrad = LinearGradient(
    colors: [Color(0xFF5CF6D2), Color(0xFF30F6C2)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const glow = BoxShadow(
    color: Color(0x4DD64531), blurRadius: 28, offset: Offset(0, 8),
  );
  static const mintGlow = BoxShadow(
    color: Color(0x3330F6C2), blurRadius: 24, offset: Offset(0, 6),
  );
}

/// پس‌زمینه محیطی — گرمای ملایم قرمز پایین‌صفحه + نفس نعنایی بالا
/// مثل ambient lighting اپ‌های smart-home؛ روی Scaffold.wrap استفاده میشه
class VzAmbientBg extends StatelessWidget {
  final Widget child;
  final bool withBlur;
  const VzAmbientBg({super.key, required this.child, this.withBlur = false});

  @override
  Widget build(BuildContext context) {
    final body = DecoratedBox(
      decoration: const BoxDecoration(color: Vz.bg),
      child: Stack(children: [
        // هاله قرمز پایین-چپ
        Positioned(
          left: -120, bottom: -140,
          child: _blob(const Color(0x2E950707), 380),
        ),
        // هاله نعنایی خیلی ملایم بالا-راست
        Positioned(
          right: -140, top: -160,
          child: _blob(const Color(0x1430F6C2), 340),
        ),
        // هاله مرکزی گرم
        Positioned(
          right: -80, bottom: 80,
          child: _blob(const Color(0x1A5C100C), 300),
        ),
        child,
      ]),
    );
    if (!withBlur) return body;
    return ClipRect(child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 0.001, sigmaY: 0.001), child: body));
  }

  Widget _blob(Color color, double size) => IgnorePointer(
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    ),
  );
}

ThemeData buildVezooTheme() {
  const scheme = ColorScheme.dark(
    primary: Vz.accent,
    onPrimary: Colors.white,
    secondary: Vz.lav,
    onSecondary: Vz.bg,
    surface: Vz.surface,
    onSurface: Vz.text,
    error: Vz.red,
    onError: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: Colors.transparent,
    splashColor: Vz.accent.withOpacity(0.14),
    highlightColor: Vz.accent.withOpacity(0.07),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Vz.accent,
      inactiveTrackColor: Color(0x24EBE8E6),
      thumbColor: Colors.white,
      trackHeight: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
        (s) => s.contains(MaterialState.selected) ? Vz.bg : Vz.mauve),
      trackColor: MaterialStateProperty.resolveWith(
        (s) => s.contains(MaterialState.selected) ? Vz.lav : Vz.cardHi),
      trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Vz.cardHi,
      side: BorderSide(color: Vz.border, width: 0.6),
      labelStyle: TextStyle(fontSize: 12, color: Vz.text),
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: Vz.accent,
      labelColor: Vz.accentHi,
      unselectedLabelColor: Vz.textDim,
      indicatorSize: TabBarIndicatorSize.label,
    ),
    dividerColor: Vz.border.withOpacity(0.55),
    dialogTheme: const DialogThemeData(
      backgroundColor: Vz.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Vz.text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
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
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Vz.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Vz.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Vz.accent, width: 1.2),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Vz.cardHi,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
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
      style: TextButton.styleFrom(foregroundColor: Vz.lav),
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
