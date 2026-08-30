import '../../core/constants/colors.dart';

class GameSettings {
  final int playerCount;
  final List<dynamic> players;
  final int boardSize;
  final int herdSize;
  final int turnTimeSeconds;

  const GameSettings({
    required this.playerCount,
    required this.players,
    required this.boardSize,
    this.herdSize = 12,
    this.turnTimeSeconds = 30,
  });

  factory GameSettings.default2Player() {
    return GameSettings(
      playerCount: 2,
      players: [
        {'id': 0, 'name': 'Blue', 'color': PlayerColor.blue, 'isAi': false},
        {'id': 1, 'name': 'Red', 'color': PlayerColor.red, 'isAi': true},
      ],
      boardSize: 7,
    );
  }

  factory GameSettings.default3Player() {
    return GameSettings(
      playerCount: 3,
      players: [
        {'id': 0, 'name': 'Blue', 'color': PlayerColor.blue, 'isAi': false},
        {'id': 1, 'name': 'Red', 'color': PlayerColor.red, 'isAi': true},
        {'id': 2, 'name': 'Yellow', 'color': PlayerColor.yellow, 'isAi': true},
      ],
      boardSize: 9,
    );
  }

  factory GameSettings.default4Player() {
    return GameSettings(
      playerCount: 4,
      players: [
        {'id': 0, 'name': 'Blue', 'color': PlayerColor.blue, 'isAi': false},
        {'id': 1, 'name': 'Red', 'color': PlayerColor.red, 'isAi': true},
        {'id': 2, 'name': 'Yellow', 'color': PlayerColor.yellow, 'isAi': true},
        {'id': 3, 'name': 'Purple', 'color': PlayerColor.purple, 'isAi': true},
      ],
      boardSize: 10,
    );
  }
}
