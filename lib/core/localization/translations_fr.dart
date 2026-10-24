import 'app_localizations.dart';

class AppLocalizationsFr implements AppLocalizations {
  // --- Common ---
  @override String get cancel => 'ANNULER';
  @override String get exit => 'QUITTER';
  @override String get start => 'DÉMARRER';
  @override String get close => 'FERMER';
  @override String get gotIt => 'COMPRIS !';
  @override String get ready => 'PRÊT';
  @override String get wait => 'ATTENTE';
  @override String get share => 'PARTAGER';
  @override String get rate => 'NOTER';
  @override String get menu => 'MENU';
  @override String get rematch => 'REVANCHE';
  @override String get draw => 'MATCH NUL !';
  @override String playerWins(String name) => '$name GAGNE !';
  @override String get shareMessage =>
      'Découvrez Battle Cows ! 🐮 Rassemblez, chargez et conquérez le pré ! https://play.google.com/store/apps/details?id=com.battlecows.game';

  // --- Home Screen ---
  @override String get gameTitle => 'BATTLE COWS';
  @override String get barnyardCampaign => 'CAMPAGNE DE LA FERME';
  @override String get playVsAi => "JOUER CONTRE L'IA";
  @override String get localMultiplayer => 'MULTIJOUEUR LOCAL';
  @override String get howToPlay => 'COMMENT JOUER';
  @override String get challenges => 'DÉFIS';
  @override String get tutorialBtn => 'TUTORIEL';
  @override String get settingsBtn => 'RÉGLAGES';
  @override String get shopBtn => 'BOUTIQUE';
  @override String get noAdsBtn => 'SANS PUB';
  @override String get exitGameTitle => 'QUITTER LE JEU ?';
  @override String get exitGameConfirm => 'Êtes-vous sûr de vouloir quitter la partie ?';
  @override String get chooseYourChallenge => 'CHOISISSEZ VOTRE DÉFI';
  @override String get cpuDifficulty => "DIFFICULTÉ DE L'IA";
  @override String get easy => 'FACILE';
  @override String get medium => 'MOYEN';
  @override String get hard => 'DIFFICILE';
  @override String get gameMode => 'MODE DE JEU';
  @override String get pastureTilesPerPlayer => 'PARCELLES PAR JOUEUR';
  @override String get pastureTilesSubtitle => 'Plus de parcelles = pâturage plus vaste & batailles plus épiques !';
  @override String get fastTiles => 'RAPIDE (4)';
  @override String get balancedTiles => 'ÉQUILIBRÉ';
  @override String get epicTiles => 'ÉPIQUE (6)';
  @override String get dailyQuests => 'QUÊTES DU JOUR';
  @override String questsReady(int count) => '$count PRÊTE${count > 1 ? 'S' : ''}';
  @override String get playMore => 'JOUEZ ENCORE';
  @override String defaultPlayerName(int index) => 'Joueur $index';
  @override String aiPlayerName(int index) => 'Vache IA $index';
  @override String get tutorialCowName => 'Vache Guide';

  // --- Settings Screen ---
  @override String get settingsTitle => 'PARAMÈTRES';
  @override String get audioSection => 'AUDIO';
  @override String get soundEffects => '🔊 Effets sonores';
  @override String get music => '🎵 Musique';
  @override String get hapticFeedback => '📳 Retour haptique';
  @override String get gameSection => 'JEU';
  @override String get accountSection => 'COMPTE';
  @override String get statLevel => '⭐ Niveau';
  @override String get statCoins => '💰 Pièces';
  @override String get statMatches => '⚔️ Parties';
  @override String get statWins => '🥇 Victoires';
  @override String get statStreak => '🔥 Série';
  @override String get premiumSection => 'PREMIUM';
  @override String get premiumActive => 'PREMIUM ACTIF';
  @override String get removeAds => 'SUPPRIMER LES PUBS';
  @override String get supportSection => 'ASSISTANCE';
  @override String get languageSection => 'LANGUE';
  @override String get languageEnglish => 'English';
  @override String get languageFrench => 'Français';
  @override String get languageArabic => 'العربية';

