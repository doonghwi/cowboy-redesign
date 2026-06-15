import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../models/player.dart';
import '../widgets/action_bar.dart';
import '../widgets/player_seat.dart';

/// The game table — the centerpiece. Cowboys arranged around a western felt
/// table, a turn timer in the middle, and the action bar pinned to the bottom.
class GameTableScreen extends StatefulWidget {
  const GameTableScreen({super.key, this.players = Player.demoTable});
  final List<Player> players;

  @override
  State<GameTableScreen> createState() => _GameTableScreenState();
}

class _GameTableScreenState extends State<GameTableScreen> {
  GameAction? _selected;
  bool _smoke = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DuskBackground(
        child: SafeArea(
          child: Column(
            children: [
              const _TableTopBar(round: 3),
              Expanded(child: _TableArena(players: widget.players)),
              ActionBar(
                selected: _selected,
                onSelect: (a) => setState(() => _selected = _selected == a ? null : a),
                parallelLabel: 'Smoke screen',
                parallelOn: _smoke,
                onParallelToggle: () => setState(() => _smoke = !_smoke),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableTopBar extends StatelessWidget {
  const _TableTopBar({required this.round});
  final int round;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(CSpace.sm, CSpace.xs, CSpace.sm, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: CColors.textMid, size: 18),
          ),
          const Spacer(),
          const SectionLabel('Round'),
          const SizedBox(width: CSpace.xs),
          Text('$round', style: CType.stat(size: 18)),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.volume_up_outlined, color: CColors.textMid, size: 20),
          ),
        ],
      ),
    );
  }
}

/// Lays the seats out around an ellipse, "You" anchored at the bottom.
class _TableArena extends StatelessWidget {
  const _TableArena({required this.players});
  final List<Player> players;

  /// Seat positions as Alignment(x, y) ∈ [-1, 1], indexed by table size.
  /// "You" is always the last entry (bottom-centre); rivals ring the top.
  static const Map<int, List<Alignment>> _layouts = {
    2: [Alignment(0, -0.92), Alignment(0, 0.95)],
    3: [Alignment(-0.85, -0.45), Alignment(0.85, -0.45), Alignment(0, 0.95)],
    4: [
      Alignment(-0.9, -0.1),
      Alignment(0, -0.92),
      Alignment(0.9, -0.1),
      Alignment(0, 0.95),
    ],
    5: [
      Alignment(-0.78, 0.05),
      Alignment(-0.5, -0.78),
      Alignment(0.5, -0.78),
      Alignment(0.78, 0.05),
      Alignment(0, 0.95),
    ],
    6: [
      Alignment(-0.8, 0.12),
      Alignment(-0.6, -0.72),
      Alignment(0, -0.95),
      Alignment(0.6, -0.72),
      Alignment(0.8, 0.12),
      Alignment(0, 0.95),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Order players so "You" is last (mapped to the bottom-centre slot).
        final you = players.firstWhere((p) => p.isYou, orElse: () => players.first);
        final ordered = [...players.where((p) => p != you), you];
        final n = ordered.length.clamp(2, 6);
        final slots = _layouts[n] ?? _layouts[6]!;

        final feltSize = math.min(c.maxWidth, c.maxHeight) * 0.62;

        return Stack(
          alignment: Alignment.center,
          children: [
            _FeltTable(size: feltSize),
            const _CenterTimer(seconds: 12),
            for (var i = 0; i < ordered.length && i < slots.length; i++)
              Align(
                alignment: slots[i],
                child: SizedBox(
                  width: 88,
                  child: PlayerSeat(player: ordered[i], highlight: ordered[i].isYou),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FeltTable extends StatelessWidget {
  const _FeltTable({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [CColors.accentDeep.withValues(alpha: 0.30), CColors.ink.withValues(alpha: 0.0)],
          stops: const [0.55, 1.0],
        ),
        border: Border.all(color: CColors.line.withValues(alpha: 0.6), width: 1.4),
      ),
    );
  }
}

class _CenterTimer extends StatelessWidget {
  const _CenterTimer({required this.seconds});
  final int seconds;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: seconds / 20,
                  strokeWidth: 4,
                  backgroundColor: CColors.line,
                  valueColor: const AlwaysStoppedAnimation(CColors.primaryBright),
                ),
              ),
              Text('$seconds', style: CType.stat(size: 24)),
            ],
          ),
        ),
        const SizedBox(height: CSpace.xs),
        const SectionLabel('Pick your move'),
      ],
    );
  }
}
