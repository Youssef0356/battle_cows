// Central lookup for cow sprite assets.
//
// The four cow sprites (cowboy / viking / farmer / disco) are tied to
// [PlayerColor] by the Flame renderer and the UI overlays. The shop's
// COWS section sells those same four sprites as skins - the local
// player's equipped skin overrides their color-based sprite.

import '../../assets/asset_paths.dart';
import '../../game/models/player_color.dart';

enum CowPose {
  idle,
  leap,
  dizzy,
}

class CowSkins {
  CowSkins._();

  static const Map<PlayerColor, String> byColor = {
    PlayerColor.blue: AssetPaths.cowP1HolsteinIdle,
    PlayerColor.red: AssetPaths.cowP2HighlandIdle,
    PlayerColor.yellow: 'assets/images/Cows/cow_farmer.png',
    PlayerColor.purple: 'assets/images/Cows/cow_disco.png',
  };

  /// Sprite for a player color with specific [pose] (idle, leap, dizzy),
  /// or the equipped skin when [skinId] is a valid skin id (`skin_*`).
  static String assetFor(
    PlayerColor color, {
    String? skinId,
    CowPose pose = CowPose.idle,
  }) {
    // If player has a specific shop skin equipped
    if (skinId != null && skinId.startsWith('skin_')) {
      const prefix = 'assets/images/Cows/cow_';
      return '$prefix${skinId.substring('skin_'.length)}.png';
    }

    // Breed-specific 3-state poses:
    if (color == PlayerColor.blue) {
      switch (pose) {
        case CowPose.idle:
          return AssetPaths.cowP1HolsteinIdle;
        case CowPose.leap:
          return AssetPaths.cowP1HolsteinLeap;
        case CowPose.dizzy:
          return AssetPaths.cowP1HolsteinDizzy;
      }
    } else if (color == PlayerColor.red) {
      switch (pose) {
        case CowPose.idle:
          return AssetPaths.cowP2HighlandIdle;
        case CowPose.leap:
          return AssetPaths.cowP2HighlandLeap;
        case CowPose.dizzy:
          return AssetPaths.cowP2HighlandDizzy;
      }
    }

    return byColor[color] ?? AssetPaths.cowP1HolsteinIdle;
  }
}
