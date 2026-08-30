import '../models/game_board.dart';
import '../models/herd.dart';
import '../models/move.dart';
import '../models/player.dart';
import '../../core/constants/colors.dart';

class GameEngine {
  GameBoard? _board;
  List<Player> _players = [];
  int _currentPlayerIndex = 0;
  int _turnCount = 0;
  bool _gameOver = false;

  GameBoard? get board => _board;
  List<Player> get players => _players;
  Player get currentPlayer => _players[_currentPlayerIndex];
  int get turnCount => _turnCount;
  bool get gameOver => _gameOver;

  void initializeGame(GameBoard board, List<Player> players) {
    _board = board;
    _players = players;
    _currentPlayerIndex = 0;
    _turnCount = 0;
    _gameOver = false;
  }

  List<Move> getValidMoves(PlayerColor playerColor) {
    if (_board == null) return [];

    final moves = <Move>[];
    final playerHerds = _board!.herds.where((h) => h.owner == playerColor).toList();

    for (final herd in playerHerds) {
      if (herd.size < 2) continue;
      final reachable = _board!.getReachablePositions(herd.position, herd.size);

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

    final originalHerd = herds[herdIndex];
    herds[herdIndex] = originalHerd.copyWith(size: move.stayCount);
    herds.add(Herd(position: move.to, owner: move.player, size: move.splitCount));

    _board = GameBoard(
      cells: _board!.cells,
      herds: herds,
    );

    _turnCount++;
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;

    _checkGameOver();

    return true;
  }

  void _checkGameOver() {
    if (_board == null) return;

    for (final player in _players) {
      final moves = getValidMoves(player.color);
      if (moves.isNotEmpty) {
        _gameOver = false;
        return;
      }
    }
    _gameOver = true;
  }

  bool hasLegalMoves(PlayerColor playerColor) {
    return getValidMoves(playerColor).isNotEmpty;
  }

  Map<PlayerColor, int> getTerritoryCount() {
    if (_board == null) return {};

    final counts = <PlayerColor, int>{};
    for (final player in _players) {
      counts[player.color] = 0;
    }

    for (final herd in _board!.herds) {
      counts[herd.owner] = (counts[herd.owner] ?? 0) + 1;
    }

    return counts;
  }

  PlayerColor? determineWinner() {
    if (!_gameOver) return null;

    final territoryCounts = getTerritoryCount();
    PlayerColor? winner;
    int maxTerritory = -1;
    int tieCount = 0;

    for (final entry in territoryCounts.entries) {
      if (entry.value > maxTerritory) {
        maxTerritory = entry.value;
        winner = entry.key;
        tieCount = 1;
      } else if (entry.value == maxTerritory) {
        tieCount++;
      }
    }

    if (tieCount > 1) {
      return _breakTie();
    }

    return winner;
  }

  PlayerColor? _breakTie() {
    if (_board == null) return null;

    final largestGroups = <PlayerColor, int>{};

    for (final player in _players) {
      final herds = _board!.herds.where((h) => h.owner == player.color).toList();
      var largest = 0;
      for (final herd in herds) {
        final size = _board!.getContiguousGroupSize(herd.position);
        if (size > largest) largest = size;
      }
      largestGroups[player.color] = largest;
    }

    PlayerColor? winner;
    int maxSize = -1;

    for (final entry in largestGroups.entries) {
      if (entry.value > maxSize) {
        maxSize = entry.value;
        winner = entry.key;
      }
    }

    return winner;
  }
}
