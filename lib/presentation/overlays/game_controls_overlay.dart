import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../core/constants/colors.dart';

class GameControlsOverlay extends StatelessWidget {
  final BattleCowsGame game;

  const GameControlsOverlay({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final selectedPosition = game.selectedPosition;
    final validMoves = game.validMoves;
    final isAnimating = game.isAnimating;
    final currentPlayer = game.engine.currentPlayer;
    final selectedHerd = selectedPosition != null
        ? game.engine.board?.getHerdAt(selectedPosition)
        : null;

    final maxSplit = selectedHerd != null ? (selectedHerd.size - 1).clamp(1, 15) : 1;
    final currentSplit = game.selectedSplitCount.clamp(1, maxSplit);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.black.withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(
              color: AppColors.getPlayerPrimary(currentPlayer.color).withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedPosition != null &&
                  !isAnimating &&
                  !currentPlayer.isAi &&
                  selectedHerd != null &&
                  selectedHerd.size > 2) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SPLIT STACK: ',
                      style: GoogleFonts.bangers(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '$currentSplit ',
                      style: GoogleFonts.bangers(
                        fontSize: 22,
                        color: AppColors.primaryAction,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'TO MOVE  •  ${selectedHerd.size - currentSplit} REMAINING',
                      style: GoogleFonts.bangers(
                        fontSize: 14,
                        color: Colors.white60,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuickButton(
                      label: '-1',
                      onTap: () => game.setSplitCount(currentSplit - 1),
                    ),
                    const SizedBox(width: 6),
                    _buildQuickButton(
                      label: 'HALF (${(selectedHerd.size / 2).round()})',
                      onTap: () => game.setSplitCount((selectedHerd.size / 2).round()),
                    ),
                    const SizedBox(width: 6),
                    _buildQuickButton(
                      label: 'MAX ($maxSplit)',
                      onTap: () => game.setSplitCount(maxSplit),
                    ),
                    const SizedBox(width: 6),
                    _buildQuickButton(
                      label: '+1',
                      onTap: () => game.setSplitCount(currentSplit + 1),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selectedPosition != null && !isAnimating && !currentPlayer.isAi)
                    GestureDetector(
                      onTap: () => game.cancelMove(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Text(
                          'CANCEL',
                          style: GoogleFonts.bangers(
                            fontSize: 14,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  if (selectedPosition != null && !isAnimating && !currentPlayer.isAi)
                    const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (selectedPosition != null ? AppColors.primaryAction : Colors.white)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (selectedPosition != null ? AppColors.primaryAction : Colors.white)
                            .withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isAnimating
                          ? 'MOVING...'
                          : currentPlayer.isAi
                              ? 'CPU THINKING...'
                              : selectedPosition != null
                                  ? 'TAP GREEN OUTLINE TO LAND (${validMoves.length} SPOTS)'
                                  : 'TAP YOUR COWS TO MOVE',
                      style: GoogleFonts.bangers(
                        fontSize: 14,
                        color: isAnimating
                            ? Colors.amber
                            : selectedPosition != null
                                ? AppColors.primaryAction
                                : Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.bangers(
            fontSize: 12,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
