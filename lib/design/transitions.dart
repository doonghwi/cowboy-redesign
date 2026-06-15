import 'package:flutter/material.dart';

import 'tokens.dart';

/// Shared page transition for the Desert Dusk app: a soft fade combined with a
/// small upward slide, so navigation feels intentional and premium rather than
/// using the default platform push. Use everywhere instead of MaterialPageRoute.
Route<T> cowboyRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: CMotion.base,
    reverseTransitionDuration: CMotion.fast,
    pageBuilder: (context, animation, secondary) => page,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: CMotion.curve);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
