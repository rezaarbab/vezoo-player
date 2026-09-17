// lib/glass.dart — Vezoo VOID Core Components
//
// Flat • hairline-ruled • single accent • zero blur.
// Every public signature is unchanged from NOVA so existing screens keep
// working, but the surfaces are now solid (no BackdropFilter) which also
// removes a real cost: each blurred card was forcing a saveLayer per frame.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'vz_icons.dart';

export 'theme.dart' show Vz, VzScanLine, Sp, Rad, Ty, Mo, VzThemeMode, VzThemeState, VzTheme, VzThemeScope, VzAmbientBg;

/// Flat surface colours, read once per build.
Color get _vzSurface => Vz.card;
Color get _vzLine => Vz.border;

// ─────────────────────────────────────────────────────────────────────────────
//  MOTION PRIMITIVES — انیمیشن‌های مشترک کل اپ
//  همه با کلید انیمیشن کاربر هماهنگ‌اند: اگر خاموش باشد، هیچ‌کدام ساخته نمی‌شوند.
// ─────────────────────────────────────────────────────────────────────────────

/// ورود پله‌ای — fade + scale. همان الگوی browser ولی برای همه‌جا.
class VzEnter extends StatefulWidget {
  final Widget child;
  final int index;
  final bool fromBottom;
  const VzEnter({super.key, required this.child, this.index = 0, this.fromBottom = true});

  @override State<VzEnter> createState() => _VzEnterState();
}

class _VzEnterState extends State<VzEnter> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  @override void initState() {
    super.initState();
    if (Vz.animations) {
      _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
      Future.delayed(Duration(milliseconds: (widget.index.clamp(0, 16)) * 28), () {
        if (mounted) _c?.forward();
      });
    }
  }
  @override void dispose() { _c?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final a = _c;
    if (a == null) return widget.child;
    final ca = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: ca,
      child: SlideTransition(
        position: Tween(
          begin: widget.fromBottom ? const Offset(0, 0.10) : const Offset(0.08, 0),
          end: Offset.zero).animate(ca),
        child: widget.child));
  }
}

/// نفس‌کشیدن آرام — برای کارت فعال، دکمه پخش، هدر.
class VzBreathing extends StatefulWidget {
  final Widget child;
  final double amount;
  final Duration period;
  const VzBreathing({
    super.key, required this.child,
    this.amount = 0.025,
    this.period = const Duration(seconds: 3),
  });
  @override State<VzBreathing> createState() => _VzBreathingState();
}

class _VzBreathingState extends State<VzBreathing> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  @override void initState() {
    super.initState();
    if (Vz.animations) {
      _c = AnimationController(vsync: this, duration: widget.period)
        ..repeat(reverse: true);
    }
  }
  @override void dispose() { _c?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.child;
    return AnimatedBuilder(
      animation: c,
      builder: (ctx, _) {
        final t = Curves.easeInOut.transform(c.value);
        return Transform.scale(
          scale: 1 + (t - 0.5) * 2 * widget.amount,
          child: widget.child,
        );
      });
  }
}

/// پالس ملایم برای دکمه‌های در انتظار.
class VzPulse extends StatefulWidget {
  final Widget child;
  const VzPulse({super.key, required this.child});
  @override State<VzPulse> createState() => _VzPulseState();
}

class _VzPulseState extends State<VzPulse> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  @override void initState() {
    super.initState();
    if (Vz.animations) {
      _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
        ..repeat(reverse: true);
    }
  }
  @override void dispose() { _c?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.child;
    return AnimatedBuilder(
      animation: c,
      builder: (ctx, _) => Opacity(
        opacity: 0.72 + Curves.easeInOut.transform(c.value) * 0.28,
        child: widget.child),
    );
  }
}

