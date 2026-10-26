import 'app_localizations.dart';

class AppLocalizationsEn implements AppLocalizations {
  // --- Common ---
  @override String get cancel => 'CANCEL';
  @override String get exit => 'EXIT';
  @override String get start => 'START';
  @override String get close => 'CLOSE';
  @override String get gotIt => 'GOT IT';
  @override String get ready => 'READY';
  @override String get wait => 'WAIT';
  @override String get share => 'SHARE';
  @override String get rate => 'RATE';
  @override String get menu => 'MENU';
  @override String get rematch => 'REMATCH';
  @override String get draw => 'DRAW!';
  @override String playerWins(String name) => '$name WINS!';
  @override String get shareMessage =>
      'Check out Battle Cows! 🐮 Round up, rampage, repeat! https://play.google.com/store/apps/details?id=com.battlecows.game';

  // --- Home Screen ---
  @override String get gameTitle => 'BATTLE COWS';
  @override String get barnyardCampaign => 'BARNYARD CAMPAIGN';
  @override String get playVsAi => 'PLAY VS AI';
  @override String get localMultiplayer => 'LOCAL MULTIPLAYER';
  @override String get howToPlay => 'HOW TO PLAY';
  @override String get challenges => 'CHALLENGES';
  @override String get tutorialBtn => 'TUTORIAL';
  @override String get settingsBtn => 'SETTINGS';
  @override String get shopBtn => 'SHOP';
  @override String get noAdsBtn => 'NO ADS';
  @override String get exitGameTitle => 'EXIT GAME?';
  @override String get exitGameConfirm => 'Are you sure you want to exit?';
  @override String get chooseYourChallenge => 'CHOOSE YOUR CHALLENGE';
  @override String get cpuDifficulty => 'CPU DIFFICULTY';
  @override String get easy => 'EASY';
  @override String get medium => 'MEDIUM';
  @override String get hard => 'HARD';
  @override String get gameMode => 'GAME MODE';
  @override String get pastureTilesPerPlayer => 'PASTURE TILES PER PLAYER';
  @override String get pastureTilesSubtitle => 'More tiles = larger pasture & longer tactical battles!';
  @override String get fastTiles => 'FAST (4)';
  @override String get balancedTiles => 'BALANCED';
  @override String get epicTiles => 'EPIC (6)';
  @override String get dailyQuests => 'DAILY QUESTS';
  @override String questsReady(int count) => '$count READY';
  @override String get playMore => 'PLAY MORE';
  @override String defaultPlayerName(int index) => 'Player $index';
  @override String aiPlayerName(int index) => 'AI Cow $index';
  @override String get tutorialCowName => 'Tutorial Cow';

  // --- Settings Screen ---
  @override String get settingsTitle => 'SETTINGS';
  @override String get audioSection => 'AUDIO';
  @override String get soundEffects => '🔊 Sound Effects';
  @override String get music => '🎵 Music';
  @override String get hapticFeedback => '📳 Haptic Feedback';
  @override String get gameSection => 'GAME';
  @override String get accountSection => 'ACCOUNT';
  @override String get statLevel => '⭐ Level';
  @override String get statCoins => '💰 Coins';
  @override String get statMatches => '⚔️ Matches';
  @override String get statWins => '🥇 Wins';
  @override String get statStreak => '🔥 Streak';
  @override String get premiumSection => 'PREMIUM';
  @override String get premiumActive => 'PREMIUM ACTIVE';
  @override String get removeAds => 'REMOVE ADS';
  @override String get supportSection => 'SUPPORT';
  @override String get languageSection => 'LANGUAGE';
  @override String get chooseLanguage => 'CHOOSE LANGUAGE';
  @override String get chooseLanguageSubtitle => 'Select your preferred language';
  @override String get languageEnglish => 'English';
  @override String get languageFrench => 'Français';
  @override String get languageArabic => 'العربية';
  @override String get confirm => 'CONFIRM';

