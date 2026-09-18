// lib/vz_motion.dart — مجموعه‌ی انیمیشن‌های آماده
//
// همه‌ی این ویجت‌ها با کلید انیمیشن کاربر (Vz.animations) هماهنگ‌اند: وقتی
// خاموش باشد، بلافاصله محتوای نهایی را نشان می‌دهند و هیچ controller ای
// ساخته نمی‌شود.
//
//   VzFadeSlide   — ورود نرم از پایین
//   VzPopIn       — ورود با بزرگ‌نمایی کشسانی (برای آیکون‌ها و کارت‌ها)
//   VzShimmer     — نوار/کارت در حال بارگذاری
//   VzTabSwitcher — ترنزیشن بین تب‌ها با اسلاید افقی
//   VzHeroGlow    — درخشش نبض‌دار برای عناصر قهرمان
//   VzSplash      — اسپلش متحرک با لوگو
import 'package:flutter/material.dart';
import 'glass.dart';
import 'vz_icons.dart';

/// ورود نرم: fade + اسلاید از پایین.
class VzFadeSlide extends StatefulWidget {
  final Widget child;
  final int index;
  final double offset;
  final Duration duration;
  const VzFadeSlide({
    super.key, required this.child, this.index = 0,
    this.offset = 0.08, this.duration = const Duration(milliseconds: 320),
  });
  @override State<VzFadeSlide> createState() => _VzFadeSlideState();
}

class _VzFadeSlideState extends State<VzFadeSlide> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  @override void initState() {
    super.initState();
    if (Vz.animations) {
      _c = AnimationController(vsync: this, duration: widget.duration);
      Future.delayed(Duration(milliseconds: (widget.index.clamp(0, 20)) * 30), () {
        if (mounted) _c?.forward();
      });
    }
  }
  @override void dispose() { _c?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.child;
    final a = CurvedAnimation(parent: c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(begin: Offset(0, widget.offset), end: Offset.zero).animate(a),
        child: widget.child));
  }
}

/// ورود کشسانی: بزرگ‌نمایی با overshoot — مناسب آیکون و کارت.
class VzPopIn extends StatefulWidget {
  final Widget child;
  final int index;
  final double from;
  const VzPopIn({super.key, required this.child, this.index = 0, this.from = 0.7});
  @override State<VzPopIn> createState() => _VzPopInState();
}

class _VzPopInState extends State<VzPopIn> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  @override void initState() {
    super.initState();
    if (Vz.animations) {
      _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
      Future.delayed(Duration(milliseconds: (widget.index.clamp(0, 20)) * 35), () {
        if (mounted) _c?.forward();
      });
    }
  }
  @override void dispose() { _c?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.child;
    // easeOutBack برای حس «فنری» بدون پکیج اضافه
    final a = CurvedAnimation(parent: c, curve: Curves.easeOutBack);
    return FadeTransition(
      opacity: CurvedAnimation(parent: c, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween(begin: widget.from, end: 1.0).animate(a),
        child: widget.child));
  }
}

/// شیمر در حال بارگذاری — روی هر ویجتی بگذار.
class VzShimmerBox extends StatefulWidget {
  final Widget child;
  const VzShimmerBox({super.key, required this.child});
  @override State<VzShimmerBox> createState() => _VzShimmerBoxState();
}

class _VzShimmerBoxState extends State<VzShimmerBox> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  @override void initState() {
    super.initState();
    if (Vz.animations) {
      _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
        ..repeat();
    }
  }
  @override void dispose() { _c?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.child;
    return AnimatedBuilder(
      animation: c,
      builder: (ctx, _) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-1 - c.value * 2, 0),
          end: Alignment(1 - c.value * 2, 0),
          colors: [
            Vz.cardHi.withValues(alpha: 0.06),
            Vz.accent.withValues(alpha: 0.32),
            Vz.cardHi.withValues(alpha: 0.06),
          ],
          stops: const [0.25, 0.5, 0.75],
        ).createShader(bounds),
        child: widget.child),
    );
  }
}

