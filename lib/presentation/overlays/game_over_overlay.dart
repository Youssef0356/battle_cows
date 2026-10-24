import 'dart:math';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../game/utils/cow_skin_loader.dart';
import '../../core/constants/colors.dart';
import '../../ads/ad_manager.dart';
import '../../data/services/progress_service.dart';
import '../widgets/kenney_button.dart';
import '../widgets/cartoon_dialog.dart';

class GameOverOverlay extends StatefulWidget {
  final BattleCowsGame game;
  final List<Player> players;

  /// Equipped skin id of the local player (empty = none). Used to render
  /// the local player's cow with their purchased skin.
  final String localSkin;

  /// Coins earned from this match, shown as a reward line.
  final int coinsEarned;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.players,
    this.localSkin = '',
    this.coinsEarned = 0,
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
    final l10n = AppLocalizations.of(context);
    final inAppReview = InAppReview.instance;
    CartoonDialog.show(
      context: context,
      title: l10n.enjoyingTheGame,
      accentColor: const Color(0xFFFFB74D),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.rateUsPrompt,
            style: AppFonts.bangers(
              fontSize: 14,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          KenneyButton(
            label: l10n.rateUs,
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
              l10n.maybeLater,
              style: AppFonts.bangers(
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
    final l10n = AppLocalizations.of(context);
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
                          ? l10n.playerWins(_getPlayerName(winner))
                          : l10n.draw,
                      style: AppFonts.bangers(
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
                            l10n.finalTerritory,
                            style: AppFonts.bangers(
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
                                    style: AppFonts.bangers(
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
                    _buildStatsSection(l10n),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: KenneyButton(
                            label: l10n.menu,
                            icon: Icons.home_rounded,
                            isWide: true,
                            style: KenneyBtnStyle.neutral,
                            fontSize: 18,
                            height: 50,
                            onPressed: () {
                              if (widget.game.suppressAds) {
                                widget.game.overlays.remove('GameOver');
                                Navigator.of(context).pop();
                                return;
                              }
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
                            label: l10n.rematch,
                            icon: Icons.refresh_rounded,
                            isWide: true,
                            fontSize: 18,
                            height: 50,
                            onPressed: () {
                              if (widget.game.suppressAds) {
                                widget.game.overlays.remove('GameOver');
                                widget.game.rematch();
                                return;
                              }
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

  Widget _buildStatsSection(AppLocalizations l10n) {
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
            l10n.gameStats,
            style: AppFonts.bangers(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(l10n.statTurns, '${game.totalMoves}'),
              _buildStatItem(l10n.statYourCows, '${game.cowCounts[widget.players.isNotEmpty ? widget.players[0].color : null] ?? 0}'),
              _buildStatItem(l10n.statCpuCows, '${game.cowCounts[widget.players.length > 1 ? widget.players[1].color : null] ?? 0}'),
            ],
          ),
          if (game.capturesPerPlayer.values.any((c) => c > 0)) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(l10n.statYourCaptures, '${game.capturesPerPlayer[widget.players.isNotEmpty ? widget.players[0].color : null] ?? 0}'),
                _buildStatItem(l10n.statCpuCaptures, '${game.capturesPerPlayer[widget.players.length > 1 ? widget.players[1].color : null] ?? 0}'),
              ],
            ),
          ],
          if (widget.coinsEarned > 0) ...[
            const SizedBox(height: 10),
            Text(
              l10n.coinsEarned(widget.coinsEarned),
              style: AppFonts.bangers(
                fontSize: 16,
                color: const Color(0xFF81C784),
                letterSpacing: 1,
              ),
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
          style: AppFonts.bangers(
            fontSize: 20,
            color: const Color(0xFFFFD54F),
          ),
        ),
        Text(
          label,
          style: AppFonts.bangers(
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
    if (widget.localSkin.startsWith('skin_') &&
        color == _localPlayerColor) {
      return CowSkins.assetFor(color, skinId: widget.localSkin);
    }
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

  /// First non-AI player (the local player), or null in AI-only matches.
  PlayerColor? get _localPlayerColor {
    for (final player in widget.players) {
      if (!player.isAi) return player.color;
    }
    return null;
  }
}
