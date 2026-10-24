import 'app_localizations.dart';

class AppLocalizationsAr implements AppLocalizations {
  // --- Common ---
  @override String get cancel => 'إلغاء';
  @override String get exit => 'خروج';
  @override String get start => 'بدء';
  @override String get close => 'إغلاق';
  @override String get gotIt => 'فهمت!';
  @override String get ready => 'جاهز';
  @override String get wait => 'انتظر';
  @override String get share => 'مشاركة';
  @override String get rate => 'تقييم';
  @override String get menu => 'القائمة';
  @override String get rematch => 'مباراة جديدة';
  @override String get draw => 'تعادل!';
  @override String playerWins(String name) => 'فاز $name!';
  @override String get shareMessage =>
      'جرّب لعبة معركة الأبقار! 🐮 اجمع قطيعك واجتاح المراعي! https://play.google.com/store/apps/details?id=com.battlecows.game';

  // --- Home Screen ---
  @override String get gameTitle => 'معركة الأبقار';
  @override String get barnyardCampaign => 'حملة المزرعة';
  @override String get playVsAi => 'ضد الحاسوب';
  @override String get localMultiplayer => 'لاعبان محلياً';
  @override String get howToPlay => 'طريقة اللعب';
  @override String get challenges => 'التحديات';
  @override String get tutorialBtn => 'تدريب';
  @override String get settingsBtn => 'الإعدادات';
  @override String get shopBtn => 'المتجر';
  @override String get noAdsBtn => 'بلا إعلانات';
  @override String get exitGameTitle => 'الخروج من اللعبة؟';
  @override String get exitGameConfirm => 'هل أنت متأكد من رغبتك بالخروج؟';
  @override String get chooseYourChallenge => 'اختر التحدي';
  @override String get cpuDifficulty => 'مستوى الذكاء الاصطناعي';
  @override String get easy => 'سهل';
  @override String get medium => 'متوسط';
  @override String get hard => 'صعب';
  @override String get gameMode => 'نمط اللعب';
  @override String get pastureTilesPerPlayer => 'قطع المرعى لكل لاعب';
  @override String get pastureTilesSubtitle => 'قطع أكثر = مرعى أوسع ومعارك استراتيجية أطول!';
  @override String get fastTiles => 'سريع (4)';
  @override String get balancedTiles => 'متوازن (5)';
  @override String get epicTiles => 'ملحمي (6)';
  @override String get dailyQuests => 'المهمات اليومية';
  @override String questsReady(int count) => '$count مهمات جاهزة';
  @override String get playMore => 'العب المزيد';
  @override String defaultPlayerName(int index) => 'اللاعب $index';
  @override String aiPlayerName(int index) => 'بقرة الحاسوب $index';
  @override String get tutorialCowName => 'بقرة التدريب';

  // --- Settings Screen ---
  @override String get settingsTitle => 'الإعدادات';
  @override String get audioSection => 'الصوتيات';
  @override String get soundEffects => '🔊 المؤثرات الصوتية';
  @override String get music => '🎵 الموسيقى';
  @override String get hapticFeedback => '📳 الاهتزاز التفاعلي';
  @override String get gameSection => 'اللعبة';
  @override String get accountSection => 'الحساب';
  @override String get statLevel => '⭐ المستوى';
  @override String get statCoins => '💰 القطع الذهبية';
  @override String get statMatches => '⚔️ المباريات';
  @override String get statWins => '🥇 الانتصارات';
  @override String get statStreak => '🔥 سلسلة الفوز';
  @override String get premiumSection => 'النسخة المميزة';
  @override String get premiumActive => 'المميز مفعّل';
  @override String get removeAds => 'إزالة الإعلانات';
  @override String get supportSection => 'الدعم والمساعدة';
  @override String get languageSection => 'اللغة';
  @override String get languageEnglish => 'English';
  @override String get languageFrench => 'Français';
  @override String get languageArabic => 'العربية';

