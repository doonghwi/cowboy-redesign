import 'dart:math' as math;

import 'package:flame/particles.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart';

import '../effect_spec.dart';

/// Presenter for a hit / kill: a radial Flame particle burst plus a quick
/// expanding shock ring at the seat.
class HitBurst extends StatefulWidget {
  const HitBurst({super.key, required this.spec});
  final EffectSpec spec;

  @override
  State<HitBurst> createState() => _HitBurstState();
}

class _HitBurstState extends State<HitBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Particle _debris;
  double _lastT = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.spec.duration)..forward();
    _debris = _build();
  }

  Particle _build() {
    final spec = widget.spec;
    final rnd = math.Random(spec.id * 7919 + 3);
    final life = spec.duration.inMilliseconds / 1000.0;
    return Particle.generate(
      count: 18,
      lifespan: life,
      generator: (i) {
        final a = (i / 18) * math.pi * 2 + rnd.nextDouble() * 0.4;
        final speed = 120 * (0.5 + rnd.nextDouble());
        final radius = 2.6 * (0.6 + rnd.nextDouble());
        return AcceleratedParticle(
          speed: Vector2(math.cos(a), math.sin(a)) * speed,
          acceleration: Vector2(0, 140), // gravity
          child: ComputedParticle(
            renderer: (canvas, p) {
              final paint = Paint()
                ..color = spec.color.withValues(alpha: (1 - p.progress).clamp(0.0, 1.0));
              canvas.drawCircle(Offset.zero, radius * (1 - p.progress * 0.5), paint);
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
        if (dt > 0) _debris.update(dt);
        return CustomPaint(
          painter: _HitPainter(spec: widget.spec, t: t, debris: _debris),
          size: Size.infinite,
        );
      },
    );
  }
}

class _HitPainter extends CustomPainter {
  _HitPainter({required this.spec, required this.t, required this.debris});
  final EffectSpec spec;
  final double t;
  final Particle debris;

  @override
  void paint(Canvas canvas, Size size) {
    final c = spec.from;
    final p = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
    // Expanding shock ring.
    final ringR = 8 + p * spec.anchorRadius;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * (1 - p)
      ..color = spec.color.withValues(alpha: (1 - p).clamp(0.0, 1.0));
    canvas.drawCircle(c, ringR, ring);

    canvas.save();
    canvas.translate(c.dx, c.dy);
    debris.render(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HitPainter old) => true;
}
