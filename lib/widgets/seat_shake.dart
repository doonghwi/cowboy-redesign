import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Wraps a seat and plays a short damped recoil shake whenever [trigger]
/// changes. Used to make a seat react when a shot lands on it — presentation
/// reacting to a game event, kept separate from the seat's own content.
class SeatShake extends StatefulWidget {
  const SeatShake({super.key, required this.trigger, required this.child});

  /// Increment this to (re)fire the shake.
  final int trigger;
  final Widget child;

  @override
  State<SeatShake> createState() => _SeatShakeState();
}

class _SeatShakeState extends State<SeatShake> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  }

  @override
  void didUpdateWidget(SeatShake old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger > 0) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        if (_c.isDismissed) return child!;
        final t = _c.value;
        final decay = (1 - t);
        final dx = math.sin(t * math.pi * 7) * 6 * decay;
        final dy = math.sin(t * math.pi * 5) * 3 * decay;
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: widget.child,
    );
  }
}
