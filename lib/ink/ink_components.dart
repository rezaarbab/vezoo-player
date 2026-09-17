// lib/ink/ink_components.dart
// INK component set — flat paper surfaces, ink outlines, hard offset shadows.
import 'package:flutter/material.dart';
import 'ink_tokens.dart';

export 'ink_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────

/// Paper texture: dot grid + diagonal hatch wedge + double rule frame.
/// Drawn procedurally so there is no asset to ship and it scales to any size.
class InkPatternBackground extends StatelessWidget {
  const InkPatternBackground({
    super.key,
    this.child,
    this.padding = const EdgeInsets.only(top: 8),
    this.dots = true,
    this.hatch = true,
  });

  final Widget? child;
  final EdgeInsets padding;
  final bool dots;
  final bool hatch;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Ink.canvas,
      child: Stack(children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _InkPatternPainter(
                color: Ink.hatch,
                strong: Ink.rule,
                dots: dots,
                hatch: hatch,
              ),
            ),
          ),
        ),
        Padding(padding: padding, child: child),
      ]),
    );
  }
}

class _InkPatternPainter extends CustomPainter {
  _InkPatternPainter({
    required this.color,
    required this.strong,
    required this.dots,
    required this.hatch,
  });

  final Color color;
  final Color strong;
  final bool dots;
  final bool hatch;

  static const double _step = 26;

  @override
  void paint(Canvas canvas, Size size) {
    if (dots) {
      final dot = Paint()..color = color;
      for (double y = _step; y < size.height; y += _step) {
        for (double x = _step; x < size.width; x += _step) {
          canvas.drawCircle(Offset(x, y), 1.1, dot);
        }
      }
    }
    if (hatch) {
      canvas.save();
      canvas.clipRect(
          Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45));
      final line = Paint()
        ..color = color
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      for (double x = -size.height; x < size.width + size.height; x += 14) {
        canvas.drawLine(Offset(x, size.height),
            Offset(x + size.height * 0.45, size.height * 0.55), line);
      }
      canvas.restore();
    }
    final frame = Paint()
      ..color = strong
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
        Rect.fromLTWH(0.7, 0.7, size.width - 1.4, size.height - 1.4), frame);
    final tick = Paint()
      ..color = strong
      ..strokeWidth = 2.2;
    const double t = 14;
    canvas.drawLine(const Offset(0, 0), const Offset(t, 0), tick);
    canvas.drawLine(const Offset(0, 0), const Offset(0, t), tick);
    canvas.drawLine(
        Offset(size.width, size.height), Offset(size.width - t, size.height), tick);
    canvas.drawLine(
        Offset(size.width, size.height), Offset(size.width, size.height - t), tick);
  }

  @override
  bool shouldRepaint(_InkPatternPainter old) =>
      old.color != color ||
      old.strong != strong ||
      old.dots != dots ||
      old.hatch != hatch;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SURFACES
// ────────────────────────────────────────────────────────────────────────────

