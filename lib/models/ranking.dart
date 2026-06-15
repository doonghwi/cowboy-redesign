import 'package:flutter/foundation.dart';

/// A leaderboard entry. View-model for the Ranking screen.
@immutable
class RankEntry {
  const RankEntry({
    required this.rank,
    required this.name,
    required this.emoji,
    required this.wins,
    required this.score,
    this.isYou = false,
  });

  final int rank;
  final String name;
  final String emoji;
  final int wins;
  final int score;
  final bool isYou;

  static const List<RankEntry> demo = [
    RankEntry(rank: 1, name: 'Calamity', emoji: '🤠', wins: 214, score: 9820),
    RankEntry(rank: 2, name: 'Ringo', emoji: '🧔', wins: 198, score: 9140),
    RankEntry(rank: 3, name: 'Belle', emoji: '👰', wins: 176, score: 8730),
    RankEntry(rank: 4, name: 'Doc', emoji: '🧑‍⚕️', wins: 151, score: 7990),
    RankEntry(rank: 5, name: 'Jin', emoji: '🥷', wins: 143, score: 7610),
    RankEntry(rank: 6, name: 'Tex', emoji: '🤖', wins: 120, score: 6880),
    RankEntry(rank: 7, name: 'You', emoji: '😎', wins: 37, score: 2410, isYou: true),
    RankEntry(rank: 8, name: 'Rookie', emoji: '👶', wins: 12, score: 980),
  ];
}
