/// Centralized constants for all asset file paths.
class AssetPaths {
  static const String modelsPath = 'assets/models';
  static const String imagesPath = 'assets/images';
  static const String soundsPath = 'assets/sounds';

  // 3D Models (GLB)
  static const String cowBlueModel = '$modelsPath/cow_blue.glb';
  static const String cowRedModel = '$modelsPath/cow_red.glb';
  static const String cowNeutralModel = '$modelsPath/cow_neutral.glb';
  static const String hexGrassModel = '$modelsPath/hex_grass.glb';
  static const String hexBlockedModel = '$modelsPath/hex_blocked.glb';
  static const String fenceModel = '$modelsPath/fence.glb';
  static const String rockModel = '$modelsPath/rock.glb';
  static const String flowersModel = '$modelsPath/flowers.glb';
  static const String tableModel = '$modelsPath/table.glb';

  // UI Images
  static const String logo = '$imagesPath/logo.png';
  static const String avatarCow = '$imagesPath/avatar_cow.png';
  static const String tableWoodTexture = '$imagesPath/table_wood.png';

  // Sounds
  static const String soundTap = 'sounds/tap.mp3';
  static const String soundSelect = 'sounds/select.mp3';
  static const String soundMove = 'sounds/move.mp3';
  static const String soundTurnStart = 'sounds/turn_start.mp3';
  static const String soundVictory = 'sounds/victory.mp3';
  static const String soundDefeat = 'sounds/defeat.mp3';
}
