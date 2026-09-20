import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/data/models/shop_item.dart';
import 'package:battle_cows/game/models/player_color.dart';
import 'package:battle_cows/game/utils/cow_skin_loader.dart';

void main() {
  group('Shop catalog integrity', () {
    test('no duplicate item ids', () {
      final ids = shopItems.map((i) => i.id).toList();
      expect(ids.length, ids.toSet().length, reason: 'duplicate ids: $ids');
    });

    test('no duplicate item names within a category', () {
      for (final category in ShopCategory.values) {
        final names = shopItems
            .where((i) => i.category == category)
            .map((i) => i.name)
            .toList();
        expect(
          names.length,
          names.toSet().length,
          reason: 'duplicate names in ${category.name}: $names',
        );
      }
    });

    test('every skin item maps to a real cow asset via its id', () {
      final skins = shopItems
          .where((i) => i.category == ShopCategory.skins)
          .toList();
      expect(skins, isNotEmpty);
      for (final item in skins) {
        expect(item.imageAsset, isNotNull, reason: '${item.id} has no image');
        expect(item.imageAsset, startsWith('assets/images/Cows/cow_'));
        final stem = item.imageAsset!.split('cow_').last.split('.').first;
        expect(item.id, 'skin_$stem');
      }
    });

    test('every skin resolves through CowSkins.assetFor', () {
      for (final item in shopItems
          .where((i) => i.category == ShopCategory.skins)) {
        final asset = CowSkins.assetFor(PlayerColor.blue, skinId: item.id);
        expect(asset, item.imageAsset);
      }
    });

    test('unknown or empty skin ids fall back to color art', () {
      expect(
        CowSkins.assetFor(PlayerColor.blue, skinId: ''),
        CowSkins.byColor[PlayerColor.blue],
      );
      expect(
        CowSkins.assetFor(PlayerColor.red, skinId: 'hat_crown'),
        CowSkins.byColor[PlayerColor.red],
      );
      expect(
        CowSkins.assetFor(PlayerColor.red),
        CowSkins.byColor[PlayerColor.red],
      );
    });

    test('each player color has color art', () {
      for (final color in PlayerColor.values) {
        expect(CowSkins.byColor[color], isNotNull);
      }
    });
  });
}