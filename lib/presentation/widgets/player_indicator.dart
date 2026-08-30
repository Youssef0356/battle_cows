import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: isActive
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
          color: isActive
              ? AppColors.getPlayerPrimary(player.color)
              : Colors.white.withValues(alpha: 0.2),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                player.name.toUpperCase(),
                style: GoogleFonts.bangers(
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '$territoryCount T | $cowCount C',
                style: GoogleFonts.bangers(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (player.isAi) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'CPU',
                style: GoogleFonts.bangers(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
