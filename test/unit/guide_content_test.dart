import 'package:battle_cows/game/models/challenge_mode.dart';
import 'package:battle_cows/game/tutorial/guide_content.dart';
import 'package:battle_cows/presentation/widgets/guide_diagrams.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GuideContent', () {
    test('has three gameplay sections plus the MODES tab', () {
      expect(GuideContent.sections, hasLength(3));
      expect(
        GuideContent.tabLabels,
        ['SETUP', 'MOVES', 'BATTLE', 'MODES'],
      );
    });

    test('steps are numbered 1..9 across the sections', () {
      final numbers = [
        for (final section in GuideContent.sections)
          ...section.steps.map((step) => step.number),
      ];
      expect(numbers, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    test('every step, tip and mode rule has non-empty text', () {
      for (final section in GuideContent.sections) {
        expect(section.id, isNotEmpty);
        expect(section.tabLabel, isNotEmpty);
        expect(section.headline, isNotEmpty);
        for (final step in section.steps) {
          expect(step.title, isNotEmpty);
          expect(step.body, isNotEmpty);
        }
        for (final tip in section.tips) {
          expect(tip, isNotEmpty);
        }
      }
      for (final mode in GuideContent.modes) {
        expect(mode.startPath, isNotEmpty);
        expect(mode.rules, isNotEmpty);
        expect(mode.tips, isNotEmpty);
      }
    });

    test('describes every ChallengeMode exactly once', () {
      expect(GuideContent.modes, hasLength(ChallengeMode.values.length));
      expect(GuideContent.modesHeadline, isNotEmpty);
    });
  });

  group('GuideDiagrams', () {
    test('every guide step renders a diagram', () {
      for (var number = 1; number <= 9; number++) {
        expect(GuideDiagrams.forStep(number), isA<Object>());
      }
      expect(GuideDiagrams.fencePlacement, isA<Object>());
    });
  });
}