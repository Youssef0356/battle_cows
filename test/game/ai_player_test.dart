import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/game/ai/ai_player.dart';
import 'package:battle_cows/game/logic/game_engine.dart';
import 'package:battle_cows/game/board/board_generator.dart';
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
      final board = BoardGenerator.generate(7, players, 12);
      engine = GameEngine();
      engine.initializeGame(board, players);
    });

    test('easy AI returns a valid move', () {
      final ai = AiPlayer(difficulty: Difficulty.easy);
      final move = ai.calculateMove(engine, PlayerColor.red);

      expect(move, isNotNull);
      expect(move!.player, PlayerColor.red);
    });

    test('medium AI returns a valid move', () {
      final ai = AiPlayer(difficulty: Difficulty.medium);
      final move = ai.calculateMove(engine, PlayerColor.red);

      expect(move, isNotNull);
      expect(move!.player, PlayerColor.red);
    });

    test('hard AI returns a valid move', () {
      final ai = AiPlayer(difficulty: Difficulty.hard);
      final move = ai.calculateMove(engine, PlayerColor.red);

      expect(move, isNotNull);
      expect(move!.player, PlayerColor.red);
    });

    test('AI move splits stack (splitCount < total)', () {
      final ai = AiPlayer(difficulty: Difficulty.medium);
      final move = ai.calculateMove(engine, PlayerColor.red);

      expect(move, isNotNull);
      expect(move!.splitCount, greaterThan(0));
      expect(move.splitCount, lessThan(12));
    });

    test('AI move has valid stayCount', () {
      final ai = AiPlayer(difficulty: Difficulty.medium);
      final move = ai.calculateMove(engine, PlayerColor.red);

      expect(move, isNotNull);
      expect(move!.stayCount, greaterThan(0));
    });

    test('AI returns null when no moves available', () {
      final players = const [
        Player(id: 0, name: 'Blue', color: PlayerColor.blue),
        Player(id: 1, name: 'Red', color: PlayerColor.red),
      ];
      final board = BoardGenerator.generate(3, players, 1);

      final testEngine = GameEngine();
      testEngine.initializeGame(board, players);

      final ai = AiPlayer(difficulty: Difficulty.easy);
      final move = ai.calculateMove(testEngine, PlayerColor.red);

      // With a small board and herd of 1, red should still have moves
      // If no moves, AI should return null
      if (testEngine.hasLegalMoves(PlayerColor.red)) {
        expect(move, isNotNull);
      } else {
        expect(move, isNull);
      }
    });
  });
}