  // --- Challenge Modes ---
  @override String get modeStandardTitle => 'المرعى الكلاسيكي';
  @override String get modeStandardDesc => 'معركة أراضٍ تقليدية بلا مؤقت للدور.';
  @override String get modeTimedTitle => 'استراتيجية الوقت';
  @override String get modeTimedDesc => 'كل دور بمؤقت زمني سريع. نفاد الوقت يفقِدك قلباً.';
  @override String get modeFenceTitle => 'حرب الأسوار';
  @override String get modeFenceDesc => 'ضع وحرّك الأسوار الخشبية لحصار قطعان المنافسين!';
  @override String get modeGoldenTitle => 'المرعى الذهبي';
  @override String get modeGoldenDesc => 'المرعى الذهبي في المنتصف يمنح +1 بقرة إضافية ونقاطاً ثلاثية!';
  @override String get modeStampedeTitle => 'الاجتياح الكاسح';
  @override String get modeStampedeDesc => 'حزم القش تفجر الحماسة! القطعان الكبيرة (4+) تنطلق بقوة اندفاع خارقة!';

  // --- Quests ---
  @override String get dailyQuestsTitle => 'المهمات اليومية';
  @override String get dailyQuestsSubtitle => 'أنجز المهمات، اجمع القطع الذهبية وارتقِ بمستوى قطيعك.';
  @override String tacticsReady(int ready, int total) => '$ready/$total مهمات مكتملة';
  @override String get today => 'اليوم';
  @override String get questVictoryLapTitle => 'جولة النصر';
  @override String get questVictoryLapDesc => 'الفوز في مباراة واحدة';
  @override String get questGetMovingTitle => 'انطلاق الأبطال';
  @override String get questGetMovingDesc => 'لعب مباراتين';
  @override String get questBusyDayTitle => 'يوم حافل';
  @override String get questBusyDayDesc => 'لعب 3 مباريات';
  @override String get questLandGrabTitle => 'التوسع السريع';
  @override String get questLandGrabDesc => 'الاستحواذ على 5 قطع مرعى';
  @override String get questConquestTitle => 'السيطرة الكبرى';
  @override String get questConquestDesc => 'الاستحواذ على 10 قطع مرعى';
  @override String get questQuickHoovesTitle => 'حوافر رشيقة';
  @override String get questQuickHoovesDesc => 'الاستحواذ على 3 قطع خلال مبارياتك';
  @override String get questWarmUpTitle => 'إحماء الصباح';
  @override String get questWarmUpDesc => 'لعب مباراة واحدة اليوم';
  @override String get questHerdBuilderTitle => 'مُربّي القطعان';
  @override String get questHerdBuilderDesc => 'تحريك 5 أبقار خلال المباريات';
  @override String get questOnARollTitle => 'في أوج التألق';
  @override String get questOnARollDesc => 'الفوز في مباراتين متتاليتين';

