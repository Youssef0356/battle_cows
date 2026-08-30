import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:battle_cows/presentation/widgets/hex_board_widget.dart';
import 'package:battle_cows/game/board/board_generator.dart';
import 'package:battle_cows/game/models/player.dart';
import 'package:battle_cows/core/constants/colors.dart';

void main() {
  group('HexBoardWidget', () {
    late var board;

    setUp(() {
      final players = const [
        Player(id: 0, name: 'Blue', color: PlayerColor.blue),
        Player(id: 1, name: 'Red', color: PlayerColor.red),
      ];
      board = BoardGenerator.generate(3, players, 12);
    });

    testWidgets('renders board with hex cells', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HexBoardWidget(
              board: board,
              onCellTap: (pos) {},
            ),
          ),
        ),
      );

      expect(find.byType(HexBoardWidget), findsOneWidget);
    });

    testWidgets('renders with selected position', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HexBoardWidget(
              board: board,
              selectedPosition: board.herds.first.position,
              onCellTap: (pos) {},
            ),
          ),
        ),
      );

      expect(find.byType(HexBoardWidget), findsOneWidget);
    });

    testWidgets('renders with valid moves', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HexBoardWidget(
              board: board,
              validMoves: board.cells.keys.take(3).toList(),
              onCellTap: (pos) {},
            ),
          ),
        ),
      );

      expect(find.byType(HexBoardWidget), findsOneWidget);
    });
  });
}
