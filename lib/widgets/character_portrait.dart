import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Renders a character's illustration from `assets/characters/<id>.png` when
/// the user has supplied one, falling back to a styled code placeholder (emoji
/// in a tinted medallion) when the PNG is missing. No image-generation here —
/// PNGs are dropped in by hand; see art/CHARACTER_PROMPTS.md.
class CharacterPortrait extends StatelessWidget {
  const CharacterPortrait({
    super.key,
    required this.id,
    required this.emoji,
    required this.color,
    this.size = 56,
    this.showRing = true,
  });

  final String id;
  final String emoji;
  final Color color;
  final double size;
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    final ring = showRing
        ? Border.all(color: color.withValues(alpha: 0.55), width: 1.6)
        : null;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.14), CColors.surface],
        ),
        border: ring,
      ),
      child: Image.asset(
        'assets/characters/$id.png',
        fit: BoxFit.cover,
        width: size,
        height: size,
        // PNG not supplied yet → graceful emoji placeholder.
        errorBuilder: (context, error, stack) => _Placeholder(emoji: emoji, size: size),
        // Avoid a flash of nothing while decoding.
        frameBuilder: (context, child, frame, wasSync) {
          if (wasSync || frame != null) return child;
          return _Placeholder(emoji: emoji, size: size);
        },
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.emoji, required this.size});
  final String emoji;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(emoji, style: TextStyle(fontSize: size * 0.46)),
    );
  }
}
