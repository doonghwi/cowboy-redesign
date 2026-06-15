import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../models/player.dart';

/// A single seat around the table: avatar token, name, ammo pips, and status
/// (alive / shielded / down). Compact so six fit around a circle on a phone.
class PlayerSeat extends StatelessWidget {
  const PlayerSeat({super.key, required this.player, this.highlight = false});

  final Player player;

  /// Whether it's this player's turn / focused.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final alive = player.alive;
    final accent = player.roleColor ?? CColors.primary;

    return Opacity(
      opacity: alive ? 1 : 0.42,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Avatar(player: player, highlight: highlight, accent: accent),
          const SizedBox(height: CSpace.xs),
          Text(
            player.name,
            style: CType.title(size: 13, color: player.isYou ? CColors.gold : CColors.textHi),
          ),
          if (player.role != null)
            Text(player.role!.toUpperCase(), style: CType.label(size: 9, color: accent)),
          const SizedBox(height: CSpace.xxs),
          _AmmoPips(ammo: player.ammo, maxAmmo: player.maxAmmo, alive: alive),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.player, required this.highlight, required this.accent});
  final Player player;
  final bool highlight;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CColors.surfaceHi, CColors.surface],
        ),
        border: Border.all(
          color: highlight ? CColors.gold : accent.withValues(alpha: player.alive ? 0.7 : 0.3),
          width: highlight ? 2.4 : 1.6,
        ),
        boxShadow: highlight ? CShadow.glow(CColors.gold) : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(player.emoji, style: const TextStyle(fontSize: 26)),
          if (player.shielded)
            const Positioned(
              right: -2,
              bottom: -2,
              child: _StatusDot(icon: Icons.shield, color: CColors.accent),
            ),
          if (!player.alive)
            const Positioned(
              right: -2,
              bottom: -2,
              child: _StatusDot(icon: Icons.close, color: CColors.danger),
            ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.icon, required this.color});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: CColors.ink,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.4),
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }
}

class _AmmoPips extends StatelessWidget {
  const _AmmoPips({required this.ammo, required this.maxAmmo, required this.alive});
  final int ammo;
  final int maxAmmo;
  final bool alive;

  @override
  Widget build(BuildContext context) {
    // Show up to 6 pips; filled = loaded round.
    final count = maxAmmo.clamp(0, 6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final filled = i < ammo;
        return Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? CColors.primaryBright : Colors.transparent,
            border: Border.all(
              color: filled ? CColors.primaryBright : CColors.line,
              width: 1.2,
            ),
          ),
        );
      }),
    );
  }
}