  // --- Shop ---
  @override String get shopTitle => 'متجر الحظيرة';
  @override String get removeAdsGoPremium => 'إزالة الإعلانات — الترقية للمميز';
  @override String get equippedCheck => 'مُجهّز ✅';
  @override String get tapToUse => 'اضغط للارتداء';
  @override String itemPurchasedAndEquipped(String name) => 'تم شراء $name وارتداؤه!';
  @override String get cannotPurchase => 'تعذر الشراء — رصيد العملات غير كافٍ أو أنك تملكه مسبقاً';
  @override String itemUnequipped(String name) => 'تم نزع $name';
  @override String itemEquipped(String name) => 'تم تجهيز $name بنجاح!';
  @override String get categorySkins => 'المظاهر';
  @override String get categoryHats => 'القبعات';
  @override String get categoryThemes => 'الخلفيات';
  @override String get categoryEmojis => 'التعبيرات';
  @override String get categoryBoards => 'ألواح اللعب';
  @override String get shopItemCowboyName => 'بقرة رعاة البقر';
  @override String get shopItemCowboyDesc => 'بقرة قناصة من الغرب الأمريكي الأصيل';
  @override String get shopItemVikingName => 'بقرة الفايكنغ';
  @override String get shopItemVikingDesc => 'محاربة بقرون من الشمال المتجمد';
  @override String get shopItemFarmerName => 'بقرة المزرعة';
  @override String get shopItemFarmerDesc => 'نشيطة ومستعدة ليوم عمل كادح في الميدان';
  @override String get shopItemDiscoName => 'بقرة الديسكو';
  @override String get shopItemDiscoDesc => 'أروع بقرة إيقاعية ومرحة في الحظيرة';
  @override String get shopItemHatCowboyName => 'قبعة رعاة البقر';
  @override String get shopItemHatCowboyDesc => 'قبعة غربية كلاسيكية تليق بقطيعك';
  @override String get shopItemHatCrownName => 'التاج الملكي';
  @override String get shopItemHatCrownDesc => 'احكم المراعي بكل فخار وهيبة';
  @override String get shopItemHatPartyName => 'قبعة الاحتفال';
  @override String get shopItemHatPartyDesc => 'كل يوم هو عيد ومهرجان بهيج';
  @override String get shopItemHatSuperheroName => 'قناع البطل الخارق';
  @override String get shopItemHatSuperheroDesc => 'بطل القطيع ومحرر الأراضي';
  @override String get shopItemThemeValleyName => 'الوادي الأخضر';
  @override String get shopItemThemeValleyDesc => 'خلفية وادٍ ريفي مشمس وخلاب';
  @override String get shopItemThemeFieldName => 'حقل الزهور';
  @override String get shopItemThemeFieldDesc => 'مرعى خلاب ومزهر بالألوان';
  @override String get shopItemThemeWoodName => 'الخشب الريفي';
  @override String get shopItemThemeWoodDesc => 'طاولة خشبية دافئة وعريقة';
  @override String get shopItemEmojiFireName => 'تعبير اللهب';
  @override String get shopItemEmojiFireDesc => 'أشعل الحماس في أرجاء اللوح';
  @override String get shopItemEmojiLightningName => 'البرق الخاطف';
  @override String get shopItemEmojiLightningDesc => 'اضرب بسرعة البرق';
  @override String get shopItemEmojiStarName => 'النجمة الذهبية';
  @override String get shopItemEmojiStarDesc => 'تألق كالنجوم في سماء المعركة';
  @override String get shopItemBoardWoodTilesName => 'بلاطات خشبية';
  @override String get shopItemBoardWoodTilesDesc => 'خلايا سداسية من الخشب المنحوت';
  @override String get shopItemBoardMeadowTilesName => 'بلاطات المروج';
  @override String get shopItemBoardMeadowTilesDesc => 'عشب أخضر نضر تداعبه الشمس';
  @override String get shopItemBoardFlowerGrassName => 'عشب الأزهار';
  @override String get shopItemBoardFlowerGrassDesc => 'عشب يانع مرصع بأزهار برية جميلة';
  @override String get shopItemThemeSunsetName => 'مزرعة الغروب';
  @override String get shopItemThemeSunsetDesc => 'شفق برتقالي دافئ فوق أسقف الحظيرة';
  @override String get shopItemThemeNightName => 'مرعى النجوم';
  @override String get shopItemThemeNightDesc => 'مراعٍ هادئة تحت لمعان الأجرام السماوية';
  @override String get shopItemThemeSnowName => 'الصقيع الأبيض';
  @override String get shopItemThemeSnowDesc => 'حقل ثلجي ناصع للأبقار الشجاعة والمغامرة';
  @override String get shopItemBoardWoodName => 'خشب البلوط';
  @override String get shopItemBoardWoodDesc => 'قطع مرعى خشبية بنقوش يدوية عتيقة';
  @override String get shopItemBoardStoneName => 'ممر الحجارة';
  @override String get shopItemBoardStoneDesc => 'بلاطات صخرية عتيقة وصامدة للأبد';
  @override String get shopItemBoardGoldName => 'العشب الذهبي';
  @override String get shopItemBoardGoldDesc => 'حواف سداسية براقة تلمع كسبائك الذهب';
  @override String get shopItemBoardDarkName => 'مرعى الأوبسيديان';
  @override String get shopItemBoardDarkDesc => 'حقل بركاني أسود أنيق ومهيب';