  // --- Challenge Modes ---
  @override String get modeStandardTitle => 'STANDARD PASTURE';
  @override String get modeStandardDesc => 'Classic territory battle. No turn timer.';
  @override String get modeTimedTitle => 'TIMED STRATEGY';
  @override String get modeTimedDesc => 'Every turn is on the clock. Run out of time and lose a heart.';
  @override String get modeFenceTitle => 'FENCE BATTLE';
  @override String get modeFenceDesc => 'Place & move wooden fences each turn to block and trap enemy herds!';
  @override String get modeGoldenTitle => 'GOLDEN PASTURE';
  @override String get modeGoldenDesc => 'Central Golden Pasture grants +1 bonus cow and 3x territory points!';
  @override String get modeStampedeTitle => 'STAMPEDE RUSH';
  @override String get modeStampedeDesc => 'Hay bales boost herds! Herds of 4+ move with blazing stampede power!';

  // --- Quests ---
  @override String get dailyQuestsTitle => 'DAILY QUESTS';
  @override String get dailyQuestsSubtitle => 'Complete tactics, claim coins, and level up your herd.';
  @override String tacticsReady(int ready, int total) => '$ready/$total tactics ready';
  @override String get today => 'TODAY';
  @override String get questVictoryLapTitle => 'Victory Lap';
  @override String get questVictoryLapDesc => 'Win 1 match';
  @override String get questGetMovingTitle => 'Get Moving';
  @override String get questGetMovingDesc => 'Play 2 matches';
  @override String get questBusyDayTitle => 'Busy Day';
  @override String get questBusyDayDesc => 'Play 3 matches';
  @override String get questLandGrabTitle => 'Land Grab';
  @override String get questLandGrabDesc => 'Capture 5 tiles';
  @override String get questConquestTitle => 'Conquest';
  @override String get questConquestDesc => 'Capture 10 tiles';
  @override String get questQuickHoovesTitle => 'Quick Hooves';
  @override String get questQuickHoovesDesc => 'Capture 3 tiles in your matches';
  @override String get questWarmUpTitle => 'Warm Up';
  @override String get questWarmUpDesc => 'Play 1 match today';
  @override String get questHerdBuilderTitle => 'Herd Builder';
  @override String get questHerdBuilderDesc => 'Move 5 cows in matches';
  @override String get questOnARollTitle => 'On a Roll';
  @override String get questOnARollDesc => 'Win 2 matches in a row';

