import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/presentation/widgets/hex_cell_widget.dart';
import 'package:battle_cows/game/models/hex_position.dart';
import 'package:battle_cows/game/models/hex_cell.dart';
import 'package:battle_cows/game/models/herd.dart';
import 'package:battle_cows/core/constants/colors.dart';

void main() {
  group('HexCellWidget', () {
    testWidgets('renders empty cell', (WidgetTester tester) async {
      final cell = HexCell(position: const HexPosition(0, 0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HexCellWidget(
              size: 50,
              cell: cell,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(HexCellWidget), findsOneWidget);
    });

    testWidgets('renders cell with herd', (WidgetTester tester) async {
      final cell = HexCell(position: const HexPosition(0, 0));
      final herd = Herd(
        position: const HexPosition(0, 0),
        owner: PlayerColor.blue,
        size: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HexCellWidget(
              size: 50,
              cell: cell,
              herd: herd,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(HexCellWidget), findsOneWidget);
    });

    testWidgets('renders obstacle cell', (WidgetTester tester) async {
      final cell = HexCell(
        position: const HexPosition(0, 0),
        type: CellType.obstacle,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HexCellWidget(
              size: 50,
              cell: cell,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(HexCellWidget), findsOneWidget);
    });

    testWidgets('renders selected cell', (WidgetTester tester) async {
      final cell = HexCell(position: const HexPosition(0, 0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HexCellWidget(
              size: 50,
              cell: cell,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(HexCellWidget), findsOneWidget);
    });

    testWidgets('renders valid move cell', (WidgetTester tester) async {
      final cell = HexCell(position: const HexPosition(0, 0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HexCellWidget(
              size: 50,
              cell: cell,
              isValidMove: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(HexCellWidget), findsOneWidget);
    });

    testWidgets('tap triggers callback', (WidgetTester tester) async {
      bool tapped = false;
      final cell = HexCell(position: const HexPosition(0, 0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HexCellWidget(
              size: 50,
              cell: cell,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HexCellWidget));
      expect(tapped, true);
    });
  });
}
