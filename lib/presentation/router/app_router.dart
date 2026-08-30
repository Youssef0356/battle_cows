import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/game_screen.dart';
import '../screens/tutorial_screen.dart';
import '../screens/result_screen.dart';
import '../../game/models/player.dart';

class AppRouter {
  static const String home = '/';
  static const String game = '/game';
  static const String tutorial = '/tutorial';
  static const String result = '/result';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/game':
        final args = settings.arguments as Map<String, dynamic>?;
        final players = args?['players'] as List<Player>? ?? [];
        final boardSize = args?['boardSize'] as int? ?? 7;
        return MaterialPageRoute(
          builder: (_) => GameScreen(
            players: players,
            boardSize: boardSize,
          ),
        );
      case '/tutorial':
        return MaterialPageRoute(builder: (_) => const TutorialScreen());
      case '/result':
        final args = settings.arguments as Map<String, dynamic>?;
        final winner = args?['winner'] as String? ?? 'Draw';
        final scores = args?['scores'] as Map<String, int>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ResultScreen(
            winner: winner,
            scores: scores,
          ),
        );
      case '/':
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
