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

    test('equipItem routes items into their category slot', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await ProgressService.getInstance();
      progress.progress.coins = 5000;
      progress.buyItem('hat_crown', 500);
      progress.buyItem('skin_disco', 500);
      progress.buyItem('theme_field', 450);

      progress.equipItem('hat_crown');
      expect(progress.progress.equippedHat, 'hat_crown');
      expect(progress.progress.equippedSkin, '');
      expect(progress.isEquipped('hat_crown'), isTrue);

      progress.equipItem('skin_disco');
      expect(progress.progress.equippedSkin, 'skin_disco');

      progress.equipItem('theme_field');
      expect(progress.progress.equippedTheme, 'theme_field');
      expect(progress.equippedThemeAsset, isNotNull);
    });

    test('equipping an already equipped item unequips it', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await ProgressService.getInstance();
      progress.progress.coins = 1000;
      progress.buyItem('hat_crown', 500);

      progress.equipItem('hat_crown');
      expect(progress.isEquipped('hat_crown'), isTrue);

      progress.equipItem('hat_crown');
      expect(progress.progress.equippedHat, '');
      expect(progress.isEquipped('hat_crown'), isFalse);
    });

    test('recordMatch awards coins for playing, winning and capturing',
        () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await ProgressService.getInstance();
      expect(progress.progress.coins, 0);

      final earned = progress.recordMatch(won: true, captures: 4);
      expect(
        earned,
        ProgressService.coinsPerMatchPlayed +
            ProgressService.coinsPerMatchWon +
            4 * ProgressService.coinsPerCapture,
      );
      expect(progress.progress.coins, earned);
    });

    test('recordMatch awards fewer coins on a loss', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await ProgressService.getInstance();

      final earned = progress.recordMatch(won: false, captures: 0);
      expect(earned, ProgressService.coinsPerMatchPlayed);
      expect(progress.progress.coins, ProgressService.coinsPerMatchPlayed);
    });

    test('daily login grants coins once per day', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await ProgressService.getInstance();

      progress.checkDailyLogin();
      expect(progress.progress.dailyStreak, 1);
      expect(progress.progress.coins, progress.dailyLoginReward(1));

      // Opening again the same day must not pay out twice.
      progress.checkDailyLogin();
      expect(progress.progress.coins, progress.dailyLoginReward(1));
    });

    test('legacy theme/board ids migrate to the new catalog', () async {
      SharedPreferences.setMockInitialValues({
        'player_progress':
            '{"coins":0,"ownedItems":["theme_sunset","board_marble"],'
                '"equippedTheme":"theme_sunset"}',
      });
      final progress = await ProgressService.getInstance();

      expect(progress.progress.ownedItems, contains('theme_field'));
      expect(progress.progress.ownedItems, contains('board_meadow'));
      expect(progress.progress.ownedItems, isNot(contains('theme_sunset')));
      expect(progress.progress.equippedTheme, 'theme_field');
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