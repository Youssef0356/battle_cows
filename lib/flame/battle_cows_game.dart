import 'dart:async' as async;
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';
import '../game/models/hex_position.dart';
import '../game/models/move.dart';
import '../game/models/player.dart';
import '../game/models/herd.dart';
import '../game/models/pasture_tile.dart';
import '../game/logic/game_engine.dart';
import '../game/board/board_generator.dart';
import '../game/board/board_builder.dart';
import '../game/ai/ai_player.dart';
import '../core/constants/colors.dart';
import 'components/hex_board_component.dart';
import 'components/background_component.dart';
import 'components/move_animation_component.dart';
import 'audio_manager.dart';

class BattleCowsGame extends FlameGame with TapCallbacks {
  final List<Player> players;
  final List<PastureTile>? tiles;
  final int herdSize;
  final int boardSize;

  late GameEngine _engine;
  late AiPlayer _aiPlayer;
  HexBoardComponent? _boardComponent;

  HexPosition? selectedPosition;
  List<HexPosition> validMoves = [];
  int selectedSplitCount = 1;
  int timeRemaining = 60;
  bool _timerRunning = false;
  async.Timer? _gameTimer;
  bool _isAnimating = false;

  PlayerColor? winner;
  Map<PlayerColor, int> territoryCounts = {};
  Map<PlayerColor, int> cowCounts = {};
  bool isGameOver = false;

  // Game stats
  int totalMoves = 0;
  Map<PlayerColor, int> capturesPerPlayer = {};
  Map<PlayerColor, int> largestHerdPerPlayer = {};

  // Hearts for survival mode
  Map<PlayerColor, int> playerHearts = {};

  // Placement phase
  bool _isPlacementPhase = false;
  int _currentPlayerIndex = 0;
  final int _tilesPerPlayer;
  List<int> _tilesRemaining = [];
  PastureTile? _currentTile;
  HexPosition _tileOffset = const HexPosition(0, 0);
  final BoardBuilder _boardBuilder = BoardBuilder();

  void Function()? onStateChanged;
  final void Function(PlayerColor? winner, Map<PlayerColor, int> scores)? onGameOver;
  final void Function()? onTimeUp;
  final void Function(String playerName, Color playerColor, bool isAi)? onTurnChanged;
  final void Function(int count, PlayerColor playerColor)? onCapture;
  final void Function(int heartsLeft)? onHeartLost;
  final void Function()? onPlacementComplete;

  BattleCowsGame({
    required this.players,
    this.tiles,
    this.herdSize = 16,
    this.boardSize = 7,
    int tilesPerPlayer = 5,
    this.onStateChanged,
    this.onGameOver,
    this.onTimeUp,
    this.onTurnChanged,
    this.onCapture,
    this.onHeartLost,
    this.onPlacementComplete,
  }) : _tilesPerPlayer = tilesPerPlayer;

  GameEngine get engine => _engine;
  bool get isAnimating => _isAnimating;
  bool get isPlacementPhase => _isPlacementPhase;
  int get currentPlayerIndex => _currentPlayerIndex;
  int get tilesPerPlayerSetting => _tilesPerPlayer;
  List<int> get tilesRemaining => List.unmodifiable(_tilesRemaining);
  PastureTile? get currentTile => _currentTile;
  HexPosition get tileOffset => _tileOffset;
  BoardBuilder get boardBuilder => _boardBuilder;

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
    totalMoves = 0;
    capturesPerPlayer = {};
    largestHerdPerPlayer = {};
    playerHearts = {};
    _boardBuilder.reset();
    _currentPlayerIndex = 0;
    _tilesRemaining = List.filled(players.length, _tilesPerPlayer);
    _currentTile = null;
    _tileOffset = const HexPosition(0, 0);

    for (final player in players) {
      capturesPerPlayer[player.color] = 0;
      largestHerdPerPlayer[player.color] = 0;
      playerHearts[player.color] = 3;
    }

    if (tiles != null && tiles!.isNotEmpty) {
      // Skip placement, go straight to game
      _isPlacementPhase = false;
      final board = BoardGenerator.generateFromTiles(tiles!, players, herdSize);
      _engine.initializeGame(board, players);
      _updateCounts();
      _startTimer();
      _setupBoardComponent();
    } else {
      // Start placement phase
      _isPlacementPhase = true;
      _generateNewTile();
      _setupBoardComponent();
    }

