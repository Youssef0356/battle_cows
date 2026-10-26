import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battle_cows/core/localization/app_localizations.dart';
import 'package:battle_cows/core/localization/locale_controller.dart';
import 'package:battle_cows/core/localization/translations_ar.dart';
import 'package:battle_cows/core/localization/translations_en.dart';
import 'package:battle_cows/core/localization/translations_fr.dart';
import 'package:battle_cows/data/models/shop_item.dart';
import 'package:battle_cows/game/campaign/campaign_data.dart';
import 'package:battle_cows/game/models/challenge_mode.dart';
import 'package:battle_cows/game/tutorial/tutorial_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleController tests', () {
    setUp(() async {
      LocaleController.instance.resetForTesting();
      SharedPreferences.setMockInitialValues({});
      await LocaleController.instance.initialize();
    });

    test('defaults to English locale and reports first launch', () {
      expect(LocaleController.instance.locale.languageCode, 'en');
      expect(LocaleController.instance.isEnglish, isTrue);
      expect(LocaleController.instance.isArabic, isFalse);
      expect(LocaleController.instance.isFrench, isFalse);
      expect(LocaleController.instance.isFirstLaunch, isTrue);
      expect(LocaleController.instance.hasChosenLanguage, isFalse);
    });

    test('switches to French and persists preference', () async {
      await LocaleController.instance.setLocale(const Locale('fr'));
      expect(LocaleController.instance.locale.languageCode, 'fr');
      expect(LocaleController.instance.isFrench, isTrue);
      expect(LocaleController.instance.isEnglish, isFalse);
      expect(LocaleController.instance.isArabic, isFalse);
      expect(LocaleController.instance.isFirstLaunch, isFalse);
      expect(LocaleController.instance.hasChosenLanguage, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_locale'), 'fr');
      expect(prefs.getBool('has_chosen_language'), isTrue);
    });

    test('persists English preference on first launch even if default', () async {
      await LocaleController.instance.setLocale(const Locale('en'));
      expect(LocaleController.instance.locale.languageCode, 'en');
      expect(LocaleController.instance.isFirstLaunch, isFalse);
      expect(LocaleController.instance.hasChosenLanguage, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_locale'), 'en');
      expect(prefs.getBool('has_chosen_language'), isTrue);
    });

    test('switches to Arabic and persists preference', () async {
      await LocaleController.instance.setLocale(const Locale('ar'));
      expect(LocaleController.instance.locale.languageCode, 'ar');
      expect(LocaleController.instance.isArabic, isTrue);
      expect(LocaleController.instance.isEnglish, isFalse);
      expect(LocaleController.instance.isFrench, isFalse);
      expect(LocaleController.instance.isFirstLaunch, isFalse);
      expect(LocaleController.instance.hasChosenLanguage, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_locale'), 'ar');
      expect(prefs.getBool('has_chosen_language'), isTrue);
    });

    test('restores previously chosen language on initialize', () async {
      SharedPreferences.setMockInitialValues({
        'selected_locale': 'fr',
        'has_chosen_language': true,
      });
      await LocaleController.instance.initialize();
      expect(LocaleController.instance.locale.languageCode, 'fr');
      expect(LocaleController.instance.isFirstLaunch, isFalse);
      expect(LocaleController.instance.hasChosenLanguage, isTrue);
    });
  });

  group('AppLocalizations and Translations Completeness', () {
    final en = AppLocalizationsEn();
    final fr = AppLocalizationsFr();
    final ar = AppLocalizationsAr();

    test('supported locales list contains en, fr, and ar', () {
      final codes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(codes, containsAll(['en', 'fr', 'ar']));
    });

    test('French translations are valid, non-empty, and free of placeholder leaks', () {
      expect(fr.barnyardCampaign, 'CAMPAGNE DE LA FERME');
      expect(fr.playVsAi, 'JOUER CONTRE L\'IA');
      expect(fr.localMultiplayer, 'MULTIJOUEUR LOCAL');
      expect(fr.howToPlay, 'COMMENT JOUER');
      expect(fr.challenges, 'DÉFIS');
      expect(fr.settingsTitle, 'PARAMÈTRES');
      expect(fr.shopTitle, 'BOUTIQUE DE L\'ÉTABLE');
      expect(fr.coinsEarned(25), '+25 💰 REMPORTÉES');
      expect(fr.playerWins('Joueur 1'), 'Joueur 1 GAGNE !');
      expect(fr.draw, 'MATCH NUL !');
      expect(fr.easy, 'FACILE');
      expect(fr.medium, 'MOYEN');
      expect(fr.hard, 'DIFFICILE');

      // Verify no untranslated English buttons in key navigation
      expect(fr.cancel, 'ANNULER');
      expect(fr.skip, 'PASSER');
      expect(fr.exit, 'QUITTER');
      expect(fr.chooseLanguage, 'CHOISIR LA LANGUE');
      expect(fr.confirm, 'CONFIRMER');
    });

    test('Arabic translations are valid Arabic script, non-empty, and natural', () {
      expect(ar.barnyardCampaign, 'حملة المزرعة');
      expect(ar.playVsAi, 'ضد الحاسوب');
      expect(ar.localMultiplayer, 'لاعبان محلياً');
      expect(ar.howToPlay, 'طريقة اللعب');
      expect(ar.challenges, 'التحديات');
      expect(ar.settingsTitle, 'الإعدادات');
      expect(ar.shopTitle, 'متجر الحظيرة');
      expect(ar.coinsEarned(25), '+25 💰 تم كسبها');
      expect(ar.playerWins('اللاعب 1'), 'فاز اللاعب 1!');
      expect(ar.draw, 'تعادل!');
      expect(ar.easy, 'سهل');
      expect(ar.medium, 'متوسط');
      expect(ar.hard, 'صعب');
      expect(ar.cancel, 'إلغاء');
      expect(ar.skip, 'تخطي');
      expect(ar.exit, 'خروج');
      expect(ar.chooseLanguage, 'اختر اللغة');
      expect(ar.confirm, 'تأكيد');
    });

    test('Parameterized strings format without errors across all languages', () {
      for (final l10n in [en, fr, ar]) {
        expect(l10n.levelBriefing(3), isNotEmpty);
        expect(l10n.vsOpponent('Bessie'), isNotEmpty);
        expect(l10n.rewardCoinsBadge(100), contains('100'));
        expect(l10n.rewardXpBadge(50), contains('50'));
        expect(l10n.tutorialStepCounter(2, 6), contains('2'));
        expect(l10n.tutorialStepCounter(2, 6), contains('6'));
        expect(l10n.fencesCount(2, 3), contains('2'));
        expect(l10n.fencesCount(2, 3), contains('3'));
        expect(l10n.scoreTiles(8), contains('8'));
      }
    });
  });

  group('Model Localizations extensions', () {
    test('ChallengeMode titles and descriptions localize properly', () {
      final mode = ChallengeMode.timed;
      expect(mode.localizedTitle(), isNotEmpty);
      expect(mode.localizedDescription(), isNotEmpty);
    });

    test('ShopCategory and ShopItem localize properly', () {
      expect(ShopCategory.skins.localizedName(), isNotEmpty);
      expect(ShopCategory.hats.localizedName(), isNotEmpty);
      expect(ShopCategory.themes.localizedName(), isNotEmpty);
      expect(ShopCategory.boards.localizedName(), isNotEmpty);

      final item = shopItems.first;
      expect(item.localizedName(), isNotEmpty);
      expect(item.localizedDescription(), isNotEmpty);
    });

    test('CampaignLevel localizes title, opponent, description, objective', () {
      final level = CampaignData.levels.first;
      expect(level.localizedTitle(), isNotEmpty);
      expect(level.localizedOpponentName(), isNotEmpty);
      expect(level.localizedDescription(), isNotEmpty);
      expect(level.localizedObjective(), isNotEmpty);
    });

    test('TutorialStep localizes titles and descriptions', () {
      final step = TutorialScenario.steps.first;
      expect(step.localizedTitle(0), isNotEmpty);
      expect(step.localizedDescription(0), isNotEmpty);
    });
  });
}
