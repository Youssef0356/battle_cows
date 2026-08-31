import 'dart:async' as async;
import 'dart:math';
import 'package:flame/game.dart';
import '../game/models/hex_position.dart';
import '../game/models/move.dart';
import '../game/models/player.dart';
import '../game/models/herd.dart';
import '../game/models/pasture_tile.dart';
import '../game/models/player_color.dart';
import '../game/logic/game_engine.dart';
import '../game/board/board_generator.dart';
import '../game/ai/ai_player.dart';
import 'components/hex_board_component.dart';
import 'components/background_component.dart';
import 'audio_manager.dart';

class BattleCowsGame extends FlameGame {
  final List<Player> players;
  final List<PastureTile>? tiles;
  final int herdSize;
  final int boardSize;

  late GameEngine _engine;
  late AiPlayer _aiPlayer;
  HexBoardComponent? _boardComponent;

  HexPosition? selectedPosition;
  List<HexPosition> validMoves = [];
  Move? selectedMove;
  int splitCount = 1;
  int timeRemaining = 30;
  bool _timerRunning = false;
  async.Timer? _gameTimer;

  PlayerColor? winner;
  Map<PlayerColor, int> territoryCounts = {};
  Map<PlayerColor, int> cowCounts = {};
  bool isGameOver = false;

  final void Function()? onStateChanged;
  final void Function(PlayerColor? winner, Map<PlayerColor, int> scores)? onGameOver;

  BattleCowsGame({
    required this.players,
    this.tiles,
    this.herdSize = 16,
    this.boardSize = 7,
    this.onStateChanged,
    this.onGameOver,
  });

  GameEngine get engine => _engine;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await AudioManager().init();
    _aiPlayer = AiPlayer();
    _initializeGame();