  // --- Shop ---
  @override String get shopTitle => 'COW BARN SHOP';
  @override String get removeAdsGoPremium => 'REMOVE ADS — GO PREMIUM';
  @override String get equippedCheck => 'EQUIPPED ✅';
  @override String get tapToUse => 'TAP TO USE';
  @override String itemPurchasedAndEquipped(String name) => '$name purchased & equipped!';
  @override String get cannotPurchase => 'Cannot purchase — check coins or already owned';
  @override String itemUnequipped(String name) => '$name unequipped';
  @override String itemEquipped(String name) => '$name equipped!';
  @override String get categorySkins => 'Skins';
  @override String get categoryHats => 'Hats';
  @override String get categoryThemes => 'Themes';
  @override String get categoryEmojis => 'Emojis';
  @override String get categoryBoards => 'Boards';
  @override String get shopItemCowboyName => 'Cowboy Cow';
  @override String get shopItemCowboyDesc => 'A sharpshooting western cow';
  @override String get shopItemVikingName => 'Viking Cow';
  @override String get shopItemVikingDesc => 'A horned raider from the north';
  @override String get shopItemFarmerName => 'Farmer Cow';
  @override String get shopItemFarmerDesc => 'Ready for a hard day in the pasture';
  @override String get shopItemDiscoName => 'Disco Cow';
  @override String get shopItemDiscoDesc => 'The grooviest cow on the board';
  @override String get shopItemHatCowboyName => 'Cowboy Hat';
  @override String get shopItemHatCowboyDesc => 'A classic western hat for your herd';
  @override String get shopItemHatCrownName => 'Royal Crown';
  @override String get shopItemHatCrownDesc => 'Rule the pasture with honor';
  @override String get shopItemHatPartyName => 'Party Hat';
  @override String get shopItemHatPartyDesc => 'Every day is a celebration';
  @override String get shopItemHatSuperheroName => 'Super Mask';
  @override String get shopItemHatSuperheroDesc => 'Hero of the herd';
  @override String get shopItemThemeValleyName => 'Green Valley';
  @override String get shopItemThemeValleyDesc => 'Sunny cartoon farm valley backdrop';
  @override String get shopItemThemeFieldName => 'Flower Field';
  @override String get shopItemThemeFieldDesc => 'Blooming meadow pasture backdrop';
  @override String get shopItemThemeWoodName => 'Rustic Wood';
  @override String get shopItemThemeWoodDesc => 'Cozy wooden tabletop backdrop';
  @override String get shopItemEmojiFireName => 'Fire Emoji';
  @override String get shopItemEmojiFireDesc => 'Flex with a fire reaction';
  @override String get shopItemEmojiLightningName => 'Lightning';
  @override String get shopItemEmojiLightningDesc => 'Strike with speed';
  @override String get shopItemEmojiStarName => 'Gold Star';
  @override String get shopItemEmojiStarDesc => 'Shine bright on the board';
  @override String get shopItemBoardWoodTilesName => 'Wooden Tiles';
  @override String get shopItemBoardWoodTilesDesc => 'Warm carved wood hex tiles';
  @override String get shopItemBoardMeadowTilesName => 'Meadow Tiles';
  @override String get shopItemBoardMeadowTilesDesc => 'Soft sunlit grass hex tiles';
  @override String get shopItemBoardFlowerGrassName => 'Flower Grass';
  @override String get shopItemBoardFlowerGrassDesc => 'Lush grass dotted with wildflowers';
  @override String get shopItemThemeSunsetName => 'Sunset Ranch';
  @override String get shopItemThemeSunsetDesc => 'Warm orange dusk over the barnyard';
  @override String get shopItemThemeNightName => 'Night Meadow';
  @override String get shopItemThemeNightDesc => 'Quiet starlit pastures';
  @override String get shopItemThemeSnowName => 'Winter Frost';
  @override String get shopItemThemeSnowDesc => 'Crisp snowy field for cool cows';
  @override String get shopItemBoardWoodName => 'Rustic Oak';
  @override String get shopItemBoardWoodDesc => 'Carved wooden pasture tiles';
  @override String get shopItemBoardStoneName => 'Stone Pathway';
  @override String get shopItemBoardStoneDesc => 'Sturdy ancient stone tiles';
  @override String get shopItemBoardGoldName => 'Gilded Grass';
  @override String get shopItemBoardGoldDesc => 'Gleaming golden hex borders';
  @override String get shopItemBoardDarkName => 'Obsidian Field';
  @override String get shopItemBoardDarkDesc => 'Sleek volcanic dark pasture';

  // --- Premium Dialog ---
  @override String get goPremiumTitle => 'GO PREMIUM';
  @override String get removeAllAds => 'REMOVE ALL ADS';
  @override String get benefitNoBanner => '🚫 No banner ads';
  @override String get benefitNoFullscreen => '⏭️ No full-screen ads between matches';
  @override String get benefitForever => '🐮 One-time purchase, yours forever';
  @override String buyWithPrice(String price) => 'BUY $price';
  @override String get unlock => 'UNLOCK';
  @override String get restorePurchases => 'RESTORE PURCHASES';
  @override String get notNow => 'NOT NOW';
  @override String get premiumActiveThanks => 'Ads are removed. Thanks for supporting Battle Cows!';
  @override String get purchasesRestored => 'Purchases restored!';
  @override String get noPurchaseFound => 'No previous purchase found';
  @override String purchaseFailed(String error) => 'Purchase failed: $error';
  @override String restoreFailed(String error) => 'Restore failed: $error';
  @override String get storeUnavailable => 'Store not available on this device.';

