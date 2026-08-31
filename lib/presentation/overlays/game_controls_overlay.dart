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

    String statusText;
    Color statusColor;

    if (isAnimating) {
      statusText = 'MOVING...';
      statusColor = Colors.amber;
    } else if (currentPlayer.isAi) {
      statusText = 'CPU THINKING...';
      statusColor = Colors.white70;
    } else if (selectedPosition != null) {
      statusText = 'TAP DESTINATION (${validMoves.length} available)';
      statusColor = AppColors.primaryAction;
    } else {
      statusText = 'SELECT A HERD TO MOVE';
      statusColor = Colors.white70;
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.black.withValues(alpha: 0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
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
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.bangers(
                    fontSize: 14,
                    color: statusColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
