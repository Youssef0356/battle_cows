import 'dart:math';
import '../models/hex_position.dart';
import '../models/move.dart';
import '../logic/game_engine.dart';
import '../../core/constants/colors.dart';

enum Difficulty { easy, medium, hard }

class AiPlayer {
  final Difficulty difficulty;
  final Random _random = Random();

  AiPlayer({this.difficulty = Difficulty.medium});

  Move? calculateMove(GameEngine engine, PlayerColor playerColor) {
    final validMoves = engine.getValidMoves(playerColor);
    if (validMoves.isEmpty) return null;

    switch (difficulty) {
      case Difficulty.easy:
        return _easyMove(validMoves);
      case Difficulty.medium:
        return _mediumMove(validMoves, engine, playerColor);
      case Difficulty.hard:
        return _hardMove(validMoves, engine, playerColor);
    }
  }

  Move _easyMove(List<Move> validMoves) {
    return validMoves[_random.nextInt(validMoves.length)];
  }

  Move _mediumMove(List<Move> validMoves, GameEngine engine, PlayerColor playerColor) {
    final scoredMoves = validMoves.map((move) {
      var score = 0.0;

      score += _scoreExpansion(move, engine, playerColor);
      score += _scoreBlocking(move, engine, playerColor);

      return _ScoredMove(move, score);
    }).toList();

    scoredMoves.sort((a, b) => b.score.compareTo(a.score));

    final topMoves = scoredMoves.take(3).toList();
    return topMoves[_random.nextInt(topMoves.length)].move;
  }

  Move _hardMove(List<Move> validMoves, GameEngine engine, PlayerColor playerColor) {
    final scoredMoves = validMoves.map((move) {
      var score = 0.0;

      score += _scoreExpansion(move, engine, playerColor) * 1.5;
      score += _scoreBlocking(move, engine, playerColor) * 2.0;
      score += _scoreCenterControl(move, engine) * 1.0;
      score += _scoreStackPreservation(move) * 0.5;

      return _ScoredMove(move, score);
    }).toList();

    scoredMoves.sort((a, b) => b.score.compareTo(a.score));
    return scoredMoves.first.move;
  }

  double _scoreExpansion(Move move, GameEngine engine, PlayerColor playerColor) {
    final board = engine.board;
    if (board == null) return 0;

    var newTiles = 0;
    for (final dir in HexPosition.directions) {
      var current = move.to;
      for (var i = 0; i < move.splitCount; i++) {
        final next = current + dir;
        if (board.isValidPosition(next) && board.isEmpty(next)) {
          newTiles++;
        }
        current = next;
      }
    }

    return newTiles.toDouble();
  }

  double _scoreBlocking(Move move, GameEngine engine, PlayerColor playerColor) {
    final board = engine.board;
    if (board == null) return 0;

    var blockingScore = 0.0;

    for (final herd in board.herds) {
      if (herd.owner != playerColor) {
        final distance = move.to.distanceTo(herd.position);
        if (distance <= 2) {
          blockingScore += 3.0;
        } else if (distance <= 3) {
          blockingScore += 1.0;
        }
      }
    }

    return blockingScore;
  }

  double _scoreCenterControl(Move move, GameEngine engine) {
    final center = HexPosition(0, 0);
    final distance = move.to.distanceTo(center);
    return (10 - distance).toDouble().clamp(0, 10);
  }

  double _scoreStackPreservation(Move move) {
    if (move.stayCount >= 3) return 2.0;
    if (move.stayCount >= 2) return 1.0;
    return 0.0;
  }
}

class _ScoredMove {
  final Move move;
  final double score;

  _ScoredMove(this.move, this.score);
}
