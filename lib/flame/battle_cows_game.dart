import 'dart:async' as async;
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import '../game/models/hex_position.dart';
import '../game/models/move.dart';
import '../game/models/player.dart';
import '../game/models/herd.dart';
import '../game/models/pasture_tile.dart';
import '../game/models/game_board.dart';
import '../game/models/challenge_mode.dart';
import '../game/logic/game_engine.dart';
import '../game/board/board_generator.dart';
import '../game/board/board_builder.dart';
import '../game/ai/ai_player.dart';
import '../core/constants/colors.dart';
import '../ads/ad_manager.dart';
import 'components/hex_board_component.dart';
import 'components/background_component.dart';
import 'components/board_border_component.dart';
import 'components/move_animation_component.dart';
import 'components/placement_preview_component.dart';
import 'audio_manager.dart';

class BattleCowsGame extends FlameGame with DragCallbacks {
  final List<Player> players;
  final List<PastureTile>? tiles;
  final int herdSize;
  final int boardSize;
  final ChallengeMode challengeMode;
  String backgroundAsset;

  late GameEngine _engine;
  late AiPlayer _aiPlayer;
  HexBoardComponent? _boardComponent;
  BoardBorderComponent? _borderComponent;
  PlacementPreviewComponent? _previewComponent;
  BackgroundComponent? _backgroundComponent;

  HexPosition? selectedPosition;
  List<HexPosition> validMoves = [];
  int selectedSplitCount = 1;
  int timeRemaining = 60;
  bool _timerRunning = false;
  async.Timer? _gameTimer;
  bool _isAnimating = false;
  bool isPlacementDragActive = false;
  double _shakeTime = 0;
  double _shakeStrength = 0;

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
  bool _isHerdPlacementPhase = false;
  int _currentPlayerIndex = 0;
  int _herdPlacementPlayerIndex = 0;
  List<HexPosition> _validHerdPositions = [];
  final int _tilesPerPlayer;
  List<int> _tilesRemaining = [];
  PastureTile? _currentTile;
  HexPosition _tileOffset = const HexPosition(0, 0);
  final BoardBuilder _boardBuilder = BoardBuilder();
  final List<void Function()> _stateListeners = [];
  int _sessionId = 0;

  double get _hexSize {
    final shortestSide = min(size.x, size.y);
    final density = max(14, boardSize + _tilesPerPlayer);
    return shortestSide > 0 ? shortestSide * .94 / density : 30.0;
  }

  void Function()? onStateChanged;
  final void Function(PlayerColor? winner, Map<PlayerColor, int> scores)? onGameOver;
  final void Function()? onTimeUp;
  final void Function(String playerName, Color playerColor, bool isAi)? onTurnChanged;
  final void Function(int count, PlayerColor playerColor)? onCapture;
  final void Function(int heartsLeft)? onHeartLost;
  final void Function()? onPlacementComplete;
  final void Function()? onTilePlacementComplete;

  void notifyStateChanged() {
    if (!_callbacksEnabled) return;
    onStateChanged?.call();
    for (final listener in List<void Function()>.from(_stateListeners)) {
      listener();
    }
  }

  void addStateListener(void Function() listener) => _stateListeners.add(listener);

  void removeStateListener(void Function() listener) => _stateListeners.remove(listener);

  bool _callbacksEnabled = true;

  void disableCallbacks() {
    _callbacksEnabled = false;
    _timerRunning = false;
    _gameTimer?.cancel();
  }

  BattleCowsGame({
    required this.players,
    this.tiles,
    this.herdSize = 16,
    this.boardSize = 7,
    int tilesPerPlayer = 5,
    this.challengeMode = ChallengeMode.standard,
    this.backgroundAsset = 'assets/images/Background/Table image.jpg',
    this.onStateChanged,
    this.onGameOver,
    this.onTimeUp,
    this.onTurnChanged,
    this.onCapture,
    this.onHeartLost,
    this.onPlacementComplete,
    this.onTilePlacementComplete,
  }) : _tilesPerPlayer = tilesPerPlayer;

