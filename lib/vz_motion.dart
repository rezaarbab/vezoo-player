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
import 'package:flutter/services.dart' show HapticFeedback;
import 'theme.dart';
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

/// اسپلش متحرک — لوگو، هاله‌ی دولایه، حروف VEZOO یکی‌یکی و نوار پیشرفت.
class VzSplash extends StatefulWidget {
  const VzSplash({super.key});
  @override State<VzSplash> createState() => _VzSplashState();
}

class _VzSplashState extends State<VzSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 2200))..forward();

  @override void dispose() { _c.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final on = Vz.animations;
    const letters = ['V', 'E', 'Z', 'O', 'O'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: Vz.bgGradient),
        child: VzAmbientBg(child: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── نشان ──
            SizedBox(width: 180, height: 180,
              child: Stack(alignment: Alignment.center, children: [
                // هاله‌ی بیرونی چرخان
                if (on)
                  RotationTransition(
                    turns: CurvedAnimation(parent: _c, curve: const Interval(0, 0.75, curve: Curves.easeOutCubic)),
                    child: Container(width: 170, height: 170,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        gradient: SweepGradient(colors: [
                          Vz.accent.withValues(alpha: 0),
                          Vz.accent.withValues(alpha: 0.55),
                          Vz.accent.withValues(alpha: 0),
                        ]))),
                  ),
                // هاله‌ی درونی چرخان (معکوس، رنگ دوم)
                if (on)
                  RotationTransition(
                    turns: ReverseAnimation(CurvedAnimation(
                      parent: _c, curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic))),
                    child: Container(width: 140, height: 140,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        gradient: SweepGradient(colors: [
                          Vz.accentHi.withValues(alpha: 0),
                          Vz.accentHi.withValues(alpha: 0.35),
                          Vz.accentHi.withValues(alpha: 0),
                        ]))),
                  ),
                // پالس نبض‌دار پشت لوگو
                if (on)
                  AnimatedBuilder(animation: _c, builder: (_, __) {
                    final t = Curves.easeOut.transform(
                      const Interval(0.25, 1, curve: Curves.easeOutCubic).transform(_c.value));
                    return Container(width: 96 + t * 40, height: 96 + t * 40,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        color: Vz.accent.withValues(alpha: 0.12 * (1 - t))));
                  }),
                // خود لوگو
                VzPopIn(
                  from: 0.4,
                  child: VzHeroGlow(radius: 28,
                    child: Container(width: 88, height: 88,
                      decoration: BoxDecoration(
                        gradient: Vz.auroraGrad,
                        borderRadius: Rad.r(Rad.lg),
                        boxShadow: [BoxShadow(
                          color: Vz.accent.withValues(alpha: 0.45),
                          blurRadius: 30, spreadRadius: 2)],
                      ),
                      child: Icon(VzIcons.data('play'),
                        color: Vz.onAccent, size: 48))),
                ),
              ]),
            ),
            const SizedBox(height: Sp.xl),
            // ── حروف VEZOO یکی‌یکی ──
            Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < letters.length; i++)
                if (on)
                  AnimatedBuilder(
                    animation: _c,
                    builder: (_, __) {
                      final t = const Interval(0.30, 0.75, curve: Curves.easeOutBack)
                          .transform(_c.value);
                      final batched = ((i * 0.09) + t.clamp(0.0, 1.0)).clamp(0.0, 1.0);
                      return Opacity(
                        opacity: batched,
                        child: Transform.translate(
                          offset: Offset(0, (1 - batched) * 16),
                          child: Text(letters[i],
                            style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w800,
                              letterSpacing: 6, color: Vz.text)),
                        ),
                      );
                    })
                else
                  Text(letters[i],
                    style: TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800,
                      letterSpacing: 6, color: Vz.text)),
            ]),
            const SizedBox(height: Sp.xs),
            VzFadeSlide(
              index: 6,
              child: Text(Vz.theme.name.toUpperCase(),
                style: Ty.overline.copyWith(color: Vz.accent, letterSpacing: 5)),
            ),
            const SizedBox(height: Sp.xxl),
            // ── نوار پیشرفت ──
            SizedBox(width: 150, child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(children: [
                Container(height: 3, color: Vz.border),
                if (on)
                  AnimatedBuilder(animation: _c, builder: (_, __) {
                    final w = const Interval(0.2, 1, curve: Curves.easeInOut)
                        .transform(_c.value);
                    return FractionallySizedBox(
                      widthFactor: w.clamp(0.0, 1.0),
                      child: Container(height: 3,
                        decoration: BoxDecoration(
                          gradient: Vz.auroraGrad,
                          borderRadius: BorderRadius.circular(999))));
                  })
                else
                  Container(height: 3,
                    decoration: BoxDecoration(
                      gradient: Vz.auroraGrad,
                      borderRadius: BorderRadius.circular(999))),
              ]),
            )),
          ],
        ))),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
