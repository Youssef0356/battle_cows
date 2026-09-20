import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/flame/battle_cows_game.dart';

void main() {
  group('BattleCowsGame.hexSizeFor', () {
    const side = 400.0;

    test('small pasture (boardSize 7) keeps the original density of 14', () {
      expect(
        BattleCowsGame.hexSizeFor(shortestSide: side, boardSize: 7),
        closeTo(side * .94 / 14, 0.0001),
      );
    });

    test('hex size grows as the pasture setting grows', () {
      double sizeFor(int boardSize) => BattleCowsGame.hexSizeFor(
            shortestSide: side,
            boardSize: boardSize,
          );
      final small = sizeFor(7);
      final medium = sizeFor(9);
      final large = sizeFor(11);
      expect(medium, greaterThan(small));
      expect(large, greaterThan(medium));
    });

    test('densities are 14 / 12 / 10 for boardSize 7 / 9 / 11', () {
      double sizeFor(int boardSize) => BattleCowsGame.hexSizeFor(
            shortestSide: side,
            boardSize: boardSize,
          );
      expect(sizeFor(7) * 14, closeTo(side * .94, 0.0001));
      expect(sizeFor(9) * 12, closeTo(side * .94, 0.0001));
      expect(sizeFor(11) * 10, closeTo(side * .94, 0.0001));
    });

    test('unexpected board sizes fall back to the 10–14 density range', () {
      expect(
        BattleCowsGame.hexSizeFor(shortestSide: side, boardSize: 4),
        closeTo(side * .94 / 14, 0.0001),
      );
      expect(
        BattleCowsGame.hexSizeFor(shortestSide: side, boardSize: 14),
        closeTo(side * .94 / 10, 0.0001),
      );
    });

    test('zero-size viewport falls back to 30', () {
      expect(
        BattleCowsGame.hexSizeFor(shortestSide: 0, boardSize: 11),
        30.0,
      );
    });
  });
}