// lib/vz_bubble.dart — ۲۰ مدل حباب که از نقطه‌ی لمس پخش می‌شوند.
//
// LTR note: این فایل عمداً «پاک» است و به theme وابسته نیست جز رنگ؛ برای
// رسم از Canvas خالص استفاده می‌کند تا سبک باشد و روی هر دستگاهی روان بماند.
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'theme.dart' show VzBubbleStyle;

/// painter مشترک برای همه‌ی مدل‌های حباب.
/// [t] پیشرفت ۰..۱ است، [origin] نقطه‌ی لمس، [color] رنگ پایه،
/// [scale] ضریب اندازه و [seed] برای تغییرات تصادفیِ پایدار هر تپ.
class VzBubblePainter extends CustomPainter {
  final Offset origin;
  final double t;
  final Color color;
  final VzBubbleStyle style;
  final double scale;
  final int seed;

  VzBubblePainter({
    required this.origin,
    required this.t,
    required this.color,
    required this.style,
    this.scale = 1.0,
    this.seed = 0,
  });

  /// شعاع پایه، با منحنی نرم و ضریب اندازه.
  double get _r => (26.0 + 84.0 * Curves.easeOutCubic.transform(t)) * scale;

  double get _fade => (1 - t).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    switch (style) {
      case VzBubbleStyle.classic:   _classic(canvas); break;
      case VzBubbleStyle.ring:      _ring(canvas); break;
      case VzBubbleStyle.pulse:     _pulse(canvas); break;
      case VzBubbleStyle.triple:    _triple(canvas); break;
      case VzBubbleStyle.fill:      _fill(canvas); break;
      case VzBubbleStyle.sparkle:   _sparkle(canvas); break;
      case VzBubbleStyle.burst:     _burst(canvas); break;
      case VzBubbleStyle.starburst: _starburst(canvas); break;
      case VzBubbleStyle.cross:     _cross(canvas); break;
      case VzBubbleStyle.dots:      _dots(canvas); break;
      case VzBubbleStyle.wave:      _wave(canvas); break;
      case VzBubbleStyle.ripple3:   _ripple3(canvas); break;
      case VzBubbleStyle.halo:      _halo(canvas); break;
      case VzBubbleStyle.target:    _target(canvas); break;
      case VzBubbleStyle.hex:       _polygon(canvas, 6); break;
      case VzBubbleStyle.diamond:   _polygon(canvas, 4); break;
      case VzBubbleStyle.square:    _polygon(canvas, 4, rotate: math.pi / 4); break;
      case VzBubbleStyle.heart:     _heart(canvas); break;
      case VzBubbleStyle.star:      _star(canvas, 5); break;
      case VzBubbleStyle.confetti:  _confetti(canvas); break;
      case VzBubbleStyle.confettiDense: _confettiDense(canvas); break;
      case VzBubbleStyle.confettiRing:  _confettiRing(canvas); break;
      case VzBubbleStyle.confettiWide:  _confettiWide(canvas); break;
      case VzBubbleStyle.confettiRain:  _confettiRain(canvas); break;
      case VzBubbleStyle.confettiBurst: _confettiBurst(canvas); break;
    }
  }

  /// پالت شاد مشترک — ۵ رنگ از hue رنگ پایه.
  List<Color> _partyPalette() {
    final h = HSLColor.fromColor(color).hue;
    return [
      color,
      HSLColor.fromColor(color).withHue((h + 60) % 360).toColor(),
      HSLColor.fromColor(color).withHue((h + 140) % 360).toColor(),
      HSLColor.fromColor(color).withHue((h + 220) % 360).toColor(),
      HSLColor.fromColor(color).withHue((h + 300) % 360).withSaturation(0.85).toColor(),
    ];
  }

  /// رسم یک تکه‌ی کانفتی چرخان.
  void _piece(Canvas c, Offset p, Color col, double sz, double rot, double alpha) {
    c.save();
    c.translate(p.dx, p.dy);
    c.rotate(rot);
    c.drawRect(Rect.fromCenter(center: Offset.zero, width: sz, height: sz * 0.6),
      Paint()..color = col.withValues(alpha: alpha));
    c.restore();
  }

  // ── واریانت‌های کانفتی ──

  void _confettiDense(Canvas c) {
    final rnd = math.Random(seed);
    final palette = _partyPalette();
    for (var i = 0; i < 60; i++) {
      final ang = rnd.nextDouble() * math.pi * 2;
      final speed = 0.3 + rnd.nextDouble() * 0.9;
      final p = origin + Offset(math.cos(ang), math.sin(ang)) * (_r * speed);
      final col = palette[i % palette.length];
      _piece(c, p, col, 3.0 + rnd.nextDouble() * 2.5,
        rnd.nextDouble() * math.pi + t * 9, _fade * 0.9);
    }
  }

  void _confettiRing(Canvas c) {
    final rnd = math.Random(seed);
    final palette = _partyPalette();
    const n = 26;
    for (var i = 0; i < n; i++) {
      final ang = i * 2 * math.pi / n;
      final jitter = 0.9 + rnd.nextDouble() * 0.2;
      final p = origin + Offset(math.cos(ang), math.sin(ang)) * _r * jitter;
      final col = palette[i % palette.length];
      _piece(c, p, col, 5.0, ang + t * 6, _fade * 0.9);
    }
  }

  void _confettiWide(Canvas c) {
    final rnd = math.Random(seed);
    final palette = _partyPalette();
    for (var i = 0; i < 40; i++) {
      final ang = rnd.nextDouble() * math.pi * 2;
      final speed = 0.8 + rnd.nextDouble() * 1.3;
      final p = origin + Offset(math.cos(ang), math.sin(ang)) * (_r * speed);
      final col = palette[i % palette.length];
      _piece(c, p, col, 5.0 + rnd.nextDouble() * 4.0,
        rnd.nextDouble() * math.pi + t * 5, _fade * 0.85);
    }
  }

  void _confettiRain(Canvas c) {
    final rnd = math.Random(seed);
    final palette = _partyPalette();
    // ذرات از نقطه‌ی لمس بالا می‌روند و مثل باران با گرانش پایین می‌آیند.
    for (var i = 0; i < 34; i++) {
      final fx = rnd.nextDouble() * 2 - 1;
      final dropT = t * (1.2 + rnd.nextDouble() * 0.6);
      final px = origin.dx + fx * _r * 0.9;
      final py = origin.dy - _r * 0.6 + dropT * _r * 2.2;
      final col = palette[i % palette.length];
      _piece(c, Offset(px, py), col, 3.5 + rnd.nextDouble() * 2.5,
        rnd.nextDouble() * math.pi + t * 7, _fade * 0.9);
    }
  }

  void _confettiBurst(Canvas c) {
    final rnd = math.Random(seed);
    final palette = _partyPalette();
    for (var i = 0; i < 36; i++) {
      final ang = rnd.nextDouble() * math.pi * 2;
      final speed = 0.9 + rnd.nextDouble() * 1.4;
      final p = origin + Offset(math.cos(ang), math.sin(ang)) *
          (_r * speed * Curves.easeOutQuart.transform(t));
      final col = palette[i % palette.length];
      _piece(c, p, col, 4.0 + rnd.nextDouble() * 3.0,
        rnd.nextDouble() * math.pi + t * 10, _fade * 0.9);
    }
  }

  // ── مدل‌ها ──

  /// پالت شاد — رنگ پایه + دو رنگ مکمل. برای حلقه‌ها/نقاط چندرنگ.
  List<Color> get _party {
    final h = HSLColor.fromColor(color).hue;
    return [
      color,
      HSLColor.fromColor(color).withHue((h + 120) % 360).toColor(),
      HSLColor.fromColor(color).withHue((h + 240) % 360).toColor(),
    ];
  }
  void _classic(Canvas c) {
    c.drawCircle(origin, _r, Paint()..color = color.withValues(alpha: _fade * 0.28));
    c.drawCircle(origin, _r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withValues(alpha: _fade * 0.55));
  }

  void _ring(Canvas c) {
    c.drawCircle(origin, _r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = color.withValues(alpha: _fade * 0.7));
  }

  void _pulse(Canvas c) {
    final pal = _party;
    for (var i = 0; i < 2; i++) { final k = i == 0 ? 0.0 : 0.35;
      final tt = (t - k).clamp(0.0, 1.0);
      final rr = (26 + 84 * Curves.easeOutCubic.transform(tt)) * scale;
      c.drawCircle(origin, rr, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = pal[i].withValues(alpha: ((1 - tt) * 0.6)));
    }
  }

  void _triple(Canvas c) {
    final pal = _party;
    for (var i = 0; i < 3; i++) { final k = i * 0.2;
      final tt = (t - k).clamp(0.0, 1.0);
      if (tt <= 0) continue;
      final rr = (20 + 90 * Curves.easeOutCubic.transform(tt)) * scale;
      c.drawCircle(origin, rr, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = pal[i].withValues(alpha: ((1 - tt) * 0.5)));
    }
  }

  void _fill(Canvas c) {
    final rr = _r * Curves.easeOutCubic.transform(t);
    c.drawCircle(origin, rr * 0.7,
      Paint()..color = color.withValues(alpha: _fade * 0.35));
  }

  void _sparkle(Canvas c) {
    final rnd = math.Random(seed);
    final h = HSLColor.fromColor(color).hue;
    for (var i = 0; i < 22; i++) {
      final ang = rnd.nextDouble() * math.pi * 2;
      final dist = _r * (0.5 + rnd.nextDouble() * 0.9);
      final p = origin + Offset(math.cos(ang), math.sin(ang)) * dist;
      // جرقه‌ها بین رنگ اصلی و رنگ مکمل می‌چرخند.
      final col = (i.isEven)
          ? color
          : HSLColor.fromColor(color).withHue((h + 160) % 360).toColor();
      c.drawCircle(p, (3.0 - t * 2.2).clamp(0.5, 3.5),
        Paint()..color = col.withValues(alpha: _fade * 0.9));
    }
  }

  void _burst(Canvas c) {
    final rnd = math.Random(seed);
    final rr = _r;
    final paint = Paint()
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: _fade * 0.8);
    for (var i = 0; i < 14; i++) {
      final ang = i * 2 * math.pi / 14 + rnd.nextDouble() * 0.12;
      final dir = Offset(math.cos(ang), math.sin(ang));
      c.drawLine(origin + dir * (rr * 0.25), origin + dir * rr, paint);
    }
  }

  void _starburst(Canvas c) {
    final rr = _r;
    final paint = Paint()
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: _fade * 0.75);
    for (var i = 0; i < 4; i++) {
      final ang = i * math.pi / 2;
      final dir = Offset(math.cos(ang), math.sin(ang));
      c.drawLine(origin + dir * (rr * 0.15), origin + dir * rr, paint);
    }
  }

  void _cross(Canvas c) {
    final rr = _r;
    final rot = t * math.pi / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withValues(alpha: _fade * 0.6);
    c.save();
    c.translate(origin.dx, origin.dy);
    c.rotate(rot);
    c.drawOval(Rect.fromCenter(center: Offset.zero, width: rr * 2, height: rr * 0.7), paint);
    c.drawOval(Rect.fromCenter(center: Offset.zero, width: rr * 0.7, height: rr * 2), paint);
    c.restore();
  }

  void _dots(Canvas c) {
    final rr = _r;
    final pal = _party;
    const n = 16;
    for (var i = 0; i < n; i++) {
      final ang = i * 2 * math.pi / n;
      final p = origin + Offset(math.cos(ang), math.sin(ang)) * rr;
      c.drawCircle(p, 2.2, Paint()..color = pal[i % pal.length].withValues(alpha: _fade * 0.8));
    }
  }

  void _wave(Canvas c) {
    final pal = _party;
    for (var k = 0; k < 3; k++) {
      final rr = _r * (0.5 + k * 0.25);
      final path = Path();
      const steps = 48;
      for (var i = 0; i <= steps; i++) {
        final a = i * 2 * math.pi / steps;
        final wobble = 1 + 0.08 * math.sin(a * 6 + t * 6);
        final p = origin + Offset(math.cos(a), math.sin(a)) * rr * wobble;
        if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
      }
      path.close();
      c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = pal[k].withValues(alpha: _fade * 0.6));
    }
  }

  void _ripple3(Canvas c) {
    final pal = _party;
    for (var k = 0; k < 3; k++) {
      final tt = (t - k * 0.18).clamp(0.0, 1.0);
      if (tt <= 0) continue;
      final rr = (25 + 80 * Curves.easeOut.transform(tt)) * scale;
      c.drawCircle(origin, rr, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = pal[k].withValues(alpha: ((1 - tt) * 0.5)));
    }
  }

  void _halo(Canvas c) {
    final rr = _r * 1.4;
    c.drawCircle(origin, rr, Paint()
      ..shader = RadialGradient(colors: [
        color.withValues(alpha: _fade * 0.35),
        color.withValues(alpha: 0),
      ]).createShader(Rect.fromCircle(center: origin, radius: rr)));
  }

  void _target(Canvas c) {
    final rr = _r;
    c.drawCircle(origin, rr, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withValues(alpha: _fade * 0.6));
    c.drawCircle(origin, rr * 0.18,
      Paint()..color = color.withValues(alpha: _fade * 0.8));
  }

  void _polygon(Canvas c, int sides, {double rotate = 0}) {
    final rr = _r;
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final a = i * 2 * math.pi / sides - math.pi / 2 + rotate + t * math.pi / 3;
      final p = origin + Offset(math.cos(a), math.sin(a)) * rr;
      if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
    }
    path.close();
    c.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = color.withValues(alpha: _fade * 0.7));
  }

  void _heart(Canvas c) {
    final rr = _r * 0.9;
    final path = Path();
    const steps = 60;
    for (var i = 0; i <= steps; i++) {
      final a = i * 2 * math.pi / steps;
      final x = 16 * math.pow(math.sin(a), 3).toDouble();
      final y = 13 * math.cos(a) - 5 * math.cos(2 * a) -
          2 * math.cos(3 * a) - math.cos(4 * a);
      final p = origin + Offset(x, -y) * (rr / 16);
      if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
    }
    path.close();
    c.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = color.withValues(alpha: _fade * 0.75));
  }

  void _star(Canvas c, int points) {
    final outer = _r;
    final inner = _r * 0.45;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final a = i * math.pi / points - math.pi / 2 + t * math.pi / 4;
      final rad = i.isEven ? outer : inner;
      final p = origin + Offset(math.cos(a), math.sin(a)) * rad;
      if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
    }
    path.close();
    c.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = color.withValues(alpha: _fade * 0.75));
  }

  void _confetti(Canvas c) {
    final rnd = math.Random(seed);
    final h = HSLColor.fromColor(color).hue;
    // پالت شاد: ۵ رنگ با فاصله‌های hue بزرگ.
    final palette = <Color>[
      color,
      HSLColor.fromColor(color).withHue((h + 60) % 360).toColor(),
      HSLColor.fromColor(color).withHue((h + 140) % 360).toColor(),
      HSLColor.fromColor(color).withHue((h + 220) % 360).toColor(),
      HSLColor.fromColor(color).withHue((h + 300) % 360).withSaturation(0.85).toColor(),
    ];
    for (var i = 0; i < 30; i++) {
      final ang = rnd.nextDouble() * math.pi * 2;
      final speed = 0.5 + rnd.nextDouble() * 1.1;
      final p = origin + Offset(math.cos(ang), math.sin(ang)) * (_r * speed);
      final col = palette[i % palette.length];
      final sz = 4.0 + rnd.nextDouble() * 4.5;
      final rot = rnd.nextDouble() * math.pi + t * 8;
      c.save();
      c.translate(p.dx, p.dy);
      c.rotate(rot);
      c.drawRect(
        Rect.fromCenter(center: Offset.zero, width: sz, height: sz * 0.6),
        Paint()..color = col.withValues(alpha: _fade * 0.85));
      c.restore();
    }
  }

  @override
  bool shouldRepaint(covariant VzBubblePainter old) =>
      old.t != t || old.origin != origin || old.color != color ||
      old.style != style || old.scale != scale;
}
