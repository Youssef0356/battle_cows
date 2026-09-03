import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../data/services/progress_service.dart';
import '../../game/models/player.dart';
import '../../game/models/pasture_tile.dart';
import '../../core/constants/colors.dart';
import '../../ads/ad_manager.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/game_controls_overlay.dart';
import '../overlays/game_over_overlay.dart';
import '../overlays/turn_banner.dart';
import '../overlays/scoreboard_overlay.dart';
import '../overlays/placement_overlay.dart';
import '../widgets/capture_toast.dart';

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
  OverlayEntry? _turnBannerEntry;
  OverlayEntry? _captureToastEntry;
  ProgressService? _progressService;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    AdManager().loadRewardedAd();
    _initProgress();
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
          _recordGameResult(winner);
          _game.overlays.add('GameOver');
        }
      },
      onTurnChanged: (String playerName, Color playerColor, bool isAi) {
        if (mounted) _showTurnBanner(playerName, playerColor, isAi);
      },
      onCapture: (int count, PlayerColor playerColor) {
        if (mounted) _showCaptureToast(count, playerColor);
      },
      onHeartLost: (int heartsLeft) {
        if (mounted) _showHeartLostToast(heartsLeft);
      },
      onPlacementComplete: () {
        if (mounted) {
          _game.overlays.remove('Placement');
          _game.overlays.add('GameControls');
          _game.overlays.add('Scoreboard');
        }
      },
    );
    // Start with placement overlay if no tiles provided
    if (widget.tiles == null || widget.tiles!.isEmpty) {
      _game.overlays.add('Placement');
    } else {
      _game.overlays.add('GameControls');
      _game.overlays.add('Scoreboard');
    }
  }

  Future<void> _initProgress() async {
    _progressService = await ProgressService.getInstance();
  }

  void _recordGameResult(PlayerColor? winner) {
    if (_progressService == null) return;
    final playerColor = widget.players.isNotEmpty ? widget.players[0].color : null;
    final won = winner != null && winner == playerColor;
    final captures = _game.capturesPerPlayer[playerColor] ?? 0;
    _progressService!.recordMatch(won: won, captures: captures);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _turnBannerEntry?.remove();
    _captureToastEntry?.remove();
    super.dispose();
  }

  void _showTurnBanner(String playerName, Color playerColor, bool isAi) {
    _turnBannerEntry?.remove();
    _turnBannerEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: TurnBanner(
          playerName: playerName,
          playerColor: playerColor,
          isAi: isAi,
          onComplete: () {
            _turnBannerEntry?.remove();
            _turnBannerEntry = null;
          },
        ),
      ),
    );
    Overlay.of(context).insert(_turnBannerEntry!);
  }

  void _showCaptureToast(int count, PlayerColor playerColor) {
    _captureToastEntry?.remove();
    final color = AppColors.getPlayerPrimary(playerColor);
    _captureToastEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: 0,
        right: 0,
        child: Center(
          child: CaptureToast(
            count: count,
            playerColor: color,
            onComplete: () {
              _captureToastEntry?.remove();
              _captureToastEntry = null;
            },
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_captureToastEntry!);
  }

  void _showHeartLostToast(int heartsLeft) {
    _captureToastEntry?.remove();
    _captureToastEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.35,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF5252), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💔', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'HEART LOST! ($heartsLeft left)',
                    style: GoogleFonts.bangers(
                      fontSize: 20,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_captureToastEntry!);
    Future.delayed(const Duration(milliseconds: 1500), () {
      _captureToastEntry?.remove();
      _captureToastEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(
              game: _game,
              backgroundBuilder: (context) => Container(color: Colors.black),
              overlayBuilderMap: {
                'HUD': (context, game) => HudOverlay(
                  game: game as BattleCowsGame,
                  players: widget.players,
                ),
                'Placement': (context, game) => PlacementOverlay(
                  game: game as BattleCowsGame,
                ),
                'GameControls': (context, game) => GameControlsOverlay(
                  game: game as BattleCowsGame,
                ),
                'Scoreboard': (context, game) => ScoreboardOverlay(
                  game: game as BattleCowsGame,
                ),
                'GameOver': (context, game) => GameOverOverlay(
                  game: game as BattleCowsGame,
                  players: widget.players,
                ),
              },
              initialActiveOverlays: const ['HUD'],
            ),
          ],
        ),
      ),
    );
  }
}
