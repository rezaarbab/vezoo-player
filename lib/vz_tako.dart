// lib/vz_tako.dart — کامپوننت‌های سبک Tako Play
//
// این ویجت‌ها از روی طرح واقعی اپ Tako Play (MIT) بازسازی شده‌اند:
//   • VzReleasedPill  — پیل «Released: YYYY» با زمینه‌ی سرمه‌ای و متن اکسنت
//   • VzGenreChip     — چیپ گرد ژانر
//   • VzBlurBackdrop  — پس‌زمینه‌ی بلور‌شده از پوستر (امضای صفحه‌ی جزئیات)
//   • VzPosterCard    — کارت پوستر عمودی بدون حاشیه
//   • VzSectionTitle  — عنوان بخش رنگی با ایموجی (Popular / Recently Added)
//   • VzCenterBar     — اپ‌بار با عنوان وسط‌چین و دکمه‌های کنار
//   • VzEpisodeGrid   — گرید شماره‌ی قسمت‌ها با مربع‌های گرد
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'theme.dart';
import 'vz_icons.dart';
import 'vz_motion.dart';

/// پیل «Released: YYYY» — زمینه‌ی کم‌رنگ، متن اکسنت، گوشه‌ی گرد.
class VzReleasedPill extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const VzReleasedPill({
    super.key,
    this.label = 'Released',
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Vz.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Color.lerp(Vz.card, c, 0.14),
        borderRadius: BorderRadius.circular(Rad.s(Rad.full)),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Text('$label: $value',
        style: TextStyle(
          fontSize: 12.5, fontWeight: FontWeight.w700, color: c,
          letterSpacing: 0.2)),
    );
  }
}

/// چیپ گرد ژانر — مثل Action / Comedy / Shounen در Tako.
class VzGenreChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  const VzGenreChip({super.key, required this.label, this.onTap, this.selected = false});

  @override
  Widget build(BuildContext context) => VzPress(
    onTap: onTap,
    scale: 0.94,
    child: AnimatedContainer(
      duration: Mo.fast, curve: Mo.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? Vz.accentSoft : Vz.cardHi,
        borderRadius: BorderRadius.circular(Rad.s(Rad.full)),
        border: Border.all(
          color: selected ? Vz.accent : Vz.border,
          width: selected ? 1.4 : 1),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: selected ? Vz.accent : Vz.textSec)),
    ),
  );
}

/// پس‌زمینه‌ی بلور‌شده از پوستر — امضای صفحه‌ی جزئیات Tako.
///
/// [artwork] تصویر پوستر است (یا هر ویجت تصویری). با بلور سنگین و یک لایه‌ی
/// تیره روی آن، پایه‌ی خوانا می‌سازد.
class VzBlurBackdrop extends StatelessWidget {
  final Widget artwork;
  final Widget child;
  final double blur;
  final double darken;
  const VzBlurBackdrop({
    super.key,
    required this.artwork,
    required this.child,
    this.blur = 40,
    this.darken = 0.72,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      // تصویر، بزرگ‌شده تا لبه‌ها با بلور پوشیده شوند
      Positioned.fill(child: artwork),
      // بلور
      Positioned.fill(child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: const SizedBox.expand())),
      // لایه‌ی تیره برای خوانایی
      Positioned.fill(child: ColoredBox(
        color: Vz.bg.withValues(alpha: darken))),
      child,
    ]);
  }
}

/// کارت پوستر عمودی — بدون حاشیه، گردی ملایم، با عنوان و پیل/زیرنویس.
class VzPosterCard extends StatelessWidget {
  final Widget artwork;
  final String title;
  final String? subtitle;
  final String? released;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double posterHeight;
  final Widget? topLeft;
  final Widget? topRight;

  const VzPosterCard({
    super.key,
    required this.artwork,
    required this.title,
    this.subtitle,
    this.released,
    this.onTap,
    this.onLongPress,
    this.width = 132,
    this.posterHeight = 196,
    this.topLeft,
    this.topRight,
  });

