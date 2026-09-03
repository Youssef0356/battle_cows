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
    final currentPlayer = game.engine.currentPlayer;
    final turnCount = game.engine.turnCount + 1;
    final p1 = players.isNotEmpty ? players[0] : null;
    final p2 = players.length > 1 ? players[1] : null;
    final p1Hearts = p1 != null ? (game.playerHearts[p1.color] ?? 3) : 3;
    final p2Hearts = p2 != null ? (game.playerHearts[p2.color] ?? 3) : 3;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            // Top Row: P1 Banner, Center Logo Plaque, P2 Banner
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p1 != null)
                  _buildPlayerBanner(
                    player: p1,
                    isLeft: true,
                    isActive: currentPlayer.color == p1.color,
                    hearts: p1Hearts,
                  ),
                const Spacer(),
                _buildCenterLogoPlaque(),
                const Spacer(),
                if (p2 != null)
                  _buildPlayerBanner(
                    player: p2,
                    isLeft: false,
                    isActive: currentPlayer.color == p2.color,
                    hearts: p2Hearts,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Secondary row: Timer & Turn Counter & Settings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimerBox(),
                _buildTurnCounterBox(turnCount),
                _buildSettingsButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterLogoPlaque() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3E2723),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🐮', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            'BATTLE COWS',
            style: GoogleFonts.bangers(
              fontSize: 13,
              color: const Color(0xFFFFD54F),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBanner({
    required Player player,
    required bool isLeft,
    required bool isActive,
    required int hearts,
  }) {
    final color = AppColors.getPlayerPrimary(player.color);
    final darkColor = AppColors.getPlayerDark(player.color);

    return Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, darkColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLeft ? 14 : 6),
              bottomLeft: Radius.circular(isLeft ? 14 : 6),
              topRight: Radius.circular(isLeft ? 6 : 14),
              bottomRight: Radius.circular(isLeft ? 6 : 14),
            ),
            border: Border.all(
              color: isActive ? Colors.white : Colors.white54,
              width: isActive ? 2.5 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isLeft
                ? [
                    _buildAvatarCircle(),
                    const SizedBox(width: 6),
                    _buildPlayerDetails(player.name),
                  ]
                : [
                    _buildPlayerDetails(player.name),
                    const SizedBox(width: 6),
                    _buildAvatarCircle(),
                  ],
          ),
        ),
        const SizedBox(height: 4),
        // Hearts display
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final isLost = i >= hearts;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLost ? Colors.grey.shade700 : const Color(0xFFD32F2F),
                border: Border.all(
                  color: isLost ? Colors.grey.shade600 : const Color(0xFFFF5252),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '❤️',
                  style: TextStyle(
                    fontSize: 8,
                    color: isLost ? Colors.grey.shade600 : Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAvatarCircle() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: const Center(
        child: Text('🐮', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildPlayerDetails(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name.toUpperCase(),
          style: GoogleFonts.bangers(
            fontSize: 12,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerBox() {
    final timeRemaining = game.timeRemaining;
    final isLowTime = timeRemaining <= 10;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLowTime
              ? [const Color(0xFF8B0000), const Color(0xFF4E0000)]
              : [const Color(0xFF4E342E), const Color(0xFF2E1C0C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLowTime ? const Color(0xFFFF5252) : const Color(0xFF8D6E63),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isLowTime
                ? const Color(0xFFD32F2F).withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '⏱️ TIME',
            style: GoogleFonts.bangers(
              fontSize: 10,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          Text(
            '$timeRemaining',
            style: GoogleFonts.bangers(
              fontSize: 20,
              color: isLowTime ? const Color(0xFFFF5252) : const Color(0xFFFFD54F),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnCounterBox(int turn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4E342E), Color(0xFF2E1C0C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF8D6E63), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TURN',
            style: GoogleFonts.bangers(
              fontSize: 10,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          Text(
            '$turn',
            style: GoogleFonts.bangers(
              fontSize: 16,
              color: const Color(0xFFFFD54F),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF2E1C0C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFFFD54F), width: 2),
            ),
            title: Text(
              'GAME PAUSED',
              style: GoogleFonts.bangers(fontSize: 22, color: const Color(0xFFFFD54F)),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPauseButton(
                  label: 'RESTART MATCH',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    Navigator.pop(ctx);
                    game.rematch();
                  },
                ),
                const SizedBox(height: 12),
                _buildPauseButton(
                  label: 'RESET BOARD',
                  icon: Icons.restart_alt_rounded,
                  onPressed: () {
                    Navigator.pop(ctx);
                    game.resetBoard();
                  },
                ),
                const SizedBox(height: 12),
                _buildPauseButton(
                  label: 'EXIT TO MAIN MENU',
                  icon: Icons.exit_to_app_rounded,
                  baseColor: const Color(0xFF8B2500),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
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
        child: const Center(
          child: Icon(Icons.settings, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildPauseButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color baseColor = const Color(0xFF5D4037),
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [baseColor, baseColor.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF8D6E63), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
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
