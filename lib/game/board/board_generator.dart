import 'dart:math';
import '../models/hex_position.dart';
import '../models/hex_cell.dart';
import '../models/herd.dart';
import '../models/player.dart';
import '../models/game_board.dart';

class BoardGenerator {
  static GameBoard generate(int size, List<Player> players, int herdSize) {
    final cells = <HexPosition, HexCell>{};

    for (var q = -size; q <= size; q++) {
      for (var r = -size; r <= size; r++) {
        final s = -q - r;
        if (s.abs() <= size) {
          cells[HexPosition(q, r)] = HexCell(position: HexPosition(q, r));
        }
      }
    }

    _addObstacles(cells, size);

    final herds = _placeStartingHerds(cells, players, herdSize, size);

    return GameBoard(size: size, cells: cells, herds: herds);
  }

  static void _addObstacles(Map<HexPosition, HexCell> cells, int size) {
    final random = Random();
    final obstacleCount = (cells.length * 0.08).round();
    final positions = cells.keys.toList();

    var placed = 0;
    while (placed < obstacleCount && positions.isNotEmpty) {
      final pos = positions[random.nextInt(positions.length)];
      if (!cells[pos]!.isObstacle) {
        cells[pos] = cells[pos]!.copyWith(type: CellType.obstacle);
        placed++;
      }
      positions.remove(pos);
    }
  }

  static List<Herd> _placeStartingHerds(
    Map<HexPosition, HexCell> cells,
    List<Player> players,
    int herdSize,
    int size,
  ) {
    final herds = <Herd>[];
    final startPositions = _getStartingPositions(players.length, size);

    for (var i = 0; i < players.length; i++) {
      final pos = startPositions[i];
      herds.add(Herd(position: pos, owner: players[i].color, size: herdSize));
    }

    return herds;
  }

  static List<HexPosition> _getStartingPositions(int playerCount, int size) {
    final positions = <HexPosition>[];

    switch (playerCount) {
      case 2:
        positions.add(HexPosition(-size, 0));
        positions.add(HexPosition(size, 0));
        break;
      case 3:
        positions.add(HexPosition(-size, 0));
        positions.add(HexPosition(0, -size));
        positions.add(HexPosition(size, 0));
        break;
      case 4:
        positions.add(HexPosition(-size, 0));
        positions.add(HexPosition(0, -size));
        positions.add(HexPosition(size, 0));
        positions.add(HexPosition(0, size));
        break;
    }

    return positions;
  }
}
