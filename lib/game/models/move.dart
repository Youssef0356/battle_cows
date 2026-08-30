import 'hex_position.dart';
import '../../core/constants/colors.dart';

enum MoveType { split, move }

class Move {
  final HexPosition from;
  final HexPosition to;
  final int splitCount;
  final int stayCount;
  final PlayerColor player;

  const Move({
    required this.from,
    required this.to,
    required this.splitCount,
    required this.stayCount,
    required this.player,
  });

  @override
  String toString() => 'Move($player: $from -> $to, split=$splitCount, stay=$stayCount)';
}
