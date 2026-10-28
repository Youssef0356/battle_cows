import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders hero elements and loading bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Initial frame
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);

    // Verify presence of tagline and initial loading status
    expect(find.text('ROUND UP  •  RAMPAGE  •  REPEAT'), findsOneWidget);
    expect(find.text('ROUNDING UP THE HERD...'), findsOneWidget);
    expect(find.text('THE ULTIMATE BARNYARD BATTLE'), findsOneWidget);

    // Unmount to trigger clean dispose
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

