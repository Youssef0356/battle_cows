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
import '../../game/models/player.dart';
import '../router/app_router.dart';

class TilePlacementScreen extends StatefulWidget {
  final List<Player> players;
  final int tilesPerPlayer;

  const TilePlacementScreen({
    super.key,
    required this.players,
    this.tilesPerPlayer = 5,
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
  late Animation<double> _dropBounceAnimation;
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
      duration: const Duration(milliseconds: 500),
    );
    _dropScaleAnimation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _dropAnimController, curve: Curves.elasticOut),
    );
    _dropBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dropAnimController, curve: Curves.easeOutBack),
    );
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

  void _generateNewTile() {
    final tileIndex = _builder.placedTiles.length;
    _currentTile = PastureTile.diamond(tileIndex, const HexPosition(0, 0));
    _tileOffset = const HexPosition(0, 0);
  }

  Player get _currentPlayer => widget.players[_currentPlayerIndex];

  bool get _allTilesPlaced => _tilesRemaining.every((count) => count == 0);

  void _moveTile(HexPosition direction) {
    setState(() {
      _tileOffset = _tileOffset + direction;
    });
  }

  void _rotateTile() {
    setState(() {
      _generateNewTile();
    });
  }

  bool _tryPlaceTile() {
    if (_currentTile == null) return false;

    final translated = _currentTile!.translate(_tileOffset);
    if (_builder.canPlace(translated)) {
      _dropAnimatingHexes = List.from(translated.hexes);
      _showDropAnim = true;
      _dropAnimController.forward(from: 0).then((_) {
        setState(() {
          _showDropAnim = false;
          _dropAnimatingHexes = [];
        });
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

  HexPosition _pixelToHexOffset(Offset dropPosition, RenderBox boardBox, double hexSize) {
    final center = Offset(boardBox.size.width / 2 + hexSize * 10, boardBox.size.height / 2 + hexSize * 10);
    final dx = dropPosition.dx - center.dx;
    final dy = dropPosition.dy - center.dy;

    final q = (dx / (sqrt(3) * hexSize)).round();
    final r = (dy / (3.0 / 2 * hexSize)).round();

    return HexPosition(q, r);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background/Background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          Column(
            children: [
              _buildTopBar(),
              _buildPlayerInfo(),
              Expanded(
                child: _buildBoardArea(),
              ),
              if (_currentTile != null) _buildControls(),
            ],
          ),
          if (_isDragging) _buildDragOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'BUILD THE PASTURE',
            style: GoogleFonts.bangers(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          if (_allTilesPlaced)
            GameButtonStyles.primaryButton(
              text: 'START GAME',
              onPressed: _startGame,
              width: 140,
              height: 44,
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.players.length, (index) {
          final player = widget.players[index];
          final isCurrent = index == _currentPlayerIndex;
          final tilesLeft = _tilesRemaining[index];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isCurrent
                  ? LinearGradient(
                      colors: [
                        AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.4),
                        AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCurrent
                    ? AppColors.getPlayerPrimary(player.color)
                    : Colors.white.withValues(alpha: 0.2),
                width: isCurrent ? 2 : 1,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.getPlayerPrimary(player.color),
                        AppColors.getPlayerDark(player.color),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$tilesLeft LEFT',
                  style: GoogleFonts.bangers(
                    fontSize: 12,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
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
        final size = min(constraints.maxWidth, constraints.maxHeight) * 0.85;
        final hexSize = size / 18;

        return Center(
          child: SizedBox(
            key: _boardKey,
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.grassMid.withValues(alpha: 0.4),
                        AppColors.grassMid.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.tileBorder.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                ),
                if (_builder.placedHexes.isEmpty && !_isDragging)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TAP ARROWS TO MOVE\nTAP PLACE TO SET',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.bangers(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ..._buildPlacedTiles(hexSize),
                if (_currentTile != null && !_isDragging) _buildPreviewTile(hexSize),
                if (_currentTile != null && _isDragging) _buildDragPreviewOnBoard(hexSize),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPlacedTiles(double hexSize) {
    final widgets = <Widget>[];

    for (final hex in _builder.placedHexes) {
      final pixelPos = _hexToPixel(hex, hexSize);
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

  Widget _buildPreviewTile(double hexSize) {
    final preview = _currentTile!.translate(_tileOffset);
    final canPlace = _builder.canPlace(preview);
    final widgets = <Widget>[];

    for (final hex in preview.hexes) {
      final pixelPos = _hexToPixel(hex, hexSize);
      widgets.add(
        Positioned(
          left: pixelPos.dx - hexSize,
          top: pixelPos.dy - hexSize,
          child: _drawHex(
            hexSize,
            canPlace
                ? AppColors.getPlayerPrimary(_currentPlayer.color).withValues(alpha: 0.8)
                : AppColors.timerRed.withValues(alpha: 0.6),
            Colors.white,
            hexPos: hex,
            hasTexture: true,
          ),
        ),
      );
    }

    return Stack(children: widgets);
  }

  Widget _buildDragPreviewOnBoard(double hexSize) {
    final preview = _currentTile!.translate(_tileOffset);
    final canPlace = _builder.canPlace(preview);
    final widgets = <Widget>[];

    for (final hex in preview.hexes) {
      final pixelPos = _hexToPixel(hex, hexSize);
      widgets.add(
        Positioned(
          left: pixelPos.dx - hexSize,
          top: pixelPos.dy - hexSize,
          child: _drawHex(
            hexSize,
            canPlace
                ? AppColors.getPlayerPrimary(_currentPlayer.color).withValues(alpha: 0.9)
                : AppColors.timerRed.withValues(alpha: 0.7),
            Colors.white,
            hexPos: hex,
            hasTexture: true,
          ),
        ),
      );
    }

    return Stack(children: widgets);
  }

  Widget _buildDragOverlay() {
    return Positioned(
      left: _dragPosition.dx - 40,
      top: _dragPosition.dy - 40,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.getPlayerPrimary(_currentPlayer.color),
                AppColors.getPlayerDark(_currentPlayer.color),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.getPlayerPrimary(_currentPlayer.color).withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              'DRAG',
              style: GoogleFonts.bangers(
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
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

  Offset _hexToPixel(HexPosition hex, double size) {
    final x = size * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
    final y = size * (3.0 / 2 * hex.r);
    return Offset(x + size * 10, y + size * 10);
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TILE ${widget.tilesPerPlayer - _tilesRemaining[_currentPlayerIndex] + 1} OF ${widget.tilesPerPlayer}',
            style: GoogleFonts.bangers(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildDraggablePreview(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildArrowButton(const HexPosition(0, -1), Icons.arrow_drop_up),
              const SizedBox(width: 4),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildArrowButton(const HexPosition(-1, 0), Icons.arrow_left),
              const SizedBox(width: 4),
              _buildPlaceButton(),
              const SizedBox(width: 4),
              _buildArrowButton(const HexPosition(1, 0), Icons.arrow_right),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildArrowButton(const HexPosition(0, 1), Icons.arrow_drop_down),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildArrowButton(const HexPosition(-1, 1), Icons.arrow_downward),
              const SizedBox(width: 8),
              _buildRotateButton(),
              const SizedBox(width: 8),
              _buildArrowButton(const HexPosition(1, -1), Icons.arrow_upward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDraggablePreview() {
    final canPlace = _builder.canPlace(_currentTile!.translate(_tileOffset));

    return GestureDetector(
      onLongPressStart: (details) {
        setState(() {
          _isDragging = true;
          _dragPosition = details.globalPosition;
        });
      },
      onLongPressMoveUpdate: (details) {
        setState(() {
          _dragPosition = details.globalPosition;
        });

        final boardBox = _boardKey.currentContext?.findRenderObject() as RenderBox?;
        if (boardBox == null) return;

        final localDrop = boardBox.globalToLocal(details.globalPosition);
        final size = min(boardBox.size.width, boardBox.size.height) * 0.85;
        final hexSize = size / 18;

        final newOffset = _pixelToHexOffset(localDrop, boardBox, hexSize);
        if (newOffset != _tileOffset) {
          setState(() {
            _tileOffset = newOffset;
          });
        }
      },
      onLongPressEnd: (details) {
        setState(() {
          _isDragging = false;
          _dragPosition = Offset.zero;
        });
        _tryPlaceTile();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canPlace
                ? [
                    AppColors.getPlayerPrimary(_currentPlayer.color),
                    AppColors.getPlayerDark(_currentPlayer.color),
                  ]
                : [Colors.grey, Colors.grey.withValues(alpha: 0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: canPlace
              ? [
                  BoxShadow(
                    color: AppColors.getPlayerPrimary(_currentPlayer.color).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isDragging ? Icons.open_with : Icons.drag_indicator,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isDragging ? 'RELEASING...' : 'HOLD & DRAG TO PLACE',
              style: GoogleFonts.bangers(
                fontSize: 14,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton(HexPosition direction, IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryAction,
            AppColors.secondaryAction.withValues(alpha: 0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => _moveTile(direction),
        icon: Icon(icon, color: Colors.white, size: 28),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPlaceButton() {
    final canPlace = _builder.canPlace(_currentTile!.translate(_tileOffset));

    return Container(
      width: 90,
      height: 48,
      decoration: BoxDecoration(
        gradient: canPlace
            ? const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : LinearGradient(
                colors: [Colors.grey, Colors.grey.withValues(alpha: 0.7)],
              ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: canPlace
            ? [
                BoxShadow(
                  color: AppColors.primaryAction.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: canPlace ? _tryPlaceTile : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'PLACE',
          style: GoogleFonts.bangers(
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildRotateButton() {
    return Container(
      width: 90,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryAction,
            AppColors.secondaryAction.withValues(alpha: 0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _rotateTile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'NEW',
          style: GoogleFonts.bangers(
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
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
    final path = _createHexPath(center, radius);

    _draw3DDepth(canvas, path, center, radius, size);
    _drawHexFill(canvas, path, center, radius);
    _drawHexBorder(canvas, path);
  }

  Path _createHexPath(Offset center, double radius) {
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
    return path;
  }

  void _draw3DDepth(Canvas canvas, Path path, Offset center, double radius, Size size) {
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

    final sidePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF4E7A25),
          const Color(0xFF2D5016),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, center.dy, size.width, depthOffset));

    canvas.drawPath(sidePath, sidePaint);

    final shadowPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle) + depthOffset + 2,
      );
      if (i == 0) {
        shadowPath.moveTo(point.dx, point.dy);
      } else {
        shadowPath.lineTo(point.dx, point.dy);
      }
    }
    shadowPath.close();

    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _drawHexFill(Canvas canvas, Path path, Offset center, double radius) {
    canvas.save();
    canvas.clipPath(path);

    if (texture != null) {
      _drawTexture(canvas, path, center, radius);
    } else {
      canvas.drawPath(path, Paint()..color = fill);
    }

    canvas.restore();
  }

  void _drawTexture(Canvas canvas, Path path, Offset center, double radius) {
    if (texture == null) return;

    final imgSize = radius * 2.0;
    final src = Rect.fromLTWH(0, 0, texture!.width.toDouble(), texture!.height.toDouble());
    final dst = Rect.fromLTWH(
      center.dx - radius,
      center.dy - radius,
      imgSize,
      imgSize,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);

    switch (flipMode) {
      case 1:
        canvas.scale(-1.0, 1.0);
        break;
      case 2:
        canvas.scale(1.0, -1.0);
        break;
      case 3:
        canvas.scale(-1.0, -1.0);
        break;
    }

    canvas.translate(-center.dx, -center.dy);
    canvas.drawImageRect(texture!, src, dst, Paint()..filterQuality = FilterQuality.low);
    canvas.restore();

    canvas.drawPath(path, Paint()..color = fill.withValues(alpha: 0.3));
  }

  void _drawHexBorder(Canvas canvas, Path path) {
    final borderPaint = Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