  @override
  Widget build(BuildContext context) {
    return VzPress(
      onTap: onTap,
      onLongPress: onLongPress,
      scale: 0.96,
      child: SizedBox(
        width: width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── پوستر ──
          ClipRRect(
            borderRadius: Rad.r(Rad.md),
            child: SizedBox(
              width: width, height: posterHeight,
              child: Stack(fit: StackFit.expand, children: [
                artwork,
                if (topLeft != null || topRight != null)
                  Positioned(top: 7, left: 7, right: 7, child: Row(children: [
                    if (topLeft != null) topLeft!,
                    const Spacer(),
                    if (topRight != null) topRight!,
                  ])),
              ]),
            ),
          ),
          const SizedBox(height: 9),
          // ── عنوان ──
          Text(title,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: Ty.label.copyWith(fontSize: 12.5, height: 1.25)),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: Ty.caption.copyWith(fontSize: 10.5)),
          ],
          if (released != null) ...[
            const SizedBox(height: 7),
            VzReleasedPill(value: released!, label: 'Released'),
          ],
        ]),
      ),
    );
  }
}

/// عنوان بخش رنگی با ایموجی — مثل «Popular 🍥» در Tako.
class VzSectionTitle extends StatelessWidget {
  final String title;
  final String? emoji;
  final Widget? trailing;
  final Color? color;
  const VzSectionTitle({
    super.key,
    required this.title,
    this.emoji,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Vz.accent;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, Sp.sm),
      child: Row(children: [
        Text(title,
          style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.w800,
            letterSpacing: -0.5, color: c, height: 1.1)),
        if (emoji != null) ...[
          const SizedBox(width: 8),
          Text(emoji!, style: const TextStyle(fontSize: 19)),
        ],
        const Spacer(),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

/// اپ‌بار با عنوان وسط‌چین — سبک Tako.
class VzCenterBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final double height;
  const VzCenterBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.height = kToolbarHeight,
  });

  @override Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SafeArea(bottom: false, child: SizedBox(
      height: height,
      child: Row(children: [
        SizedBox(width: 56, child: Center(
          child: leading ?? IconButton(
            icon: Icon(VzIcons.data('back'), size: 22),
            onPressed: () => Navigator.maybePop(context)))),
        Expanded(child: Center(child: Text(title,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 21, fontWeight: FontWeight.w700,
            letterSpacing: -0.3, color: Vz.text)))),
        SizedBox(width: 56, child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions.isEmpty
            ? const [SizedBox.shrink()]
            : [for (final a in actions) a, const SizedBox(width: 4)])),
      ]),
    ));
  }
}

/// گرید شماره‌ی قسمت‌ها — مربع‌های گرد با عدد، به رنگ اکسنت.
class VzEpisodeGrid extends StatelessWidget {
  final int count;
  final int? current;
  final Set<int> watched;
  final ValueChanged<int> onTap;
  final int columns;
  const VzEpisodeGrid({
    super.key,
    required this.count,
    required this.onTap,
    this.current,
    this.watched = const {},
    this.columns = 5,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10, crossAxisSpacing: 10,
        childAspectRatio: 1.35),
      itemCount: count,
      itemBuilder: (ctx, i) {
        final n = i + 1;
        final active = n == current;
        final seen = watched.contains(n);
        return VzPress(
          onTap: () => onTap(n),
          scale: 0.92,
          child: AnimatedContainer(
            duration: Mo.fast, curve: Mo.easeOut,
            decoration: BoxDecoration(
              color: active ? Vz.accent : Vz.accent.withValues(alpha: seen ? 0.30 : 0.16),
              borderRadius: Rad.r(Rad.sm),
              border: Border.all(
                color: active ? Vz.accentHi : Vz.accent.withValues(alpha: 0.35)),
            ),
            child: Center(child: Text('$n',
              style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800,
                color: active ? Vz.onAccent : Vz.accent))),
          ),
        );
      },
    );
  }
}

/// ردیف افقی پوستر — کاروسل سبک Tako.
class VzPosterRow extends StatelessWidget {
  final int count;
  final Widget Function(BuildContext, int) builder;
  final double height;
  const VzPosterRow({
    super.key,
    required this.count,
    required this.builder,
    this.height = 268,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(width: Sp.md),
      itemBuilder: builder,
    ),
  );
}
