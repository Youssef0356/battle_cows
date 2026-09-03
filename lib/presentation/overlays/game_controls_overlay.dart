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
    final totalCows = herd?.size ?? 0;
    final maxMoving = max(0, totalCows - 1);
    final movingCount = game.selectedSplitCount.clamp(0, maxMoving);
    final playerColor = herd?.owner ?? game.engine.currentPlayer.color;
    final hearts = game.playerHearts[game.engine.currentPlayer.color] ?? 3;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Hearts display
          _buildHeartsDisplay(hearts),
          const SizedBox(height: 8),
          // Selected stack plaque with shortcut buttons
          if (herd != null && totalCows >= 2)
            _buildSelectedStackPlaque(
              herdExists: true,
              movingCount: movingCount,
              maxMoving: maxMoving,
              totalCows: totalCows,
              playerColor: playerColor,
            ),
          const SizedBox(height: 8),
          // Instruction banner
          _buildParchmentBanner(herd != null, movingCount, maxMoving),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeartsDisplay(int hearts) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isLost = index >= hearts;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLost ? Colors.grey.shade800 : const Color(0xFFD32F2F),
              border: Border.all(
                color: isLost ? Colors.grey.shade600 : const Color(0xFFFF5252),
                width: 2,
              ),
              boxShadow: isLost
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFFD32F2F).withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                '❤️',
                style: TextStyle(
                  fontSize: 18,
                  color: isLost ? Colors.grey.shade600 : Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6B4F12),
            Color(0xFF5C3D0E),
            Color(0xFF8B6914),
            Color(0xFF5C3D0E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA0792A), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFFD4A84B).withValues(alpha: 0.2),
            offset: const Offset(0, -1),
            blurRadius: 3,
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
              color: const Color(0xFFFFF3D6),
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cow icon with count
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getPlayerPrimary(playerColor),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFF3D6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '🐮',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$totalCows',
                style: GoogleFonts.bangers(
                  fontSize: 20,
                  color: const Color(0xFFFFF3D6),
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '>>',
                style: TextStyle(
                  color: Color(0xFFFFF3D6),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              // Moving count display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA0792A)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🐮 MOVE',
                      style: GoogleFonts.bangers(
                        fontSize: 9,
                        color: const Color(0xFFFFF3D6).withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '$movingCount',
                      style: GoogleFonts.bangers(
                        fontSize: 18,
                        color: const Color(0xFFFFF3D6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Shortcut buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShortcutButton('1', () {
                widget.game.setSplitCount(1);
              }),
              const SizedBox(width: 6),
              if (maxMoving >= 2)
                _buildShortcutButton('${(totalCows / 2).floor()}', () {
                  widget.game.setSplitCount((totalCows / 2).floor().clamp(1, maxMoving));
                }),
              if (maxMoving >= 2) const SizedBox(width: 6),
              if (maxMoving >= 3)
                _buildShortcutButton('${(totalCows * 2 / 3).floor()}', () {
                  widget.game.setSplitCount((totalCows * 2 / 3).floor().clamp(1, maxMoving));
                }),
              if (maxMoving >= 3) const SizedBox(width: 6),
              _buildShortcutButton('MAX', () {
                widget.game.setSplitCount(maxMoving);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 32,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B6914), Color(0xFF6B4F12)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD4A84B), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.bangers(
              fontSize: 12,
              color: const Color(0xFFFFF3D6),
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
