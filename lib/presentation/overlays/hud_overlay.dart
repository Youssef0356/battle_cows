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
                    trophies: 1250,
                  ),
                const Spacer(),
                _buildCenterLogoPlaque(),
                const Spacer(),
                if (p2 != null)
                  _buildPlayerBanner(
                    player: p2,
                    isLeft: false,
                    isActive: currentPlayer.color == p2.color,
                    trophies: 1180,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Secondary row: Turn Counter (Left) & Settings Button (Right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
    required int trophies,
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
                    _buildPlayerDetails(player.name, trophies),
                  ]
                : [
                    _buildPlayerDetails(player.name, trophies),
                    const SizedBox(width: 6),
                    _buildAvatarCircle(),
                  ],
          ),
        ),
        const SizedBox(height: 4),
        // Turn dot indicators
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? color : Colors.white24,
                border: Border.all(color: Colors.white, width: 0.8),
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

  Widget _buildPlayerDetails(String name, int trophies) {
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
        Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 10)),
            Text(
              ' $trophies',
              style: GoogleFonts.bangers(
                fontSize: 11,
                color: const Color(0xFFFFECB3),
              ),
            ),
          ],
        ),
      ],
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
            '$turn / 30',
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D4037)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    game.rematch();
                  },
                  child: Text('RESTART MATCH', style: GoogleFonts.bangers(color: Colors.white)),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text('EXIT TO MAIN MENU', style: GoogleFonts.bangers(color: Colors.white)),
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
          border: Border.all(color: const Color(0xFF8D6E63), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.settings, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
