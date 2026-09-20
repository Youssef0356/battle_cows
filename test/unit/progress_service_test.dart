import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battle_cows/data/services/progress_service.dart';

void main() {
  group('ProgressService shop logic', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      ProgressService.resetInstance();
    });

    test('buyItem deducts coins and records ownership', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await ProgressService.getInstance();
      progress.progress.coins = 1000;

      expect(progress.buyItem('skin_viking', 450), isTrue);
      expect(progress.progress.coins, 550);
      expect(progress.progress.ownedItems, contains('skin_viking'));
      expect(progress.buyItem('skin_viking', 450), isFalse);
    });

    test('equipItem only accepts skins', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await ProgressService.getInstance();
      progress.progress.coins = 2000;
      progress.buyItem('hat_crown', 500);
      progress.buyItem('skin_disco', 500);

      progress.equipItem('hat_crown');
      expect(progress.progress.equippedSkin, '');

      progress.equipItem('skin_disco');
      expect(progress.progress.equippedSkin, 'skin_disco');
    });

    test('legacy COWS purchases migrate to the skins section', () async {
      // Pre-consolidation save: duplicate cow ids + an unequipped legacy
      // skin id. cow_robot has no art in the project, so it is dropped.
      SharedPreferences.setMockInitialValues({
        'player_progress':
            '{"coins":100,"ownedItems":["cow_cowboy","cow_robot"]}',
      });
      final progress = await ProgressService.getInstance();

      expect(progress.progress.ownedItems, contains('skin_cowboy'));
      expect(progress.progress.ownedItems, isNot(contains('cow_cowboy')));
      expect(progress.progress.ownedItems, isNot(contains('cow_robot')));
    });

    test('legacy equipped skin remaps when its cow was owned', () async {
      SharedPreferences.setMockInitialValues({
        'player_progress':
            '{"coins":0,"ownedItems":["cow_viking"],"equippedSkin":"cow_viking"}',
      });
      final progress = await ProgressService.getInstance();

      expect(progress.progress.ownedItems, contains('skin_viking'));
      expect(progress.progress.equippedSkin, 'skin_viking');
    });

    test('legacy equipped skin clears when its cow was not owned', () async {
      SharedPreferences.setMockInitialValues({
        'player_progress':
            '{"coins":0,"ownedItems":["cow_disco"],"equippedSkin":"cow_viking"}',
      });
      final progress = await ProgressService.getInstance();

      expect(progress.progress.ownedItems, contains('skin_disco'));
      expect(progress.progress.equippedSkin, '');
    });
  });
}