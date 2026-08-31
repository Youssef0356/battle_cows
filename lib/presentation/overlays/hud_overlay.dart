import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../core/constants/colors.dart';

class HudOverlay extends StatelessWidget {
  final BattleCowsGame game;
  final List<Player> players;

  const HudOverlay({
    super.key,
    required this.game,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    final timeRemaining = game.timeRemaining;
    final currentPlayer = game.engine.currentPlayer;
    final territoryCounts = game.territoryCounts;
    final cowCounts = game.cowCounts;

    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(timeRemaining, currentPlayer),
          _buildPlayerIndicators(currentPlayer, territoryCounts, cowCounts),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTopBar(int timeRemaining, Player currentPlayer) {
    Color timerColor;
    if (timeRemaining > 15) {
      timerColor = AppColors.timerGreen;
    } else if (timeRemaining > 5) {
      timerColor = AppColors.timerAmber;
    } else {
      timerColor = AppColors.timerRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'BATTLE COWS',
            style: GoogleFonts.bangers(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: timerColor, width: 2),
              boxShadow: timeRemaining <= 10
                  ? [
                      BoxShadow(
                        color: timerColor.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Text(
              '$timeRemaining S',
              style: GoogleFonts.bangers(
                color: timerColor,
                fontSize: 22,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerIndicators(
    Player currentPlayer,
    Map<PlayerColor, int> territoryCounts,
    Map<PlayerColor, int> cowCounts,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: players.map((player) {
          final isActive = player.color == currentPlayer.color;
          final territory = territoryCounts[player.color] ?? 0;
          final cows = cowCounts[player.color] ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? AppColors.getPlayerPrimary(player.color)
                      : Colors.white.withValues(alpha: 0.2),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.getPlayerPrimary(player.color),
                      shape: BoxShape.circle,
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
                        '$territory | $cows',
                        style: GoogleFonts.bangers(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  if (player.isAi) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CPU',
                        style: GoogleFonts.bangers(
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
