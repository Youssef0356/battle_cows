// Central lookup for cow sprite assets.
//
// The four cow sprites (cowboy / viking / farmer / disco) are tied to
// [PlayerColor] by the Flame renderer and the UI overlays. The shop's
// COWS section sells those same four sprites as skins - the local
// player's equipped skin overrides their color-based sprite.

import '../../game/models/player_color.dart';

class CowSkins {
  CowSkins._();

  static const Map<PlayerColor, String> byColor = {
    PlayerColor.blue: 'assets/images/Cows/cow_viking.png',
    PlayerColor.red: 'assets/images/Cows/cow_cowboy.png',
    PlayerColor.yellow: 'assets/images/Cows/cow_farmer.png',
    PlayerColor.purple: 'assets/images/Cows/cow_disco.png',
  };

  /// Sprite for a player color, or the equipped skin when [skinId] is a
  /// valid skin id (`skin_*`). Invalid/empty ids fall back to the
  /// color-based sprite.
  static String assetFor(PlayerColor color, {String? skinId}) {
    const prefix = 'assets/images/Cows/cow_';
    if (skinId != null && skinId.startsWith('skin_')) {
      return '$prefix${skinId.substring('skin_'.length)}.png';
    }
    return byColor[color] ?? '${prefix}cow_viking.png';
  }
}
