import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../models/ranking.dart';

/// The Ranking screen — a top-3 podium over the dusk sky, then a leaderboard
/// list with the player's own row highlighted.
class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key, this.entries = RankEntry.demo});
  final List<RankEntry> entries;

  @override
  Widget build(BuildContext context) {
    final top3 = entries.where((e) => e.rank <= 3).toList()..sort((a, b) => a.rank.compareTo(b.rank));
    final rest = entries.where((e) => e.rank > 3).toList();

    return Scaffold(
      body: DuskBackground(
        child: SafeArea(
          child: Column(
            children: [
              _RankHeader(),
              if (top3.length == 3) _Podium(top3: top3),
              const SizedBox(height: CSpace.sm),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(CSpace.md, 0, CSpace.md, CSpace.lg),
                  itemCount: rest.length,
                  separatorBuilder: (_, _) => const SizedBox(height: CSpace.xs),
                  itemBuilder: (context, i) => _RankRow(entry: rest[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankHeader extends StatelessWidget {
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
          Text('Leaderboard', style: CType.heading(size: 22)),
          const Spacer(),
          const Icon(Icons.emoji_events, color: CColors.gold),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top3});
  final List<RankEntry> top3;
  @override
  Widget build(BuildContext context) {
    // Order on screen: 2nd, 1st, 3rd.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CSpace.md, vertical: CSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _PodiumPillar(entry: top3[1], height: 96, medal: CColors.textMid)),
          const SizedBox(width: CSpace.xs),
          Expanded(child: _PodiumPillar(entry: top3[0], height: 128, medal: CColors.gold)),
          const SizedBox(width: CSpace.xs),
          Expanded(child: _PodiumPillar(entry: top3[2], height: 76, medal: CColors.primaryBright)),
        ],
      ),
    );
  }
}

class _PodiumPillar extends StatelessWidget {
  const _PodiumPillar({required this.entry, required this.height, required this.medal});
  final RankEntry entry;
  final double height;
  final Color medal;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CColors.surface,
            border: Border.all(color: medal, width: 2),
            boxShadow: entry.rank == 1 ? CShadow.glow(CColors.gold) : null,
          ),
          child: Text(entry.emoji, style: const TextStyle(fontSize: 26)),
        ),
        const SizedBox(height: CSpace.xxs),
        Text(entry.name, style: CType.title(size: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('${entry.score}', style: CType.label(size: 11, color: CColors.textLow)),
        const SizedBox(height: CSpace.xs),
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(CRadius.sm)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [medal.withValues(alpha: 0.32), medal.withValues(alpha: 0.06)],
            ),
            border: Border.all(color: medal.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: CSpace.xs),
          child: Text('${entry.rank}', style: CType.stat(size: 26, color: medal)),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry});
  final RankEntry entry;
  @override
  Widget build(BuildContext context) {
    return CowboyCard(
      padding: const EdgeInsets.symmetric(horizontal: CSpace.md, vertical: CSpace.sm),
      accent: entry.isYou ? CColors.gold : null,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${entry.rank}',
                style: CType.stat(size: 18, color: entry.isYou ? CColors.gold : CColors.textMid)),
          ),
          const SizedBox(width: CSpace.xs),
          Text(entry.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: CSpace.sm),
          Expanded(
            child: Text(
              entry.name,
              style: CType.title(size: 15, color: entry.isYou ? CColors.gold : CColors.textHi),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.score}', style: CType.stat(size: 16)),
              Text('${entry.wins} wins', style: CType.label(size: 10, color: CColors.textLow)),
            ],
          ),
        ],
      ),
    );
  }
}