  // --- In-Game Overlays & Controls ---
  @override String get gamePaused => 'GAME PAUSED';
  @override String get restartMatch => 'RESTART MATCH';
  @override String get resetBoard => 'RESET BOARD';
  @override String get exitToMainMenu => 'EXIT TO MAIN MENU';
  @override String get tableBackground => 'TABLE BACKGROUND';
  @override String get defaultTheme => 'DEFAULT';
  @override String get buyThemesInShop => 'Buy themes in the shop to unlock more tables';
  @override String get buildThePasture => 'BUILD THE PASTURE';
  @override String get rotate => 'ROTATE';
  @override String get place => 'PLACE';
  @override String get placeHerd => 'PLACE HERD';
  @override String tapHighlightedHexToPlace(String name) => '$name, tap a highlighted hex to place your herd';
  @override String splitHerdTotal(int total) => 'SPLIT HERD ($total TOTAL)';
  @override String get deselect => 'DESELECT';
  @override String stayCount(int count) => 'STAY: $count';
  @override String moveCount(int count) => 'MOVE: $count';
  @override String get quickOneCow => '1 COW';
  @override String get quickHalf => '½ HALF';
  @override String quickMax(int max) => 'MAX ($max)';
  @override String get tapHerdPrompt => 'TAP ANY OF YOUR HERDS (SIZE 2+) TO MOVE COWS';
  @override String fencesCount(int current, int max) => 'FENCES: $current/$max';
  @override String get placeFence => 'PLACE FENCE';
  @override String get relocateFence => 'RELOCATE FENCE';
  @override String get tapEmptyToDrop => 'Tap empty hex to drop fence';
  @override String get tapEmptyToPlace => 'Tap empty hex to place';
  @override String get tapFenceToMove => 'Tap your fence to move';
  @override String get blockEnemyPaths => 'Block enemy paths or move';
  @override String get use => 'USE';
  @override String get playerTurn => 'PLAYER TURN';
  @override String get cpuTurn => "CPU'S TURN";
  @override String get finalTerritory => 'FINAL TERRITORY';
  @override String get gameStats => 'GAME STATS';
  @override String get statTurns => 'TURNS';
  @override String get statYourCows => 'YOUR COWS';
  @override String get statCpuCows => 'CPU COWS';
  @override String get statYourCaptures => 'YOUR CAPTURES';
  @override String get statCpuCaptures => 'CPU CAPTURES';
  @override String coinsEarned(int coins) => '+$coins 💰 EARNED';
  @override String get enjoyingTheGame => 'ENJOYING THE GAME?';
  @override String get rateUsPrompt => 'Rate us 5 stars to support the herd!';
  @override String get rateUs => 'RATE US';
  @override String get maybeLater => 'MAYBE LATER';
  @override String toastStampede(int count) => 'STAMPEDE! +$count';
  @override String toastMoovelous(int count) => 'MOO-VELOUS! +$count';
  @override String toastPastureRaid(int count) => 'PASTURE RAID! +$count';

  // --- Tutorial ---
  @override String tutorialStepCounter(int step, int total) => 'TUTORIAL · $step / $total';
  @override String get skip => 'SKIP';
  @override String get startExclamation => 'START!';
  @override String get doneBtn => 'DONE';
  @override String get letsPlay => "LET'S PLAY!";
  @override String get tutScenarioStep4Title => 'SELECT & MOVE';
  @override String get tutScenarioStep4Desc =>
      'Tap YOUR herd to select it. Use the slider to choose how many cows split off, then tap a lit hex to move!';
  @override String get tutScenarioStep5Title => 'CLAIM TO WIN';
  @override String get tutScenarioStep5Desc =>
      'Every hex you reach becomes yours. Keep splitting and expanding — when the pasture is full, the player with the MOST hexes wins!';
  @override String get tutScenarioStep6Title => "YOU'RE READY!";
  @override String get tutScenarioStep6Desc =>
      "That's the whole game! Expand your territory, crush rival herds, and when the pasture is full — count the cows. HAVE FUN!";
  @override String get tutStep1Title => 'WELCOME, COWPUNCHER!';
  @override String get tutStep1Desc =>
      "In this quick match you'll learn everything you need. Goal: fill the pasture — when the board is full, the player with the BIGGEST herd wins!";
  @override String get tutStep2Title => 'BUILD THE PASTURE';
  @override String get tutStep2Desc =>
      'Tap the board to drop your pasture tiles. Press ROTATE to turn a tile first. Tap the glowing button to place it!';
  @override String get tutStep3Title => 'PLACE YOUR HERD';
  @override String get tutStep3Desc =>
      "Now tap a glowing hex on the edge to drop your herd of 16 cows. That's your home base!";
  @override String get tutStep4Title => 'YOUR FIRST MOVE';
  @override String get tutStep4Desc =>
      'Tap your herd to select it. The slider on the right lets you choose how many cows march out. Split off at least 1 cow, then tap any lit tile in a straight line!';
  @override String get tutStep5Title => 'CLAIM & EXPAND';
  @override String get tutStep5Desc =>
      'Cows run until they hit another herd or the edge of the board. Every tile your cows land on becomes your territory!';
  @override String get tutStep6Title => 'TRAP & OUTSMART';
  @override String get tutStep6Desc =>
      'Block your opponent! A herd that gets boxed in can never move again. Plan ahead to claim the most grass!';
  @override String get tutStep7Title => "YOU'RE READY TO ROAM!";
  @override String get tutStep7Desc =>
      'That\'s it! Build smart pastures, split stacks wisely, and dominate the pasture. Good luck, boss cow!';

