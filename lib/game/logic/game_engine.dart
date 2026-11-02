import 'dart:math';
import '../models/game_board.dart';
import '../models/herd.dart';
import '../models/move.dart';
import '../models/player.dart';
import '../models/player_color.dart';
import '../models/hex_cell.dart';
import '../models/hex_position.dart';
import '../models/challenge_mode.dart';

class GameEngine {
  GameBoard? _board;
  List<Player> _players = [];
  int _currentPlayerIndex = 0;
  int _turnCount = 0;
  bool _gameOver = false;
  int _lastCaptureCount = 0;
  ChallengeMode _challengeMode = ChallengeMode.standard;
  final Map<PlayerColor, int> _hearts = {};
  Random _random = Random();
  HexPosition? _lastSpawnedPosition;
  SpecialTileType? _lastSpawnedType;

  // ignore: unnecessary_getters_setters
  GameBoard? get board => _board;
  set board(GameBoard? value) => _board = value;
  List<Player> get players => _players;
  Player get currentPlayer => _players[_currentPlayerIndex];
  int get turnCount => _turnCount;
  bool get gameOver => _gameOver;
  int get lastCaptureCount => _lastCaptureCount;
  Map<PlayerColor, int> get hearts => Map.unmodifiable(_hearts);
  HexPosition? get lastSpawnedPosition => _lastSpawnedPosition;
  SpecialTileType? get lastSpawnedType => _lastSpawnedType;

  ChallengeMode get challengeMode => _challengeMode;

  void initializeGame(
    GameBoard board,
    List<Player> players, {
    ChallengeMode challengeMode = ChallengeMode.standard,
    Random? random,
  }) {
    _board = board;
    _players = players;
    _currentPlayerIndex = 0;
    _turnCount = 0;
    _gameOver = false;
    _challengeMode = challengeMode;
    if (random != null) _random = random;
    _lastSpawnedPosition = null;
    _lastSpawnedType = null;
    _hearts.clear();
    for (final player in players) {
      _hearts[player.color] = 3;
    }
    checkGameOver();
  }

  List<Move> getValidMoves(PlayerColor playerColor) {
    if (_board == null) return [];

    final moves = <Move>[];
    final playerHerds = _board!.herds.where((h) => h.owner == playerColor).toList();

    for (final herd in playerHerds) {
      if (herd.size < 2) continue;
      final reachable = _board!.getReachablePositions(herd.position, max(herd.size, 5));

      for (final target in reachable) {
        for (var split = 1; split < herd.size; split++) {
          moves.add(Move(
            from: herd.position,
            to: target,
            splitCount: split,
            stayCount: herd.size - split,
            player: playerColor,
          ));
        }
      }
    }

    return moves;
  }

  bool executeMove(Move move) {
    if (_board == null || _gameOver) return false;

    final validMoves = getValidMoves(move.player);
    final isValid = validMoves.any((m) =>
        m.from == move.from &&
        m.to == move.to &&
        m.splitCount == move.splitCount);

    if (!isValid) return false;

    final herds = List<Herd>.from(_board!.herds);
    final herdIndex = herds.indexWhere((h) =>
        h.position == move.from && h.owner == move.player);

    if (herdIndex == -1) return false;

    // Check if there's an enemy herd at the target position
    final targetHerd = herds.firstWhere(
      (h) => h.position == move.to,
      orElse: () => Herd(position: move.to, owner: move.player, size: 0),
    );

    _lastCaptureCount = 0;
    if (targetHerd.owner != move.player && targetHerd.size > 0) {
      _lastCaptureCount = targetHerd.size;
    }

    final originalHerd = herds[herdIndex];
    herds[herdIndex] = originalHerd.copyWith(size: move.stayCount);

    // Remove the enemy herd at target if it exists
    herds.removeWhere((h) => h.position == move.to);

    var movedCows = move.splitCount;
    final targetCell = _board!.getCell(move.to);
    if (targetCell?.specialType == SpecialTileType.goldenPasture) {
      movedCows++; // Golden pasture nourishes the herd with an extra cow
    }
    herds.add(Herd(position: move.to, owner: move.player, size: movedCows));

    final updatedCells = Map<HexPosition, HexCell>.from(_board!.cells);

    _lastSpawnedPosition = null;
    _lastSpawnedType = null;
    if (_challengeMode == ChallengeMode.stampedeRush) {
      _spawnBonusTile(updatedCells, herds);
    }

    _board = GameBoard(
      cells: updatedCells,
      herds: herds.where((h) => h.size > 0).toList(),
    );

    _turnCount++;
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;

    checkGameOver();

    return true;
  }

  void checkGameOver() {
    if (_board == null || _board!.herds.isEmpty) {
      _gameOver = false;
      return;
    }

    for (final player in _players) {
      final moves = getValidMoves(player.color);
      if (moves.isNotEmpty) {
        _gameOver = false;
        return;
      }
    }
    _gameOver = true;
  }

