import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/game/ai/ai_player.dart';
import 'package:battle_cows/game/logic/game_engine.dart';
import 'package:battle_cows/game/board/board_generator.dart';
import 'package:battle_cows/game/models/hex_position.dart';
import 'package:battle_cows/game/models/pasture_tile.dart';
import 'package:battle_cows/game/models/player.dart';
import 'package:battle_cows/core/constants/colors.dart';

void main() {
  group('AiPlayer', () {
    late GameEngine engine;

    setUp(() {
      final players = const [
        Player(id: 0, name: 'Blue', color: PlayerColor.blue),
        Player(id: 1, name: 'Red', color: PlayerColor.red, isAi: true),
      ];
      final tiles = [
        PastureTile.diamond(0, const HexPosition(0, 0)),
        PastureTile.diamond(1, const HexPosition(2, -1)),
        PastureTile.diamond(2, const HexPosition(-2, 1)),
      ];
      final board = BoardGenerator.generateFromTiles(tiles, players, 16);
      engine = GameEngine();
      engine.initializeGame(board, players);
    });

    test('easy AI returns a valid move', () {
      final ai = AiPlayer(difficulty: Difficulty.easy);
      final move = ai.calculateMove(engine, PlayerColor.red);

      if (engine.hasLegalMoves(PlayerColor.red)) {
        expect(move, isNotNull);
        expect(move!.player, PlayerColor.red);
      }
    });

    test('medium AI returns a valid move', () {
      final ai = AiPlayer(difficulty: Difficulty.medium);
      final move = ai.calculateMove(engine, PlayerColor.red);

      if (engine.hasLegalMoves(PlayerColor.red)) {
        expect(move, isNotNull);
        expect(move!.player, PlayerColor.red);
      }
    });

    test('hard AI returns a valid move', () {
      final ai = AiPlayer(difficulty: Difficulty.hard);
      final move = ai.calculateMove(engine, PlayerColor.red);

      if (engine.hasLegalMoves(PlayerColor.red)) {
        expect(move, isNotNull);
        expect(move!.player, PlayerColor.red);
      }
    });

    test('AI move splits stack (splitCount < total)', () {
      final ai = AiPlayer(difficulty: Difficulty.medium);
      final move = ai.calculateMove(engine, PlayerColor.red);

      if (move != null) {
        expect(move.splitCount, greaterThan(0));
        expect(move.splitCount, lessThan(16));
      }
    });

    test('AI move has valid stayCount', () {
      final ai = AiPlayer(difficulty: Difficulty.medium);
      final move = ai.calculateMove(engine, PlayerColor.red);

      if (move != null) {
        expect(move.stayCount, greaterThan(0));
      }
    });

    test('AI returns null when no moves available', () {
      final ai = AiPlayer(difficulty: Difficulty.easy);
      final move = ai.calculateMove(engine, PlayerColor.red);

      if (engine.hasLegalMoves(PlayerColor.red)) {
        expect(move, isNotNull);
      } else {
        expect(move, isNull);
      }
    });
  });
}
