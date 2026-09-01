// lib/theme.dart — Vezoo Design System v3 "Carbon Scanner"
// Glass-Tech: کاربن مشکی + گرید فنی + سبز Diagnostic + کهربایی Audit
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Vz {
  static const bg       = Color(0xFF070908);   // کاربن
  static const bgDeep   = Color(0xFF050605);
  static const surface  = Color(0xFF0E1210);
  static const card     = Color(0xFF141A17);
  static const cardHi   = Color(0xFF1B231F);
  static const border   = Color(0xFF26322C);
  static const borderHi = Color(0xFF36453D);
  static const accent   = Color(0xFF35F2A2);   // Diagnostic Green
  static const accentHi = Color(0xFF5CF6C2);
  static const deep     = Color(0xFF1F8A5F);   // سبز عمیق
  static const deepBg   = Color(0xFF0F4A33);
  static const mauve    = Color(0xFF6B7F73);   // sage خنثی
  static const mint     = Color(0xFF35F2A2);
  static const amber    = Color(0xFFE8B44C);   // Audit Amber
  static const sand     = Color(0xFFE8B44C);
  static const text     = Color(0xFFE8EFE9);
  static const textSec  = Color(0xFFA9B8AE);
  static const textDim  = Color(0xFF6E7F74);
  static const green    = Color(0xFF5FD0A0);
  static const red      = Color(0xFFE8745C);   // خطا — گرم ولی ملایم
  static const pink     = Color(0xFF63D9A8);

  static const heroGrad = LinearGradient(
    colors: [deepBg, deep, accent],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const accentGrad = LinearGradient(
    colors: [accentHi, accent, deep],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const glow = BoxShadow(
    color: Color(0x4035F2A2), blurRadius: 28, offset: Offset(0, 8),
  );
  static const amberGlow = BoxShadow(
    color: Color(0x33E8B44C), blurRadius: 24, offset: Offset(0, 6),
  );
}

/// پس‌زمینه محیطی Carbon-Scanner:
/// گرید فنی کم‌رنگ + هاله سبز پایین + هاله کهربایی بالا
class VzAmbientBg extends StatelessWidget {
  final Widget child;
  const VzAmbientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Vz.bg),
      child: Stack(children: [
        // گرید فنی — خطوط 40px با opacity خیلی کم
        Positioned.fill(child: IgnorePointer(child: CustomPaint(
          painter: _GridPainter(),
        ))),
        // هاله سبز پایین-چپ (نفس Diagnostic)
        Positioned(left: -140, bottom: -160, child: _blob(const Color(0x2635F2A2), 420)),
        // هاله کهربایی بالا-راست (نفس Audit)
        Positioned(right: -140, top: -170, child: _blob(const Color(0x1AE8B44C), 360)),
        // هاله سبز عمیق مرکز-راست
        Positioned(right: -100, bottom: 60, child: _blob(const Color(0x141F8A5F), 320)),
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0DE8EFE9)   // ~5% سفیدسبز
      ..strokeWidth = 1;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// موتیف Scan Line — خط اسکن متحرک برای هدر و کارت‌های فعال
class VzScanLine extends StatefulWidget {
  final double height;
  final Color color;
  const VzScanLine({super.key, this.height = 2, this.color = Vz.accent});
  @override State<VzScanLine> createState()=>_VzScanLineState();
}
class _VzScanLineState extends State<VzScanLine> with SingleTickerProviderStateMixin{
  late final AnimationController _c = AnimationController(
    vsync:this,duration:const Duration(seconds:3))..repeat();
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
                widget.color.withOpacity(0),widget.color.withOpacity(0.7),widget.color.withOpacity(0)])),
            )),
        ]));
      });
    });
  }
}

ThemeData buildVezooTheme() {
  const scheme = ColorScheme.dark(
    primary: Vz.accent,
    onPrimary: Vz.bg,
    secondary: Vz.amber,
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
        letterSpacing: 0.4, color: Vz.text,
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
      inactiveTrackColor: Color(0x24E8EFE9),
      thumbColor: Colors.white,
      trackHeight: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
        (s) => s.contains(MaterialState.selected) ? Vz.bg : Vz.mauve),
      trackColor: MaterialStateProperty.resolveWith(
        (s) => s.contains(MaterialState.selected) ? Vz.accent : Vz.cardHi),
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
      foregroundColor: Vz.bg,
      elevation: 0, focusElevation: 0, hoverElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Vz.accent,
        foregroundColor: Vz.bg,
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
      style: TextButton.styleFrom(foregroundColor: Vz.accent),
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
