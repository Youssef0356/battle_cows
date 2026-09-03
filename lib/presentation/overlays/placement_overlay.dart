import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../core/constants/colors.dart';

class PlacementOverlay extends StatefulWidget {
  final BattleCowsGame game;

  const PlacementOverlay({
    super.key,
    required this.game,
  });

  @override
  State<PlacementOverlay> createState() => _PlacementOverlayState();
}

class _PlacementOverlayState extends State<PlacementOverlay> {
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
    final currentPlayerIndex = game.currentPlayerIndex;
    final players = game.players;
    final tilesRemaining = game.tilesRemaining;
    final currentTile = game.currentTile;
    final canPlace = game.canPlaceCurrentTile;
    final isAi = players[currentPlayerIndex].isAi;

    return SafeArea(
      child: Column(
        children: [
          // Top bar with player info
          _buildTopBar(currentPlayerIndex, players, tilesRemaining),
          const Spacer(),
          // Bottom controls
          if (!isAi && currentTile != null)
            _buildBottomControls(canPlace),
        ],
      ),
    );
  }

  Widget _buildTopBar(int currentPlayerIndex, List<Player> players, List<int> tilesRemaining) {
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
              'BUILD THE PASTURE',
              style: GoogleFonts.bangers(
                fontSize: 16,
                color: const Color(0xFFFFD54F),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Spacer(),
          // Player indicators
          ...List.generate(players.length, (index) {
            final player = players[index];
            final isCurrent = index == currentPlayerIndex;
            final tilesLeft = tilesRemaining[index];

            return Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.35)
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
                    '$tilesLeft',
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

  Widget _buildBottomControls(bool canPlace) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1C0C).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8D6E63), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Rotate button
          _buildControlButton(
            label: 'ROTATE',
            icon: Icons.rotate_right_rounded,
            onTap: () => widget.game.rotateCurrentTile(),
          ),
          // Place button
          _buildControlButton(
            label: 'PLACE',
            icon: Icons.add_circle_outline,
            color: canPlace ? const Color(0xFF66BB6A) : Colors.grey,
            onTap: canPlace ? () => widget.game.placeCurrentTile() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    Color color = const Color(0xFF5D4037),
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8D6E63), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.bangers(
                fontSize: 14,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
