import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/game/models/hex_position.dart';
import 'package:battle_cows/game/models/herd.dart';
import 'package:battle_cows/game/models/game_board.dart';
import 'package:battle_cows/game/logic/territory_counter.dart';
import 'package:battle_cows/game/board/board_generator.dart';
import 'package:battle_cows/game/models/pasture_tile.dart';
import 'package:battle_cows/core/constants/colors.dart';
import 'package:battle_cows/game/models/player.dart';

void main() {
  group('TerritoryCounter', () {
    late GameBoard board;
    late List<Player> players;

    setUp(() {
      players = const [
        Player(id: 0, name: 'Blue', color: PlayerColor.blue),
        Player(id: 1, name: 'Red', color: PlayerColor.red),
      ];
      board = _createTestBoard();
    });

    test('countTerritory counts herds per player', () {
      final counts = TerritoryCounter.countTerritory(board, players);
      expect(counts[PlayerColor.blue], 1);
      expect(counts[PlayerColor.red], 1);
    });

    test('countCows sums herd sizes per player', () {
      final counts = TerritoryCounter.countCows(board, players);
      expect(counts[PlayerColor.blue], 16);
      expect(counts[PlayerColor.red], 16);
    });

    test('getLeader returns player with most territory', () {
      final herds = [
        const Herd(position: HexPosition(-1, 0), owner: PlayerColor.blue, size: 16),
        const Herd(position: HexPosition(3, -1), owner: PlayerColor.red, size: 16),
        const Herd(position: HexPosition(1, -1), owner: PlayerColor.blue, size: 3),
      ];
      final customBoard = GameBoard(cells: board.cells, herds: herds);

      final leader = TerritoryCounter.getLeader(customBoard, players);
      expect(leader, PlayerColor.blue);
    });

    test('countTerritory returns zero for player with no herds', () {
      final threePlayers = [
        const Player(id: 0, name: 'Blue', color: PlayerColor.blue),
        const Player(id: 1, name: 'Red', color: PlayerColor.red),
        const Player(id: 2, name: 'Yellow', color: PlayerColor.yellow),
      ];
      final herds = [
        const Herd(position: HexPosition(-1, 0), owner: PlayerColor.blue, size: 5),
      ];
      final customBoard = GameBoard(cells: board.cells, herds: herds);

      final counts = TerritoryCounter.countTerritory(customBoard, threePlayers);
      expect(counts[PlayerColor.yellow], 0);
      expect(counts[PlayerColor.blue], 1);
    });

    test('countCows sums correctly with multiple herds', () {
      final herds = [
        const Herd(position: HexPosition(-1, 0), owner: PlayerColor.blue, size: 5),
        const Herd(position: HexPosition(0, -1), owner: PlayerColor.blue, size: 3),
        const Herd(position: HexPosition(3, -1), owner: PlayerColor.red, size: 8),
      ];
      final customBoard = GameBoard(cells: board.cells, herds: herds);

      final counts = TerritoryCounter.countCows(customBoard, players);
      expect(counts[PlayerColor.blue], 8);
      expect(counts[PlayerColor.red], 8);
    });
  });
}

GameBoard _createTestBoard() {
  final tiles = [
    PastureTile.diamond(0, const HexPosition(0, 0)),
    PastureTile.diamond(1, const HexPosition(2, -1)),
    PastureTile.diamond(2, const HexPosition(-2, 1)),
  ];
  final players = const [
    Player(id: 0, name: 'Blue', color: PlayerColor.blue),
    Player(id: 1, name: 'Red', color: PlayerColor.red),
  ];
  return BoardGenerator.generateFromTiles(tiles, players, 16);
}
