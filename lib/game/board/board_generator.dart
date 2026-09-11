import 'dart:math';
import '../models/hex_position.dart';
import '../models/herd.dart';
import '../models/pasture_tile.dart';
import '../models/game_board.dart';
import '../models/player.dart';
import '../models/challenge_mode.dart';

class BoardGenerator {
  static GameBoard generateFromTiles(List<PastureTile> tiles, List<Player> players, int herdSize) {
    final herds = _placeStartingHerds(tiles, players, herdSize);
    return _decorate(GameBoard.fromTiles(tiles, herds), ChallengeMode.standard);
  }

  static GameBoard generateEmptyBoard(List<PastureTile> tiles, {ChallengeMode mode = ChallengeMode.standard}) {
    return _decorate(GameBoard.fromTiles(tiles, []), mode);
  }

  static GameBoard _decorate(GameBoard board, ChallengeMode mode) {
    // Special terrain is kept implemented but disabled until the board art is
    // fully matched to the base pasture tiles.
    return board;

    /*
    final cells = <HexPosition, HexCell>{};
    final specialTiles = mode == ChallengeMode.noTimer
        ? const [
            SpecialTileType.mud,
            SpecialTileType.waterPond,
            SpecialTileType.hayBale,
            SpecialTileType.goldenPasture,
            SpecialTileType.hill,
          ]
        : const [
            SpecialTileType.hayBale,
            SpecialTileType.goldenPasture,
            SpecialTileType.hill,
          ];

    for (final entry in board.cells.entries) {
      final hash = (entry.key.q * 31 + entry.key.r * 17).abs();
      final specialType = hash % 8 == 0
          ? specialTiles[hash % specialTiles.length]
          : SpecialTileType.none;
      cells[entry.key] = entry.value.copyWith(specialType: specialType);
    }
    return GameBoard(cells: cells, herds: board.herds);
    */
  }

  static List<Herd> _placeStartingHerds(
    List<PastureTile> tiles,
    List<Player> players,
    int herdSize,
  ) {
    final allHexes = <HexPosition>[];
    for (final tile in tiles) {
      allHexes.addAll(tile.hexes);
    }

    final outerHexes = getOuterHexes(allHexes);
    final startPositions = _selectStartingPositions(outerHexes, players.length);

    final herds = <Herd>[];
    for (var i = 0; i < players.length; i++) {
      herds.add(Herd(
        position: startPositions[i],
        owner: players[i].color,
        size: herdSize,
      ));
    }

    return herds;
  }

  static List<HexPosition> getOuterHexes(List<HexPosition> allHexes) {
    final outer = <HexPosition>[];
    for (final hex in allHexes) {
      for (final dir in HexPosition.directions) {
        final neighbor = hex + dir;
        if (!allHexes.contains(neighbor)) {
          outer.add(hex);
          break;
        }
      }
    }
    return outer;
  }

  static List<HexPosition> _selectStartingPositions(List<HexPosition> outerHexes, int playerCount) {
    final positions = <HexPosition>[];
    final random = Random();
    final available = List<HexPosition>.from(outerHexes);

    if (available.isEmpty) return [];

    for (var i = 0; i < playerCount && available.isNotEmpty; i++) {
      final idx = random.nextInt(available.length);
      final pos = available.removeAt(idx);

      available.removeWhere((p) => p.distanceTo(pos) < 2);
      positions.add(pos);
    }

    while (positions.length < playerCount && outerHexes.isNotEmpty) {
      final idx = random.nextInt(outerHexes.length);
      final pos = outerHexes.removeAt(idx);
      if (!positions.contains(pos)) {
        positions.add(pos);
      }
    }

    return positions;
  }
}
