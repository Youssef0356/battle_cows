import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../data/services/progress_service.dart';
import '../../game/models/player.dart';
import '../../game/models/pasture_tile.dart';
import '../../game/models/challenge_mode.dart';
import '../../core/constants/colors.dart';
import '../../ads/ad_manager.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/game_controls_overlay.dart';
import '../overlays/game_over_overlay.dart';
import '../overlays/turn_banner.dart';
import '../overlays/scoreboard_overlay.dart';
import '../overlays/placement_overlay.dart';
import '../overlays/herd_placement_overlay.dart';
import '../overlays/tutorial_overlay.dart';
import '../../game/tutorial/tutorial_data.dart';
import '../widgets/capture_toast.dart';
import '../widgets/parallax_dust_layer.dart';

class FlameGameScreen extends StatefulWidget {
  final List<Player> players;
  final List<PastureTile>? tiles;
  final int herdSize;
  final int boardSize;
  final int tilesPerPlayer;
  final ChallengeMode challengeMode;
  final bool isTutorial;

  const FlameGameScreen({
    super.key,
    required this.players,
    this.tiles,
    this.herdSize = 16,
    this.boardSize = 7,
    this.tilesPerPlayer = 5,
    this.challengeMode = ChallengeMode.standard,
    this.isTutorial = false,
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
    if (!widget.isTutorial) AdManager().loadRewardedAd();
    _initProgress();
    _game = BattleCowsGame(
      players: widget.players,
      tiles: widget.tiles,
      herdSize: widget.herdSize,
      boardSize: widget.boardSize,
      tilesPerPlayer: widget.tilesPerPlayer,
      challengeMode: widget.challengeMode,
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
          _game.overlays.remove('HerdPlacement');
          _game.overlays.add('HUD');
          _game.overlays.add('GameControls');
          _game.overlays.add('Scoreboard');
        }
      },
      onTilePlacementComplete: () {
        if (mounted) {
          _game.overlays.remove('HUD');
          _game.overlays.remove('Placement');
          _game.overlays.add('HerdPlacement');
        }
      },
    );
    // Start with placement overlay if no tiles provided
    // Defer to after first frame so overlayBuilderMap is registered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.isTutorial) {
        _game.overlays.add('Tutorial');
        _game.overlays.add('Placement');
      } else if (widget.tiles == null || widget.tiles!.isEmpty) {
        _game.overlays.add('Placement');
      } else {
        _game.overlays.add('HerdPlacement');
      }
    });
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
    _game.disableCallbacks();
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

  void _onTutorialComplete() {
    _game.overlays.remove('Tutorial');
    _game.overlays.remove('Placement');
    _game.overlays.remove('HerdPlacement');
    _game.overlays.remove('HUD');
    _game.overlays.remove('GameControls');
    _game.overlays.remove('Scoreboard');
    if (widget.isTutorial && mounted) {
      _progressService?.markTutorialCompleted();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _onTutorialStepChanged(int stepIndex, TutorialStep step) {
    if (!mounted) return;
    final activeOverlays = _game.overlays.activeOverlays;
    // Manage game overlays based on tutorial phase
    switch (step.phase) {
      case TutorialPhase.tilePlacement:
        if (!activeOverlays.contains('Placement')) {
          _game.overlays.remove('HerdPlacement');
          _game.overlays.remove('HUD');
          _game.overlays.remove('GameControls');
          _game.overlays.remove('Scoreboard');
          _game.overlays.add('Placement');
        }
        break;
      case TutorialPhase.herdPlacement:
        if (!activeOverlays.contains('HerdPlacement')) {
          _game.overlays.remove('Placement');
          _game.overlays.add('HerdPlacement');
        }
        break;
      case TutorialPhase.gameplay:
        if (!activeOverlays.contains('HUD')) {
          _game.overlays.remove('Placement');
          _game.overlays.remove('HerdPlacement');
          _game.overlays.add('HUD');
          _game.overlays.add('GameControls');
          _game.overlays.add('Scoreboard');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _game.backgroundAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(color: const Color(0xFF1B3A1B)),
            ),
          ),
          Positioned.fill(
            child: ColoredBox(color: Colors.black26),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (details) {
                _game.onTapDownFromScreen(details);
              },
              child: GameWidget(
                game: _game,
                backgroundBuilder: (context) => const SizedBox.expand(),
                overlayBuilderMap: {
                  'HUD': (context, game) => Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: HudOverlay(
                      game: game as BattleCowsGame,
                      players: widget.players,
                    ),
                  ),
                  'Placement': (context, game) => PlacementOverlay(
                    game: game as BattleCowsGame,
                  ),
                  'HerdPlacement': (context, game) => HerdPlacementOverlay(
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
                  if (widget.isTutorial)
                    'Tutorial': (context, game) => TutorialOverlay(
                      steps: TutorialScenario.steps,
                      onComplete: _onTutorialComplete,
                      onStepChanged: _onTutorialStepChanged,
                    ),
                },
                initialActiveOverlays: const [],
              ),
            ),
          ),
          const Positioned.fill(
            child: ParallaxDustLayer(),
          ),
        ],
      ),
    );
  }
}
