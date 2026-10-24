import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../flame/battle_cows_game.dart';
import '../../core/constants/colors.dart';
import '../../game/models/challenge_mode.dart';

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
  late final void Function() _stateListener;

  @override
  void initState() {
    super.initState();
    _stateListener = () {
      if (mounted) setState(() {});
    };
    widget.game.addStateListener(_stateListener);
  }

  @override
  void dispose() {
    widget.game.removeStateListener(_stateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = widget.game;
    final selectedPos = game.selectedPosition;
    final herd = selectedPos != null ? game.engine.board?.getHerdAt(selectedPos) : null;
    final totalCows = herd?.size ?? 0;
    final maxMoving = max(0, totalCows - 1);
    final movingCount = game.selectedSplitCount.clamp(0, max(maxMoving, 1)).toInt();
    final currentPlayer = game.engine.players.isEmpty ? null : game.engine.currentPlayer;

    if (currentPlayer == null) return const SizedBox.shrink();

    final isFenceChallenge = game.challengeMode == ChallengeMode.fenceChallenge;
    final isMyTurn = !currentPlayer.isAi && !game.isGameOver;
    final remainingFences = game.getRemainingFences(currentPlayer.color);

    return SafeArea(
      child: Column(
        children: [
          const Expanded(child: IgnorePointer(child: SizedBox.expand())),
          if (isFenceChallenge && isMyTurn)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _buildFenceActionBar(game, currentPlayer, remainingFences, l10n),
            ),
          _buildMoveBar(
            herd: herd,
            totalCows: totalCows,
            maxMoving: maxMoving,
            movingCount: movingCount,
            l10n: l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildFenceActionBar(BattleCowsGame game, dynamic currentPlayer, int remainingFences, AppLocalizations l10n) {
    final isFenceMode = game.isFenceMode;
    final hasSelectedFence = game.selectedFencePosition != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFenceMode
              ? [const Color(0xFF6D4C41), const Color(0xFF3E2723)]
              : [const Color(0xFF4E342E), const Color(0xFF2E1C0C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFenceMode ? const Color(0xFFFFD54F) : const Color(0xFF8D6E63),
          width: isFenceMode ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isFenceMode
                ? const Color(0xFFFFD54F).withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.5),
            blurRadius: isFenceMode ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🪵', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isFenceMode
                      ? (hasSelectedFence ? l10n.relocateFence : l10n.placeFence)
                      : l10n.fencesCount(remainingFences, 3),
                  style: AppFonts.bangers(
                    fontSize: 14,
                    color: isFenceMode ? const Color(0xFFFFD54F) : Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  isFenceMode
                      ? (hasSelectedFence
                          ? l10n.tapEmptyToDrop
                          : (remainingFences > 0 ? l10n.tapEmptyToPlace : l10n.tapFenceToMove))
                      : l10n.blockEnemyPaths,
                  style: AppFonts.bangers(
                    fontSize: 10,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              game.toggleFenceMode();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isFenceMode
                      ? [const Color(0xFFD32F2F), const Color(0xFF8B0000)]
                      : [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isFenceMode ? const Color(0xFFFF8A80) : const Color(0xFFA5D6A7),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Text(
                isFenceMode ? l10n.cancel : l10n.use,
                style: AppFonts.bangers(
                  fontSize: 12,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveBar({
    dynamic herd,
    required int totalCows,
    required int maxMoving,
    required int movingCount,
    required AppLocalizations l10n,
  }) {
    final hasHerd = herd != null && totalCows >= 2;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasHerd
              ? [const Color(0xFF4E342E), const Color(0xFF2E1C0C)]
              : [const Color(0xFF3E2723), const Color(0xFF24140E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: herd != null
              ? AppColors.getPlayerPrimary(herd.owner)
              : const Color(0xFF6D4C41),
          width: hasHerd ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: herd != null
                ? AppColors.getPlayerPrimary(herd.owner).withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: hasHerd
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🐮 ', style: TextStyle(fontSize: 14)),
                        Text(
                          l10n.splitHerdTotal(totalCows),
                          style: AppFonts.bangers(
                            fontSize: 13,
                            color: const Color(0xFFFFD54F),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.game.clearSelection();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          l10n.deselect,
                          style: AppFonts.bangers(
                            fontSize: 10,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Stepper minus
                    GestureDetector(
                      onTap: movingCount > 1
                          ? () => widget.game.setSplitCount(movingCount - 1)
                          : null,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: movingCount > 1
                              ? const Color(0xFF5D4037)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: movingCount > 1 ? const Color(0xFFFFD54F) : Colors.white12,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: movingCount > 1 ? Colors.white : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Split slider (horizontal)
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFF66BB6A),
                          inactiveTrackColor: Colors.white24,
                          thumbColor: const Color(0xFFFFD54F),
                          overlayColor:
                              const Color(0xFFFFD54F).withValues(alpha: 0.25),
                          trackHeight: 6,
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          value: movingCount.toDouble(),
                          min: 1,
                          max: maxMoving.toDouble(),
                          divisions: maxMoving > 1 ? maxMoving - 1 : null,
                          onChanged: (value) =>
                              widget.game.setSplitCount(value.round()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Stepper plus
                    GestureDetector(
                      onTap: movingCount < maxMoving
                          ? () => widget.game.setSplitCount(movingCount + 1)
                          : null,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: movingCount < maxMoving
                              ? const Color(0xFF5D4037)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: movingCount < maxMoving ? const Color(0xFFFFD54F) : Colors.white12,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 18,
                            color: movingCount < maxMoving ? Colors.white : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Quick preset buttons and summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quick preset buttons
                    Row(
                      children: [
                        _buildQuickSplitChip(l10n.quickOneCow, 1, movingCount),
                        if (maxMoving >= 4) ...[
                          const SizedBox(width: 6),
                          _buildQuickSplitChip(l10n.quickHalf, totalCows ~/ 2, movingCount),
                        ],
                        if (maxMoving >= 2) ...[
                          const SizedBox(width: 6),
                          _buildQuickSplitChip(l10n.quickMax(maxMoving), maxMoving, movingCount),
                        ],
                      ],
                    ),
                    // Visual breakdown badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF66BB6A).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.stayCount(totalCows - movingCount),
                            style: AppFonts.bangers(fontSize: 11, color: Colors.white70),
                          ),
                          const Text(' ➜ ', style: TextStyle(fontSize: 10, color: Color(0xFFFFD54F))),
                          Text(
                            l10n.moveCount(movingCount),
                            style: AppFonts.bangers(fontSize: 12, color: const Color(0xFF66BB6A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text('🐮', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.tapHerdPrompt,
                    style: AppFonts.bangers(
                      fontSize: 12,
                      color: const Color(0xFFFFD54F),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickSplitChip(String label, int targetValue, int currentCount) {
    final isSelected = targetValue == currentCount;
    return GestureDetector(
      onTap: () => widget.game.setSplitCount(targetValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E7D32)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF81C784) : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppFonts.bangers(
            fontSize: 10,
            color: isSelected ? Colors.white : Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
