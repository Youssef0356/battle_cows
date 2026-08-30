import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../game/models/hex_position.dart';
import '../../game/models/move.dart';
import '../../game/models/player.dart';
import '../../game/models/herd.dart';
import '../../game/models/pasture_tile.dart';
import '../../game/logic/game_engine.dart';
import '../../game/board/board_generator.dart';
import '../widgets/hex_board_widget.dart';
import '../widgets/player_indicator.dart';
import '../widgets/game_controls.dart';
import '../widgets/score_board.dart';

class GameScreen extends StatefulWidget {
  final List<Player> players;
  final List<PastureTile>? tiles;
  final int herdSize;
  final int boardSize;

  const GameScreen({
    super.key,
    required this.players,
    this.tiles,
    this.herdSize = 16,
    this.boardSize = 7,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameEngine _engine;
  late Timer _timer;
  int _timeRemaining = 30;
  HexPosition? _selectedPosition;
  List<HexPosition> _validMoves = [];
  Move? _selectedMove;
  int _splitCount = 1;

  late AnimationController _timerPulseController;
  late Animation<double> _timerPulseAnimation;

  late AnimationController _turnTransitionController;
  late Animation<double> _turnFadeAnimation;
  late Animation<Offset> _turnSlideAnimation;
  PlayerColor? _previousPlayerColor;

  Move? _animatingMove;
  late AnimationController _coinSlideController;
  late Animation<double> _coinSlideAnimation;

  @override
  void initState() {
    super.initState();

    _timerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _timerPulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _timerPulseController, curve: Curves.easeInOut),
    );

    _turnTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _turnFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _turnTransitionController, curve: Curves.easeIn),
    );
    _turnSlideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _turnTransitionController, curve: Curves.easeOutCubic),
    );

    _coinSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _coinSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _coinSlideController, curve: Curves.easeOutCubic),
    );

    _coinSlideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animatingMove = null;
        });
      }
    });

    _initializeGame();
  }

  void _initializeGame() {
    _previousPlayerColor = null;
    _engine = GameEngine();

    if (widget.tiles != null && widget.tiles!.isNotEmpty) {
      final board = BoardGenerator.generateFromTiles(
        widget.tiles!,
        widget.players,
        widget.herdSize,
      );
      _engine.initializeGame(board, widget.players);
    } else {
      _engine.initializeGame(
        BoardGenerator.generateFromTiles(_generateDefaultTiles(), widget.players, widget.herdSize),
        widget.players,
      );
    }

    _startTimer();
    _turnTransitionController.forward(from: 0);
  }

  List<PastureTile> _generateDefaultTiles() {
    final tiles = <PastureTile>[];
    final offsets = [
      const HexPosition(0, 0),
      const HexPosition(2, 0),
      const HexPosition(-2, 0),
      const HexPosition(0, 2),
      const HexPosition(0, -2),
      const HexPosition(2, -2),
      const HexPosition(-2, 2),
      const HexPosition(3, -1),
      const HexPosition(-3, 1),
    ];

    for (var i = 0; i < offsets.length; i++) {
      tiles.add(PastureTile.diamond(i, offsets[i]));
    }

    return tiles;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 10 && _timeRemaining > 0) {
          if (!_timerPulseController.isAnimating) {
            _timerPulseController.repeat(reverse: true);
          }
        }
        if (_timeRemaining <= 0) {
          _timerPulseController.stop();
          _timerPulseController.reset();
          _handleTimeUp();
        }
      });
    });
  }

  void _handleTimeUp() {
    if (_engine.currentPlayer.isAi) return;

    final validMoves = _engine.getValidMoves(_engine.currentPlayer.color);
    if (validMoves.isNotEmpty) {
      _executeMove(validMoves.first);
    } else {
      _nextTurn();
    }
  }

  void _nextTurn() {
    _timer.cancel();
    _timerPulseController.stop();
    _timerPulseController.reset();
    _timeRemaining = 30;
    _selectedPosition = null;
    _validMoves = [];
    _selectedMove = null;

    _previousPlayerColor = _engine.currentPlayer.color;

    setState(() {});

    if (_engine.gameOver) {
      _showGameOverDialog();
      return;
    }

    _startTimer();

    _turnTransitionController.forward(from: 0);

    if (_engine.currentPlayer.isAi) {
      _performAiMove();
    }
  }

  void _performAiMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      final validMoves = _engine.getValidMoves(_engine.currentPlayer.color);
      if (validMoves.isNotEmpty) {
        validMoves.sort((a, b) => b.splitCount.compareTo(a.splitCount));
        _executeMove(validMoves.first);
      } else {
        _nextTurn();
      }
    });
  }

  void _onCellTap(HexPosition position) {
    if (_engine.currentPlayer.isAi) return;
    if (_engine.gameOver) return;

    final herd = _engine.board?.getHerdAt(position);

    if (_selectedPosition == null) {
      if (herd != null && herd.owner == _engine.currentPlayer.color && herd.size >= 2) {
        setState(() {
          _selectedPosition = position;
          _validMoves = _engine.board!.getReachablePositions(position, herd.size)
              .where((p) => _engine.board!.isEmpty(p))
              .toList();
        });
      }
    } else {
      if (_validMoves.contains(position)) {
        final herd = _engine.board!.getHerdAt(_selectedPosition!);
        if (herd != null) {
          setState(() {
            _selectedMove = Move(
              from: _selectedPosition!,
              to: position,
              splitCount: 1,
              stayCount: herd.size - 1,
              player: _engine.currentPlayer.color,
            );
            _splitCount = 1;
          });
        }
      } else {
        setState(() {
          _selectedPosition = null;
          _validMoves = [];
          _selectedMove = null;
        });
      }
    }
  }

  void _onSplitChanged(int value) {
    setState(() {
      _splitCount = value;
      if (_selectedMove != null && _selectedPosition != null) {
        final herd = _engine.board!.getHerdAt(_selectedPosition!);
        if (herd != null) {
          _selectedMove = Move(
            from: _selectedMove!.from,
            to: _selectedMove!.to,
            splitCount: value,
            stayCount: herd.size - value,
            player: _engine.currentPlayer.color,
          );
        }
      }
    });
  }

  void _confirmMove() {
    if (_selectedMove == null || _selectedPosition == null) return;

    final herd = _engine.board!.getHerdAt(_selectedPosition!);
    if (herd == null) return;

    final move = Move(
      from: _selectedMove!.from,
      to: _selectedMove!.to,
      splitCount: _splitCount,
      stayCount: herd.size - _splitCount,
      player: _engine.currentPlayer.color,
    );

    _animatingMove = move;
    _coinSlideController.forward(from: 0).then((_) {
      _engine.executeMove(move);
      setState(() {
        _selectedPosition = null;
        _validMoves = [];
        _selectedMove = null;
        _animatingMove = null;
      });
      _nextTurn();
    });
  }

  void _executeMove(Move move) {
    _animatingMove = move;
    _coinSlideController.forward(from: 0).then((_) {
      _engine.executeMove(move);
      setState(() {
        _selectedPosition = null;
        _validMoves = [];
        _selectedMove = null;
        _animatingMove = null;
      });
      _nextTurn();
    });
  }

  void _cancelMove() {
    setState(() {
      _selectedPosition = null;
      _validMoves = [];
      _selectedMove = null;
    });
  }

  void _showGameOverDialog() {
    final winner = _engine.determineWinner();
    final territoryCounts = _engine.getTerritoryCount();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _GameOverDialog(
        winner: winner,
        territoryCounts: territoryCounts,
        players: widget.players,
        getPlayerName: _getPlayerName,
        onRematch: () {
          Navigator.of(context).pop();
          _initializeGame();
        },
        onMenu: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  String _getPlayerName(dynamic color) {
    final player = widget.players.firstWhere((p) => p.color == color);
    return player.name.toUpperCase();
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerPulseController.dispose();
    _turnTransitionController.dispose();
    _coinSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final territoryCounts = _engine.getTerritoryCount();
    final cowCounts = <PlayerColor, int>{};
    for (final player in widget.players) {
      cowCounts[player.color] = 0;
    }
    final herds = _engine.board?.herds ?? <Herd>[];
    for (final herd in herds) {
      cowCounts[herd.owner] = (cowCounts[herd.owner] ?? 0) + herd.size;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background/Background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildPlayerIndicators(territoryCounts, cowCounts),
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      HexBoardWidget(
                        board: _engine.board!,
                        selectedPosition: _selectedPosition,
                        validMoves: _validMoves,
                        onCellTap: _onCellTap,
                        currentPlayerColor: _engine.currentPlayer.color,
                      ),
                      if (_animatingMove != null)
                        _buildCoinSlideOverlay(),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: ScoreBoard(
                          players: widget.players,
                          territoryCounts: territoryCounts,
                          cowCounts: cowCounts,
                          currentPlayerColor: _engine.currentPlayer.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GameControls(
                    selectedMove: _selectedMove,
                    splitCount: _splitCount,
                    onSplitChanged: _onSplitChanged,
                    onConfirmMove: _confirmMove,
                    onCancelMove: _cancelMove,
                    canConfirm: _selectedMove != null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'BATTLE COWS',
            style: GoogleFonts.bangers(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _timerPulseAnimation,
            builder: (context, child) {
              final scale = _timeRemaining <= 10 ? _timerPulseAnimation.value : 1.0;
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getTimeColor(), width: 2),
                boxShadow: _timeRemaining <= 10
                    ? [
                        BoxShadow(
                          color: _getTimeColor().withValues(alpha: 0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Text(
                '$_timeRemaining S',
                style: GoogleFonts.bangers(
                  color: _getTimeColor(),
                  fontSize: 22,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerIndicators(Map<PlayerColor, int> territoryCounts, Map<PlayerColor, int> cowCounts) {
    return Expanded(
      flex: 1,
      child: FadeTransition(
        opacity: _turnFadeAnimation,
        child: SlideTransition(
          position: _turnSlideAnimation,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: widget.players.map((player) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PlayerIndicatorWidget(
                    player: player,
                    isActive: player.color == _engine.currentPlayer.color,
                    territoryCount: territoryCounts[player.color] ?? 0,
                    cowCount: cowCounts[player.color] ?? 0,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinSlideOverlay() {
    if (_animatingMove == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _coinSlideAnimation,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _CoinSlidePainter(
            move: _animatingMove!,
            progress: _coinSlideAnimation.value,
            board: _engine.board!,
          ),
        );
      },
    );
  }

  Color _getTimeColor() {
    if (_timeRemaining > 15) return AppColors.timerGreen;
    if (_timeRemaining > 5) return AppColors.timerAmber;
    return AppColors.timerRed;
  }
}

class _CoinSlidePainter extends CustomPainter {
  final Move move;
  final double progress;
  final dynamic board;

  _CoinSlidePainter({
    required this.move,
    required this.progress,
    required this.board,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hexSize = size.width / 20;

    final fromPixel = _hexToPixel(move.from, hexSize);
    final toPixel = _hexToPixel(move.to, hexSize);

    final currentPos = Offset(
      fromPixel.dx + (toPixel.dx - fromPixel.dx) * progress,
      fromPixel.dy + (toPixel.dy - fromPixel.dy) * progress,
    );

    final coinRadius = hexSize * 0.35;
    final coinColor = AppColors.getPlayerPrimary(move.player);
    final edgeColor = AppColors.getPlayerDark(move.player);

    for (int i = move.splitCount - 1; i >= 0; i--) {
      final coinCenter = Offset(
        currentPos.dx,
        currentPos.dy - i * coinRadius * 0.5,
      );

      final edgeHeight = coinRadius * 0.3;
      final edgePath = Path()
        ..addOval(Rect.fromCircle(center: Offset(coinCenter.dx, coinCenter.dy + edgeHeight), radius: coinRadius))
        ..addOval(Rect.fromCircle(center: coinCenter, radius: coinRadius))
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(edgePath, Paint()..color = edgeColor);

      final faceGradient = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          _lightenColor(coinColor, 0.3),
          coinColor,
          _darkenColor(coinColor, 0.2),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      canvas.drawOval(
        Rect.fromCircle(center: coinCenter, radius: coinRadius),
        Paint()..shader = faceGradient.createShader(Rect.fromCircle(center: coinCenter, radius: coinRadius)),
      );

      final rimPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawOval(
        Rect.fromCircle(center: coinCenter, radius: coinRadius * 0.85),
        rimPaint,
      );
    }

    final trailPaint = Paint()
      ..color = coinColor.withValues(alpha: 0.2)
      ..strokeWidth = hexSize * 0.5
      ..strokeCap = StrokeCap.round;

    final trailEnd = Offset(
      fromPixel.dx + (toPixel.dx - fromPixel.dx) * max(0, progress - 0.3),
      fromPixel.dy + (toPixel.dy - fromPixel.dy) * max(0, progress - 0.3),
    );
    canvas.drawLine(trailEnd, currentPos, trailPaint);
  }

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Offset _hexToPixel(HexPosition hex, double size) {
    final x = size * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
    final y = size * (3.0 / 2 * hex.r);
    return Offset(x + size * 12, y + size * 12);
  }

  @override
  bool shouldRepaint(covariant _CoinSlidePainter oldDelegate) => true;
}

class _GameOverDialog extends StatefulWidget {
  final PlayerColor? winner;
  final Map<PlayerColor, int> territoryCounts;
  final List<Player> players;
  final String Function(dynamic) getPlayerName;
  final VoidCallback onRematch;
  final VoidCallback onMenu;

  const _GameOverDialog({
    required this.winner,
    required this.territoryCounts,
    required this.players,
    required this.getPlayerName,
    required this.onRematch,
    required this.onMenu,
  });

  @override
  State<_GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<_GameOverDialog> with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
    _rotateAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeOutBack),
    );
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.95),
                      Colors.black.withValues(alpha: 0.99),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildConfetti(),
                    const Text('\ud83c\udfc6', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 12),
                    Text(
                      widget.winner != null
                          ? '${widget.getPlayerName(widget.winner)} WINS!'
                          : 'DRAW!',
                      style: GoogleFonts.bangers(
                        fontSize: 32,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            offset: const Offset(2, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'FINAL TERRITORY',
                            style: GoogleFonts.bangers(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...widget.territoryCounts.entries.map((entry) {
                            final color = entry.key;
                            final count = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AppColors.getPlayerPrimary(color),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.getPlayerName(color)}: $count',
                                    style: GoogleFonts.bangers(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondaryAction,
                                  AppColors.secondaryAction.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: ElevatedButton(
                              onPressed: widget.onMenu,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'MENU',
                                style: GoogleFonts.bangers(
                                  fontSize: 18,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: ElevatedButton(
                              onPressed: widget.onRematch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'REMATCH',
                                style: GoogleFonts.bangers(
                                  fontSize: 18,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfetti() {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _celebrationController,
        builder: (context, _) {
          final particles = <Widget>[];
          final random = Random(42);
          for (int i = 0; i < 15; i++) {
            final x = random.nextDouble() * 280;
            final startY = -10.0;
            final endY = 40.0;
            final currentY = startY + (endY - startY) * _celebrationController.value;
            final color = [
              AppColors.yellow,
              AppColors.primaryAction,
              AppColors.red,
              AppColors.blue,
              AppColors.purple,
            ][i % 5];

            particles.add(
              Positioned(
                left: x,
                top: currentY,
                child: Transform.rotate(
                  angle: _celebrationController.value * 3.14 * 2 * (i.isEven ? 1 : -1),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(i.isEven ? 4 : 1),
                    ),
                  ),
                ),
              ),
            );
          }
          return Stack(children: particles);
        },
      ),
    );
  }
}
