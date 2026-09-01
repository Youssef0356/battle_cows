import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../core/constants/colors.dart';
import '../../core/theme/game_button_styles.dart';
import '../../game/models/hex_position.dart';
import '../../game/models/pasture_tile.dart';
import '../../game/board/board_builder.dart';
import '../../game/board/board_generator.dart';
import '../../game/models/player.dart';
import '../router/app_router.dart';

class TilePlacementScreen extends StatefulWidget {
  final List<Player> players;
  final int tilesPerPlayer;

  const TilePlacementScreen({
    super.key,
    required this.players,
    this.tilesPerPlayer = 4,
  });

  @override
  State<TilePlacementScreen> createState() => _TilePlacementScreenState();
}

class _TilePlacementScreenState extends State<TilePlacementScreen> with TickerProviderStateMixin {
  final BoardBuilder _builder = BoardBuilder();
  final GlobalKey _boardKey = GlobalKey();
  late List<int> _tilesRemaining;
  int _currentPlayerIndex = 0;
  PastureTile? _currentTile;
  HexPosition _tileOffset = const HexPosition(0, 0);
  bool _isDragging = false;
  Offset _dragPosition = Offset.zero;
  ui.Image? _texture;

  late AnimationController _dropAnimController;
  late Animation<double> _dropScaleAnimation;
  bool _showDropAnim = false;
  List<HexPosition> _dropAnimatingHexes = [];

