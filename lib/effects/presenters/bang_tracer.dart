import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/particles.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart';

import '../effect_shaders.dart';
import '../effect_spec.dart';

/// Presenter for BANG / SUPER BANG: a fragment-shader beam from shooter to
/// target, a Flame particle muzzle burst at the source, and an arrow head +
/// impact flash at the target. Self-animates over [spec.duration].
class BangTracer extends StatefulWidget {
  const BangTracer({super.key, required this.spec});
  final EffectSpec spec;

  @override
  State<BangTracer> createState() => _BangTracerState();
}

class _BangTracerState extends State<BangTracer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Particle _muzzle;
  double _lastT = 0;

  @override
  void initState() {
    super.initState();
    final spec = widget.spec;
    _ctrl = AnimationController(vsync: this, duration: spec.duration)..forward();
    _muzzle = _buildMuzzle(spec);
  }

  Particle _buildMuzzle(EffectSpec spec) {
    final rnd = math.Random(spec.id * 9973 + 7);
    final super_ = spec.kind == EffectKind.superBeam;
    final dir = spec.to - spec.from;
    final baseAngle = math.atan2(dir.dy, dir.dx);
    final count = super_ ? 26 : 16;
    final life = spec.duration.inMilliseconds / 1000.0;
    return Particle.generate(
      count: count,
      lifespan: life,
      generator: (i) {
        // Spray forward along the beam with a cone of spread.
        final spread = (rnd.nextDouble() - 0.5) * (super_ ? 1.5 : 1.1);
        final a = baseAngle + spread;
        final speed = (super_ ? 220 : 150) * (0.4 + rnd.nextDouble());
        final radius = (super_ ? 3.5 : 2.4) * (0.6 + rnd.nextDouble());
        return AcceleratedParticle(
          speed: Vector2(math.cos(a), math.sin(a)) * speed,
          acceleration: Vector2(math.cos(a), math.sin(a)) * -speed * 0.8,
          child: ComputedParticle(
            renderer: (canvas, p) {
              final paint = Paint()
                ..color = Color.lerp(Colors.white, spec.color, p.progress)!
                    .withValues(alpha: (1 - p.progress).clamp(0.0, 1.0))
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6);
              canvas.drawCircle(Offset.zero, radius * (1 - p.progress * 0.4), paint);
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
        final dt = ((t - _lastT) * widget.spec.duration.inMilliseconds / 1000.0);
        _lastT = t;
        if (dt > 0) _muzzle.update(dt);
        return CustomPaint(
          painter: _BangPainter(spec: widget.spec, t: t, muzzle: _muzzle),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BangPainter extends CustomPainter {
  _BangPainter({required this.spec, required this.t, required this.muzzle});
  final EffectSpec spec;
  final double t;
  final Particle muzzle;

  @override
  void paint(Canvas canvas, Size size) {
    final from = spec.from;
    final to = spec.to;
    final dir = to - from;
    final length = dir.distance;
    if (length < 1) return;
    final angle = math.atan2(dir.dy, dir.dx);
    final isSuper = spec.kind == EffectKind.superBeam;
    final thickness = isSuper ? 34.0 : 24.0;

    // Beam progress (head travel + fade-out tail).
    final progress = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
    final fade = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3).clamp(0.0, 1.0);
    final headPos = from + dir * progress;

    // Base layer — a reliable multi-stroke Canvas glow line up to the head.
    // (The shader bloom below enhances this; the line guarantees visibility.)
    if (fade > 0.01) {
      final glowPaint = Paint()
        ..color = spec.color.withValues(alpha: 0.35 * fade)
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isSuper ? 10 : 7);
      final corePaint = Paint()
        ..color = spec.color.withValues(alpha: 0.95 * fade)
        ..strokeWidth = isSuper ? 6 : 4
        ..strokeCap = StrokeCap.round;
      final innerPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9 * fade)
        ..strokeWidth = isSuper ? 2.4 : 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, headPos, glowPaint);
      canvas.drawLine(from, headPos, corePaint);
      canvas.drawLine(from, headPos, innerPaint);
    }

    final shader = EffectShaders.beam;
    if (shader != null && fade > 0.01) {
      shader.setFloat(0, length);
      shader.setFloat(1, thickness);
      shader.setFloat(2, spec.color.r);
      shader.setFloat(3, spec.color.g);
      shader.setFloat(4, spec.color.b);
      shader.setFloat(5, fade);
      shader.setFloat(6, progress);
      // Render the beam into an origin-anchored picture so FlutterFragCoord
      // maps cleanly to 0..size, then composite it rotated onto the canvas.
      final w = length.ceil().clamp(1, 4096);
      final h = thickness.ceil();
      final rec = ui.PictureRecorder();
      Canvas(rec).drawRect(Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()), Paint()..shader = shader);
      final img = rec.endRecording().toImageSync(w, h);
      canvas.save();
      canvas.translate(from.dx, from.dy);
      canvas.rotate(angle);
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromLTWH(0, -thickness / 2, length, thickness),
        Paint()..blendMode = BlendMode.plus,
      );
      canvas.restore();
      img.dispose();

      // Arrow head at the travelling beam tip.
      _arrow(canvas, headPos, dir / length, spec.color.withValues(alpha: fade), isSuper ? 16 : 11);
    }

    // Impact flash at the target, after the beam mostly arrives.
    if (progress > 0.8) {
      final pulse = ((progress - 0.8) / 0.2).clamp(0.0, 1.0);
      final glow = Paint()
        ..color = spec.color.withValues(alpha: 0.5 * fade * (1 - pulse))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(to, (isSuper ? 26 : 16) * (0.5 + pulse), glow);
    }

    // Muzzle particles, drawn at the source.
    canvas.save();
    canvas.translate(from.dx, from.dy);
    muzzle.render(canvas);
    canvas.restore();
  }

  void _arrow(Canvas canvas, Offset tip, Offset unit, Color color, double s) {
    final perp = Offset(-unit.dy, unit.dx);
    final back = tip - unit * s;
    final p = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(back.dx + perp.dx * s * 0.6, back.dy + perp.dy * s * 0.6)
      ..lineTo(back.dx - perp.dx * s * 0.6, back.dy - perp.dy * s * 0.6)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BangPainter old) => true;
}
