import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../game/models/pasture_tile.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/game_controls_overlay.dart';
import '../overlays/game_over_overlay.dart';

class FlameGameScreen extends StatefulWidget {
  final List<Player> players;
  final List<PastureTile>? tiles;
  final int herdSize;
  final int boardSize;

  const FlameGameScreen({
    super.key,
    required this.players,
    this.tiles,
    this.herdSize = 16,
    this.boardSize = 7,
  });

  @override
  State<FlameGameScreen> createState() => _FlameGameScreenState();
}

class _FlameGameScreenState extends State<FlameGameScreen> {
  late BattleCowsGame _game;

  @override
  void initState() {
    super.initState();
    _game = BattleCowsGame(
      players: widget.players,
      tiles: widget.tiles,
      herdSize: widget.herdSize,
      boardSize: widget.boardSize,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
      onGameOver: (winner, scores) {
        if (mounted) {
          _game.overlays.add('GameOver');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'HUD': (context, game) => HudOverlay(
            game: game as BattleCowsGame,
            players: widget.players,
          ),
          'GameControls': (context, game) => GameControlsOverlay(
            game: game as BattleCowsGame,
          ),
          'GameOver': (context, game) => GameOverOverlay(
            game: game as BattleCowsGame,
            players: widget.players,
          ),
        },
        initialActiveOverlays: const ['HUD', 'GameControls'],
      ),
    );
  }
}
