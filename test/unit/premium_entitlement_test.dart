import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battle_cows/ads/ad_manager.dart';
import 'package:battle_cows/data/services/premium_service.dart';
import 'package:battle_cows/data/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ProgressService.resetInstance();
    PremiumService.instance.resetForTesting();
  });

  tearDown(() {
    AdManager().setAdsEnabled(true);
  });

  group('premium entitlement', () {
    test('is off by default', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await ProgressService.getInstance();
      expect(progress.isPremium, isFalse);
    });

    test('unlockPremium persists across reloads', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await ProgressService.getInstance();
      progress.unlockPremium();
      expect(progress.isPremium, isTrue);

      ProgressService.resetInstance();
      final reloaded = await ProgressService.getInstance();
      expect(reloaded.isPremium, isTrue);
    });

    test('loading a premium entitlement disables ads', () async {
      SharedPreferences.setMockInitialValues({
        'player_progress': '{"isPremium":true}',
      });
      await PremiumService.instance.loadEntitlement();

      expect(PremiumService.instance.isPremium, isTrue);
      expect(AdManager().adsEnabled, isFalse);
    });

    test('free players keep ads enabled', () async {
      SharedPreferences.setMockInitialValues({});
      await PremiumService.instance.loadEntitlement();

      expect(PremiumService.instance.isPremium, isFalse);
      expect(AdManager().adsEnabled, isTrue);
    });
  });
}
