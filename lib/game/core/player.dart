import 'player_color.dart';

/// Player representation for Battle Cows.
class Player {
  final String id;
  final String name;
  final PlayerColor color;
  final bool isHuman;
  final int trophies;

  const Player({
    required this.id,
    required this.name,
    required this.color,
    this.isHuman = true,
    this.trophies = 1200,
  });

  bool get isAI => !isHuman;

  Player copyWith({
    String? id,
    String? name,
    PlayerColor? color,
    bool? isHuman,
    int? trophies,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isHuman: isHuman ?? this.isHuman,
      trophies: trophies ?? this.trophies,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.name,
    'isHuman': isHuman,
    'trophies': trophies,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      color: PlayerColor.values.byName(json['color'] as String),
      isHuman: json['isHuman'] as bool? ?? true,
      trophies: json['trophies'] as int? ?? 1200,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          color == other.color &&
          isHuman == other.isHuman;

  @override
  int get hashCode => id.hashCode ^ color.hashCode ^ isHuman.hashCode;
}
