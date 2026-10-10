import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/game/tutorial/tutorial_data.dart';
import 'package:battle_cows/presentation/overlays/tutorial_overlay.dart';

void main() {
  group('TutorialOverlay', () {
    int nextCalls = 0;
    int completeCalls = 0;
    int skipCalls = 0;

    setUp(() {
      nextCalls = 0;
      completeCalls = 0;
      skipCalls = 0;
    });

    Future<void> pumpOverlay(WidgetTester tester, {int currentStep = 0}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                TutorialOverlay(
                  steps: TutorialScenario.steps,
                  currentStep: currentStep,
                  onNext: () => nextCalls++,
                  onComplete: () => completeCalls++,
                  onSkip: () => skipCalls++,
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('intro card is blocking and START advances one step',
        (tester) async {
      await pumpOverlay(tester);

      expect(find.text('WELCOME, COWPUNCHER!'), findsOneWidget);
      expect(find.text('START!'), findsOneWidget);
      expect(find.text('SKIP'), findsOneWidget);

      await tester.tap(find.text('START!'));
      expect(nextCalls, 1);
      expect(completeCalls, 0);
    });

    testWidgets('SKIP is tappable on the blocking intro card', (tester) async {
      await pumpOverlay(tester);

      // The dim scrim must not absorb the SKIP button's taps.
      await tester.tap(find.text('SKIP'));
      expect(skipCalls, 1);
      expect(nextCalls, 0);
      expect(completeCalls, 0);
    });

    testWidgets('action steps show a coach banner with the step title',
        (tester) async {
      await pumpOverlay(tester, currentStep: 3);

      expect(find.text('SELECT & MOVE'), findsOneWidget);
      expect(find.text('DONE ›'), findsOneWidget);
      expect(find.text('TUTORIAL · 4 / 6'), findsOneWidget);
    });

    testWidgets('coach banner tap advances the step', (tester) async {
      await pumpOverlay(tester, currentStep: 1);

      await tester.tap(find.text('BUILD THE PASTURE'));
      expect(nextCalls, 1);
      expect(completeCalls, 0);
    });

    testWidgets('last step button completes the tutorial', (tester) async {
      await pumpOverlay(tester, currentStep: TutorialScenario.steps.length - 1);

      expect(find.text("YOU'RE READY!"), findsOneWidget);
      expect(find.text("LET'S PLAY!"), findsOneWidget);

      await tester.tap(find.text("LET'S PLAY!"));
      expect(completeCalls, 1);
      expect(nextCalls, 0);
    });

    testWidgets('SKIP completes the tutorial from any step', (tester) async {
      await pumpOverlay(tester, currentStep: 2);

      await tester.tap(find.text('SKIP'));
      expect(skipCalls, 1);
    });
  });
}
