import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import 'game_table_screen.dart';

/// Home / title screen — the first impression.
/// Hero wordmark over the dusk sky, a single confident "Play" CTA, secondary
/// destinations, and a coin/streak readout strip.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DuskBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(CSpace.lg, 0, CSpace.lg, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: CSpace.xl),
                      _TopBar(),
                      const SizedBox(height: CSpace.xxxl),
                      _Hero(),
                      const SizedBox(height: CSpace.xl),
                      _PrimaryCta(),
                      const SizedBox(height: CSpace.sm),
                      _SecondaryRow(),
                      const SizedBox(height: CSpace.xxxl),
                      _CoinStrip(),
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

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          const _Badge(),
          const SizedBox(width: CSpace.xs),
          Text('SHERIFF', style: CType.label(color: CColors.textMid)),
        ]),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined, color: CColors.textMid),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CColors.gold.withValues(alpha: 0.15),
        border: Border.all(color: CColors.gold, width: 1.4),
      ),
      child: const Icon(Icons.star, size: 16, color: CColors.gold),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('THE LAST ONE STANDING WINS', style: CType.label(color: CColors.primaryBright)),
        const SizedBox(height: CSpace.sm),
        Text('Cowboy', style: CType.wordmark(size: 64)),
        Transform.translate(
          offset: const Offset(0, -6),
          child: Text('Party', style: CType.wordmark(size: 64, color: CColors.primaryBright)),
        ),
        const SizedBox(height: CSpace.md),
        SizedBox(
          width: 320,
          child: Text(
            'Reload, dodge, and outdraw 2–6 cowboys in a tense circle of nerves. One move a turn — read the table, pull the trigger.',
            style: CType.body(size: 16),
          ),
        ),
      ],
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CowboyButton(
      label: 'PLAY',
      icon: Icons.play_arrow_rounded,
      expand: true,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GameTableScreen()),
      ),
    );
  }
}

class _SecondaryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CowboyButton(
            label: 'How to play',
            kind: CButtonKind.ghost,
            icon: Icons.menu_book_outlined,
            expand: true,
            onPressed: () {},
          ),
        ),
        const SizedBox(width: CSpace.sm),
        Expanded(
          child: CowboyButton(
            label: 'Saloon',
            kind: CButtonKind.secondary,
            icon: Icons.storefront_outlined,
            expand: true,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

class _CoinStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CowboyCard(
      padding: const EdgeInsets.symmetric(horizontal: CSpace.lg, vertical: CSpace.md),
      child: Row(
        children: const [
          _Stat(icon: Icons.monetization_on, label: 'Coins', value: '1,250', color: CColors.gold),
          _Divider(),
          _Stat(icon: Icons.local_fire_department, label: 'Streak', value: '4', color: CColors.primaryBright),
          _Divider(),
          _Stat(icon: Icons.emoji_events, label: 'Wins', value: '37', color: CColors.accent),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value, required this.color});
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
          const SizedBox(height: CSpace.xs),
          Text(value, style: CType.stat(size: 20)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(), style: CType.label(size: 11, color: CColors.textLow)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 44, color: CColors.line);
  }
}