  // --- Premium Dialog ---
  @override String get goPremiumTitle => 'الترقية للمميز';
  @override String get removeAllAds => 'إزالة الإعلانات نهائياً';
  @override String get benefitNoBanner => '🚫 بدون أي إعلانات شريطية';
  @override String get benefitNoFullscreen => '⏭️ بدون إعلانات شاشة كاملة بين المباريات';
  @override String get benefitForever => '🐮 دفعة واحدة فقط، وملكك للأبد';
  @override String buyWithPrice(String price) => 'شراء $price';
  @override String get unlock => 'فتح';
  @override String get restorePurchases => 'استعادة المشتريات';
  @override String get notNow => 'ليس الآن';
  @override String get premiumActiveThanks => 'تمت إزالة الإعلانات. شكراً جزيلاً لدعمك للعبة معركة الأبقار!';
  @override String get purchasesRestored => 'تمت استعادة مشترياتك بنجاح!';
  @override String get noPurchaseFound => 'لم يتم العثور على أي مشتريات سابقة';
  @override String purchaseFailed(String error) => 'تعذرت عملية الشراء: $error';
  @override String restoreFailed(String error) => 'تعذرت الاستعادة: $error';
  @override String get storeUnavailable => 'المتجر غير متاح على هذا الجهاز حالياً.';

  // --- In-Game Overlays & Controls ---
  @override String get gamePaused => 'اللعبة متوقفة';
  @override String get restartMatch => 'إعادة بدء المباراة';
  @override String get resetBoard => 'إعادة ضبط اللوح';
  @override String get exitToMainMenu => 'العودة للقائمة الرئيسية';
  @override String get tableBackground => 'خلفية الطاولة';
  @override String get defaultTheme => 'الافتراضية';
  @override String get buyThemesInShop => 'اشترِ خلفيات من المتجر لفتح مزيد من الطاولات';
  @override String get buildThePasture => 'بناء المرعى';
  @override String get rotate => 'تدوير';
  @override String get place => 'وضع';
  @override String get placeHerd => 'إنزال القطيع';
  @override String tapHighlightedHexToPlace(String name) => 'يا $name، اضغط على خانة مضيئة لإنزال قطيعك';
  @override String splitHerdTotal(int total) => 'تقسيم القطيع ($total كلي)';
  @override String get deselect => 'إلغاء التحديد';
  @override String stayCount(int count) => 'بقاء: $count';
  @override String moveCount(int count) => 'تحريك: $count';
  @override String get quickOneCow => 'بقرة واحدة';
  @override String get quickHalf => '½ النصف';
  @override String quickMax(int max) => 'الكل ($max)';
  @override String get tapHerdPrompt => 'المس أي قطيع من أبقارك (2+) لتحريك الأبقار';
  @override String fencesCount(int current, int max) => 'الأسوار: $current/$max';
  @override String get placeFence => 'وضع سياج';
  @override String get relocateFence => 'نقل السياج';
  @override String get tapEmptyToDrop => 'المس خانة فارغة لإنزال السياج';
  @override String get tapEmptyToPlace => 'المس خانة فارغة لوضع السياج';
  @override String get tapFenceToMove => 'المس سياجك لنقله لمكان آخر';
  @override String get blockEnemyPaths => 'اعترض طريق الخصم أو تقدّم';
  @override String get use => 'استخدام';
  @override String get playerTurn => 'دور اللاعب';
  @override String get cpuTurn => 'دور الحاسوب';
  @override String get finalTerritory => 'السيطرة النهائية';
  @override String get gameStats => 'إحصائيات المباراة';
  @override String get statTurns => 'الأدوار';
  @override String get statYourCows => 'أبقارك';
  @override String get statCpuCows => 'أبقار الحاسوب';
  @override String get statYourCaptures => 'استحواذك';
  @override String get statCpuCaptures => 'استحواذ الحاسوب';
  @override String coinsEarned(int coins) => '+$coins 💰 تم كسبها';
  @override String get enjoyingTheGame => 'هل تستمتع باللعبة؟';
  @override String get rateUsPrompt => 'قيّمنا بـ 5 نجوم لدعم قطيع الأبقار وتطويره!';
  @override String get rateUs => 'تقييم الآن';
  @override String get maybeLater => 'ربما لاحقاً';
  @override String toastStampede(int count) => 'اجتياح كاسح! +$count';
  @override String toastMoovelous(int count) => 'خوراااافي! +$count';
  @override String toastPastureRaid(int count) => 'غارة المرعى! +$count';

