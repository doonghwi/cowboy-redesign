import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../design/theme.dart';
import '../effect_spec.dart';

/// Presenter for SUPER BANG's full-screen flash — a dramatic dark vignette with
/// a stroked "SUPER BANG" wordmark and a bolt: pops in with an overshoot, a
/// quick shake, then fades out. Driven by an explicit AnimationController
/// (renders reliably under headless capture, unlike declarative tickers).
class SuperFlash extends StatefulWidget {
  const SuperFlash({super.key, required this.spec});
  final EffectSpec spec;

  @override
  State<SuperFlash> createState() => _SuperFlashState();
}

class _SuperFlashState extends State<SuperFlash> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.spec.duration)..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final pop = t < 0.2 ? Curves.easeOutBack.transform(t / 0.2) : 1.0;
          final out = t > 0.72 ? (t - 0.72) / 0.28 : 0.0;
          final fade = (1 - out).clamp(0.0, 1.0);
          final scale = 0.55 + 0.45 * pop + out * 0.16;
          final shake = t < 0.45 ? math.sin(t * 60) * (0.45 - t) / 0.45 * 7 : 0.0;

          return Opacity(
            opacity: fade,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.9,
                  colors: [Color(0x00000000), Color(0xAA000000)],
                  stops: [0.42, 1.0],
                ),
              ),
              child: Center(
                child: Transform.translate(
                  offset: Offset(shake, 0),
                  child: Transform.scale(
                    scale: scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, size: 64, color: widget.spec.color, shadows: [
                          Shadow(color: widget.spec.color.withValues(alpha: 0.85), blurRadius: 26),
                        ]),
                        const SizedBox(height: 4),
                        Stack(
                          children: [
                            // Stroke layer — built without a colour so foreground is allowed.
                            Text('SUPER BANG',
                                style: GoogleFonts.bitter(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 9
                                    ..strokeJoin = StrokeJoin.round
                                    ..color = const Color(0xFF7A1408),
                                )),
                            Text('SUPER BANG', style: CType.display(size: 40, color: widget.spec.color)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
