// lib/vz_pet.dart — موتور «پت انیمه» به سبک ANeko
//
// یک شخصیت کوچک که روی صفحه راه می‌رود، انگشت کاربر را دنبال می‌کند، به
// لبه‌ی صفحه می‌رسد «togi» می‌زند، و وقتی تنها بماند می‌خوابد و خمیازه
// می‌کشد.
//
// ── این چه چیزی از ANeko است و چه چیزی نیست ──────────────────────────────
// گرفته‌شده از **ایده و مدل حرکت** ANeko (که خودش از nekoDA/oneko/xneko
// الهام گرفته): هشت جهت حرکت، شتاب/کاهش سرعت، دنبال‌کردن مکان‌نما، ماشین
// حالت با حالت‌های stop / wait / sleep / awake / move*
//
// نوشته‌شده از صفر: موتور فیزیک و ماشین حالت (کد ANeko LGPL است و کپی
// نشده)، و رسم شخصیت با react-kawaii (MIT). هیچ اسپرایت PNG از ANeko
// برداشته نشده چون گرافیک گربه‌ی آن کپی‌رایت دارد.
//
// ── چطور اسکین اضافه کنم؟ ────────────────────────────────────────────────
// فعلاً شخصیت‌ها از [VzKawaii] می‌آیند (lib/vz_kawaii.dart). برای اسکین
// سفارشی، یک [VzPetSkin] بساز که برای هر حالت یک widget بدهد.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import 'vz_kawaii.dart';
import 'glass.dart';

/// هشت جهت حرکت + حالت‌های پایدار.
enum PetMotion {
  stop, wait, sleep, awake,
  moveUp, moveDown, moveLeft, moveRight,
  moveUpLeft, moveUpRight, moveDownLeft, moveDownRight,
}

extension PetMotionX on PetMotion {
  bool get isMoving => name.startsWith('move');

  /// بردار واحد حرکت.
  Offset get vector => switch (this) {
    PetMotion.moveUp        => const Offset(0, -1),
    PetMotion.moveDown      => const Offset(0, 1),
    PetMotion.moveLeft      => const Offset(-1, 0),
    PetMotion.moveRight     => const Offset(1, 0),
    PetMotion.moveUpLeft    => const Offset(-0.707, -0.707),
    PetMotion.moveUpRight   => const Offset(0.707, -0.707),
    PetMotion.moveDownLeft  => const Offset(-0.707, 0.707),
    PetMotion.moveDownRight => const Offset(0.707, 0.707),
    _ => Offset.zero,
  };
}

/// از بردار سرعت، نزدیک‌ترین جهت را می‌دهد.
PetMotion petMotionFor(Offset v) {
  if (v.distance < 0.01) return PetMotion.stop;
  final a = math.atan2(v.dy, v.dx);              // -π .. π
  final deg = (a * 180 / math.pi + 360) % 360;   // 0=راست، 90=پایین
  if (deg >= 337.5 || deg < 22.5)   return PetMotion.moveRight;
  if (deg < 67.5)                   return PetMotion.moveDownRight;
  if (deg < 112.5)                  return PetMotion.moveDown;
  if (deg < 157.5)                  return PetMotion.moveDownLeft;
  if (deg < 202.5)                  return PetMotion.moveLeft;
  if (deg < 247.5)                  return PetMotion.moveUpLeft;
  if (deg < 292.5)                  return PetMotion.moveUp;
  return PetMotion.moveUpRight;
}

/// تنظیمات رفتار پت — معادل پارامترهای skin.xml در ANeko.
@immutable
class VzPetConfig {
  /// شتاب (پیکسل بر ثانیه²).
  final double acceleration;
  /// بیشترین سرعت.
  final double maxVelocity;
  /// فرسنگ نزدیکی به هدف که پت «رسیدم» حساب می‌کند.
  final double proximityDistance;
  /// فاصله‌ای که در آن شروع به کاهش سرعت می‌کند.
  final double deaccelerationDistance;
  /// اندازه‌ی رسم.
  final double size;
  /// اگر true، پت مکان‌نما را دنبال می‌کند.
  final bool followPointer;
  /// اگر true، خودش می‌گردد.
  final bool wander;
  /// هر چند وقت یک‌بار خودش هدف تازه انتخاب می‌کند.
  final Duration wanderInterval;