  @override
  void initState() {
    super.initState();
    _tilesRemaining = List.filled(widget.players.length, widget.tilesPerPlayer);
    _generateNewTile();
    _loadTexture();

    _dropAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _dropScaleAnimation = Tween<double>(begin: 1.4, end: 1.0).animate(
      CurvedAnimation(parent: _dropAnimController, curve: Curves.elasticOut),
    );

    if (_currentPlayer.isAi) {
      _scheduleAiPlacement();
    }
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
    } catch (_) {}
  }

  void _generateNewTile() {
    final tileIndex = _builder.placedTiles.length;
    _currentTile = PastureTile.diamond(tileIndex, const HexPosition(0, 0));
    _tileOffset = const HexPosition(0, 0);

    // Default offset to adjacent position if board already has hexes
    if (_builder.placedHexes.isNotEmpty) {
      final outer = BoardGenerator.getOuterHexes(_builder.placedHexes);
      if (outer.isNotEmpty) {
        for (final hex in outer) {
          for (final dir in HexPosition.directions) {
            final testOffset = hex + dir;
            final candidate = _currentTile!.translate(testOffset);
            if (_builder.canPlace(candidate)) {
              _tileOffset = testOffset;
              return;
            }
          }
        }
      }
    }
  }

  Player get _currentPlayer => widget.players[_currentPlayerIndex];

  bool get _allTilesPlaced => _tilesRemaining.every((count) => count == 0);

  void _rotateTile() {
    if (_currentTile == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentTile = _currentTile!.rotate(1);
    });
  }

  bool _tryPlaceTile() {
    if (_currentTile == null) return false;

    final translated = _currentTile!.translate(_tileOffset);
    if (_builder.canPlace(translated)) {
      HapticFeedback.mediumImpact();
      _dropAnimatingHexes = List.from(translated.hexes);
      _showDropAnim = true;
      _dropAnimController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _showDropAnim = false;
            _dropAnimatingHexes = [];
          });
        }
      });

      setState(() {
        _builder.placeTile(translated);
        _tilesRemaining[_currentPlayerIndex]--;

        if (!_allTilesPlaced) {
          _advancePlayer();
          _generateNewTile();
        } else {
          _currentTile = null;
        }
      });
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _dropAnimController.dispose();
    super.dispose();
  }

  void _advancePlayer() {
    do {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % widget.players.length;
    } while (_tilesRemaining[_currentPlayerIndex] == 0 && !_allTilesPlaced);

    if (!_allTilesPlaced && _currentPlayer.isAi) {
      _scheduleAiPlacement();
    }
  }

  void _scheduleAiPlacement() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || _allTilesPlaced || !_currentPlayer.isAi) return;
      _performAiTilePlacement();
    });
  }

  void _performAiTilePlacement() {
    final existing = _builder.placedHexes;
    if (existing.isEmpty) {
      _currentTile = PastureTile.diamond(_builder.placedTiles.length, const HexPosition(0, 0));
      _tileOffset = const HexPosition(0, 0);
      _tryPlaceTile();
      return;
    }

    final outer = BoardGenerator.getOuterHexes(existing);
    final random = Random();
    final candidateOffsets = <HexPosition>[];
    for (final hex in outer) {
      for (final dir in HexPosition.directions) {
        final pos = hex + dir;
        if (!existing.contains(pos)) {
          candidateOffsets.add(pos);
        }
      }
    }
    candidateOffsets.shuffle(random);

    for (final offset in candidateOffsets) {
      for (var rot = 0; rot < 6; rot++) {
        final candidate = PastureTile.diamond(_builder.placedTiles.length, const HexPosition(0, 0))
            .rotate(rot)
            .translate(offset);
        if (_builder.canPlace(candidate)) {
          _currentTile = PastureTile.diamond(_builder.placedTiles.length, const HexPosition(0, 0)).rotate(rot);
          _tileOffset = offset;
          _tryPlaceTile();
          return;
        }
      }
    }
  }

  void _startGame() {
    Navigator.pushReplacementNamed(
      context,
      AppRouter.game,
      arguments: {
        'players': widget.players,
        'tiles': _builder.placedTiles,
        'herdSize': 16,
      },
    );
  }

  HexPosition _pixelToHexOffset(Offset localPos, RenderBox boardBox, double hexSize) {
    final center = Offset(boardBox.size.width / 2, boardBox.size.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;

    final q = ((sqrt(3) / 3 * dx - 1.0 / 3 * dy) / hexSize).round();
    final r = ((2.0 / 3 * dy) / hexSize).round();

    return HexPosition(q, r);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background/Table_Gameplay_Background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/Background/Background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildPlayerInfo(),
                Expanded(
                  child: _buildBoardArea(),
                ),
                if (!_allTilesPlaced) _buildBottomShelf(),
              ],
            ),
          ),
          if (_isDragging && _currentTile != null) _buildFloatingDragAvatar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
            ),
            child: Text(
              _allTilesPlaced ? 'PASTURE COMPLETE!' : 'BUILD THE PASTURE',
              style: GoogleFonts.bangers(
                fontSize: 18,
                color: const Color(0xFFFFD54F),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Spacer(),
          if (_allTilesPlaced)
            GameButtonStyles.primaryButton(
              text: 'START BATTLE',
              onPressed: _startGame,
              width: 150,
              height: 44,
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.players.length, (index) {
          final player = widget.players[index];
          final isCurrent = index == _currentPlayerIndex && !_allTilesPlaced;
          final tilesLeft = _tilesRemaining[index];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.35)
                  : Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent
                    ? AppColors.getPlayerPrimary(player.color)
                    : Colors.white24,
                width: isCurrent ? 2.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.getPlayerPrimary(player.color),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.name,
                      style: GoogleFonts.bangers(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$tilesLeft TILES',
                      style: GoogleFonts.bangers(
                        fontSize: 11,
                        color: isCurrent ? const Color(0xFFFFD54F) : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBoardArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardDimension = min(constraints.maxWidth, constraints.maxHeight) * 0.92;
        final hexSize = boardDimension / 16;

        return GestureDetector(
          onPanStart: (details) {
            if (_currentPlayer.isAi || _allTilesPlaced || _currentTile == null) return;
            setState(() {
              _isDragging = true;
              _dragPosition = details.globalPosition;
            });
            _updateSnappedHexOffset(details.globalPosition, hexSize);
          },
          onPanUpdate: (details) {
            if (_currentPlayer.isAi || _allTilesPlaced || _currentTile == null) return;
            setState(() {
              _dragPosition = details.globalPosition;
            });
            _updateSnappedHexOffset(details.globalPosition, hexSize);
          },
          onPanEnd: (_) {
            if (_currentPlayer.isAi || _allTilesPlaced || _currentTile == null) return;
            setState(() {
              _isDragging = false;
            });
            _tryPlaceTile();
          },
          onTapUp: (details) {
            if (_currentPlayer.isAi || _allTilesPlaced || _currentTile == null) return;
            _updateSnappedHexOffset(details.globalPosition, hexSize);
            _tryPlaceTile();
          },
          child: Center(
            child: Container(
              key: _boardKey,
              width: boardDimension,
              height: boardDimension,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12, width: 1.5),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (_builder.placedHexes.isEmpty && !_isDragging)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded, color: Colors.white54, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'DRAG TILE ONTO THE BOARD\nOR TAP TO PLACE',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.bangers(
                              fontSize: 16,
                              color: Colors.white70,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ..._buildPlacedTiles(hexSize, boardDimension),
                  if (_currentTile != null)
                    _buildPreviewTile(hexSize, boardDimension),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateSnappedHexOffset(Offset globalPos, double hexSize) {
    final boardBox = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (boardBox == null) return;

    final localPos = boardBox.globalToLocal(globalPos);
    final snapped = _pixelToHexOffset(localPos, boardBox, hexSize);
    if (snapped != _tileOffset) {
      setState(() {
        _tileOffset = snapped;
      });
    }
  }

  List<Widget> _buildPlacedTiles(double hexSize, double boardDimension) {
    final widgets = <Widget>[];
    final center = Offset(boardDimension / 2, boardDimension / 2);

    for (final hex in _builder.placedHexes) {
      final pixelPos = _hexToPixel(hex, hexSize, center);
      final isAnimating = _showDropAnim && _dropAnimatingHexes.contains(hex);

      Widget tileWidget = _drawHex(hexSize, AppColors.grassMid, AppColors.tileBorder, hexPos: hex, hasTexture: true);

      if (isAnimating) {
        tileWidget = AnimatedBuilder(
          animation: _dropAnimController,
          builder: (context, child) {
            return Transform.scale(
              scale: _dropScaleAnimation.value,
              child: child,
            );
          },
          child: tileWidget,
        );
      }

      widgets.add(
        Positioned(
          left: pixelPos.dx - hexSize,
          top: pixelPos.dy - hexSize,
          child: tileWidget,
        ),
      );
    }

    return widgets;
  }

  Widget _buildPreviewTile(double hexSize, double boardDimension) {
    final preview = _currentTile!.translate(_tileOffset);
    final canPlace = _builder.canPlace(preview);
    final center = Offset(boardDimension / 2, boardDimension / 2);
    final widgets = <Widget>[];

    for (final hex in preview.hexes) {
      final pixelPos = _hexToPixel(hex, hexSize, center);
      final color = canPlace ? Colors.green.withValues(alpha: 0.6) : Colors.red.withValues(alpha: 0.6);
      final border = canPlace ? Colors.greenAccent : Colors.redAccent;

      widgets.add(
        Positioned(
          left: pixelPos.dx - hexSize,
          top: pixelPos.dy - hexSize,
          child: _drawHex(hexSize, color, border, hexPos: hex, hasTexture: canPlace),
        ),
      );
    }

    return Stack(children: widgets);
  }

  Widget _buildBottomShelf() {
    final canPlace = _currentTile != null && _builder.canPlace(_currentTile!.translate(_tileOffset));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1C0C).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getPlayerPrimary(_currentPlayer.color),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Current Player Token & Tile Preview
          GestureDetector(
            onTap: _rotateTile,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  const Text('🌾', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '4-HEX PASTURE',
                        style: GoogleFonts.bangers(
                          fontSize: 14,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'TAP TO ROTATE 🔄',
                        style: GoogleFonts.bangers(
                          fontSize: 11,
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Rotate Button
          GestureDetector(
            onTap: _rotateTile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8D6E63), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.rotate_right_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'ROTATE',
                    style: GoogleFonts.bangers(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Place Button
          GestureDetector(
            onTap: canPlace ? _tryPlaceTile : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: canPlace
                    ? const LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade700, Colors.grey.shade800],
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: canPlace ? Colors.white : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: Text(
                'PLACE',
                style: GoogleFonts.bangers(
                  fontSize: 16,
                  color: canPlace ? Colors.white : Colors.white38,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDragAvatar() {
    return Positioned(
      left: _dragPosition.dx - 35,
      top: _dragPosition.dy - 35,
      child: IgnorePointer(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.getPlayerPrimary(_currentPlayer.color).withValues(alpha: 0.8),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.getPlayerPrimary(_currentPlayer.color).withValues(alpha: 0.6),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Center(
            child: Text('🌾', style: TextStyle(fontSize: 32)),
          ),
        ),
      ),
    );
  }

  Widget _drawHex(double size, Color fill, Color border, {HexPosition? hexPos, bool hasTexture = false}) {
    final flipMode = hexPos != null
        ? (hexPos.q * 7 + hexPos.r * 13 + hexPos.q * hexPos.r * 3).abs() % 4
        : 0;
    return CustomPaint(
      size: Size(size * 2, size * 2),
      painter: _HexPainter(
        fill: fill,
        border: border,
        texture: hasTexture ? _texture : null,
        flipMode: flipMode,
      ),
    );
  }

  Offset _hexToPixel(HexPosition hex, double size, Offset center) {
    final x = size * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
    final y = size * (3.0 / 2 * hex.r);
    return Offset(center.dx + x, center.dy + y);
  }
}

class _HexPainter extends CustomPainter {
  final Color fill;
  final Color border;
  final ui.Image? texture;
  final int flipMode;

  _HexPainter({
    required this.fill,
    required this.border,
    this.texture,
    this.flipMode = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // 3D Depth bevel
    final depthOffset = radius * 0.12;
    final sidePath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final topPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        sidePath.moveTo(topPoint.dx, topPoint.dy);
      } else {
        sidePath.lineTo(topPoint.dx, topPoint.dy);
      }
    }
    for (var i = 5; i >= 0; i--) {
      final angle = (pi / 3) * i - pi / 6;
      final bottomPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle) + depthOffset,
      );
      sidePath.lineTo(bottomPoint.dx, bottomPoint.dy);
    }
    sidePath.close();

    canvas.drawPath(
      sidePath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF4E7A25), Color(0xFF2D5016)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, center.dy, size.width, depthOffset)),
    );

    // Hex fill with texture
    canvas.save();
    canvas.clipPath(path);
    if (texture != null) {
      final imgSize = radius * 2.0;
      final src = Rect.fromLTWH(0, 0, texture!.width.toDouble(), texture!.height.toDouble());
      final dst = Rect.fromLTWH(
        center.dx - radius,
        center.dy - radius,
        imgSize,
        imgSize,
      );
      canvas.save();
      if (flipMode == 1) {
        canvas.translate(center.dx, center.dy);
        canvas.scale(-1, 1);
        canvas.translate(-center.dx, -center.dy);
      } else if (flipMode == 2) {
        canvas.translate(center.dx, center.dy);
        canvas.scale(1, -1);
        canvas.translate(-center.dx, -center.dy);
      } else if (flipMode == 3) {
        canvas.translate(center.dx, center.dy);
        canvas.scale(-1, -1);
        canvas.translate(-center.dx, -center.dy);
      }
      canvas.drawImageRect(texture!, src, dst, Paint()..filterQuality = FilterQuality.medium);
      canvas.restore();
    } else {
      canvas.drawPath(path, Paint()..color = fill);
    }
    canvas.restore();

    // Hex border
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _HexPainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.border != border ||
      oldDelegate.texture != texture ||
      oldDelegate.flipMode != flipMode;
}
