import 'hex_position.dart';
import 'hex_cell.dart';
import 'herd.dart';

class GameBoard {
  final int size;
  final Map<HexPosition, HexCell> cells;
  final List<Herd> herds;

  const GameBoard({
    required this.size,
    required this.cells,
    required this.herds,
  });

  HexCell? getCell(HexPosition pos) => cells[pos];

  bool isValidPosition(HexPosition pos) => cells.containsKey(pos);

  bool isEmpty(HexPosition pos) {
    final cell = cells[pos];
    return cell != null && cell.isEmpty && !hasHerdAt(pos);
  }

  bool hasHerdAt(HexPosition pos) => herds.any((h) => h.position == pos);

  Herd? getHerdAt(HexPosition pos) {
    try {
      return herds.firstWhere((h) => h.position == pos);
    } catch (_) {
      return null;
    }
  }

  List<HexPosition> getReachablePositions(HexPosition from, int maxDistance) {
    final reachable = <HexPosition>[];
    for (final dir in HexPosition.directions) {
      var current = from;
      for (var i = 0; i < maxDistance; i++) {
        final next = current + dir;
        if (!isValidPosition(next)) break;
        final cell = cells[next];
        if (cell == null || cell.isObstacle) break;
        if (hasHerdAt(next)) break;
        reachable.add(next);
        current = next;
      }
    }
    return reachable;
  }
}
