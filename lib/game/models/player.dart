import 'player_color.dart';
import '../ai/ai_player.dart';

class Player {
  final int id;
  final String name;
  final PlayerColor color;
  final bool isAi;
  final int herdSize;
  final Difficulty? difficulty;

  const Player({
    required this.id,
    required this.name,
    required this.color,
    this.isAi = false,
    this.herdSize = 12,
    this.difficulty,
  });

  Player copyWith({String? name, bool? isAi, int? herdSize, Difficulty? difficulty}) {
    return Player(
      id: id,
      name: name ?? this.name,
      color: color,
      isAi: isAi ?? this.isAi,
      herdSize: herdSize ?? this.herdSize,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
