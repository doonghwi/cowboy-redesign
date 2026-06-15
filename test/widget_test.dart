import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cowboy_redesign/design/theme.dart';
import 'package:cowboy_redesign/models/player.dart';
import 'package:cowboy_redesign/screens/game_table_screen.dart';
import 'package:cowboy_redesign/screens/home_screen.dart';

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
}
