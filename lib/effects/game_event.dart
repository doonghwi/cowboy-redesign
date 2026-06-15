/// Layer 1 — what happened, in game terms only. No coordinates, no colours,
/// no timing. The simulation emits these; the dispatcher turns them into
/// presentation data. Seat indices reference the table layout.
sealed class GameEvent {
  const GameEvent();
}

class BangEvent extends GameEvent {
  const BangEvent({required this.shooter, required this.target, this.isSuper = false});
  final int shooter;
  final int target;
  final bool isSuper;
}

class DefendEvent extends GameEvent {
  const DefendEvent(this.seat);
  final int seat;
}

class TrapEvent extends GameEvent {
  const TrapEvent(this.seat);
  final int seat;
}

class SmokeEvent extends GameEvent {
  const SmokeEvent(this.seat);
  final int seat;
}

class CurseEvent extends GameEvent {
  const CurseEvent({required this.caster, required this.target});
  final int caster;
  final int target;
}

class HitEvent extends GameEvent {
  const HitEvent(this.seat);
  final int seat;
}
