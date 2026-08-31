import 'hex_position.dart';
import 'player_color.dart';

enum CellType { empty, obstacle, claimed }

class HexCell {
  final HexPosition position;
  final CellType type;
  final PlayerColor? owner;
  final int herdSize;

  const HexCell({
    required this.position,
    this.type = CellType.empty,
    this.owner,
    this.herdSize = 0,
  });

  bool get isEmpty => type == CellType.empty;
  bool get isObstacle => type == CellType.obstacle;
  bool get isClaimed => type == CellType.claimed;
  bool get hasHerd => herdSize > 0;

  HexCell copyWith({CellType? type, PlayerColor? owner, int? herdSize}) {
    return HexCell(
      position: position,
      type: type ?? this.type,
      owner: owner,
      herdSize: herdSize ?? this.herdSize,
    );
  }
}
