import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flame/battle_cows_game.dart';
import '../../core/constants/colors.dart';

class GameControlsOverlay extends StatelessWidget {
  final BattleCowsGame game;

  const GameControlsOverlay({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final selectedMove = game.selectedMove;
    final splitCount = game.splitCount;
    final canConfirm = selectedMove != null;
    final maxSplit = selectedMove != null
        ? (game.engine.board?.getHerdAt(game.selectedPosition!)?.size ?? 2) - 1
        : 1;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canConfirm) ...[
                Text(
                  'SPLIT: $splitCount / ${selectedMove.stayCount + splitCount}',
                  style: GoogleFonts.bangers(
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primaryAction,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                    thumbColor: AppColors.primaryAction,
                    overlayColor: AppColors.primaryAction.withValues(alpha: 0.2),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: splitCount.toDouble(),
                    min: 1,
                    max: maxSplit.toDouble(),
                    divisions: maxSplit > 1 ? maxSplit - 1 : 1,
                    onChanged: (value) {
                      game.onSplitChanged(value.round());
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (canConfirm)
                    Expanded(
                      child: _buildButton(
                        label: 'CANCEL',
                        color: AppColors.secondaryAction,
                        onPressed: () => game.cancelMove(),
                      ),
                    ),
                  if (canConfirm) const SizedBox(width: 12),
                  Expanded(
                    child: _buildButton(
                      label: canConfirm ? 'MOVE!' : 'SELECT COW',
                      color: canConfirm ? AppColors.primaryAction : Colors.grey,
                      onPressed: canConfirm ? () => game.confirmMove() : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.bangers(
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