  // --- Challenge Modes ---
  @override String get modeStandardTitle => 'PÂTURAGE CLASSIQUE';
  @override String get modeStandardDesc => 'Bataille de territoire traditionnelle. Sans compte à rebours.';
  @override String get modeTimedTitle => 'STRATÉGIE CHRONO';
  @override String get modeTimedDesc => 'Chaque tour est compté. Si le temps expire, vous perdez un cœur.';
  @override String get modeFenceTitle => 'GUERRE DES CLÔTURES';
  @override String get modeFenceDesc => 'Posez et bougez des barrières en bois pour coincer vos rivaux !';
  @override String get modeGoldenTitle => 'PÂTURAGE DORÉ';
  @override String get modeGoldenDesc => 'Le pré doré au centre offre +1 vache bonus et triple vos points !';
  @override String get modeStampedeTitle => 'RUÉE SAUVAGE';
  @override String get modeStampedeDesc => 'Le foin donne des ailes ! Les groupes de 4+ foncent à toute allure !';

  // --- Quests ---
  @override String get dailyQuestsTitle => 'QUÊTES QUOTIDIENNES';
  @override String get dailyQuestsSubtitle => 'Remplissez vos objectifs, empochez des pièces et faites grandir le troupeau.';
  @override String tacticsReady(int ready, int total) => '$ready/$total tactique${ready > 1 ? 's' : ''} prête${ready > 1 ? 's' : ''}';
  @override String get today => "AUJOURD'HUI";
  @override String get questVictoryLapTitle => "Tour d'honneur";
  @override String get questVictoryLapDesc => 'Remporter 1 partie';
  @override String get questGetMovingTitle => 'En selle';
  @override String get questGetMovingDesc => 'Jouer 2 parties';
  @override String get questBusyDayTitle => 'Journée chargée';
  @override String get questBusyDayDesc => 'Jouer 3 parties';
  @override String get questLandGrabTitle => 'Prise de terre';
  @override String get questLandGrabDesc => 'Capturer 5 parcelles';
  @override String get questConquestTitle => 'Conquête totale';
  @override String get questConquestDesc => 'Capturer 10 parcelles';
  @override String get questQuickHoovesTitle => 'Sabots agiles';
  @override String get questQuickHoovesDesc => 'Capturer 3 parcelles au fil des matchs';
  @override String get questWarmUpTitle => 'Mise en jambes';
  @override String get questWarmUpDesc => 'Jouer 1 partie aujourd\'hui';
  @override String get questHerdBuilderTitle => 'Éleveur né';
  @override String get questHerdBuilderDesc => 'Déplacer 5 vaches en match';
  @override String get questOnARollTitle => 'Sur sa lancée';
  @override String get questOnARollDesc => 'Gagner 2 parties consécutives';

