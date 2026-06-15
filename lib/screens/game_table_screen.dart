import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../effects/effect_controller.dart';
import '../effects/effect_overlay.dart';
import '../effects/effect_shaders.dart';
import '../effects/game_event.dart';
import '../models/player.dart';
import '../widgets/action_bar.dart';
import '../widgets/player_seat.dart';

/// The game table — the centerpiece. Cowboys arranged around a western felt
/// table, a turn timer in the middle, the action bar pinned to the bottom, and
/// the code-based effect layer firing on real seat anchors.
class GameTableScreen extends StatefulWidget {
  const GameTableScreen({super.key, this.players = Player.demoTable});
  final List<Player> players;

  @override
  State<GameTableScreen> createState() => _GameTableScreenState();
}

class _GameTableScreenState extends State<GameTableScreen> {
  GameAction? _selected;
  bool _smoke = false;

  late final EffectController _fx;
  List<Offset> _anchors = const [];
  int _youIndex = 0;
  Timer? _auto;
  int _autoStep = 0;

  bool get _autoMode => Uri.base.toString().contains('auto');

  @override
  void initState() {
    super.initState();
    _fx = EffectController(
      resolveAnchor: (i) => (i >= 0 && i < _anchors.length) ? _anchors[i] : Offset.zero,
    );
    EffectShaders.load().then((_) {
      if (!mounted) return;
      setState(() {});
      if (_autoMode) {
        _autoDemo();
        _auto = Timer.periodic(const Duration(milliseconds: 320), (_) => _autoDemo());
      }
    });
  }

  @override
  void dispose() {
    _auto?.cancel();
    _fx.dispose();
    super.dispose();
  }

  void _autoDemo() {
    if (!mounted || _anchors.isEmpty) return;
    final rivals = [for (var i = 0; i < _anchors.length; i++) if (i != _youIndex) i];
    if (rivals.isEmpty) return;
    final target = rivals[_autoStep % rivals.length];
    // Mostly beams (so a shot is always crossing the table for screenshots),
    // with an occasional defend ring and curse for variety.
    switch (_autoStep % 5) {
      case 1:
        _fx.dispatch(DefendEvent(_youIndex));
        _fx.dispatch(BangEvent(shooter: _youIndex, target: target));
      case 4:
        _fx.dispatch(CurseEvent(caster: _youIndex, target: target));
        _fx.dispatch(BangEvent(shooter: _youIndex, target: target, isSuper: true));
      default:
        _fx.dispatch(BangEvent(shooter: _youIndex, target: target, isSuper: _autoStep.isEven));
    }
    _autoStep++;
  }

  /// Player tapped a seat — fire the effect matching the selected action.
  void _onSeatTap(int index) {
    if (index == _youIndex) {
      if (_selected == GameAction.defend) {
        _fx.dispatch(DefendEvent(_youIndex));
      } else if (_selected == GameAction.special) {
        _fx.dispatch(TrapEvent(_youIndex));
      }
      if (_smoke) _fx.dispatch(SmokeEvent(_youIndex));
      return;
    }
    // Tapping a rival fires your shot at them.
    final isSuper = _selected == GameAction.special; // demo: special = super-ish
    _fx.dispatch(BangEvent(shooter: _youIndex, target: index, isSuper: isSuper));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DuskBackground(
        child: SafeArea(
          child: Column(
            children: [
              const _TableTopBar(round: 3),
              Expanded(
                child: _TableArena(
                  players: widget.players,
                  controller: _fx,
                  onLayout: (anchors, youIndex) {
                    _anchors = anchors;
                    _youIndex = youIndex;
                  },
                  onSeatTap: _onSeatTap,
                ),
              ),
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

/// Lays the seats out around an ellipse, "You" anchored at the bottom, with the
/// effect overlay composited on top using the same seat anchors.
class _TableArena extends StatelessWidget {
  const _TableArena({
    required this.players,
    required this.controller,
    required this.onLayout,
    required this.onSeatTap,
  });
  final List<Player> players;
  final EffectController controller;
  final void Function(List<Offset> anchors, int youIndex) onLayout;
  final ValueChanged<int> onSeatTap;

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

  static const double _seatW = 88;
  static const double _seatH = 104;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Order players so "You" is last (mapped to the bottom-centre slot).
        final you = players.firstWhere((p) => p.isYou, orElse: () => players.first);
        final ordered = [...players.where((p) => p != you), you];
        final n = ordered.length.clamp(2, 6);
        final slots = _layouts[n] ?? _layouts[6]!;
        final count = math.min(ordered.length, slots.length);

        // Resolve each Align slot to the avatar-centre anchor for effects.
        final w = c.maxWidth, h = c.maxHeight;
        final anchors = <Offset>[];
        for (var i = 0; i < count; i++) {
          final a = slots[i];
          final cx = w / 2 + a.x * (w - _seatW) / 2;
          final cy = h / 2 + a.y * (h - _seatH) / 2;
          anchors.add(Offset(cx, cy - (_seatH / 2 - 29))); // avatar sits at column top
        }
        onLayout(anchors, count - 1); // "You" is the last seat

        final feltSize = math.min(w, h) * 0.62;

        return Stack(
          alignment: Alignment.center,
          children: [
            _FeltTable(size: feltSize),
            const _CenterTimer(seconds: 12),
            for (var i = 0; i < count; i++)
              Align(
                alignment: slots[i],
                child: GestureDetector(
                  onTap: () => onSeatTap(i),
                  child: SizedBox(
                    width: _seatW,
                    child: PlayerSeat(player: ordered[i], highlight: ordered[i].isYou),
                  ),
                ),
              ),
            EffectOverlay(controller: controller),
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
