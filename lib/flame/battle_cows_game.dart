import 'dart:async' as async;
import 'dart:math';
import 'package:flame/game.dart';
import '../game/models/hex_position.dart';
import '../game/models/move.dart';
import '../game/models/player.dart';
import '../game/models/herd.dart';
import '../game/models/pasture_tile.dart';
import '../game/logic/game_engine.dart';
import '../game/board/board_generator.dart';
import '../game/ai/ai_player.dart';
import '../core/constants/colors.dart';
import 'components/hex_board_component.dart';
import 'components/background_component.dart';
import 'components/move_animation_component.dart';
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
  int timeRemaining = 30;
  bool _timerRunning = false;
  async.Timer? _gameTimer;
  bool _isAnimating = false;

  PlayerColor? winner;
  Map<PlayerColor, int> territoryCounts = {};
  Map<PlayerColor, int> cowCounts = {};
  bool isGameOver = false;

  final void Function()? onStateChanged;
  final void Function(PlayerColor? winner, Map<PlayerColor, int> scores)? onGameOver;
  final void Function()? onTimeUp;

  BattleCowsGame({
    required this.players,
    this.tiles,
    this.herdSize = 16,
    this.boardSize = 7,
    this.onStateChanged,
    this.onGameOver,
    this.onTimeUp,
  });

  GameEngine get engine => _engine;
  bool get isAnimating => _isAnimating;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await AudioManager().init();
    _aiPlayer = AiPlayer();

    final bg = BackgroundComponent(
      position: Vector2.zero(),
      size: Vector2(size.x, size.y),
    );
    camera.backdrop.add(bg);

    _initializeGame();
  }

  void _initializeGame() {
    _engine = GameEngine();
    isGameOver = false;
    winner = null;
    selectedPosition = null;
    validMoves = [];
    _isAnimating = false;

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
      position: Vector2.zero(),
      size: Vector2(boardSize, boardSize),
      onCellTap: (pos) => onCellTapped(pos),
    );
    world.add(_boardComponent!);

    camera.viewfinder.position = Vector2.zero();
    camera.viewfinder.anchor = Anchor.center;

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

    final hexSize = 30.0;
    for (final pos in cells.keys) {
      final x = hexSize * (sqrt(3) * pos.q + sqrt(3) / 2 * pos.r);
      final y = hexSize * (3.0 / 2 * pos.r);
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }

    final width = maxX - minX + hexSize * 6;
    final height = maxY - minY + hexSize * 6;
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
      const HexPosition(-2, -2),
      const HexPosition(2, 2),
      const HexPosition(4, 0),
      const HexPosition(-4, 0),
      const HexPosition(0, 4),
      const HexPosition(0, -4),
      const HexPosition(3, -3),
      const HexPosition(-3, 3),
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

    onTimeUp?.call();
  }

  void addExtraTime(int seconds) {
    timeRemaining += seconds;
    _startTimer();
  }

  void autoPlayMove() {
    final moves = _engine.getValidMoves(_engine.currentPlayer.color);
    if (moves.isNotEmpty) {
      _executeWithAnimation(moves.first);
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
        _executeWithAnimation(move);
      } else {
        nextTurn();
      }
    });
  }

  void onCellTapped(HexPosition position) {
    if (_engine.currentPlayer.isAi || isGameOver || _isAnimating) return;

    final herd = _engine.board?.getHerdAt(position);

    if (selectedPosition == null) {
      if (herd != null && herd.owner == _engine.currentPlayer.color && herd.size >= 2) {
        selectedPosition = position;
        validMoves = _engine.board!.getReachablePositions(position, herd.size)
            .where((p) => _engine.board!.isEmpty(p))
            .toList();
        AudioManager().playSelect();
      }
    } else {
      if (validMoves.contains(position)) {
        final h = _engine.board!.getHerdAt(selectedPosition!);
        if (h != null) {
          final move = Move(
            from: selectedPosition!,
            to: position,
            splitCount: 1,
            stayCount: h.size - 1,
            player: _engine.currentPlayer.color,
          );
          _executeWithAnimation(move);
          return;
        }
      }
      selectedPosition = null;
      validMoves = [];
    }

    _boardComponent?.updateSelection(selectedPosition, validMoves);
    onStateChanged?.call();
  }

  void _executeWithAnimation(Move move) {
    _isAnimating = true;
    _timerRunning = false;
    _gameTimer?.cancel();
    onStateChanged?.call();

    final fromPos = move.from;
    final toPos = move.to;
    final herd = _engine.board?.getHerdAt(fromPos);
    if (herd == null) {
      _isAnimating = false;
      executeMove(move);
      return;
    }

    final hexSize = _boardComponent!.size.x / 14;
    final fromPixel = _boardComponent!.hexToPixel(fromPos, hexSize);
    final toPixel = _boardComponent!.hexToPixel(toPos, hexSize);

    final animComponent = MoveAnimationComponent(
      from: fromPixel,
      to: toPixel,
      count: move.splitCount,
      color: AppColors.getPlayerPrimary(herd.owner),
      onComplete: () {
        _isAnimating = false;
        executeMove(move);
      },
    );
    add(animComponent);
  }

  void executeMove(Move move) {
    _engine.executeMove(move);
    selectedPosition = null;
    validMoves = [];
    _updateCounts();
    _boardComponent?.updateBoard(_engine.board!);
    AudioManager().playMove();
    nextTurn();
  }

  void cancelMove() {
    selectedPosition = null;
    validMoves = [];
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
