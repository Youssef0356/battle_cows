import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../core/constants/colors.dart';

class GameControlsOverlay extends StatefulWidget {
  final BattleCowsGame game;

  const GameControlsOverlay({
    super.key,
    required this.game,
  });

  @override
  State<GameControlsOverlay> createState() => _GameControlsOverlayState();
}

class _GameControlsOverlayState extends State<GameControlsOverlay> {
  @override
  void initState() {
    super.initState();
    widget.game.onStateChanged = () {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final selectedPos = game.selectedPosition;
    final herd = selectedPos != null ? game.engine.board?.getHerdAt(selectedPos) : null;
    final totalCows = herd?.size ?? 1;
    final maxMoving = max(1, totalCows - 1);
    final movingCount = game.selectedSplitCount.clamp(1, maxMoving);
    final playerColor = herd?.owner ?? game.engine.currentPlayer.color;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 1. Left: Wooden UNDO button
                _buildWoodSquareButton(
                  icon: Icons.undo_rounded,
                  label: 'UNDO',
                  color: const Color(0xFF6D4C41),
                  borderColor: const Color(0xFFA1887F),
                  onTap: () {
                    game.cancelMove();
                  },
                ),
                // 2. Center: Wooden SELECTED STACK plaque
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildSelectedStackPlaque(
                      herdExists: herd != null,
                      movingCount: movingCount,
                      maxMoving: maxMoving,
                      totalCows: totalCows,
                      playerColor: playerColor,
                    ),
                  ),
                ),
                // 3. Right: Wooden END TURN button
                _buildWoodSquareButton(
                  icon: Icons.flag_rounded,
                  label: 'END TURN',
                  color: const Color(0xFFB71C1C),
                  borderColor: const Color(0xFFE57373),
                  onTap: () {
                    game.cancelMove();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // 4. Bottom Parchment instruction banner
          _buildParchmentBanner(herd != null, movingCount, maxMoving),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildWoodSquareButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.bangers(
                fontSize: 10,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedStackPlaque({
    required bool herdExists,
    required int movingCount,
    required int maxMoving,
    required int totalCows,
    required playerColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1C0C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8D6E63), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SELECTED STACK',
            style: GoogleFonts.bangers(
              fontSize: 11,
              color: const Color(0xFFFFD54F),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Active Token with Cow Face
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.getPlayerPrimary(playerColor),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    herdExists ? '🐮' : '❓',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Stack Size
              Text(
                '$totalCows',
                style: GoogleFonts.bangers(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '>>',
                style: TextStyle(
                  color: Color(0xFFFFD54F),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              // Move Stepper
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStepperBtn('-', () {
                      if (movingCount > 1) {
                        widget.game.setSplitCount(movingCount - 1);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'MOVE',
                            style: GoogleFonts.bangers(
                              fontSize: 9,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            herdExists ? '$movingCount' : '1',
                            style: GoogleFonts.bangers(
                              fontSize: 16,
                              color: const Color(0xFFFFD54F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStepperBtn('+', () {
                      if (movingCount < maxMoving) {
                        widget.game.setSplitCount(movingCount + 1);
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperBtn(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF5D4037),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFFD54F), width: 1),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.bangers(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParchmentBanner(bool hasSelected, int moving, int maxMove) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD7CCC8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF8D6E63), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        hasSelected
            ? 'Moving $moving cows (leaving ${maxMove - moving + 1}). Tap a highlighted tile.'
            : 'Select a stack with 2+ cows to move across the pasture.',
        textAlign: TextAlign.center,
        style: GoogleFonts.bangers(
          fontSize: 12,
          color: const Color(0xFF3E2723),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
