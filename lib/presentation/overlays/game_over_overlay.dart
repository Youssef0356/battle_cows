import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../core/constants/colors.dart';
import '../../ads/ad_manager.dart';
import '../../data/services/progress_service.dart';
import '../widgets/kenney_button.dart';
import '../widgets/cartoon_dialog.dart';

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
    _checkRatePrompt();
  }

  Future<void> _checkRatePrompt() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final progress = await ProgressService.getInstance();
    if (progress.shouldShowRatePrompt) {
      progress.markRatePromptShown();
      if (!mounted) return;
      _showRatePrompt();
    }
  }

  void _showRatePrompt() {
    final inAppReview = InAppReview.instance;
    CartoonDialog.show(
      context: context,
      title: 'ENJOYING THE GAME?',
      accentColor: const Color(0xFFFFB74D),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rate us 5 stars to support the herd!',
            style: GoogleFonts.bangers(
              fontSize: 14,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          KenneyButton(
            label: 'RATE US',
            icon: Icons.star_rounded,
            isWide: true,
            onPressed: () async {
              Navigator.pop(context);
              if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
              }
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'MAYBE LATER',
              style: GoogleFonts.bangers(
                fontSize: 12,
                color: Colors.white54,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
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

    if (widget.players.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3E2723), Color(0xFF1B0000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD54F), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
               child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: SingleChildScrollView(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildConfetti(),
                     Image.asset(
                       'assets/images/Effects/victory_badge.png',
                       width: 96,
                       height: 96,
                     ),
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
                                  Image.asset(
                                    _getCowAsset(color),
                                    width: 26,
                                    height: 26,
                                    fit: BoxFit.contain,
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
                    Row(
                      children: [
                        Expanded(
                          child: KenneyButton(
                            label: 'MENU',
                            icon: Icons.home_rounded,
                            isWide: true,
                            style: KenneyBtnStyle.neutral,
                            fontSize: 18,
                            height: 50,
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
                          child: KenneyButton(
                            label: 'REMATCH',
                            icon: Icons.refresh_rounded,
                            isWide: true,
                            fontSize: 18,
                            height: 50,
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
            ),
          ),
        );
      },
    );
  }

  String _getPlayerName(PlayerColor color) {
    final player = widget.players.where((p) => p.color == color).firstOrNull;
    return (player?.name ?? 'UNKNOWN').toUpperCase();
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
          if (game.capturesPerPlayer.values.any((c) => c > 0)) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('YOUR CAPTURES', '${game.capturesPerPlayer[widget.players.isNotEmpty ? widget.players[0].color : null] ?? 0}'),
                _buildStatItem('CPU CAPTURES', '${game.capturesPerPlayer[widget.players.length > 1 ? widget.players[1].color : null] ?? 0}'),
              ],
            ),
          ],
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

  String _getCowAsset(PlayerColor color) {
    switch (color) {
      case PlayerColor.blue:
        return 'assets/images/Cows/cow_viking.png';
      case PlayerColor.red:
        return 'assets/images/Cows/cow_cowboy.png';
      case PlayerColor.yellow:
        return 'assets/images/Cows/cow_farmer.png';
      case PlayerColor.purple:
        return 'assets/images/Cows/cow_disco.png';
    }
  }
}
