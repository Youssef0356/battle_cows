import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../game/models/challenge_mode.dart';
import '../widgets/cartoon_dialog.dart';
import '../widgets/kenney_button.dart';

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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerBox() {
    final timeRemaining = game.timeRemaining;
    final hasTimer = game.challengeMode.hasTimer;
    final isLowTime = hasTimer && timeRemaining <= 10;
    final isFenceBattle = game.challengeMode == ChallengeMode.fenceChallenge;

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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowTime ? const Color(0xFFFF5252) : const Color(0xFF8D6E63),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isLowTime
                ? const Color(0xFFD32F2F).withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 2),
            blurRadius: isLowTime ? 8 : 4,
          ),
        ],
      ),
      child: hasTimer
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: (timeRemaining / 60.0).clamp(0.0, 1.0),
                        strokeWidth: 3.0,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isLowTime ? const Color(0xFFFF5252) : const Color(0xFFFFD54F),
                        ),
                      ),
                      Text(
                        '',
                        style: GoogleFonts.bangers(
                          fontSize: 11,
                          color: isLowTime ? const Color(0xFFFF5252) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⏱️ TIME',
                      style: GoogleFonts.bangers(
                        fontSize: 9,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      isLowTime ? 'HURRY!' : 'RUNNING',
                      style: GoogleFonts.bangers(
                        fontSize: 10,
                        color: isLowTime ? const Color(0xFFFF8A80) : const Color(0xFFFFD54F),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isFenceBattle ? '🪵 FENCES' : '🎮 FREE PLAY',
                  style: GoogleFonts.bangers(
                    fontSize: 10,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  isFenceBattle ? 'BATTLE' : '∞',
                  style: GoogleFonts.bangers(
                    fontSize: 18,
                    color: const Color(0xFFFFD54F),
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
        CartoonDialog.show(
          context: context,
          title: 'GAME PAUSED',
          maxWidth: 340,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KenneyButton(
                label: 'RESTART MATCH',
                icon: Icons.refresh_rounded,
                isWide: true,
                onPressed: () {
                  Navigator.pop(context);
                  game.rematch();
                },
              ),
              const SizedBox(height: 10),
              KenneyButton(
                label: 'RESET BOARD',
                icon: Icons.restart_alt_rounded,
                isWide: true,
                style: KenneyBtnStyle.neutral,
                onPressed: () {
                  Navigator.pop(context);
                  game.resetBoard();
                },
              ),
              const SizedBox(height: 10),
              KenneyButton(
                label: 'EXIT TO MAIN MENU',
                icon: Icons.exit_to_app_rounded,
                isWide: true,
                style: KenneyBtnStyle.danger,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 14),
              Text(
                'TABLE BACKGROUND',
                style: GoogleFonts.bangers(fontSize: 12, color: Colors.white70, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBackgroundButton(
                    context,
                    'TABLE',
                    'assets/images/Background/Table image.jpg',
                  ),
                  const SizedBox(width: 8),
                   _buildBackgroundButton(
                     context,
                     'WOOD',
                     'assets/images/Background/Wood planks.jpg',
                   ),
                  const SizedBox(width: 8),
                  _buildBackgroundButton(
                    context,
                    'FARM',
                    'assets/images/Background/Farm field.jpg',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: KenneyButton(
                      label: 'SHARE',
                      icon: Icons.share_rounded,
                      style: KenneyBtnStyle.neutral,
                      fontSize: 13,
                      height: 42,
                      isWide: true,
                      onPressed: () {
                        Share.share(
                          'Check out Battle Cows! Round up, rampage, repeat! 🐮 https://play.google.com/store/apps/details?id=com.battlecows.game',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: KenneyButton(
                      label: 'RATE',
                      icon: Icons.star_rounded,
                      fontSize: 13,
                      height: 42,
                      isWide: true,
                      onPressed: () async {
                        final inAppReview = InAppReview.instance;
                        if (await inAppReview.isAvailable()) {
                          inAppReview.requestReview();
                        }
                      },
                    ),
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
}