/// Flat sheet with an ink outline and a hard offset shadow. Optional [index]
/// prints a monospaced ledger number; [accentBar] adds a leading rule.
class InkCard extends StatelessWidget {
  const InkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(InkSp.x3),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.index,
    this.accentBar = false,
    this.raised = true,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final int? index;
  final bool accentBar;
  final bool raised;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(InkRad.card);
    final sheet = DecoratedBox(
      decoration: BoxDecoration(
        color: Ink.sheet,
        borderRadius: radius,
        border: Border.all(color: Ink.ruleStrong, width: 1.4),
        boxShadow: raised ? Ink.hardShadow : Ink.noShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (accentBar)
              ColoredBox(color: Ink.accent, child: const SizedBox(width: 4)),
            Expanded(child: Padding(padding: padding, child: child)),
            if (index != null)
              ColoredBox(
                color: Ink.ink.withValues(alpha: 0.04),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: InkSp.x2),
                  child: Center(
                    child: Text('${index!}'.padLeft(2, '0'),
                        style: InkType.mono.copyWith(color: Ink.inkFaint)),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
    final tappable = onTap == null
        ? sheet
        : Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap, borderRadius: radius, child: sheet),
          );
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Padding(padding: margin, child: tappable),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TEXT BLOCKS
// ─────────────────────────────────────────────────────────────────────────────

/// Section heading: uppercase kicker with a terracotta tick + title.
class InkHeader extends StatelessWidget {
  const InkHeader({
    super.key,
    required this.title,
    this.kicker,
    this.trailing,
    this.padding =
        const EdgeInsets.fromLTRB(InkSp.x4, InkSp.x4, InkSp.x4, InkSp.x2),
  });

  final String title;
  final String? kicker;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (kicker != null) ...[
          Row(children: [
            Container(width: 18, height: 3, color: Ink.accent),
            const SizedBox(width: InkSp.x2),
            Expanded(
              child: Text(kicker!.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: InkType.micro.copyWith(color: Ink.inkFaint)),
            ),
          ]),
          const SizedBox(height: InkSp.x2),
        ],
        Row(children: [
          Expanded(
            child: Text(title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: InkType.title.copyWith(color: Ink.ink)),
          ),
          if (trailing != null) trailing!,
        ]),
      ]),
    );
  }
}

/// Hairline rule, optionally captioned in the middle.
class InkRule extends StatelessWidget {
  const InkRule({
    super.key,
    this.label,
    this.padding = const EdgeInsets.symmetric(horizontal: InkSp.x4),
  });

  final String? label;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final line = Container(height: 1.4, color: Ink.rule);
    if (label == null) return Padding(padding: padding, child: line);
    return Padding(
      padding: padding,
      child: Row(children: [
        Expanded(child: line),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: InkSp.x2),
          child: Text(label!.toUpperCase(),
              style: InkType.micro.copyWith(color: Ink.inkFaint)),
        ),
        Expanded(child: line),
      ]),
    );
  }
}

/// Uppercase stamp. [filled] paints an accent block, otherwise outlined.
class InkBadge extends StatelessWidget {
  const InkBadge({
    super.key,
    required this.text,
    this.filled = false,
    this.color,
    this.icon,
  });

  final String text;
  final bool filled;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Ink.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: InkSp.x2, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? c : Colors.transparent,
        borderRadius: BorderRadius.circular(InkRad.sharp),
        border: Border.all(color: c, width: 1.4),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 11, color: filled ? Ink.accentInk : c),
          const SizedBox(width: 4),
        ],
        Text(text.toUpperCase(),
            maxLines: 1,
            style: InkType.micro
                .copyWith(fontSize: 9.5, color: filled ? Ink.accentInk : c)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ACTIONS
// ─────────────────────────────────────────────────────────────────────────────

/// Shared press behaviour: 2–3 px sink + shadow collapse. No scale, no fade.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.builder, this.onTap, this.onLongPress});

  final Widget Function(BuildContext context, bool down) builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (_down == value || !mounted) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    final animationsOff = MediaQuery.disableAnimationsOf(context);
    return GestureDetector(
      onTapDown: enabled && !animationsOff ? (_) => _set(true) : null,
      onTapUp: enabled && !animationsOff ? (_) => _set(false) : null,
      onTapCancel: enabled && !animationsOff ? () => _set(false) : null,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: widget.builder(context, _down && enabled),
    );
  }
}

Duration _pressDuration(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 90);

/// Primary action: accent block, square corners, sinks into its own shadow.
class InkButton extends StatelessWidget {
  const InkButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final button = _Pressable(
      onTap: onTap,
      builder: (context, down) => AnimatedContainer(
        duration: _pressDuration(context),
        transform: Matrix4.translationValues(down ? 3 : 0, down ? 3 : 0, 0),
        padding: const EdgeInsets.symmetric(
            horizontal: InkSp.x4, vertical: InkSp.x3),
        decoration: BoxDecoration(
          color: enabled ? Ink.accent : Ink.ink.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(InkRad.sharp),
          border: Border.all(color: Ink.ink.withValues(alpha: 0.55), width: 1.4),
          boxShadow: down || !enabled ? Ink.noShadow : Ink.hardShadow,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Ink.accentInk),
            const SizedBox(width: InkSp.x2),
          ],
          Text(label.toUpperCase(),
              maxLines: 1,
              style: InkType.micro.copyWith(color: Ink.accentInk)),
        ]),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Secondary action: transparent with an ink outline.
