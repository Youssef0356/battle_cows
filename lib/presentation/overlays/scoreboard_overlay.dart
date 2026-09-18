import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/challenge_mode.dart';
import '../../core/constants/colors.dart';

class ScoreboardOverlay extends StatefulWidget {
  final BattleCowsGame game;

  const ScoreboardOverlay({super.key, required this.game});

  @override
  State<ScoreboardOverlay> createState() => _ScoreboardOverlayState();
}

class _ScoreboardOverlayState extends State<ScoreboardOverlay>
    with SingleTickerProviderStateMixin {
  late final void Function() _stateListener;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _stateListener = () {
      if (mounted) setState(() {});
    };
    widget.game.addStateListener(_stateListener);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    widget.game.removeStateListener(_stateListener);
    _pulseController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final players = widget.game.players;
    if (players.isEmpty) return const SizedBox.shrink();
    final cowCounts = widget.game.cowCounts;
    final territoryCounts = widget.game.territoryCounts;
    final currentColor = widget.game.engine.players.isEmpty ? players.first.color : widget.game.engine.currentPlayer.color;
    final isFenceMode = widget.game.challengeMode == ChallengeMode.fenceChallenge;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 72, left: 16, right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4E342E),
                  Color(0xFF3E2723),
                  Color(0xFF4E342E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF8D6E63), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, _) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: players.map((player) {
                    final isActive = currentColor == player.color;
                    final cows = cowCounts[player.color] ?? 0;
                    final territory = territoryCounts[player.color] ?? 0;
                    final color = AppColors.getPlayerPrimary(player.color);
                    final fencesLeft = widget.game.getRemainingFences(player.color);

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? color.withValues(alpha: 0.22 + _pulseAnim.value * 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isActive
                              ? Border.all(
                                  color: color.withValues(alpha: _pulseAnim.value),
                                  width: 2.0,
                                )
                              : Border.all(color: Colors.white10, width: 1.0),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: _pulseAnim.value * 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  _getCowAsset(player.color),
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    player.name.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.bangers(
                                      fontSize: 11,
                                      color: isActive ? Colors.white : Colors.white70,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🐮', style: TextStyle(fontSize: 11)),
                                const SizedBox(width: 1),
                                Text(
                                  '$cows',
                                  style: GoogleFonts.bangers(
                                    fontSize: 13,
                                    color: isActive
                                        ? const Color(0xFFFFD54F)
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '♥ ${widget.game.playerHearts[player.color] ?? 3}',
                                  style: GoogleFonts.bangers(
                                    fontSize: 11,
                                    color: const Color(0xFFFF8A80),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('🏴', style: TextStyle(fontSize: 11)),
                                const SizedBox(width: 1),
                                Text(
                                  '$territory',
                                  style: GoogleFonts.bangers(
                                    fontSize: 13,
                                    color: isActive
                                        ? const Color(0xFFFFD54F)
                                        : Colors.white,
                                  ),
                                ),
                                if (isFenceMode) ...[
                                  const SizedBox(width: 6),
                                  Text('🪵', style: TextStyle(fontSize: 10)),
                                  Text(
                                    '$fencesLeft',
                                    style: GoogleFonts.bangers(
                                      fontSize: 12,
                                      color: const Color(0xFFFFCC80),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