  // --- Shop ---
  @override String get shopTitle => "BOUTIQUE DE L'ÉTABLE";
  @override String get removeAdsGoPremium => 'ZÉRO PUB — PASSER EN PREMIUM';
  @override String get equippedCheck => 'ÉQUIPÉ ✅';
  @override String get tapToUse => 'UTILISER';
  @override String itemPurchasedAndEquipped(String name) => '$name acheté et équipé !';
  @override String get cannotPurchase => 'Achat impossible — pièces insuffisantes ou objet déjà possédé';
  @override String itemUnequipped(String name) => '$name retiré';
  @override String itemEquipped(String name) => '$name équipé !';
  @override String get categorySkins => 'Vaches';
  @override String get categoryHats => 'Chapeaux';
  @override String get categoryThemes => 'Décors';
  @override String get categoryEmojis => 'Émojis';
  @override String get categoryBoards => 'Plateaux';
  @override String get shopItemCowboyName => 'Vache Cowboy';
  @override String get shopItemCowboyDesc => 'Fine gâchette venue tout droit de l\'Ouest';
  @override String get shopItemVikingName => 'Vache Viking';
  @override String get shopItemVikingDesc => 'Pilleuse casquée venue des fjords du Nord';
  @override String get shopItemFarmerName => 'Vache Fermière';
  @override String get shopItemFarmerDesc => 'Toujours vaillante pour travailler au pré';
  @override String get shopItemDiscoName => 'Vache Disco';
  @override String get shopItemDiscoDesc => 'La reine du funk et du dancefloor';
  @override String get shopItemHatCowboyName => 'Chapeau de Cowboy';
  @override String get shopItemHatCowboyDesc => 'Un stetson authentique pour vos bêtes';
  @override String get shopItemHatCrownName => 'Couronne Royale';
  @override String get shopItemHatCrownDesc => 'Régnez sur les prés avec majesté';
  @override String get shopItemHatPartyName => 'Chapeau Festif';
  @override String get shopItemHatPartyDesc => 'La vie est une fête permanente';
  @override String get shopItemHatSuperheroName => 'Masque de Justicier';
  @override String get shopItemHatSuperheroDesc => 'Le défenseur masqué du troupeau';
  @override String get shopItemThemeValleyName => 'Vallée Verdoyante';
  @override String get shopItemThemeValleyDesc => 'Un beau vallon fermier baigné de soleil';
  @override String get shopItemThemeFieldName => 'Champ Fleuri';
  @override String get shopItemThemeFieldDesc => 'Une prairie fleurie et enchanteresse';
  @override String get shopItemThemeWoodName => 'Bois Rustique';
  @override String get shopItemThemeWoodDesc => 'Un plateau de bois chaleureux et boisé';
  @override String get shopItemEmojiFireName => 'Émoji Flamme';
  @override String get shopItemEmojiFireDesc => 'Mettez le feu au plateau';
  @override String get shopItemEmojiLightningName => 'Éclair';
  @override String get shopItemEmojiLightningDesc => 'Frappez avec la vitesse de l\'éclair';
  @override String get shopItemEmojiStarName => 'Étoile Dorée';
  @override String get shopItemEmojiStarDesc => 'Brillez de mille feux dans le pré';
  @override String get shopItemBoardWoodTilesName => 'Dalles de Bois';
  @override String get shopItemBoardWoodTilesDesc => 'Des hexagones de bois sculpté';
  @override String get shopItemBoardMeadowTilesName => 'Dalles Prairie';
  @override String get shopItemBoardMeadowTilesDesc => 'Une herbe douce caressée par le soleil';
  @override String get shopItemBoardFlowerGrassName => 'Herbe Fleurie';
  @override String get shopItemBoardFlowerGrassDesc => 'Une pelouse luxuriante parsemée de fleurs';
  @override String get shopItemThemeSunsetName => 'Ranch au Crépuscule';
  @override String get shopItemThemeSunsetDesc => 'Lueurs ambrées sur les toits de la grange';
  @override String get shopItemThemeNightName => 'Clair de Lune';
  @override String get shopItemThemeNightDesc => 'Pâturage paisible sous les étoiles';
  @override String get shopItemThemeSnowName => 'Prairie Glacée';
  @override String get shopItemThemeSnowDesc => 'Manteau neigeux pour vaches intrépides';
  @override String get shopItemBoardWoodName => 'Chêne Rustique';
  @override String get shopItemBoardWoodDesc => 'Dalles de bois façonné à la main';
  @override String get shopItemBoardStoneName => 'Voie de Pierre';
  @override String get shopItemBoardStoneDesc => 'Dallage ancien, robuste et inusable';
  @override String get shopItemBoardGoldName => 'Pâture Dorée';
  @override String get shopItemBoardGoldDesc => 'Hexagones bordés d\'or étincelant';
  @override String get shopItemBoardDarkName => 'Plaine Volcanique';
  @override String get shopItemBoardDarkDesc => 'Terre d\'obsidienne au style ravageur';

