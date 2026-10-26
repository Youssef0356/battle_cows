import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'locale_controller.dart';
import 'translations_en.dart';
import 'translations_fr.dart';
import 'translations_ar.dart';

abstract class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return instance ?? current;
  }

  static AppLocalizations get current {
    switch (LocaleController.instance.languageCode) {
      case 'fr':
        return AppLocalizationsFr();
      case 'ar':
        return AppLocalizationsAr();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  // --- Common ---
  String get cancel;
  String get exit;
  String get start;
  String get close;
  String get gotIt;
  String get ready;
  String get wait;
  String get share;
  String get rate;
  String get menu;
  String get rematch;
  String get draw;
  String playerWins(String name);
  String get shareMessage;

  // --- Home Screen ---
  String get gameTitle;
  String get barnyardCampaign;
  String get playVsAi;
  String get localMultiplayer;
  String get howToPlay;
  String get challenges;
  String get tutorialBtn;
  String get settingsBtn;
  String get shopBtn;
  String get noAdsBtn;
  String get exitGameTitle;
  String get exitGameConfirm;
  String get chooseYourChallenge;
  String get cpuDifficulty;
  String get easy;
  String get medium;
  String get hard;
  String get gameMode;
  String get pastureTilesPerPlayer;
  String get pastureTilesSubtitle;
  String get fastTiles;
  String get balancedTiles;
  String get epicTiles;
  String get dailyQuests;
  String questsReady(int count);
  String get playMore;
  String defaultPlayerName(int index);
  String aiPlayerName(int index);
  String get tutorialCowName;

  // --- Settings Screen ---
  String get settingsTitle;
  String get audioSection;
  String get soundEffects;
  String get music;
  String get hapticFeedback;
  String get gameSection;
  String get accountSection;
  String get statLevel;
  String get statCoins;
  String get statMatches;
  String get statWins;
  String get statStreak;
  String get premiumSection;
  String get premiumActive;
  String get removeAds;
  String get supportSection;
  String get languageSection;
  String get chooseLanguage;
  String get chooseLanguageSubtitle;
  String get languageEnglish;
  String get languageFrench;
  String get languageArabic;
  String get confirm;

  // --- Challenge Modes ---
  String get modeStandardTitle;
  String get modeStandardDesc;
  String get modeTimedTitle;
  String get modeTimedDesc;
  String get modeFenceTitle;
  String get modeFenceDesc;
  String get modeGoldenTitle;
  String get modeGoldenDesc;
  String get modeStampedeTitle;
  String get modeStampedeDesc;

  // --- Quests ---
  String get dailyQuestsTitle;
  String get dailyQuestsSubtitle;
  String tacticsReady(int ready, int total);
  String get today;
  String get questVictoryLapTitle;
  String get questVictoryLapDesc;
  String get questGetMovingTitle;
  String get questGetMovingDesc;
  String get questBusyDayTitle;
  String get questBusyDayDesc;
  String get questLandGrabTitle;
  String get questLandGrabDesc;
  String get questConquestTitle;
  String get questConquestDesc;
  String get questQuickHoovesTitle;
  String get questQuickHoovesDesc;
  String get questWarmUpTitle;
  String get questWarmUpDesc;
  String get questHerdBuilderTitle;
  String get questHerdBuilderDesc;
  String get questOnARollTitle;
  String get questOnARollDesc;

  // --- Shop ---
  String get shopTitle;
  String get removeAdsGoPremium;
  String get equippedCheck;
  String get tapToUse;
  String itemPurchasedAndEquipped(String name);
  String get cannotPurchase;
  String itemUnequipped(String name);
  String itemEquipped(String name);
  String get categorySkins;
  String get categoryHats;
  String get categoryThemes;
  String get categoryEmojis;
  String get categoryBoards;
  String get shopItemCowboyName;
  String get shopItemCowboyDesc;
  String get shopItemVikingName;
  String get shopItemVikingDesc;
  String get shopItemFarmerName;
  String get shopItemFarmerDesc;
  String get shopItemDiscoName;
  String get shopItemDiscoDesc;
  String get shopItemHatCowboyName;
  String get shopItemHatCowboyDesc;
  String get shopItemHatCrownName;
  String get shopItemHatCrownDesc;
  String get shopItemHatPartyName;
  String get shopItemHatPartyDesc;
  String get shopItemHatSuperheroName;
  String get shopItemHatSuperheroDesc;
  String get shopItemThemeValleyName;
  String get shopItemThemeValleyDesc;
  String get shopItemThemeFieldName;
  String get shopItemThemeFieldDesc;
  String get shopItemThemeWoodName;
  String get shopItemThemeWoodDesc;
  String get shopItemEmojiFireName;
  String get shopItemEmojiFireDesc;
  String get shopItemEmojiLightningName;
  String get shopItemEmojiLightningDesc;
  String get shopItemEmojiStarName;
  String get shopItemEmojiStarDesc;
  String get shopItemBoardWoodTilesName;
  String get shopItemBoardWoodTilesDesc;
  String get shopItemBoardMeadowTilesName;
  String get shopItemBoardMeadowTilesDesc;
  String get shopItemBoardFlowerGrassName;
  String get shopItemBoardFlowerGrassDesc;
  String get shopItemThemeSunsetName;
  String get shopItemThemeSunsetDesc;
  String get shopItemThemeNightName;
  String get shopItemThemeNightDesc;
  String get shopItemThemeSnowName;
  String get shopItemThemeSnowDesc;
  String get shopItemBoardWoodName;
  String get shopItemBoardWoodDesc;
  String get shopItemBoardStoneName;
  String get shopItemBoardStoneDesc;
  String get shopItemBoardGoldName;
  String get shopItemBoardGoldDesc;
  String get shopItemBoardDarkName;
  String get shopItemBoardDarkDesc;

  // --- Premium Dialog ---
  String get goPremiumTitle;
  String get removeAllAds;
  String get benefitNoBanner;
  String get benefitNoFullscreen;
  String get benefitForever;
  String buyWithPrice(String price);
  String get unlock;
  String get restorePurchases;
  String get notNow;
  String get premiumActiveThanks;
  String get purchasesRestored;
  String get noPurchaseFound;
  String purchaseFailed(String error);
  String restoreFailed(String error);
  String get storeUnavailable;

  // --- In-Game Overlays & Controls ---
  String get gamePaused;
  String get restartMatch;
  String get resetBoard;
  String get exitToMainMenu;
  String get tableBackground;
  String get defaultTheme;
  String get buyThemesInShop;
  String get buildThePasture;
  String get rotate;
  String get place;
  String get placeHerd;
  String tapHighlightedHexToPlace(String name);
  String splitHerdTotal(int total);
  String get deselect;
  String stayCount(int count);
  String moveCount(int count);
  String get quickOneCow;
  String get quickHalf;
  String quickMax(int max);
  String get tapHerdPrompt;
  String fencesCount(int current, int max);
  String get placeFence;
  String get relocateFence;
  String get tapEmptyToDrop;
  String get tapEmptyToPlace;
  String get tapFenceToMove;
  String get blockEnemyPaths;
  String get use;
  String get playerTurn;
  String get cpuTurn;
  String get finalTerritory;
  String get gameStats;
  String get statTurns;
  String get statYourCows;
  String get statCpuCows;
  String get statYourCaptures;
  String get statCpuCaptures;
  String coinsEarned(int coins);
  String get enjoyingTheGame;
  String get rateUsPrompt;
  String get rateUs;
  String get maybeLater;
  String toastStampede(int count);
  String toastMoovelous(int count);
  String toastPastureRaid(int count);

  // --- Tutorial ---
  String tutorialStepCounter(int step, int total);
  String get skip;
  String get startExclamation;
  String get doneBtn;
  String get letsPlay;
  String get tutScenarioStep4Title;
  String get tutScenarioStep4Desc;
  String get tutScenarioStep5Title;
  String get tutScenarioStep5Desc;
  String get tutScenarioStep6Title;
  String get tutScenarioStep6Desc;
  String get tutStep1Title;
  String get tutStep1Desc;
  String get tutStep2Title;
  String get tutStep2Desc;
  String get tutStep3Title;
  String get tutStep3Desc;
  String get tutStep4Title;
  String get tutStep4Desc;
  String get tutStep5Title;
  String get tutStep5Desc;
  String get tutStep6Title;
  String get tutStep6Desc;
  String get tutStep7Title;
  String get tutStep7Desc;

  // --- How to Play Guide ---
  String get guideSetupTab;
  String get guideMovesTab;
  String get guideBattleTab;
  String get guideModesTab;
  String get guideSetupHeadline;
  String get guideMovesHeadline;
  String get guideBattleHeadline;
  String get guideModesHeadline;
  String get guideStep1Title;
  String get guideStep1Body;
  String get guideStep2Title;
  String get guideStep2Body;
  String get guideStep3Title;
  String get guideStep3Body;
  String get guideStep4Title;
  String get guideStep4Body;
  String get guideStep5Title;
  String get guideStep5Body;
  String get guideStep6Title;
  String get guideStep6Body;
  String get guideStep7Title;
  String get guideStep7Body;
  String get guideStep8Title;
  String get guideStep8Body;
  String get guideStep9Title;
  String get guideStep9Body;
  String get guideTip1;
  String get guideTip2;
  String get guideTip3;
  String get guideTip4;
  String get guideTip5;
  String get guideTip6;
  String get guideTip7;
  String get guideTip8;
  String get guideTip9;

  // --- Campaign ---
  String get barnyardConquest;
  String get campaignPuzzlesBattles;
  String levelBriefing(int level);
  String vsOpponent(String name);
  String rewardCoinsBadge(int coins);
  String rewardXpBadge(int xp);
  String get startBattle;
  String campaignLevelTitle(int id);
  String campaignLevelSubtitle(int id);
  String campaignLevelOpponent(int id);
  String campaignLevelDescription(int id);
  String campaignLevelObjective(int id);

  // --- Results ---
  String get finalScores;
  String scoreTiles(int count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return SynchronousFuture<AppLocalizations>(AppLocalizationsFr());
      case 'ar':
        return SynchronousFuture<AppLocalizations>(AppLocalizationsAr());
      case 'en':
      default:
        return SynchronousFuture<AppLocalizations>(AppLocalizationsEn());
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
