import 'hex_position.dart';
import 'player_color.dart';

class Herd {
  final HexPosition position;
  final PlayerColor owner;
  final int size;

  const Herd({
    required this.position,
    required this.owner,
    required this.size,
  });

  Herd copyWith({HexPosition? position, int? size}) {
    return Herd(
      position: position ?? this.position,
      owner: owner,
      size: size ?? this.size,
    );
  }

  bool get isTrapped => false;
}
