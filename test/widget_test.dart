import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cowboy_redesign/design/theme.dart';
import 'package:cowboy_redesign/effects/effect_controller.dart';
import 'package:cowboy_redesign/effects/effect_spec.dart';
import 'package:cowboy_redesign/effects/game_event.dart';
import 'package:cowboy_redesign/models/player.dart';
import 'package:cowboy_redesign/screens/game_table_screen.dart';
import 'package:cowboy_redesign/screens/home_screen.dart';
import 'package:cowboy_redesign/screens/how_to_play_screen.dart';
import 'package:cowboy_redesign/screens/ranking_screen.dart';
import 'package:cowboy_redesign/screens/result_screen.dart';
import 'package:cowboy_redesign/screens/saloon_screen.dart';

void main() {
  testWidgets('Home screen renders wordmark and primary CTA', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildCowboyTheme(), home: const HomeScreen()));
    await tester.pump();

    expect(find.text('Cowboy'), findsOneWidget);
    expect(find.text('Party'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('Game table renders all seats and the action bar', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildCowboyTheme(), home: const GameTableScreen()));
    await tester.pump();

    // Every demo player gets a seat.
    for (final p in Player.demoTable) {
      expect(find.text(p.name), findsOneWidget);
    }
    // Core actions present.
    expect(find.text('Reload'), findsOneWidget);
    expect(find.text('Bang!'), findsOneWidget);
  });

  testWidgets('Saloon renders header and character cards', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildCowboyTheme(), home: const SaloonScreen()));
    await tester.pump();

    expect(find.text('Saloon'), findsOneWidget);
    expect(find.text('Commoner'), findsOneWidget);
    expect(find.text('Owned'), findsWidgets); // free starters are owned
  });

  testWidgets('Ranking renders podium and your highlighted row', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildCowboyTheme(), home: const RankingScreen()));
    await tester.pump();

    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Calamity'), findsOneWidget); // rank 1 on the podium
    expect(find.text('You'), findsOneWidget);
  });

  testWidgets('Result screen renders victory banner and rewards', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildCowboyTheme(), home: const ResultScreen()));
    await tester.pump();

    expect(find.text('Victory'), findsOneWidget);
    expect(find.text('+320'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
  });

  testWidgets('How to play lists core moves and win conditions', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildCowboyTheme(), home: const HowToPlayScreen()));
    await tester.pump();

    expect(find.text('Reload'), findsOneWidget);
    expect(find.text('Super Bang'), findsOneWidget);
    expect(find.text('Last standing'), findsOneWidget);
  });

  test('EffectController maps events to effect-spec data with anchors', () {
    final anchors = [const Offset(0, 100), const Offset(50, 0), const Offset(100, 100)];
    final c = EffectController(resolveAnchor: (i) => anchors[i]);

    c.dispatch(const BangEvent(shooter: 0, target: 1));
    expect(c.active, hasLength(1));
    expect(c.active.first.kind, EffectKind.beam);
    expect(c.active.first.from, anchors[0]);
    expect(c.active.first.to, anchors[1]);

    c.dispatch(const BangEvent(shooter: 0, target: 2, isSuper: true));
    expect(c.active.any((s) => s.kind == EffectKind.superBeam), isTrue);

    c.dispatch(const DefendEvent(1));
    c.dispatch(const TrapEvent(2));
    c.dispatch(const SmokeEvent(1));
    c.dispatch(const CurseEvent(caster: 0, target: 2));
    expect(c.active.any((s) => s.kind == EffectKind.shieldRing), isTrue);
    expect(c.active.any((s) => s.kind == EffectKind.trapRing), isTrue);
    expect(c.active.any((s) => s.kind == EffectKind.smokePuff), isTrue);
    final curse = c.active.firstWhere((s) => s.kind == EffectKind.curseAura);
    expect(curse.from, anchors[0]); // caster
    expect(curse.to, anchors[2]); // target

    c.clear();
    expect(c.active, isEmpty);
    c.dispose();
  });
}