  // --- Premium Dialog ---
  @override String get goPremiumTitle => 'OFFRE PREMIUM';
  @override String get removeAllAds => 'SUPPRIMER TOUTES LES PUBS';
  @override String get benefitNoBanner => '🚫 Plus aucune bannière publicitaire';
  @override String get benefitNoFullscreen => '⏭️ Zéro coupure vidéo entre les matchs';
  @override String get benefitForever => '🐮 Achat définitif, valable pour toujours';
  @override String buyWithPrice(String price) => 'ACHETER $price';
  @override String get unlock => 'DÉBLOQUER';
  @override String get restorePurchases => 'RESTAURER LES ACHATS';
  @override String get notNow => 'PAS MAINTENANT';
  @override String get premiumActiveThanks => 'Publicités supprimées. Merci pour votre soutien !';
  @override String get purchasesRestored => 'Achats restaurés avec succès !';
  @override String get noPurchaseFound => 'Aucun achat précédent trouvé';
  @override String purchaseFailed(String error) => 'Échec du paiement : $error';
  @override String restoreFailed(String error) => 'Échec de la restauration : $error';
  @override String get storeUnavailable => 'Boutique indisponible sur cet appareil.';

  // --- In-Game Overlays & Controls ---
  @override String get gamePaused => 'PAUSE';
  @override String get restartMatch => 'RECOMMENCER LA PARTIE';
  @override String get resetBoard => 'RÉINITIALISER LE PLATEAU';
  @override String get exitToMainMenu => 'RETOURNER AU MENU';
  @override String get tableBackground => 'DÉCOR DU PLATEAU';
  @override String get defaultTheme => 'PAR DÉFAUT';
  @override String get buyThemesInShop => 'Débloquez de nouveaux décors dans la boutique';
  @override String get buildThePasture => 'CONSTRUIRE LE PRÉ';
  @override String get rotate => 'PIVOTER';
  @override String get place => 'POSER';
  @override String get placeHerd => 'POSER LE TROUPEAU';
  @override String tapHighlightedHexToPlace(String name) => '$name, touchez une case illuminée pour poser votre troupeau';
  @override String splitHerdTotal(int total) => 'DIVISER LE TROUPEAU ($total TOTAL)';
  @override String get deselect => 'DÉSÉLECTIONNER';
  @override String stayCount(int count) => 'RESTE : $count';
  @override String moveCount(int count) => 'AVANCE : $count';
  @override String get quickOneCow => '1 VACHE';
  @override String get quickHalf => '½ MOITIÉ';
  @override String quickMax(int max) => 'MAX ($max)';
  @override String get tapHerdPrompt => 'TOUCHEZ UN GROUPE (2+ VACHES) POUR DÉPLACER';
  @override String fencesCount(int current, int max) => 'CLÔTURES : $current/$max';
  @override String get placeFence => 'POSER CLÔTURE';
  @override String get relocateFence => 'BOUGER CLÔTURE';
  @override String get tapEmptyToDrop => 'Touchez une case vide pour poser la clôture';
  @override String get tapEmptyToPlace => 'Touchez une case vide pour l\'installer';
  @override String get tapFenceToMove => 'Touchez votre clôture pour la repositionner';
  @override String get blockEnemyPaths => 'Barrez la route ennemie ou avancez';
  @override String get use => 'ACTION';
  @override String get playerTurn => 'TOUR DU JOUEUR';
  @override String get cpuTurn => "TOUR DE L'IA";
  @override String get finalTerritory => 'TERRITOIRE FINAL';
  @override String get gameStats => 'STATISTIQUES DU MATCH';
  @override String get statTurns => 'TOURS';
  @override String get statYourCows => 'VOS VACHES';
  @override String get statCpuCows => 'VACHES IA';
  @override String get statYourCaptures => 'VOS CAPTURES';
  @override String get statCpuCaptures => 'CAPTURES IA';
  @override String coinsEarned(int coins) => '+$coins 💰 REMPORTÉES';
  @override String get enjoyingTheGame => 'LE JEU VOUS PLAÎT ?';
  @override String get rateUsPrompt => 'Mettez-nous 5 étoiles pour motiver le troupeau !';
  @override String get rateUs => 'DONNER MON AVIS';
  @override String get maybeLater => 'PLUS TARD';
  @override String toastStampede(int count) => 'RUÉE SAUVAGE ! +$count';
  @override String toastMoovelous(int count) => 'MEUH-GNIFIQUE ! +$count';
  @override String toastPastureRaid(int count) => 'RAID EN PÂTURE ! +$count';

