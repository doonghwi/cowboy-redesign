import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// A seat at the table. Pure view-model for the redesign prototype — game
/// logic lives in cowboy_party and is ported later. Just enough state to draw
/// a beautiful, believable table.
@immutable
class Player {
  const Player({
    required this.name,
    required this.emoji,
    required this.ammo,
    this.charId = 'commoner',
    this.maxAmmo = 6,
    this.alive = true,
    this.shielded = false,
    this.isYou = false,
    this.role,
    this.roleColor,
  });

  final String name;
  final String emoji;

  /// Character id — maps to the illustration `assets/characters/<charId>.png`.
  final String charId;
  final int ammo;
  final int maxAmmo;
  final bool alive;
  final bool shielded;
  final bool isYou;

  /// Optional character/role label (e.g. "Sniper") and its accent colour.
  final String? role;
  final Color? roleColor;

  /// Demo table — you plus five rivals around the circle.
  static const List<Player> demoTable = [
    Player(name: 'You', emoji: '🤠', charId: 'commoner', ammo: 2, isYou: true, role: 'Commoner'),
    Player(name: 'Doc', emoji: '🧑‍⚕️', charId: 'doctor', ammo: 3, shielded: true, role: 'Doctor', roleColor: CColors.accent),
    Player(name: 'Belle', emoji: '🕊️', charId: 'pacifist', ammo: 1, role: 'Pacifist', roleColor: CColors.gold),
    Player(name: 'Rio', emoji: '❓', charId: 'mystery', ammo: 0, alive: false, role: 'Mystery'),
    Player(name: 'Tex', emoji: '🎯', charId: 'sniper', ammo: 5, role: 'Sniper', roleColor: CColors.primaryBright),
    Player(name: 'Jin', emoji: '🥷', charId: 'shadow', ammo: 2, role: 'Shadow', roleColor: CColors.textLow),
  ];
}
