// lib/vz_color_wheel.dart — انتخابگر رنگ کامل
//
// کاربر می‌تواند از **هر جای طیف رنگ** انتخاب کند، نه فقط پالت‌های آماده:
//   • چرخ رنگ (HSV) با درگ — انتخاب hue/saturation
//   • اسلایدر روشنایی
//   • اسلایدر alpha اختیاری
//   • کد HEX + کپی
//   • چند رنگ سریع برای دسترسی آسان
//
// خروجی: یک `Color` که به VzThemeState.setCustomAccent داده می‌شود.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'glass.dart';
import 'vz_icons.dart';

/// دیالوگ انتخاب رنگ. اگر کاربر تایید کند، Color برمی‌گردد.
Future<Color?> showVzColorPicker(
  BuildContext context, {
  Color initial = const Color(0xFF00AEEC),
}) => showVzSheet<Color>(
  context: context,
  builder: (ctx) => _ColorPickerSheet(initial: initial),
);

/// صفحه‌ی تمام‌صفحه (برای دکمه‌ی «رنگ دلخواه» در تنظیمات).
class VzColorPickerScreen extends StatelessWidget {
  final Color initial;
  const VzColorPickerScreen({super.key, this.initial = const Color(0xFF00AEEC)});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppBar(
      title: const Text('Custom color'),
      leading: IconButton(
        icon: Icon(VzIcons.data('back')),
        onPressed: () => Navigator.pop(context)),
    ),
    body: SafeArea(child: _ColorPickerSheet(initial: initial, standalone: true)),
  );
}

class _ColorPickerSheet extends StatefulWidget {
  final Color initial;
  final bool standalone;
  const _ColorPickerSheet({required this.initial, this.standalone = false});

  @override State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
  }

  Color get _color => _hsv.toColor();

  String get _hex =>
      '#${_color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  void _done() => Navigator.pop(context, _color);

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.standalone)
          VzSheetHeader(
            icon: VzIcons.data('palette'),
            title: 'Custom color',
            onClose: () => Navigator.pop(context),
          ),
        Padding(
          padding: const EdgeInsets.all(Sp.lg),
          child: Column(children: [
            // ── پیش‌نمایش + HEX ──
            Row(children: [
              AnimatedContainer(
                duration: Mo.fast,
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: Rad.r(Rad.sm),
                  border: Border.all(color: Vz.border, width: 2),
                  boxShadow: [BoxShadow(
                    color: _color.withValues(alpha: 0.4),
                    blurRadius: 18, offset: const Offset(0, 6))],
                ),
              ),
              const SizedBox(width: Sp.md),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_hex, style: Ty.heading.copyWith(
                  fontFamily: 'monospace', fontSize: 18)),
                const SizedBox(height: 4),
                Row(children: [
                  Text('R${(_color.r * 255).round()} '
                       'G${(_color.g * 255).round()} '
                       'B${(_color.b * 255).round()}',
                    style: Ty.caption.copyWith(fontSize: 11)),
                  const SizedBox(width: Sp.sm),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _hex));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('HEX copied'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating));
                    },
                    child: Icon(VzIcons.data('copy'),
                      size: 14, color: Vz.textDim)),
                ]),
              ])),
            ]),
            const SizedBox(height: Sp.lg),

            // ── چرخ رنگ ──
            AspectRatio(
              aspectRatio: 1.6,
              child: LayoutBuilder(builder: (ctx, box) {
                final w = box.maxWidth, h = box.maxHeight;
                return GestureDetector(
                  onPanDown: (d) => _pick(d.localPosition, w, h),
                  onPanUpdate: (d) => _pick(d.localPosition, w, h),
                  child: ClipRRect(
                    borderRadius: Rad.r(Rad.md),
                    child: Stack(children: [
                      // گرادیان اشباع (افقی) × روشنایی (عمودی)
                      const Positioned.fill(child: CustomPaint(painter: _SvPainter())),
                      // نشانگر موقعیت فعلی
                      Positioned(
                        left: (_hsv.saturation * w) - 11,
                        top: ((1 - _hsv.value) * h) - 11,
                        child: IgnorePointer(child: Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _color,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [BoxShadow(
                              color: Colors.black45, blurRadius: 6)],
                          ),
                        )),
                      ),
                    ]),
                  ),
                );
              }),
            ),
            const SizedBox(height: Sp.md),

            // ── اسلایدر Hue ──
            _HueSlider(
              hue: _hsv.hue,
              onChanged: (h) => setState(() => _hsv = _hsv.withHue(h)),
            ),
            const SizedBox(height: Sp.sm),

            // ── اسلایدر روشنایی ──
            _LabeledSlider(
              label: 'Brightness',
              value: _hsv.value,
              gradient: LinearGradient(colors: [
                Colors.black, HSVColor.fromAHSV(1, _hsv.hue, _hsv.saturation, 1).toColor(),
              ]),
              onChanged: (v) => setState(() => _hsv = _hsv.withValue(v)),
            ),

            // ── اسلایدر اشباع ──
            _LabeledSlider(
              label: 'Saturation',
              value: _hsv.saturation,
              gradient: LinearGradient(colors: [
                HSVColor.fromAHSV(1, _hsv.hue, 0, _hsv.value).toColor(),
                HSVColor.fromAHSV(1, _hsv.hue, 1, _hsv.value).toColor(),
              ]),
              onChanged: (s) => setState(() => _hsv = _hsv.withSaturation(s)),
            ),
            const SizedBox(height: Sp.md),

            // ── رنگ‌های سریع ──
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quick.length,
                separatorBuilder: (_, __) => const SizedBox(width: Sp.sm),
                itemBuilder: (ctx, i) {
                  final c = _quick[i];
                  final sel = (c.toARGB32() & 0xFFFFFF) == (_color.toARGB32() & 0xFFFFFF);
                  return GestureDetector(
                    onTap: () => setState(() => _hsv = HSVColor.fromColor(c)),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: sel ? Vz.text : Vz.border,
                          width: sel ? 2.5 : 1),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Sp.lg),

            // ── اعمال ──
            SizedBox(
              width: double.infinity,
              child: VzGradButton(
                onTap: _done,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(child: Text('Apply',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Vz.onAccent,
                    fontSize: 14))),
              ),
            ),
          ]),
        ),
      ],
    );

    if (widget.standalone) {
      return SingleChildScrollView(child: body);
    }
    return SafeArea(top: false, child: SingleChildScrollView(child: body));
  }

  void _pick(Offset p, double w, double h) {
    final s = (p.dx / w).clamp(0.0, 1.0);
    final v = (1 - p.dy / h).clamp(0.0, 1.0);
    setState(() => _hsv = _hsv.withSaturation(s).withValue(v));
  }

  static const _quick = [
    Color(0xFF00AEEC), Color(0xFFFB7299), Color(0xFF8B5CF6),
    Color(0xFF22C55E), Color(0xFFF59E0B), Color(0xFFEF4444),
    Color(0xFF06B6D4), Color(0xFFEC4899), Color(0xFF84CC16),
  ];
}

