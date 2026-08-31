import '../models/game_board.dart';
import '../models/player.dart';
import '../models/player_color.dart';

class TerritoryCounter {
  static Map<PlayerColor, int> countTerritory(GameBoard board, List<Player> players) {
    final counts = <PlayerColor, int>{};

    for (final player in players) {
      counts[player.color] = 0;
    }

    for (final herd in board.herds) {
      counts[herd.owner] = (counts[herd.owner] ?? 0) + 1;
    }

    return counts;
  }

  static Map<PlayerColor, int> countCows(GameBoard board, List<Player> players) {
    final counts = <PlayerColor, int>{};

    for (final player in players) {
      counts[player.color] = 0;
    }

    for (final herd in board.herds) {
      counts[herd.owner] = (counts[herd.owner] ?? 0) + herd.size;
    }

    return counts;
  }

  static PlayerColor? getLeader(GameBoard board, List<Player> players) {
    final territory = countTerritory(board, players);
    PlayerColor? leader;
    int maxCount = -1;

    for (final entry in territory.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        leader = entry.key;
      }
    }

    return leader;
  }
}
