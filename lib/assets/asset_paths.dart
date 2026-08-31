/// Centralized constants for all asset file paths.
class AssetPaths {
  static const String modelsPath = 'assets/models';
  static const String imagesPath = 'assets/images';
  static const String soundsPath = 'assets/sounds';

  // 3D Models (GLB)
  static const String cowPawnModel = '$modelsPath/Cow Pawn .glb';
  static const String fenceModel = '$modelsPath/fence.glb';
  static const String flowerModel = '$modelsPath/flower.glb';
  static const String rockModel = '$modelsPath/rock.glb';

  // Background & UI Images
  static const String background = '$imagesPath/Background/Background.jpg';
  static const String tableImage = '$imagesPath/Background/Table image.jpg';
  static const String logo = '$imagesPath/Background/Logo.png';
  static const String titleText = '$imagesPath/Background/Title Text.png';

  // Tile & Pasture Textures
  static const String grassTexture = '$imagesPath/Tile Image/Grass Texture.jpg';
  static const String tileTexture = '$imagesPath/Tile Image/Tile Texture.png';

  // Sounds
  static const String soundTap = 'sounds/tap.mp3';
  static const String soundSelect = 'sounds/select.mp3';
  static const String soundMove = 'sounds/move.mp3';
  static const String soundTurnStart = 'sounds/turn_start.mp3';
  static const String soundVictory = 'sounds/victory.mp3';
  static const String soundDefeat = 'sounds/defeat.mp3';
}
