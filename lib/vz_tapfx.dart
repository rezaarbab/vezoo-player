// lib/vz_tapfx.dart — ۱۰۰ طرح افکت لمس (۱۰ خانواده × ۱۰ سطح).
//
// هر طرح = خانواده + سطح. سطح اندازه/تعداد/سرعت عناصر را پله‌ای زیاد
// می‌کند تا از یک خانواده، ده طرح متمایز به دست آید.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class VzTapFx {
  final String family; // ripple, rings, burst, sparkle, shapes, firework, glow, bolt, orbit, bloom
  final int level;     // 1..10
  final String name;
  const VzTapFx(this.family, this.level, this.name);

  static const families = <String>[
    'ripple', 'rings', 'burst', 'sparkle', 'shapes',
    'firework', 'glow', 'bolt', 'orbit', 'bloom',
  ];

  static const familyLabels = <String, String>{
    'ripple':   'موج',
    'rings':    'حلقهها',
    'burst':    'انفجار',
    'sparkle':  'جرقه',
    'shapes':   'شکل',
    'firework': 'آتشبازی',
    'glow':     'هاله',
    'bolt':     'صاعقه',
    'orbit':    'مدار',
    'bloom':    'شکوفه',
  };

  /// ۱۰۰ طرح آماده.
  static final List<VzTapFx> all = () {
    final list = <VzTapFx>[];
    for (final f in families) {
      for (var l = 1; l <= 10; l++) {
        list.add(VzTapFx(f, l, '${familyLabels[f]} ${l}'));
      }
    }
    return list;
  }();
}

/// پارامترهای مشتق‌شده از خانواده/سطح — برای painter و پیشنمایش.
class FxParams {
  final double size;    // ضریب شعاع
  final int count;      // تعداد عناصر
  final double spread;  // پراکندگی
  final double speed;   // ضریب سرعت
  final int hueSpread;  // گسترهی رنگ
  FxParams(this.size, this.count, this.spread, this.speed, this.hueSpread);
}

FxParams fxParams(VzTapFx fx) {
  final l = fx.level.toDouble();
  switch (fx.family) {
    case 'ripple':   return FxParams(0.6 + l * 0.09, 1, 1.0, 1.0, 0);
    case 'rings':    return FxParams(0.8, 2 + (l / 2).floor(), 1.0, 1.0, 40 + l * 12);
    case 'burst':    return FxParams(0.7 + l * 0.05, 6 + l * 2, 1.0, 1.0, 30 + l * 10);
    case 'sparkle':  return FxParams(0.9, 8 + l * 4, 0.9, 1.0, 60 + l * 10);
    case 'shapes':   return FxParams(0.8, 3 + l, 0.8, 1.0, 90);
    case 'firework': return FxParams(1.0 + l * 0.06, 10 + l * 5, 1.2, 1.0, 120 + l * 12);
    case 'glow':     return FxParams(0.9 + l * 0.1, 1, 1.0, 1.0, 0);
    case 'bolt':     return FxParams(0.8, 3 + l, 1.0, 1.0, 40);
    case 'orbit':    return FxParams(0.9, 6 + l, 1.0, 1.0, 80 + l * 10);
    case 'bloom':    return FxParams(0.9, 4 + l, 0.9, 1.0, 100 + l * 12);
  }
  return FxParams(1, 8, 1, 1, 60);
}

/// painter همهی خانوادهها.
class VzTapFxPainter extends CustomPainter {
  final Offset origin;
  final double t;          // 0..1
  final VzTapFx fx;
  final Color color;
  final double scale;
  VzTapFxPainter({
    required this.origin, required this.t,
    required this.fx, required this.color, this.scale = 1.0,
  });

  static const _rBase = 30.0;
  double _r(FxParams p) => _rBase * p.size * Curves.easeOutCubic.transform(t) * scale;
  double get _fade => (1 - t).clamp(0.0, 1.0);

  Color _shift(int deg) {
    final h = HSLColor.fromColor(color).hue;
    return HSLColor.fromColor(color).withHue((h + deg) % 360).toColor();
  }