//  VzPress — افکت کلیک فنری (scale + haptic)
// ─────────────────────────────────────────────────────────────────────────────

/// هر ویجتی را قابل‌کلیک می‌کند. حالا از سبک کلیک انتخاب‌شده در تنظیمات
/// ([Vz.clickStyle]) پیروی می‌کند؛ پارامتر [scale] فقط برای سبک فنری است.
class VzPress extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  /// scale هنگام فشار (فقط سبک فنری)
  final double scale;
  /// لرزش هنگام کلیک
  final bool haptic;
  const VzPress({
    super.key, required this.child, this.onTap, this.onLongPress,
    this.scale = 0.96, this.haptic = true,
  });
  @override Widget build(BuildContext context) => VzTappable(
    onTap: onTap, onLongPress: onLongPress, haptic: haptic,
    child: child,
  );
}


// ─────────────────────────────────────────────────────────────────────────────
//  VzSlideIn — ورود از کنار (برای لیست‌ها و شیت‌ها)
// ─────────────────────────────────────────────────────────────────────────────

class VzSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Offset from;
  final Duration duration;
  const VzSlideIn({
    super.key, required this.child, this.index = 0,
    this.from = const Offset(-0.10, 0),
    this.duration = const Duration(milliseconds: 300),
  });
  @override State<VzSlideIn> createState() => _VzSlideInState();
}

class _VzSlideInState extends State<VzSlideIn> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  @override void initState() {
    super.initState();
    if (Vz.animations) {
      _c = AnimationController(vsync: this, duration: widget.duration);
      Future.delayed(Duration(milliseconds: (widget.index.clamp(0, 20)) * 28), () {
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
        position: Tween(begin: widget.from, end: Offset.zero).animate(a),
        child: widget.child));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  VzTappable — افکت لمسی انتخاب‌شدنی (۵ مدل) به‌جای پت انیمه
// ─────────────────────────────────────────────────────────────────────────────

/// دور هر ویجتی می‌پیچد و هنگام لمس، افکت [Vz.clickStyle] را اجرا می‌کند.
/// سبک از تنظیمات خوانده می‌شود و به‌صورت زنده تغییر می‌کند.
class VzTappable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final BorderRadius? radius;
  final bool haptic;
  const VzTappable({
    super.key, required this.child, this.onTap, this.onLongPress,
    this.color, this.radius, this.haptic = true,
  });
  @override State<VzTappable> createState() => _VzTappableState();
}

class _VzTappableState extends State<VzTappable>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;
  bool _down = false;
  Offset _origin = Offset.zero;

  @override void initState() {
    super.initState();
    if (Vz.animations) {
      _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    }
  }

  @override void dispose() { _c?.dispose(); super.dispose(); }

  VzClickStyle get _style => Vz.clickStyle;

  void _downAt(Offset p) {
    _origin = p;
    if (_c != null) _c!.forward(from: 0);
    if (_style == VzClickStyle.spring ||
        _style == VzClickStyle.lift ||
        _style == VzClickStyle.glow) {
      setState(() => _down = true);
    }
  }

  void _up() { if (_down) setState(() => _down = false); }

