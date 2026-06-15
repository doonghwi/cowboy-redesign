import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../design/tokens.dart';

/// One core action the player can take this turn.
enum GameAction { reload, defend, shoot, special }

class ActionSpec {
  const ActionSpec(this.action, this.label, this.icon, this.color, {this.enabled = true});
  final GameAction action;
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
}

/// Bottom action bar for the game table.
///   • A thin parallel-toggle strip on top (e.g. Smoke — used *with* an action).
///   • The core action row: Reload / Defend / Shoot / Special.
/// Mirrors cowboy_party's SpecialSlot layout, redrawn in the Desert Dusk style.
class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    required this.selected,
    required this.onSelect,
    this.parallelLabel,
    this.parallelOn = false,
    this.onParallelToggle,
  });

  final GameAction? selected;
  final ValueChanged<GameAction> onSelect;

  final String? parallelLabel;
  final bool parallelOn;
  final VoidCallback? onParallelToggle;

  static const List<ActionSpec> _core = [
    ActionSpec(GameAction.reload, 'Reload', Icons.refresh, CColors.accent),
    ActionSpec(GameAction.defend, 'Defend', Icons.shield_outlined, CColors.gold),
    ActionSpec(GameAction.shoot, 'Bang!', Icons.gps_fixed, CColors.primaryBright),
    ActionSpec(GameAction.special, 'Trap', Icons.dangerous_outlined, CColors.danger),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(CSpace.md, CSpace.md, CSpace.md, CSpace.lg),
      decoration: const BoxDecoration(
        color: CColors.ink,
        borderRadius: BorderRadius.vertical(top: Radius.circular(CRadius.lg)),
        border: Border(top: BorderSide(color: CColors.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (parallelLabel != null) ...[
            _ParallelToggle(label: parallelLabel!, on: parallelOn, onTap: onParallelToggle),
            const SizedBox(height: CSpace.sm),
          ],
          Row(
            children: [
              for (final spec in _core) ...[
                Expanded(
                  child: _ActionTile(
                    spec: spec,
                    selected: selected == spec.action,
                    onTap: spec.enabled ? () => onSelect(spec.action) : null,
                  ),
                ),
                if (spec.action != GameAction.special) const SizedBox(width: CSpace.xs),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ParallelToggle extends StatelessWidget {
  const _ParallelToggle({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: CMotion.fast,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: CSpace.xs, horizontal: CSpace.md),
        decoration: BoxDecoration(
          borderRadius: CRadius.brSm,
          color: on ? CColors.accent.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: on ? CColors.accent : CColors.line, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_outlined, size: 16, color: on ? CColors.accent : CColors.textLow),
            const SizedBox(width: CSpace.xs),
            Text(label, style: CType.label(color: on ? CColors.accent : CColors.textLow)),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.spec, required this.selected, required this.onTap});
  final ActionSpec spec;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: CMotion.fast,
          curve: CMotion.curve,
          padding: const EdgeInsets.symmetric(vertical: CSpace.md),
          decoration: BoxDecoration(
            borderRadius: CRadius.brMd,
            color: selected ? spec.color.withValues(alpha: 0.18) : CColors.surface,
            border: Border.all(
              color: selected ? spec.color : CColors.line,
              width: selected ? 2 : 1.2,
            ),
            boxShadow: selected ? CShadow.glow(spec.color) : null,
          ),
          child: Column(
            children: [
              Icon(spec.icon, size: 24, color: spec.color),
              const SizedBox(height: CSpace.xs),
              Text(spec.label, style: CType.label(size: 11, color: CColors.textHi)),
            ],
          ),
        ),
      ),
    );
  }
}