  void _piece(Canvas c, Offset p, Color col, double sz, double rot, double a) {
    c.save();
    c.translate(p.dx, p.dy);
    c.rotate(rot);
    c.drawRect(Rect.fromCenter(center: Offset.zero, width: sz, height: sz * 0.6),
      Paint()..color = col.withValues(alpha: a));
    c.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final p = fxParams(fx);
    final rnd = math.Random(fx.level * 7 + fx.family.hashCode);
    switch (fx.family) {
      case 'ripple':
        canvas.drawCircle(origin, _r(p),
          Paint()..color = color.withValues(alpha: _fade * 0.30));
        canvas.drawCircle(origin, _r(p),
          Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2
            ..color = color.withValues(alpha: _fade * 0.6));
        break;
      case 'rings':
        for (var i = 0; i < p.count; i++) {
          final tt = (t - i * 0.14).clamp(0.0, 1.0);
          if (tt <= 0) continue;
          canvas.drawCircle(origin, _rBase * p.size * Curves.easeOutCubic.transform(tt) * scale,
            Paint()..style = PaintingStyle.stroke..strokeWidth = 2
              ..color = _shift(p.hueSpread * i / math.max(1, p.count - 1))
                .withValues(alpha: (1 - tt) * 0.6));
        }
        break;
      case 'burst':
        for (var i = 0; i < p.count; i++) {
          final ang = i * 2 * math.pi / p.count + rnd.nextDouble() * 0.1;
          final dir = Offset(math.cos(ang), math.sin(ang));
          final rr = _r(p);
          canvas.drawLine(origin + dir * (rr * 0.25), origin + dir * rr, Paint()
            ..strokeWidth = 2.4..strokeCap = StrokeCap.round
            ..color = _shift(p.hueSpread * (i % 3)).withValues(alpha: _fade * 0.85));
        }
        break;
      case 'sparkle':
        for (var i = 0; i < p.count; i++) {
          final ang = rnd.nextDouble() * math.pi * 2;
          final dist = _r(p) * (0.5 + rnd.nextDouble() * p.spread);
          canvas.drawCircle(origin + Offset(math.cos(ang), math.sin(ang)) * dist,
            (3.2 - t * 2.4).clamp(0.5, 3.5),
            Paint()..color = _shift(p.hueSpread * (i % 4)).withValues(alpha: _fade * 0.9));
        }
        break;
      case 'shapes':
        // چندضلعی چرخان با تعداد اضلاع متغیر؛ سطوح بالا ستاره.
        final sides = 3 + (p.count / 2).floor().clamp(3, 8);
        final rr = _r(p);
        final star = fx.level >= 8;
        final path = Path();
        final steps = star ? sides * 2 : sides;
        for (var i = 0; i <= steps; i++) {
          final a = i * 2 * math.pi / steps - math.pi / 2 + t * math.pi / 4;
          final rad = star ? (i.isEven ? rr : rr * 0.45) : rr;
          final pt = origin + Offset(math.cos(a), math.sin(a)) * rad;
          if (i == 0) { path.moveTo(pt.dx, pt.dy); } else { path.lineTo(pt.dx, pt.dy); }
        }
        path.close();
        canvas.drawPath(path, Paint()
          ..style = PaintingStyle.stroke..strokeWidth = 2.4
          ..color = _shift(p.hueSpread).withValues(alpha: _fade * 0.8));
        break;
      case 'firework':
        for (var i = 0; i < p.count; i++) {
          final ang = rnd.nextDouble() * math.pi * 2;
          final speed = 0.6 + rnd.nextDouble() * 1.1;
          final pt = origin + Offset(math.cos(ang), math.sin(ang)) *
              (_r(p) * speed * Curves.easeOutQuart.transform(t));
          _piece(canvas, pt, _shift(p.hueSpread * (i % 5)),
            3.5 + rnd.nextDouble() * 3.0, rnd.nextDouble() * math.pi + t * 8,
            _fade * 0.9);
        }
        break;
      case 'glow':
        final rr = _r(p) * 1.5;
        canvas.drawCircle(origin, rr, Paint()
          ..shader = RadialGradient(colors: [
            color.withValues(alpha: _fade * 0.5),
            color.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: origin, radius: rr)));
        break;
      case 'bolt':
        for (var i = 0; i < p.count; i++) {
          final ang = i * 2 * math.pi / p.count + rnd.nextDouble() * 0.3;
          final rr = _r(p);
          final path = Path();
          path.moveTo(origin.dx, origin.dy);
          for (var s = 1; s <= 4; s++) {
            final d = rr * s / 4;
            final wob = (rnd.nextDouble() - 0.5) * rr * 0.35;
            path.lineTo(origin.dx + math.cos(ang) * d + math.sin(ang) * wob,
              origin.dy + math.sin(ang) * d - math.cos(ang) * wob);
          }
          canvas.drawPath(path, Paint()
            ..strokeWidth = 2..strokeCap = StrokeCap.round
            ..color = _shift(p.hueSpread * (i % 2)).withValues(alpha: _fade * 0.85));
        }
        break;
      case 'orbit':
        final rr = _r(p);
        final pal = List.generate(3, (i) => _shift(p.hueSpread * i / 2));
        for (var i = 0; i < p.count; i++) {
          final ang = i * 2 * math.pi / p.count + t * math.pi;
          canvas.drawCircle(origin + Offset(math.cos(ang), math.sin(ang)) * rr,
            3.0, Paint()..color = pal[i % pal.length].withValues(alpha: _fade * 0.85));
        }
        break;
      case 'bloom':
        // گلبرگها — بیضیهای چرخیده دور مرکز.
        final n = p.count;
        final rr = _r(p);
        for (var i = 0; i < n; i++) {
          final ang = i * 2 * math.pi / n + t * math.pi / 6;
          canvas.save();
          canvas.translate(origin.dx, origin.dy);
          canvas.rotate(ang);
          canvas.drawOval(
            Rect.fromCenter(center: Offset(rr * 0.6, 0), width: rr * 0.9, height: rr * 0.4),
            Paint()..color = _shift(p.hueSpread * i / n).withValues(alpha: _fade * 0.7));
          canvas.restore();
        }
        canvas.drawCircle(origin, rr * 0.18,
          Paint()..color = color.withValues(alpha: _fade * 0.8));
        break;
    }
  }

  @override
  bool shouldRepaint(covariant VzTapFxPainter old) =>
      old.t != t || old.origin != origin || old.fx != fx || old.color != color;
}
