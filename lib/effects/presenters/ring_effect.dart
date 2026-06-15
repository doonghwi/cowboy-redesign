import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../effect_shaders.dart';
import '../effect_spec.dart';

/// Presenter for DEFENSE (shield) and TRAP rings. A fragment-shader shockwave
/// ring (ring.frag) expands from the seat while a flutter_animate icon badge
/// pops in with an easeOutBack overshoot. Parametric: kind picks icon.
class RingEffect extends StatefulWidget {
  const RingEffect({super.key, required this.spec});
  final EffectSpec spec;

  @override
  State<RingEffect> createState() => _RingEffectState();
}

class _RingEffectState extends State<RingEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.spec.duration)..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  IconData get _icon =>
      widget.spec.kind == EffectKind.trapRing ? Icons.crisis_alert : Icons.shield;

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final d = spec.anchorRadius * 3.0; // ring box (room for bloom)
    return Stack(
      fit: StackFit.expand,
      children: [
        // Shader shockwave ring, driven by the controller.
        CustomPaint(painter: _RingPainter(spec: spec, anim: _ctrl), size: Size.infinite),
        // Icon badge pop-in via flutter_animate, centred above the seat.
        Positioned(
          left: spec.from.dx - 16,
          top: spec.from.dy - d / 2 - 8,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: spec.color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: spec.color.withValues(alpha: 0.5), blurRadius: 12)],
            ),
            child: Icon(_icon, size: 18, color: Colors.white),
          )
              .animate()
              .scale(duration: 360.ms, curve: Curves.easeOutBack, begin: const Offset(0.4, 0.4), end: const Offset(1, 1))
              .fadeIn(duration: 200.ms)
              .then(delay: 120.ms)
              .fadeOut(duration: 220.ms),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.spec, required this.anim}) : super(repaint: anim);
  final EffectSpec spec;
  final Animation<double> anim;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = EffectShaders.ring;
    final t = spec.curve.transform(anim.value.clamp(0.0, 1.0));
    final d = (spec.anchorRadius * 3.0).ceilToDouble();

    // Reliable Canvas base: an expanding ring with a soft glow that peaks
    // mid-pop. Guarantees the effect is visible; the shader adds bloom.
    final life = (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
    final r = spec.anchorRadius * (0.55 + t * 0.85);
    canvas.drawCircle(
      spec.from,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..color = spec.color.withValues(alpha: 0.28 * life)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(
      spec.from,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = spec.color.withValues(alpha: 0.95 * life),
    );

    if (shader != null) {
      shader.setFloat(0, d);
      shader.setFloat(1, d);
      shader.setFloat(2, spec.color.r);
      shader.setFloat(3, spec.color.g);
      shader.setFloat(4, spec.color.b);
      shader.setFloat(5, 1.0);
      shader.setFloat(6, t);
      final rec = ui.PictureRecorder();
      Canvas(rec).drawRect(Rect.fromLTWH(0, 0, d, d), Paint()..shader = shader);
      final img = rec.endRecording().toImageSync(d.toInt(), d.toInt());
      canvas.drawImage(img, Offset(spec.from.dx - d / 2, spec.from.dy - d / 2),
          Paint()..blendMode = BlendMode.plus);
      img.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => true;
}
