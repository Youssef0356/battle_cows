/// Global and per-match configuration for Battle Cows.
class GameConfig {
  static bool debug = false;

  final int boardRadius;
  final int startingStackCount;
  final int maxTurns;
  final double hexRadius;
  final double hexSpacing;
  final double hexHeight;
  final bool autoFocusOnSelection;
  final bool soundEnabled;
  final bool musicEnabled;
  final double cameraSensitivity;

  const GameConfig({
    this.boardRadius = 3,
    this.startingStackCount = 4,
    this.maxTurns = 30,
    this.hexRadius = 1.0,
    this.hexSpacing = 0.05,
    this.hexHeight = 0.25,
    this.autoFocusOnSelection = false,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.cameraSensitivity = 1.0,
  });

  GameConfig copyWith({
    int? boardRadius,
    int? startingStackCount,
    int? maxTurns,
    double? hexRadius,
    double? hexSpacing,
    double? hexHeight,
    bool? autoFocusOnSelection,
    bool? soundEnabled,
    bool? musicEnabled,
    double? cameraSensitivity,
  }) {
    return GameConfig(
      boardRadius: boardRadius ?? this.boardRadius,
      startingStackCount: startingStackCount ?? this.startingStackCount,
      maxTurns: maxTurns ?? this.maxTurns,
      hexRadius: hexRadius ?? this.hexRadius,
      hexSpacing: hexSpacing ?? this.hexSpacing,
      hexHeight: hexHeight ?? this.hexHeight,
      autoFocusOnSelection: autoFocusOnSelection ?? this.autoFocusOnSelection,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      cameraSensitivity: cameraSensitivity ?? this.cameraSensitivity,
    );
  }
}