  // --- Tutorial ---
  @override String tutorialStepCounter(int step, int total) => 'التدريب · $step / $total';
  @override String get skip => 'تخطي';
  @override String get startExclamation => 'ابدأ!';
  @override String get doneBtn => 'تم';
  @override String get letsPlay => 'هيّا نلعب!';
  @override String get tutScenarioStep4Title => 'حدّد وتحرّك';
  @override String get tutScenarioStep4Desc =>
      'المس قطيعك لتحديده. استخدم شريط التمرير لاختيار عدد الأبقار المنفصلة، ثم المس مسدساً مضيئاً للتحرك!';
  @override String get tutScenarioStep5Title => 'سيطر لتفوز';
  @override String get tutScenarioStep5Desc =>
      'كل مسدس تصله يصبح ملكك. واصل الانقسام والتوسع — عندما يمتلئ المرعى، يفوز اللاعب صاحب أكبر عدد من المسدسات!';
  @override String get tutScenarioStep6Title => 'أنت جاهز!';
  @override String get tutScenarioStep6Desc =>
      'هذه هي اللعبة كلها! وسّع أرضك، واهزم قطعان المنافسين، وحين يكتمل المرعى — عدّ الأبقار. استمتع بوقتك!';
  @override String get tutStep1Title => 'أهلاً بك يا راعي الأبقار!';
  @override String get tutStep1Desc =>
      'في هذا النزال التدريبي السريع ستتعلم كل الأساسيات. الهدف: ملء المرعى — وعندما يكتمل اللوح، اللاعب صاحب القطيع الأكبر يفوز!';
  @override String get tutStep2Title => 'بناء المرعى';
  @override String get tutStep2Desc =>
      'المس اللوح لإنزال قطع المرعى. اضغط "تدوير" لتغيير اتجاه القطعة، ثم اضغط على الزر المتوهج لتثبيتها!';
  @override String get tutStep3Title => 'إنزال القطيع';
  @override String get tutStep3Desc =>
      'الآن المس خانة مضيئة على الحافة لإنزال قطيعك المكون من 16 بقرة. هذه قاعدتك الرئيسية!';
  @override String get tutStep4Title => 'حركتك الأولى';
  @override String get tutStep4Desc =>
      'المس قطيعك لتحديده. شريط التمرير على اليمين يحدد عدد الأبقار المتقدمة. اترك بقرة واحدة على الأقل، ثم المس أي خانة مضيئة في خط مستقيم!';
  @override String get tutStep5Title => 'التوسع والسيطرة';
  @override String get tutStep5Desc =>
      'تجري الأبقار في خط مستقيم حتى تصطدم بعائق أو بحافة اللوح. كل خانة يصلها قطيعك تصبح أرضاً تحت سيطرتك!';
  @override String get tutStep6Title => 'المحاصرة والمناورة';
  @override String get tutStep6Desc =>
      'حاصر خصمك! أي قطيع يُغلق عليه الطريق من كل الجهات لن يتمكن من الحركة مجدداً. خطط بحكمة للسيطرة على أكبر رقعة!';
  @override String get tutStep7Title => 'أنت جاهز للميدان!';
  @override String get tutStep7Desc =>
      'هذا كل شيء! ابنِ المرعى بذكاء، قسّم قطعانك بحكمة وتسيّد الأراضي الخضراء. بالتوفيق يا قائد الأبقار!';