  void _spawnBonusTile(Map<HexPosition, HexCell> cells, List<Herd> herds) {
    final occupiedPositions = herds.where((h) => h.size > 0).map((h) => h.position).toSet();
    final eligiblePositions = cells.entries
        .where((entry) =>
            !entry.value.isObstacle &&
            entry.value.specialType == SpecialTileType.none &&
            !occupiedPositions.contains(entry.key))
        .map((entry) => entry.key)
        .toList();

    if (eligiblePositions.isEmpty) return;

    final targetHex = eligiblePositions[_random.nextInt(eligiblePositions.length)];
    final currentCell = cells[targetHex]!;
    // 80% chance for Hay Bale (+1 cow bonus), 20% for Golden Pasture (+1 cow & 3x territory points)
    final isGolden = _random.nextDouble() < 0.20;
    final special = isGolden ? SpecialTileType.goldenPasture : SpecialTileType.hayBale;

    cells[targetHex] = currentCell.copyWith(specialType: special);
    _lastSpawnedPosition = targetHex;
    _lastSpawnedType = special;
  }

  bool hasLegalMoves(PlayerColor playerColor) {
    return getValidMoves(playerColor).isNotEmpty;
  }

  bool currentPlayerHasNoMoves() {
    return getValidMoves(currentPlayer.color).isEmpty;
  }

