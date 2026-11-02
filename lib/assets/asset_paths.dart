/// Centralized constants for all asset file paths.
class AssetPaths {
  static const String modelsPath = 'assets/models';
  static const String imagesPath = 'assets/images';
  static const String soundsPath = 'assets/audio';

  // 3D Models (GLB)
  static const String cowPawnModel = '$modelsPath/Cow Pawn .glb';
  static const String fenceModel = '$modelsPath/fence.glb';
  static const String flowerModel = '$modelsPath/flower.glb';
  static const String rockModel = '$modelsPath/rock.glb';

  // Background & UI Images
  static const String background = '$imagesPath/Background/Background.jpg';
  static const String tableImage = '$imagesPath/Background/Table image.jpg';
  static const String tableGameplayBackground = '$imagesPath/Background/Table image.jpg';
  static const String logo = '$imagesPath/Background/Logo.png';
  static const String titleText = '$imagesPath/Background/Title Text.png';

  // Selectable theme backgrounds (shop themes map onto these).
  static const String backgroundValley = '$imagesPath/Background/Background.jpg';
  static const String backgroundFarmField = '$imagesPath/Background/Farm field.jpg';
  static const String backgroundWood = '$imagesPath/Background/Wood planks.jpg';

  // Tile & Pasture Textures
  static const String grassTexture = '$imagesPath/Tile Image/Grass Texture.jpg';
  static const String tileTexture = '$imagesPath/Tile Image/Tile Texture.png';

  // Selectable board tile textures (shop boards map onto these).
  static const String boardTextureWood = '$imagesPath/Tile Image/Tile Texture.jpg';
  static const String boardTextureMeadow = '$imagesPath/Tile Image/Tile Texture.png';
  static const String boardTextureFlowers = '$imagesPath/Tile Image/Grass Texture.jpg';

  // 2.5D Hex Sprites (Normalized)
  static const String hexNeutralPasture = '$imagesPath/Ui V2/Hexes_normalized/Neutral Pasture.png';
  static const String hexPlayer1Claimed = '$imagesPath/Ui V2/Hexes_normalized/Player 1 Claimed (Blue Rim).png';
  static const String hexPlayer2Claimed = '$imagesPath/Ui V2/Hexes_normalized/Player 2  AI Claimed (Red Rim).png';
  static const String hexValidMoveHighlight = '$imagesPath/Ui V2/Hexes_normalized/Valid Move Highlight (Neon Mint Glow).png';
  static const String hexBlockedTrapped = '$imagesPath/Ui V2/Hexes_normalized/Blocked Trapped State.png';

  // Cow Herd Sprites (3 states per breed)
  static const String cowP1HolsteinIdle = '$imagesPath/Ui V2/Cows_normalized/p1_holstein_idle.png';
  static const String cowP1HolsteinLeap = '$imagesPath/Ui V2/Cows_normalized/p1_holstein_leap.png';
  static const String cowP1HolsteinDizzy = '$imagesPath/Ui V2/Cows_normalized/p1_holstein_dizzy.png';

  static const String cowP2HighlandIdle = '$imagesPath/Ui V2/Cows_normalized/p2_highland_idle.png';
  static const String cowP2HighlandLeap = '$imagesPath/Ui V2/Cows_normalized/p2_highland_leap.png';
  static const String cowP2HighlandDizzy = '$imagesPath/Ui V2/Cows_normalized/p2_highland_dizzy.png';

  // Tokens & VFX
  static const String stackCounterBadge = '$imagesPath/Ui V2/Cows_normalized/stack_counter_badge.png';
  static const String landingDustBurst = '$imagesPath/Ui V2/Cows_normalized/landing_dust_burst.png';

  // Blank Carved Wood & Rope HUD Kit
  static const String uiHudCounterPlaque = '$imagesPath/Ui V2/battle_cows_ui_components/ui_hud_counter_plaque.png';
  static const String uiScoreboardRibbonsBar = '$imagesPath/Ui V2/battle_cows_ui_components/ui_scoreboard_ribbons_bar.png';
  static const String uiBottomInstructionBanner = '$imagesPath/Ui V2/battle_cows_ui_components/ui_bottom_instruction_banner.png';
  static const String uiBtnSettingsGear = '$imagesPath/Ui V2/battle_cows_ui_components/ui_btn_settings_gear.png';
  static const String uiBtnActionBrown = '$imagesPath/Ui V2/battle_cows_ui_components/ui_btn_action_brown.png';
  static const String uiBtnActionGreen = '$imagesPath/Ui V2/battle_cows_ui_components/ui_btn_action_green.png';

  // Main Menu UI V2
  static const String mainMenuBackground = '$imagesPath/Ui V2/battle_cows_main_menu_ui/Background.jpeg';
  static const String battleCowsLogo = '$imagesPath/Ui V2/battle_cows_main_menu_ui/battle_cows_logo.png';
  static const String menuPlayerProfilePlaque = '$imagesPath/Ui V2/battle_cows_main_menu_ui/menu_player_profile_plaque.png';
  static const String menuBtnShop = '$imagesPath/Ui V2/battle_cows_main_menu_ui/menu_btn_shop.png';
  static const String menuBtnNoAds = '$imagesPath/Ui V2/battle_cows_main_menu_ui/menu_btn_no_ads.png';
  static const String menuBtnHeroCampaign = '$imagesPath/Ui V2/battle_cows_main_menu_ui/menu_btn_hero_campaign.png';
  static const String menuCardModeBlue = '$imagesPath/Ui V2/battle_cows_main_menu_ui/menu_card_mode_blue.png';
  static const String menuCardModeRed = '$imagesPath/Ui V2/battle_cows_main_menu_ui/menu_card_mode_red.png';
  static const String menuBtnSecondaryShield = '$imagesPath/Ui V2/battle_cows_main_menu_ui/menu_btn_secondary_shield.png';
  static const String menuBtnSecondaryBlank = '$imagesPath/Ui V2/battle_cows_main_menu_ui/menu_btn_secondary_blank.png';
  static const String menuBannerDailyQuests = '$imagesPath/Ui V2/battle_cows_main_menu_ui/menu_banner_daily_quests.png';
  static const String menuBtnExit = '$imagesPath/Ui V2/battle_cows_main_menu_ui/menu_btn_exit.png';
  static const String playerCowAvatar = '$imagesPath/Ui V2/battle_cows_main_menu_ui/player_cow_avatar.png';

  // Sounds
  static const String soundTap = 'sounds/tap.mp3';
  static const String soundSelect = 'sounds/select.mp3';
  static const String soundMove = 'sounds/move.mp3';
  static const String soundTurnStart = 'sounds/turn_start.mp3';
  static const String soundVictory = 'sounds/victory.mp3';
  static const String soundDefeat = 'sounds/defeat.mp3';
}