  // --- How to Play Guide ---
  @override String get guideSetupTab => 'البداية';
  @override String get guideMovesTab => 'التحركات';
  @override String get guideBattleTab => 'المعركة';
  @override String get guideModesTab => 'الأنماط';
  @override String get guideSetupHeadline => 'ابنِ المرعى أولاً، ثم أنزل قطيعك عليه.';
  @override String get guideMovesHeadline => 'المس القطيع، قسّم الأبقار، وانطلق في خط مستقيم.';
  @override String get guideBattleHeadline => 'حاصر الأعداء، سيطر على كل خانة، وتسيّد المزرعة.';
  @override String get guideModesHeadline => 'طرق متعددة للعب، كلها من الشاشة الرئيسية.';
  @override String get guideStep1Title => 'اختر مباراتك';
  @override String get guideStep1Body =>
      'نمط "ضد الحاسوب" يتيح لك اختيار سهل أو متوسط أو صعب. "لاعبان محلياً" يتيح لشخصين اللعب على نفس الجهاز. كلاهما يطلب حجم المرعى: صغير (3 قطع)، متوسط (4) أو كبير (5).';
  @override String get guideStep2Title => 'بناء المرعى';
  @override String get guideStep2Body =>
      'يتناوب اللاعبون على إضافة قطع ألماسية رباعية السداسيات. اضغط "تدوير" لتغيير الاتجاه، ثم اسحبها لمكان فارغ يلامس المرعى، واضغط "وضع". كل خانة هي أرض تستحق القتال لأجلها.';
  @override String get guideStep3Title => 'إنزال القطيع';
  @override String get guideStep3Body =>
      'عند وضع آخر قطعة، يلمس كل لاعب خانة حافة مضيئة لإنزال قطيع من 16 بقرة. اختر موقعاً يتيح لك مساحة رحبة للتوسع.';
  @override String get guideStep4Title => 'تحديد القطيع';
  @override String get guideStep4Body =>
      'المس خانة تضم بقرتين أو أكثر من أبقارك. تظهر حلقة مضيئة وتضاء كل الخانات المتاحة بخطوط متقطعة. البقرة الوحيدة (حجم 1) لا تتحرك أبداً — بل تحرس الأرض فقط.';
  @override String get guideStep5Title => 'تقسيم القطيع';
  @override String get guideStep5Body =>
      'لوحة التحكم تعرض حجم القطيع ونسبة "تحريك / بقاء". اسحب المؤشر لتحديد عدد الأبقار المنطلقة؛ حيث يجب أن تبقى بقرة واحدة على الأقل لحراسة الخانة.';
  @override String get guideStep6Title => 'الانطلاق في خط مستقيم';
  @override String get guideStep6Body =>
      'المس إحدى الخانات المضيئة المستهدفة. تنطلق الأبقار في خط مستقيم حتى تصطدم بعائق، أو قطيع آخر، أو حافة اللوح، وتستحوذ على تلك الخانة لفريقك!';
  @override String get guideStep7Title => 'محاصرة قطعان العدو';
  @override String get guideStep7Body =>
      'لا يمكن للقطيع التحرك إلا في خطوط مستقيمة نحو خانات فارغة. إذا سُدت كل المسارات المستقيمة، يصبح القطيع مَحْصوراً ولا يستطيع الحركة لما تبقى من المباراة.';
  @override String get guideStep8Title => 'توسيع نطاق السيطرة';
  @override String get guideStep8Body =>
      'كل خانة تضم بقرة واحدة على الأقل من أبقارك تحتسب كنقطة سيطرة واحدة. تنتهي اللعبة عندما تنعدم الحركات القانونية لجميع اللاعبين.';
  @override String get guideStep9Title => 'صاحب الأرض الأكبر يفوز';
  @override String get guideStep9Body =>
      'شاشة النتائج تحصي الخانات التي استحوذ عليها كل لون. اللاعب صاحب المساحة الأكبر يفوز بالمباراة! حجم القطيع لا يكسر التعادل — الخانات هي الفيصل فقط.';
  @override String get guideTip1 =>
      'المزيد من القطع يعني ساحة معركة أكبر: 3 قطع يبلغ عرضها نحو 7 خانات، و5 قطع نحو 11 خانة.';
  @override String get guideTip2 =>
      'حاسوب المستوى الصعب يتبع نفس قواعدك تماماً — ولكنه يختار أذكى الحركات التكتيكية.';
  @override String get guideTip3 =>
      'تبدأ القطعان عند حواف المرعى، لذا يجب أن تتجه أولى تحركاتك نحو المنتصف.';
  @override String get guideTip4 =>
      'تحريك بقرة واحدة يبقي البقية للحراسة. بينما تحريك قطيع كبير يسيطر على الوجهة بقوة وحصانة.';
  @override String get guideTip5 =>
      'لا يمكن التراجع عن الحركة بعد تأكيدها — خطط لمسارك جيداً قبل اللمس.';
  @override String get guideTip6 =>
      'لا تستطيع الأبقار القفز فوق الأبقار الأخرى، حتى لو كانت صديقة. استخدم قطعانك كحواجز مصدّة!';
  @override String get guideTip7 =>
      'ترك أبقار مفردة في الخلف يبني جداراً يقسم اللوح ويقطع طرق الإمداد على الخصم.';
  @override String get guideTip8 =>
      'فكر بحركتين للأمام: التوقف بجوار قطيع العدو يتيح لك محاصرته وتطويقه في دورك القادم مباشرة.';
  @override String get guideTip9 =>
      'التعادل وارد إذا امتلك كلا اللاعبين نفس عدد الخانات — كل شبر في المرعى يصنع فارقاً!';

