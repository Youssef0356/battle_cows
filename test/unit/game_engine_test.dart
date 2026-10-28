import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/game/models/hex_position.dart';
import 'package:battle_cows/game/models/pasture_tile.dart';
import 'package:battle_cows/game/models/game_board.dart';
import 'package:battle_cows/game/models/move.dart';
import 'package:battle_cows/game/logic/game_engine.dart';
import 'package:battle_cows/game/board/board_generator.dart';
import 'package:battle_cows/game/models/player.dart';
import 'package:battle_cows/game/models/challenge_mode.dart';
import 'package:battle_cows/game/models/hex_cell.dart';
import 'package:battle_cows/game/models/herd.dart';
import 'package:battle_cows/core/constants/colors.dart';

void main() {
  group('GameEngine', () {
    late GameEngine engine;

    setUp(() {
      engine = GameEngine();
    });

    test('initializes with correct state', () {
      final board = _createTestBoard();
      engine.initializeGame(board, _testPlayers());

      expect(engine.board, isNotNull);
      expect(engine.players.length, 2);
      expect(engine.turnCount, 0);
      expect(engine.gameOver, false);
    });

    test('currentPlayer returns first player initially', () {
      final board = _createTestBoard();
      engine.initializeGame(board, _testPlayers());

      expect(engine.currentPlayer.color, PlayerColor.blue);
    });

    test('getValidMoves returns moves for a player', () {
      final board = _createTestBoard();
      engine.initializeGame(board, _testPlayers());

      final moves = engine.getValidMoves(PlayerColor.blue);
      expect(moves, isNotEmpty);
      expect(moves.every((m) => m.player == PlayerColor.blue), true);
    });

    test('getValidMoves returns empty for player with no herds', () {
      final board = _createTestBoard();
      final players = _testPlayers();
      engine.initializeGame(board, players);

      final herdsWithoutRed = board.herds.where((h) => h.owner != PlayerColor.red).toList();
      final boardWithoutRed = GameBoard(cells: board.cells, herds: herdsWithoutRed);
      engine.initializeGame(boardWithoutRed, players);

      final moves = engine.getValidMoves(PlayerColor.red);
      expect(moves, isEmpty);
    });

    test('executeMove advances turn', () {
      final board = _createTestBoard();
      engine.initializeGame(board, _testPlayers());

      final moves = engine.getValidMoves(PlayerColor.blue);
      if (moves.isNotEmpty) {
        engine.executeMove(moves.first);
        expect(engine.turnCount, 1);
        expect(engine.currentPlayer.color, PlayerColor.red);
      }
    });

    test('executeMove returns false for invalid move', () {
      final board = _createTestBoard();
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
      final board = _createTestBoard();
      engine.initializeGame(board, _testPlayers());

      expect(engine.hasLegalMoves(PlayerColor.blue), true);
    });

    test('getTerritoryCount returns correct counts', () {
      final board = _createTestBoard();
      engine.initializeGame(board, _testPlayers());

      final counts = engine.getTerritoryCount();
      expect(counts[PlayerColor.blue], 1);
      expect(counts[PlayerColor.red], 1);
    });

    test('determineWinner returns null when game not over', () {
      final board = _createTestBoard();
      engine.initializeGame(board, _testPlayers());

      expect(engine.determineWinner(), isNull);
    });

    test('game starts with turnCount 0', () {
      final board = _createTestBoard();
      engine.initializeGame(board, _testPlayers());

      expect(engine.turnCount, 0);
    });

    test('pasture frenzy (stampedeRush) spawns bonus tiles after each player turn', () {
      final board = _createTestBoard();
      engine.initializeGame(
        board,
        _testPlayers(),
        challengeMode: ChallengeMode.stampedeRush,
      );

      final moves = engine.getValidMoves(PlayerColor.blue);
      expect(moves, isNotEmpty);

      // Count specials before move
      final specialsBefore = engine.board!.cells.values
          .where((c) => c.specialType != SpecialTileType.none)
          .length;

      final success = engine.executeMove(moves.first);
      expect(success, true);

      // Verify a tile was spawned
      expect(engine.lastSpawnedPosition, isNotNull);
      expect(engine.lastSpawnedType, isNotNull);
      expect(
        engine.lastSpawnedType == SpecialTileType.hayBale ||
            engine.lastSpawnedType == SpecialTileType.goldenPasture,
        true,
      );

      final spawnedCell = engine.board!.getCell(engine.lastSpawnedPosition!);
      expect(spawnedCell?.specialType, engine.lastSpawnedType);

      // Count specials after move (accounting for if move destination was a special)
      final specialsAfter = engine.board!.cells.values
          .where((c) => c.specialType != SpecialTileType.none)
          .length;
      expect(specialsAfter, greaterThanOrEqualTo(specialsBefore));
    });

    test('standard mode does NOT spawn bonus tiles on turn completion', () {
      final board = _createTestBoard();
      engine.initializeGame(
        board,
        _testPlayers(),
        challengeMode: ChallengeMode.standard,
      );

      final moves = engine.getValidMoves(PlayerColor.blue);
      engine.executeMove(moves.first);

      expect(engine.lastSpawnedPosition, isNull);
      expect(engine.lastSpawnedType, isNull);
    });

    test('hay bale blocks herds: cannot be landed on and stops slide', () {
      final board = _createTestBoard();
      final blueHerd = board.herds.firstWhere((h) => h.owner == PlayerColor.blue);
      final reachable = board.getReachablePositions(blueHerd.position, 5);
      final targetHex = reachable.first;

      final modifiedCells = Map<HexPosition, HexCell>.from(board.cells);
      modifiedCells[targetHex] = modifiedCells[targetHex]!.copyWith(specialType: SpecialTileType.hayBale);
      final modifiedBoard = GameBoard(cells: modifiedCells, herds: board.herds);

      // Hay bale cell is not empty (cannot place herd on it)
      expect(modifiedBoard.isEmpty(targetHex), false);

      // Reachable positions now exclude the hay bale cell
      final newReachable = modifiedBoard.getReachablePositions(blueHerd.position, 5);
      expect(newReachable.contains(targetHex), false);
    });

    test('winner is determined by the player controlling more tiles/territory', () {
      final board = _createTestBoard();
      // Setup a board where blue controls 3 tiles and red controls 1 tile
      final blueHerds = [
        const Herd(position: HexPosition(0, 0), owner: PlayerColor.blue, size: 1),
        const Herd(position: HexPosition(1, 0), owner: PlayerColor.blue, size: 1),
        const Herd(position: HexPosition(0, 1), owner: PlayerColor.blue, size: 1),
      ];
      final redHerds = [
        const Herd(position: HexPosition(-2, 1), owner: PlayerColor.red, size: 1),
      ];
      final gameOverBoard = GameBoard(cells: board.cells, herds: [...blueHerds, ...redHerds]);

      engine.initializeGame(gameOverBoard, _testPlayers(), challengeMode: ChallengeMode.stampedeRush);

      // Verify game is over (no herds can move because all sizes are 1)
      expect(engine.gameOver, true);
      expect(engine.determineWinner(), PlayerColor.blue);
    });

    test('empty board before herd placement does not trigger game over and allows subsequent moves', () {
      final tiles = [
        PastureTile.diamond(0, const HexPosition(0, 0)),
        PastureTile.diamond(1, const HexPosition(2, -1)),
      ];
      final emptyBoard = BoardGenerator.generateEmptyBoard(tiles);
      expect(emptyBoard.herds, isEmpty);

      engine.initializeGame(emptyBoard, _testPlayers());
      expect(engine.gameOver, false);

      // Now place herds as happens in match flow
      emptyBoard.herds.add(const Herd(position: HexPosition(0, 0), owner: PlayerColor.blue, size: 16));
      emptyBoard.herds.add(const Herd(position: HexPosition(2, -1), owner: PlayerColor.red, size: 16));
      engine.checkGameOver();
      expect(engine.gameOver, false);

      // Execute first move
      final blueMoves = engine.getValidMoves(PlayerColor.blue);
      expect(blueMoves, isNotEmpty);
      final moveSuccess = engine.executeMove(blueMoves.first);
      expect(moveSuccess, true);
      expect(engine.gameOver, false);
      expect(engine.turnCount, 1);
    });
  });
}

GameBoard _createTestBoard() {
  final tiles = [
    PastureTile.diamond(0, const HexPosition(0, 0)),
    PastureTile.diamond(1, const HexPosition(2, -1)),
    PastureTile.diamond(2, const HexPosition(-2, 1)),
  ];
  return BoardGenerator.generateFromTiles(tiles, _testPlayers(), 16);
}

List<Player> _testPlayers() {
  return const [
    Player(id: 0, name: 'Blue', color: PlayerColor.blue),
    Player(id: 1, name: 'Red', color: PlayerColor.red),
  ];
}
