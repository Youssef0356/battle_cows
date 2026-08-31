/// Enum representing player colors in Battle Cows.
enum PlayerColor {
  blue,
  red,
  green,
  yellow;

  String get displayName {
    switch (this) {
      case PlayerColor.blue:
        return 'Blue';
      case PlayerColor.red:
        return 'Red';
      case PlayerColor.green:
        return 'Green';
      case PlayerColor.yellow:
        return 'Yellow';
    }
  }

  PlayerColor get opponent {
    switch (this) {
      case PlayerColor.blue:
        return PlayerColor.red;
      case PlayerColor.red:
        return PlayerColor.blue;
      case PlayerColor.green:
        return PlayerColor.yellow;
      case PlayerColor.yellow:
        return PlayerColor.green;
    }
  }
}
