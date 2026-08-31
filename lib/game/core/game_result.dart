import 'player_color.dart';

/// Represents the final outcome of a Battle Cows match.
class GameResult {
  final PlayerColor? winner;
  final bool isDraw;
  final Map<PlayerColor, int> scores;
  final int totalTurns;

  const GameResult({
    required this.winner,
    required this.isDraw,
    required this.scores,
    required this.totalTurns,
  });

  factory GameResult.draw({
    required Map<PlayerColor, int> scores,
    required int totalTurns,
  }) {
    return GameResult(
      winner: null,
      isDraw: true,
      scores: scores,
      totalTurns: totalTurns,
    );
  }

  factory GameResult.victory({
    required PlayerColor winner,
    required Map<PlayerColor, int> scores,
    required int totalTurns,
  }) {
    return GameResult(
      winner: winner,
      isDraw: false,
      scores: scores,
      totalTurns: totalTurns,
    );
  }

  Map<String, dynamic> toJson() => {
    'winner': winner?.name,
    'isDraw': isDraw,
    'scores': scores.map((k, v) => MapEntry(k.name, v)),
    'totalTurns': totalTurns,
  };

  factory GameResult.fromJson(Map<String, dynamic> json) {
    final winnerStr = json['winner'] as String?;
    final rawScores = json['scores'] as Map<String, dynamic>? ?? {};
    final scores = rawScores.map(
      (k, v) => MapEntry(PlayerColor.values.byName(k), v as int),
    );
    return GameResult(
      winner: winnerStr != null ? PlayerColor.values.byName(winnerStr) : null,
      isDraw: json['isDraw'] as bool? ?? false,
      scores: scores,
      totalTurns: json['totalTurns'] as int? ?? 0,
    );
  }
}
