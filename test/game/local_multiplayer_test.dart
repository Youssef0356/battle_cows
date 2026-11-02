import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/flame/audio_manager.dart';
import 'package:battle_cows/flame/battle_cows_game.dart';
import 'package:battle_cows/game/models/player.dart';
import 'package:battle_cows/game/models/challenge_mode.dart';
import 'package:battle_cows/core/constants/colors.dart';

void main() {
  group('BattleCowsGame without AI players', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      // The audioplayers plugin is not available in the test environment and
      // FlameAudio.play() reports failures asynchronously, so mute SFX.
      AudioManager().toggleSfx();
    });

    const humanPlayers = [
      Player(id: 0, name: 'Player 1', color: PlayerColor.blue),
      Player(id: 1, name: 'Player 2', color: PlayerColor.red),
    ];

    test('loads a local multiplayer match', () async {
      // Regression: onLoad used to run
      // `players.firstWhere((p) => p.isAi)` without an orElse, which threw
      // "Bad state: No element" as soon as local multiplayer was opened.
      final game = BattleCowsGame(players: humanPlayers);
      game.onGameResize(Vector2(800, 600));
      await game.onLoad();

      expect(game.players.length, 2);
      expect(game.players.any((p) => p.isAi), isFalse);
      expect(game.isPlacementPhase, isTrue);
      expect(game.isGameOver, isFalse);
    });

    test('both humans can build the pasture and place their herds', () async {
      final game = BattleCowsGame(players: humanPlayers, tilesPerPlayer: 1);
      game.onGameResize(Vector2(800, 600));
      await game.onLoad();

      // Tile placement phase: one tile each, no AI should auto-play.
      var guard = 0;
      while (game.isPlacementPhase && guard < 10) {
        expect(game.placeCurrentTile(), isTrue);
        guard++;
      }
      expect(game.isPlacementPhase, isFalse);
      expect(game.isHerdPlacementPhase, isTrue);

      // Herd placement phase: each human taps a highlighted hex.
      expect(game.validHerdPositions, isNotEmpty);
      guard = 0;
      while (game.isHerdPlacementPhase && guard < 10) {
        game.placeHerdAt(game.validHerdPositions.first);
        guard++;
      }
      expect(game.isHerdPlacementPhase, isFalse);

      // Match is live with two human players and two herds on the board.
      expect(game.engine.players.length, 2);
      expect(game.engine.currentPlayer.isAi, isFalse);
      expect(game.engine.board!.herds.length, 2);
    });

    test('loads a local multiplayer challenge match', () async {
      final game = BattleCowsGame(
        players: humanPlayers,
        challengeMode: ChallengeMode.fenceChallenge,
      );
      game.onGameResize(Vector2(800, 600));
      await game.onLoad();

      expect(game.challengeMode, ChallengeMode.fenceChallenge);
      expect(game.getRemainingFences(PlayerColor.blue), 3);
    });

    test('3-player local multiplayer builds pasture and places herds', () async {
      const threePlayers = [
        Player(id: 0, name: 'Player 1', color: PlayerColor.blue),
        Player(id: 1, name: 'Player 2', color: PlayerColor.red),
        Player(id: 2, name: 'Player 3', color: PlayerColor.yellow),
      ];

      final game = BattleCowsGame(players: threePlayers, tilesPerPlayer: 1);
      game.onGameResize(Vector2(800, 600));
      await game.onLoad();

      expect(game.players.length, 3);
      expect(game.isPlacementPhase, isTrue);

      var guard = 0;
      while (game.isPlacementPhase && guard < 10) {
        expect(game.placeCurrentTile(), isTrue);
        guard++;
      }
      expect(game.isPlacementPhase, isFalse);
      expect(game.isHerdPlacementPhase, isTrue);

      guard = 0;
      while (game.isHerdPlacementPhase && guard < 10) {
        expect(game.validHerdPositions, isNotEmpty);
        game.placeHerdAt(game.validHerdPositions.first);
        guard++;
      }
      expect(game.isHerdPlacementPhase, isFalse);
      expect(game.engine.players.length, 3);
      expect(game.engine.board!.herds.length, 3);
      expect(game.engine.board!.herds.map((h) => h.owner).toSet(), {
        PlayerColor.blue,
        PlayerColor.red,
        PlayerColor.yellow,
      });
    });

    test('4-player local multiplayer builds pasture and places herds for all 4 players', () async {
      const fourPlayers = [
        Player(id: 0, name: 'Player 1', color: PlayerColor.blue),
        Player(id: 1, name: 'Player 2', color: PlayerColor.red),
        Player(id: 2, name: 'Player 3', color: PlayerColor.yellow),
        Player(id: 3, name: 'Player 4', color: PlayerColor.purple),
      ];

      final game = BattleCowsGame(players: fourPlayers, tilesPerPlayer: 1);
      game.onGameResize(Vector2(800, 600));
      await game.onLoad();

      expect(game.players.length, 4);
      expect(game.isPlacementPhase, isTrue);

      var guard = 0;
      while (game.isPlacementPhase && guard < 10) {
        expect(game.placeCurrentTile(), isTrue);
        guard++;
      }
      expect(game.isPlacementPhase, isFalse);
      expect(game.isHerdPlacementPhase, isTrue);

      guard = 0;
      while (game.isHerdPlacementPhase && guard < 10) {
        expect(game.validHerdPositions, isNotEmpty);
        game.placeHerdAt(game.validHerdPositions.first);
        guard++;
      }
      expect(game.isHerdPlacementPhase, isFalse);
      expect(game.engine.players.length, 4);
      expect(game.engine.board!.herds.length, 4);
      expect(game.engine.board!.herds.map((h) => h.owner).toSet(), {
        PlayerColor.blue,
        PlayerColor.red,
        PlayerColor.yellow,
        PlayerColor.purple,
      });
    });
  });
}
