import 'package:flutter/material.dart';
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
        color: AppColors.cardBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SCORE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          ...players.map((player) {
            final territory = territoryCounts[player.color] ?? 0;
            final cows = cowCounts[player.color] ?? 0;
            final isActive = player.color == currentPlayerColor;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.getPlayerPrimary(player.color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$territory ($cows)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
