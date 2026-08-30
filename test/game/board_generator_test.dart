import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/game/models/hex_position.dart';
import 'package:battle_cows/game/models/pasture_tile.dart';
import 'package:battle_cows/game/board/board_builder.dart';

void main() {
  group('BoardBuilder', () {
    late BoardBuilder builder;

    setUp(() {
      builder = BoardBuilder();
    });

    test('starts empty', () {
      expect(builder.placedHexes, isEmpty);
      expect(builder.placedTiles, isEmpty);
    });

    test('can place first tile anywhere', () {
      final tile = PastureTile.diamond(0, const HexPosition(0, 0));
      expect(builder.canPlace(tile), true);
    });

    test('places tile correctly', () {
      final tile = PastureTile.diamond(0, const HexPosition(0, 0));
      builder.placeTile(tile);
      expect(builder.placedTiles.length, 1);
      expect(builder.placedHexes.length, 4);
    });

    test('cannot place overlapping tile', () {
      final tile1 = PastureTile.diamond(0, const HexPosition(0, 0));
      final tile2 = PastureTile.diamond(1, const HexPosition(0, 0));
      builder.placeTile(tile1);
      expect(builder.canPlace(tile2), false);
    });

    test('can place adjacent tile', () {
      final tile1 = PastureTile.diamond(0, const HexPosition(0, 0));
      final tile2 = PastureTile.diamond(1, const HexPosition(2, 0));
      builder.placeTile(tile1);
      expect(builder.canPlace(tile2), true);
    });

    test('cannot place disconnected tile', () {
      final tile1 = PastureTile.diamond(0, const HexPosition(0, 0));
      final tile2 = PastureTile.diamond(1, const HexPosition(10, 10));
      builder.placeTile(tile1);
      expect(builder.canPlace(tile2), false);
    });

    test('getOuterHexes returns perimeter hexes', () {
      final tile = PastureTile.diamond(0, const HexPosition(0, 0));
      builder.placeTile(tile);
      final outer = builder.getOuterHexes();
      expect(outer, isNotEmpty);
      expect(outer.length, greaterThan(0));
    });

    test('reset clears everything', () {
      final tile = PastureTile.diamond(0, const HexPosition(0, 0));
      builder.placeTile(tile);
      builder.reset();
      expect(builder.placedHexes, isEmpty);
      expect(builder.placedTiles, isEmpty);
    });
  });

  group('PastureTile', () {
    test('diamond creates 4 hexes', () {
      final tile = PastureTile.diamond(0, const HexPosition(0, 0));
      expect(tile.hexes.length, 4);
    });

    test('translate moves all hexes', () {
      final tile = PastureTile.diamond(0, const HexPosition(0, 0));
      final translated = tile.translate(const HexPosition(2, 3));
      expect(translated.hexes.first, const HexPosition(2, 3));
    });

    test('sharesEdgeWith detects adjacency', () {
      final tile1 = PastureTile.diamond(0, const HexPosition(0, 0));
      final tile2 = PastureTile.diamond(1, const HexPosition(2, 0));
      expect(tile2.sharesEdgeWith(tile1.hexes), true);
    });

    test('overlaps detects collision', () {
      final tile1 = PastureTile.diamond(0, const HexPosition(0, 0));
      final tile2 = PastureTile.diamond(1, const HexPosition(0, 0));
      expect(tile2.overlaps(tile1.hexes), true);
    });
  });
}
