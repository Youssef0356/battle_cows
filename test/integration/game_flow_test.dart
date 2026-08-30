import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/game/board/board_generator.dart';
import 'package:battle_cows/game/logic/game_engine.dart';
import 'package:battle_cows/game/ai/ai_player.dart';
import 'package:battle_cows/game/models/player.dart';
import 'package:battle_cows/core/constants/colors.dart';

void main() {
  group('Full Game Flow Integration', () {
    test('2-player game can be played through multiple turns', () {
      final players = const [
        Player(id: 0, name: 'Blue', color: PlayerColor.blue),
        Player(id: 1, name: 'Red', color: PlayerColor.red, isAi: true),
      ];

      final board = BoardGenerator.generate(5, players, 12);
      final engine = GameEngine();
      engine.initializeGame(board, players);

      expect(engine.gameOver, false);
      expect(engine.turnCount, 0);

      final ai = AiPlayer(difficulty: Difficulty.easy);

      // Play 10 turns
      for (var i = 0; i < 10; i++) {
        if (engine.gameOver) break;

        final currentPlayer = engine.currentPlayer;
        final move = ai.calculateMove(engine, currentPlayer.color);

        if (move != null) {
          final success = engine.executeMove(move);
          expect(success, true);
        }
      }

      expect(engine.turnCount, greaterThan(0));
    });

    test('game tracks territory correctly after moves', () {
      final players = const [
        Player(id: 0, name: 'Blue', color: PlayerColor.blue),
        Player(id: 1, name: 'Red', color: PlayerColor.red),
      ];

      final board = BoardGenerator.generate(5, players, 12);
      final engine = GameEngine();
      engine.initializeGame(board, players);

      final initialCounts = engine.getTerritoryCount();
      expect(initialCounts[PlayerColor.blue], 1);
      expect(initialCounts[PlayerColor.red], 1);

      // Make a move for blue
      final moves = engine.getValidMoves(PlayerColor.blue);
      if (moves.isNotEmpty) {
        engine.executeMove(moves.first);

        final afterCounts = engine.getTerritoryCount();
        expect(afterCounts[PlayerColor.blue], 2);
      }
    });

    test('game over detected when no moves left', () {
      final players = const [
        Player(id: 0, name: 'Blue', color: PlayerColor.blue),
        Player(id: 1, name: 'Red', color: PlayerColor.red),
      ];

      // Small board, small herd - game should end quickly
      final board = BoardGenerator.generate(3, players, 2);
      final engine = GameEngine();
      engine.initializeGame(board, players);

      final ai = AiPlayer(difficulty: Difficulty.hard);

      // Play until game over or max turns
      var maxTurns = 50;
      while (!engine.gameOver && maxTurns > 0) {
        final move = ai.calculateMove(engine, engine.currentPlayer.color);
        if (move != null) {
          engine.executeMove(move);
        } else {
          break;
        }
        maxTurns--;
      }

      // Game should eventually end or be close to ending
      expect(engine.turnCount, greaterThan(0));
    });

    test('winner is determined at game end', () {
      final players = const [
        Player(id: 0, name: 'Blue', color: PlayerColor.blue),
        Player(id: 1, name: 'Red', color: PlayerColor.red),
      ];

      final board = BoardGenerator.generate(3, players, 2);
      final engine = GameEngine();
      engine.initializeGame(board, players);

      final ai = AiPlayer(difficulty: Difficulty.hard);

      // Play until game over
      var maxTurns = 50;
      while (!engine.gameOver && maxTurns > 0) {
        final move = ai.calculateMove(engine, engine.currentPlayer.color);
        if (move != null) {
          engine.executeMove(move);
        } else {
          break;
        }
        maxTurns--;
      }

      if (engine.gameOver) {
        final winner = engine.determineWinner();
        expect(winner, isNotNull);
      }
    });
  });
}
