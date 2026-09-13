// lib/glass.dart — Vezoo NOVA Core Components
// Glass surfaces • media cards • nav dock • states • motion
import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';

export 'theme.dart' show Vz, VzScanLine, Sp, Rad, Ty, Mo;

// ─────────────────────────────────────────────────────────────────────────────
//  GLASS SURFACES
// ─────────────────────────────────────────────────────────────────────────────

/// کارت شیشه‌ای NOVA — بدون گرید، استروک نرم + inner highlight
class VzGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? tint;
  final Color? borderColor;
  final double blur;
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
              width: 0.7,
            ),
          ),
          child: child,
        ),
      ),
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

/// دکمه Aurora — اکشن اصلی با گرادیان و glow
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
          gradient: Vz.auroraGrad,
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
      ),
    );
  }
}

/// دکمه ثانویه — glass با استروک
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
          gradient: const LinearGradient(
            colors: [Color(0xFFFCE16A), Color(0xFFFBBF24)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [Vz.amberGlow],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(padding: padding, child: child),
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
      color: color.withOpacity(0.13),
      borderRadius: BorderRadius.circular(box * 0.32),
      border: Border.all(color: color.withOpacity(0.26), width: 0.7),
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
      width: 44, height: 4.5,
      decoration: BoxDecoration(
        color: Vz.textDim.withOpacity(0.55),
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  BUTTON VARIANTS
// ─────────────────────────────────────────────────────────────────────────────

/// دکمه دایره‌ای شیشه‌ای — برای overlay ها و player controls
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
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: size, height: size,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.32),
              border: Border.all(color: Colors.white.withOpacity(0.14), width: 0.8),
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
        color: selected ? c.withOpacity(0.16) : Vz.card.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rad.full),
          side: BorderSide(
            color: selected ? c.withOpacity(0.55) : Vz.border,
            width: selected ? 1 : 0.7,
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
      color: Colors.black.withOpacity(0.55),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.5), width: 0.6),
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

/// Empty state استاندارد — آیکون دایره‌ای + متن + CTA اختیاری
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
            width: 84, height: 84,
            decoration: BoxDecoration(
              color: c.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: c.withOpacity(0.22), width: 1),
            ),
            child: Icon(icon, size: 36, color: c.withOpacity(0.75)),
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
              child: Text(ctaLabel!, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
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
          colors: const [Color(0x1422222E), Color(0x3A3A4C4C), Color(0x1422222E)],
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Vz.border, width: 0.6),
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

/// سربرگ بخش — عنوان + اکشن اختیاری
class VzSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const VzSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, Sp.sm, 0, Sp.md),
    child: Row(children: [
      Container(
        width: 4, height: 16,
        decoration: BoxDecoration(
          gradient: Vz.accentGrad,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: Sp.sm),
      Expanded(child: Text(title, style: Ty.heading.copyWith(fontSize: 15))),
      if (actionLabel != null)
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: Vz.accentHi,
            padding: const EdgeInsets.symmetric(horizontal: Sp.sm),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        ),
    ]),
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
    (VzNavDest.home,     Icons.movie_filter_rounded),
    (VzNavDest.live,     Icons.live_tv_rounded),
    (VzNavDest.discover, Icons.explore_rounded),
    (VzNavDest.library,  Icons.video_library_outlined),
    (VzNavDest.settings, Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Rad.full),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Sp.xs, vertical: Sp.xs),
            decoration: BoxDecoration(
              color: Vz.surface.withOpacity(0.88),
              borderRadius: BorderRadius.circular(Rad.full),
              border: Border.all(color: Vz.borderHi.withOpacity(0.8), width: 0.7),
              boxShadow: const [Vz.shadow],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              for (final (dest, icon) in _items)
                _dockItem(context, dest, icon),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _dockItem(BuildContext context, VzNavDest dest, IconData icon) {
    final active = current == dest;
    return GestureDetector(
      onTap: () => onSelect(dest),
      child: AnimatedContainer(
        duration: Mo.normal,
        curve: Mo.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: active ? 15 : 12, vertical: active ? 9 : 9),
        decoration: BoxDecoration(
          gradient: active ? Vz.accentGrad : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(Rad.full),
          boxShadow: active ? const [Vz.glowSoft] : null,
        ),
        child: Icon(
          icon,
          size: 21,
          color: active ? Colors.white : Vz.textDim,
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

/// دیالوگ استاندارد NOVA — آیکون + عنوان + متن + دکمه‌های معنادار
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
        borderRadius: BorderRadius.circular(Rad.lg),
        side: BorderSide(color: Vz.border, width: 0.7),
      ),
      title: Row(children: [
        if (icon != null) ...[
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: c.withOpacity(0.13),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: c.withOpacity(0.3), width: 0.7),
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
              child: Text(cancelLabel, textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF171204), fontWeight: FontWeight.w700, fontSize: 13)),
            )),
          if (cancelLabel != null) const SizedBox(width: Sp.sm),
          if (confirmLabel != null)
            Expanded(child: DecoratedBox(
              decoration: BoxDecoration(
                color: destructive ? Vz.red : Vz.accent,
                borderRadius: BorderRadius.circular(Rad.sm),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Rad.sm),
                  onTap: () { Navigator.pop(ctx); onConfirm?.call(); },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(confirmLabel, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
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
        borderRadius: BorderRadius.circular(Rad.lg),
        side: BorderSide(color: Vz.border, width: 0.7),
      ),
      title: Row(children: [
        if (icon != null) ...[
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Vz.accent.withOpacity(0.13),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Vz.accent.withOpacity(0.3), width: 0.7),
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
        style: const TextStyle(fontSize: 14, color: Vz.text),
        decoration: InputDecoration(hintText: hint),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.md),
      actions: [
        Row(children: [
          Expanded(child: VzMintButton(
            onTap: () => Navigator.pop(ctx),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(cancelLabel ?? 'Cancel', textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF171204), fontWeight: FontWeight.w700, fontSize: 13)),
          )),
          const SizedBox(width: Sp.sm),
          Expanded(child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: Vz.accentGrad,
              borderRadius: BorderRadius.circular(Rad.sm),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(Rad.sm),
                onTap: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(confirmLabel ?? 'OK', textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
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
          color: Vz.card.withOpacity(0.85),
          borderRadius: BorderRadius.circular(Rad.sm),
          border: Border.all(color: Vz.border, width: 0.7),
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 19, color: Vz.textDim),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: readOnly
              ? Text(hint, style: TextStyle(fontSize: 13.5, color: Vz.textDim))
              : TextField(
                  controller: controller,
                  autofocus: autofocus,
                  onChanged: onChanged,
                  style: const TextStyle(fontSize: 13.5, color: Vz.text),
                  decoration: InputDecoration.collapsed(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Vz.textDim, fontSize: 13),
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
              color: selected ? Vz.accent.withOpacity(0.75) : Vz.border.withOpacity(0.8),
              width: selected ? 1.2 : 0.7,
            ),
            boxShadow: selected ? const [Vz.glowSoft] : null,
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
                    decoration: const BoxDecoration(gradient: Vz.scrimGrad),
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
                  child: VzBadge(text: duration!, color: Colors.white)),
              // دکمه پخش شیشه‌ای
              if (onTap != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: VzGlassIconButton(icon: Icons.play_arrow_rounded, size: 42),
                    ),
                  ),
                ),
              // انتخاب
              if (selected)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Vz.accent.withOpacity(0.16),
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