/// کارت با عمق و نفس‌کشیدن — قهرمان گرید کتابخانه.
class VzLiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool breathing;
  final bool active;
  const VzLiveCard({
    super.key, required this.child,
    this.onTap, this.breathing = true, this.active = false,
  });

  @override Widget build(BuildContext context) {
    final body = VzGlass(
      onTap: onTap,
      borderColor: active ? Vz.accent : null,
      child: child,
    );
    if (!breathing || !Vz.animations) return body;
    return VzBreathing(amount: active ? 0.012 : 0.006, child: body);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SURFACES
// ─────────────────────────────────────────────────────────────────────────────

/// کارت VOID — سطح تخت + خط مویی. بدون blur، بدون گرید.
class VzGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? tint;
  final Color? borderColor;
  final double blur; // kept for API compat — VOID is flat, ignored
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const VzGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Sp.md),
    this.margin,
    this.radius = Rad.md,
    this.tint,
    this.borderColor,
    this.blur = 16,
    this.onTap,
    this.onLongPress,
    this.gradient,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (tint ?? _vzSurface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? _vzLine, width: 1),
        boxShadow: boxShadow,
      ),
      child: child,
    );
    final interactive = onTap != null || onLongPress != null;
    if (!interactive) {
      return margin == null ? body : Padding(padding: margin!, child: body);
    }
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(radius),
          child: body,
        ),
      ),
    );
  }
}

/// دکمه اصلی VOID — گرادیان کهربایی، متن تیره برای کنتراست کافی
class VzGradButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  const VzGradButton({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: Sp.xl, vertical: Sp.md),
    this.radius = Rad.sm,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: Vz.accentGrad,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: onTap == null ? null : [Vz.glowSoft],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: padding,
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: Vz.onAccent,
                  fontWeight: FontWeight.w700, fontSize: 13.5),
                child: IconTheme.merge(
                  data: IconThemeData(
                    color: Vz.onAccent,
                    size: 18),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// دکمه ثانویه VOID — سطح تخت + خط مویی
class VzMintButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  const VzMintButton({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: Sp.xl, vertical: Sp.md),
    this.radius = Rad.sm,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Vz.cardHi,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Vz.borderHi, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: padding,
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: Vz.text, fontWeight: FontWeight.w700, fontSize: 13),
                child: IconTheme.merge(
                  data: IconThemeData(color: Vz.text, size: 18),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// micro-interaction: scale-down نرم هنگام press
class _PressScale extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  const _PressScale({this.onTap, required this.child});
  @override State<_PressScale> createState()=>_PressScaleState();
}
class _PressScaleState extends State<_PressScale>{
  bool _down=false;
  @override Widget build(BuildContext context)=>GestureDetector(
    onTapDown:widget.onTap==null?null:(_)=>setState(()=>_down=true),
    onTapCancel:()=>setState(()=>_down=false),
    onTapUp:(_)=>setState(()=>_down=false),
    child:AnimatedScale(
      scale:_down?0.96:1.0,
      duration:Mo.press,curve:Mo.easeOut,
      child:widget.child),
  );
}

/// آیکون‌باکس — مربع نرم‌گوشه با زمینه‌ی کم‌رنگ accent
class VzIconBadge extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final double box;
  const VzIconBadge({
    super.key,
    required this.icon,
    this.color,
    this.size = 18,
    this.box = 40,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Vz.accent; // default از پالت runtime (const نیست)
    return Container(
      width: box, height: box,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(box * 0.30),
        border: Border.all(color: c.withValues(alpha: 0.24), width: 1),
      ),
      child: Icon(icon, color: c, size: size),
    );
  }
}

