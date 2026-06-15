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
/// cowboy_party's roster but only the copy needed to render a shop card.
@immutable
class Character {
  const Character({
    required this.name,
    required this.emoji,
    required this.tagline,
    required this.price,
    required this.rarity,
    this.owned = false,
  });

  final String name;
  final String emoji;
  final String tagline;
  final int price;
  final Rarity rarity;
  final bool owned;

  /// Curated Saloon catalogue (subset of the full cowboy_party roster).
  static const List<Character> catalog = [
    Character(name: 'Commoner', emoji: '🤠', tagline: 'No tricks — just grit.', price: 0, rarity: Rarity.common, owned: true),
    Character(name: 'Prepper', emoji: '🎒', tagline: 'Starts with a round chambered.', price: 1000, rarity: Rarity.common, owned: true),
    Character(name: 'Sniper', emoji: '🎯', tagline: '20% chance to pierce a shield.', price: 1500, rarity: Rarity.rare),
    Character(name: 'Doctor', emoji: '🧑‍⚕️', tagline: 'Survives one lethal hit per game.', price: 2500, rarity: Rarity.rare),
    Character(name: 'Smoker', emoji: '🚬', tagline: 'Smoke screen — 50% dodge, twice.', price: 3000, rarity: Rarity.rare),
    Character(name: 'Hunter', emoji: '🪤', tagline: 'Trap reflects bullets back.', price: 3500, rarity: Rarity.epic),
    Character(name: 'Duelist', emoji: '🤺', tagline: 'Always wins the showdown.', price: 4500, rarity: Rarity.epic),
    Character(name: 'Pacifist', emoji: '🕊️', tagline: 'Reload six times to win.', price: 5000, rarity: Rarity.epic),
    Character(name: 'Shadow', emoji: '🥷', tagline: 'Ammo & moves stay hidden.', price: 5500, rarity: Rarity.epic),
    Character(name: 'Voodoo', emoji: '🪬', tagline: 'Curse — target dies in 10 turns.', price: 7500, rarity: Rarity.legend),
    Character(name: 'Mystery', emoji: '❓', tagline: 'A random role every game.', price: 10000, rarity: Rarity.legend),
  ];
}
