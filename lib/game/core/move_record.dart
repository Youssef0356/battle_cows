import '../board/hex_coordinate.dart';
import 'player_color.dart';

/// Serializable record of a player's movement action.
class MoveRecord {
  final PlayerColor playerColor;
  final HexCoordinate source;
  final HexCoordinate destination;
  final int count;
  final DateTime timestamp;

  MoveRecord({
    required this.playerColor,
    required this.source,
    required this.destination,
    required this.count,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'playerColor': playerColor.name,
    'source': source.toJson(),
    'destination': destination.toJson(),
    'count': count,
    'timestamp': timestamp.toIso8601String(),
  };

  factory MoveRecord.fromJson(Map<String, dynamic> json) {
    return MoveRecord(
      playerColor: PlayerColor.values.byName(json['playerColor'] as String),
      source: HexCoordinate.fromJson(json['source'] as Map<String, dynamic>),
      destination: HexCoordinate.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      count: json['count'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() =>
      'MoveRecord($playerColor: $count cows $source -> $destination)';
}