/// هندل drag بالای sheet ها
class VzSheetHandle extends StatelessWidget {
  const VzSheetHandle({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40, height: 4,
      decoration: BoxDecoration(
        color: Vz.borderHi,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  BUTTON VARIANTS
// ─────────────────────────────────────────────────────────────────────────────

/// دکمه دایره‌ای — برای overlay ها و player controls.
/// تخت و بدون blur تا روی ویدیو هم روان بماند.
class VzGlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  const VzGlassIconButton({
    super.key, required this.icon, this.onTap,
    this.size = 44, this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Icon(icon, color: color ?? Colors.white, size: size * 0.46),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CHIPS
// ─────────────────────────────────────────────────────────────────────────────

/// Chip انتخاب‌پذیر — segmented filter ها
class VzChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;
  const VzChip({
    super.key, required this.label,
    this.icon, this.selected = false, this.onTap, this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Vz.accent;
    return _PressScale(
      onTap: onTap,
      child: Material(
        color: selected ? c.withValues(alpha: 0.14) : Vz.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rad.full),
          side: BorderSide(
            color: selected ? c.withValues(alpha: 0.6) : Vz.border,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Rad.full),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: selected ? c : Vz.textDim),
                const SizedBox(width: 6),
              ],
              Text(label, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: selected ? c : Vz.textSec,
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

/// بج کوچک روی media cards
class VzBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const VzBadge({super.key, required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: Vz.badgeBg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.55), width: 1),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
      ],
      Text(text, style: TextStyle(
        fontSize: 10, color: color, fontWeight: FontWeight.w700, height: 1.2,
        fontFeatures: [const FontFeature.tabularFigures()])),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATES — empty / loading / error
// ─────────────────────────────────────────────────────────────────────────────

/// Empty state استاندارد — آیکون + متن + CTA اختیاری
class VzEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? hint;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final Color? color;
  const VzEmpty({
    super.key, required this.icon, required this.title,
    this.hint, this.ctaLabel, this.onCta, this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Vz.accent;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sp.xxl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.withValues(alpha: 0.20), width: 1),
            ),
            child: Icon(icon, size: 34, color: c.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: Sp.lg),
          Text(title, style: Ty.heading),
          if (hint != null) ...[
            const SizedBox(height: Sp.sm),
            Text(hint!, textAlign: TextAlign.center, style: Ty.caption),
          ],
          if (ctaLabel != null) ...[
            const SizedBox(height: Sp.xl),
            VzGradButton(
              onTap: onCta,
              child: Text(ctaLabel!),
            ),
          ],
        ]),
      ),
    );
  }
}

/// Error state + دکمه Retry
class VzError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const VzError({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => VzEmpty(
    icon: Icons.wifi_off_rounded,
    title: message,
    hint: 'Check your connection and try again',
    ctaLabel: 'Retry',
    onCta: onRetry,
    color: Vz.red,
  );
}

/// Shimmer — skeleton loading برای کارت‌ها و لیست‌ها
class VzShimmer extends StatefulWidget {
  final Widget child;
  const VzShimmer({super.key, required this.child});
  @override State<VzShimmer> createState()=>_VzShimmerState();
}
class _VzShimmerState extends State<VzShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override void dispose(){_c.dispose();super.dispose();}
  @override
  Widget build(BuildContext context){
    return AnimatedBuilder(animation:_c, builder:(ctx,_){
      return ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback:(bounds)=>LinearGradient(
          begin: Alignment(-1 - _c.value*2, 0),
          end: Alignment(1 - _c.value*2, 0),
          colors: [
            Vz.cardHi.withValues(alpha: 0.05),
            Vz.borderHi.withValues(alpha: 0.35),
            Vz.cardHi.withValues(alpha: 0.05),
          ],
        ).createShader(bounds),
        child: widget.child,
      );
    });
  }
}

/// skeleton کارت media — برای گرید در حال بارگذاری
class VzSkeletonCard extends StatelessWidget {
  final double? width;
  final double aspectRatio;
  const VzSkeletonCard({super.key, this.width, this.aspectRatio = 0.72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Vz.card,
        borderRadius: Rad.r(Rad.md),
        border: Border.all(color: Vz.border, width: 1),
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: const VzShimmer(child: SizedBox.expand()),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────

/// سربرگ بخش — برچسب ریز uppercase + خط مویی تا انتهای ردیف
class VzSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const VzSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, Sp.lg, 0, Sp.sm),
    child: Row(children: [
      Text(
        title.toUpperCase(),
        style: Ty.overline.copyWith(color: Vz.textDim),
      ),
      const SizedBox(width: Sp.md),
      Expanded(child: Container(height: 1, color: Vz.border)),
      if (actionLabel != null) ...[
        const SizedBox(width: Sp.sm),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: Vz.accent,
            padding: const EdgeInsets.symmetric(horizontal: Sp.sm),
            minimumSize: const Size(0, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ],
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHEET KIT — واژگان مشترک همه‌ی bottom sheet ها
// ─────────────────────────────────────────────────────────────────────────────

/// ورودی رسمی شیت‌ها. همه‌ی شیت‌های اپ از این استفاده می‌کنند تا chrome یکسان
/// داشته باشند (سطح، گوشه، safe-area) و با تم هماهنگ بمانند.
Future<T?> showVzSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool showDragHandle = false,
  Color? backgroundColor,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: isScrollControlled,
  useSafeArea: true,
  backgroundColor: backgroundColor ?? Vz.surface,
  showDragHandle: showDragHandle,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.xl)),
  ),
  builder: builder,
);

/// برچسب ریز بخش داخل شیت — uppercase + خط مویی
class VzSectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const VzSectionLabel({super.key, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Sp.md, bottom: Sp.sm),
    child: Row(children: [
      Text(text.toUpperCase(), style: Ty.overline),
      const SizedBox(width: Sp.sm),
      Expanded(child: Container(height: 1, color: Vz.border)),
      if (trailing != null) ...[const SizedBox(width: Sp.sm), trailing!],
    ]),
  );
}

