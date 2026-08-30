import '../models/hex_position.dart';
import '../models/pasture_tile.dart';

class TileBag {
  PastureTile generateTile(int id) {
    final center = HexPosition(0, 0);
    return PastureTile.diamond(id, center);
  }
}

class BoardBuilder {
  final List<HexPosition> _placedHexes = [];
  final List<PastureTile> _placedTiles = [];

  List<HexPosition> get placedHexes => List.unmodifiable(_placedHexes);
  List<PastureTile> get placedTiles => List.unmodifiable(_placedTiles);

  bool canPlace(PastureTile tile) {
    if (_placedHexes.isEmpty) return true;
    return tile.sharesEdgeWith(_placedHexes) && !tile.overlaps(_placedHexes);
  }

  void placeTile(PastureTile tile) {
    _placedHexes.addAll(tile.hexes);
    _placedTiles.add(tile);
  }

  bool isValidPosition(PastureTile tile, HexPosition offset) {
    final translated = tile.translate(offset);
    return canPlace(translated);
  }

  List<HexPosition> getOuterHexes() {
    final outer = <HexPosition>[];
    for (final hex in _placedHexes) {
      for (final dir in HexPosition.directions) {
        final neighbor = hex + dir;
        if (!_placedHexes.contains(neighbor)) {
          outer.add(hex);
          break;
        }
      }
    }
    return outer;
  }

  void reset() {
    _placedHexes.clear();
    _placedTiles.clear();
  }
}
