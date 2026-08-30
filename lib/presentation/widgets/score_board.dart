import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../game/models/player.dart';

class ScoreBoard extends StatelessWidget {
  final List<Player> players;
  final Map<PlayerColor, int> territoryCounts;
  final Map<PlayerColor, int> cowCounts;
  final PlayerColor? currentPlayerColor;

  const ScoreBoard({
    super.key,
    required this.players,
    required this.territoryCounts,
    required this.cowCounts,
    this.currentPlayerColor,
  });

  @override
  Widget build(BuildContext context) {
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCORE',
            style: GoogleFonts.bangers(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          ...players.map((player) {
            final territory = territoryCounts[player.color] ?? 0;
            final cows = cowCounts[player.color] ?? 0;
            final isActive = player.color == currentPlayerColor;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isActive
                      ? Border.all(
                          color: AppColors.getPlayerPrimary(player.color),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
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
                        border: Border.all(
                          color: isActive ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ]
                            : [],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$territory ($cows)',
                      style: GoogleFonts.bangers(
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
