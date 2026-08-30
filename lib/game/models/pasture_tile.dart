import 'hex_position.dart';

class PastureTile {
  final int id;
  final List<HexPosition> hexes;

  const PastureTile({
    required this.id,
    required this.hexes,
  });

  static PastureTile diamond(int id, HexPosition center) {
    return PastureTile(
      id: id,
      hexes: [
        center,
        center + const HexPosition(1, 0),
        center + const HexPosition(0, 1),
        center + const HexPosition(1, -1),
      ],
    );
  }

  PastureTile translate(HexPosition offset) {
    return PastureTile(
      id: id,
      hexes: hexes.map((h) => h + offset).toList(),
    );
  }

  bool sharesEdgeWith(List<HexPosition> boardHexes) {
    for (final hex in hexes) {
      for (final dir in HexPosition.directions) {
        final neighbor = hex + dir;
        if (boardHexes.contains(neighbor)) {
          return true;
        }
      }
    }
    return false;
  }

  bool overlaps(List<HexPosition> existing) {
    return hexes.any((h) => existing.contains(h));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PastureTile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