  // --- Tutorial ---
  @override String tutorialStepCounter(int step, int total) => 'TUTORIEL · $step / $total';
  @override String get skip => 'PASSER';
  @override String get startExclamation => 'COMMENCER !';
  @override String get doneBtn => 'TERMINÉ';
  @override String get letsPlay => "C'EST PARTI !";
  @override String get tutScenarioStep4Title => 'SÉLECTIONNER & DÉPLACER';
  @override String get tutScenarioStep4Desc =>
      'Touchez votre troupeau pour le sélectionner. Utilisez le curseur pour choisir le nombre de vaches qui se séparent, puis touchez un hexagone allumé pour vous déplacer !';
  @override String get tutScenarioStep5Title => 'CONQUÉRIR POUR GAGNER';
  @override String get tutScenarioStep5Desc =>
      'Chaque hexagone atteint devient le vôtre. Continuez à vous diviser et à vous étendre — lorsque le pâturage est plein, le joueur qui a le PLUS d\'hexagones gagne !';
  @override String get tutScenarioStep6Title => "VOUS ÊTES PRÊT !";
  @override String get tutScenarioStep6Desc =>
      'C\'est tout le jeu ! Étendez votre territoire, repoussez les troupeaux rivaux, et quand le pâturage est plein — comptez les vaches. AMUSEZ-VOUS !';
  @override String get tutStep1Title => 'BIENVENUE AU RANCH !';
  @override String get tutStep1Desc =>
      'Cette initiation rapide vous apprend tout le nécessaire. But : occuper le pré — quand il est rempli, celui qui a le PLUS GRAND troupeau l\'emporte !';
  @override String get tutStep2Title => 'CONSTRUIRE LE PRÉ';
  @override String get tutStep2Desc =>
      'Touchez le plateau pour placer vos tuiles de pâture. Utilisez PIVOTER si besoin, puis validez sur le bouton lumineux !';
  @override String get tutStep3Title => 'DÉPLOYER LE TROUPEAU';
  @override String get tutStep3Desc =>
      'Touchez une case illuminée en bordure pour installer vos 16 bêtes. C\'est votre quartier général !';
  @override String get tutStep4Title => 'VOTRE PREMIER COUP';
  @override String get tutStep4Desc =>
      'Sélectionnez votre troupeau. Le curseur vous permet de décider combien de vaches partent. Gardez-en au moins une, puis touchez une case illuminée en ligne droite !';
  @override String get tutStep5Title => 'AGRANDIR SON DOMAINE';
  @override String get tutStep5Desc =>
      'Les vaches galopent en ligne droite jusqu\'à percuter un obstacle ou le bord. Chaque case atteinte devient vôtre !';
  @override String get tutStep6Title => "COINCER L'ADVERSAIRE";
  @override String get tutStep6Desc =>
      'Enfermez votre rival ! Un groupe bloqué de tous côtés ne pourra plus jamais bouger. Anticipez vos trajectoires !';
  @override String get tutStep7Title => 'VOUS ÊTES PRÊT !';
  @override String get tutStep7Desc =>
      'C\'est tout ! Bâtissez malin, séparez vos bêtes avec ruse et régnez sans partage. Bonne chance !';