    final bg = BackgroundComponent(
      position: Vector2.zero(),
      size: Vector2(size.x, size.y),
    );
    world.add(bg);
  }

  void _initializeGame() {
    _engine = GameEngine();
    isGameOver = false;
    winner = null;
    selectedPosition = null;
    validMoves = [];
    selectedMove = null;
    splitCount = 1;

    if (tiles != null && tiles!.isNotEmpty) {
      final board = BoardGenerator.generateFromTiles(tiles!, players, herdSize);
      _engine.initializeGame(board, players);
    } else {
      _engine.initializeGame(
        BoardGenerator.generateFromTiles(_generateDefaultTiles(), players, herdSize),
        players,
      );
    }

    _updateCounts();
    _startTimer();

    if (_boardComponent != null) {
      _boardComponent!.removeFromParent();
    }

    final boardSize = _calculateBoardSize();
    _boardComponent = HexBoardComponent(
      board: _engine.board!,
      position: Vector2(size.x / 2, size.y / 2 - 50),
      size: Vector2(boardSize, boardSize),
      onCellTap: (pos) => onCellTapped(pos),
    );
    world.add(_boardComponent!);

    onStateChanged?.call();
  }

  double _calculateBoardSize() {
    if (_engine.board == null) return 400;
    final cells = _engine.board!.cells;
    if (cells.isEmpty) return 400;

    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    final hexSize = 20.0;
    for (final pos in cells.keys) {
      final x = hexSize * (sqrt(3) * pos.q + sqrt(3) / 2 * pos.r);
      final y = hexSize * (3.0 / 2 * pos.r);
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }

    final width = maxX - minX + hexSize * 4;
    final height = maxY - minY + hexSize * 4;
    return max(width, height);
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
    _timerRunning = true;
    timeRemaining = 30;
    _gameTimer?.cancel();
    _gameTimer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_timerRunning) {
        timer.cancel();
        return;
      }
      timeRemaining--;
      if (timeRemaining <= 5 && timeRemaining > 0) {
        AudioManager().playTick();
      }
      if (timeRemaining <= 0) {
        _handleTimeUp();
      }
      onStateChanged?.call();
    });
  }

  void _handleTimeUp() {
    _timerRunning = false;
    _gameTimer?.cancel();

    if (_engine.currentPlayer.isAi) return;

    final moves = _engine.getValidMoves(_engine.currentPlayer.color);
    if (moves.isNotEmpty) {
      executeMove(moves.first);
    } else {
      nextTurn();
    }
  }

  void nextTurn() {
    _timerRunning = false;
    _gameTimer?.cancel();
    timeRemaining = 30;
    selectedPosition = null;
    validMoves = [];
    selectedMove = null;
    splitCount = 1;

    _boardComponent?.updateSelection(null, []);

    if (_engine.gameOver) {
      _handleGameOver();
      return;
    }

    _startTimer();

    if (_engine.currentPlayer.isAi) {
      _performAiMove();
    }

    onStateChanged?.call();
  }

  void _performAiMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isGameOver) return;
      final move = _aiPlayer.calculateMove(_engine, _engine.currentPlayer.color);
      if (move != null) {
        executeMove(move);
      } else {
        nextTurn();
      }
    });
  }

  void onCellTapped(HexPosition position) {
    if (_engine.currentPlayer.isAi || isGameOver) return;

    final herd = _engine.board?.getHerdAt(position);

    if (selectedPosition == null) {
      if (herd != null && herd.owner == _engine.currentPlayer.color && herd.size >= 2) {
        selectedPosition = position;
        validMoves = _engine.board!.getReachablePositions(position, herd.size)
            .where((p) => _engine.board!.isEmpty(p))
            .toList();
      }
    } else {
      if (validMoves.contains(position)) {
        final h = _engine.board!.getHerdAt(selectedPosition!);
        if (h != null) {
          selectedMove = Move(
            from: selectedPosition!,
            to: position,
            splitCount: 1,
            stayCount: h.size - 1,
            player: _engine.currentPlayer.color,
          );
          splitCount = 1;
          AudioManager().playSelect();
        }
      } else {
        selectedPosition = null;
        validMoves = [];
        selectedMove = null;
      }
    }

    _boardComponent?.updateSelection(selectedPosition, validMoves);
    onStateChanged?.call();
  }

  void onSplitChanged(int value) {
    splitCount = value;
    if (selectedMove != null && selectedPosition != null) {
      final herd = _engine.board!.getHerdAt(selectedPosition!);
      if (herd != null) {
        selectedMove = Move(
          from: selectedMove!.from,
          to: selectedMove!.to,
          splitCount: value,
          stayCount: herd.size - value,
          player: _engine.currentPlayer.color,
        );
      }
    }
    onStateChanged?.call();
  }

  void confirmMove() {
    if (selectedMove == null || selectedPosition == null) return;

    final herd = _engine.board!.getHerdAt(selectedPosition!);
    if (herd == null) return;

    final move = Move(
      from: selectedMove!.from,
      to: selectedMove!.to,
      splitCount: splitCount,
      stayCount: herd.size - splitCount,
      player: _engine.currentPlayer.color,
    );

    executeMove(move);
  }

  void executeMove(Move move) {
    _engine.executeMove(move);
    selectedPosition = null;
    validMoves = [];
    selectedMove = null;
    _updateCounts();
    _boardComponent?.updateBoard(_engine.board!);
    AudioManager().playMove();
    nextTurn();
  }

  void cancelMove() {
    selectedPosition = null;
    validMoves = [];
    selectedMove = null;
    _boardComponent?.updateSelection(null, []);
    onStateChanged?.call();
  }

  void _updateCounts() {
    territoryCounts = _engine.getTerritoryCount();
    cowCounts = {};
    for (final player in players) {
      cowCounts[player.color] = 0;
    }
    final herds = _engine.board?.herds ?? <Herd>[];
    for (final herd in herds) {
      cowCounts[herd.owner] = (cowCounts[herd.owner] ?? 0) + herd.size;
    }
  }

  void _handleGameOver() {
    isGameOver = true;
    winner = _engine.determineWinner();
    _updateCounts();
    AudioManager().playGameOver();
    onGameOver?.call(winner, territoryCounts);
    onStateChanged?.call();
  }

  void rematch() {
    _initializeGame();
  }

  @override
  void onRemove() {
    _gameTimer?.cancel();
    super.onRemove();
  }

  static Vector2 hexToPixel(HexPosition hex, double size) {
    final x = size * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
    final y = size * (3.0 / 2 * hex.r);
    return Vector2(x + size * 12, y + size * 12);
  }
}
