import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cowboy_redesign/design/theme.dart';
import 'package:cowboy_redesign/screens/home_screen.dart';

void main() {
  testWidgets('Home screen renders wordmark and primary CTA', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildCowboyTheme(), home: const HomeScreen()));
    await tester.pump();

    expect(find.text('Cowboy'), findsOneWidget);
    expect(find.text('Party'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });
}
