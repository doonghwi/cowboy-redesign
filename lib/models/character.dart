import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Rarity tiers drive the card accent colour and price banding.
enum Rarity { common, rare, epic, legend }

extension RarityStyle on Rarity {
  Color get color => switch (this) {
        Rarity.common => CColors.textLow,
        Rarity.rare => CColors.accent,
        Rarity.epic => CColors.primaryBright,
        Rarity.legend => CColors.gold,
      };
  String get label => switch (this) {
        Rarity.common => 'Common',
        Rarity.rare => 'Rare',
        Rarity.epic => 'Epic',
        Rarity.legend => 'Legend',
      };
}

/// A buyable cowboy character. View-model for the Saloon; abilities mirror
/// cowboy_party's roster. [id] matches the illustration filename
/// (`assets/characters/<id>.png`) and the prompt id in art/CHARACTER_PROMPTS.md.
@immutable
class Character {
  const Character({
    required this.id,
    required this.name,
    required this.emoji,
    required this.tagline,
    required this.price,
    required this.rarity,
    this.owned = false,
  });

  final String id;
  final String name;
  final String emoji;
  final String tagline;
  final int price;
  final Rarity rarity;
  final bool owned;

  /// Full Saloon catalogue — all 16 characters (ids match CHARACTER_PROMPTS.md).
  static const List<Character> catalog = [
    Character(id: 'commoner', name: 'Commoner', emoji: '🤠', tagline: 'No tricks — just grit.', price: 0, rarity: Rarity.common, owned: true),
    Character(id: 'prepper', name: 'Prepper', emoji: '🎒', tagline: 'Starts with a round chambered.', price: 1000, rarity: Rarity.common, owned: true),
    Character(id: 'sniper', name: 'Sniper', emoji: '🎯', tagline: '20% chance to pierce a shield.', price: 1500, rarity: Rarity.rare),
    Character(id: 'speedloader', name: 'Speedloader', emoji: '⚙️', tagline: '50% chance to load two at once.', price: 2000, rarity: Rarity.rare),
    Character(id: 'doctor', name: 'Doctor', emoji: '🧑‍⚕️', tagline: 'Survives one lethal hit per game.', price: 2500, rarity: Rarity.rare),
    Character(id: 'smoker', name: 'Smoker', emoji: '🚬', tagline: 'Smoke screen — 50% dodge, twice.', price: 3000, rarity: Rarity.rare),
    Character(id: 'hunter', name: 'Hunter', emoji: '🪤', tagline: 'Trap reflects bullets back.', price: 3500, rarity: Rarity.epic),
    Character(id: 'resetter', name: 'Resetter', emoji: '🔄', tagline: 'Nullify everyone\'s move once.', price: 4000, rarity: Rarity.epic),
    Character(id: 'duelist', name: 'Duelist', emoji: '🤺', tagline: 'Always wins the showdown.', price: 4500, rarity: Rarity.epic),
    Character(id: 'pacifist', name: 'Pacifist', emoji: '🕊️', tagline: 'Reload six times to win.', price: 5000, rarity: Rarity.epic),
    Character(id: 'shadow', name: 'Shadow', emoji: '🥷', tagline: 'Ammo & moves stay hidden.', price: 5500, rarity: Rarity.epic),
    Character(id: 'roulette', name: 'Roulette', emoji: '🎰', tagline: '50:50 fate trigger, always on.', price: 6000, rarity: Rarity.epic),
    Character(id: 'dualgun', name: 'Dualgun', emoji: '🔫', tagline: 'Two bullets, two targets at once.', price: 6500, rarity: Rarity.legend),
    Character(id: 'paparazzi', name: 'Paparazzi', emoji: '📸', tagline: 'Peek one rival\'s move first.', price: 7000, rarity: Rarity.legend),
    Character(id: 'voodoo', name: 'Voodoo', emoji: '🪬', tagline: 'Curse — target dies in 10 turns.', price: 7500, rarity: Rarity.legend),
    Character(id: 'mystery', name: 'Mystery', emoji: '❓', tagline: 'A random role every game.', price: 10000, rarity: Rarity.legend),
  ];
}