  // --- How to Play Guide ---
  @override String get guideSetupTab => 'PRÉPARATION';
  @override String get guideMovesTab => 'MOUVEMENTS';
  @override String get guideBattleTab => 'BATAILLE';
  @override String get guideModesTab => 'MODES';
  @override String get guideSetupHeadline => 'Façonnez le pré, puis faites entrer votre troupeau.';
  @override String get guideMovesHeadline => 'Touchez un groupe, séparez-le et chargez en ligne droite.';
  @override String get guideBattleHeadline => 'Bloquez vos rivaux, grignotez l\'espace et devenez le boss.';
  @override String get guideModesHeadline => 'Trois façons de jouer, toutes sur l\'écran d\'accueil.';
  @override String get guideStep1Title => 'CHOISIR LE FORMAT';
  @override String get guideStep1Body =>
      "JOUER CONTRE L'IA vous propose les niveaux FACILE, MOYEN ou DIFFICILE. Le MULTIJOUEUR LOCAL permet à deux humains de s'affronter sur le même appareil. Tous deux demandent la taille du pré : PETIT (3 tuiles), MOYEN (4) ou GRAND (5).";
  @override String get guideStep2Title => 'ASSEMBLER LE PÂTURAGE';
  @override String get guideStep2Body =>
      'À tour de rôle, chaque joueur pose une tuile en losange de 4 hexagones. Appuyez sur PIVOTER pour l\'orienter, glissez-la sur un emplacement libre adjacent, puis appuyez sur POSER. Chaque case compte !';
  @override String get guideStep3Title => 'POSER SON TROUPEAU';
  @override String get guideStep3Body =>
      'Dès que la dernière tuile est fixée, chaque participant touche un hexagone de bordure surbrillant pour y faire entrer 16 vaches. Choisissez un point avec de l\'espace pour vous étendre.';
  @override String get guideStep4Title => 'SÉLECTIONNER UN GROUPE';
  @override String get guideStep4Body =>
      'Touchez une case comptant 2 vaches ou plus. Un anneau lumineux s\'allume et toutes les destinations possibles s\'entourent de pointillés. Une vache solitaire ne bougera plus jamais — elle conserve la case.';
  @override String get guideStep5Title => 'SÉPARER LE GROUPE';
  @override String get guideStep5Body =>
      'Le panneau de déplacement affiche la taille du groupe et la répartition "avance / reste". Faites glisser la barre : au moins 1 vache doit obligatoirement rester pour garder le terrain.';
  @override String get guideStep6Title => 'GALOPER TOUT DROIT';
  @override String get guideStep6Body =>
      'Touchez l\'une des cases cibles. Les vaches courent en ligne droite jusqu\'à buter contre un obstacle, un troupeau ou la bordure du pré. La case d\'arrivée est à vous !';
  @override String get guideStep7Title => 'MURER LES RIVAUX';
  @override String get guideStep7Body =>
      'Un groupe ne peut avancer qu\'en ligne droite sur des cases vides. Si toutes les voies de sortie sont coupées, le troupeau est PIÉGÉ et ne bougera plus de la partie.';
  @override String get guideStep8Title => 'CONQUÉRIR DU TERRAIN';
  @override String get guideStep8Body =>
      'Chaque case abritant au moins 1 de vos vaches rapporte 1 point de territoire. La fin de partie sonne quand plus aucun joueur ne peut bouger.';
  @override String get guideStep9Title => 'LE PLUS VASTE L\'EMPORTE';
  @override String get guideStep9Body =>
      'Le récapitulatif compte les cases acquises par couleur. Celui qui détient la plus grande superficie gagne la partie ! Le nombre de vaches ne départage pas les égalités.';
  @override String get guideTip1 =>
      'Plus de tuiles signifie un terrain plus vaste : 3 tuiles mesurent environ 7 cases de large, 5 tuiles environ 11.';
  @override String get guideTip2 =>
      'L\'IA DIFFICILE respecte exactement vos règles : elle choisit simplement les meilleurs coups tactiques.';
  @override String get guideTip3 =>
      'Les troupeaux commencent sur les bordures, vos premiers déplacements visent donc naturellement le centre.';
  @override String get guideTip4 =>
      'Laisser 1 vache conserve la case. Envoyer un groupe massif garantit une solide tête de pont.';
  @override String get guideTip5 =>
      'Une fois la course lancée, impossible d\'annuler : planifiez bien avant de valider votre coup.';
  @override String get guideTip6 =>
      'Les vaches ne peuvent pas sauter par-dessus leurs congénères. Servez-vous de vos propres bêtes comme amortisseur !';
  @override String get guideTip7 =>
      'Semer des vaches isolées crée des barrières infranchissables qui coupent le terrain en deux.';
  @override String get guideTip8 =>
      'Anticipez avec un coup d\'avance : s\'arrêter à côté d\'un rival permet de le bloquer au tour suivant.';
  @override String get guideTip9 =>
      'Une égalité parfaite est possible si les deux camps détiennent le même total de cases — chaque case est capitale !';

