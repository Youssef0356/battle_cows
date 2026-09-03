import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../core/constants/colors.dart';
import '../../ads/ad_manager.dart';
import '../widgets/wood_button.dart';

class GameOverOverlay extends StatefulWidget {
  final BattleCowsGame game;
  final List<Player> players;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.players,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.game.winner;
    final territoryCounts = widget.game.territoryCounts;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.95),
                    Colors.black.withValues(alpha: 0.99),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildConfetti(),
                  const Text('\ud83c\udfc6', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  Text(
                    winner != null
                        ? '${_getPlayerName(winner)} WINS!'
                        : 'DRAW!',
                    style: GoogleFonts.bangers(
                      fontSize: 32,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'FINAL TERRITORY',
                          style: GoogleFonts.bangers(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...territoryCounts.entries.map((entry) {
                          final color = entry.key;
                          final count = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.getPlayerPrimary(color),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_getPlayerName(color)}: $count',
                                  style: GoogleFonts.bangers(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStatsSection(),
                  const SizedBox(height: 20),
                  _buildSecondChanceButton(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: WoodButton(
                          label: 'MENU',
                          width: double.infinity,
                          height: 50,
                          fontSize: 18,
                          baseColor: AppColors.secondaryAction,
                          onPressed: () {
                            AdManager().showInterstitialAd(
                              onAdDismissed: () {
                                widget.game.overlays.remove('GameOver');
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: WoodButton(
                          label: 'REMATCH',
                          width: double.infinity,
                          height: 50,
                          fontSize: 18,
                          baseColor: AppColors.primaryAction,
                          onPressed: () {
                            AdManager().showInterstitialAd(
                              onAdDismissed: () {
                                widget.game.overlays.remove('GameOver');
                                widget.game.rematch();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getPlayerName(PlayerColor color) {
    final player = widget.players.firstWhere((p) => p.color == color);
    return player.name.toUpperCase();
  }

  Widget _buildSecondChanceButton() {
    return WoodButton(
      label: 'WATCH AD FOR SECOND CHANCE',
      icon: Icons.play_arrow,
      width: double.infinity,
      height: 44,
      fontSize: 14,
      baseColor: AppColors.yellow,
      onPressed: () {
        AdManager().showRewardedAd(
          onUserEarnedReward: (reward) {
            Navigator.of(context).pop();
            widget.game.overlays.remove('GameOver');
            widget.game.rematch();
          },
        );
      },
    );
  }

  Widget _buildStatsSection() {
    final game = widget.game;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Text(
            'GAME STATS',
            style: GoogleFonts.bangers(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('TURNS', '${game.totalMoves}'),
              _buildStatItem('YOUR COWS', '${game.cowCounts[widget.players.isNotEmpty ? widget.players[0].color : null] ?? 0}'),
              _buildStatItem('CPU COWS', '${game.cowCounts[widget.players.length > 1 ? widget.players[1].color : null] ?? 0}'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('YOUR CAPTURES', '${game.capturesPerPlayer[widget.players.isNotEmpty ? widget.players[0].color : null] ?? 0}'),
              _buildStatItem('CPU CAPTURES', '${game.capturesPerPlayer[widget.players.length > 1 ? widget.players[1].color : null] ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.bangers(
            fontSize: 20,
            color: const Color(0xFFFFD54F),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.bangers(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildConfetti() {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final particles = <Widget>[];
          final random = Random(42);
          for (int i = 0; i < 15; i++) {
            final x = random.nextDouble() * 280;
            final startY = -10.0;
            final endY = 40.0;
            final currentY =
                startY + (endY - startY) * _controller.value;
            final color = [
              AppColors.yellow,
              AppColors.primaryAction,
              AppColors.red,
              AppColors.blue,
              AppColors.purple,
            ][i % 5];

            particles.add(
              Positioned(
                left: x,
                top: currentY,
                child: Transform.rotate(
                  angle: _controller.value * 3.14 * 2 * (i.isEven ? 1 : -1),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius:
                          BorderRadius.circular(i.isEven ? 4 : 1),
                    ),
                  ),
                ),
              ),
            );
          }
          return Stack(children: particles);
        },
      ),
    );
  }
}
