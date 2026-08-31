import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../game/models/pasture_tile.dart';
import '../../core/constants/colors.dart';
import '../../ads/ad_manager.dart';
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
  Offset? _panStart;

  @override
  void initState() {
    super.initState();
    AdManager().loadRewardedAd();
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
      onTimeUp: () {
        if (mounted) _showTimeUpAdDialog();
      },
    );
  }

  void _showTimeUpAdDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2),
        ),
        title: Text(
          'TIME\'S UP!',
          style: GoogleFonts.bangers(
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Watch an ad to get 15 extra seconds?',
          style: GoogleFonts.bangers(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _game.autoPlayMove();
            },
            child: Text(
              'NO, PLAY MOVE',
              style: GoogleFonts.bangers(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AdManager().showRewardedAd(
                onUserEarnedReward: (reward) {
                  _game.addExtraTime(15);
                },
                onAdDismissed: () {
                  if (_game.timeRemaining <= 0) {
                    _game.autoPlayMove();
                  }
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryAction, AppColors.primaryAction.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'WATCH AD (+15s)',
                style: GoogleFonts.bangers(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onPanStart: (details) {
          _panStart = details.localPosition;
        },
        onPanUpdate: (details) {
          if (_panStart == null) return;
          final delta = _panStart! - details.localPosition;
          _game.camera.viewfinder.position += delta.toVector2();
          _panStart = details.localPosition;
        },
        onPanEnd: (_) {
          _panStart = null;
        },
        onPanCancel: () {
          _panStart = null;
        },
        child: GameWidget(
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
      ),
    );
  }
}