  // --- Campaign ---
  @override String get barnyardConquest => 'غزو المزرعة';
  @override String get campaignPuzzlesBattles => 'معارك وألغاز الحملة الكبرى';
  @override String levelBriefing(int level) => 'المستوى $level';
  @override String vsOpponent(String name) => 'ضد $name';
  @override String rewardCoinsBadge(int coins) => '+$coins قطعة';
  @override String rewardXpBadge(int xp) => '+$xp خبرة';
  @override String get startBattle => 'ابدأ المعركة!';
  @override
  String campaignLevelTitle(int id) {
    switch (id) {
      case 1: return 'معبر الوادي';
      case 2: return 'جدول الطين';
      case 3: return 'نزال المرعى الذهبي';
      case 4: return 'جنون الأسوار';
      case 5: return 'وادي الاجتياح';
      case 6: return 'مواجهة المزرعة الكبرى';
      default: return 'المستوى $id';
    }
  }
  @override
  String campaignLevelSubtitle(int id) {
    switch (id) {
      case 1: return 'أساسيات المزرعة';
      case 2: return 'خوض الوحل';
      case 3: return 'تاج المرعى';
      case 4: return 'دفاع الأخشاب';
      case 5: return 'بأقصى طاقة';
      case 6: return 'المرعى الأسطوري';
      default: return 'التحدي';
    }
  }
  @override
  String campaignLevelOpponent(int id) {
    switch (id) {
      case 1: return 'المزارع بوب';
      case 2: return 'ديزي الوحل';
      case 3: return 'راعي البقر تكس';
      case 4: return 'الثور وودي';
      case 5: return 'بيسي الشجاعة';
      case 6: return 'العمدة أنغوس';
      default: return 'المنافس';
    }
  }
  @override
  String campaignLevelDescription(int id) {
    switch (id) {
      case 1: return 'المزارع بوب يستيقظ من قيلولته. انشر قطيعك واستحوذ على المراعي الشاسعة!';
      case 2: return 'الطين يعيق حركة أبقارك! خطط لتقسيم قطيعك بعناية لتجاوز المستنقع.';
      case 3: return 'تكس يسعى للسيطرة على المرعى الذهبي المركزي. سيطر على القلب ودافع عنه!';
      case 4: return 'وودي وضع أسواراً في كل مكان! استغل أسوارك لحصاره في الزاوية الضيقة.';
      case 5: return 'نمط الاجتياح الكاسح! كوّن مجموعات من 4+ أبقار لإطلاق سرعة فائقة تكتسح الميدان!';
      case 6: return 'العمدة أنغوس هو البطل المتوج. استخدم كل خبراتك التكتيكية لهزيمته واعتلاء العرش!';
      default: return 'اهزم خصمك لكسب النجوم والمكافآت القيمة!';
    }
  }
  @override
  String campaignLevelObjective(int id) {
    switch (id) {
      case 1: return 'سيطر على مساحة أكبر من المزارع بوب لكسب حتى 3 نجوم.';
      case 2: return 'تجاوز بقع الطين واستولِ على المساحات الخضراء النضرة.';
      case 3: return 'استحوذ على المرعى الذهبي المركزي لكسب أبقار إضافية ونقاط مضاعفة 3 مرات.';
      case 4: return 'استخدم الأسوار بذكاء لمناورة الثور وودي ومحاصرته بالكامل.';
      case 5: return 'أطلق هجمات الاجتياح الكاسح للتغلب على بيسي الشجاعة.';
      case 6: return 'تغلب على العمدة أنغوس بدهائك في مرعى ملحمي كبير.';
      default: return 'سيطر على مساحة أكبر من خصمك لتحقيق الانتصار.';
    }
  }

  // --- Results ---
  @override String get finalScores => 'النتائج النهائية';
  @override String scoreTiles(int count) => '$count خانات';
}