/// پس‌زمینه‌ی مربع اشباع/روشنایی.
class _SvPainter extends CustomPainter {
  const _SvPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // سفید → رنگ کامل (افقی)
    canvas.drawRect(rect, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft, end: Alignment.centerRight,
        colors: [Colors.white, Color(0xFFFF0000)],
      ).createShader(rect));
    // شفاف → سیاه (عمودی) برای روشنایی
    canvas.drawRect(rect, Paint()
      ..blendMode = BlendMode.multiply
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.black],
      ).createShader(rect));
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _HueSlider extends StatelessWidget {
  final double hue;
  final ValueChanged<double> onChanged;
  const _HueSlider({required this.hue, required this.onChanged});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (ctx, box) {
    final w = box.maxWidth;
    return GestureDetector(
      onPanDown: (d) => onChanged((d.localPosition.dx / w).clamp(0.0, 1.0) * 360),
      onPanUpdate: (d) => onChanged((d.localPosition.dx / w).clamp(0.0, 1.0) * 360),
      child: SizedBox(
        height: 28,
        child: Stack(children: [
          Positioned.fill(top: 8, bottom: 8, child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xFFFF0000), Color(0xFFFFFF00), Color(0xFF00FF00),
                Color(0xFF00FFFF), Color(0xFF0000FF), Color(0xFFFF00FF),
                Color(0xFFFF0000),
              ]),
            )),
          )),
          Positioned(
            left: (hue / 360 * w) - 8,
            top: 2,
            child: IgnorePointer(child: Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
              ),
            )),
          ),
        ]),
      ),
    );
  });
}

class _LabeledSlider extends StatelessWidget {
  final String label;
  final double value;
  final Gradient gradient;
  final ValueChanged<double> onChanged;
  const _LabeledSlider({
    required this.label, required this.value,
    required this.gradient, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Text(label, style: Ty.caption.copyWith(fontSize: 11)),
        const Spacer(),
        Text('${(value * 100).round()}%',
          style: Ty.mono.copyWith(fontSize: 11, color: Vz.textSec)),
      ]),
      LayoutBuilder(builder: (ctx, box) {
        final w = box.maxWidth;
        void set(Offset p) =>
            onChanged((p.dx / w).clamp(0.0, 1.0));
        return GestureDetector(
          onPanDown: (d) => set(d.localPosition),
          onPanUpdate: (d) => set(d.localPosition),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 28,
            child: Stack(children: [
              Positioned.fill(top: 9, bottom: 9, child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
              )),
              Positioned(
                left: (value.clamp(0.0, 1.0) * w) - 8,
                top: 4,
                child: IgnorePointer(child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                  ),
                )),
              ),
            ]),
          ),
        );
      }),
    ],
  );
}
