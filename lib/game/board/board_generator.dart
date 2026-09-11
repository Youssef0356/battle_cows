import 'dart:math';
import '../models/hex_position.dart';
import '../models/herd.dart';
import '../models/pasture_tile.dart';
import '../models/game_board.dart';
import '../models/player.dart';
import '../models/challenge_mode.dart';
import '../models/hex_cell.dart';

class BoardGenerator {
  static GameBoard generateFromTiles(
    List<PastureTile> tiles,
    List<Player> players,
    int herdSize, {
    ChallengeMode mode = ChallengeMode.standard,
  }) {
    final herds = _placeStartingHerds(tiles, players, herdSize);
    return GameBoard.fromTiles(tiles, herds, specialTiles: _specialTiles(tiles, mode));
  }

  static GameBoard generateEmptyBoard(List<PastureTile> tiles, {ChallengeMode mode = ChallengeMode.standard}) {
    return GameBoard.fromTiles(tiles, [], specialTiles: _specialTiles(tiles, mode));
  }

  static Map<HexPosition, SpecialTileType> _specialTiles(
    List<PastureTile> tiles,
    ChallengeMode mode,
  ) {
    if (mode == ChallengeMode.standard || tiles.isEmpty) return {};
    final cells = <HexPosition>{};
    for (final tile in tiles) {
      cells.addAll(tile.hexes);
    }
    final sorted = cells.toList()..sort((a, b) => a.distanceTo(const HexPosition(0, 0)).compareTo(b.distanceTo(const HexPosition(0, 0))));
    if (sorted.isEmpty) return {};
    final specials = <HexPosition, SpecialTileType>{};
    if (mode == ChallengeMode.goldenPasture) {
      specials[sorted.first] = SpecialTileType.goldenPasture;
      if (sorted.length > 4) specials[sorted[sorted.length ~/ 2]] = SpecialTileType.hayBale;
    } else if (mode == ChallengeMode.kingOfTheHill) {
      specials[sorted.first] = SpecialTileType.hill;
      if (sorted.length > 6) specials[sorted[sorted.length ~/ 2]] = SpecialTileType.mud;
    } else if (mode == ChallengeMode.noTimer) {
      if (sorted.length > 3) specials[sorted[sorted.length ~/ 3]] = SpecialTileType.hayBale;
    }
    return specials;
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
