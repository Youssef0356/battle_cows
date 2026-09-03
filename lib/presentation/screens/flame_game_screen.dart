import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart' hide Matrix4;
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

class _FlameGameScreenState extends State<FlameGameScreen>
    with TickerProviderStateMixin {
  late BattleCowsGame _game;
  OverlayEntry? _turnBannerEntry;
  OverlayEntry? _captureToastEntry;
  ProgressService? _progressService;
  bool _overlaysAdded = false;

  // 3D camera breathing animation
  late AnimationController _cameraController;
  late Animation<double> _cameraTiltAnim;
  late Animation<double> _cameraFloatAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    AdManager().loadRewardedAd();
    _initProgress();

    // Slow breathing camera animation – gives the board a living 3D feel
    _cameraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);

    _cameraTiltAnim = Tween<double>(begin: -0.045, end: -0.025).animate(
      CurvedAnimation(parent: _cameraController, curve: Curves.easeInOut),
    );
    _cameraFloatAnim = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _cameraController, curve: Curves.easeInOut),
    );

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
  }

  Future<void> _initProgress() async {
    _progressService = await ProgressService.getInstance();
  }

  void _recordGameResult(PlayerColor? winner) {
    if (_progressService == null) return;
    
    // Track results for all human players
    for (final player in widget.players) {
      if (!player.isAi) {
        final won = winner != null && winner == player.color;
        final captures = _game.capturesPerPlayer[player.color] ?? 0;
        _progressService!.recordMatch(won: won, captures: captures);
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
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
    if (!_overlaysAdded) {
      _overlaysAdded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.tiles == null || widget.tiles!.isEmpty) {
          _game.overlays.add('Placement');
        } else {
          _game.overlays.add('GameControls');
          _game.overlays.add('Scoreboard');
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Table background – fills entire screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background/Table image.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Image.asset(
                'assets/images/Background/Background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Subtle warm dark overlay to let the Flame board pop
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.22),
            ),
          ),
          // Animated 3D perspective board area
          SafeArea(
            child: AnimatedBuilder(
              animation: _cameraController,
              builder: (context, child) {
                // 3D angled camera: slight X-axis tilt + vertical float
                final tilt = _cameraTiltAnim.value;
                final floatY = _cameraFloatAnim.value;
                final matrix = Matrix4.identity()
                  ..setEntry(3, 2, 0.0008)   // perspective depth
                  ..rotateX(tilt.toDouble()); // tilt angle

                return Transform(
                  transform: matrix,
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: Offset(0, floatY),
                    child: child,
                  ),
                );
              },
              child: GameWidget(
                game: _game,
                backgroundBuilder: (context) => const SizedBox.shrink(),
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
            ),
          ),
        ],
      ),
    );
  }
}
