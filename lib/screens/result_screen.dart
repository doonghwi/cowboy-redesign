import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../models/player.dart';

/// End-of-round result screen — celebrates the last cowboy standing (or
/// commiserates a loss), shows the rewards earned and the final standings.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    this.won = true,
    this.coinsEarned = 320,
    this.standings = Player.demoTable,
  });

  final bool won;
  final int coinsEarned;
  final List<Player> standings;

  @override
  Widget build(BuildContext context) {
    final accent = won ? CColors.gold : CColors.danger;
    final winner = standings.firstWhere((p) => p.isYou, orElse: () => standings.first);

    return Scaffold(
      body: DuskBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(CSpace.lg, CSpace.xl, CSpace.lg, CSpace.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Banner(won: won, accent: accent),
                      const SizedBox(height: CSpace.lg),
                      _WinnerBadge(winner: winner, accent: accent, won: won),
                      const SizedBox(height: CSpace.lg),
                      _Rewards(coins: coinsEarned, won: won),
                      const SizedBox(height: CSpace.lg),
                      const SectionLabel('Final standings'),
                      const SizedBox(height: CSpace.xs),
                      _Standings(standings: standings),
                      const SizedBox(height: CSpace.xl),
                      CowboyButton(
                        label: 'Play again',
                        icon: Icons.replay_rounded,
                        expand: true,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(height: CSpace.sm),
                      CowboyButton(
                        label: 'Back to town',
                        kind: CButtonKind.ghost,
                        icon: Icons.home_outlined,
                        expand: true,
                        onPressed: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                      ),
                      const SizedBox(height: CSpace.lg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.won, required this.accent});
  final bool won;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(won ? 'LAST ONE STANDING' : 'YOU WERE OUTDRAWN',
            style: CType.label(color: accent), textAlign: TextAlign.center),
        const SizedBox(height: CSpace.xs),
        Text(won ? 'Victory' : 'Defeat',
            style: CType.wordmark(size: 52, color: accent), textAlign: TextAlign.center),
      ],
    );
  }
}

class _WinnerBadge extends StatelessWidget {
  const _WinnerBadge({required this.winner, required this.accent, required this.won});
  final Player winner;
  final Color accent;
  final bool won;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [CColors.surfaceHi, CColors.surface],
          ),
          border: Border.all(color: accent, width: 3),
          boxShadow: CShadow.glow(accent),
        ),
        child: Text(winner.emoji, style: const TextStyle(fontSize: 56)),
      ),
    );
  }
}

class _Rewards extends StatelessWidget {
  const _Rewards({required this.coins, required this.won});
  final int coins;
  final bool won;
  @override
  Widget build(BuildContext context) {
    return CowboyCard(
      child: Row(
        children: [
          _Reward(icon: Icons.monetization_on, label: 'Coins', value: '+$coins', color: CColors.gold),
          Container(width: 1, height: 40, color: CColors.line),
          _Reward(
            icon: Icons.trending_up,
            label: 'Rank',
            value: won ? '+18' : '-6',
            color: won ? CColors.success : CColors.danger,
          ),
          Container(width: 1, height: 40, color: CColors.line),
          _Reward(icon: Icons.bolt, label: 'XP', value: won ? '+120' : '+40', color: CColors.accent),
        ],
      ),
    );
  }
}

class _Reward extends StatelessWidget {
  const _Reward({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: CSpace.xxs),
          Text(value, style: CType.stat(size: 18, color: color)),
          Text(label.toUpperCase(), style: CType.label(size: 10, color: CColors.textLow)),
        ],
      ),
    );
  }
}

class _Standings extends StatelessWidget {
  const _Standings({required this.standings});
  final List<Player> standings;
  @override
  Widget build(BuildContext context) {
    // Survivors first (you on top if alive), then the fallen.
    final order = [...standings]
      ..sort((a, b) => (b.alive ? 1 : 0).compareTo(a.alive ? 1 : 0));
    return Column(
      children: [
        for (var i = 0; i < order.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: CSpace.xs),
            child: CowboyCard(
              padding: const EdgeInsets.symmetric(horizontal: CSpace.md, vertical: CSpace.xs),
              accent: order[i].isYou ? CColors.gold : null,
              child: Row(
                children: [
                  SizedBox(width: 22, child: Text('${i + 1}', style: CType.stat(size: 15))),
                  const SizedBox(width: CSpace.xs),
                  Text(order[i].emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: CSpace.sm),
                  Expanded(
                    child: Text(order[i].name,
                        style: CType.title(
                            size: 14, color: order[i].isYou ? CColors.gold : CColors.textHi)),
                  ),
                  Text(
                    order[i].alive ? 'Survived' : 'Down',
                    style: CType.label(
                        size: 11, color: order[i].alive ? CColors.success : CColors.textLow),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
