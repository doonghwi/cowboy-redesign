import 'package:flutter/material.dart';

/// Layer 2 output — an effect described purely as DATA: kind, anchor points,
/// timing, curve, colour. Presenters consume this; they hold no game knowledge.
enum EffectKind { beam, superBeam, shieldRing, trapRing, smokePuff, curseAura, hitBurst }

@immutable
class EffectSpec {
  const EffectSpec({
    required this.id,
    required this.kind,
    required this.from,
    required this.to,
    required this.duration,
    required this.color,
    this.curve = Curves.easeOutCubic,
    this.anchorRadius = 44,
  });

  final int id;
  final EffectKind kind;

  /// Source anchor (e.g. shooter seat / the affected seat).
  final Offset from;

  /// Destination anchor (target seat). Equals [from] for self-centred effects.
  final Offset to;

  final Duration duration;
  final Color color;
  final Curve curve;

  /// Seat token radius — sizes rings/auras around a seat.
  final double anchorRadius;
}
