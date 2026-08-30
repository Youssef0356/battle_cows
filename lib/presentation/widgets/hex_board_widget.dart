import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../game/models/hex_position.dart';
import '../../game/models/game_board.dart';
import 'hex_cell_widget.dart';

class HexBoardWidget extends StatefulWidget {
  final GameBoard board;
  final HexPosition? selectedPosition;
  final List<HexPosition> validMoves;
  final Function(HexPosition) onCellTap;
  final dynamic currentPlayerColor;

  const HexBoardWidget({
    super.key,
    required this.board,
    this.selectedPosition,
    this.validMoves = const [],
    required this.onCellTap,
    this.currentPlayerColor,
  });

  @override
  State<HexBoardWidget> createState() => _HexBoardWidgetState();
}

class _HexBoardWidgetState extends State<HexBoardWidget> with SingleTickerProviderStateMixin {
  ui.Image? _texture;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadTexture();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(HexBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.board != widget.board) {
      _loadTexture();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadTexture() async {
    try {
      final data = await rootBundle.load('assets/images/Tile Image/Tile Texture.png');
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _texture = frame.image;
        });
      }
    } catch (e) {
      // Fallback: texture will be null, painter uses solid color
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final hexSize = size / 20;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) {
                return Stack(
                  children: _buildHexGrid(hexSize),
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildHexGrid(double hexSize) {
    final widgets = <Widget>[];

    for (final entry in widget.board.cells.entries) {
      final pos = entry.key;
      final cell = entry.value;
      final herd = widget.board.getHerdAt(pos);

      final pixelPos = _hexToPixel(pos, hexSize);
      final isSelected = widget.selectedPosition == pos;
      final isValidMove = widget.validMoves.contains(pos);
      final flipMode = HexCellWidget.getFlipMode(pos.q, pos.r);

      widgets.add(
        Positioned(
          left: pixelPos.dx - hexSize,
          top: pixelPos.dy - hexSize,
          child: HexCellWidget(
            size: hexSize * 2,
            cell: cell,
            herd: herd,
            isSelected: isSelected,
            isValidMove: isValidMove,
            texture: _texture,
            flipMode: flipMode,
            pulseValue: isSelected ? _pulseAnimation.value : 0.0,
            onTap: () => widget.onCellTap(pos),
          ),
        ),
      );
    }

    return widgets;
  }

  Offset _hexToPixel(HexPosition hex, double size) {
    final x = size * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
    final y = size * (3.0 / 2 * hex.r);
    return Offset(x + size * 12, y + size * 12);
  }
}