    onStateChanged?.call();
  }

  void _setupBoardComponent() {
    if (_boardComponent != null) {
      _boardComponent!.removeFromParent();
      _boardComponent = null;
    }

    if (!_isPlacementPhase) {
      final boardSize = _calculateBoardSize();
      _boardComponent = HexBoardComponent(
        board: _engine.board!,
        position: Vector2.zero(),
        size: Vector2(boardSize, boardSize),
        onCellTap: (pos) => onCellTapped(pos),
      );
      world.add(_boardComponent!);
    }

    camera.viewfinder.position = Vector2.zero();
    camera.viewfinder.anchor = Anchor.center;
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

  Player get _currentPlacementPlayer => players[_currentPlayerIndex];

  bool get _allTilesPlaced => _tilesRemaining.every((count) => count == 0);

  bool get canPlaceCurrentTile {
    if (_currentTile == null) return false;
    final translated = _currentTile!.translate(_tileOffset);
    return _boardBuilder.canPlace(translated);
  }

  void _generateNewTile() {
    final tileIndex = _boardBuilder.placedTiles.length;
    _currentTile = PastureTile.diamond(tileIndex, const HexPosition(0, 0));
    _tileOffset = const HexPosition(0, 0);

    // Default offset to adjacent position if board already has hexes
    if (_boardBuilder.placedHexes.isNotEmpty) {
      final outer = BoardGenerator.getOuterHexes(_boardBuilder.placedHexes);
      if (outer.isNotEmpty) {
        for (final hex in outer) {
          for (final dir in HexPosition.directions) {
            final testOffset = hex + dir;
            final candidate = _currentTile!.translate(testOffset);
            if (_boardBuilder.canPlace(candidate)) {
              _tileOffset = testOffset;
              return;
            }
          }
        }
      }
    }
  }

  void rotateCurrentTile() {
    if (_currentTile == null) return;
    _currentTile = _currentTile!.rotate(1);
    onStateChanged?.call();
  }

  void setTileOffset(HexPosition offset) {
    _tileOffset = offset;
    onStateChanged?.call();
  }

  bool placeCurrentTile() {
    if (_currentTile == null || !canPlaceCurrentTile) return false;

    final translated = _currentTile!.translate(_tileOffset);
    _boardBuilder.placeTile(translated);
    _tilesRemaining[_currentPlayerIndex]--;

    AudioManager().playMove();

    if (!_allTilesPlaced) {
      _advancePlacementTurn();
      _generateNewTile();
    } else {
      _currentTile = null;
      _finishPlacement();
    }

    onStateChanged?.call();
    return true;
  }

  void _advancePlacementTurn() {
    do {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % players.length;
    } while (_tilesRemaining[_currentPlayerIndex] == 0 && !_allTilesPlaced);

    // AI placement
    if (!_allTilesPlaced && _currentPlacementPlayer.isAi) {
      _performAiTilePlacement();
    }
  }

  void _performAiTilePlacement() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_allTilesPlaced || !_currentPlacementPlayer.isAi) return;

      final existing = _boardBuilder.placedHexes;
      if (existing.isEmpty) {
        _currentTile = PastureTile.diamond(_boardBuilder.placedTiles.length, const HexPosition(0, 0));
        _tileOffset = const HexPosition(0, 0);
        placeCurrentTile();
        return;
      }

      final outer = BoardGenerator.getOuterHexes(existing);
      final random = Random();
      final candidateOffsets = <HexPosition>[];
      for (final hex in outer) {
        for (final dir in HexPosition.directions) {
          final pos = hex + dir;
          if (!existing.contains(pos)) {
            candidateOffsets.add(pos);
          }
        }
      }
      candidateOffsets.shuffle(random);

      for (final offset in candidateOffsets) {
        for (var rot = 0; rot < 6; rot++) {
          final candidate = PastureTile.diamond(_boardBuilder.placedTiles.length, const HexPosition(0, 0))
              .rotate(rot)
              .translate(offset);
          if (_boardBuilder.canPlace(candidate)) {
            _currentTile = PastureTile.diamond(_boardBuilder.placedTiles.length, const HexPosition(0, 0)).rotate(rot);
            _tileOffset = offset;
            placeCurrentTile();
            return;
          }
        }
      }
    });
  }

  void _finishPlacement() {
    _isPlacementPhase = false;
    final board = BoardGenerator.generateFromTiles(_boardBuilder.placedTiles, players, herdSize);
    _engine.initializeGame(board, players);

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

    _updateCounts();
    _startTimer();

    onPlacementComplete?.call();
    onStateChanged?.call();
  }

  void onPlacementCellTapped(HexPosition position) {
    if (_currentPlacementPlayer.isAi || _allTilesPlaced || _currentTile == null) return;

    // Try to place at tapped position
    _tileOffset = position;
    placeCurrentTile();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_isPlacementPhase || _currentPlacementPlayer.isAi || _allTilesPlaced || _currentTile == null) {
      super.onTapDown(event);
      return;
    }

    // Convert tap position to hex position
    final worldPos = camera.viewfinder.globalToLocal(event.canvasPosition);
    final hexSize = 30.0;
    final q = ((sqrt(3) / 3 * worldPos.x - 1.0 / 3 * worldPos.y) / hexSize).round();
    final r = ((2.0 / 3 * worldPos.y) / hexSize).round();
    final hexPos = HexPosition(q, r);

    _tileOffset = hexPos;
    placeCurrentTile();
    super.onTapDown(event);
  }

  void _startTimer() {
    _timerRunning = true;
    timeRemaining = 60;
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

    // Lose a heart and perform random move
    final heartsLeft = _engine.loseHeart();
    playerHearts[_engine.currentPlayer.color] = heartsLeft;
    onHeartLost?.call(heartsLeft);

    // Check if game over due to heart loss
    if (_engine.gameOver) {
      _handleGameOver();
      return;
    }

    // Move to next turn
    nextTurn();
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
    while (true) {
      _timerRunning = false;
      _gameTimer?.cancel();
      timeRemaining = 60;
      selectedPosition = null;
      validMoves = [];

      _boardComponent?.updateSelection(null, []);

      if (_engine.gameOver || _engine.allPlayersHaveNoMoves()) {
        _handleGameOver();
        return;
      }

      if (_engine.currentPlayerHasNoMoves()) {
        _advanceTurn();
        continue;
      }

      _startTimer();

      final current = _engine.currentPlayer;
      onTurnChanged?.call(
        current.name,
        AppColors.getPlayerPrimary(current.color),
        current.isAi,
      );

      if (_engine.currentPlayer.isAi) {
        _performAiMove();
      }

      onStateChanged?.call();
      return;
    }
  }

  void _advanceTurn() {
    _engine.advanceTurn();
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
        selectedSplitCount = max(1, herd.size - 1);
        validMoves = _engine.board!.getReachablePositions(position, herd.size)
            .where((p) => _engine.board!.isEmpty(p))
            .toList();
        AudioManager().playSelect();
      }
    } else {
      if (validMoves.contains(position)) {
        final h = _engine.board!.getHerdAt(selectedPosition!);
        if (h != null) {
          final split = selectedSplitCount.clamp(1, max(1, h.size - 1)).toInt();
          final move = Move(
            from: selectedPosition!,
            to: position,
            splitCount: split,
            stayCount: h.size - split,
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

  void setSplitCount(int count) {
    if (selectedPosition == null) return;
    final herd = _engine.board?.getHerdAt(selectedPosition!);
    if (herd == null) return;
    selectedSplitCount = count.clamp(1, max(1, herd.size - 1));
    onStateChanged?.call();
  }

  void cancelMove() {
    selectedPosition = null;
    validMoves = [];
    _boardComponent?.updateSelection(null, []);
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

    final hexSize = _boardComponent!.size.x / 20;
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

    totalMoves++;

    final captureCount = _engine.lastCaptureCount;
    if (captureCount > 0) {
      capturesPerPlayer[move.player] = (capturesPerPlayer[move.player] ?? 0) + captureCount;
      onCapture?.call(captureCount, move.player);
    }

    _updateLargestHerd();

    nextTurn();
  }

  void _updateLargestHerd() {
    for (final player in players) {
      final herds = _engine.board?.herds.where((h) => h.owner == player.color).toList() ?? [];
      var largest = 0;
      for (final herd in herds) {
        if (herd.size > largest) largest = herd.size;
      }
      largestHerdPerPlayer[player.color] = largest;
    }
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

  void resetBoard() {
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
