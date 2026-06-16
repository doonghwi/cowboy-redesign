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

  // The illustrations are chest-up bust portraits, so the face sits in the
  // upper-middle of the square. Zoom in and bias upward so the FACE fills the
  // circular avatar instead of the chest. Tuned by screenshot across chars.
  static const double _zoom = 1.85;
  static const Alignment _faceAlign = Alignment(0, -0.58);

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
      child: OverflowBox(
        maxWidth: size * _zoom,
        maxHeight: size * _zoom,
        alignment: _faceAlign,
        child: Image.asset(
          'assets/characters/$id.png',
          fit: BoxFit.cover,
          width: size * _zoom,
          height: size * _zoom,
          // PNG not supplied yet → graceful emoji placeholder (un-zoomed).
          errorBuilder: (context, error, stack) => _Placeholder(emoji: emoji, size: size),
          // Avoid a flash of nothing while decoding.
          frameBuilder: (context, child, frame, wasSync) {
            if (wasSync || frame != null) return child;
            return _Placeholder(emoji: emoji, size: size);
          },
        ),
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
