import 'package:flutter/material.dart';

import 'effect_controller.dart';
import 'effect_spec.dart';
import 'presenters/bang_tracer.dart';
import 'presenters/hit_burst.dart';
import 'presenters/ring_effect.dart';

/// Layer 3 — renders the controller's active [EffectSpec]s as presenter
/// widgets in a non-interactive overlay. Add it on top of the game/table
/// stack. Each presenter self-animates and is removed when the controller
/// evicts its spec. Unimplemented kinds simply render nothing (added per
/// effect-upgrade cycle).
class EffectOverlay extends StatelessWidget {
  const EffectOverlay({super.key, required this.controller});
  final EffectController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              for (final spec in controller.active) _present(spec),
            ],
          );
        },
      ),
    );
  }

  Widget _present(EffectSpec spec) {
    final key = ValueKey('fx-${spec.id}');
    switch (spec.kind) {
      case EffectKind.beam:
      case EffectKind.superBeam:
        return BangTracer(key: key, spec: spec);
      case EffectKind.hitBurst:
        return HitBurst(key: key, spec: spec);
      case EffectKind.shieldRing:
      case EffectKind.trapRing:
        return RingEffect(key: key, spec: spec);
      case EffectKind.smokePuff:
      case EffectKind.curseAura:
        return SizedBox.shrink(key: key); // implemented in later cycles
    }
  }
}
