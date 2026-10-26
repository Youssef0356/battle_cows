import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battle_cows/core/localization/app_localizations.dart';
import 'package:battle_cows/core/localization/locale_controller.dart';
import 'package:battle_cows/presentation/dialogs/language_selection_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp({bool isFirstTime = false}) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) {
        return MaterialApp(
          locale: LocaleController.instance.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    LanguageSelectionDialog.show(
                      context: ctx,
                      isFirstTime: isFirstTime,
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocaleController.instance.resetForTesting();
    await LocaleController.instance.initialize();
  });

  testWidgets('renders all language options and confirm button', (tester) async {
    await tester.pumpWidget(buildTestApp(isFirstTime: true));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('English'), findsWidgets);
    expect(find.text('Français'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('CONFIRM'), findsOneWidget);
  });

  testWidgets('selecting French updates app locale and confirms choice', (tester) async {
    await tester.pumpWidget(buildTestApp(isFirstTime: true));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Tap Français card
    await tester.tap(find.text('Français'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Verify locale changed live to French (button label is now CONFIRMER)
    expect(LocaleController.instance.languageCode, 'fr');
    expect(find.text('CONFIRMER'), findsOneWidget);

    // Tap confirm
    await tester.tap(find.text('CONFIRMER'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Dialog should be dismissed
    expect(find.byType(LanguageSelectionDialog), findsNothing);
    expect(LocaleController.instance.hasChosenLanguage, isTrue);
    expect(LocaleController.instance.isFirstLaunch, isFalse);
  });

  testWidgets('selecting Arabic updates app locale and confirms choice', (tester) async {
    await tester.pumpWidget(buildTestApp(isFirstTime: true));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Tap العربية card
    await tester.tap(find.text('العربية'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Verify locale changed live to Arabic (button label is now تأكيد)
    expect(LocaleController.instance.languageCode, 'ar');
    expect(find.text('تأكيد'), findsOneWidget);

    // Tap confirm
    await tester.tap(find.text('تأكيد'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(LanguageSelectionDialog), findsNothing);
    expect(LocaleController.instance.hasChosenLanguage, isTrue);
    expect(LocaleController.instance.isFirstLaunch, isFalse);
  });
}
