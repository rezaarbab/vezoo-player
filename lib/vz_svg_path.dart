// lib/vz_svg_path.dart — پارسر سبک SVG path → dart:ui Path
//
// فقط دستورهای موردنیاز react-kawaii را پشتیبانی می‌کند:
//   M m L l H h V v C c Z z (و اعداد نسبی/مطلق)
// به‌علاوه exponent (1.2e-14) که در فایل‌های اصلی وجود دارد.
//
// این فایل هیچ وابستگی‌ای ندارد جز dart:ui، تا هم در ویجت و هم در
// CustomPainter قابل استفاده باشد.
import 'dart:ui';

/// یک مسیر SVG را به [Path] فلاتر تبدیل می‌کند.
Path vzParseSvgPath(String d) {
  final path = Path();
  final tl = _Tokenizer(d);

  double curX = 0, curY = 0;   // نقطه‌ی جاری
  double startX = 0, startY = 0; // ابتدای زیرمسیر
  String? cmd = tl.nextCommand();

  while (cmd != null) {
    switch (cmd) {
      case 'M':
      case 'm':
        final rel = cmd == 'm';
        var x = tl.nextNumber();
        var y = tl.nextNumber();
        if (rel) { x += curX; y += curY; }
        path.moveTo(x, y);
        curX = startX = x;
        curY = startY = y;
        // اعداد بعدی به‌صورت خط در نظر گرفته می‌شوند
        cmd = (rel ? 'l' : 'L');
        break;

      case 'L':
      case 'l':
        final rel = cmd == 'l';
        var x = tl.nextNumber();
        var y = tl.nextNumber();
        if (rel) { x += curX; y += curY; }
        path.lineTo(x, y);
        curX = x; curY = y;
        break;

      case 'H':
      case 'h':
        var x = tl.nextNumber();
        if (cmd == 'h') x += curX;
        path.lineTo(x, curY);
        curX = x;
        break;

      case 'V':
      case 'v':
        var y = tl.nextNumber();
        if (cmd == 'v') y += curY;
        path.lineTo(curX, y);
        curY = y;
        break;

      case 'C':
      case 'c':
        final rel = cmd == 'c';
        var x1 = tl.nextNumber(), y1 = tl.nextNumber();
        var x2 = tl.nextNumber(), y2 = tl.nextNumber();
        var x = tl.nextNumber(), y = tl.nextNumber();
        if (rel) {
          x1 += curX; y1 += curY;
          x2 += curX; y2 += curY;
          x += curX;  y += curY;
        }
        path.cubicTo(x1, y1, x2, y2, x, y);
        curX = x; curY = y;
        break;

      case 'Z':
      case 'z':
        path.close();
        curX = startX; curY = startY;
        break;
    }
    cmd = tl.nextCommand();
  }
  return path;
}

class _Tokenizer {
  final String s;
  int i = 0;
  _Tokenizer(this.s);

  void _skip() {
    while (i < s.length) {
      final c = s.codeUnitAt(i);
      // فاصله یا کاما
      if (c == 0x20 || c == 0x2C || c == 0x09 || c == 0x0A || c == 0x0D) { i++; continue; }
      break;
    }
  }

  /// دستور بعدی را می‌خواند (یا null اگر تمام شد).
  /// اگر عدد بعدی باشد، همان دستور قبلی تکرار می‌شود — اینجا null برمی‌گردانیم
  /// و caller با نگه‌داشتن cmd قبلی ادامه می‌دهد؛ برای سادگی، هر دستور باید
  /// در فایل باشد (فایل‌های react-kawaii هم همین‌طورند).
  String? nextCommand() {
    _skip();
    if (i >= s.length) return null;
    final c = s[i];
    if (RegExp(r'[A-Za-z]').hasMatch(c)) {
      i++;
      final rest = _remainingNumbers();
      // اگر بعد از دستور عددی نیست، null
      return rest.isEmpty ? null : c;
    }
    return null;
  }

  /// فهرست اعداد باقی‌مانده تا دستور بعدی (برای بررسی وجود).
  List<String> _remainingNumbers() {
    final out = <String>[];
    final save = i;
    while (true) {
      _skip();
      if (i >= s.length) break;
      final m = _numberMatch();
      if (m == null) break;
      out.add(m);
      i += m.length;
    }
    i = save;
    return out;
  }

  double nextNumber() {
    _skip();
    final m = _numberMatch();
    if (m == null) return 0;
    i += m.length;
    return double.parse(m);
  }

  String? _numberMatch() {
    final re = RegExp(r'^[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');
    final m = re.firstMatch(s.substring(i));
    return m?.group(0);
  }
}
