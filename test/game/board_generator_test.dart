import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/game/board/board_generator.dart';
import 'package:battle_cows/game/models/player.dart';
import 'package:battle_cows/core/constants/colors.dart';

void main() {
  group('BoardGenerator', () {
    test('generates board with correct size for 2 players', () {
      final players = _twoPlayers();
      final board = BoardGenerator.generate(7, players, 12);

      expect(board.size, 7);
      expect(board.cells, isNotEmpty);
    });

    test('board cells form hexagonal shape', () {
      final players = _twoPlayers();
      final board = BoardGenerator.generate(3, players, 12);

      // All cells should have valid hex coordinates (|q|, |r|, |s| <= size)
      for (final entry in board.cells.entries) {
        final pos = entry.key;
        expect(pos.q.abs() + pos.r.abs() + pos.s.abs(), lessThanOrEqualTo(3 * 2));
      }
    });

    test('places starting herds for all players', () {
      final players = _twoPlayers();
      final board = BoardGenerator.generate(5, players, 12);

      final blueHerds = board.herds.where((h) => h.owner == PlayerColor.blue).toList();
      final redHerds = board.herds.where((h) => h.owner == PlayerColor.red).toList();

      expect(blueHerds.length, 1);
      expect(redHerds.length, 1);
    });

    test('starting herds have correct size', () {
      final players = _twoPlayers();
      final board = BoardGenerator.generate(5, players, 12);

      for (final herd in board.herds) {
        expect(herd.size, 12);
      }
    });

    test('starting positions are on opposite sides', () {
      final players = _twoPlayers();
      final board = BoardGenerator.generate(7, players, 12);

      final blueHerd = board.herds.firstWhere((h) => h.owner == PlayerColor.blue);
      final redHerd = board.herds.firstWhere((h) => h.owner == PlayerColor.red);

      // Blue starts at negative q, Red at positive q
      expect(blueHerd.position.q, lessThan(0));
      expect(redHerd.position.q, greaterThan(0));
    });

    test('generates board with obstacles', () {
      final players = _twoPlayers();
      final board = BoardGenerator.generate(7, players, 12);

      final obstacles = board.cells.values.where((c) => c.isObstacle).toList();
      expect(obstacles, isNotEmpty);
    });

    test('generates 3-player board with 3 starting herds', () {
      final players = _threePlayers();
      final board = BoardGenerator.generate(9, players, 12);

      expect(board.herds.length, 3);
    });

    test('generates 4-player board with 4 starting herds', () {
      final players = _fourPlayers();
      final board = BoardGenerator.generate(10, players, 12);

      expect(board.herds.length, 4);
    });

    test('larger board has more cells than smaller board', () {
      final players = _twoPlayers();
      final smallBoard = BoardGenerator.generate(5, players, 12);
      final largeBoard = BoardGenerator.generate(10, players, 12);

      expect(largeBoard.cells.length, greaterThan(smallBoard.cells.length));
    });
  });
}

List<Player> _twoPlayers() {
  return const [
    Player(id: 0, name: 'Blue', color: PlayerColor.blue),
    Player(id: 1, name: 'Red', color: PlayerColor.red),
  ];
}

List<Player> _threePlayers() {
  return const [
    Player(id: 0, name: 'Blue', color: PlayerColor.blue),
    Player(id: 1, name: 'Red', color: PlayerColor.red),
    Player(id: 2, name: 'Yellow', color: PlayerColor.yellow),
  ];
}

List<Player> _fourPlayers() {
  return const [
    Player(id: 0, name: 'Blue', color: PlayerColor.blue),
    Player(id: 1, name: 'Red', color: PlayerColor.red),
    Player(id: 2, name: 'Yellow', color: PlayerColor.yellow),
    Player(id: 3, name: 'Purple', color: PlayerColor.purple),
  ];
}
