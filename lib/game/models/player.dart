import '../../core/constants/colors.dart';

class Player {
  final int id;
  final String name;
  final PlayerColor color;
  final bool isAi;
  final int herdSize;

  const Player({
    required this.id,
    required this.name,
    required this.color,
    this.isAi = false,
    this.herdSize = 12,
  });

  Player copyWith({String? name, bool? isAi, int? herdSize}) {
    return Player(
      id: id,
      name: name ?? this.name,
      color: color,
      isAi: isAi ?? this.isAi,
      herdSize: herdSize ?? this.herdSize,
    );
  }
}