/// هدر استاندارد شیت — دستگیره + آیکون + عنوان + زیرعنوان + دکمه بستن
class VzSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool handle;
  final VoidCallback? onClose;
  const VzSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.handle = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (handle) const Padding(
        padding: EdgeInsets.only(top: Sp.sm, bottom: Sp.xs),
        child: VzSheetHandle(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.sm, Sp.sm),
        child: Row(children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Vz.accent),
            const SizedBox(width: Sp.md),
          ],
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Ty.heading, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: Ty.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ])),
          if (trailing != null) trailing!,
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close_rounded, size: 20, color: Vz.textSec),
              tooltip: 'Close'),
        ]),
      ),
      Container(height: 1, color: Vz.border),
    ]);
  }
}

/// ردیف شیت — عنوان/زیرعنوان + کنترل دلخواه سمت راست
class VzSheetRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Color? accent;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  const VzSheetRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.accent,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 11),
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: padding,
      child: Row(children: [
        if (icon != null) ...[
          Icon(icon, size: 19, color: accent ?? Vz.textSec),
          const SizedBox(width: Sp.md),
        ],
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Ty.label.copyWith(fontSize: 13.5)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: Ty.caption.copyWith(fontSize: 11)),
            ],
          ])),
        if (trailing != null) trailing!,
      ]),
    );
    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

/// سگمنت انتخاب — چند گزینه‌ی هم‌عرض داخل یک قاب
class VzSegmented extends StatelessWidget {
  final List<String> labels;
  final int value;
  final ValueChanged<int> onChanged;
  const VzSegmented({
    super.key,
    required this.labels,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.xs),
      decoration: BoxDecoration(
        color: Vz.card,
        borderRadius: Rad.r(Rad.sm),
        border: Border.all(color: Vz.border),
      ),
      child: Row(children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: Sp.xs),
          Expanded(child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: Rad.r(Rad.xs),
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: Mo.fast,
                curve: Mo.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
                decoration: BoxDecoration(
                  color: i == value ? Vz.accent.withValues(alpha: 0.14) : Colors.transparent,
                  borderRadius: Rad.r(Rad.xs),
                  border: Border.all(
                    color: i == value ? Vz.accent : Colors.transparent),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: i == value ? Vz.accent : Vz.textSec),
                ),
              ),
            ),
          )),
        ],
      ]),
    );
  }
}

/// ردیف سوییچ با عنوان/زیرعنوان
class VzSwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const VzSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => VzSheetRow(
    title: title,
    subtitle: subtitle,
    trailing: Switch(value: value, onChanged: onChanged),
  );
}

/// ردیف اسلایدر با برچسب و مقدار عددی
class VzSliderRow extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? format;
  final ValueChanged<double> onChanged;
  const VzSliderRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.format,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, 0),
      child: Row(children: [
        Expanded(child: Text(title, style: Ty.label.copyWith(fontSize: 13))),
        Text(format?.call(value) ?? value.toStringAsFixed(2),
          style: Ty.mono.copyWith(color: Vz.accent)),
      ]),
    ),
    Slider(
      value: value.clamp(min, max),
      min: min, max: max, divisions: divisions,
      onChanged: onChanged,
    ),
  ]);
}

