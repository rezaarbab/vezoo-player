// lib/theme.dart — Vezoo Design System v4 "NOVA"
// Dark immersive • media-first • aurora accents • glass surfaces
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COLOR SYSTEM — Obsidian & Aurora
// ─────────────────────────────────────────────────────────────────────────────
class Vz {
  // Obsidian base — deep near-black with cool violet undertone
  static const bg       = Color(0xFF0B0B10);   // canvas
  static const bgDeep   = Color(0xFF07070B);   // behind everything
  static const surface  = Color(0xFF131319);   // sheets / nav
  static const card     = Color(0xFF1A1A23);   // cards
  static const cardHi   = Color(0xFF22222E);   // hover / active card
  static const border   = Color(0xFF2A2A38);   // hairline stroke
  static const borderHi = Color(0xFF3A3A4C);   // emphasized stroke

  // Aurora accents
  static const accent   = Color(0xFF8B5CF6);   // violet — primary
  static const accentHi = Color(0xFFA78BFA);   // light violet
  static const magenta  = Color(0xFFEC4899);   // magenta — secondary energy
  static const deep     = Color(0xFF6D28D9);   // deep violet

  // Semantic
  static const green    = Color(0xFF34D399);   // success / watched
  static const amber    = Color(0xFFFBBF24);   // warning / bookmark
  static const red      = Color(0xFFF87171);   // error / destructive
  static const mauve    = Color(0xFF9CA0B4);   // neutral

  // Text
  static const text     = Color(0xFFF4F4F8);
  static const textSec  = Color(0xFF9CA0B4);
  static const textDim  = Color(0xFF5C5F73);

  // Gradients
  static const auroraGrad = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const accentGrad = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const heroGrad = LinearGradient(
    colors: [Color(0xFF2A1E4A), Color(0xFF16122A), Color(0xFF0B0B10)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  // scrim روی thumbnail برای خوانایی متن
  static const scrimGrad = LinearGradient(
    begin: Alignment.bottomCenter, end: Alignment.topCenter,
    colors: [Color(0xE60B0B10), Color(0x800B0B10), Color(0x000B0B10)],
    stops: [0.0, 0.45, 1.0],
  );

  // Elevation — سایه‌های ملایم
  static const glow = BoxShadow(
    color: Color(0x338B5CF6), blurRadius: 28, offset: Offset(0, 8),
  );
  static const glowSoft = BoxShadow(
    color: Color(0x1F8B5CF6), blurRadius: 18, offset: Offset(0, 4),
  );
  static const shadow = BoxShadow(
    color: Color(0x29000000), blurRadius: 24, offset: Offset(0, 6),
  );
  static const amberGlow = BoxShadow(
    color: Color(0x2EFBBF24), blurRadius: 20, offset: Offset(0, 6),
  );
  static const redGlow = BoxShadow(
    color: Color(0x33F87171), blurRadius: 20, offset: Offset(0, 6),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SPACING — ۴pt scale
// ─────────────────────────────────────────────────────────────────────────────
abstract final class Sp {
  static const xs = 4.0, sm = 8.0, md = 12.0;
  static const lg = 16.0, xl = 20.0, xxl = 24.0;
  static const xxxl = 32.0, huge = 40.0, giant = 56.0;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHAPES — radius system
// ─────────────────────────────────────────────────────────────────────────────
abstract final class Rad {
  static const xs = 10.0, sm = 14.0, md = 18.0;
  static const lg = 24.0, xl = 28.0, full = 999.0;
  // کارت‌های media 20، sheetها 28، دکمه 14، chip full
}

// ─────────────────────────────────────────────────────────────────────────────
//  TYPOGRAPHY — scale واحد
// ─────────────────────────────────────────────────────────────────────────────
abstract final class Ty {
  static const display = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Vz.text, height: 1.15);
  static const title   = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: Vz.text, height: 1.2);
  static const heading = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: Vz.text, height: 1.3);
  static const body    = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.0, color: Vz.text, height: 1.45);
  static const bodySec = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.0, color: Vz.textSec, height: 1.45);
  static const label   = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: Vz.text, height: 1.3);
  static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Vz.textSec, height: 1.3);
  static const overline= TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Vz.textDim, height: 1.2);
  static const mono    = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Vz.text, height: 1.2, fontFeatures: [FontFeature.tabularFigures()]);
}

// ─────────────────────────────────────────────────────────────────────────────
//  MOTION — durations & curves
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

/// پس‌زمینه محیطی NOVA:
/// سیاه عمیق + دو هاله aurora خیلی ملایم (بدون گرید فنی، بدون scan line)
class VzAmbientBg extends StatelessWidget {
  final Widget child;
  const VzAmbientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Vz.bg),
      child: Stack(children: [
        // هاله بنفش بالا-چپ — نفس aurora
        Positioned(left: -160, top: -180, child: _blob(const Color(0x268B5CF6), 460)),
        // هاله سرخابی پایین-راست
        Positioned(right: -180, bottom: -200, child: _blob(const Color(0x1FEC4899), 480)),
        child,
      ]),
    );
  }

  Widget _blob(Color color, double size) => IgnorePointer(
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    ),
  );
}

/// موتیف آرام Aurora Line — خط گرادیانی متحرک برای هدرهای برند
class VzScanLine extends StatefulWidget {
  final double height;
  final Color color;
  const VzScanLine({super.key, this.height = 2, this.color = Vz.accentHi});
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
                widget.color.withOpacity(0),widget.color.withOpacity(0.55),widget.color.withOpacity(0)])),
            )),
        ]));
      });
    });
  }
}

ThemeData buildVezooTheme() {
  const scheme = ColorScheme.dark(
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
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: Vz.bg,
    canvasColor: Vz.bg,
    splashColor: Vz.accent.withOpacity(0.10),
    highlightColor: Vz.accent.withOpacity(0.05),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0, scrolledUnderElevation: 0,
      foregroundColor: Vz.text,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700,
        letterSpacing: -0.3, color: Vz.text,
      ),
      iconTheme: IconThemeData(color: Vz.text),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Vz.surface,
      modalBackgroundColor: Vz.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.xl)),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Vz.accent,
      inactiveTrackColor: Color(0x22F4F4F8),
      thumbColor: Colors.white,
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
      backgroundColor: Vz.card,
      side: BorderSide(color: Vz.border, width: 0.6),
      labelStyle: TextStyle(fontSize: 12, color: Vz.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Rad.full))),
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: Vz.accent,
      labelColor: Vz.text,
      unselectedLabelColor: Vz.textDim,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    ),
    dividerColor: Vz.border.withOpacity(0.55),
    dialogTheme: const DialogThemeData(
      backgroundColor: Vz.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Vz.text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Rad.lg)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 2),
      iconColor: Vz.textSec,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Vz.card.withOpacity(0.75),
      hintStyle: const TextStyle(color: Vz.textDim, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rad.sm),
        borderSide: const BorderSide(color: Vz.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rad.sm),
        borderSide: const BorderSide(color: Vz.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rad.sm),
        borderSide: const BorderSide(color: Vz.accent, width: 1.2),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Vz.cardHi,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Rad.md)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Vz.accent,
      foregroundColor: Colors.white,
      elevation: 0, focusElevation: 0, hoverElevation: 0,
      shape: RoundedRectangleBorder(
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
        side: const BorderSide(color: Vz.borderHi),
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
      contentTextStyle: const TextStyle(color: Vz.text, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rad.sm),
        side: BorderSide(color: Vz.border.withOpacity(0.8)),
      ),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
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
      titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2, color: Vz.text),
      bodySmall: TextStyle(color: Vz.textSec),
    ),
  );
}
