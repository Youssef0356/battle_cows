import 'hex_position.dart';
import 'hex_cell.dart';
import 'herd.dart';
import 'pasture_tile.dart';

class GameBoard {
  final Map<HexPosition, HexCell> cells;
  final List<Herd> herds;

  const GameBoard({
    required this.cells,
    required this.herds,
  });

  factory GameBoard.fromTiles(List<PastureTile> tiles, List<Herd> initialHerds) {
    final cells = <HexPosition, HexCell>{};

    for (final tile in tiles) {
      for (final hex in tile.hexes) {
        cells[hex] = HexCell(position: hex);
      }
    }

    return GameBoard(cells: cells, herds: initialHerds);
  }

  HexCell? getCell(HexPosition pos) => cells[pos];

  bool isValidPosition(HexPosition pos) => cells.containsKey(pos);

  bool isEmpty(HexPosition pos) {
    final cell = cells[pos];
    return cell != null && cell.isEmpty && !hasHerdAt(pos);
  }

  bool isHole(HexPosition pos) => !cells.containsKey(pos);

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
        if (isHole(next)) break;
        if (hasHerdAt(next)) break;
        reachable.add(next);
        current = next;
      }
    }
    return reachable;
  }

  int getContiguousGroupSize(HexPosition start) {
    if (!hasHerdAt(start)) return 0;

    final visited = <HexPosition>{};
    final queue = [start];
    final herd = getHerdAt(start);
    if (herd == null) return 0;

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (visited.contains(current)) continue;
      visited.add(current);

      final currentHerd = getHerdAt(current);
      if (currentHerd == null || currentHerd.owner != herd.owner) continue;

      for (final dir in HexPosition.directions) {
        final neighbor = current + dir;
        if (!visited.contains(neighbor) && isValidPosition(neighbor)) {
          queue.add(neighbor);
        }
      }
    }

    return visited.length;
  }
}