  bool allPlayersHaveNoMoves() {
    for (final player in _players) {
      if (getValidMoves(player.color).isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  void advanceTurn() {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    _turnCount++;
  }

  int loseHeart() {
    if (_board == null) return 0;
    
    final player = currentPlayer;
    final currentHearts = _hearts[player.color] ?? 3;
    if (currentHearts <= 0) return 0;
    
    _hearts[player.color] = currentHearts - 1;
    
    // Check if player lost all hearts
    if (_hearts[player.color]! <= 0) {
      final alivePlayers = _players.where((p) => !playerIsEliminated(p.color)).toList();
      if (alivePlayers.length <= 1) {
        _gameOver = true;
      }
      return currentHearts - 1;
    }
    
    // Random cow movement for the current player
    _performRandomMove(player.color);
    
    return currentHearts - 1;
  }

  void _performRandomMove(PlayerColor playerColor) {
    if (_board == null) return;
    
    final playerHerds = _board!.herds.where((h) => h.owner == playerColor).toList();
    if (playerHerds.isEmpty) return;
    
    // Try to find a herd that can move (size >= 2)
    final movableHerds = playerHerds.where((h) => h.size >= 2).toList();
    if (movableHerds.isEmpty) return;
    
    // Pick a random herd
    final herd = movableHerds[_random.nextInt(movableHerds.length)];
    
    // Get reachable positions
    final reachable = _board!.getReachablePositions(herd.position, max(herd.size, 5));
    if (reachable.isEmpty) return;
    
    // Pick a random destination
    final destination = reachable[_random.nextInt(reachable.length)];
    
    // Execute a random split move
    final splitCount = 1 + _random.nextInt(herd.size - 1);
    final move = Move(
      from: herd.position,
      to: destination,
      splitCount: splitCount,
      stayCount: herd.size - splitCount,
      player: playerColor,
    );
    
    executeMove(move);
  }

  Map<PlayerColor, int> getTerritoryCount() {
    if (_board == null) return {};

    final counts = <PlayerColor, int>{};
    for (final player in _players) {
      counts[player.color] = 0;
    }

    for (final herd in _board!.herds) {
      final cell = _board!.getCell(herd.position);
      final tileValue = (cell?.specialType == SpecialTileType.goldenPasture) ? 3 : 1;
      counts[herd.owner] = (counts[herd.owner] ?? 0) + tileValue;
    }

    return counts;
  }

  bool playerIsEliminated(PlayerColor color) {
    if (_board == null) return false;
    final hearts = _hearts[color] ?? 3;
    return hearts <= 0;
  }

  /// Returns all players who tied for 1st place after all tiebreakers.
  /// If there is a single clear winner, returns a list with that single player.
  /// If game is not over, returns an empty list.
  List<PlayerColor> getWinningPlayers() {
    if (!_gameOver) return [];

    final candidatePlayers = _challengeMode == ChallengeMode.timed
        ? _players.where((p) => !playerIsEliminated(p.color)).toList()
        : _players;

    if (candidatePlayers.isEmpty) return [];
    if (candidatePlayers.length == 1) return [candidatePlayers.first.color];

    final territoryCounts = getTerritoryCount();

    // If all candidate players successfully placed all 16 herds, the match is an immediate draw
    final allPlaced16 = candidatePlayers.isNotEmpty &&
        candidatePlayers.every((p) => (territoryCounts[p.color] ?? 0) >= 16);
    if (allPlaced16) {
      return candidatePlayers.map((p) => p.color).toList();
    }

    int maxTerritory = -1;
    for (final player in candidatePlayers) {
      final score = territoryCounts[player.color] ?? 0;
      if (score > maxTerritory) {
        maxTerritory = score;
      }
    }

    final topScorers = candidatePlayers
        .where((p) => (territoryCounts[p.color] ?? 0) == maxTerritory)
        .map((p) => p.color)
        .toList();

    if (topScorers.length <= 1) {
      return topScorers;
    }

    // Tie-break only among top scorers
    return _breakTieFor(topScorers);
  }

  List<PlayerColor> _breakTieFor(List<PlayerColor> tiedPlayers) {
    if (_board == null || tiedPlayers.isEmpty) return tiedPlayers;
    if (tiedPlayers.length == 1) return tiedPlayers;

    final largestGroups = <PlayerColor, int>{};
    for (final color in tiedPlayers) {
      final herds = _board!.herds.where((h) => h.owner == color).toList();
      var largest = 0;
      for (final herd in herds) {
        final size = _board!.getContiguousGroupSize(herd.position);
        if (size > largest) largest = size;
      }
      largestGroups[color] = largest;
    }

    int maxSize = -1;
    for (final color in tiedPlayers) {
      final size = largestGroups[color] ?? 0;
      if (size > maxSize) {
        maxSize = size;
      }
    }

    final bestContiguous = tiedPlayers
        .where((c) => (largestGroups[c] ?? 0) == maxSize)
        .toList();

    if (bestContiguous.length <= 1) {
      return bestContiguous;
    }

    // Secondary Tie-break: Total cow count on the board
    final cowCounts = <PlayerColor, int>{};
    for (final color in bestContiguous) {
      final totalCows = _board!.herds
          .where((h) => h.owner == color)
          .fold<int>(0, (sum, h) => sum + h.size);
      cowCounts[color] = totalCows;
    }

    int maxCows = -1;
    for (final color in bestContiguous) {
      final cows = cowCounts[color] ?? 0;
      if (cows > maxCows) {
        maxCows = cows;
      }
    }

    final bestCows = bestContiguous
        .where((c) => (cowCounts[c] ?? 0) == maxCows)
        .toList();

    return bestCows;
  }

  PlayerColor? determineWinner() {
    final winners = getWinningPlayers();
    return winners.length == 1 ? winners.first : null;
  }

  PlayerColor? determineWinnerWithHearts() {
    return determineWinner();
  }

  /// Returns sorted standings (#1 to #N) for all players.
  List<PlayerStanding> getStandings() {
    final territoryCounts = getTerritoryCount();
    final largestGroups = <PlayerColor, int>{};
    final cowCounts = <PlayerColor, int>{};

    for (final player in _players) {
      final herds = _board?.herds.where((h) => h.owner == player.color).toList() ?? [];
      var largest = 0;
      var totalCows = 0;
      for (final herd in herds) {
        final size = _board?.getContiguousGroupSize(herd.position) ?? 0;
        if (size > largest) largest = size;
        totalCows += herd.size;
      }
      largestGroups[player.color] = largest;
      cowCounts[player.color] = totalCows;
    }

    final list = _players.map((p) {
      final isElim = _challengeMode == ChallengeMode.timed && playerIsEliminated(p.color);
      return _RawStanding(
        color: p.color,
        score: isElim ? -1 : (territoryCounts[p.color] ?? 0),
        largestGroup: largestGroups[p.color] ?? 0,
        cowCount: cowCounts[p.color] ?? 0,
        isEliminated: isElim,
      );
    }).toList();

    // Sort descending by score, then largestGroup, then cowCount
    list.sort((a, b) {
      if (a.isEliminated != b.isEliminated) {
        return a.isEliminated ? 1 : -1;
      }
      final scoreCmp = b.score.compareTo(a.score);
      if (scoreCmp != 0) return scoreCmp;
      final groupCmp = b.largestGroup.compareTo(a.largestGroup);
      if (groupCmp != 0) return groupCmp;
      return b.cowCount.compareTo(a.cowCount);
    });

    final standings = <PlayerStanding>[];
    var currentRank = 1;
    for (var i = 0; i < list.length; i++) {
      if (i > 0) {
        final prev = list[i - 1];
        final curr = list[i];
        final isTied = curr.score == prev.score &&
            curr.largestGroup == prev.largestGroup &&
            curr.cowCount == prev.cowCount;
        if (!isTied) {
          currentRank = i + 1;
        }
      }
      standings.add(PlayerStanding(
        color: list[i].color,
        score: list[i].isEliminated ? 0 : list[i].score,
        largestGroup: list[i].largestGroup,
        cowCount: list[i].cowCount,
        rank: currentRank,
        isEliminated: list[i].isEliminated,
      ));
    }

    return standings;
  }
}

class _RawStanding {
  final PlayerColor color;
  final int score;
  final int largestGroup;
  final int cowCount;
  final bool isEliminated;

  _RawStanding({
    required this.color,
    required this.score,
    required this.largestGroup,
    required this.cowCount,
    required this.isEliminated,
  });
}

class PlayerStanding {
  final PlayerColor color;
  final int score;
  final int largestGroup;
  final int cowCount;
  final int rank;
  final bool isEliminated;

  const PlayerStanding({
    required this.color,
    required this.score,
    required this.largestGroup,
    required this.cowCount,
    required this.rank,
    this.isEliminated = false,
  });
}