  void _fire() {
    if (widget.haptic && Vz.animations) HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  @override Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    if (!enabled) return widget.child;

    final style = _style;
    final accent = widget.color ?? Vz.accent;
    final radius = widget.radius ?? BorderRadius.zero;
    final on = Vz.animations;

    // ── بدنه‌ی پایه + موج (برای ripple) ──
    Widget core = widget.child;

    if (style == VzClickStyle.ripple && _c != null) {
      core = ClipRRect(
        borderRadius: radius,
        child: Stack(children: [
          widget.child,
          Positioned.fill(child: IgnorePointer(
            child: AnimatedBuilder(animation: _c!, builder: (ctx, _) {
              final t = Curves.easeOut.transform(_c!.value);
              return CustomPaint(
                painter: _RipplePainter(origin: _origin, progress: t, color: accent));
            }),
          )),
        ]),
      );
    }

    // ── تبدیل بر اساس سبک ──
    Widget inner = core;
    if (on) {
      switch (style) {
        case VzClickStyle.spring:
          inner = AnimatedScale(
            scale: _down ? 0.94 : 1.0,
            duration: Mo.press, curve: Mo.easeOut,
            child: core);
          break;
        case VzClickStyle.lift:
          inner = AnimatedSlide(
            offset: _down ? const Offset(0, -0.02) : Offset.zero,
            duration: Mo.press, curve: Mo.easeOut,
            child: AnimatedContainer(
              duration: Mo.press, curve: Mo.easeOut,
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: _down
                  ? [BoxShadow(color: accent.withValues(alpha: 0.30),
                      blurRadius: 18, offset: const Offset(0, 8))]
                  : const []),
              child: core));
          break;
        case VzClickStyle.glow:
          inner = AnimatedContainer(
            duration: Mo.press, curve: Mo.easeOut,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: _down
                ? [BoxShadow(color: accent.withValues(alpha: 0.55),
                    blurRadius: 22, spreadRadius: 1)]
                : const []),
            child: core);
          break;
        case VzClickStyle.ripple:
        case VzClickStyle.none:
          inner = core;
          break;
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (d) => _downAt(d.localPosition),
      onTapUp: (_) => _up(),
      onTapCancel: _up,
      onTap: widget.onTap == null ? null : _fire,
      onLongPress: widget.onLongPress,
      child: inner,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  VzRipple — موج رنگی هنگام کلیک (سبک Material)
// ─────────────────────────────────────────────────────────────────────────────


class VzRipple extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? radius;
  const VzRipple({
    super.key, required this.child, this.onTap,
    this.color, this.radius,
  });
  @override State<VzRipple> createState() => _VzRippleState();
}

class _VzRippleState extends State<VzRipple> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  Offset _origin = Offset.zero;

  @override void initState() {
    super.initState();
    if (Vz.animations) {
      _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    }
  }
  @override void dispose() { _c?.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final c = _c;
    if (c == null || widget.onTap == null) {
      return GestureDetector(onTap: widget.onTap, child: widget.child);
    }
    return GestureDetector(
      onTapDown: (d) { _origin = d.localPosition; c.forward(from: 0); },
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: widget.radius ?? BorderRadius.zero,
        child: Stack(children: [
          widget.child,
          Positioned.fill(child: IgnorePointer(
            child: AnimatedBuilder(animation: c, builder: (ctx, _) {
              final t = Curves.easeOut.transform(c.value);
              return CustomPaint(
                painter: _RipplePainter(
                  origin: _origin, progress: t,
                  color: widget.color ?? Vz.accent));
            }),
          )),
        ]),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Offset origin;
  final double progress;
  final Color color;
  _RipplePainter({required this.origin, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    // شعاع تا دورترین گوشه
    final maxR = <double>[
      (origin - Offset.zero).distance,
      (origin - Offset(size.width, 0)).distance,
      (origin - Offset(0, size.height)).distance,
      (origin - Offset(size.width, size.height)).distance,
    ].reduce((a, b) => a > b ? a : b);
    final r = maxR * Curves.easeOut.transform(progress);
    canvas.drawCircle(origin, r,
      Paint()..color = color.withValues(alpha: (1 - progress) * 0.22));
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) =>
      old.progress != progress || old.origin != origin;
}