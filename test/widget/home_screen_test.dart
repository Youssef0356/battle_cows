import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battle_cows/core/localization/app_localizations.dart';
import 'package:battle_cows/core/localization/locale_controller.dart';
import 'package:battle_cows/data/services/progress_service.dart';
import 'package:battle_cows/presentation/screens/home_screen.dart';

void main() {
  group('HomeScreen Responsiveness & Layout', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({
        'tutorial_completed': true,
        'first_launch_done': true,
      });
      ProgressService.resetInstance();
      LocaleController.instance.resetForTesting();
      await ProgressService.getInstance();
    });

    Future<void> pumpHomeScreen(
      WidgetTester tester, {
      required Size surfaceSize,
    }) async {
      tester.view.physicalSize = surfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders all texts and buttons cleanly on phone (390 x 844)',
        (WidgetTester tester) async {
      await pumpHomeScreen(tester, surfaceSize: const Size(390, 844));

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('BARNYARD CAMPAIGN'), findsOneWidget);
      expect(find.text('PLAY VS AI'), findsOneWidget);
      expect(find.text('LOCAL\nMULTIPLAYER'), findsOneWidget);
      expect(find.text('CHALLENGES'), findsOneWidget);
      expect(find.text('HOW TO PLAY'), findsOneWidget);
      expect(find.text('DAILY QUESTS'), findsOneWidget);
      expect(find.text('SHOP'), findsOneWidget);
      expect(find.text('NO ADS'), findsOneWidget);
      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('PLAYER 1'), findsOneWidget);
    });

    testWidgets('renders cleanly on small phone (320 x 568) without overflow',
        (WidgetTester tester) async {
      await pumpHomeScreen(tester, surfaceSize: const Size(320, 568));

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('BARNYARD CAMPAIGN'), findsOneWidget);
      expect(find.text('HOW TO PLAY'), findsOneWidget);
    });

    testWidgets('renders cleanly on tablet portrait (768 x 1024) without overflow',
        (WidgetTester tester) async {
      await pumpHomeScreen(tester, surfaceSize: const Size(768, 1024));

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('BARNYARD CAMPAIGN'), findsOneWidget);
      expect(find.text('HOW TO PLAY'), findsOneWidget);
    });

    testWidgets('renders cleanly on tablet landscape (1024 x 768) without overflow',
        (WidgetTester tester) async {
      await pumpHomeScreen(tester, surfaceSize: const Size(1024, 768));

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('BARNYARD CAMPAIGN'), findsOneWidget);
      expect(find.text('HOW TO PLAY'), findsOneWidget);
    });

    testWidgets('renders cleanly on 16:10 tablet portrait (800 x 1280) without overflow',
        (WidgetTester tester) async {
      await pumpHomeScreen(tester, surfaceSize: const Size(800, 1280));

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('BARNYARD CAMPAIGN'), findsOneWidget);
      expect(find.text('HOW TO PLAY'), findsOneWidget);
    });

    testWidgets('renders cleanly on 16:10 tablet landscape (1280 x 800) without overflow',
        (WidgetTester tester) async {
      await pumpHomeScreen(tester, surfaceSize: const Size(1280, 800));

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('BARNYARD CAMPAIGN'), findsOneWidget);
      expect(find.text('HOW TO PLAY'), findsOneWidget);
    });
  });
}
