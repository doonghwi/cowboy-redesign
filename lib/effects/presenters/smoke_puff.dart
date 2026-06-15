import 'dart:math' as math;

import 'package:flame/particles.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart';

import '../effect_spec.dart';

/// Presenter for SMOKE (스모커 연막): a soft Flame particle cloud that billows
/// up and out around the seat, growing and fading — a dodge/concealment puff.
class SmokePuff extends StatefulWidget {
  const SmokePuff({super.key, required this.spec});
  final EffectSpec spec;

  @override
  State<SmokePuff> createState() => _SmokePuffState();
}

class _SmokePuffState extends State<SmokePuff> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Particle _cloud;
  double _lastT = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.spec.duration)..forward();
    _cloud = _build();
  }

  Particle _build() {
    final spec = widget.spec;
    final rnd = math.Random(spec.id * 5381 + 11);
    final life = spec.duration.inMilliseconds / 1000.0;
    return Particle.generate(
      count: 16,
      lifespan: life,
      generator: (i) {
        final a = rnd.nextDouble() * math.pi * 2;
        final spread = 20 + rnd.nextDouble() * 26;
        // Drift outward and gently upward.
        final vx = math.cos(a) * (14 + rnd.nextDouble() * 22);
        final vy = -30 - rnd.nextDouble() * 40;
        final baseR = 14 + rnd.nextDouble() * 16;
        final start = Vector2(math.cos(a) * spread, math.sin(a) * spread * 0.5);
        return AcceleratedParticle(
          position: start,
          speed: Vector2(vx, vy),
          acceleration: Vector2(0, 8),
          child: ComputedParticle(
            renderer: (canvas, p) {
              // Puff grows then fades; soft blurred grey.
              final grow = 0.5 + p.progress * 0.9;
              final alpha = (math.sin(p.progress * math.pi) * 0.5).clamp(0.0, 1.0);
              final paint = Paint()
                ..color = Color.lerp(spec.color, Colors.white, 0.2)!.withValues(alpha: alpha)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
              canvas.drawCircle(Offset.zero, baseR * grow, paint);
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final dt = (t - _lastT) * widget.spec.duration.inMilliseconds / 1000.0;
        _lastT = t;
        if (dt > 0) _cloud.update(dt);
        return CustomPaint(
          painter: _SmokePainter(spec: widget.spec, cloud: _cloud),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SmokePainter extends CustomPainter {
  _SmokePainter({required this.spec, required this.cloud});
  final EffectSpec spec;
  final Particle cloud;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(spec.from.dx, spec.from.dy);
    cloud.render(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SmokePainter old) => true;
}
