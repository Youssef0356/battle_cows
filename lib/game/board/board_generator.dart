import 'dart:math';
import '../models/hex_position.dart';
import '../models/hex_cell.dart';
import '../models/herd.dart';
import '../models/pasture_tile.dart';
import '../models/game_board.dart';
import '../models/player.dart';

class BoardGenerator {
  static GameBoard generateFromTiles(List<PastureTile> tiles, List<Player> players, int herdSize) {
    final herds = _placeStartingHerds(tiles, players, herdSize);
    return GameBoard.fromTiles(tiles, herds);
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

    final outerHexes = _getOuterHexes(allHexes);
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

  static List<HexPosition> _getOuterHexes(List<HexPosition> allHexes) {
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
