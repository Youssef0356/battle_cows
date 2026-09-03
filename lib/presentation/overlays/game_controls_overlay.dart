import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icony/icony_gameicons.dart';
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
  late final VoidCallback _updateListener;

  @override
  void initState() {
    super.initState();
    _updateListener = () {
      if (mounted) setState(() {});
    };
    widget.game.addStateListener(_updateListener);
  }

  @override
  void dispose() {
    widget.game.removeStateListener(_updateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    if (game.engine.players.isEmpty) return const SizedBox.shrink();
    final selectedPos = game.selectedPosition;
    final herd = selectedPos != null ? game.engine.board?.getHerdAt(selectedPos) : null;
    final totalCows = herd?.size ?? 0;
    final maxMoving = max(0, totalCows - 1);
    final movingCount = game.selectedSplitCount.clamp(0, maxMoving);
    final playerColor = herd?.owner ?? game.engine.currentPlayer.color;
    final hearts = game.playerHearts[game.engine.currentPlayer.color] ?? 3;
    final screenW = MediaQuery.of(context).size.width;
    final panelWidth = (screenW - 32).clamp(0.0, 480.0);

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Hearts display
          _buildHeartsDisplay(hearts),
          const SizedBox(height: 8),
          // Split controls (only when herd selected)
          if (herd != null && totalCows >= 2)
            _buildSplitControls(
              totalCows: totalCows,
              maxMoving: maxMoving,
              movingCount: movingCount,
              playerColor: playerColor,
            ),
          const SizedBox(height: 8),
          // Instruction banner
          SizedBox(
            width: panelWidth,
            child: _buildParchmentBanner(herd != null, movingCount, maxMoving),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeartsDisplay(int hearts) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isLost = index >= hearts;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLost ? Colors.grey.shade800 : const Color(0xFFD32F2F),
              border: Border.all(
                color: isLost ? Colors.grey.shade600 : const Color(0xFFFF5252),
                width: 2,
              ),
              boxShadow: isLost
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFFD32F2F).withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Center(
              child: GameIcons(
                GameIcons.heart_beats,
                width: 18,
                height: 18,
                color: isLost ? Colors.grey.shade600 : Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSplitControls({
    required int totalCows,
    required int maxMoving,
    required int movingCount,
    required dynamic playerColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6B4F12),
            Color(0xFF5C3D0E),
            Color(0xFF8B6914),
            Color(0xFF5C3D0E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA0792A), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFFD4A84B).withValues(alpha: 0.2),
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MOVE COWS',
                style: GoogleFonts.bangers(
                  fontSize: 13,
                  color: const Color(0xFFFFF3D6),
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$totalCows TOTAL',
                  style: GoogleFonts.bangers(
                    fontSize: 11,
                    color: const Color(0xFFFFF3D6).withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Split count display with +/- buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minus button
              _buildStepperButton(
                icon: Icons.remove,
                onTap: movingCount > 1
                    ? () => widget.game.setSplitCount(movingCount - 1)
                    : null,
              ),
              const SizedBox(width: 12),
              // Count display
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.getPlayerPrimary(playerColor),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getPlayerPrimary(playerColor).withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GameIcons(
                          GameIcons.cow,
                          width: 20,
                          height: 20,
                          color: const Color(0xFFFFF3D6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'x$movingCount',
                          style: GoogleFonts.bangers(
                            fontSize: 22,
                            color: const Color(0xFFFFF3D6),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'WILL MOVE',
                      style: GoogleFonts.bangers(
                        fontSize: 8,
                        color: const Color(0xFFFFF3D6).withValues(alpha: 0.7),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Plus button
              _buildStepperButton(
                icon: Icons.add,
                onTap: movingCount < maxMoving
                    ? () => widget.game.setSplitCount(movingCount + 1)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Quick select buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickButton('1', () {
                widget.game.setSplitCount(1);
              }),
              const SizedBox(width: 8),
              if (maxMoving >= 2)
                _buildQuickButton('${(totalCows / 2).floor()}', () {
                  widget.game.setSplitCount((totalCows / 2).floor().clamp(1, maxMoving));
                }),
              if (maxMoving >= 2) const SizedBox(width: 8),
              if (maxMoving >= 3)
                _buildQuickButton('${(totalCows * 2 / 3).floor()}', () {
                  widget.game.setSplitCount((totalCows * 2 / 3).floor().clamp(1, maxMoving));
                }),
              if (maxMoving >= 3) const SizedBox(width: 8),
              _buildQuickButton('MAX', () {
                widget.game.setSplitCount(maxMoving);
              }),
            ],
          ),
          const SizedBox(height: 6),
          // Stay count info
          Text(
            '${totalCows - movingCount} cow${totalCows - movingCount != 1 ? 's' : ''} will stay behind',
            style: GoogleFonts.bangers(
              fontSize: 11,
              color: const Color(0xFFFFF3D6).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [Color(0xFF8B6914), Color(0xFF6B4F12)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade800, Colors.grey.shade900],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? const Color(0xFFD4A84B) : Colors.grey.shade600,
            width: 2,
          ),
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
          color: isEnabled ? const Color(0xFFFFF3D6) : Colors.grey.shade500,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B6914), Color(0xFF6B4F12)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD4A84B), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.bangers(
            fontSize: 14,
            color: const Color(0xFFFFF3D6),
          ),
        ),
      ),
    );
  }

  Widget _buildParchmentBanner(bool hasSelected, int moving, int maxMove) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD7CCC8),
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
      child: Text(
        hasSelected
            ? 'Moving $moving cows (leaving ${maxMove - moving + 1}). Tap a highlighted tile.'
            : 'Select a stack with 2+ cows to move across the pasture.',
        textAlign: TextAlign.center,
        style: GoogleFonts.bangers(
          fontSize: 12,
          color: const Color(0xFF3E2723),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