class InkOutlineButton extends StatelessWidget {
  const InkOutlineButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = _Pressable(
      onTap: onTap,
      builder: (context, down) => AnimatedContainer(
        duration: _pressDuration(context),
        transform: Matrix4.translationValues(down ? 2 : 0, down ? 2 : 0, 0),
        padding: const EdgeInsets.symmetric(
            horizontal: InkSp.x4, vertical: InkSp.x3),
        decoration: BoxDecoration(
          color: down ? Ink.ink.withValues(alpha: 0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(InkRad.sharp),
          border: Border.all(color: Ink.ruleStrong, width: 1.4),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Ink.ink),
            const SizedBox(width: InkSp.x2),
          ],
          Text(label.toUpperCase(),
              maxLines: 1,
              style: InkType.micro.copyWith(color: Ink.ink)),
        ]),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Square icon action. [selected] paints the accent block.
class InkIconButton extends StatelessWidget {
  const InkIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.selected = false,
    this.tooltip,
    this.size = 20,
    this.box = 42,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool selected;
  final String? tooltip;
  final double size;
  final double box;

  @override
  Widget build(BuildContext context) {
    final content = _Pressable(
      onTap: onTap,
      builder: (context, down) => AnimatedContainer(
        duration: _pressDuration(context),
        width: box,
        height: box,
        transform: Matrix4.translationValues(down ? 2 : 0, down ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: selected ? Ink.accent : Ink.sheet,
          borderRadius: BorderRadius.circular(InkRad.sharp),
          border: Border.all(
              color: selected
                  ? Ink.ink.withValues(alpha: 0.55)
                  : Ink.ruleStrong,
              width: 1.4),
          boxShadow: down || !selected ? Ink.noShadow : Ink.hardShadow,
        ),
        child:
            Icon(icon, size: size, color: selected ? Ink.accentInk : Ink.ink),
      ),
    );
    return Semantics(
      button: onTap != null,
      label: tooltip,
      child: tooltip == null
          ? content
          : Tooltip(message: tooltip!, child: content),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  FORMS
// ─────────────────────────────────────────────────────────────────────────────

/// Labelled field: uppercase caption above a square outlined input.
class InkField extends StatelessWidget {
  const InkField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.icon,
    this.obscure = false,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label != null) ...[
        Text(label!.toUpperCase(),
            style: InkType.micro.copyWith(color: Ink.inkFaint)),
        const SizedBox(height: InkSp.x1),
      ],
      TextField(
        controller: controller,
        obscureText: obscure,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: InkType.body.copyWith(color: Ink.ink),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon == null
              ? null
              : Icon(icon, size: 18, color: Ink.inkFaint),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ),
    ]);
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

/// Empty state: outlined icon plate, headline, hint and optional action.
class InkEmpty extends StatelessWidget {
  const InkEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
    this.action,
    this.padding = const EdgeInsets.all(InkSp.x6),
  });

  final IconData icon;
  final String title;
  final String? hint;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Ink.sheet,
              borderRadius: BorderRadius.circular(InkRad.card),
              border: Border.all(color: Ink.ruleStrong, width: 1.4),
              boxShadow: Ink.hardShadow,
            ),
            child: Icon(icon, size: 30, color: Ink.accent),
          ),
          const SizedBox(height: InkSp.x4),
          Text(title,
              textAlign: TextAlign.center,
              style: InkType.heading.copyWith(color: Ink.ink)),
          if (hint != null) ...[
            const SizedBox(height: InkSp.x2),
            Text(hint!,
                textAlign: TextAlign.center,
                style: InkType.body.copyWith(color: Ink.inkFaint)),
          ],
          if (action != null) ...[
            const SizedBox(height: InkSp.x5),
            action!,
          ],
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  NAVIGATION
// ─────────────────────────────────────────────────────────────────────────────

