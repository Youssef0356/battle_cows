import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../game/models/hex_position.dart';
import '../../game/models/move.dart';
import '../../game/models/player.dart';
import '../../game/models/herd.dart';
import '../../game/logic/game_engine.dart';
import '../../game/board/board_generator.dart';
import '../../game/ai/ai_player.dart';
import '../widgets/hex_board_widget.dart';
import '../widgets/player_indicator.dart';
import '../widgets/game_controls.dart';
import '../widgets/score_board.dart';

class GameScreen extends StatefulWidget {
  final List<Player> players;
  final int boardSize;

  const GameScreen({
    super.key,
    required this.players,
    required this.boardSize,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameEngine _engine;
  late Timer _timer;
  int _timeRemaining = 30;
  HexPosition? _selectedPosition;
  List<HexPosition> _validMoves = [];
  Move? _selectedMove;
  int _splitCount = 1;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _engine = GameEngine();
    final board = BoardGenerator.generate(
      widget.boardSize,
      widget.players,
      12,
    );
    _engine.initializeGame(board, widget.players);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
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
    _timeRemaining = 30;
    _selectedPosition = null;
    _validMoves = [];
    _selectedMove = null;

    setState(() {});

    if (_engine.gameOver) {
      _showGameOverDialog();
      return;
    }

    _startTimer();

    if (_engine.currentPlayer.isAi) {
      _performAiMove();
    }
  }

  void _performAiMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      final ai = AiPlayer(difficulty: Difficulty.medium);
      final move = ai.calculateMove(_engine, _engine.currentPlayer.color);

      if (move != null) {
        _executeMove(move);
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
      if (herd != null && herd.owner == _engine.currentPlayer.color) {
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
    if (_selectedMove == null) return;

    final move = Move(
      from: _selectedMove!.from,
      to: _selectedMove!.to,
      splitCount: _splitCount,
      stayCount: _selectedMove!.stayCount,
      player: _engine.currentPlayer.color,
    );

    _executeMove(move);
  }

  void _executeMove(Move move) {
    setState(() {
      _engine.executeMove(move);
      _selectedPosition = null;
      _validMoves = [];
      _selectedMove = null;
    });

    _nextTurn();
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
      builder: (context) => AlertDialog(
        title: Text(
          winner != null ? '${_getPlayerName(winner)} Wins!' : 'Draw!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Final Territory Count:'),
            const SizedBox(height: 8),
            ...territoryCounts.entries.map((entry) {
              final color = entry.key;
              final count = entry.value;
              return Text(
                '${_getPlayerName(color)}: $count tiles',
                style: TextStyle(
                  color: AppColors.getPlayerPrimary(color),
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Menu'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  String _getPlayerName(dynamic color) {
    final player = widget.players.firstWhere((p) => p.color == color);
    return player.name;
  }

  @override
  void dispose() {
    _timer.cancel();
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
      final current = cowCounts[herd.owner] ?? 0;
      cowCounts[herd.owner] = current + herd.size;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Battle Cows'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getTimeColor()),
                ),
                child: Text(
                  '$_timeRemaining s',
                  style: TextStyle(
                    color: _getTimeColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
            Expanded(
              flex: 1,
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
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ScoreBoard(
                      players: widget.players,
                      territoryCounts: territoryCounts.cast<PlayerColor, int>(),
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

  Color _getTimeColor() {
    if (_timeRemaining > 15) return AppColors.timerGreen;
    if (_timeRemaining > 5) return AppColors.timerAmber;
    return AppColors.timerRed;
  }
}
