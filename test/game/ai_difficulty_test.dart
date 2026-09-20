import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/flame/battle_cows_game.dart';
import 'package:battle_cows/game/ai/ai_player.dart';
import 'package:battle_cows/game/models/player.dart';
import 'package:battle_cows/core/constants/colors.dart';

void main() {
  group('BattleCowsGame.resolveAiDifficulty', () {
    test('uses the AI player difficulty when an AI is present', () {
      const players = [
        Player(id: 0, name: 'Player 1', color: PlayerColor.blue),
        Player(
          id: 1,
          name: 'AI Cow 1',
          color: PlayerColor.red,
          isAi: true,
          difficulty: Difficulty.hard,
        ),
      ];

      expect(BattleCowsGame.resolveAiDifficulty(players), Difficulty.hard);
    });

    test('defaults to medium when the AI has no difficulty set', () {
      const players = [
        Player(id: 0, name: 'Player 1', color: PlayerColor.blue),
        Player(id: 1, name: 'AI Cow 1', color: PlayerColor.red, isAi: true),
      ];

      expect(BattleCowsGame.resolveAiDifficulty(players), Difficulty.medium);
    });

    test('falls back to medium for local multiplayer (no AI players)', () {
      // Regression: this used to be `players.firstWhere((p) => p.isAi)`
      // which threw "Bad state: No element" when starting local multiplayer.
      const players = [
        Player(id: 0, name: 'Player 1', color: PlayerColor.blue),
        Player(id: 1, name: 'Player 2', color: PlayerColor.red),
      ];

      expect(BattleCowsGame.resolveAiDifficulty(players), Difficulty.medium);
    });

    test('falls back to medium for an empty player list', () {
      expect(BattleCowsGame.resolveAiDifficulty(const []), Difficulty.medium);
    });
  });
}