/// One destination of [InkTabBar].
class InkTabItem {
  const InkTabItem({required this.id, required this.icon, required this.label});
  final String id;
  final IconData icon;
  final String label;
}

/// Bottom index bar: flat segments, accent top rule on the active segment.
/// Intentionally neither a floating pill nor translucent.
class InkTabBar extends StatelessWidget {
  const InkTabBar({
    super.key,
    required this.items,
    required this.current,
    required this.onSelect,
  });

  final List<InkTabItem> items;
  final String current;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Ink.sheet,
        border: Border(top: BorderSide(color: Ink.ruleStrong, width: 1.4)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: InkSp.x1),
        child: Row(
          children: [
            for (final item in items) Expanded(child: _segment(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _segment(BuildContext context, InkTabItem item) {
    final active = item.id == current;
    return Semantics(
      selected: active,
      button: true,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelect(item.id),
            child: AnimatedContainer(
              duration: _pressDuration(context),
              padding: const EdgeInsets.only(top: InkSp.x3, bottom: InkSp.x2),
              decoration: BoxDecoration(
                color: active ? Ink.accentSoft : Colors.transparent,
                border: Border(
                  top: BorderSide(
                      color: active ? Ink.accent : Colors.transparent,
                      width: 3),
                ),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(item.icon,
                    size: 21, color: active ? Ink.accent : Ink.inkFaint),
                const SizedBox(height: 5),
                Text(item.label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: InkType.micro.copyWith(
                        fontSize: 9, color: active ? Ink.accent : Ink.inkFaint)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHEETS & DIALOGS
// ─────────────────────────────────────────────────────────────────────────────

/// Grab handle for sheets.
class InkSheetHandle extends StatelessWidget {
  const InkSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: InkSp.x3),
        color: Ink.ruleStrong,
      ),
    );
  }
}

/// Flat sheet body: handle, uppercase kicker title, then the content.
class InkSheetFrame extends StatelessWidget {
  const InkSheetFrame({
    super.key,
    required this.title,
    required this.child,
    this.kicker,
  });

  final String title;
  final String? kicker;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Ink.sheet,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(InkRad.card)),
          border: Border.all(color: Ink.ruleStrong, width: 1.4),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.88),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const InkSheetHandle(),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(InkSp.x4, 0, InkSp.x4, InkSp.x3),
              child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (kicker != null)
                          Text(kicker!.toUpperCase(),
                              maxLines: 1,
                              style: InkType.micro
                                  .copyWith(color: Ink.inkFaint)),
                        Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: InkType.heading.copyWith(color: Ink.ink)),
                      ]),
                ),
                InkIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Close',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ]),
            ),
            const InkRule(),
            Flexible(
              child: SingleChildScrollView(child: child),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Shows [InkSheetFrame] as a modal sheet.
Future<T?> showInkSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  String? kicker,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => InkSheetFrame(title: title, kicker: kicker, child: child),
  );
}

/// Flat confirm dialog. Resolves to `true` when confirmed, `false` otherwise.
Future<bool> showInkConfirm({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(InkSp.x4, InkSp.x4, InkSp.x4, 0),
      contentPadding: const EdgeInsets.fromLTRB(InkSp.x4, InkSp.x2, InkSp.x4, 0),
      actionsPadding:
          const EdgeInsets.fromLTRB(InkSp.x3, InkSp.x3, InkSp.x3, InkSp.x3),
      title: Text(title.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: InkType.micro.copyWith(fontSize: 12, color: Ink.inkFaint)),
      content: Text(message, style: InkType.body.copyWith(color: Ink.ink)),
      actions: [
        InkOutlineButton(
          label: cancelLabel,
          onTap: () => Navigator.of(ctx).pop(false),
        ),
        InkButton(
          label: destructive ? '${confirmLabel.toUpperCase()} !' : confirmLabel,
          onTap: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}