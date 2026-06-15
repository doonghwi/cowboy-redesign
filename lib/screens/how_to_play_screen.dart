import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/theme.dart';
import '../design/tokens.dart';

/// How to play — a calm, scannable guide to the core moves and win conditions,
/// drawn in the Desert Dusk style. Static content; no game state.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static const _moves = <_Move>[
    _Move('🔄', 'Reload', 'Add a bullet (up to 6). You need ammo before you can fire.', CColors.accent),
    _Move('🛡️', 'Defend', 'Block every normal shot aimed at you this turn.', CColors.gold),
    _Move('🔫', 'Bang!', 'Spend one bullet to shoot a rival. Can\'t fire on turn one.', CColors.primaryBright),
    _Move('💥', 'Super Bang', 'At full ammo, spend five to ignore shields and traps.', CColors.danger),
    _Move('😶', 'Idle', 'Do nothing. Auto-picked if your 20s timer runs out.', CColors.textLow),
  ];

  static const _wins = <_Move>[
    _Move('🏆', 'Last standing', 'Be the only cowboy left alive to win the round.', CColors.gold),
    _Move('🕊️', 'Pacifist', 'Reload six times and survive for an instant win.', CColors.accent),
    _Move('🤺', 'Duelist', 'Reach a two-player showdown and you win the draw.', CColors.primaryBright),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DuskBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(CSpace.md, 0, CSpace.md, CSpace.lg),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: CSpace.xs),
                          Text(
                            'Everyone picks one move at the same time, then all moves reveal and resolve together. Read your rivals — bluff, bait, and outdraw them.',
                            style: CType.body(size: 14),
                          ),
                          const SizedBox(height: CSpace.lg),
                          const SectionLabel('Your moves'),
                          const SizedBox(height: CSpace.xs),
                          for (final m in _moves) _MoveCard(move: m),
                          const SizedBox(height: CSpace.md),
                          const SectionLabel('Ways to win'),
                          const SizedBox(height: CSpace.xs),
                          for (final m in _wins) _MoveCard(move: m, accentStripe: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Move {
  const _Move(this.emoji, this.title, this.body, this.color);
  final String emoji;
  final String title;
  final String body;
  final Color color;
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(CSpace.sm, CSpace.xs, CSpace.md, CSpace.xs),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: CColors.textMid, size: 18),
          ),
          Text('How to play', style: CType.heading(size: 22)),
        ],
      ),
    );
  }
}

class _MoveCard extends StatelessWidget {
  const _MoveCard({required this.move, this.accentStripe = false});
  final _Move move;
  final bool accentStripe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CSpace.xs),
      child: CowboyCard(
        padding: const EdgeInsets.all(CSpace.sm),
        accent: accentStripe ? move.color : null,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: move.color.withValues(alpha: 0.12),
                border: Border.all(color: move.color.withValues(alpha: 0.5), width: 1.4),
              ),
              child: Text(move.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: CSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(move.title, style: CType.title(size: 15, color: move.color)),
                  const SizedBox(height: 2),
                  Text(move.body, style: CType.body(size: 12.5, color: CColors.textMid)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
