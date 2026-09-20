import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battle_cows/data/models/shop_item.dart';
import 'package:battle_cows/data/services/progress_service.dart';
import 'package:battle_cows/presentation/dialogs/shop_dialog.dart';

void main() {
  group('ShopDialog layout', () {
    late ProgressService progress;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      progress = await ProgressService.getInstance();
      progress.progress.coins = 1000;
      progress.progress.ownedItems.clear();
    });

    /// Pumps the shop in a box the size of a phone-sized dialog body.
    /// The test font has square glyphs and 1.0 line height, so [textScale]
    /// emulates a real font (like Bangers) with taller line metrics.
    Future<void> pumpShop(WidgetTester tester, {double textScale = 1.0}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(textScale)),
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 520,
                    child: ShopDialog(progress: progress),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('grid tiles do not overflow their cells', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await pumpShop(tester, textScale: 1.8);

      // A RenderFlex overflow is reported as an exception during pump.
      expect(tester.takeException(), isNull);
      expect(find.text('Cowboy Cow'), findsOneWidget);
    });

    testWidgets('owned and equipped tiles do not overflow their cells', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      progress.buyItem('skin_farmer', 350);
      progress.equipItem('skin_farmer');

      await pumpShop(tester, textScale: 1.8);

      expect(tester.takeException(), isNull);
      expect(find.text('EQUIPPED ✅'), findsOneWidget);
    });

    testWidgets('every shop category lays out without overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await pumpShop(tester, textScale: 1.8);

      for (final category in ShopCategory.values) {
        final tab = find.byKey(ValueKey('shop-tab-${category.name}'));
        await tester.ensureVisible(tab);
        await tester.pump();
        await tester.tap(tab);
        await tester.pump();

        expect(tester.takeException(), isNull, reason: 'overflow in ${category.name}');
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('shop scrolls instead of overflowing on a short screen', (tester) async {
      // Landscape phone: only ~280px of height for the whole dialog.
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => MediaQuery(
                // Keeps the dialog title inside the test font's square glyphs.
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(0.85)),
                child: Center(
                  child: TextButton(
                    onPressed: () =>
                        ShopDialog.show(context: context, progress: progress),
                    child: const Text('OPEN SHOP'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('OPEN SHOP'));
      await tester.pump();
      // CartoonDialog bobs forever, so pumpAndSettle is not an option.
      await tester.pump(const Duration(milliseconds: 350));

      expect(tester.takeException(), isNull);
      expect(find.text('COW BARN SHOP'), findsOneWidget);

      // The shop is taller than the dialog, so it must scroll.
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
      expect(scrollable.position.maxScrollExtent, greaterThan(0));
    });
  });
}