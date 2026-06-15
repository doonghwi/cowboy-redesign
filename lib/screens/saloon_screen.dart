import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../models/character.dart';
import '../widgets/character_portrait.dart';

/// The Saloon — the character shop. A responsive grid of character cards over
/// the shared dusk backdrop, with the player's coin balance pinned to the top.
class SaloonScreen extends StatelessWidget {
  const SaloonScreen({super.key, this.coins = 1250, this.catalog = Character.catalog});

  final int coins;
  final List<Character> catalog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DuskBackground(
        child: SafeArea(
          child: Column(
            children: [
              _SaloonHeader(coins: coins),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final columns = (c.maxWidth ~/ 220).clamp(2, 4); // 2 on phones, more on wide screens
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(CSpace.md, CSpace.xs, CSpace.md, CSpace.lg),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: CSpace.sm,
                        mainAxisSpacing: CSpace.sm,
                        childAspectRatio: 0.74,
                      ),
                      itemCount: catalog.length,
                      itemBuilder: (context, i) =>
                          CharacterCard(character: catalog[i], affordable: coins >= catalog[i].price),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaloonHeader extends StatelessWidget {
  const _SaloonHeader({required this.coins});
  final int coins;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(CSpace.sm, CSpace.xs, CSpace.md, CSpace.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: CColors.textMid, size: 18),
          ),
          Text('Saloon', style: CType.heading(size: 22)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: CSpace.md, vertical: CSpace.xs),
            decoration: BoxDecoration(
              borderRadius: CRadius.brSm,
              color: CColors.gold.withValues(alpha: 0.12),
              border: Border.all(color: CColors.gold.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, size: 18, color: CColors.gold),
                const SizedBox(width: CSpace.xs),
                Text('$coins', style: CType.stat(size: 18, color: CColors.gold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  const CharacterCard({super.key, required this.character, required this.affordable});
  final Character character;
  final bool affordable;

  @override
  Widget build(BuildContext context) {
    final r = character.rarity;
    return CowboyCard(
      padding: const EdgeInsets.all(CSpace.sm),
      accent: r.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: SectionLabel(r.label, color: r.color),
          ),
          const SizedBox(height: CSpace.xxs),
          Center(
            child: CharacterPortrait(
              id: character.id,
              emoji: character.emoji,
              color: r.color,
              size: 60,
            ),
          ),
          const SizedBox(height: CSpace.xs),
          Text(character.name, style: CType.title(size: 15), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              character.tagline,
              style: CType.body(size: 11.5, color: CColors.textLow),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: CSpace.xs),
          _BuyChip(character: character, affordable: affordable),
        ],
      ),
    );
  }
}

class _BuyChip extends StatelessWidget {
  const _BuyChip({required this.character, required this.affordable});
  final Character character;
  final bool affordable;

  @override
  Widget build(BuildContext context) {
    if (character.owned) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: CSpace.xs),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: CRadius.brSm,
          color: CColors.success.withValues(alpha: 0.14),
          border: Border.all(color: CColors.success.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, size: 14, color: CColors.success),
            const SizedBox(width: CSpace.xxs),
            Text('Owned', style: CType.label(size: 11, color: CColors.success)),
          ],
        ),
      );
    }
    final color = affordable ? CColors.gold : CColors.textLow;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: CSpace.xs),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: CRadius.brSm,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monetization_on, size: 14, color: color),
          const SizedBox(width: CSpace.xxs),
          Text('${character.price}', style: CType.label(size: 12, color: color)),
        ],
      ),
    );
  }
}
