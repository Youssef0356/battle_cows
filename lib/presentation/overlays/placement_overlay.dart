import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icony/icony_gameicons.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../core/constants/colors.dart';
import '../widgets/wood_button.dart';

class PlacementOverlay extends StatefulWidget {
  final BattleCowsGame game;

  const PlacementOverlay({
    super.key,
    required this.game,
  });

  @override
  State<PlacementOverlay> createState() => _PlacementOverlayState();
}

class _PlacementOverlayState extends State<PlacementOverlay>
    with TickerProviderStateMixin {
  late final VoidCallback _updateListener;
  // Pulse animation for the hint arrow
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Slide-in animation for the bottom shelf
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  // Rotation animation for the tile preview
  late AnimationController _tileRotateController;
  late Animation<double> _tileRotateAnim;

  // Funny farm encouragement banner animation
  late AnimationController _encouragementController;
  late Animation<double> _encouragementScale;
  late Animation<double> _encouragementOpacity;
  int _lastPlacementCount = 0;

  @override
  void initState() {
    super.initState();

    _updateListener = () {
      if (mounted) {
        if (widget.game.placementCount > _lastPlacementCount) {
          _lastPlacementCount = widget.game.placementCount;
          _encouragementController.forward(from: 0.0);
        }
        setState(() {});
      }
    };
    widget.game.addStateListener(_updateListener);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _tileRotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _tileRotateAnim = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _tileRotateController, curve: Curves.easeInOut),
    );

    _encouragementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _encouragementScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.12).chain(CurveTween(curve: Curves.elasticOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8).chain(CurveTween(curve: Curves.easeIn)), weight: 15),
    ]).animate(_encouragementController);

    _encouragementOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_encouragementController);

    // Delay slide-in so it feels like an entrance
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    widget.game.removeStateListener(_updateListener);
    _pulseController.dispose();
    _slideController.dispose();
    _tileRotateController.dispose();
    _encouragementController.dispose();
    super.dispose();
  }

  void _rotateWithAnimation() {
    _tileRotateController.forward(from: 0).then((_) {
      _tileRotateController.reset();
    });
    widget.game.rotateCurrentTile();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    if (game.players.isEmpty) return const SizedBox.shrink();

    final currentPlayerIndex = game.currentPlayerIndex;
    final players = game.players;
    final tilesRemaining = game.tilesRemaining;
    final currentTile = game.currentTile;
    final canPlace = game.canPlaceCurrentTile;
    final isAi = players[currentPlayerIndex].isAi;
    final currentPlayer = players[currentPlayerIndex];
    final playerColor = AppColors.getPlayerPrimary(currentPlayer.color);
    final size = MediaQuery.of(context).size;

    // Count total tiles placed
    final totalTilesPerPlayer = game.tilesPerPlayerSetting;
    final tilesPlaced = totalTilesPerPlayer - tilesRemaining[currentPlayerIndex];

    return SafeArea(
      child: Column(
        children: [
          // ── Top bar ──────────────────────────────────────────────
          _buildTopBar(currentPlayerIndex, players, tilesRemaining,
              totalTilesPerPlayer, tilesPlaced, playerColor),

          // ── Funny Farm Encouragement Toast ───────────────────────
          _buildEncouragementToast(),

          const Spacer(),

          // ── Drag & Place instruction ─────────────────────────────
          if (!isAi && currentTile != null)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnim.value,
                child: child,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: playerColor.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: playerColor.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.swipe_rounded,
                        color: playerColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'DRAG TO MOVE • TAP PLACE TO CLAIM',
                      style: GoogleFonts.bangers(
                        fontSize: size.width < 400 ? 12 : 14,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                              color: Colors.black.withValues(alpha: 0.7),
                              offset: const Offset(1, 1),
                              blurRadius: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Bottom control shelf ─────────────────────────────────
          if (!isAi && currentTile != null)
            SlideTransition(
              position: _slideAnim,
              child: _buildBottomShelf(canPlace, currentTile, playerColor, size),
            ),

          if (isAi)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E1C0C).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD54F)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFD54F),
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI IS PLACING TILES…',
                      style: GoogleFonts.bangers(
                        fontSize: 16,
                        color: const Color(0xFFFFD54F),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEncouragementToast() {
    final message = widget.game.currentEncouragement;
    if (message.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _encouragementController,
      builder: (context, child) {
        if (_encouragementOpacity.value <= 0.01) return const SizedBox.shrink();

        return Opacity(
          opacity: _encouragementOpacity.value,
          child: Transform.scale(
            scale: _encouragementScale.value,
            child: child,
          ),
        );
      },
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.bangers(
              fontSize: 16,
              color: const Color(0xFF2E1C0C),
              letterSpacing: 1.2,
              shadows: const [
                Shadow(
                  color: Colors.white70,
                  offset: Offset(0.5, 0.5),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    int currentPlayerIndex,
    List<Player> players,
    List<int> tilesRemaining,
    int totalTiles,
    int tilesPlaced,
    Color playerColor,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3E2505), Color(0xFF5C3D0E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA07830), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      child: Row(
        children: [
          // Phase label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BUILD THE PASTURE',
                  style: GoogleFonts.bangers(
                    fontSize: 16,
                    color: const Color(0xFFFFD54F),
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          offset: const Offset(1, 1),
                          blurRadius: 2),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: totalTiles > 0
                            ? tilesPlaced / totalTiles
                            : 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: playerColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tile $tilesPlaced / $totalTiles',
                      style: GoogleFonts.bangers(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Player indicators
          ...List.generate(players.length, (index) {
            final player = players[index];
            final isCurrent = index == currentPlayerIndex;
            final tilesLeft = tilesRemaining[index];
            final pColor = AppColors.getPlayerPrimary(player.color);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isCurrent
                    ? pColor.withValues(alpha: 0.3)
                    : Colors.black38,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent ? pColor : Colors.white24,
                  width: isCurrent ? 2.5 : 1,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: pColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GameIcons(
                    GameIcons.cow,
                    width: isCurrent ? 18 : 14,
                    height: isCurrent ? 18 : 14,
                    color: const Color(0xFFFFD54F),
                  ),
                  Text(
                    '$tilesLeft',
                    style: GoogleFonts.bangers(
                      fontSize: isCurrent ? 16 : 13,
                      color: isCurrent
                          ? const Color(0xFFFFD54F)
                          : Colors.white70,
                    ),
                  ),
                  Text(
                    player.name.split(' ').last,
                    style: GoogleFonts.bangers(
                      fontSize: 9,
                      color: Colors.white54,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          }),
          // Menu button
          const SizedBox(width: 8),
          _buildMenuButton(context),
        ],
      ),
    ));
  }

  Widget _buildMenuButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF2E1C0C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFFFD54F), width: 2),
            ),
            title: Text(
              'GAME PAUSED',
              style: GoogleFonts.bangers(fontSize: 22, color: const Color(0xFFFFD54F)),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPauseButton(
                  label: 'RESTART MATCH',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.game.rematch();
                  },
                ),
                const SizedBox(height: 12),
                _buildPauseButton(
                  label: 'EXIT TO MAIN MENU',
                  icon: Icons.exit_to_app_rounded,
                  baseColor: const Color(0xFF8B2500),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF8D6E63), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.menu, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildPauseButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color baseColor = const Color(0xFF5D4037),
  }) {
    return WoodButton(
      label: label,
      icon: icon,
      width: 220,
      height: 48,
      fontSize: 15,
      baseColor: baseColor,
      borderColor: baseColor == const Color(0xFF8B2500)
          ? const Color(0xFFFFCDD2)
          : const Color(0xFFBCAAA4),
      onPressed: onPressed,
    );
  }

  Widget _buildBottomShelf(
      bool canPlace, dynamic currentTile, Color playerColor, Size screenSize) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3E2505), Color(0xFF6B4F12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFA07830), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
            BoxShadow(
              color: playerColor.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hex tile preview (mini)
          _buildTilePreview(playerColor),
          const SizedBox(width: 12),

          // Tile info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '4-HEX PASTURE TILE',
                  style: GoogleFonts.bangers(
                    fontSize: screenSize.width < 400 ? 12 : 14,
                    color: const Color(0xFFFFF3D6),
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2),
                    ],
                  ),
                ),
                Text(
                  canPlace
                      ? '✅ Ready to place!'
                      : '🔴 Overlapping – move position',
                  style: GoogleFonts.bangers(
                    fontSize: 11,
                    color: canPlace
                        ? const Color(0xFF81C784)
                        : const Color(0xFFEF9A9A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Rotate button
          GestureDetector(
            onTap: _rotateWithAnimation,
            child: WoodButton(
              label: 'ROTATE',
              icon: Icons.rotate_right_rounded,
              height: 46,
              fontSize: 14,
              isSmall: true,
              baseColor: const Color(0xFF5D4037),
              borderColor: const Color(0xFFBCAAA4),
            ),
          ),
          const SizedBox(width: 8),

          // Place button
          WoodButton(
            label: 'PLACE',
            emoji: canPlace ? '✅' : null,
            icon: canPlace ? null : Icons.block_rounded,
            height: 46,
            fontSize: 14,
            isSmall: true,
            baseColor: canPlace ? const Color(0xFF2E7D32) : const Color(0xFF4A4A4A),
            borderColor: canPlace ? const Color(0xFF81C784) : const Color(0xFF666666),
            onPressed: canPlace ? () => widget.game.placeCurrentTile() : null,
          ),
        ],
      ),
    ));
  }

  Widget _buildTilePreview(Color playerColor) {
    // Draw a mini hex cluster preview matching the diamond tile shape
    return AnimatedBuilder(
      animation: _tileRotateAnim,
      builder: (context, child) {
        return SizedBox(
          width: 64,
          height: 64,
          child: CustomPaint(
            painter: _MiniTilePreviewPainter(
              playerColor: playerColor,
              rotationAngle: 0, // static preview
            ),
          ),
        );
      },
    );
  }
}