  // --- How to Play Guide ---
  @override String get guideSetupTab => 'SETUP';
  @override String get guideMovesTab => 'MOVES';
  @override String get guideBattleTab => 'BATTLE';
  @override String get guideModesTab => 'MODES';
  @override String get guideSetupHeadline => 'Build the pasture, then drop your herd onto it.';
  @override String get guideMovesHeadline => 'Tap a herd, split the herd, march in a straight line.';
  @override String get guideBattleHeadline => 'Box enemies in, claim every hex, rule the ranch.';
  @override String get guideModesHeadline => 'Three ways to play, all from the home screen.';
  @override String get guideStep1Title => 'PICK YOUR MATCH';
  @override String get guideStep1Body =>
      'PLAY VS AI lets you choose EASY, MEDIUM or HARD. LOCAL MULTIPLAYER puts two humans on the same device. Both then ask for the pasture size: SMALL (3 tiles), MEDIUM (4) or LARGE (5).';
  @override String get guideStep2Title => 'BUILD THE PASTURE';
  @override String get guideStep2Body =>
      'Players take turns adding 4-hex diamond tiles. Tap ROTATE to spin the tile, drag it onto a free spot that touches the pasture, then tap PLACE. Every hex you add is ground worth fighting for.';
  @override String get guideStep3Title => 'PLACE YOUR HERD';
  @override String get guideStep3Body =>
      'When the last tile is down, each player taps a highlighted edge hex to drop a herd of 16 cows. Choose a spot with room to spread out.';
  @override String get guideStep4Title => 'SELECT A HERD';
  @override String get guideStep4Body =>
      'Tap a hex holding 2 or more of your cows. A glowing ring marks it and every reachable hex lights up with a dashed outline. A herd of 1 cow can never move again - it only holds ground.';
  @override String get guideStep5Title => 'SPLIT THE HERD';
  @override String get guideStep5Body =>
      'The MOVE COWS panel on the right shows the herd size and "move / stay". Drag the slider to choose how many cows march out; at least 1 cow always stays behind to hold the hex.';
  @override String get guideStep6Title => 'MARCH IN A LINE';
  @override String get guideStep6Body =>
      'Tap one of the highlighted target hexes. The marching cows run in a straight line until they hit an obstacle, another herd, or the edge of the board. They claim that hex for your team!';
  @override String get guideStep7Title => 'WALL OFF ENEMY HERDS';
  @override String get guideStep7Body =>
      'A herd can only move in straight lines into empty hexes. If every straight path out is blocked by other cows or empty space, that herd is TRAPPED and cannot move for the rest of the match.';
  @override String get guideStep8Title => 'EXPAND YOUR TERRITORY';
  @override String get guideStep8Body =>
      'Every hex holding at least 1 of your cows counts as 1 point of territory. The game ends when no player has any legal moves left - usually when all hexes are occupied or remaining herds are walled in.';
  @override String get guideStep9Title => 'MOST GROUND WINS';
  @override String get guideStep9Body =>
      'The final screen tallies up the hexes claimed by each color. The player with the most territory wins the match! Herd size does not break ties - only claimed hexes count.';
  @override String get guideTip1 =>
      'More tiles means a bigger battlefield: 3 tiles is about 7 hexes wide, 5 tiles about 11.';
  @override String get guideTip2 =>
      'HARD AI plays by exactly the same rules as you - it just picks better moves.';
  @override String get guideTip3 =>
      'Herds start on the rim of the pasture, so your first moves push towards the middle.';
  @override String get guideTip4 =>
      'Moving 1 cow leaves the rest behind to defend. Moving a big stack claims the destination with power.';
  @override String get guideTip5 =>
      'A split cannot be undone once confirmed - plan your route before tapping.';
  @override String get guideTip6 =>
      'Cows cannot jump over other cows, even friendly ones. Use your own herds as backstops!';
  @override String get guideTip7 =>
      'Leaving single cows behind forms a wall that cuts the board in half and blocks opponent routes.';
  @override String get guideTip8 =>
      'Look two moves ahead: landing next to an enemy herd lets you pin it on your very next turn.';
  @override String get guideTip9 =>
      'A draw is possible if both players claim the same number of hexes - every single tile matters!';

