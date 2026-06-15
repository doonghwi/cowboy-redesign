import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cowboy_redesign/design/theme.dart';
import 'package:cowboy_redesign/models/player.dart';
import 'package:cowboy_redesign/screens/game_table_screen.dart';
import 'package:cowboy_redesign/screens/home_screen.dart';
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
}
