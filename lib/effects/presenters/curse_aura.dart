import 'dart:math' as math;

import 'package:flame/particles.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart';

import '../effect_spec.dart';

/// Presenter for CURSE (부두 저주): a wavering purple tether snakes from the
/// caster to the target, then a pulsing aura + rising motes settle over the
/// cursed seat.
class CurseAura extends StatefulWidget {
  const CurseAura({super.key, required this.spec});
  final EffectSpec spec;

  @override
  State<CurseAura> createState() => _CurseAuraState();
}

class _CurseAuraState extends State<CurseAura> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Particle _motes;
  double _lastT = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.spec.duration)..forward();
    _motes = _build();
  }

  Particle _build() {
    final spec = widget.spec;
    final rnd = math.Random(spec.id * 2663 + 5);
    final life = spec.duration.inMilliseconds / 1000.0;
    return Particle.generate(
      count: 12,
      lifespan: life,
      generator: (i) {
        final a = rnd.nextDouble() * math.pi * 2;
        final spread = 6 + rnd.nextDouble() * 22;
        final start = Vector2(math.cos(a) * spread, math.sin(a) * spread);
        return AcceleratedParticle(
          position: start,
          speed: Vector2((rnd.nextDouble() - 0.5) * 18, -26 - rnd.nextDouble() * 26),
          acceleration: Vector2(0, 4),
          child: ComputedParticle(
            renderer: (canvas, p) {
              final alpha = (math.sin(p.progress * math.pi)).clamp(0.0, 1.0);
              final paint = Paint()
                ..color = spec.color.withValues(alpha: alpha * 0.9)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
              canvas.drawCircle(Offset.zero, 2.4 * (1 - p.progress * 0.4), paint);
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
        if (dt > 0) _motes.update(dt);
        return CustomPaint(
          painter: _CursePainter(spec: widget.spec, t: t, motes: _motes),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CursePainter extends CustomPainter {
  _CursePainter({required this.spec, required this.t, required this.motes});
  final EffectSpec spec;
  final double t;
  final Particle motes;

  @override
  void paint(Canvas canvas, Size size) {
    final from = spec.from;
    final to = spec.to;
    final color = spec.color;

    // Phase 1 (0..0.45): wavering tether travels from caster to target.
    final travel = (t / 0.45).clamp(0.0, 1.0);
    if (from != to && travel < 1.0) {
      final dir = to - from;
      final n = 24;
      final path = Path()..moveTo(from.dx, from.dy);
      for (var i = 1; i <= n; i++) {
        final f = (i / n) * travel;
        final base = from + dir * f;
        final perp = Offset(-dir.dy, dir.dx) / dir.distance;
        final wobble = math.sin(f * 18 + t * 12) * 8 * (1 - f);
        final pt = base + perp * wobble;
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color.withValues(alpha: 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    // Phase 2 (0.35..1): pulsing aura settles over the target.
    if (t > 0.35) {
      final p = ((t - 0.35) / 0.65).clamp(0.0, 1.0);
      final pulse = 0.6 + 0.4 * math.sin(t * 16);
      final fade = (1 - (p - 0.7).clamp(0.0, 0.3) / 0.3);
      final glow = Paint()
        ..color = color.withValues(alpha: 0.4 * fade * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(to, spec.anchorRadius * (0.7 + 0.15 * pulse), glow);
      canvas.drawCircle(
        to,
        spec.anchorRadius * 0.85,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: 0.8 * fade),
      );

      canvas.save();
      canvas.translate(to.dx, to.dy);
      motes.render(canvas);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CursePainter old) => true;
}
