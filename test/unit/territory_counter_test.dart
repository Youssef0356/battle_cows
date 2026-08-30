import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/game/models/hex_position.dart';
import 'package:battle_cows/game/models/herd.dart';
import 'package:battle_cows/game/models/game_board.dart';
import 'package:battle_cows/game/logic/territory_counter.dart';
import 'package:battle_cows/game/board/board_generator.dart';
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
      board = BoardGenerator.generate(5, players, 12);
    });

    test('countTerritory counts herds per player', () {
      final counts = TerritoryCounter.countTerritory(board, players);
      expect(counts[PlayerColor.blue], 1);
      expect(counts[PlayerColor.red], 1);
    });

    test('countCows sums herd sizes per player', () {
      final counts = TerritoryCounter.countCows(board, players);
      expect(counts[PlayerColor.blue], 12);
      expect(counts[PlayerColor.red], 12);
    });

    test('getLeader returns player with most territory', () {
      final herds = [
        const Herd(position: HexPosition(-5, 0), owner: PlayerColor.blue, size: 12),
        const Herd(position: HexPosition(5, 0), owner: PlayerColor.red, size: 12),
        const Herd(position: HexPosition(2, 0), owner: PlayerColor.blue, size: 3),
      ];
      final customBoard = GameBoard(size: 5, cells: board.cells, herds: herds);

      final leader = TerritoryCounter.getLeader(customBoard, players);
      expect(leader, PlayerColor.blue);
    });

    test('countTerritory returns zero for player with no herds', () {
      final blueOnly = [
        const Player(id: 0, name: 'Blue', color: PlayerColor.blue),
        const Player(id: 1, name: 'Red', color: PlayerColor.red),
        const Player(id: 2, name: 'Yellow', color: PlayerColor.yellow),
      ];
      final herds = [
        const Herd(position: HexPosition(-5, 0), owner: PlayerColor.blue, size: 5),
      ];
      final customBoard = GameBoard(size: 5, cells: board.cells, herds: herds);

      final counts = TerritoryCounter.countTerritory(customBoard, blueOnly);
      expect(counts[PlayerColor.yellow], 0);
      expect(counts[PlayerColor.blue], 1);
    });

    test('countCows sums correctly with multiple herds', () {
      final herds = [
        const Herd(position: HexPosition(-5, 0), owner: PlayerColor.blue, size: 5),
        const Herd(position: HexPosition(-3, 0), owner: PlayerColor.blue, size: 3),
        const Herd(position: HexPosition(5, 0), owner: PlayerColor.red, size: 8),
      ];
      final customBoard = GameBoard(size: 5, cells: board.cells, herds: herds);

      final counts = TerritoryCounter.countCows(customBoard, players);
      expect(counts[PlayerColor.blue], 8);
      expect(counts[PlayerColor.red], 8);
    });
  });
}
