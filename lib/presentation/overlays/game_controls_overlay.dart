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
    final movingCount = game.selectedSplitCount.clamp(0, max(maxMoving, 1)).toInt();
    final playerColor = herd?.owner ?? game.engine.currentPlayer.color;
    final currentPlayer = game.engine.players.isEmpty ? null : game.engine.currentPlayer;
    final hearts = currentPlayer != null ? (game.playerHearts[currentPlayer.color] ?? 3) : 3;

    if (currentPlayer == null) return const SizedBox.shrink();

    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(currentPlayer, hearts),
          const Spacer(),
          _buildRightPanel(
            herd: herd,
            totalCows: totalCows,
            maxMoving: maxMoving,
            movingCount: movingCount,
            playerColor: playerColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(dynamic currentPlayer, int hearts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.getPlayerPrimary(currentPlayer.color),
                  AppColors.getPlayerDark(currentPlayer.color),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '🐮',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  currentPlayer.name.toUpperCase(),
                  style: GoogleFonts.bangers(
                    fontSize: 14,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildHeartsDisplay(hearts),
        ],
      ),
    );
  }

  Widget _buildHeartsDisplay(int hearts) {
    return Row(
      children: List.generate(3, (index) {
        final isLost = index >= hearts;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLost ? Colors.grey.shade800 : const Color(0xFFD32F2F),
              border: Border.all(
                color: isLost ? Colors.grey.shade600 : const Color(0xFFFF5252),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '❤',
                style: TextStyle(
                  fontSize: 13,
                  color: isLost ? Colors.grey.shade600 : Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRightPanel({
    dynamic herd,
    required int totalCows,
    required int maxMoving,
    required int movingCount,
    required dynamic playerColor,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3E2723),
              Color(0xFF4E342E),
              Color(0xFF3E2723),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: herd != null
                ? AppColors.getPlayerPrimary(herd.owner).withValues(alpha: 0.6)
                : const Color(0xFF6D4C41),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SPLIT',
              style: GoogleFonts.bangers(
                fontSize: 11,
                color: const Color(0xFFFFD54F),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            if (herd != null && totalCows >= 2) ...[
              // Total cows display
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.getPlayerPrimary(herd.owner).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.getPlayerPrimary(herd.owner),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🐮', style: TextStyle(fontSize: 16)),
                    Text(
                      '$totalCows',
                      style: GoogleFonts.bangers(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Arrow down
              Icon(
                Icons.arrow_downward,
                color: const Color(0xFFFFD54F).withValues(alpha: 0.7),
                size: 16,
              ),
              const SizedBox(height: 4),
              // Move count display
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF66BB6A),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('➡', style: TextStyle(fontSize: 14)),
                    Text(
                      '$movingCount',
                      style: GoogleFonts.bangers(
                        fontSize: 16,
                        color: const Color(0xFF66BB6A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // + button
              _buildAdjustButton(Icons.add, () {
                widget.game.setSplitCount(movingCount + 1);
              }),
              const SizedBox(height: 6),
              // - button
              _buildAdjustButton(Icons.remove, () {
                widget.game.setSplitCount(movingCount - 1);
              }),
              const SizedBox(height: 10),
              // Stay count label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${totalCows - movingCount} STAY',
                  style: GoogleFonts.bangers(
                    fontSize: 8,
                    color: Colors.white54,
                  ),
                ),
              ),
            ] else ...[
              // No herd selected state
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text('🐮', style: TextStyle(fontSize: 20, color: Colors.white24)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'TAP\nHERD',
                textAlign: TextAlign.center,
                style: GoogleFonts.bangers(
                  fontSize: 9,
                  color: Colors.white38,
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF5D4037),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF8D6E63), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFFFFD54F),
          size: 20,
        ),
      ),
    );
  }
}