/// دکمه اصلی تمام‌عرض شیت
class VzPrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool busy;
  const VzPrimaryButton({super.key, required this.child, this.onTap, this.busy = false});

  @override
  Widget build(BuildContext context) => VzGradButton(
    onTap: busy ? null : onTap,
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Center(
      child: busy
        ? const SizedBox(width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2))
        : child,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  NAV DOCK — ناوبری اصلی اپ
// ─────────────────────────────────────────────────────────────────────────────

enum VzNavDest { home, live, discover, library, settings }

class VzNavDock extends StatelessWidget {
  final VzNavDest current;
  final ValueChanged<VzNavDest> onSelect;
  const VzNavDock({super.key, required this.current, required this.onSelect});

  static const _items = [
    (VzNavDest.home,     'home'),
    (VzNavDest.live,     'live'),
    (VzNavDest.discover, 'discover'),
    (VzNavDest.library,  'library'),
    (VzNavDest.settings, 'settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Sp.xs, vertical: Sp.xs),
        decoration: BoxDecoration(
          color: Vz.dockFill,
          borderRadius: Rad.r(Rad.full),
          border: Border.all(color: Vz.borderHi, width: 1),
          boxShadow: [Vz.shadow],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          for (final (dest, iconName) in _items)
            _dockItem(context, dest, iconName),
        ]),
      ),
    );
  }

  Widget _dockItem(BuildContext context, VzNavDest dest, String iconName) {
    final active = current == dest;
    return Semantics(
      selected: active,
      button: true,
      label: dest.label,
      container: true,
      excludeSemantics: true,
      onTap: () => onSelect(dest),
      child: GestureDetector(
        onTap: () => onSelect(dest),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Mo.normal,
          curve: Mo.easeOut,
          // آیتم فعال پهن‌تر می‌شود (پیل کهربایی/اکسنت) — نشانه‌ی واضح‌تر
          padding: EdgeInsets.symmetric(
            horizontal: active ? 20 : 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? Vz.accent : Colors.transparent,
            borderRadius: Rad.r(Rad.full),
            boxShadow: active
              ? [BoxShadow(color: Vz.accent.withValues(alpha: 0.35),
                  blurRadius: 14, offset: const Offset(0, 4))]
              : null,
          ),
          child: active
            ? VzBreathing(
                amount: 0.06,
                child: VzIcon(iconName,
                  size: 21, color: Vz.onAccent, animated: true))
            : VzIcon(iconName, size: 21, color: Vz.textDim),
        ),
      ),
    );
  }
}

/// لیبل‌های NavDock — جدا از آیکون برای ترجمه آسان
extension VzNavDestX on VzNavDest {
  String get label => switch (this) {
    VzNavDest.home => 'Home',
    VzNavDest.live => 'Live',
    VzNavDest.discover => 'Discover',
    VzNavDest.library => 'Library',
    VzNavDest.settings => 'Settings',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
//  DIALOGS
// ─────────────────────────────────────────────────────────────────────────────

/// دیالوگ استاندارد VOID — آیکون + عنوان + متن + دکمه‌های معنادار
Future<T?> showVzDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  IconData? icon,
  Color? accent,
  String? cancelLabel,
  String? confirmLabel,
  VoidCallback? onConfirm,
  bool destructive = false,
}) {
  final c = destructive ? Vz.red : (accent ?? Vz.accent);
  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Vz.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: Rad.r(Rad.lg),
        side: BorderSide(color: Vz.border, width: 1),
      ),
      title: Row(children: [
        if (icon != null) ...[
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: c.withValues(alpha: 0.28), width: 1),
            ),
            child: Icon(icon, size: 18, color: c),
          ),
          const SizedBox(width: Sp.md),
        ],
        Expanded(child: Text(title, style: Ty.heading.copyWith(fontSize: 16))),
      ]),
      content: content ?? (message == null ? null : Text(message, style: Ty.bodySec)),
      actionsPadding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.md),
      actions: [
        Row(children: [
          if (cancelLabel != null)
            Expanded(child: VzMintButton(
              onTap: () => Navigator.pop(ctx),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(cancelLabel, textAlign: TextAlign.center),
            )),
          if (cancelLabel != null) const SizedBox(width: Sp.sm),
          if (confirmLabel != null)
            Expanded(child: DecoratedBox(
              decoration: BoxDecoration(
                color: destructive ? Vz.red : Vz.accent,
                borderRadius: Rad.r(Rad.sm),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: Rad.r(Rad.sm),
                  onTap: () { Navigator.pop(ctx); onConfirm?.call(); },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(confirmLabel, textAlign: TextAlign.center,
                      style: TextStyle(
                        color: destructive
                            ? Colors.white
                            : (Vz.onAccent),
                        fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ),
            )),
        ]),
      ],
    ),
  );
}

