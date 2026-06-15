import 'package:flutter/material.dart';

import 'dailyapp_stats.dart';
import 'design/theme.dart';
import 'screens/game_table_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/result_screen.dart';
import 'screens/saloon_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Fire-and-forget usage ping (shared dailyapp tracker).
  DailyAppStats.recordOpen(
    appId: 'cowboy_redesign',
    name: '🤠 카우보이 파티 (리디자인)',
    desc: 'Figma 주도 리디자인 프로토타입',
    platforms: ['web'],
    webUrl: 'https://doonghwi.github.io/cowboy-redesign/',
    repoUrl: 'https://github.com/doonghwi/cowboy-redesign',
  );
  runApp(const CowboyRedesignApp());
}

class CowboyRedesignApp extends StatelessWidget {
  const CowboyRedesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cowboy Party',
      debugShowCheckedModeBanner: false,
      theme: buildCowboyTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/table': (_) => const GameTableScreen(),
        '/saloon': (_) => const SaloonScreen(),
        '/ranking': (_) => const RankingScreen(),
        '/result': (_) => const ResultScreen(),
      },
    );
  }
}
