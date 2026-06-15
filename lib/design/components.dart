import 'package:flutter/material.dart';

import 'theme.dart';
import 'tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Reusable component library for "Desert Dusk".
///   • DuskBackground — the warm vertical gradient + subtle vignette used on
///     every screen so the whole app shares one atmosphere.
///   • CowboyButton   — primary / secondary / ghost, pressed-state animation.
///   • CowboyCard     — raised leather panel with hairline border.
///   • SectionLabel   — small all-caps eyebrow label.
/// ─────────────────────────────────────────────────────────────────────────

/// Full-bleed dusk gradient backdrop.
class DuskBackground extends StatelessWidget {
  const DuskBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CColors.bgTop, CColors.bgBottom],
        ),
      ),
      child: Stack(
        children: [
          // Soft sun-glow bloom in the upper area.
          Positioned(
            top: -120,
            right: -80,
            child: _Glow(color: CColors.primary.withValues(alpha: 0.22), size: 360),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: _Glow(color: CColors.accent.withValues(alpha: 0.12), size: 320),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

enum CButtonKind { primary, secondary, ghost }

class CowboyButton extends StatefulWidget {
  const CowboyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = CButtonKind.primary,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final CButtonKind kind;
  final IconData? icon;
  final bool expand;

  @override
  State<CowboyButton> createState() => _CowboyButtonState();
}

class _CowboyButtonState extends State<CowboyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final kind = widget.kind;

    final Color fg = switch (kind) {
      CButtonKind.primary => CColors.textHi,
      CButtonKind.secondary => CColors.accent,
      CButtonKind.ghost => CColors.textMid,
    };

    final BoxDecoration deco = switch (kind) {
      CButtonKind.primary => BoxDecoration(
          borderRadius: CRadius.brMd,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [CColors.primaryBright, CColors.primaryDeep],
          ),
          boxShadow: _down ? null : CShadow.glow(CColors.primary),
        ),
      CButtonKind.secondary => BoxDecoration(
          borderRadius: CRadius.brMd,
          color: CColors.accent.withValues(alpha: 0.10),
          border: Border.all(color: CColors.accent.withValues(alpha: 0.65), width: 1.4),
        ),
      CButtonKind.ghost => BoxDecoration(
          borderRadius: CRadius.brMd,
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: CColors.line, width: 1.2),
        ),
    };

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: fg),
          const SizedBox(width: CSpace.xs),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: CType.button(color: fg),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: CMotion.fast,
          curve: CMotion.curve,
          child: AnimatedContainer(
            duration: CMotion.fast,
            padding: const EdgeInsets.symmetric(horizontal: CSpace.lg, vertical: CSpace.md),
            decoration: deco,
            child: content,
          ),
        ),
      ),
    );
  }
}

class CowboyCard extends StatelessWidget {
  const CowboyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(CSpace.lg),
    this.onTap,
    this.accent,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  /// Optional left accent stripe colour (highlights special cards).
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    // Without an accent stripe the body is just a padded child — no Row, so
    // the card never needs a bounded height. With an accent stripe we wrap the
    // Row in IntrinsicHeight so the full-height stripe can stretch correctly.
    final Widget body = accent == null
        ? Padding(padding: padding, child: child)
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: accent),
                Expanded(child: Padding(padding: padding, child: child)),
              ],
            ),
          );

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: CRadius.brLg,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CColors.surfaceHi, CColors.surface],
        ),
        border: Border.all(color: CColors.line, width: 1),
        boxShadow: CShadow.card,
      ),
      child: ClipRRect(borderRadius: CRadius.brLg, child: body),
    );
    if (onTap == null) return card;
    return InkWell(borderRadius: CRadius.brLg, onTap: onTap, child: card);
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color = CColors.textLow});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: CType.label(color: color));
  }
}