  // --- Campaign ---
  @override String get barnyardConquest => 'BARNYARD CONQUEST';
  @override String get campaignPuzzlesBattles => 'CAMPAIGN PUZZLES & BATTLES';
  @override String levelBriefing(int level) => 'LEVEL $level';
  @override String vsOpponent(String name) => 'VS $name';
  @override String rewardCoinsBadge(int coins) => '+$coins COINS';
  @override String rewardXpBadge(int xp) => '+$xp XP';
  @override String get startBattle => 'START BATTLE!';
  @override
  String campaignLevelTitle(int id) {
    switch (id) {
      case 1: return 'Meadow Crossing';
      case 2: return 'Muddy Creek';
      case 3: return 'Golden Pasture Duel';
      case 4: return 'Fence Frenzy';
      case 5: return 'Stampede Canyon';
      case 6: return 'Ranch Showdown';
      default: return 'Level $id';
    }
  }
  @override
  String campaignLevelSubtitle(int id) {
    switch (id) {
      case 1: return 'Barnyard Basics';
      case 2: return 'Treading Through Mud';
      case 3: return 'The Crown Clover';
      case 4: return 'Timber Defense';
      case 5: return 'Full Throttle';
      case 6: return 'The Grand Pasture';
      default: return 'Challenge';
    }
  }
  @override
  String campaignLevelOpponent(int id) {
    switch (id) {
      case 1: return 'Farmer Bob';
      case 2: return 'Daisy Dirt';
      case 3: return 'Cowboy Tex';
      case 4: return 'Woody Bull';
      case 5: return 'Bessie Brawn';
      case 6: return 'Sheriff Angus';
      default: return 'Opponent';
    }
  }
  @override
  String campaignLevelDescription(int id) {
    switch (id) {
      case 1: return 'Farmer Bob is waking up from a nap. Spread your herd and claim the open pastures!';
      case 2: return 'Mud slows your cows down! Plan your splits carefully to bypass the bog.';
      case 3: return 'Tex wants the central Golden Pasture. Capture the middle and hold it!';
      case 4: return 'Woody placed fences everywhere! Place your own fences to box him into a corner.';
      case 5: return 'Stampede Rush mode! Build 4+ cow stacks to trigger blistering speed!';
      case 6: return 'Sheriff Angus is the reigning champion. Bring all your tactical mastery to defeat him!';
      default: return 'Defeat your opponent to earn stars and rewards!';
    }
  }
  @override
  String campaignLevelObjective(int id) {
    switch (id) {
      case 1: return 'Claim more territory than Farmer Bob to earn up to 3 stars.';
      case 2: return 'Navigate past the mud and capture the green pastures.';
      case 3: return 'Seize the central Golden Pasture for bonus cows and triple points.';
      case 4: return 'Use fences tactically to outmaneuver and trap Woody Bull.';
      case 5: return 'Unleash stampede rushes to overwhelm Bessie Brawn.';
      case 6: return 'Outsmart Sheriff Angus on an epic grand pasture.';
      default: return 'Claim more territory than your opponent to win.';
    }
  }

  // --- Results ---
  @override String get finalScores => 'FINAL SCORES';
  @override String scoreTiles(int count) => '$count TILES';
}