/// ترنزیشن بین محتواها با اسلاید افقی جهت‌دار.
/// [index] تغییر کند → محتوای جدید از جهت درست وارد می‌شود.
class VzTabSwitcher extends StatelessWidget {
  final int index;
  final Widget child;
  const VzTabSwitcher({super.key, required this.index, required this.child});

  @override Widget build(BuildContext context) {
    if (!Vz.animations) return child;
    return AnimatedSwitcher(
      duration: Mo.normal,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (c, anim) {
        final incoming = anim.status == AnimationStatus.forward ||
            anim.status == AnimationStatus.completed;
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: Offset(incoming ? 0.06 : -0.06, 0),
              end: Offset.zero,
            ).animate(anim),
            child: c,
          ));
      },
      child: KeyedSubtree(key: ValueKey(index), child: child),
    );
  }
}

/// درخشش نبض‌دار — برای عناصر قهرمان (دکمه پخش، هدر).
class VzHeroGlow extends StatefulWidget {
  final Widget child;
  final Color? color;
  final double radius;
  const VzHeroGlow({super.key, required this.child, this.color, this.radius = 24});
  @override State<VzHeroGlow> createState() => _VzHeroGlowState();
}

class _VzHeroGlowState extends State<VzHeroGlow> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  @override void initState() {
    super.initState();
    if (Vz.animations) {
      _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);
    }
  }
  @override void dispose() { _c?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final c = _c;
    final col = widget.color ?? Vz.accent;
    if (c == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: [BoxShadow(color: col.withValues(alpha: 0.3),
            blurRadius: 18, offset: const Offset(0, 6))]),
        child: widget.child);
    }
    return AnimatedBuilder(
      animation: c,
      builder: (ctx, _) {
        final t = Curves.easeInOut.transform(c.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [BoxShadow(
              color: col.withValues(alpha: 0.18 + t * 0.30),
              blurRadius: 14 + t * 20,
              offset: const Offset(0, 6))]),
          child: widget.child);
      });
  }
}

/// اسپلش متحرک — لوگو با انیمیشن ورود، هاله‌ی چرخان و نوار پیشرفت.
class VzSplash extends StatefulWidget {
  const VzSplash({super.key});
  @override State<VzSplash> createState() => _VzSplashState();
}

class _VzSplashState extends State<VzSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1600))..forward();

  @override void dispose() { _c.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: Vz.bgGradient),
        child: Center(child: VzAmbientBg(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // هاله‌ی چرخان پشت لوگو
            SizedBox(
              width: 140, height: 140,
              child: Stack(alignment: Alignment.center, children: [
                if (Vz.animations)
                  RotationTransition(
                    turns: CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(colors: [
                          Vz.accent.withValues(alpha: 0),
                          Vz.accent.withValues(alpha: 0.6),
                          Vz.accent.withValues(alpha: 0),
                        ]),
                      ),
                    )),
                VzPopIn(
                  from: 0.4,
                  child: VzHeroGlow(
                    radius: 26,
                    child: Container(
                      width: 84, height: 84,
                      decoration: BoxDecoration(
                        gradient: Vz.auroraGrad,
                        borderRadius: Rad.r(Rad.lg),
                      ),
                      child: Icon(VzIcons.data('play'),
                        color: Vz.onAccent, size: 46),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: Sp.xl),
            VzFadeSlide(
              index: 4,
              child: Text('VEZOO',
                style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  letterSpacing: 8, color: Vz.text)),
            ),
            const SizedBox(height: Sp.xs),
            VzFadeSlide(
              index: 6,
              child: Text(Vz.theme.name.toUpperCase(),
                style: Ty.overline.copyWith(color: Vz.accent, letterSpacing: 4)),
            ),
            const SizedBox(height: Sp.xxl),
            SizedBox(
              width: 130,
              child: VzShimmerBox(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Vz.border,
                    borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ),
          ],
        ))),
      ),
    );
  }
}
