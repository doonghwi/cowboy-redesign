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

/// Effects lab — a ring of seat tokens with buttons that fire game events so
/// each effect can be triggered, watched, and screenshotted in isolation.
class EffectsLabScreen extends StatefulWidget {
  const EffectsLabScreen({super.key});

  @override
  State<EffectsLabScreen> createState() => _EffectsLabScreenState();
}

class _EffectsLabScreenState extends State<EffectsLabScreen> {
  static const _seatCount = 5;
  late final EffectController _fx;
  List<Offset> _anchors = const [];
  bool _shadersReady = false;
  int _target = 2;
  Timer? _auto;

  /// Auto-fire mode (URL contains "auto") keeps an effect on screen so a
  /// headless screenshot always catches one mid-flight.
  bool get _autoMode => Uri.base.toString().contains('auto');

  @override
  void initState() {
    super.initState();
    _fx = EffectController(resolveAnchor: (i) => _anchors.isEmpty ? Offset.zero : _anchors[i % _anchors.length]);
    EffectShaders.load().then((_) {
      if (!mounted) return;
      setState(() => _shadersReady = true);
      if (_autoMode) {
        _bang();
        _auto = Timer.periodic(const Duration(milliseconds: 480), (_) {
          if (!mounted) return;
          _bang(isSuper: _target.isEven);
        });
      }
    });
  }

  @override
  void dispose() {
    _auto?.cancel();
    _fx.dispose();
    super.dispose();
  }

  void _bang({bool isSuper = false}) {
    _target = (_target + 1) % _seatCount;
    if (_target == 0) _target = 1;
    _fx.dispatch(BangEvent(shooter: 0, target: _target, isSuper: isSuper));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DuskBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(ready: _shadersReady),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    _anchors = _layout(c.biggest, _seatCount);
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        for (var i = 0; i < _anchors.length; i++)
                          Positioned(
                            left: _anchors[i].dx - 28,
                            top: _anchors[i].dy - 28,
                            child: _SeatToken(index: i, isShooter: i == 0, isTarget: i == _target),
                          ),
                        EffectOverlay(controller: _fx),
                      ],
                    );
                  },
                ),
              ),
              _Controls(
                ready: _shadersReady,
                onBang: () => _bang(),
                onSuper: () => _bang(isSuper: true),
                onHit: () => _fx.dispatch(HitEvent(_target)),
                onClear: _fx.clear,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Offset> _layout(Size size, int n) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width / 2 - 48;
    final ry = size.height / 2 - 48;
    // Seat 0 at the bottom (shooter), the rest around the ring.
    return List.generate(n, (i) {
      final angle = math.pi / 2 + (2 * math.pi * i / n);
      return Offset(cx + rx * math.cos(angle), cy + ry * math.sin(angle));
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.ready});
  final bool ready;
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
          Text('Effects Lab', style: CType.heading(size: 22)),
          const SizedBox(width: CSpace.xs),
          Icon(Icons.bolt, size: 18, color: ready ? CColors.gold : CColors.textLow),
        ],
      ),
    );
  }
}

class _SeatToken extends StatelessWidget {
  const _SeatToken({required this.index, required this.isShooter, required this.isTarget});
  final int index;
  final bool isShooter;
  final bool isTarget;
  @override
  Widget build(BuildContext context) {
    final color = isShooter ? CColors.gold : (isTarget ? CColors.danger : CColors.line);
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CColors.surfaceHi, CColors.surface],
        ),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(isShooter ? '🤠' : '🎯', style: const TextStyle(fontSize: 24)),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.ready,
    required this.onBang,
    required this.onSuper,
    required this.onHit,
    required this.onClear,
  });
  final bool ready;
  final VoidCallback onBang;
  final VoidCallback onSuper;
  final VoidCallback onHit;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(CSpace.md, 0, CSpace.md, CSpace.lg),
      child: Wrap(
        spacing: CSpace.xs,
        runSpacing: CSpace.xs,
        alignment: WrapAlignment.center,
        children: [
          CowboyButton(label: 'Bang!', icon: Icons.gps_fixed, onPressed: ready ? onBang : null),
          CowboyButton(label: 'Super Bang', icon: Icons.bolt, kind: CButtonKind.secondary, onPressed: ready ? onSuper : null),
          CowboyButton(label: 'Hit', icon: Icons.whatshot, kind: CButtonKind.ghost, onPressed: onHit),
          CowboyButton(label: 'Clear', icon: Icons.clear_all, kind: CButtonKind.ghost, onPressed: onClear),
        ],
      ),
    );
  }
}