  const VzPetConfig({
    this.acceleration = 160,
    this.maxVelocity = 100,
    this.proximityDistance = 10,
    this.deaccelerationDistance = 60,
    this.size = 64,
    this.followPointer = true,
    this.wander = true,
    this.wanderInterval = const Duration(seconds: 6),
  });
}

/// لایه‌ی پت که روی کل اپ می‌نشیند (بالای نوار ناوبری).
///
/// استفاده:
/// ```dart
/// Stack(children: [ appContent, VzPetLayer(config: ...) ])
/// ```
class VzPetLayer extends StatefulWidget {
  final VzPetConfig config;

  /// چهره‌ی انتخابی کاربر (اگر null، بر اساس حالت حرکت تعیین می‌شود).
  final VzKawaiiMood? mood;

  const VzPetLayer({super.key, this.config = const VzPetConfig(), this.mood});

  @override State<VzPetLayer> createState() => _VzPetLayerState();
}

class _VzPetLayerState extends State<VzPetLayer> with SingleTickerProviderStateMixin {
  late final VzPetConfig c = widget.config;

  /// موقعیت مرکز پت.
  Offset _pos = Offset.zero;
  Offset _vel = Offset.zero;
  Offset _target = Offset.zero;

  PetMotion _motion = PetMotion.stop;
  Size _bounds = Size.zero;
  bool _ready = false;

  /// فاز انیمیشن اسپرایت (۰ یا ۱) — برای راه رفتن دو فریمی.
  bool _step = false;
  int _idleTicks = 0;
  Timer? _wanderTimer;

  Ticker? _ticker;
  Duration _last = Duration.zero;

  // ── ماشین حالت ──
  void _retarget() {
    if (_bounds == Size.zero) return;
    final r = math.Random();
    // هدف تصادفی داخل صفحه، با کمی حاشیه
    _target = Offset(
      c.size / 2 + r.nextDouble() * (_bounds.width - c.size),
      c.size / 2 + r.nextDouble() * (_bounds.height - c.size),
    );
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    if (c.wander) {
      _wanderTimer = Timer.periodic(c.wanderInterval, (_) {
        if (mounted && _motion == PetMotion.wait) _retarget();
      });
    }
  }

  @override
  void dispose() {
    _wanderTimer?.cancel();
    _ticker?.dispose();
    super.dispose();
  }

  void _setPointer(Offset global) {
    if (!c.followPointer || _bounds == Size.zero) return;
    _target = Offset(
      global.dx.clamp(c.size / 2, _bounds.width - c.size / 2),
      global.dy.clamp(c.size / 2, _bounds.height - c.size / 2),
    );
    if (_motion == PetMotion.sleep) _motion = PetMotion.awake;
  }