/// Paints a small 4-hex diamond cluster as a tile preview
class _MiniTilePreviewPainter extends CustomPainter {
  final Color playerColor;
  final double rotationAngle;

  _MiniTilePreviewPainter({
    required this.playerColor,
    this.rotationAngle = 0,
  });

  static const List<List<int>> _diamondHexes = [
    [0, 0],
    [1, 0],
    [0, 1],
    [-1, 1],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final hexSize = 13.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    for (final hex in _diamondHexes) {
      final q = hex[0];
      final r = hex[1];
      final x = hexSize * (sqrt(3) * q + sqrt(3) / 2 * r);
      final y = hexSize * (3.0 / 2 * r);

      _drawHex(canvas, Offset(x, y), hexSize * 0.92, playerColor);
    }

    canvas.restore();
  }

  void _drawHex(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final pt = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();

    // 3D bevel bottom
    final depthPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final pt = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) { depthPath.moveTo(pt.dx, pt.dy); }
      else { depthPath.lineTo(pt.dx, pt.dy); }
    }
    for (var i = 5; i >= 0; i--) {
      final angle = (pi / 3) * i - pi / 6;
      depthPath.lineTo(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle) + 3,
      );
    }
    depthPath.close();

    canvas.drawPath(
      depthPath,
      Paint()
        ..color = HSLColor.fromColor(color)
            .withLightness(
                (HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0))
            .toColor()
            .withValues(alpha: 0.8),
    );

    // Fill
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.5),
          colors: [
            HSLColor.fromColor(color)
                .withLightness(
                    (HSLColor.fromColor(color).lightness + 0.12).clamp(0.0, 1.0))
                .toColor(),
            color,
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        ),
    );

    // Border
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniTilePreviewPainter old) =>
      old.playerColor != playerColor || old.rotationAngle != rotationAngle;
}
