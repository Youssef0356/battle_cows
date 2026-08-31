import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/flame_game_screen.dart';
import '../screens/tutorial_screen.dart';
import '../screens/result_screen.dart';
import '../screens/tile_placement_screen.dart';
import '../../game/models/player.dart';
import '../../game/models/pasture_tile.dart';

class AppRouter {
  static const String home = '/';
  static const String game = '/game';
  static const String tutorial = '/tutorial';
  static const String result = '/result';
  static const String tilePlacement = '/tile-placement';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/game':
        final args = settings.arguments as Map<String, dynamic>?;
        final players = args?['players'] as List<Player>? ?? [];
        final tiles = args?['tiles'] as List<PastureTile>?;
        final herdSize = args?['herdSize'] as int? ?? 16;
        final boardSize = args?['boardSize'] as int? ?? 7;
        return MaterialPageRoute(
          builder: (_) => FlameGameScreen(
            players: players,
            tiles: tiles,
            herdSize: herdSize,
            boardSize: boardSize,
          ),
        );
      case '/tile-placement':
        final args = settings.arguments as Map<String, dynamic>?;
        final players = args?['players'] as List<Player>? ?? [];
        final tilesPerPlayer = args?['tilesPerPlayer'] as int? ?? 5;
        return MaterialPageRoute(
          builder: (_) => TilePlacementScreen(
            players: players,
            tilesPerPlayer: tilesPerPlayer,
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
