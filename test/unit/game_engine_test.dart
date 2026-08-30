import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/game/models/hex_position.dart';
import 'package:battle_cows/game/models/herd.dart';
import 'package:battle_cows/game/models/game_board.dart';
import 'package:battle_cows/game/models/move.dart';
import 'package:battle_cows/game/logic/game_engine.dart';
import 'package:battle_cows/game/board/board_generator.dart';
import 'package:battle_cows/game/models/player.dart';
import 'package:battle_cows/core/constants/colors.dart';

void main() {
  group('GameEngine', () {
    late GameEngine engine;

    setUp(() {
      engine = GameEngine();
    });

    test('initializes with correct state', () {
      final board = BoardGenerator.generate(5, _testPlayers(), 12);
      engine.initializeGame(board, _testPlayers());

      expect(engine.board, isNotNull);
      expect(engine.players.length, 2);
      expect(engine.turnCount, 0);
      expect(engine.gameOver, false);
    });

    test('currentPlayer returns first player initially', () {
      final board = BoardGenerator.generate(5, _testPlayers(), 12);
      engine.initializeGame(board, _testPlayers());

      expect(engine.currentPlayer.color, PlayerColor.blue);
    });

    test('getValidMoves returns moves for a player', () {
      final board = BoardGenerator.generate(5, _testPlayers(), 12);
      engine.initializeGame(board, _testPlayers());

      final moves = engine.getValidMoves(PlayerColor.blue);
      expect(moves, isNotEmpty);
      expect(moves.every((m) => m.player == PlayerColor.blue), true);
    });

    test('getValidMoves returns empty for player with no herds', () {
      final players = [
        const Player(id: 0, name: 'Blue', color: PlayerColor.blue),
        const Player(id: 1, name: 'Red', color: PlayerColor.red),
      ];
      final board = BoardGenerator.generate(5, players, 12);
      engine.initializeGame(board, players);

      final blueOnly = board.herds.where((h) => h.owner == PlayerColor.blue).toList();
      final modifiedBoard = GameBoard(size: 5, cells: board.cells, herds: blueOnly);
      engine.initializeGame(modifiedBoard, players);

      final moves = engine.getValidMoves(PlayerColor.red);
      expect(moves, isEmpty);
    });

    test('executeMove advances turn', () {
      final board = BoardGenerator.generate(5, _testPlayers(), 12);
      engine.initializeGame(board, _testPlayers());

      final moves = engine.getValidMoves(PlayerColor.blue);
      if (moves.isNotEmpty) {
        engine.executeMove(moves.first);
        expect(engine.turnCount, 1);
        expect(engine.currentPlayer.color, PlayerColor.red);
      }
    });

    test('executeMove returns false for invalid move', () {
      final board = BoardGenerator.generate(5, _testPlayers(), 12);
      engine.initializeGame(board, _testPlayers());

      final invalidMove = Move(
        from: const HexPosition(99, 99),
        to: const HexPosition(0, 0),
        splitCount: 1,
        stayCount: 1,
        player: PlayerColor.blue,
      );

      final result = engine.executeMove(invalidMove);
      expect(result, false);
      expect(engine.turnCount, 0);
    });

    test('hasLegalMoves returns true when player can move', () {
      final board = BoardGenerator.generate(5, _testPlayers(), 12);
      engine.initializeGame(board, _testPlayers());

      expect(engine.hasLegalMoves(PlayerColor.blue), true);
    });

    test('getTerritoryCount returns correct counts', () {
      final board = BoardGenerator.generate(5, _testPlayers(), 12);
      engine.initializeGame(board, _testPlayers());

      final counts = engine.getTerritoryCount();
      expect(counts[PlayerColor.blue], 1);
      expect(counts[PlayerColor.red], 1);
    });

    test('determineWinner returns null when game not over', () {
      final board = BoardGenerator.generate(5, _testPlayers(), 12);
      engine.initializeGame(board, _testPlayers());

      expect(engine.determineWinner(), isNull);
    });

    test('game starts with turnCount 0', () {
      final board = BoardGenerator.generate(5, _testPlayers(), 12);
      engine.initializeGame(board, _testPlayers());

      expect(engine.turnCount, 0);
    });
  });
}

List<Player> _testPlayers() {
  return const [
    Player(id: 0, name: 'Blue', color: PlayerColor.blue),
    Player(id: 1, name: 'Red', color: PlayerColor.red),
  ];
}
