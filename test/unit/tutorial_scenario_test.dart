import 'package:battle_cows/game/tutorial/tutorial_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TutorialScenario', () {
    test('uses a small board and easy 2-player setup', () {
      expect(TutorialScenario.playerCount, 2);
      expect(TutorialScenario.herdSize, 16);
      expect(TutorialScenario.tilesPerPlayer, 3);
      expect(TutorialScenario.boardSize, 7);
    });

    test('walks the player through placement, moves and claiming to win', () {
      final steps = TutorialScenario.steps;
      expect(steps, hasLength(6));

      // Intro card explains the win condition and is blocking.
      expect(steps.first.blocking, isTrue);
      expect(steps.first.advanceOn, isNull);
      expect(
        steps.first.description.toLowerCase(),
        contains('biggest herd'),
      );

      // Action steps auto-advance on real game events, in play order. Both
      // gameplay steps consume the player's next move (the engine only allows
      // moves onto empty hexes, so there is no "capture" event).
      expect(
        steps.map((s) => s.advanceOn).toList(),
        [
          null,
          TutorialEvent.tilePlacementDone,
          TutorialEvent.herdPlacementDone,
          TutorialEvent.playerMove,
          TutorialEvent.playerMove,
          null,
        ],
      );

      // Outro card sends the player back into the match.
      expect(steps.last.blocking, isTrue);
      expect(steps.last.advanceOn, isNull);
    });

    test('every step has a title and description', () {
      for (final step in TutorialScenario.steps) {
        expect(step.title, isNotEmpty);
        expect(step.description, isNotEmpty);
      }
    });
  });
}
