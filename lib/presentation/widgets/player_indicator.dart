import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../game/models/player.dart';

class PlayerIndicatorWidget extends StatelessWidget {
  final Player player;
  final bool isActive;
  final int territoryCount;
  final int cowCount;

  const PlayerIndicatorWidget({
    super.key,
    required this.player,
    this.isActive = false,
    this.territoryCount = 0,
    this.cowCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.getPlayerPrimary(player.color)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.getPlayerPrimary(player.color),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                player.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                '$territoryCount tiles | $cowCount cows',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (player.isAi) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.computer,
              size: 16,
              color: Colors.white54,
            ),
          ],
        ],
      ),
    );
  }
}
