import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../core/constants/colors.dart';

class ScoreboardOverlay extends StatefulWidget {
  final BattleCowsGame game;

  const ScoreboardOverlay({super.key, required this.game});

  @override
  State<ScoreboardOverlay> createState() => _ScoreboardOverlayState();
}

class _ScoreboardOverlayState extends State<ScoreboardOverlay> {
  @override
  void initState() {
    super.initState();
    widget.game.onStateChanged = () {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.game.players;
    final cowCounts = widget.game.cowCounts;
    final territoryCounts = widget.game.territoryCounts;
    final currentColor = widget.game.engine.currentPlayer.color;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 72, left: 12, right: 12),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: players.map((player) {
                final isActive = currentColor == player.color;
                final cows = cowCounts[player.color] ?? 0;
                final territory = territoryCounts[player.color] ?? 0;
                final color = AppColors.getPlayerPrimary(player.color);

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? color.withValues(alpha: 0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isActive
                          ? Border.all(color: color, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          player.name.toUpperCase(),
                          style: GoogleFonts.bangers(
                            fontSize: 11,
                            color: isActive ? Colors.white : Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🐮', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 2),
                            Text(
                              '$cows',
                              style: GoogleFonts.bangers(
                                fontSize: 14,
                                color: isActive
                                    ? const Color(0xFFFFD54F)
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('🏴', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 2),
                            Text(
                              '$territory',
                              style: GoogleFonts.bangers(
                                fontSize: 14,
                                color: isActive
                                    ? const Color(0xFFFFD54F)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
