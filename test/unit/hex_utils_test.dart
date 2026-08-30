import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/game/models/hex_position.dart';

void main() {
  group('HexPosition', () {
    test('creates with correct q and r values', () {
      const pos = HexPosition(3, -2);
      expect(pos.q, 3);
      expect(pos.r, -2);
      expect(pos.s, -1);
    });

    test('s is always -q - r', () {
      const pos = HexPosition(1, 2);
      expect(pos.s, -3);

      const pos2 = HexPosition(-4, 0);
      expect(pos2.s, 4);

      const pos3 = HexPosition(0, 0);
      expect(pos3.s, 0);
    });

    test('addition works correctly', () {
      const a = HexPosition(1, 2);
      const b = HexPosition(3, -1);
      final result = a + b;
      expect(result, const HexPosition(4, 1));
    });

    test('subtraction works correctly', () {
      const a = HexPosition(5, 3);
      const b = HexPosition(2, 1);
      final result = a - b;
      expect(result, const HexPosition(3, 2));
    });

    test('multiplication works correctly', () {
      const pos = HexPosition(2, -1);
      final result = pos * 3;
      expect(result, const HexPosition(6, -3));
    });

    test('equality works for same positions', () {
      const a = HexPosition(1, 2);
      const b = HexPosition(1, 2);
      expect(a, equals(b));
    });

    test('equality fails for different positions', () {
      const a = HexPosition(1, 2);
      const b = HexPosition(2, 1);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent for equal positions', () {
      const a = HexPosition(3, -1);
      const b = HexPosition(3, -1);
      expect(a.hashCode, b.hashCode);
    });

    test('distanceTo returns correct distance', () {
      const origin = HexPosition(0, 0);
      const neighbor = HexPosition(1, 0);
      expect(origin.distanceTo(neighbor), 1.0);

      const far = HexPosition(2, -1);
      expect(origin.distanceTo(far), 2.0);
    });

    test('neighbors returns 6 adjacent hexes', () {
      const pos = HexPosition(0, 0);
      final neighbors = pos.neighbors();
      expect(neighbors.length, 6);
      expect(neighbors, contains(const HexPosition(1, 0)));
      expect(neighbors, contains(const HexPosition(1, -1)));
      expect(neighbors, contains(const HexPosition(0, -1)));
      expect(neighbors, contains(const HexPosition(-1, 0)));
      expect(neighbors, contains(const HexPosition(-1, 1)));
      expect(neighbors, contains(const HexPosition(0, 1)));
    });

    test('directions has 6 entries', () {
      expect(HexPosition.directions.length, 6);
    });

    test('toString returns readable format', () {
      const pos = HexPosition(2, -3);
      expect(pos.toString(), '(2, -3)');
    });
  });
}
