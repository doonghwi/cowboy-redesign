import 'package:flutter/material.dart';

import '../design/tokens.dart';
import 'effect_spec.dart';
import 'game_event.dart';

/// Resolves a seat index to its on-screen anchor (centre of the seat token).
typedef AnchorResolver = Offset Function(int seat);

/// Layer 2 — the dispatcher. Turns [GameEvent]s into [EffectSpec] data with
/// resolved coordinates/colours/timing, holds the live set, and evicts each
/// spec when its lifetime ends. Pure presentation orchestration: it never
/// touches game state. Widgets listen via [ChangeNotifier].
class EffectController extends ChangeNotifier {
  EffectController({required this.resolveAnchor});

  /// Injected at construction so the controller stays layout-agnostic.
  AnchorResolver resolveAnchor;

  final List<EffectSpec> _active = [];
  List<EffectSpec> get active => List.unmodifiable(_active);

  int _seq = 0;
  bool _disposed = false;

  /// Map a game event to one or more effect specs and schedule them.
  void dispatch(GameEvent event) {
    for (final spec in _specsFor(event)) {
      _active.add(spec);
      Future.delayed(spec.duration + const Duration(milliseconds: 60), () => _remove(spec.id));
    }
    if (_active.isNotEmpty) notifyListeners();
  }

  void clear() {
    _active.clear();
    if (!_disposed) notifyListeners();
  }

  void _remove(int id) {
    final before = _active.length;
    _active.removeWhere((s) => s.id == id);
    if (_active.length != before && !_disposed) notifyListeners();
  }

  List<EffectSpec> _specsFor(GameEvent e) {
    final id = _seq++;
    switch (e) {
      case BangEvent(:final shooter, :final target, :final isSuper):
        final specs = [
          EffectSpec(
            id: id,
            kind: isSuper ? EffectKind.superBeam : EffectKind.beam,
            from: resolveAnchor(shooter),
            to: resolveAnchor(target),
            duration: Duration(milliseconds: isSuper ? 900 : 620),
            color: isSuper ? CColors.gold : CColors.primaryBright,
          ),
        ];
        // A super bang also triggers a brief full-screen flash.
        if (isSuper) {
          specs.add(EffectSpec(
            id: _seq++,
            kind: EffectKind.superFlash,
            from: resolveAnchor(shooter),
            to: resolveAnchor(target),
            duration: const Duration(milliseconds: 1100),
            color: CColors.gold,
          ));
        }
        return specs;
      case DefendEvent(:final seat):
        return [_centred(id, EffectKind.shieldRing, seat, 760, CColors.accent)];
      case TrapEvent(:final seat):
        return [_centred(id, EffectKind.trapRing, seat, 800, const Color(0xFFB5742E))];
      case SmokeEvent(:final seat):
        return [_centred(id, EffectKind.smokePuff, seat, 1100, CColors.textMid)];
      case CurseEvent(:final caster, :final target):
        return [
          EffectSpec(
            id: id,
            kind: EffectKind.curseAura,
            from: resolveAnchor(caster),
            to: resolveAnchor(target),
            duration: const Duration(milliseconds: 1200),
            color: const Color(0xFF8E5BD8),
          ),
        ];
      case HitEvent(:final seat):
        return [_centred(id, EffectKind.hitBurst, seat, 560, CColors.danger)];
    }
  }

  EffectSpec _centred(int id, EffectKind kind, int seat, int ms, Color color) {
    final at = resolveAnchor(seat);
    return EffectSpec(
      id: id,
      kind: kind,
      from: at,
      to: at,
      duration: Duration(milliseconds: ms),
      color: color,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _active.clear();
    super.dispose();
  }
}