/// دیالوگ ورودی — برای rename، پلی‌لیست جدید و…
Future<String?> showVzInputDialog({
  required BuildContext context,
  required String title,
  String? hint,
  String? initialValue,
  IconData? icon,
  String? cancelLabel,
  String? confirmLabel,
  int maxLines = 1,
}) {
  final ctrl = TextEditingController(text: initialValue ?? '');
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Vz.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: Rad.r(Rad.lg),
        side: BorderSide(color: Vz.border, width: 1),
      ),
      title: Row(children: [
        if (icon != null) ...[
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Vz.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Vz.accent.withValues(alpha: 0.28), width: 1),
            ),
            child: Icon(icon, size: 18, color: Vz.accent),
          ),
          const SizedBox(width: Sp.md),
        ],
        Expanded(child: Text(title, style: Ty.heading.copyWith(fontSize: 16))),
      ]),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        maxLines: maxLines,
        style: TextStyle(fontSize: 14, color: Vz.text),
        decoration: InputDecoration(hintText: hint),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.md),
      actions: [
        Row(children: [
          Expanded(child: VzMintButton(
            onTap: () => Navigator.pop(ctx),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(cancelLabel ?? 'Cancel', textAlign: TextAlign.center),
          )),
          const SizedBox(width: Sp.sm),
          Expanded(child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: Vz.accentGrad,
              borderRadius: Rad.r(Rad.sm),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: Rad.r(Rad.sm),
                onTap: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(confirmLabel ?? 'OK', textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Vz.onAccent,
                      fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ),
          )),
        ]),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  INPUT
// ─────────────────────────────────────────────────────────────────────────────

/// فیلد جستجوی دائمی — search bar اصلی زیر هدر
class VzSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool readOnly;
  final Widget? trailing;
  const VzSearchField({
    super.key, this.controller, required this.hint,
    this.onChanged, this.onTap, this.autofocus = false,
    this.readOnly = false, this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: Sp.md),
        decoration: BoxDecoration(
          color: Vz.card,
          borderRadius: Rad.r(Rad.sm),
          border: Border.all(color: Vz.border, width: 1),
        ),
        child: Row(children: [
          Icon(Icons.search_rounded, size: 19, color: Vz.textDim),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: readOnly
              ? Text(hint, style: TextStyle(fontSize: 13.5, color: Vz.textDim))
              : TextField(
                  controller: controller,
                  autofocus: autofocus,
                  onChanged: onChanged,
                  style: TextStyle(fontSize: 13.5, color: Vz.text),
                  decoration: InputDecoration.collapsed(
                    hintText: hint,
                    hintStyle: TextStyle(color: Vz.textDim, fontSize: 13),
                  ),
                ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: Sp.sm),
            trailing!,
          ],
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MEDIA CARD — قهرمان layout های media-first
// ─────────────────────────────────────────────────────────────────────────────

/// کارت media عمودی — thumbnail تمام + scrim + بج‌ها + متادیتا
class VzMediaCard extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget image;          // thumbnail یا placeholder
  final String title;
  final String? subtitle;
  final String? duration;
  final List<Widget> badges;
  final bool selected;
  final double width;
  final double radius;

  const VzMediaCard({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.image,
    required this.title,
    this.subtitle,
    this.duration,
    this.badges = const [],
    this.selected = false,
    this.width = double.infinity,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: Mo.fast,
          curve: Mo.easeOut,
          width: width,
          decoration: BoxDecoration(
            color: Vz.card,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: selected ? Vz.accent : Vz.border,
              width: 1,
            ),
            boxShadow: selected ? [Vz.glowSoft] : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            // ── media ──
            Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(radius - 1)),
                child: SizedBox(
                  height: 132, width: double.infinity,
                  child: image,
                ),
              ),
              // scrim
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: Vz.scrimGrad),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              // بج‌ها بالا
              if (badges.isNotEmpty)
                Positioned(top: Sp.sm, left: Sp.sm, right: Sp.sm,
                  child: Wrap(spacing: 5, runSpacing: 5,
                    alignment: WrapAlignment.start,
                    children: badges,
                  )),
              // مدت پایین-راست
              if (duration != null)
                Positioned(right: Sp.sm, bottom: Sp.sm,
                  child: VzBadge(text: duration!, color: Colors.white),
                ),
              // دکمه پخش
              if (onTap != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.24), width: 1),
                        ),
                        child: Icon(VzIcons.data('play'), color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              // انتخاب
              if (selected)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Vz.accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(radius - 1)),
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
            ]),
            // ── metadata ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: Ty.label.copyWith(fontSize: 12.5)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: Ty.caption.copyWith(fontSize: 10)),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