  // --- Campaign ---
  @override String get barnyardConquest => 'CONQUÊTE DE LA FERME';
  @override String get campaignPuzzlesBattles => 'ÉPREUVES & DUELS DE CAMPAGNE';
  @override String levelBriefing(int level) => 'NIVEAU $level';
  @override String vsOpponent(String name) => 'CONTRE $name';
  @override String rewardCoinsBadge(int coins) => '+$coins PIÈCES';
  @override String rewardXpBadge(int xp) => '+$xp XP';
  @override String get startBattle => 'AU COMBAT !';
  @override
  String campaignLevelTitle(int id) {
    switch (id) {
      case 1: return 'La Traversée du Pré';
      case 2: return 'Le Ruisseau Boueux';
      case 3: return 'Duel au Trèfle d\'Or';
      case 4: return 'La Folie des Barrières';
      case 5: return 'Le Canyon de la Ruée';
      case 6: return 'Le Face-à-Face au Ranch';
      default: return 'Niveau $id';
    }
  }
  @override
  String campaignLevelSubtitle(int id) {
    switch (id) {
      case 1: return 'Initiation fermière';
      case 2: return 'Progression dans la boue';
      case 3: return 'La couronne du pré';
      case 4: return 'Défense forestière';
      case 5: return 'À toute vitesse';
      case 6: return 'Le grand pré';
      default: return 'Défi';
    }
  }
  @override
  String campaignLevelOpponent(int id) {
    switch (id) {
      case 1: return 'Fermier Bob';
      case 2: return 'Marguerite';
      case 3: return 'Cowboy Tex';
      case 4: return 'Taureau Woody';
      case 5: return 'Bessie Musclée';
      case 6: return 'Shérif Angus';
      default: return 'Adversaire';
    }
  }
  @override
  String campaignLevelDescription(int id) {
    switch (id) {
      case 1: return 'Le Fermier Bob émerge de sa sieste. Déployez votre troupeau et prenez le contrôle des herbages !';
      case 2: return 'La boue engloutit vos sabots ! Calculez vos divisions pour contourner le marais sans encombre.';
      case 3: return 'Tex convoite le Trèfle d\'Or central. Prenez d\'assaut le centre et défendez-le vaillamment !';
      case 4: return 'Woody a semé des barrières partout ! Utilisez les vôtres pour le repousser dans ses retranchements.';
      case 5: return 'Mode Ruée Sauvage ! Formez des groupes de 4+ vaches pour déclencher des sprints supersoniques !';
      case 6: return 'Le Shérif Angus défend son titre. Déployez tout votre génie stratégique pour le terrasser !';
      default: return 'Battez votre rival pour amasser étoiles et trésors !';
    }
  }
  @override
  String campaignLevelObjective(int id) {
    switch (id) {
      case 1: return 'Occupez plus de terrain que le Fermier Bob pour décrocher jusqu\'à 3 étoiles.';
      case 2: return 'Contournez les bourbiers et emparez-vous des parcelles d\'herbe tendre.';
      case 3: return 'Contrôlez le pré doré pour gagner des vaches bonus et tripler vos points.';
      case 4: return 'Exploitez les clôtures avec ruse pour coincer le Taureau Woody.';
      case 5: return 'Déchaînez les ruées sauvages pour submerger Bessie.';
      case 6: return 'Déjouez les pièges du Shérif Angus sur un champ de bataille colossal.';
      default: return 'Conquérez plus de territoire que votre rival pour triompher.';
    }
  }

  // --- Results ---
  @override String get finalScores => 'SCORES FINAUX';
  @override String scoreTiles(int count) => '$count CASES';
}