  void _tick(Duration now) {
    if (!_ready) return;
    final dt = _last == Duration.zero
        ? 1 / 60
        : ((now - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = now;

    // ── فیزیک: شتاب به سمت هدف ──
    final toTarget = _target - _pos;
    final dist = toTarget.distance;

    if (dist < c.proximityDistance) {
      // رسید — کم‌کم بایستد
      _vel = Offset.zero;
      _motion = _motion.isMoving ? PetMotion.wait : _motion;
      _idleTicks++;
      // بعد از مدتی بی‌کاری، بخوابد
      if (_idleTicks > 60 * 8 && _motion != PetMotion.sleep) {
        _motion = PetMotion.sleep;
      }
      if (c.wander && _idleTicks > 60 * 4 && _motion != PetMotion.sleep) {
        _idleTicks = 0;
        _retarget();
      }
    } else {
      _idleTicks = 0;
      final dir = toTarget / dist;
      // کاهش سرعت نزدیک هدف
      final speedCap = dist < c.deaccelerationDistance
          ? c.maxVelocity * (dist / c.deaccelerationDistance)
          : c.maxVelocity;
      _vel += dir * c.acceleration * dt;
      final sp = _vel.distance;
      if (sp > speedCap) _vel = _vel / sp * speedCap;
      _pos += _vel * dt;
      _motion = petMotionFor(_vel);
    }

    // ── برخورد با دیوار (معادل togi در ANeko) ──
    final half = c.size / 2;
    var bounced = false;
    if (_pos.dx < half) { _pos = Offset(half, _pos.dy); _vel = Offset(-_vel.dx, _vel.dy); bounced = true; }
    if (_pos.dx > _bounds.width - half) { _pos = Offset(_bounds.width - half, _pos.dy); _vel = Offset(-_vel.dx, _vel.dy); bounced = true; }
    if (_pos.dy < half) { _pos = Offset(_pos.dx, half); _vel = Offset(_vel.dx, -_vel.dy); bounced = true; }
    if (_pos.dy > _bounds.height - half) { _pos = Offset(_pos.dx, _bounds.height - half); _vel = Offset(_vel.dx, -_vel.dy); bounced = true; }
    if (bounced) {
      // هدف تازه تا در گوشه گیر نکند
      if (c.wander) _retarget();
    }

    // ── فاز اسپرایت ──
    if (_motion.isMoving) {
      _step = (now.inMilliseconds ~/ 250).isEven;
    } else {
      _step = false;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      _bounds = Size(box.maxWidth, box.maxHeight);
      if (!_ready) {
        _ready = true;
        _pos = Offset(box.maxWidth / 2, box.maxHeight * 0.7);
        _target = _pos;
        _retarget();
      }
      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerHover: (e) => _setPointer(e.position),
        onPointerDown: (e) => _setPointer(e.position),
        onPointerMove: (e) => _setPointer(e.position),
        child: Stack(children: [
          Positioned(
            left: _pos.dx - c.size / 2,
            top: _pos.dy - c.size / 2,
            child: IgnorePointer(
              child: _PetBody(
                motion: _motion,
                step: _step,
                size: c.size,
                moodOverride: widget.mood,
              ),
            ),
          ),
        ]),
      );
    });
  }
}

/// بدنه‌ی پت — شخصیت از [VzKawaii] با mood متناسب حالت.
class _PetBody extends StatelessWidget {
  final PetMotion motion;
  final bool step;
  final double size;
  final VzKawaiiMood? moodOverride;
  const _PetBody({
    required this.motion, required this.step, required this.size,
    this.moodOverride,
  });

  VzKawaiiMood get _mood {
    // اگر کاربر چهره‌ی خاصی انتخاب کرده، همان را نشان بده (مگر در خواب)
    if (moodOverride != null && motion != PetMotion.sleep) return moodOverride!;
    return switch (motion) {
      PetMotion.sleep   => VzKawaiiMood.blissful,
      PetMotion.awake   => VzKawaiiMood.shocked,
      PetMotion.wait    => VzKawaiiMood.happy,
      PetMotion.stop    => VzKawaiiMood.blissful,
      _                 => VzKawaiiMood.excited,
    };
  }

  @override
  Widget build(BuildContext context) {
    // حرکت: با هر فریم کمی خم/کشیده شود تا «راه رفتن» حس شود
    final bob = motion.isMoving ? (step ? -2.0 : 1.0) : 0.0;
    // جهت نگاه: آینه‌کردن افقی وقتی چپ می‌رود
    final facingLeft = motion == PetMotion.moveLeft ||
        motion == PetMotion.moveUpLeft ||
        motion == PetMotion.moveDownLeft;

    return Transform.translate(
      offset: Offset(0, bob),
      child: Transform.flip(
        flipX: facingLeft,
        child: VzKawaii(
          kind: VzKawaiiKind.cat,
          mood: _mood,
          color: Vz.accent,
          size: size,
        ),
      ),
    );
  }
}