  GameEngine get engine => _engine;
  bool get isAnimating => _isAnimating;
  bool get isPlacementPhase => _isPlacementPhase;
  bool get isHerdPlacementPhase => _isHerdPlacementPhase;
  int get currentPlayerIndex => _currentPlayerIndex;
  int get herdPlacementPlayerIndex => _herdPlacementPlayerIndex;
  List<HexPosition> get validHerdPositions => List.unmodifiable(_validHerdPositions);
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
      assetPath: backgroundAsset,
    );
    _backgroundComponent = bg;
    camera.backdrop.add(bg);

    _initializeGame();
  }

  void _initializeGame() {
    _sessionId++;
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
      _isPlacementPhase = false;
      final board = BoardGenerator.generateEmptyBoard(tiles!, mode: challengeMode);
      _engine.initializeGame(board, players, challengeMode: challengeMode);
      _setupBoardComponent();
      _startHerdPlacement();
      onTilePlacementComplete?.call();
    } else {
      // Start placement phase
      _isPlacementPhase = true;
      _generateNewTile();
      _setupBoardComponent();
    }

    notifyStateChanged();
  }

  void _setupBoardComponent() {
    if (_boardComponent != null) {
      _boardComponent!.removeFromParent();
      _boardComponent = null;
    }
    if (_borderComponent != null) {
      _borderComponent!.removeFromParent();
      _borderComponent = null;
    }
    if (_previewComponent != null) {
      _previewComponent!.removeFromParent();
      _previewComponent = null;
    }

    if (_isPlacementPhase) {
      final board = GameBoard(cells: {}, herds: []);
        final fixedSize = _hexSize * 15;
      _boardComponent = HexBoardComponent(
        board: board,
        position: Vector2.zero(),
        size: Vector2(fixedSize, fixedSize),
      );
      world.add(_boardComponent!);

      _previewComponent = PlacementPreviewComponent(
        position: Vector2.zero(),
        hexSize: _hexSize,
      );
      world.add(_previewComponent!);

      _rebuildPlacementCells();
      _updatePreview();
    } else {
        final boardSize = _hexSize * 15;
      _boardComponent = HexBoardComponent(
        board: _engine.board!,
        position: Vector2.zero(),
        size: Vector2(boardSize, boardSize),
      );
      world.add(_boardComponent!);
    }

    camera.viewfinder.position = Vector2.zero();
    camera.viewfinder.anchor = Anchor.center;
  }

  void _rebuildPlacementCells() {
    if (_boardComponent == null) return;
    for (final hex in _boardBuilder.placedHexes) {
      _boardComponent!.addCell(hex);
    }
  }

  void _updatePreview() {
    if (_previewComponent == null) return;
    _previewComponent!.updatePreview(
      tile: _currentTile,
      offset: _tileOffset,
      isValid: canPlaceCurrentTile,
    );
  }

  Player get _currentPlacementPlayer => players[_currentPlayerIndex];

  bool get _allTilesPlaced => _tilesRemaining.every((count) => count == 0);

  bool get canPlaceCurrentTile {
    if (_currentTile == null) return false;
    final translated = _currentTile!.translate(_tileOffset);
    if (!_boardBuilder.canPlace(translated)) return false;
    return _isTileWithinBounds(translated);
  }

  bool _isTileWithinBounds(PastureTile tile) {
    final hexSize = _hexSize;
    const horizontalMarginFraction = 0.23;
    const topMarginFraction = 0.34;
    const bottomMarginFraction = 0.23;
    final halfW = size.x / 2;
    final halfH = size.y / 2;
    final marginX = halfW * horizontalMarginFraction;
    final topMargin = halfH * topMarginFraction;
    final bottomMargin = halfH * bottomMarginFraction;

    for (final pos in tile.hexes) {
      final px = hexSize * (sqrt(3) * pos.q + sqrt(3) / 2 * pos.r);
      final py = hexSize * (3.0 / 2 * pos.r);
      if (px < -halfW + marginX || px > halfW - marginX) return false;
      if (py < -halfH + topMargin || py > halfH - bottomMargin) return false;
    }
    return true;
  }

  Future<void> setBackgroundAsset(String assetPath) async {
    backgroundAsset = assetPath;
    await _backgroundComponent?.setAsset(assetPath);
    notifyStateChanged();
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
            if (_boardBuilder.canPlace(candidate) && _isTileWithinBounds(candidate)) {
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
    _updatePreview();
    notifyStateChanged();
  }

  void setTileOffset(HexPosition offset) {
    _tileOffset = offset;
    _updatePreview();
    notifyStateChanged();
  }

  bool placeCurrentTile() {
    if (_currentTile == null || !canPlaceCurrentTile) return false;

    final translated = _currentTile!.translate(_tileOffset);
    _boardBuilder.placeTile(translated);
    _tilesRemaining[_currentPlayerIndex]--;

    AudioManager().playMove();

    for (final hex in translated.hexes) {
      _boardComponent?.addCell(hex);
    }

    if (!_allTilesPlaced) {
      _advancePlacementTurn();
      _generateNewTile();
      _updatePreview();
    } else {
      _currentTile = null;
      _finishPlacement();
    }

    notifyStateChanged();
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
    final session = _sessionId;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (session != _sessionId || !_callbacksEnabled || _allTilesPlaced || !_currentPlacementPlayer.isAi) return;

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
          if (_boardBuilder.canPlace(candidate) && _isTileWithinBounds(candidate)) {
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

    final board = BoardGenerator.generateEmptyBoard(_boardBuilder.placedTiles, mode: challengeMode);
    _engine.initializeGame(board, players, challengeMode: challengeMode);

    if (_boardComponent != null) {
      _boardComponent!.removeFromParent();
      _boardComponent = null;
    }
    if (_borderComponent != null) {
      _borderComponent!.removeFromParent();
      _borderComponent = null;
    }
    if (_previewComponent != null) {
      _previewComponent!.removeFromParent();
      _previewComponent = null;
    }
    final boardSize = _hexSize * 15;
    _boardComponent = HexBoardComponent(
      board: _engine.board!,
      position: Vector2.zero(),
      size: Vector2(boardSize, boardSize),
    );
    world.add(_boardComponent!);

    final allHexes = _engine.board!.cells.keys.toList();
    _borderComponent = BoardBorderComponent(
      hexPositions: allHexes,
      hexSize: _hexSize,
      position: Vector2.zero(),
      size: Vector2(boardSize, boardSize),
    );
    world.add(_borderComponent!);

    camera.viewfinder.position = Vector2.zero();
    camera.viewfinder.anchor = Anchor.center;

    _startHerdPlacement();

    onTilePlacementComplete?.call();
    notifyStateChanged();
  }

  void _startHerdPlacement() {
    _isHerdPlacementPhase = true;
    _herdPlacementPlayerIndex = 0;
    _computeValidHerdPositions();
    _performAiHerdPlacementIfNeeded();
    notifyStateChanged();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shakeTime <= 0) {
      camera.viewfinder.position = Vector2.zero();
      return;
    }
    _shakeTime -= dt;
    final zoom = camera.viewfinder.zoom;
    final strength = _shakeStrength * (_shakeTime / .22).clamp(0.0, 1.0) * zoom;
    camera.viewfinder.position = Vector2(
      sin(_shakeTime * 95) * strength,
      cos(_shakeTime * 83) * strength,
    );
  }

  void shakeCamera({double strength = 3.0}) {
    _shakeTime = .22;
    _shakeStrength = strength;
  }

  void _computeValidHerdPositions() {
    final allHexes = _engine.board!.cells.keys.toList();
    final herds = _engine.board!.herds.map((h) => h.position).toSet();
    final outerHexes = BoardGenerator.getOuterHexes(allHexes);
    _validHerdPositions = outerHexes.where((h) => !herds.contains(h)).toList();

    _boardComponent?.updateBoard(_engine.board!);
    _boardComponent?.updateSelection(null, _validHerdPositions);
  }

  void placeHerdAt(HexPosition position) {
    if (!_isHerdPlacementPhase) return;
    if (!_validHerdPositions.contains(position)) return;

    final player = players[_herdPlacementPlayerIndex];
    final herd = Herd(
      position: position,
      owner: player.color,
      size: herdSize,
    );
    _engine.board!.herds.add(herd);

    final cell = _boardComponent?.cells[position];
    if (cell != null) {
      cell.herd = herd;
      cell.territoryOwner = herd.owner;
    }

    shakeCamera(strength: 2.5);

    _herdPlacementPlayerIndex++;

    if (_herdPlacementPlayerIndex >= players.length) {
      _finishHerdPlacement();
    } else {
      _computeValidHerdPositions();
      _performAiHerdPlacementIfNeeded();
    }
    notifyStateChanged();
  }

  void _performAiHerdPlacementIfNeeded() {
    if (!_isHerdPlacementPhase || _herdPlacementPlayerIndex >= players.length) return;
    if (!players[_herdPlacementPlayerIndex].isAi || _validHerdPositions.isEmpty) return;
    final session = _sessionId;
    Future.delayed(const Duration(milliseconds: 450), () {
      if (session != _sessionId || !_callbacksEnabled || !_isHerdPlacementPhase || _validHerdPositions.isEmpty) return;
      placeHerdAt(_validHerdPositions[Random().nextInt(_validHerdPositions.length)]);
    });
  }

  void _finishHerdPlacement() {
    _isHerdPlacementPhase = false;
    _validHerdPositions = [];

    _boardComponent?.updateBoard(_engine.board!);

    _updateCounts();
    _startTimer();

    onPlacementComplete?.call();
    notifyStateChanged();
  }

  void onPlacementCellTapped(HexPosition position) {
    if (_currentPlacementPlayer.isAi || _allTilesPlaced || _currentTile == null) return;
    _tileOffset = position;
    _updatePreview();
    notifyStateChanged();
  }

  bool _isDragging = false;

  HexPosition _screenToHex(Vector2 screenPos) {
    return _worldToHex(camera.globalToLocal(screenPos));
  }

  HexPosition _worldToHex(Vector2 worldPos) {
    final hexSize = _hexSize;
    if (hexSize <= 0) return const HexPosition(0, 0);
    final q = (sqrt(3) / 3 * worldPos.x - 1.0 / 3 * worldPos.y) / hexSize;
    final r = (2.0 / 3 * worldPos.y) / hexSize;
    return _cubeRound(q, r);
  }

  HexPosition _cubeRound(double fq, double fr) {
    final fs = -fq - fr;
    var q = fq.round();
    var r = fr.round();
    var s = fs.round();
    final qDiff = (q - fq).abs();
    final rDiff = (r - fr).abs();
    final sDiff = (s - fs).abs();
    if (qDiff > rDiff && qDiff > sDiff) {
      q = -r - s;
    } else if (rDiff > sDiff) {
      r = -q - s;
    }
    return HexPosition(q, r);
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (!_isPlacementPhase || _currentPlacementPlayer.isAi || _allTilesPlaced || _currentTile == null) {
      super.onDragStart(event);
      return;
    }
    _isDragging = true;
    isPlacementDragActive = true;
    _tileOffset = _screenToHex(event.canvasPosition);
    _updatePreview();
    notifyStateChanged();
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging || !_isPlacementPhase || _currentTile == null) {
      super.onDragUpdate(event);
      return;
    }
    _tileOffset = _screenToHex(event.canvasEndPosition);
    _updatePreview();
    notifyStateChanged();
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!_isDragging || !_isPlacementPhase || _currentTile == null) {
      super.onDragEnd(event);
      return;
    }
    _isDragging = false;
    isPlacementDragActive = false;
    placeCurrentTile();
    super.onDragEnd(event);
  }

  void onTapDownFromScreen(TapUpDetails details) {
    final hexPos = _screenToHex(Vector2(details.localPosition.dx, details.localPosition.dy));

    if (_isHerdPlacementPhase) {
      if (_validHerdPositions.contains(hexPos)) {
        placeHerdAt(hexPos);
      }
      return;
    }

    if (!_isPlacementPhase || _currentPlacementPlayer.isAi || _allTilesPlaced || _currentTile == null) {
      if (!_isPlacementPhase && !_isHerdPlacementPhase && !isGameOver && !_isAnimating) {
        onCellTapped(hexPos);
      }
      return;
    }

    _tileOffset = hexPos;
    _updatePreview();
    notifyStateChanged();
  }

  void _startTimer() {
    if (!challengeMode.hasTimer) {
      _timerRunning = false;
      _gameTimer?.cancel();
      timeRemaining = 0;
      notifyStateChanged();
      return;
    }
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
      notifyStateChanged();
    });
  }

  void _handleTimeUp() {
    _timerRunning = false;
    _gameTimer?.cancel();

    final timedOutPlayer = _engine.currentPlayer;
    final heartsLeft = _engine.loseHeart();
    playerHearts[timedOutPlayer.color] = heartsLeft;
    onHeartLost?.call(heartsLeft);

    _boardComponent?.updateBoard(_engine.board!);
    _updateCounts();

    if (_engine.gameOver) {
      _handleGameOver();
      return;
    }

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

      notifyStateChanged();
      return;
    }
  }

  void _advanceTurn() {
    _engine.advanceTurn();
  }

  void _performAiMove() {
    final session = _sessionId;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (session != _sessionId || !_callbacksEnabled || isGameOver) return;
      final move = _aiPlayer.calculateMove(_engine, _engine.currentPlayer.color);
      if (move != null) {
        _executeWithAnimation(move);
      } else {
        nextTurn();
      }
    });
  }

  void onCellTapped(HexPosition position) {
    if (_isHerdPlacementPhase) {
      if (_validHerdPositions.contains(position)) {
        placeHerdAt(position);
      }
      return;
    }
    if (_isPlacementPhase || _engine.currentPlayer.isAi || isGameOver || _isAnimating) return;

    final herd = _engine.board?.getHerdAt(position);

    if (selectedPosition == null) {
      if (herd != null && herd.owner == _engine.currentPlayer.color && herd.size >= 2) {
        selectedPosition = position;
        selectedSplitCount = 1;
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
    notifyStateChanged();
  }

  void setSplitCount(int count) {
    if (selectedPosition == null) return;
    final herd = _engine.board?.getHerdAt(selectedPosition!);
    if (herd == null) return;
    selectedSplitCount = count.clamp(1, max(1, herd.size - 1));
    notifyStateChanged();
  }

  void cancelMove() {
    selectedPosition = null;
    validMoves = [];
    _boardComponent?.updateSelection(null, []);
    notifyStateChanged();
  }

  void _executeWithAnimation(Move move) {
    _isAnimating = true;
    _timerRunning = false;
    _gameTimer?.cancel();
    notifyStateChanged();

    final fromPos = move.from;
    final toPos = move.to;
    final herd = _engine.board?.getHerdAt(fromPos);
    if (herd == null) {
      _isAnimating = false;
      executeMove(move);
      return;
    }

    final hexSize = _hexSize;
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
      AudioManager().playCapture();
      shakeCamera(strength: min(8.0, 2.5 + captureCount));
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
    territoryCounts = _engine.getChallengeScores();
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
    AdManager().loadInterstitialAd();
    onGameOver?.call(winner, territoryCounts);
    notifyStateChanged();
  }

  void rematch() {
    _resetOverlaysForNewMatch();
    _initializeGame();
    if (tiles == null || tiles!.isEmpty) {
      overlays.add('Placement');
    }
  }

  void resetBoard() {
    rematch();
  }

  void _resetOverlaysForNewMatch() {
    overlays.remove('GameOver');
    overlays.remove('HUD');
    overlays.remove('GameControls');
    overlays.remove('Scoreboard');
    overlays.remove('HerdPlacement');
    overlays.remove('Placement');
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
