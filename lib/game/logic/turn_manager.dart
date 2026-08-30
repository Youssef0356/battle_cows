import '../models/player.dart';

class TurnManager {
  final List<Player> _players;
  int _currentIndex = 0;
  final Set<int> _skippedPlayers = {};

  TurnManager(this._players);

  Player get currentPlayer => _players[_currentIndex];
  int get currentIndex => _currentIndex;

  Player nextTurn() {
    do {
      _currentIndex = (_currentIndex + 1) % _players.length;
    } while (_skippedPlayers.contains(_currentIndex) && _skippedPlayers.length < _players.length);

    return currentPlayer;
  }

  void skipPlayer(int playerId) {
    _skippedPlayers.add(playerId);
  }

  void resetSkipped() {
    _skippedPlayers.clear();
  }

  bool allPlayersSkipped() {
    return _skippedPlayers.length >= _players.length;
  }

  void reset() {
    _currentIndex = 0;
    _skippedPlayers.clear();
  }
}
