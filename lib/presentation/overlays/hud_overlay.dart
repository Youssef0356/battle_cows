import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../game/models/challenge_mode.dart';
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
    if (game.engine.players.isEmpty) return const SizedBox.shrink();
    final turnCount = game.engine.turnCount + 1;

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Align(alignment: Alignment.centerLeft, child: _buildTimerBox())),
                    Expanded(child: Center(child: _buildTurnCounterBox(turnCount))),
                    Expanded(child: Align(alignment: Alignment.centerRight, child: buildSettingsButton(context))),
                  ],
                ),
                if (game.engine.hasObjective) ...[
                  const SizedBox(height: 6),
                  _buildObjectiveBar(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildObjectiveBar() {
    final engine = game.engine;
    final target = engine.objectiveTarget;
    final icon = game.challengeMode.icon;
    final isKing = game.challengeMode == ChallengeMode.kingOfTheHill;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: players.map((player) {
        final score = engine.objectiveScores[player.color] ?? 0;
        final color = AppColors.getPlayerPrimary(player.color);
        final progress = target > 0 ? (score / target).clamp(0.0, 1.0) : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                isKing ? '${player.name} ⛰️' : player.name,
                style: GoogleFonts.bangers(fontSize: 12, color: Colors.white, letterSpacing: 1),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 46,
                height: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$score/$target',
                style: GoogleFonts.bangers(fontSize: 12, color: const Color(0xFFFFD54F)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimerBox() {
    final timeRemaining = game.timeRemaining;
    final hasTimer = game.challengeMode.hasTimer;
    final isLowTime = hasTimer && timeRemaining <= 10;
    
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
             hasTimer ? '⏱️ TIME' : '🎮 FREE PLAY',
            style: GoogleFonts.bangers(
              fontSize: 10,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
           Text(
             hasTimer ? '$timeRemaining' : '∞',
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

  Widget buildSettingsButton(BuildContext context) {
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
                const SizedBox(height: 16),
                Text(
                  'TABLE BACKGROUND',
                  style: GoogleFonts.bangers(fontSize: 12, color: Colors.white70, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBackgroundButton(
                      ctx,
                       'TABLE',
                       'assets/images/Background/Table image.jpg',
                    ),
                    const SizedBox(width: 8),
                    _buildBackgroundButton(
                      ctx,
                      'WOOD',
                      'assets/images/Background/Table image.jpg',
                    ),
                    const SizedBox(width: 8),
                    _buildBackgroundButton(
                      ctx,
                       'FARM',
                       'assets/images/Background/Background.jpg',
                    ),
                  ],
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

  Widget _buildBackgroundButton(BuildContext context, String label, String asset) {
    return GestureDetector(
      onTap: () {
        game.setBackgroundAsset(asset);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF5D4037),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF8D6E63)),
        ),
        child: Text(label, style: GoogleFonts.bangers(fontSize: 12, color: Colors.white)),
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
