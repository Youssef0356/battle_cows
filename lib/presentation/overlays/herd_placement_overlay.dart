import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../core/constants/colors.dart';

class HerdPlacementOverlay extends StatefulWidget {
  final BattleCowsGame game;

  const HerdPlacementOverlay({
    super.key,
    required this.game,
  });

  @override
  State<HerdPlacementOverlay> createState() => _HerdPlacementOverlayState();
}

class _HerdPlacementOverlayState extends State<HerdPlacementOverlay> {
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
    final playerIndex = game.herdPlacementPlayerIndex;
    final players = game.players;

    if (playerIndex >= players.length) return const SizedBox.shrink();

    final currentPlayer = players[playerIndex];

    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(playerIndex, players),
          const Spacer(),
          _buildInstructions(currentPlayer),
        ],
      ),
    );
  }

  Widget _buildTopBar(int currentPlayerIndex, List<Player> players) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
            ),
            child: Text(
              'PLACE YOUR HERD',
              style: GoogleFonts.bangers(
                fontSize: 16,
                color: const Color(0xFFFFD54F),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Spacer(),
          ...List.generate(players.length, (index) {
            final player = players[index];
            final isCurrent = index == currentPlayerIndex;
            final isPlaced = index < currentPlayerIndex;

            return Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.35)
                    : isPlaced
                        ? AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.15)
                        : Colors.black45,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.getPlayerPrimary(player.color)
                      : Colors.white24,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.getPlayerPrimary(player.color),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPlaced ? '✓' : '',
                    style: GoogleFonts.bangers(
                      fontSize: 14,
                      color: isCurrent ? const Color(0xFFFFD54F) : Colors.white70,
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

  Widget _buildInstructions(Player currentPlayer) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1C0C).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8D6E63), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.getPlayerPrimary(currentPlayer.color),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${currentPlayer.name}, tap a highlighted hex to place your herd',
              style: GoogleFonts.bangers(
                fontSize: 14,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
