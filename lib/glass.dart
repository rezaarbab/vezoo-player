// lib/glass.dart — ویجت‌های شیشه‌ای مشترک Vezoo
import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';

/// موتیف Scan Line از theme
export 'theme.dart' show VzScanLine;

/// کارت شیشه‌ای با استروک نرم — پایه هویت بصری اپ
class VzGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? tint;
  final Color? borderColor;
  final double blur;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const VzGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.radius = 20,
    this.tint,
    this.borderColor,
    this.blur = 14,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final body = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint ?? Vz.card.withOpacity(0.72),
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ?? Vz.border.withOpacity(0.8),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) {
      return margin == null ? body : Padding(padding: margin!, child: body);
    }
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: body,
        ),
      ),
    );
  }
}

/// دکمه گرد گرادیانتی ember — اکشن‌های اصلی
class VzGradButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  const VzGradButton({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: Vz.accentGrad,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [Vz.glow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// دکمه گرد نئون نعنایی — اکشن‌های دوم
class VzMintButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  const VzMintButton({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: Vz.mintGrad,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [Vz.mintGlow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// آیکون‌باکس گرد نرم
class VzIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double box;
  const VzIconBadge({
    super.key,
    required this.icon,
    this.color = Vz.accent,
    this.size = 18,
    this.box = 40,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: box, height: box,
    decoration: BoxDecoration(
      color: color.withOpacity(0.14),
      borderRadius: BorderRadius.circular(box * 0.32),
      border: Border.all(color: color.withOpacity(0.28), width: 0.7),
    ),
    child: Icon(icon, color: color, size: size),
  );
}

/// هندل drag بالای sheet ها
class VzSheetHandle extends StatelessWidget {
  const VzSheetHandle({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 42, height: 4.5,
      decoration: BoxDecoration(
        gradient: Vz.accentGrad,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );
}
